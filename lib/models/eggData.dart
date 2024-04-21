import 'package:caterpillar_crawl/models/animationData.dart';
import 'package:flame/components.dart';

class EggData {
  final AnimationData idleEgg;
  final AnimationData explodingEgg;

  const EggData({
    required this.idleEgg,
    required this.explodingEgg,
  });

  static EggData createEggData() {
    return EggData(
      idleEgg: AnimationData(
          imagePath: 'bombanim.png',
          spriteSize: Vector2.all(64),
          finalSize: Vector2.all(64),
          animationstepCount: 3),
      explodingEgg: AnimationData(
          imagePath: 'explodeanimall.png',
          spriteSize: Vector2.all(128),
          finalSize: Vector2.all(128),
          animationstepCount: 8),
    );
  }
}
