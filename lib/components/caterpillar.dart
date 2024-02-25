import 'dart:collection';
import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillarSegment.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/caterpillarData.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
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

  bool segemntAddRequest =false;
  late Vector2 finalSize;

  Vector2 orientation = Vector2.zero();
  double velocity = 1;
  double speedMultiplier = 1;

  late double fixedDistToSegment;
  late Vector2 initPosition;


  CaterpillarElement(this.caterpillardata, this.gameWorld);

  @override
  void update(double dt) {
    super.update(dt);
    velocity = dt *caterpillardata.movingspeed;

    initSegment();

    timeSinceInit +=dt;
  }

  @override
  Future<void> onLoad() async {
    fixedDistToSegment = caterpillardata.refinedSegmentDistance * caterpillardata.caterpillarSegment.finalSize.y;
  }

  @override
  void onMount()
  {
    super.onMount();
    initPosition = Vector2(position.x, position.y);
  }

  bool caterPillarFixedUpdate(double dt,double frameDuration)
  {
    secondCounter += dt;
    if(secondCounter >=frameDuration)
    {
      secondCounter  =0;
      return true;
    }
    return false;
  } 
  void addCaterPillarSegment(CaterPillar caterpillar)
  {
    if(caterpillardata.maxElementCount <= index)
    {
      return;
    }
    nextSegment = CaterpillarSegment(caterpillardata, gameWorld, previousSegment: this, caterpillar: caterpillar);
    nextSegment?.position = position;
    gameWorld.world.add(nextSegment!);
    caterpillar.lastSegment = nextSegment;
    nextSegment?.previousSegment = this; 
    nextSegment?.priority = priority-1;
    nextSegment?.index = index+1;
    return;
    
  }

  void updateAngleQueue(int fixIterations, int entriesNeeded)
  {
    angleQueue.addFirst(MovementTransferData(orientation: orientation,position: absolutePositionOfAnchor(anchor), angle: angle));
    correctListLength(fixIterations, entriesNeeded);

    if(nextSegment !=null)
    {
      nextSegment?.angle = angleQueue.last.angle;
      nextSegment?.position = angleQueue.last.position;
      nextSegment?.updateAngleQueue(fixIterations, entriesNeeded);
    }
  }

  void correctListLength(int fixIt, int entriesNeeded)
  {

    for(int i =0;i<fixIt;i++)
    {
      if(angleQueue.length > entriesNeeded+1)
      {
        // for(int i = debugLeN; i >entriesNeeded; i--)
        // {
        angleQueue.removeLast();
        //}
      }
      else {
        return;
      }
    }
  }

  void initSegment()
  {
    if(isInitializing && initPosition.distanceTo(position)>fixedDistToSegment)
    {
      //kommt einmal vor
      isInitializing =false;
      print("init of segment done $index");
    }
  }

  //the size the queue has to be right now
  int calcSteptToReachDistance(double dt)
  {
    double finalTimeInSec = fixedDistToSegment/(caterpillardata.movingspeed*speedMultiplier);
    if(dt==0)
    {
      return 0;
    }
    double fps =1/dt;
    return (finalTimeInSec * fps).toInt();
  }
}

class CaterPillar extends CaterpillarElement
{
  static const double fullCircle = 2*pi;

  double rotationSpeed;

  late double angleToLerpTo;
  late double scaledAnchorYPos;

  CaterpillarSegment? lastSegment;
  late int entriesNeeded;
  int fixIterationPerFrame =1; //how much need to be fixed - the higher the more
  double tolerance = 20; //how tolerant should be segment distance differnces?




  int snackCount = 0;

  CaterPillar(super.caterpillardata, super.gameWorld, this.rotationSpeed);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = caterpillardata.finalSize;
    finalSize = caterpillardata.finalSize;
    final data = SpriteAnimationData.sequenced(
    textureSize: caterpillardata.spriteSize,
    amount: caterpillardata.animationSprites,
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
    add(animation);
    priority = 10000;
    index  =0;
  }

  @override
  void onMount()
  {
    super.onMount();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if(!isInitializing)
    {
      if(segemntAddRequest)
      {
        addSegment();
      }
    }
    updateLerpToAngle(dt);
    startUpdateAngleQueue(dt);
  }

  void startUpdateAngleQueue(double dt)
  {
    orientation = Vector2( 1 * sin(angle), -1 * cos(angle)).normalized();
    position += orientation * velocity * speedMultiplier;
    entriesNeeded = calcSteptToReachDistance(dt);
    Vector2 currentPos = absolutePositionOfAnchor(anchor);
    angleQueue.addFirst(MovementTransferData(orientation: orientation,position: currentPos, angle: angle));
    correctListLength(fixIterationPerFrame, entriesNeeded);
    if(nextSegment !=null)
    {
      if(currentPos.distanceTo(nextSegment!.absolutePositionOfAnchor(nextSegment!.anchor)) > fixedDistToSegment + tolerance)
      {
        fixIterationPerFrame  = 3;
      }
      else
      {
        fixIterationPerFrame  = 1;
      }
      nextSegment?.updateAngleQueue(fixIterationPerFrame, entriesNeeded);
      nextSegment?.angle = angleQueue.last.angle;
      nextSegment?.position = angleQueue.last.position;
    }
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    position = gameSize / 2;
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

    double lerpSpeedDt = dt*rotationSpeed *direction * speedMultiplier;
    transform.angle += lerpSpeedDt;

    //fix error from 0 to 360 degrees
    angle = angle%(fullCircle);
    if(angle <0)
    {
      angle = fullCircle+(angle%(fullCircle));
    }
   
  }

  void onMoveDirectionChange(Vector2 pointToMoveTo)
  {
    angleToLerpTo = FlameGameUtils.getAngleFromUp(pointToMoveTo);
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
    segemntAddRequest = false;
  }
    
}
