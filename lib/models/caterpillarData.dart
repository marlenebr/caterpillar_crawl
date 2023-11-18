import 'package:flame/components.dart';
import 'package:flame/game.dart';

class CaterpillarData
{
  final String imagePath;
  final Vector2 spriteSize;
  final double anchorPosY;
  final CaterpillarSegmentData caterpillarSegment;
  final Vector2 finalSize;


  const CaterpillarData({
    required this.imagePath,
    required this.spriteSize,
    required this.anchorPosY,
    required this.caterpillarSegment,
    required this.finalSize
    });
}

class CaterpillarSegmentData
{
  final String imagePath;
  final Vector2 spriteSize;
  final Vector2 finalSize;


  const CaterpillarSegmentData({
    required this.imagePath,
    required this.spriteSize,
    required this.finalSize
    });
}

class MovementTransferData
{
  final double angle;
  final Vector2 position;

  const MovementTransferData({required this.angle,required this.position});
}