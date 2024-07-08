import 'package:caterpillar_crawl/components/obstacle.dart';
import 'package:caterpillar_crawl/models/data/animation_data.dart';
import 'package:flame/components.dart';

class ObstacleData {
  final String pathToDefaultSprite;
  final double size;
  final int calculateOnFrame = 3;
  final DamageTowards damageTowards;

  const ObstacleData(
      {required this.pathToDefaultSprite,
      required this.damageTowards,
      required this.size});

  static ObstacleData createBombObstacle() {
    return const ObstacleData(
        pathToDefaultSprite: "bombobstacle.png",
        damageTowards: DamageTowards.all,
        size: 128);
  }
}

class ThrowableObstacleData {
  final ObstacleData obstacleData;
  final String pathToFinalSprite;
  final AnimationData transformingAnimation;
  final double throwSpeed;

  const ThrowableObstacleData(
      {required this.obstacleData,
      required this.pathToFinalSprite,
      required this.transformingAnimation,
      required this.throwSpeed});

  static ThrowableObstacleData createUltiSegmentObstacle() {
    return ThrowableObstacleData(
        obstacleData: const ObstacleData(
          damageTowards: DamageTowards.damageToEnemy,
          pathToDefaultSprite: 'segment_single_dead_128.png',
          size: 64,
        ),
        pathToFinalSprite: 'ulti_segment_splash.png',
        throwSpeed: 7,
        transformingAnimation: AnimationData(
          animationstepCount: 7,
          finalSize: Vector2.all(64),
          imagePath: 'segment_ulti_anim_128.png',
          spriteSize: Vector2.all(128),
        ));
  }

  static ThrowableObstacleData createDeadSegmentObstacle() {
    return ThrowableObstacleData(
        obstacleData: const ObstacleData(
          damageTowards: DamageTowards.damageToPlayer,
          pathToDefaultSprite: 'segment_single_dead_128.png',
          size: 64,
        ),
        pathToFinalSprite: 'segment_falloff_splash.png',
        throwSpeed: 5,
        transformingAnimation: AnimationData(
          animationstepCount: 6,
          finalSize: Vector2.all(64),
          imagePath: 'segment_falloff_anim_128.png',
          spriteSize: Vector2.all(128),
        ));
  }
}
