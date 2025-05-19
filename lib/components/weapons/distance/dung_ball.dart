import 'package:caterpillar_crawl/components/weapons/distance/base_distance_weapon.dart';
import 'package:flame/components.dart';

class DungBallShooter extends BaseDistanceWeapon {
  bool isPlayerWeapon = false;
  DungBallShooter(
      {required super.weaponData,
      required super.map,
      required this.isPlayerWeapon});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    anchor = Anchor.bottomCenter;
  }

  @override
  void startAttacking() {
    super.startAttacking();
    if (isPlayerWeapon) {
      shootSingleMunition();
    } else {
      shootMultipleMunitions(map.world, position, angle, map.level + 1);
    }
  }
}
