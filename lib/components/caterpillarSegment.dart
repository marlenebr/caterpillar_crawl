import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillar.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/caterpillarData.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

///The body segments to be added behind the previous one (or the head)
class CaterpillarSegment extends CaterpillarElement
{
  CaterPillar caterpillar;
  CaterpillarSegmentData segmentData;
  double finalSize;

  Forge2DWorld gameWorld;

  CaterpillarElement previousSegment;

  late int index;
  late PositionComponent anchorComponent;

  CaterpillarSegment({required this.segmentData, required this.gameWorld, required this.previousSegment, required this.finalSize, required this.caterpillar});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = previousSegment.size;
    final double anchorPosY = (segmentData.anchorPosYTop/segmentData.spriteSize.y);
    anchor = Anchor(0.5,anchorPosY);
    index = caterpillar.snackCount;
    print("NEW SEGMENT $index");  

    addSegmentSprite();
    //DEBUG
    add(FlameGameUtils.debugDrawAnchor(this)); 
  }

  @override
  void update(double dt) {
    super.update(dt); 
    initSegment();
    updateAngleQueue();
    //lerp towards parent normal
  }

  void initSegment()
  {
    if(isInitializing && angleQueue.length >= previousSegment.angleQueue.length)
    {
      isInitializing =false;
      int debug  =caterpillar.snackCount;
      print("init of segment done $debug");
      if(segemntAddRequest)
      {
        _addCaterPillarSegment();
      }
    }
  }
  

  Future<void> addSegmentSprite()
  async {
    final data = SpriteAnimationData.sequenced(
    textureSize: segmentData.spriteSize,
    amount: 4,
    stepTime: 0.1,
    );

    animation = SpriteAnimationComponent.fromFrameData(
        await imageLoader.load(segmentData.imagePath),
        data,
        scale: Vector2.all(finalSize/segmentData.spriteSize.x)

      );
    add(animation);
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
  }

  void updateLerpToAngle(double dt, double angleToLerpTo, double rotationSpeed)
  {
    double diff = transform.angle - angleToLerpTo;
    if(diff.abs() < 0.1)
    {
      transform.angle = angleToLerpTo;
      //initRotation  = angleToLerpTo;
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

  void addCaterpillarSegemntRequest()
  {
    if(!isInitializing)
    {
      _addCaterPillarSegment();
    }
    else
    {
      segemntAddRequest  =true;
    }
  }

  CaterpillarSegment _addCaterPillarSegment()
  {
    // CaterpillarSegment segment = CaterpillarSegment(segmentData: segmentData, gameWorld: gameWorld,previousSegment: this, finalSize: finalSize, caterpillar: caterpillar);
    // nextSegment = segment;
    // segment.previousSegment = this;
    // gameWorld.add(segment);
    // //segment.position = angleQueue.last.position;
    // segment.angle = angle;
    // int debug = angleQueue.length;
    // int debugINdexSegment = segment.index;
    // caterpillar.lastSegment = segment;

    nextSegment = CaterpillarSegment(segmentData: segmentData, gameWorld: gameWorld,previousSegment: this, finalSize: finalSize, caterpillar: caterpillar);
    nextSegment?.position = position;
    gameWorld.add(nextSegment!);
    int debug = angleQueue.length;
    print('BBB- LENGHT OF ANGLE LIST; $debug');
    print("BBBB in init $position");

    caterpillar.lastSegment = nextSegment;
    nextSegment?.previousSegment = this; 
    nextSegment?.priority = priority-1;
    return nextSegment!;
    
  }
}
