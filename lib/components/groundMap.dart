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
  late CaterPillar? enemy;
  double secondCounter = 0;

  CaterpillarCrawlMain world;

  bool hasEnemies = false;

  GroundMap(this.mapSize, this.player, this.world) : super(size: Vector2.all(mapSize));


  @override
  Future<void> onLoad() async {
    priority = 1;
    enemy = null;
    add(GroundMapFloorParallax(player,super.size/6));
    add(SpriteComponent(
      sprite: await Sprite.load('leafGround01.png'),
      size: Vector2.all(mapSize))
    );
    anchor = Anchor.center;
    player.transform.position = Vector2.all(0);
    await fillWithSnacks(300);
  }

  @override
  void update(double dt) {    
    super.update(dt);
    resetPlayerOnMapEnd();
    updateEnemydirection(dt,3);
  }

  @override
  void render(Canvas canvas) {
    // TODO: implement render
    // canvas.drawPaint(Paint()..color = Color.fromARGB(255, 158, 179, 139));
    super.render(canvas);

  }

  void resetPlayerOnMapEnd()
  {
    if(player.transform.position.x.abs() >mapSize/2 || player.transform.position.y.abs() >mapSize/2)
    {
      player.transform.position = Vector2.all(0);
    }

    if(enemy !=  null)
    {Vector2 enemyPos = enemy!.transform.position;
      if(enemyPos.x.abs() >mapSize/2 || enemyPos.y.abs() >mapSize/2)
      {
        enemy?.transform.position = Vector2.all(0);
      }
    }
  }

  Future<void> fillWithSnacks(int snackCount)
  async {
    for(int i= 0; i<snackCount;i++)
    {
      addSnack();
    }
  }

  void addSnack()
  {
    Vector2 randomPosition = Vector2(Random().nextDouble(),Random().nextDouble()) * mapSize - size/2;
    double randomSize = (Random().nextDouble() +8) * 2;
    double randomAngle = Random().nextDouble() * 360;

    world.world.add(Snack(snackSize: randomSize,snackAngle: randomAngle,snackPosition: randomPosition, groundMap: this));
  }

  void addEnemy(CaterPillar enemyCaterpillar)
  {
    enemy = enemyCaterpillar;
    hasEnemies  = true;
  }

  bool updateEnemydirection(double dt,double frameDuration)
  {
    if(hasEnemies)
    {
      secondCounter += dt;
      if(secondCounter >=frameDuration)
      {
        secondCounter  =0;
        enemy?.onMoveDirectionChange(player.position);
      }
    }
    return false;
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