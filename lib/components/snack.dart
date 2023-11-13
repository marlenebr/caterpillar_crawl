
import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillar.dart';
import 'package:caterpillar_crawl/components/groundMap.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Snack extends SpriteComponent with CollisionCallbacks
{

late final RectangleHitbox hitBox;

  late SpriteAnimationComponent animation;

  double snackSize;
  double snackAngle;
  Vector2 snackPosition;
  GroundMap groundMap;

  Snack({required this.snackSize, required this.snackAngle, required this.snackPosition, required this.groundMap}) : super(size: Vector2.all(snackSize), angle: snackAngle, position: snackPosition);

  @override
  Future<void> onLoad() async {
    int randomInt = Random().nextInt(2)+1;
    sprite= await Sprite.load("snack00$randomInt.png");
    anchor = Anchor.center;
    hitBox = RectangleHitbox();
    add(hitBox);
  }

  // Future<void> _addSnackAnimationSprite(String spritePath)
  // async {
  //   final data = SpriteAnimationData.sequenced(
  //   textureSize: Vector2.all(64),
  //   amount: 3,
  //   stepTime: 0.2,
  //   );
  //    animation = SpriteAnimationComponent.fromFrameData(
  //     await imageLoader.load(spritePath),
  //     data,
  //     scale: Vector2.all(super.size.x/64)
  //   );
  //   add(animation);

  // }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is CaterPillar) {
      removeFromParent();
      groundMap.addSnack();
    }
  }
}
