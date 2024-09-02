import 'package:caterpillar_crawl/components/moving_around_component.dart';
import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:flame/components.dart';

class CollectibleItem extends MovingAroundComponent {
  double iconSize;
  final String iconSpritePath;
  double distToPlayer;
  late SpriteComponent spriteComponent;
  Function? onPlayerCollected;

  CollectibleItem({
    required this.iconSpritePath,
    this.onPlayerCollected,
    required super.map,
    required super.movingdata,
  })  : iconSize = UIConstants.iconSizeMedium,
        distToPlayer = UIConstants.iconSizeMedium / 2 + map.player.size.x / 2;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2.all(iconSize);
    Sprite sprite = await Sprite.load(iconSpritePath);
    spriteComponent =
        SpriteComponent(size: Vector2.all(iconSize), sprite: sprite);
    anchor = Anchor.center;
    await add(spriteComponent);
    priority = 8;
  }

  @override
  void update(double dt) {
    super.update(dt);
    //no rotation of sprite
    spriteComponent.angle = -angle;
    //magnetic effect somehow
    if (map.player.position.distanceTo(position) < distToPlayer) {
      onPlayerCollected!();
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
