import 'dart:collection';
import 'dart:isolate';
import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillarSegment.dart';
// import 'package:caterpillar_crawl/components/snack.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/caterpillarData.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

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

  CaterpillarElement(this.caterpillardata, this.gameWorld);

  @override
  void update(double dt) {
    super.update(dt);
    timeSinceInit +=dt;
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
    //nextSegment?.position = angleQueue.last.position;
    gameWorld.world.add(nextSegment!);
    caterpillar.lastSegment = nextSegment;
    nextSegment?.previousSegment = this; 
    nextSegment?.priority = priority-1;
    nextSegment?.index = index+1;
    return nextSegment!;
    
  }

  void updateAngleQueue()
  {
    angleQueue.addFirst(MovementTransferData(angle: angle, position: absolutePositionOfAnchor(anchor)));
    if(!isInitializing)
    {
      nextSegment?.angle = angleQueue.last.angle;
      nextSegment?.position  = angleQueue.last.position;
      angleQueue.removeLast();
    }

    if(nextSegment !=null)
    {
      nextSegment!.updateAngleQueue();
    }
  }
}

class CaterPillar extends CaterpillarElement
{
  static const double fullCircle = 2*pi;

  double rotationSpeed;

  late double angleToLerpTo;
  late Vector2 velocity;
  late double scaledAnchorYPos;

  late Vector2 initPosition;
  late double segmentTravelTime;


  CaterpillarSegment? lastSegment;


  int snackCount = 0;

  CaterPillar(super.caterpillardata, super.gameWorld, this.rotationSpeed);

  @override
  Future<void> onLoad() async {
    segmentTravelTime = _calcTimeForSegmentTravel();
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
    velocity = Vector2(0, 0);
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
    if(debugMode && caterPillarFixedUpdate(dt,3))
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
    //TODO: fix startIsolateSegmentCalculation to run as isolate
    updateAngleQueue();  
  }

  bool startIolateSegments  =false;

  Future<void> startIsolateSegmentCalculation()
  async {
    startIolateSegments  =true;
    final receivePort = ReceivePort();
    Isolate isolate = await Isolate.spawn(updateCaterpillarsegmentMovement, [receivePort.sendPort, this]);

    receivePort.listen((caterpillarDone) {
    print(caterpillarDone);
    receivePort.close();
    isolate.kill();
    startIolateSegments  =false;
  });
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    position = gameSize / 2;
  }

// @override
//   void onCollision(Set<Vector2> points, PositionComponent other) {
//     super.onCollision(points,other);

//     if (other is Snack) {
//       snackCount++;
//       addCaterpillarSegemntRequest();
//     }
//   }

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
    velocity = direction * dt  *caterpillardata.movingspeed;
    position += velocity;
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

    double _calcTimeForSegmentTravel()
  {
    return (caterpillardata.refinedSegmentDistance * caterpillardata.caterpillarSegment.finalSize.y)/caterpillardata.movingspeed;
  }
    
}

void updateCaterpillarsegmentMovement(List<dynamic> arguments)
{
  bool caterpillarDone = false;
  CaterpillarElement caterpillarElement = arguments[1] as CaterpillarElement;
  caterpillarElement.angleQueue.addFirst(MovementTransferData(angle: caterpillarElement.angle, position: caterpillarElement.position));
  
  if(!caterpillarElement.isInitializing)
  {
    caterpillarElement.nextSegment?.angle = caterpillarElement.angleQueue.last.angle;
    caterpillarElement.nextSegment?.position = caterpillarElement.angleQueue.last.position;
    caterpillarElement.angleQueue.removeLast();
  }

  if(caterpillarElement.nextSegment !=null)
  {
    updateCaterpillarsegmentMovement([arguments[0],caterpillarElement.nextSegment ]);
  }
  else
  {
    caterpillarDone = true;
    SendPort sendport = arguments[0] as SendPort;
    sendport.send(caterpillarDone);
  }
}

class IsolateSegmentArgs
{
  final SendPort sendPort;
  final CaterpillarElement caterpillarelement;

  IsolateSegmentArgs({required this.sendPort, required this.caterpillarelement});
}
