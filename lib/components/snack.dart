
import 'dart:math';

import 'package:caterpillar_crawl/components/groundMap.dart';
import 'package:flame/components.dart';

class Snack extends SpriteComponent
{

  late SpriteAnimationComponent animation;

  double snackSize;
  double snackAngle;
  int index;
  Vector2 snackPosition;
  GroundMap groundMap;

  Snack({required this.snackSize, required this.snackAngle, required this.snackPosition, required this.groundMap, required this.index}) : super(size: Vector2.all(snackSize), angle: snackAngle, position: snackPosition);

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
