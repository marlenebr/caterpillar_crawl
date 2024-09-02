import 'package:caterpillar_crawl/components/items/collectible_item.dart';
import 'package:caterpillar_crawl/models/data/moving_data.dart';
import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

class WeaponCollectItem extends CollectibleItem {
  final double inconSize = 64;
  late SpriteComponent heartSpriteComponent;
  WeaponCollectItem({
    required super.map,
    super.iconSpritePath = "sword.png",
    required super.movingdata,
  }) {
    distToPlayer = UIConstants.imageSizeSmall / 2 + map.player.size.x / 2;
    movingdata = MovingData.createItemMovingdata();
    onPlayerCollected = () => map.player.addMeleeWeapon();
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final effect = MoveByEffect(
      (absolutePosition - map.player.absolutePosition).normalized() * 100,
      EffectController(duration: 1.5, curve: Curves.easeOut),
    );
    await add(effect);
  }
}
