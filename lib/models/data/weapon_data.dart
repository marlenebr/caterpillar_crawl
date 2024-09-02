import 'package:caterpillar_crawl/models/data/animation_data.dart';
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
  AnimationData munitionanimation;
  AnimationData? explodingAnimation;

  DistanceWeaponData({
    explodingAnimation,
    required this.distanceToShoot,
    required this.munitionanimation,
    required super.pathToSprite,
    required super.size,
    required super.hitRadius,
    required super.damagePerHit,
    required super.attackSpeed,
  });

  static DistanceWeaponData createDungBall() {
    return DistanceWeaponData(
        distanceToShoot: 260,
        munitionanimation: AnimationData(
            animationstepCount: 3,
            finalSize: Vector2.all(32),
            imagePath: "dungball_animation.png",
            spriteSize: Vector2.all(64)),
        pathToSprite: "",
        attackSpeed: 1,
        size: Vector2(32, 32),
        hitRadius: 16,
        damagePerHit: 2);
  }

  static DistanceWeaponData createExplodingEgg() {
    return DistanceWeaponData(
        distanceToShoot: 111,
        explodingAnimation: AnimationData(
            animationstepCount: 11,
            finalSize: Vector2.all(128),
            imagePath: "bombanimexplode.png",
            spriteSize: Vector2.all(128)),
        munitionanimation: AnimationData(
            animationstepCount: 3,
            finalSize: Vector2.all(64),
            imagePath: "bombanim.png",
            spriteSize: Vector2.all(64)),
        pathToSprite: "",
        attackSpeed: 6,
        size: Vector2(64, 64),
        hitRadius: 16,
        damagePerHit: 2);
  }
}

class MeleeWeaponData extends WeaponData {
  MeleMovement meleeMovement;
  double? rotationSpeed;
  int durationFail;

  MeleeWeaponData(
      {this.rotationSpeed,
      required this.durationFail,
      required this.meleeMovement,
      required super.pathToSprite,
      required super.size,
      required super.hitRadius,
      required super.damagePerHit,
      required super.attackSpeed});

  static MeleeWeaponData createSwordData() {
    return MeleeWeaponData(
        pathToSprite: "sword.png",
        durationFail: 100,
        meleeMovement: MeleMovement.rotate,
        rotationSpeed: 6.5,
        attackSpeed: 4.5,
        size: Vector2(64, 128),
        hitRadius: 10,
        damagePerHit: 3);
  }
}

enum MeleMovement { rotate, shoot, explode }
