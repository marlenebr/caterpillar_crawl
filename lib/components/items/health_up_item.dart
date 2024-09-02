import 'package:caterpillar_crawl/components/items/collectible_item.dart';
import 'package:caterpillar_crawl/models/data/moving_data.dart';
import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:flame/components.dart';

class HealthUpItem extends CollectibleItem {
  final double inconSize = 64;
  late SpriteComponent heartSpriteComponent;
  HealthUpItem({
    required super.map,
    super.iconSpritePath = "heartgreen_64.png",
    required super.movingdata,
  }) {
    distToPlayer = UIConstants.imageSizeSmall / 2 + map.player.size.x / 2;
    movingdata = MovingData.createItemMovingdata();
    onPlayerCollected = () => map.healthUp(this);
  }
}
