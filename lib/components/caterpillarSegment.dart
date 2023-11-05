import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/caterpillarData.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

///The body segments to be added behind the previous one (or the head)
class CaterpillarSegment extends PositionComponent
{

  CaterpillarSegmentData segmentData;

  Forge2DWorld gameWorld;

  CaterpillarSegment({required this.segmentData, required this.gameWorld});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2.all(64);
    final scale = Vector2.all(size.x/segmentData.spriteSize.x);
    final double anchorPos = (segmentData.anchorPosYTop/segmentData.spriteSize.y);
    //anchor = Anchor(0,anchorPos);
    addSegmentSprite();
    position = Vector2(0,anchorPos * size.y*2);
  }

  @override
  void update(double dt) {
    super.update(dt); 
    //position = parentSegment.position;
  }

  Future<void> addSegmentSprite()
  async {
    final scale = Vector2.all(super.size.x/segmentData.spriteSize.x);
    final data = SpriteAnimationData.sequenced(
    textureSize: segmentData.spriteSize,
    amount: 4,
    stepTime: 0.1,
    );

    final SpriteAnimationComponent animation = SpriteAnimationComponent.fromFrameData(
        await imageLoader.load(segmentData.imagePath),
        data,
        scale: scale
      );
    add(animation);
  }

  void connectSegments(BodyComponent previousSegmentBody, BodyComponent thisSegmentBody)
  {
    final jointDef = RevoluteJointDef()
    ..initialize(previousSegmentBody.createBody(), thisSegmentBody.createBody(), Vector2(0, 0));
    gameWorld.createJoint(RevoluteJoint(jointDef));
  }
}
