import 'dart:math';

import 'package:caterpillar_crawl/components/weapons/melee/base_melee_weapon.dart';
import 'package:flame/components.dart';

class MiniSword extends BaseMeleeWeapon {
  MiniSword({required super.weaponData, required super.map});

  double startAngle = 0;
  double endAngle = 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    initializeMovementData();
    createBlade();
    map.world.meleeButtonViewModel
        .onChangeType('sword.png', () => map.world.onPewPewButtonclicked());
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateAttacking(dt);
  }

  void updateAttacking(double dt) {
    if (isAttacking) {
      angle -= meleeWeapondata.rotationSpeed! * startAngle * dt;
      if (angle < endAngle) {
        isAttacking = false;
        angle = startAngle;
        scale = idlescale;
      }
    }
  }

  void initializeMovementData() {
    startAngle = pi / 2;
    endAngle = -pi / 2;
    angle = startAngle;
  }

  void createBlade() {
    for (double i = size.y - meleeWeapondata.hitRadius * 2;
        i > 0;
        i -= meleeWeapondata.hitRadius * 2) {
      PositionComponent hitPoint =
          PositionComponent(position: Vector2(size.x / 2, i));
      add(hitPoint);
      hitPoints.add(hitPoint);
    }
  }
}
