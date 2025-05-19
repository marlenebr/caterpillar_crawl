import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillar/caterpillarElement.dart';
import 'package:caterpillar_crawl/components/caterpillar/caterpillar_base.dart';
import 'package:caterpillar_crawl/components/enemy/enemy.dart';
import 'package:caterpillar_crawl/components/map/obstacle_snapshot.dart';
import 'package:caterpillar_crawl/components/obstacle.dart';
import 'package:caterpillar_crawl/components/snack.dart';
import 'package:caterpillar_crawl/models/data/segment_data.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';

///The body segments to be added behind the previous one (or the head)
class CaterpillarSegment extends CaterpillarElement {
  CaterpillarBase caterpillar;
  CaterpillarElement previousSegment;
  bool removeOnNextFrame = false;
  SnackType snackType;

  late SpriteAnimationComponent animation;

  bool isFallenOff = false;

  CaterpillarSegment(super.caterpillardata, super.gameWorld,
      {required this.snackType,
      required this.previousSegment,
      required this.caterpillar});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    finalSize = caterpillardata.segmentAnimation.finalSize;
    size = previousSegment.size;
    scale = caterpillar.scale;
    anchor = Anchor.center;
    animation = await CaterpillarCrawlUtils.createAnimationComponent(
        SegmentData.getAnimationDataBySnackType(snackType));
    add(animation);
  }

  @override
  void update(double dt) {
    super.update(dt);
    //initSegment();
    if (isInitializing) {
      return;
    }
    updateHCollisionWithSelf();
    updateEnemyCollision();
    // UpdateFallOff(dt);
  }

  void updateHCollisionWithSelf() {
    if (caterpillar.caterpillarStatsViewModel.currentState !=
        CaterpillarState.crawling) {
      return;
    }

    if (position.distanceTo(caterpillar.position) < distToCollide) {
      if (caterpillar.nextSegment?.index == index) {
        return;
      }
      caterpillar.hurt();
    }
  }

  void updateEnemyCollision() {
    //??????????????
    for (Enemy enemy in gameWorld.groundMap.enemies.values) {
      if (enemy.position.distanceTo(position) < caterpillar.distToCollide) {
        //ENEMY DEAD
        //IS INIT?
        if (enemy.isLoaded) {
          enemy.onEnemyHit(5, true);
        }
        return;
      }
    }
  }

  Future<void> addSegmentSprite2() async {
    Sprite segmentSprite =
        await Sprite.load(caterpillardata.segmentAnimation.imagePath);
    SpriteComponent spritecomp = SpriteComponent(
        sprite: segmentSprite,
        scale: Vector2(
            finalSize.x / caterpillardata.segmentAnimation.spriteSize.x,
            finalSize.y / caterpillardata.segmentAnimation.spriteSize.y));
    add(spritecomp);
  }

  void updateLerpToAngle(
      double dt, double angleToLerpTo, double rotationSpeed) {
    double diff = transform.angle - angleToLerpTo;
    if (diff.abs() < 0.1) {
      transform.angle = angleToLerpTo;
      return;
    }
    int direction = 1;
    if ((diff > 0 && diff < pi) || diff < -pi) {
      direction = -1;
    }

    double lerpSpeedDt = dt * rotationSpeed * direction;
    transform.angle += lerpSpeedDt;
  }

  // void addCaterpillarSegemntRequest() {
  //   // if (!isInitializing) {
  //   //   addCaterPillarSegment(caterpillar);
  //   // } else {
  //   segemntAddRequest = true;
  //   // }
  // }

  void falloff(bool justRemove) {
    if (isFallenOff) {
      return;
    }
    isFallenOff = true;
    nextSegment?.falloff(justRemove);

    if (!justRemove) {
      ObstacleType obstacleType =
          justRemove ? ObstacleType.ultiSegment : ObstacleType.deadSegment;
      gameWorld.groundMap.obstacleSnapshot.addObstacle<ThrowableObstacle>(
          Vector2(transform.position.x, transform.position.y),
          angle,
          null,
          obstacleType);
    }
    removeFromParent();
    caterpillar.caterpillarStatsViewModel.onRemoveSegment();
  }

  Future<void> setSegmentType(SnackType snackType) async {
    if (snackType != this.snackType) {
      this.snackType = snackType;
      animation = await CaterpillarCrawlUtils.createAnimationComponent(
          SegmentData.getAnimationDataBySnackType(snackType));
    }
  }

  double fallOffTime = 0.1;

  // void UpdateFallOff(double dt) {
  //   if (!removeOnNextFrame) {
  //     return;
  //   }

  //   fallOffTime -= dt;
  //   if (fallOffTime < 0) {
  //     if (previousSegment is CaterpillarSegment) {
  //       (previousSegment as CaterpillarSegment).removeOnNextFrame = true;
  //     } else if (previousSegment is CaterPillar) {
  //       (previousSegment as CaterPillar).onAllSegmentsRemoved();
  //     }
  //     removeFromParent();
  //     removeOnNextFrame = false;

  //     caterpillar.caterpillarStatsViewModel.onRemoveSegment();
  //   }
  // }

  void fallOff() {
    nextSegment?.fallOff();
    removeFromParent();
    removeOnNextFrame = false;
    caterpillar.caterpillarStatsViewModel.onRemoveSegment();
  }

  @override
  void onRemove() {
    caterpillar.caterpillarStateViewModel.setIsRemovingSegment(false);
  }

  @override
  void reset() {
    super.reset();
    isFallenOff = false;
    removeFromParent();
  }
}
