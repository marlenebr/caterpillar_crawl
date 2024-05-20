import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillar/caterpillar.dart';
import 'package:caterpillar_crawl/components/caterpillar/caterpillarElement.dart';
import 'package:caterpillar_crawl/components/enemy/enemy.dart';
import 'package:caterpillar_crawl/components/obstacle.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';

///The body segments to be added behind the previous one (or the head)
class CaterpillarSegment extends CaterpillarElement {
  CaterPillar caterpillar;
  CaterpillarElement previousSegment;

  late SpriteAnimationComponent animation;

  bool isFallenOff = false;

  CaterpillarSegment(super.caterpillardata, super.gameWorld,
      {required this.previousSegment, required this.caterpillar});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    finalSize = caterpillardata.segmentAnimation.finalSize;
    size = previousSegment.size;
    scale = caterpillar.scale;
    anchor = Anchor.center;
    SpriteAnimationComponent animation =
        await CaterpillarCrawlUtils.createAnimationComponent(
            caterpillardata.segmentAnimation);
    add(animation);
  }

  @override
  void update(double dt) {
    super.update(dt);
    //initSegment();
    updateHCollisionWithSelf();
    updateEnemyCollision();
  }

  void updateHCollisionWithSelf() {
    if (caterpillar.caterpillarStatsViewModel.currentState !=
        CaterpillarState.crawling) {
      return;
    }
    if (caterpillar.isInUlti) {
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

  // Future<void> addSegmentSprite() async {
  //   final data = SpriteAnimationData.sequenced(
  //     textureSize: caterpillardata.segmentAnimation.spriteSize,
  //     amount: 4,
  //     stepTime: 0.1,
  //   );

  //   animation = SpriteAnimationComponent.fromFrameData(
  //       await imageLoader.load(caterpillardata.segmentAnimation.imagePath),
  //       data,
  //       scale: Vector2(
  //           finalSize.x / caterpillardata.segmentAnimation.spriteSize.x,
  //           finalSize.y / caterpillardata.segmentAnimation.spriteSize.y));
  //   add(animation);
  // }

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

  void addCaterpillarSegemntRequest() {
    if (!isInitializing) {
      addCaterPillarSegment(caterpillar);
    } else {
      segemntAddRequest = true;
    }
  }

  void falloff(bool isUlti) {
    if (isFallenOff) {
      return;
    }
    isFallenOff = true;
    nextSegment?.falloff(isUlti);
    if (isUlti) {
      gameWorld.groundMap.obstacleSnapshot.addObstacle<UltiObstacle>(
          Vector2(transform.position.x, transform.position.y),
          size * scale.x,
          angle,
          null);
    } else {
      gameWorld.groundMap.obstacleSnapshot.addObstacle<PlayerHurtObstacle>(
          Vector2(transform.position.x, transform.position.y),
          size * scale.x,
          angle,
          null);
    }
    removeFromParent();
    caterpillar.caterpillarStatsViewModel.onRemoveSegment();
  }

  @override
  void onRemove() {
    caterpillar.caterpillarStateViewModel.setIsRemovingSegment(false);
  }

  void reset() {
    super.reset();
    isFallenOff = false;
    removeFromParent();
  }
}
