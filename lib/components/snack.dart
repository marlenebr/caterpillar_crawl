
import 'package:caterpillar_crawl/components/caterpillar.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Snack extends SpriteComponent with CollisionCallbacks
{

late final RectangleHitbox hitBox;

  Snack({super.position}) : super(size: Vector2.all(16));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('Leaf.png');
    anchor = Anchor.center;
    hitBox = RectangleHitbox();
    add(hitBox);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is CaterPillar) {
      removeFromParent();
    }
  }
}
