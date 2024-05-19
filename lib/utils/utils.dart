import 'dart:math';

import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/data/animation_data.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class CaterpillarCrawlUtils {
  //---Constants---
  static const double fullCircle = 2 * pi;

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

  ///updates the angle of the transform. returns true if angle is reached.
  static bool updateLerpToAngle(double dt, Transform2D transformToRotate,
      double angleToLerpTo, double rotationSpeed) {
    double diff = transformToRotate.angle - angleToLerpTo;
    if (diff.abs() < 0.1) {
      transformToRotate.angle = angleToLerpTo;
      return true;
    }
    int direction = 1;
    if ((diff > 0 && diff < pi) || diff < -pi) {
      direction = -1;
    }

    double lerpSpeedDt = dt * rotationSpeed * direction * 0.5;
    transformToRotate.angle += lerpSpeedDt;

    //fix error from 0 to 360 degrees
    transformToRotate.angle = transformToRotate.angle % (fullCircle);
    if (transformToRotate.angle < 0) {
      transformToRotate.angle =
          fullCircle + (transformToRotate.angle % (fullCircle));
    }
    return false;
  }

  ///updates the angle of the transform. returns true if angle is reached.
  static bool updateLerpToAngle2(double dt, Transform2D transformToRotate,
      double angleToLerpTo, double rotationSpeed) {
    double diff = transformToRotate.angle - angleToLerpTo;
    // if (diff.abs() < 0.1) {
    //   transformToRotate.angle = angleToLerpTo;
    //   return true;
    // }
    int direction = 1;
    if ((diff > 0 && diff < pi) || diff < -pi) {
      direction = -1;
    }

    double lerpSpeedDt = dt * rotationSpeed * 1 * 0.5;
    transformToRotate.angle += lerpSpeedDt;

    //fix error from 0 to 360 degrees
    // transformToRotate.angle = transformToRotate.angle % (fullCircle);
    // if (transformToRotate.angle < 0) {
    //   transformToRotate.angle =
    //       fullCircle + (transformToRotate.angle % (fullCircle));

    return false;
  }

  static void updatePosition(
      double dt, Transform2D transformToMove, double speed, double angle) {
    transformToMove.position +=
        (Vector2(1 * sin(angle), -1 * cos(angle)).normalized()) *
            dt *
            speed *
            40;
  }

  static bool isOnOnMapEnd(
      PositionComponent positionComponent, double mapSize) {
    if (positionComponent.transform.position.x.abs() > mapSize / 2 ||
        positionComponent.transform.position.y.abs() > mapSize / 2) {
      return true;
    }
    return false;
  }

  static double getRandomAngle() {
    return Random().nextDouble() * 6.2831;
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