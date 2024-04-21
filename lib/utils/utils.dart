import 'dart:math';

import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/animation_data.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class CaterpillarCrawlUtils {
  ///Gets the angle from a point and the up vector
  static double getAngleFromUp(Vector2 point) {
    double radiansOfTap = atan2(point.y, point.x);
    double quaterRotationInRadiant = 90 *
        (pi / 180); //atan2 uses positive x axis as vektor to calulate angle
    //double angleOfTap = degrees(-radiansOfTap -quaterRotationInRadiant);
    double worldRadiansOfTap = radiansOfTap - quaterRotationInRadiant;
    double finalAngle;

    if (worldRadiansOfTap < 0) {
      finalAngle = 2 * pi + worldRadiansOfTap;
    } else {
      finalAngle = worldRadiansOfTap;
    }
    return finalAngle;
  }

  static RectangleComponent debugDrawAnchor(PositionComponent positionComp) {
    final anchorVector = positionComp.anchor.toVector2();
    final anchorPosLocal = Vector2(positionComp.size.x * anchorVector.x,
        positionComp.size.y * anchorVector.y);
    double renderSize = 10;
    return RectangleComponent(
        size: Vector2.all(renderSize),
        paint: Paint()..color = Color.fromARGB(255, 60, 4, 214),
        position: Vector2(anchorPosLocal.x - renderSize / 2,
            anchorPosLocal.y - renderSize / 2));
  }

  static Future<SpriteAnimation> createAnimation(
      {required AnimationData animationData, bool loopAnimation = true}) async {
    final data = SpriteAnimationData.sequenced(
      textureSize: animationData.spriteSize,
      amount: animationData.animationstepCount,
      stepTime: 0.1,
      loop: loopAnimation,
    );
    SpriteAnimationComponent eggAnim = SpriteAnimationComponent.fromFrameData(
      await imageLoader.load(animationData.imagePath),
      data,
    );

    return eggAnim.animation!;
  }

  static Future<SpriteAnimationComponent> createAnimationComponent(
      AnimationData animationData) async {
    final data = SpriteAnimationData.sequenced(
      textureSize: animationData.spriteSize,
      amount: animationData.animationstepCount,
      stepTime: 0.1,
    );

    return SpriteAnimationComponent.fromFrameData(
        await imageLoader.load(animationData.imagePath), data,
        scale: Vector2(animationData.finalSize.x / animationData.spriteSize.x,
            animationData.finalSize.y / animationData.spriteSize.y));
  }
}

// extension PositionComponentExtensions on PositionComponent {
//     void setChildToAnchorPosition(PositionComponent child)
//     {
//       //cause anchor is not the 0/0 position - calculate that
//       final anchorVector  = anchor.toVector2();
//       final anchorPosLocal = Vector2(size.x*anchorVector.x,size.y*anchorVector.y);
//       child.position = anchorPosLocal;// + position;
//     }
// }