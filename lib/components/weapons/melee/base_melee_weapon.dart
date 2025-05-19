import 'package:caterpillar_crawl/components/weapons/base_weapon.dart';
import 'package:caterpillar_crawl/models/data/weapon_data.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class BaseMeleeWeapon extends BaseWeapon {
  Vector2 idlescale = Vector2(0.1, 0.1);
  MeleeWeaponData meleeWeapondata;

  late ScaleEffect scaleEffect;

  BaseMeleeWeapon({required super.weaponData, required super.map})
      : meleeWeapondata = weaponData as MeleeWeaponData;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    scale = idlescale;
    map.world.meleeButtonViewModel.resetDuration(meleeWeapondata.durationFail);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isAttacking) {
      if (updateHits()) {
        map.world.meleeButtonViewModel.setWeaponDurationDown();
        if (map.world.meleeButtonViewModel.weaponDuration <= 0) {
          map.player.removeMeleeWeapon();
        }
      }
    }
  }

  @override
  void startAttacking() {
    if (map.world.meleeButtonViewModel.weaponDuration <= 0) {
      return;
    }
    super.startAttacking();
    scale = Vector2.all(1);
  }
}

enum MeleeWeaponType {
  miniSword,
}
