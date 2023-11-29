import 'package:flame/components.dart';
import 'package:flame/game.dart';

class CaterpillarData
{
  final String imagePath;
  final Vector2 spriteSize;
  final double anchorPosY;
  final double movingspeed;
  final double refinedSegmentDistance; //value to slightly change the segment distance - depends on how the sprite design looks the best with
  final int animationSprites;
  final CaterpillarSegmentData caterpillarSegment;
  final Vector2 finalSize;


  const CaterpillarData({
    required this.imagePath,
    required this.spriteSize,
    required this.anchorPosY,
    required this.movingspeed,
    required this.refinedSegmentDistance,
    required this.animationSprites,
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
  final Vector2 orientation;
  final Vector2 position;
  final double angle;

  const MovementTransferData({required this.orientation,required this.position,required this.angle});
}