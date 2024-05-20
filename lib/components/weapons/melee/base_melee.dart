import 'dart:math';

import 'package:caterpillar_crawl/components/enemy/enemy.dart';
import 'package:caterpillar_crawl/components/map/ground_map.dart';
import 'package:caterpillar_crawl/models/data/weapon_data.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class BaseMeleeWeapon extends PositionComponent {
  WeaponData weaponData;
  bool isAttacking = false;
  WeaponHolder weaponHolder = WeaponHolder.player;

  Vector2 orientation = Vector2.zero();

  GroundMap map;

  Vector2 idlescale = Vector2(0.1, 0.1);

  double enemyHitRadius = 0;
  double playerhitradius = 0;

  Vector2 startPosition = Vector2.zero();
  Vector2 endPosition = Vector2.zero();

  List<PositionComponent> hitPoints = [];

  late ScaleEffect scaleEffect;

  BaseMeleeWeapon({required this.weaponData, required this.map});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    enemyHitRadius = weaponData.hitRadius + 10;
    playerhitradius = weaponData.hitRadius + map.player.size.x;
    size = weaponData.size;
    Sprite weaponSprite = await Sprite.load(weaponData.pathToSprite);
    SpriteComponent spriteComponent =
        SpriteComponent(size: size, sprite: weaponSprite);
    anchor = Anchor.center;
    anchor = Anchor.bottomCenter;
    add(spriteComponent);
    priority = 1000;
    // scaleEffect = ScaleEffect.to(Vector2(0.1, 0.1), EffectController(duration: 0.5));
    // add(scaleEffect);
    scale = idlescale;
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
    scale = Vector2.all(1);
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
}

enum WeaponHolder { enemy, player }
