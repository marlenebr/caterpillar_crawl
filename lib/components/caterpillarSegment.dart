import 'dart:math';

import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/caterpillarData.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

///The body segments to be added behind the previous one (or the head)
class CaterpillarSegment extends PositionComponent
{

  CaterpillarSegmentData segmentData;
  double finalSize;

  Forge2DWorld gameWorld;

  PositionComponent previousSegment;

  CaterpillarSegment({required this.segmentData, required this.gameWorld, required this.previousSegment, required this.finalSize});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = previousSegment.size;
    final double anchorPosY = (segmentData.anchorPosYTop/segmentData.spriteSize.y);
    anchor = Anchor(0.5,anchorPosY);

    addSegmentSprite();
    //DEBUG
    add(FlameGameUtils.debugDrawAnchor(this)); 
  }

  @override
  void update(double dt) {
    super.update(dt); 

    //lerp towards parent normal
  }

  Future<void> addSegmentSprite()
  async {
    final data = SpriteAnimationData.sequenced(
    textureSize: segmentData.spriteSize,
    amount: 4,
    stepTime: 0.1,
    );

    final SpriteAnimationComponent animation = SpriteAnimationComponent.fromFrameData(
        await imageLoader.load(segmentData.imagePath),
        data,
        scale: Vector2.all(finalSize/segmentData.spriteSize.x)

      );
    add(animation);
  }

  void updateSegmentByPrevious(PositionComponent preveiousSegment)
  {

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
}
