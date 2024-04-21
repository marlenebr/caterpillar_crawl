import 'package:caterpillar_crawl/models/animation_data.dart';
import 'package:flame/components.dart';

class EnemyData {
  final AnimationData idleAnimation;
  final AnimationData? wobbleAnimation;
  final double movingspeed;
  final List<Vector2> moveToPositions;

  const EnemyData({
    required this.idleAnimation,
    required this.wobbleAnimation,
    required this.movingspeed,
    required this.moveToPositions,
  });

  static EnemyData createEnemeyData() {
    return EnemyData(
      idleAnimation: AnimationData(
        imagePath: 'enemy_head_anim.png',
        spriteSize: Vector2.all(128),
        finalSize: Vector2.all(64),
        animationstepCount: 3,
      ),
      movingspeed: 0.5,
      wobbleAnimation: null,
      moveToPositions: <Vector2>[
        Vector2(-60, -10),
        Vector2(0, 60),
        Vector2(60, 60),
      ],
    );
  }
}
