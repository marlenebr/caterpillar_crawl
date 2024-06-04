import 'package:flame/components.dart';

class WeaponData {
  String pathToSprite;
  double attackSpeed;
  Vector2 size;
  double hitRadius;
  int damagePerHit;

  WeaponData(
      {required this.pathToSprite,
      required this.attackSpeed,
      required this.size,
      required this.hitRadius,
      required this.damagePerHit});
}

class DistanceWeaponData extends WeaponData {
  double distanceToShoot;

  DistanceWeaponData(
      {required this.distanceToShoot,
      required super.pathToSprite,
      required super.size,
      required super.hitRadius,
      required super.damagePerHit,
      required super.attackSpeed});

  static DistanceWeaponData createDungBall() {
    return DistanceWeaponData(
        distanceToShoot: 120,
        pathToSprite: "",
        attackSpeed: 1,
        size: Vector2(32, 32),
        hitRadius: 16,
        damagePerHit: 2);
  }
}

class MeleeWeaponData extends WeaponData {
  MeleMovement meleeMovement;
  double? rotationSpeed;

  MeleeWeaponData(
      {this.rotationSpeed,
      required this.meleeMovement,
      required super.pathToSprite,
      required super.size,
      required super.hitRadius,
      required super.damagePerHit,
      required super.attackSpeed});

  static MeleeWeaponData createSwordData() {
    return MeleeWeaponData(
        pathToSprite: "sword.png",
        meleeMovement: MeleMovement.rotate,
        rotationSpeed: 4.5,
        attackSpeed: 4.5,
        size: Vector2(64, 128),
        hitRadius: 10,
        damagePerHit: 3);
  }
}

enum MeleMovement { rotate, shoot, explode }
