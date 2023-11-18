
import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillar.dart';
import 'package:caterpillar_crawl/components/groundMap.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Snack extends SpriteComponent
{

  late SpriteAnimationComponent animation;

  double snackSize;
  double snackAngle;
  Vector2 snackPosition;
  GroundMap groundMap;

  Snack({required this.snackSize, required this.snackAngle, required this.snackPosition, required this.groundMap}) : super(size: Vector2.all(snackSize), angle: snackAngle, position: snackPosition);

  @override
  Future<void> onLoad() async {
    priority = 2;
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
      groundMap.world.onSegmentAddedToPlayer(groundMap.player.lastSegment!.index);

    }
    if(groundMap.enemy != null && groundMap.enemy!.position.distanceTo(position) < 60)
    {
      removeFromParent();
      groundMap.addSnack();
      groundMap.enemy?.snackCount++;
      if(groundMap.enemy!.snackCount % 3 ==0)
      {
        groundMap.enemy?.addCaterpillarSegemntRequest();
        groundMap.world.onSegmentAddedToEnemy(groundMap.enemy!.lastSegment!.index);
      }
    }
  }
}
