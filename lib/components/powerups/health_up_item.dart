import 'package:caterpillar_crawl/components/moving_around_component.dart';
import 'package:flame/components.dart';

class HealthUpItem extends MovingAroundComponent {
  double iconSize;
  final String _heartIconSpritePath = "heartgreen_64.png";
  double distToPlayer;
  late SpriteComponent heartSpriteComponent;
  HealthUpItem(
      {required this.iconSize, required super.map, required super.movingdata})
      : distToPlayer = iconSize / 2 + map.player.size.x / 2;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2.all(iconSize);
    Sprite heartSprite = await Sprite.load(_heartIconSpritePath);
    heartSpriteComponent =
        SpriteComponent(size: Vector2.all(iconSize), sprite: heartSprite);
    anchor = Anchor.center;
    await add(heartSpriteComponent);
    priority = 8;
  }

  @override
  void update(double dt) {
    super.update(dt);
    //no rotation of sprite
    heartSpriteComponent.angle = -angle;
    //magnetic effect somehow
    if (map.player.position.distanceTo(position) < distToPlayer) {
      map.healthUp(this);
      removeFromParent();
      return;
    } else if (map.player.position.distanceTo(position) <
        map.player.size.x * 1.5) {
      moveToPlayer = true;
    } else {
      moveToPlayer = false;
    }
  }
}
