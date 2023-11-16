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
  World gameWorld;

  late SpriteAnimationComponent animation;

  final angleQueue = Queue<MovementTransferData>(); // ListQueue() by default
  bool isInitializing = true;
  late int index;


  double secondCounter = 0;
  double frameDuration = 1/2;

  bool segemntAddRequest =false;
  double finalSize;

  CaterpillarElement(this.finalSize, this.caterpillardata, this.gameWorld);

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
    nextSegment = CaterpillarSegment(finalSize, caterpillardata, gameWorld, previousSegment: this, caterpillar: caterpillar);
    //nextSegment?.position = angleQueue.last.position;
    gameWorld.add(nextSegment!);
    caterpillar.lastSegment = nextSegment;
    nextSegment?.previousSegment = this; 
    nextSegment?.priority = priority-1;
    return nextSegment!;
    
  }
}

class CaterPillar extends CaterpillarElement with CollisionCallbacks
{
  static const double fullCircle = 2*pi;

  double rotationSpeed;
  double movingSpeed;

  //value between 0 and 1 - more higher is more accurate but the segment distance to another is lower
  //eg. ist needs mor segments for a longer caterpillar
  double accuracy = 0.65;


  late double angleToLerpTo;
  late Vector2 velocity;
  late double scaledAnchorYPos;

  late Vector2 initPosition;

  CaterpillarSegment? lastSegment;


  int snackCount = 0;

  CaterPillar(super.finalSize, super.caterpillardata, super.gameWorld, this.rotationSpeed, this.movingSpeed);

  @override
  Future<void> onLoad() async {
    size = Vector2.all(finalSize);
    final data = SpriteAnimationData.sequenced(
    textureSize: caterpillardata.spriteSize,
    amount: 4,
    stepTime: 0.1,
    );
    animation = SpriteAnimationComponent.fromFrameData(
      await imageLoader.load(caterpillardata.imagePath),
      data,
      scale: Vector2.all(finalSize/caterpillardata.spriteSize.x)
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
  bool initOnUpdate = false;

  void updateMoveOn(double dt)
  { 
    //based on rotation implementation but without the x part (start calculate from up vector where x is 0)
    Vector2 direction = Vector2( 1 * sin(angle), -1 * cos(angle)).normalized();
    velocity = direction * dt  *movingSpeed;
    position += velocity;
    if(isMounted)
    {
      if(!initOnUpdate)
      {
        initPosition = Vector2(position.x,position.y); 
        initOnUpdate  =true;
      }
      if(isInitializing && initPosition.distanceTo(position) > size.y/(1+accuracy))
      {
        isInitializing = false;
        if(segemntAddRequest)
        {
          addSegment();
        }
      }
    }

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
