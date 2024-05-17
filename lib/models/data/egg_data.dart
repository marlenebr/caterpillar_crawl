import 'package:caterpillar_crawl/models/data/animation_data.dart';
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
          animationstepCount: 4),
      explodingEgg: AnimationData(
          imagePath: 'bombanimexplode.png',
          spriteSize: Vector2.all(128),
          finalSize: Vector2.all(128),
          animationstepCount: 11),
    );
  }
}
