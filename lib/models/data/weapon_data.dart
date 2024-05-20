import 'package:flame/components.dart';

class WeaponData {
  String pathToSprite;
  MeleMovement meleeMovement;
  double? movementSpeed;
  double? rotationSpeed;
  Vector2 size;
  double hitRadius;
  int damagePerHit;

  WeaponData(
      {required this.pathToSprite,
      required this.meleeMovement,
      this.movementSpeed,
      this.rotationSpeed,
      required this.size,
      required this.hitRadius,
      required this.damagePerHit});

  static WeaponData createSwordData() {
    return WeaponData(
        pathToSprite: "sword.png",
        meleeMovement: MeleMovement.rotate,
        rotationSpeed: 4.5,
        size: Vector2(64, 128),
        hitRadius: 10,
        damagePerHit: 3);
  }

  static WeaponData createDungBall() {
    return WeaponData(
        pathToSprite: "snack001.png",
        meleeMovement: MeleMovement.push,
        movementSpeed: 1,
        size: Vector2(32, 32),
        hitRadius: 16,
        damagePerHit: 3);
  }
}

enum MeleMovement { rotate, push, explode }
