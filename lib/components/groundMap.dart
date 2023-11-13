import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillar.dart';
import 'package:caterpillar_crawl/components/snack.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

class GroundMap extends PositionComponent
{

  double mapSize;
  CaterPillar player;

  GroundMap(this.mapSize, this.player) : super(size: Vector2.all(mapSize));


  @override
  Future<void> onLoad() async {
    add(GroundMapFloorParallax(player,super.size/6));
    add(SpriteComponent(
      sprite: await Sprite.load('leafGround01.png'),
      size: Vector2.all(mapSize))
    );
    anchor = Anchor.center;
    player.transform.position = Vector2.all(0);
    fillWithSnacks(80);
  }

    @override
  void update(double dt) {    
    super.update(dt);
    resetPlayerOnMapEnd();
  }

  @override
  void render(Canvas canvas) {
    // TODO: implement render
    canvas.drawPaint(Paint()..color = Color.fromARGB(255, 158, 179, 139));
    super.render(canvas);

  }

  void resetPlayerOnMapEnd()
  {
    if(player.transform.position.x.abs() >mapSize/2 || player.transform.position.y.abs() >mapSize/2)
    {
      player.transform.position = Vector2.all(0);
    }
  }

  void fillWithSnacks(int snackCount)
  {
    for(int i= 0; i<snackCount;i++)
    {
      Vector2 randomPosition = Vector2(Random().nextDouble(),Random().nextDouble()) * mapSize;
      double randomSize = (Random().nextDouble() +8) * 2;
      double randomAngle = Random().nextDouble() * 360;

      add(Snack(snackSize: randomSize,snackAngle: randomAngle,snackPosition: randomPosition));
    }
  }
}

class GroundMapFloorParallax extends ParallaxComponent<CaterpillarCrawlMain> {

  CaterPillar player;
  Vector2 tileSize;

  GroundMapFloorParallax(this.player, this.tileSize);

  @override
  Future<void> onLoad() async {
    parallax = await game.loadParallax(
      [
        ParallaxImageData('leafGround03.png'),
        ParallaxImageData('leafGround02.png'),
      ],
      baseVelocity: Vector2(0.1,0.1),
      velocityMultiplierDelta: Vector2(4, 4),
      filterQuality: FilterQuality.none,
      repeat: ImageRepeat.repeat,
      size: tileSize
    );
  }

   @override
   void update(double dt) {   
    super.update(dt);
    parallax?.baseVelocity = player.velocity; 
   }
}