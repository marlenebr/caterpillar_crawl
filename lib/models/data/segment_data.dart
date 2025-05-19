import 'package:caterpillar_crawl/components/snack.dart';
import 'package:caterpillar_crawl/models/data/animation_data.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class SegmentData {
  final Map<SnackType, AnimationData> segmentAnitationDatas;

  const SegmentData({
    required this.segmentAnitationDatas,
  });

  static SegmentData createSegmentData() {
    Map<SnackType, AnimationData> animationDataMap =
        <SnackType, AnimationData>{};
    animationDataMap[SnackType.green] =
        getAnimationDataBySnackType(SnackType.green);

    animationDataMap[SnackType.red] =
        getAnimationDataBySnackType(SnackType.red);

    return SegmentData(segmentAnitationDatas: animationDataMap);
  }

  static AnimationData getAnimationDataBySnackType(SnackType snackType) {
    switch (snackType) {
      case SnackType.green:
        return AnimationData(
            imagePath: 'caterPillar_segment.png',
            spriteSize: Vector2.all(128),
            finalSize: Vector2(64, 64),
            animationstepCount: 4);
      case SnackType.red:
        return AnimationData(
            imagePath: 'dungball_animation.png',
            spriteSize: Vector2.all(64),
            animationstepCount: 3,
            finalSize: Vector2.all(64));
    }
  }
}
