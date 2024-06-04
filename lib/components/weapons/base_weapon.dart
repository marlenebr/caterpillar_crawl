import 'package:caterpillar_crawl/components/enemy/enemy.dart';
import 'package:caterpillar_crawl/components/map/ground_map.dart';
import 'package:caterpillar_crawl/models/data/weapon_data.dart';
import 'package:flame/components.dart';

class BaseWeapon extends PositionComponent {
  WeaponData weaponData;
  bool isAttacking = false;
  WeaponHolder weaponHolder = WeaponHolder.player;

  List<PositionComponent> hitPoints = [];

  GroundMap map;

  double enemyHitRadius = 0;
  double playerhitradius = 0;
  BaseWeapon({required this.weaponData, required this.map});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    enemyHitRadius = weaponData.hitRadius + 10;
    playerhitradius = map.player.size.x / 2;
    size = weaponData.size;
    if (weaponData.pathToSprite != "") {
      Sprite weaponSprite = await Sprite.load(weaponData.pathToSprite);
      SpriteComponent spriteComponent =
          SpriteComponent(size: size, sprite: weaponSprite);
      add(spriteComponent);
    }
    anchor = Anchor.center;
    anchor = Anchor.bottomCenter;
    priority = 1000;
  }

  void updateHits() {
    switch (weaponHolder) {
      case WeaponHolder.enemy:
        for (PositionComponent hitPos in hitPoints) {
          if (map.player.absolutePosition.distanceTo(hitPos.absolutePosition) <
              playerhitradius) {
            map.player.hurt();
            continue;
          }
        }
      case WeaponHolder.player:
        for (Enemy enemy in map.enemies.values) {
          for (PositionComponent hitPos in hitPoints) {
            if (enemy.absolutePosition.distanceTo(hitPos.absolutePosition) <
                enemyHitRadius) {
              enemy.onEnemyHit(weaponData.damagePerHit, false);
              continue;
            }
          }
        }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isAttacking) {
      updateHits();
    }
  }

  void startAttacking() {
    isAttacking = true;
  }
}

enum WeaponHolder { enemy, player }
