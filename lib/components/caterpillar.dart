import 'dart:collection';
import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillarSegment.dart';
import 'package:caterpillar_crawl/components/snack.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/caterpillarData.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class CaterpillarElement extends PositionComponent
{
  CaterpillarSegment? nextSegment;
  CaterpillarData caterpillardata;
  CaterpillarCrawlMain gameWorld;

  late SpriteAnimationComponent animation;

  final angleQueue = Queue<MovementTransferData>(); // ListQueue() by default
  bool isInitializing = true;
  late int index;


  double secondCounter= 0;
  double timeSinceInit = 0; 
  double frameDuration = 1/2;

  double segmentTravelTime;


  bool segemntAddRequest =false;
  late Vector2 finalSize;

  CaterpillarElement(this.caterpillardata, this.gameWorld, this.segmentTravelTime);

  @override
  void update(double dt) {
    super.update(dt);
    timeSinceInit +=dt;
  }

  bool caterPillarFixedUpdate(double dt)
  {
    secondCounter += dt;
    if(secondCounter >=frameDuration)
    {
      secondCounter  =0;
      return true;
    }
    return false;
  } 
  CaterpillarSegment addCaterPillarSegment(CaterPillar caterpillar)
  {
    nextSegment = CaterpillarSegment(caterpillardata, gameWorld,segmentTravelTime, previousSegment: this, caterpillar: caterpillar);
    //nextSegment?.position = angleQueue.last.position;
    gameWorld.world.add(nextSegment!);
    caterpillar.lastSegment = nextSegment;
    nextSegment?.previousSegment = this; 
    nextSegment?.priority = priority-1;
    nextSegment?.index = index+1;
    gameWorld.onSegmentAddedToPlayer(nextSegment!.index);
    return nextSegment!;
    
  }
}

class CaterPillar extends CaterpillarElement with CollisionCallbacks
{
  static const double fullCircle = 2*pi;

  double rotationSpeed;

  late double angleToLerpTo;
  late Vector2 velocity;
  late double scaledAnchorYPos;
  double movingSpeed;

  late Vector2 initPosition;

  CaterpillarSegment? lastSegment;


  int snackCount = 0;

  CaterPillar(super.caterpillardata, super.gameWorld, this.rotationSpeed, this.movingSpeed, super.segmentTravelTime);

  @override
  Future<void> onLoad() async {
    size = caterpillardata.finalSize;
    finalSize = caterpillardata.finalSize;
    final data = SpriteAnimationData.sequenced(
    textureSize: caterpillardata.spriteSize,
    amount: 4,
    stepTime: 0.1,
    );
    animation = SpriteAnimationComponent.fromFrameData(
      await imageLoader.load(caterpillardata.imagePath),
      data,
      scale: Vector2(finalSize.x/caterpillardata.spriteSize.x,
      finalSize.y/caterpillardata.spriteSize.y)
    );

   final double anchorPos = (caterpillardata.anchorPosY/caterpillardata.spriteSize.y);
   anchor = Anchor(0.5,anchorPos);
    angleToLerpTo = angle;
    velocity = Vector2(0, 0);
    add(RectangleHitbox());
    add(animation);
    priority = 10000;
    index  =0;
  }

  @override
  void onMount()
  {
    super.onMount();
    print('Mount with pos: -> $position');     

  }

  @override
  void update(double dt) {
    super.update(dt);
    if(timeSinceInit >= segmentTravelTime)
    {
      isInitializing = false;
      if(segemntAddRequest)
      {
        addSegment();
      }
    }
    if(debugMode && caterPillarFixedUpdate(dt))
    {
      //Create Segemtns Faster
      addCaterpillarSegemntRequest();
    }
    updateLerpToAngle(dt);
    updateMoveOn(dt);

    angle = angle%(fullCircle);
    if(angle <0)
    {
      angle = fullCircle+(angle%(fullCircle));
    }
    //angle queue
    updateAngleQueue();
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    position = gameSize / 2;
  }

@override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points,other);

    if (other is Snack) {
      snackCount++;
      addCaterpillarSegemntRequest();
    }
  }

  void updateLerpToAngle(double dt)
  {
    double diff = transform.angle - angleToLerpTo;
    if(diff.abs() < 0.1)
    {
      transform.angle = angleToLerpTo;
      return;
    }
    int direction = 1;
    if((diff>0  && diff<pi) || diff<-pi)
    {
      direction = -1;
    }

    double lerpSpeedDt = dt*rotationSpeed*direction;
    transform.angle += lerpSpeedDt;
   
  }

  void onMoveDirectionChange(Vector2 pointToMoveTo)
  {
    angleToLerpTo = FlameGameUtils.getAngleFromUp(pointToMoveTo);
  }

  //onMounted is not giving the correct position - too early?
  // bool initOnUpdate = false;

  void updateMoveOn(double dt)
  { 
    //based on rotation implementation but without the x part (start calculate from up vector where x is 0)
    Vector2 direction = Vector2( 1 * sin(angle), -1 * cos(angle)).normalized();
    velocity = direction * dt  *movingSpeed;
    position += velocity;
  }

  void updateAngleQueue()
  {
    angleQueue.addFirst(MovementTransferData(angle: angle, position: position));
    
    if(!isInitializing)
    {
      nextSegment?.angle = angleQueue.last.angle;
      nextSegment?.position = angleQueue.last.position;
      angleQueue.removeLast();
    }
  }

  void addCaterpillarSegemntRequest()
  {
    if(!isInitializing)
    {
      addSegment();
    }
    else
    {
      segemntAddRequest  =true;
    }
  }

  void addSegment()
  {
    if(lastSegment != null)
    {
      lastSegment?.addCaterpillarSegemntRequest();
    }
    else{
      super.addCaterPillarSegment(this);   
    }
  }
    
}
