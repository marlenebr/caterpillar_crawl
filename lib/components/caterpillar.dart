import 'dart:collection';
import 'dart:isolate';
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
  CaterpillarSegment addCaterPillarSegment(CaterPillar caterpillar)
  {
    nextSegment = CaterpillarSegment(caterpillardata, gameWorld, previousSegment: this, caterpillar: caterpillar);
    nextSegment?.position = position;
    gameWorld.world.add(nextSegment!);
    caterpillar.lastSegment = nextSegment;
    nextSegment?.previousSegment = this; 
    nextSegment?.priority = priority-1;
    nextSegment?.index = index+1;
    return nextSegment!;
    
  }

  void updateAngleQueue(double dt)
  {
    angleQueue.addFirst(MovementTransferData(orientation: orientation,position: absolutePositionOfAnchor(anchor), angle: angle));

    if(!isInitializing)
    {
      nextSegment?.angle = angleQueue.last.angle;
      nextSegment?.position = angleQueue.last.position;
      angleQueue.removeLast();
    }

    if(nextSegment !=null)
    {
      nextSegment?.updateAngleQueue(dt);
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

Vector2 FindNearestPointOnLine(Vector2 origin, Vector2 end, Vector2 point)
{
    //Get heading
    Vector2 heading = (end - origin);
    double magnitudeMax = origin.distanceTo(end);
    heading.normalize();

    //Do projection from the point but clamp it
    Vector2 lhs = point - origin;
    double dotP = lhs.dot(heading);
    dotP = dotP.clamp(0, magnitudeMax);
    return origin + heading * dotP;
}
}

class CaterPillar extends CaterpillarElement
{
  static const double fullCircle = 2*pi;

  double rotationSpeed;

  late double angleToLerpTo;
  late double scaledAnchorYPos;

  CaterpillarSegment? lastSegment;


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
    //TODO: fix startIsolateSegmentCalculation to run as isolate
    updateLerpToAngle(dt);
    orientation = Vector2( 1 * sin(angle), -1 * cos(angle)).normalized();
    position += orientation * velocity;
    updateAngleQueue(dt);
  }

  bool startIolateSegments  =false;

  // Future<void> startIsolateSegmentCalculation()
  // async {
  //   startIolateSegments  =true;
  //   final receivePort = ReceivePort();
  //   Isolate isolate = await Isolate.spawn(updateCaterpillarsegmentMovement, [receivePort.sendPort, this]);

  //   receivePort.listen((caterpillarDone) {
  //   print(caterpillarDone);
  //   receivePort.close();
  //   isolate.kill();
  //   startIolateSegments  =false;
  // });
  // }

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

    double lerpSpeedDt = dt*rotationSpeed *direction;
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

// void updateCaterpillarsegmentMovement(List<dynamic> arguments)
// {
//   bool caterpillarDone = false;
//   CaterpillarElement caterpillarElement = arguments[1] as CaterpillarElement;
//   caterpillarElement.angleQueue.addFirst(MovementTransferData(angle: caterpillarElement.angle, position: caterpillarElement.position));
  
//   if(!caterpillarElement.isInitializing)
//   {
//     caterpillarElement.nextSegment?.angle = caterpillarElement.angleQueue.last.angle;
//     caterpillarElement.nextSegment?.position = caterpillarElement.angleQueue.last.position;
//     caterpillarElement.angleQueue.removeLast();
//   }

//   if(caterpillarElement.nextSegment !=null)
//   {
//     updateCaterpillarsegmentMovement([arguments[0],caterpillarElement.nextSegment ]);
//   }
//   else
//   {
//     caterpillarDone = true;
//     SendPort sendport = arguments[0] as SendPort;
//     sendport.send(caterpillarDone);
//   }
// }

// class IsolateSegmentArgs
// {
//   final SendPort sendPort;
//   final CaterpillarElement caterpillarelement;

//   IsolateSegmentArgs({required this.sendPort, required this.caterpillarelement});
// }
