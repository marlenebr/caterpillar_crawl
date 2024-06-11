import 'dart:math';

import 'package:caterpillar_crawl/components/weapons/base_weapon.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/data/weapon_data.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';

class BaseDistanceWeapon extends BaseWeapon {
  DistanceWeaponData distanceWeapondata;

  BaseDistanceWeapon({required super.weaponData, required super.map})
      : distanceWeapondata = weaponData as DistanceWeaponData;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    anchor = Anchor.center;
  }

  shootMultipleMunitions(CaterpillarCrawlMain gameWorld, Vector2 position,
      double angle, int pelletCount) {
    int pelletsPerSide = (pelletCount / 2).toInt();
    double rotationAngle = 0.3;
    double startAngle = rotationAngle * pelletsPerSide;
    if (pelletCount % 2 != 0) {
      startAngle += rotationAngle / 2;
    }
    for (int i = 0; i < pelletCount; i++) {
      BaseDistanceMunition pellet = BaseDistanceMunition(distanceWeapon: this);
      gameWorld.world.add(pellet);
      pellet.position = absolutePosition;
      pellet.angle = absoluteAngle + startAngle * i;
    }
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
