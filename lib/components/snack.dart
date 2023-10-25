
import 'package:flame/components.dart';

class Snack extends SpriteComponent
{
  Snack({super.position}) : super(size: Vector2.all(16));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('Leaf.png');
    anchor = Anchor.center;
  }
}