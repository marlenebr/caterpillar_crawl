import 'package:caterpillar_crawl/models/animation_data.dart';
import 'package:flame/components.dart';

class EnemyData {
  final AnimationData idleAnimation;
  final AnimationData? deadAnimation;
  final double movingspeed;
  final int angleFractions;
  final bool moveCircle;
  final double wayDistance;

  const EnemyData(
      {required this.idleAnimation,
      required this.deadAnimation,
      required this.movingspeed,
      required this.angleFractions,
      required this.moveCircle,
      required this.wayDistance});

  static EnemyData createEnemeyData() {
    return EnemyData(
      idleAnimation: AnimationData(
        imagePath: 'enemywalk.png',
        spriteSize: Vector2.all(128),
        finalSize: Vector2.all(64),
        animationstepCount: 3,
      ),
      movingspeed: 0.5,
      deadAnimation: AnimationData(
        imagePath: 'deadenemy.png',
        spriteSize: Vector2.all(128),
        finalSize: Vector2.all(64),
        animationstepCount: 9,
      ),
      angleFractions: 3,
      moveCircle: true,
      wayDistance: 60,
    );
  }
}
