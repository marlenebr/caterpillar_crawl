import 'dart:math';

import 'package:caterpillar_crawl/components/weapons/melee/base_melee.dart';
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
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateAttacking(dt);
  }

  void updateAttacking(double dt) {
    if (isAttacking) {
      angle -= weaponData.rotationSpeed! * startAngle * dt;
      if (angle < endAngle) {
        isAttacking = false;
        angle = startAngle;
        scale = idlescale;
      }
    }
    // if (isTranslating) {
    //   orientation = Vector2(1 * sin(angle), -1 * cos(angle)).normalized();
    //   position += orientation * weaponData.movementSpeed! * dt;
    // }
  }

  void initializeMovementData() {
    startAngle = pi / 2;
    endAngle = -pi / 2;
    angle = startAngle;
  }

  void createBlade() {
    for (double i = size.y - weaponData.hitRadius * 2;
        i > 0;
        i -= weaponData.hitRadius * 2) {
      PositionComponent hitPoint =
          PositionComponent(position: Vector2(size.x / 2, i));
      // hitPoint.add(CircleComponent(
      //   radius: weaponData.hitRadius,
      //   paint: Paint()..color = Color.fromARGB(255, 226, 0, 30),
      // ));
      add(hitPoint);
      hitPoints.add(hitPoint);
    }
  }
}
