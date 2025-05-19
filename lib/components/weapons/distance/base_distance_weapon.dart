import 'dart:math';

import 'package:caterpillar_crawl/components/map/obstacle_snapshot.dart';
import 'package:caterpillar_crawl/components/obstacle.dart';
import 'package:caterpillar_crawl/components/weapons/base_weapon.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/data/weapon_data.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BaseDistanceWeapon extends BaseWeapon with HasVisibility {
  DistanceWeaponData distanceWeapondata;
  bool isInMultipleShoot = false;
  bool isInSingleShoot = false;

  double shootDelay = 0.4;
  double currentShotTime = 0;
  int currentPelletIndex = 0;
  int currentPelletCount = 0;

  double startAngle = 0;
  double angleOffset = 0.3;

  BaseDistanceWeapon({required super.weaponData, required super.map})
      : distanceWeapondata = weaponData as DistanceWeaponData;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    removeHitPointsOnHit = true;
  }

  @override
  void update(double dt) {
    if (!isVisible) {
      return;
    }
    super.update(dt);
    _updateShootMultipleMunitions(dt);

    if (isAttacking) {
      if (updateHits()) {
        isInSingleShoot = false;
      }
    }
  }

  void setActive(bool activate) {
    isVisible = activate;
  }

  shootMultipleMunitions(CaterpillarCrawlMain gameWorld, Vector2 position,
      double angle, int pelletCount) {
    if (!isVisible) {
      return;
    }
    currentPelletCount = pelletCount;
    int pelletsPerSide = pelletCount ~/ 2;
    startAngle = absoluteAngle - angleOffset * (pelletsPerSide);
    currentPelletCount = pelletCount;
    isInMultipleShoot = true;
  }

  shootSingleMunition() {
    if (isInSingleShoot || !isVisible) {
      return;
    }
    startAngle = absoluteAngle;
    _spawnMunition(absoluteAngle);
    isInSingleShoot = true;
  }

  void _updateShootMultipleMunitions(double dt) {
    if (!isInMultipleShoot) {
      return;
    }
    currentShotTime += dt;
    if (currentShotTime > shootDelay) {
      _spawnMunition((absoluteAngle - (angleOffset * currentPelletCount) / 2) +
          (angleOffset * currentPelletIndex));
      currentShotTime = 0;
      currentPelletIndex++;
      if (currentPelletIndex + 1 > currentPelletCount) {
        isInMultipleShoot = false;
        return;
      }
      currentPelletIndex++;
    }
  }

  void _spawnMunition(double angleDirection) {
    BaseDistanceMunition pellet = BaseDistanceMunition(distanceWeapon: this);
    map.world.world.add(pellet);
    pellet.position = Vector2(absolutePosition.x, absolutePosition.y);
    pellet.angle = angleDirection;
  }
}

class BaseDistanceMunition extends PositionComponent {
  bool isInExplosion = false;
  bool canExplode = false;
  Vector2 initPosition = Vector2.zero();

  double explosionTimer = 2;

  late SpriteAnimationGroupComponent munitionAnimationGroup;
  late SpriteAnimation _shootAnimation;
  late SpriteAnimation? _explodingAnimation;

  MunitionState currentState = MunitionState.inShoot;

  BaseDistanceWeapon distanceWeapon;
  BaseDistanceMunition({required this.distanceWeapon});
  @override
  Future<void> onLoad() async {
    super.onLoad();
    if (distanceWeapon.distanceWeapondata.explodingAnimation != null) {
      canExplode = true;
      distanceWeapon.removeHitPointsOnHit = false;
    }
    _shootAnimation = await CaterpillarCrawlUtils.createAnimation(
        animationData: distanceWeapon.distanceWeapondata.munitionanimation);
    if (canExplode) {
      _explodingAnimation = await CaterpillarCrawlUtils.createAnimation(
          animationData: distanceWeapon.distanceWeapondata.explodingAnimation!,
          loopAnimation: false);
    }
    if (canExplode) {
      munitionAnimationGroup =
          SpriteAnimationGroupComponent<MunitionState>(animations: {
        MunitionState.inShoot: _shootAnimation,
        MunitionState.exploding: _explodingAnimation!,
      }, anchor: Anchor.center, current: currentState);
    } else {
      munitionAnimationGroup =
          SpriteAnimationGroupComponent<MunitionState>(animations: {
        MunitionState.inShoot: _shootAnimation,
      }, anchor: Anchor.center, current: currentState);
    }

    add(munitionAnimationGroup);
    munitionAnimationGroup.size =
        distanceWeapon.distanceWeapondata.munitionanimation.finalSize;
    anchor = Anchor.center;
    priority = 100;
    // size = Vector2.all(
    //     distanceWeapon.distanceWeapondata.munitionanimation.finalSize.x / 2);
    if (!canExplode) {
      distanceWeapon.hitPoints.add(this);
    }
    initPosition = Vector2(absolutePosition.x, absolutePosition.y);
    // position = Vector2(position.x - distanceWeapon.position.x / 2, position.y);
    angle = distanceWeapon.absoluteAngle;
  }

  @override
  void update(double dt) {
    if (isInExplosion) {
      explosionTimer -= dt;
      distanceWeapon.hitRadiusMultiplicator = 4;
      if (explosionTimer < 0) {
        distanceWeapon.hitPoints.remove(this);
        distanceWeapon.map.obstacleSnapshot
            .addObstacleAndRenderSnapshot<BombObstacle>(
                absolutePosition,
                distanceWeapon
                    .distanceWeapondata.explodingAnimation!.spriteSize,
                angle,
                true,
                ObstacleType.bomb);
        distanceWeapon.isInSingleShoot = false;
        distanceWeapon.hitPoints.remove(this);
        distanceWeapon.isAttacking = false; //optimize here
        removeFromParent();
      }
      return;
    }
    distanceWeapon.hitRadiusMultiplicator = 1;
    CaterpillarCrawlUtils.updatePosition(
        dt, transform, distanceWeapon.distanceWeapondata.attackSpeed, angle);
    if (initPosition.distanceTo(absolutePosition) >
        distanceWeapon.distanceWeapondata.distanceToShoot) {
      if (canExplode) {
        setCurrentMunitionState(MunitionState.exploding);
        return;
      }

      //In single shoot done
      distanceWeapon.isInSingleShoot = false;
      distanceWeapon.hitPoints.remove(this);
      distanceWeapon.isAttacking = false; //optimize here

      removeFromParent();
      return;
    }
  }

  void setCurrentMunitionState(MunitionState eggState) {
    currentState = eggState;
    munitionAnimationGroup.current = currentState;
    if (currentState == MunitionState.exploding) {
      isInExplosion = true;
      if (!distanceWeapon.hitPoints.contains(this)) {
        distanceWeapon.hitPoints.add(this);
      }

      munitionAnimationGroup.size =
          distanceWeapon.distanceWeapondata.explodingAnimation!.finalSize;
    }
  }
}

enum MunitionState {
  inShoot,
  exploding,
}
