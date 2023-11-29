
import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillar.dart';
import 'package:caterpillar_crawl/components/groundMap.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class SpeedUpItem extends SpriteComponent
{

  late SpriteAnimationComponent animation;

  double itemSize;
  int index;
  GroundMap groundMap;

  SpeedUpItem({required this.itemSize, required this.groundMap, required this.index}) : super(size: Vector2.all(itemSize));

  @override
  Future<void> onLoad() async {
    priority = 2;
    int randomInt = Random().nextInt(2)+1;
    sprite= await Sprite.load("snack00$randomInt.png");
    anchor = Anchor.center;
  }

   @override
  void update(double dt) {    
  }
}