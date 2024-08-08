import 'package:caterpillar_crawl/components/enemy/enemy.dart';
import 'package:caterpillar_crawl/components/map/ground_map.dart';
import 'package:caterpillar_crawl/models/data/weapon_data.dart';
import 'package:flame/components.dart';

class BaseWeapon extends PositionComponent {
  WeaponData weaponData;
  bool isAttacking = false;
  WeaponHolder weaponHolder = WeaponHolder.player;
  bool removeHitPointsOnHit = false;

  List<PositionComponent> hitPoints = [];

  GroundMap map;

  final double _enemyHitRadius;
  final double _playerhitradius;
  BaseWeapon({required this.weaponData, required this.map})
      : _enemyHitRadius = weaponData.hitRadius + 10,
        _playerhitradius = weaponData.hitRadius;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = weaponData.size;
    if (weaponData.pathToSprite != "") {
      Sprite weaponSprite = await Sprite.load(weaponData.pathToSprite);
      SpriteComponent spriteComponent =
          SpriteComponent(size: size, sprite: weaponSprite);
      add(spriteComponent);
    }
    anchor = Anchor.center;
    anchor = Anchor.bottomCenter;
    priority = -1;
  }

  bool updateHits() {
    switch (weaponHolder) {
      case WeaponHolder.enemy:
        for (PositionComponent hitPos in hitPoints) {
          if (map.player.absolutePosition.distanceTo(hitPos.absolutePosition) <
              _playerhitradius + 16) {
            map.player.hurt();
            if (removeHitPointsOnHit) {
              hitPoints.remove(hitPos);
              hitPos.removeFromParent();
            }
            return true;
          }
        }
      case WeaponHolder.player:
        for (Enemy enemy in map.enemies.values) {
          for (PositionComponent hitPos in hitPoints) {
            if (enemy.absolutePosition.distanceTo(hitPos.absolutePosition) <
                _enemyHitRadius) {
              enemy.onEnemyHit(weaponData.damagePerHit, false);
              if (removeHitPointsOnHit) {
                hitPoints.remove(hitPos);
                hitPos.removeFromParent();
              }
              return true;
            }
          }
        }
    }
    return false;
  }

  void startAttacking() {
    isAttacking = true;
  }
}

enum WeaponHolder { enemy, player }
