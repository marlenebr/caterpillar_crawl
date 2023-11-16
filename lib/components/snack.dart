
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
  }

   @override
  void update(double dt) {    
    if(groundMap.player.position.distanceTo(position) <60)
    {
      removeFromParent();
      groundMap.addSnack();
      groundMap.player.snackCount++;
      groundMap.player.addCaterpillarSegemntRequest();
    }
  }
}
