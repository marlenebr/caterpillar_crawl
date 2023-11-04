import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/caterpillarData.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

///The body segments to be added behind the previous one (or the head)
class CaterpillarSegment extends PositionComponent
{

  CaterpillarSegmentData segmentData;

  BodyComponent parentSegmentBody;

  Forge2DWorld gameWorld;

  late BodyComponent bodyComponent;

  CaterpillarSegment({required this.segmentData , required this.parentSegmentBody, required this.gameWorld}): super(size: Vector2.all(64));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final double anchorPos = (segmentData.anchorPosYTop/segmentData.spriteSize.y);
    anchor = Anchor(0,anchorPos);
    bodyComponent =  BodyComponent();
    bodyComponent.debugMode = true;
    add(bodyComponent);
    addSegmentSprite();
    //position = parentSegment.transform.position + Vector2.all(1);
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

    final jointDef = RevoluteJointDef()
  ..initialize(bodyComponent.body, parentSegmentBody.body, anchor.toVector2());
gameWorld.createJoint(RevoluteJoint(jointDef));
  }

}
