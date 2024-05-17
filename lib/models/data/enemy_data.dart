import 'package:caterpillar_crawl/models/data/animation_data.dart';
import 'package:caterpillar_crawl/models/data/moving_data.dart';
import 'package:flame/components.dart';

class EnemyData {
  final AnimationData idleAnimation;
  final AnimationData? deadAnimation;
  final MovingData movingData;

  const EnemyData({
    required this.idleAnimation,
    required this.deadAnimation,
    required this.movingData,
  });

  static EnemyData createEnemeyData() {
    return EnemyData(
      idleAnimation: AnimationData(
        imagePath: 'enemywalk.png',
        spriteSize: Vector2.all(128),
        finalSize: Vector2.all(64),
        animationstepCount: 3,
      ),
      deadAnimation: AnimationData(
        imagePath: 'deadenemy.png',
        spriteSize: Vector2.all(128),
        finalSize: Vector2.all(64),
        animationstepCount: 9,
      ),
      movingData: MovingData.createenemyMovingData(),
    );
  }
}
