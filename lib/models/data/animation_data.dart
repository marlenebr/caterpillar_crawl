import 'package:flame/components.dart';

class AnimationData {
  final String imagePath;
  final Vector2 spriteSize;
  final Vector2 finalSize;
  final int animationstepCount;

  const AnimationData({
    required this.imagePath,
    required this.spriteSize,
    required this.finalSize,
    required this.animationstepCount,
  });
}
