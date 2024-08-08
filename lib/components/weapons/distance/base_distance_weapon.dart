import 'dart:math';

import 'package:caterpillar_crawl/components/weapons/base_weapon.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/data/weapon_data.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';

class BaseDistanceWeapon extends BaseWeapon {
  DistanceWeaponData distanceWeapondata;
  bool isInMultipleShoot = false;
  double shootDelay = 0.2;
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
    anchor = Anchor.center;
    removeHitPointsOnHit = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    UpdateShootMultipleMunitions(dt);
    if (isAttacking) {
      updateHits();
    }
  }

  void UpdateShootMultipleMunitions(double dt) {
    if (!isInMultipleShoot) {
      return;
    }
    currentShotTime += dt;
    if (currentShotTime > shootDelay) {
      BaseDistanceMunition pellet = BaseDistanceMunition(distanceWeapon: this);
      map.world.world.add(pellet);
      pellet.position = absolutePosition;
      pellet.angle = ((absoluteAngle - (angleOffset * currentPelletCount) / 2) +
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

  shootMultipleMunitions(CaterpillarCrawlMain gameWorld, Vector2 position,
      double angle, int pelletCount) {
    currentPelletCount = pelletCount;
    int pelletsPerSide = (pelletCount / 2).toInt();
    startAngle = absoluteAngle - angleOffset * (pelletsPerSide);
    currentPelletCount = pelletCount;
    // if (pelletCount % 2 != 0) {
    //   startAngle += angleOffset / 2;
    // }
    currentPelletIndex = 0;
    isInMultipleShoot = true;
  }
}

class BaseDistanceMunition extends PositionComponent {
  Vector2 initPosition = Vector2.zero();

  BaseDistanceWeapon distanceWeapon;
  BaseDistanceMunition({required this.distanceWeapon});
  @override
  Future<void> onLoad() async {
    super.onLoad();
    SpriteAnimationComponent spriteAnimation =
        await CaterpillarCrawlUtils.createAnimationComponent(
            distanceWeapon.distanceWeapondata.munitionanimation);
    add(spriteAnimation);
    anchor = Anchor.center;
    priority = 100;
    size = Vector2.all(
        distanceWeapon.distanceWeapondata.munitionanimation.finalSize.x);
    distanceWeapon.hitPoints.add(this);
    initPosition = Vector2(absolutePosition.x, absolutePosition.y);
  }

  @override
  void update(double dt) {
    CaterpillarCrawlUtils.updatePosition(
        dt, transform, distanceWeapon.distanceWeapondata.attackSpeed, angle);
    if (initPosition.distanceTo(absolutePosition) >
        distanceWeapon.distanceWeapondata.distanceToShoot) {
      distanceWeapon.hitPoints.remove(this);
      distanceWeapon.isAttacking = false; //optimize here
      removeFromParent();
      return;
    }
  }
}
