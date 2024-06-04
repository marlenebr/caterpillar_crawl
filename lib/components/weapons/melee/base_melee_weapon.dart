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
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void startAttacking() {
    super.startAttacking();
    scale = Vector2.all(1);
  }
}
