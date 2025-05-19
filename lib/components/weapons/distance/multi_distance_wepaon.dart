import 'package:caterpillar_crawl/components/map/ground_map.dart';
import 'package:caterpillar_crawl/components/snack.dart';
import 'package:caterpillar_crawl/components/weapons/distance/base_distance_weapon.dart';
import 'package:caterpillar_crawl/components/weapons/distance/dung_ball.dart';
import 'package:caterpillar_crawl/components/weapons/distance/eggy_bomb.dart';
import 'package:caterpillar_crawl/models/data/animation_data.dart';
import 'package:caterpillar_crawl/models/data/weapon_data.dart';
import 'package:flame/components.dart';

class MultiDistanceWeapon extends PositionComponent {
  Map<SnackType, DistanceWeaponData> allDistanceWeaponData;
  Map<SnackType, BaseDistanceWeapon> allDistanceWeapons = {};
  GroundMap map;
  SnackType? currentActive = SnackType.green;

  MultiDistanceWeapon({required this.allDistanceWeaponData, required this.map});

  @override
  Future<void> onLoad() async {
    //DEBUG
    allDistanceWeaponData[SnackType.green]!.explodingAnimation = AnimationData(
        animationstepCount: 11,
        finalSize: Vector2.all(128),
        imagePath: "bombanimexplode.png",
        spriteSize: Vector2.all(128));

    //OVERWRITE
    allDistanceWeaponData[SnackType.red]!.attackSpeed = 16;
    allDistanceWeaponData[SnackType.red]!.hitRadius = 30;

    allDistanceWeapons[SnackType.green] = EggyBomb(
        weaponData: allDistanceWeaponData[SnackType.green] as WeaponData,
        map: map);
    allDistanceWeapons[SnackType.red] = DungBallShooter(
        weaponData: allDistanceWeaponData[SnackType.red] as WeaponData,
        map: map,
        isPlayerWeapon: true);

    allDistanceWeapons.forEach((key, value) async {
      await add(value);
      value.position = position;
      value.angle = angle;
    });

    setWeapon(currentActive);
  }

  void setWeapon(SnackType? snackType) {
    currentActive = snackType;
    allDistanceWeapons.forEach((key, value) async {
      (key == snackType) ? value.setActive(true) : value.setActive(false);
    });

    setViewButtonType(snackType);
  }

  void setViewButtonType(SnackType? snackType) {
    if (snackType == null) {
      map.world.distanceActionButtonViewModel
          .onChangeType(null, () => map.world.onLayEggTap());
    } else {
      map.world.distanceActionButtonViewModel.onChangeType(
          allDistanceWeaponData[currentActive]!.pathToMunitionIcon,
          () => map.world.onLayEggTap());
    }
  }

  void shoot() {
    allDistanceWeapons[currentActive]?.startAttacking();
  }
}
