import 'package:caterpillar_crawl/components/weapons/distance/base_distance_weapon.dart';
import 'package:flame/components.dart';

class DungBallShooter extends BaseDistanceWeapon {
  DungBallShooter({required super.weaponData, required super.map});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    anchor = Anchor.bottomCenter;
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void startAttacking() {
    super.startAttacking();
    shootMultipleMunitions(map.world, position, angle, map.level + 1);
  }
}
