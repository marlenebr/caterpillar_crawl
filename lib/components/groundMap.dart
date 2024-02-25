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
  int snackCount;
  int enemyIndexer = 1;
  double secondCounter = 0;

  CaterpillarCrawlMain world;

  bool hasEnemies = false;
  bool calcDist  =false;

  Map<int,Vector2> snackData = {};
  Map<int,Snack> snacks = {};

  CaterPillar player;
  Map<int,CaterPillar> caterpillars = {};

  bool isCalculatingSnacks = false;


  GroundMap(this.mapSize, this.player, this.world,this.snackCount) : super(size: Vector2.all(mapSize));


  @override
  Future<void> onLoad() async {
    priority = 1;
    add(GroundMapFloorParallax(player,super.size/6));
    add(SpriteComponent(
      sprite: await Sprite.load('leafGround01.png'),
      size: Vector2.all(mapSize))
    );
    anchor = Anchor.center;
    player.transform.position = Vector2.all(0);
    caterpillars[0] = player; 
    await fillWithSnacks(snackCount);
  }

  @override
  Future onMount() async{
  }

  @override
  void update(double dt) {    
    super.update(dt);
    resetPlayerOnMapEnd();
    updateEnemydirection(dt,3);
    calculateSnacks(); 
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  void calculateSnacks()
  {
    for(int i  = 0; i<snacks.length;i++)
    {
      caterpillars.forEach((k,v) { 
              if(v.position.distanceTo(snacks[i]!.position) <60)
              {
                removeSnack(snacks[i]!);
                addSnack(i);
                updatePlayOnSnackEaten(k,v);
              }
      });     
    }
  }

  bool coolDownForNextSpeedChange = false;

  void updatePlayOnSnackEaten(int cIndex, CaterPillar caterpillar)
  {
    caterpillar.snackCount++;
    caterpillar.addCaterpillarSegemntRequest();
    if(caterpillar.lastSegment!=null)
    {
      if(cIndex==0) //its the main plaxer
      {
        world.onSegmentAddedToPlayer(caterpillar.lastSegment!.index);
      }
      else
      {
        world.onSegmentAddedToEnemy(caterpillar.lastSegment!.index);
      }
    }
  }

  void resetPlayerOnMapEnd()
  {
    caterpillars.forEach((key, value) {
      if(caterpillars[key]!.transform.position.x.abs() >mapSize/2 || caterpillars[key]!.transform.position.y.abs() >mapSize/2)
      {
        caterpillars[key]!.transform.position = Vector2.all(0);
      }
    }); 
  }

  Future<void> fillWithSnacks(int snackCount)
  async {
    for(int i= 0; i<snackCount;i++)
    {
      addSnack(i);
    }
  }

  Snack addSnack(int index)
  {
    Vector2 randomPosition = Vector2(Random().nextDouble(),Random().nextDouble()) * mapSize - size/2;
    double randomSize = (Random().nextDouble() +8) * 2;
    double randomAngle = Random().nextDouble() * 360;
    Snack newSnack  =Snack(snackSize: randomSize,snackAngle: randomAngle,snackPosition: randomPosition, groundMap: this, index: index);
    snacks[index] = newSnack;
    snackData[index] = newSnack.position;    
    world.world.add(newSnack);
    return newSnack;
  }

  void removeSnack(Snack snack)
  {
    snack.removeFromParent();
  }

  void addEnemy(CaterPillar enemyCaterpillar)
  {
    caterpillars[enemyIndexer]=enemyCaterpillar;
    caterpillars[enemyIndexer]!.transform.position = Vector2(Random().nextDouble(),Random().nextDouble()) * mapSize - size/2;
    hasEnemies  = true;
    enemyIndexer++;
  }

  bool updateEnemydirection(double dt,double frameDuration)
  {
    if(hasEnemies)
    {
      secondCounter += dt;
      if(secondCounter >=frameDuration)
      {
        secondCounter  =0;
        caterpillars.forEach((key, value) {
          if(key > 0) //0 is player
          {
            value.onMoveDirectionChange(player.position);
          }
        });
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
    parallax?.baseVelocity = player.orientation * player.velocity; 
   }
}