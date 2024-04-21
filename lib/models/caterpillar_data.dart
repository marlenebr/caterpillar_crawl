import 'package:caterpillar_crawl/models/animation_data.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class CaterpillarData {
  final AnimationData idleAnimation;
  final AnimationData? wobbleAnimation;
  final double anchorPosY;
  final double movingspeed;
  final double
      refinedSegmentDistance; //value to slightly change the segment distance - depends on how the sprite design looks the best with
  final AnimationData segmentAnimation;
  final int maxElementCount;

  const CaterpillarData({
    required this.idleAnimation,
    required this.wobbleAnimation,
    required this.anchorPosY,
    required this.movingspeed,
    required this.refinedSegmentDistance,
    required this.segmentAnimation,
    required this.maxElementCount,
  });

  static CaterpillarData createCaterpillarData() {
    //Data for first Caterpillar - Green Wobbly
    return CaterpillarData(
        idleAnimation: AnimationData(
            imagePath: 'caterPillar_head.png',
            spriteSize: Vector2.all(128),
            animationstepCount: 4,
            finalSize: Vector2.all(64)),
        wobbleAnimation: AnimationData(
            imagePath: 'caterpillar_wobble.png',
            spriteSize: Vector2.all(128),
            animationstepCount: 5,
            finalSize: Vector2.all(64)),
        anchorPosY: 75,
        movingspeed: 120,
        refinedSegmentDistance: 0.45,
        segmentAnimation: AnimationData(
            imagePath: 'caterPillar_segment.png',
            spriteSize: Vector2.all(128),
            finalSize: Vector2(64, 64),
            animationstepCount: 4),
        maxElementCount: 150);
  }
}

class MovementTransferData {
  final Vector2 orientation;
  final Vector2 position;

  final double angle;

  const MovementTransferData(
      {required this.orientation, required this.position, required this.angle});
}
