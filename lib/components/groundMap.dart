import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillar.dart';
import 'package:caterpillar_crawl/components/snack.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame_isolate/flame_isolate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GroundMap extends PositionComponent with FlameIsolate
{

  double mapSize;
  CaterPillar player;
  int snackCount;
  late List<CaterPillar> enemies;
  double secondCounter = 0;

  CaterpillarCrawlMain world;

  bool hasEnemies = false;
  bool calcDist  =false;

  //late List<Snack> allSnacks = List.filled(snackCount, Snack(snackSize: 0,snackAngle: 0, snackPosition: Vector2.zero(),groundMap: this));
  Map<int,Vector2> snackData = {};
  Map<int,Snack> snacks = {};

  bool isCalculatingSnacks = false;


  GroundMap(this.mapSize, this.player, this.world,this.snackCount) : super(size: Vector2.all(mapSize));


  @override
  Future<void> onLoad() async {
    priority = 1;
    enemies = List.empty(growable: true);
    add(GroundMapFloorParallax(player,super.size/6));
    add(SpriteComponent(
      sprite: await Sprite.load('leafGround01.png'),
      size: Vector2.all(mapSize))
    );
    anchor = Anchor.center;
    player.transform.position = Vector2.all(0);
    await fillWithSnacks(snackCount);
  }

  @override
  Future onMount() {
    return super.onMount();
  }

  @override
  void update(double dt) {    
    super.update(dt);
    resetPlayerOnMapEnd();
    updateEnemydirection(dt,3);
    if(world.usingIsolates)
    {
      if(!isCalculatingSnacks)
      {
        calculateSnacksIsolate();
      }
    }
    else
    {
      calculateSnacksForWeb();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  void calculateSnacksForWeb()
  {
    for(int i  = 0; i<snacks.length;i++)
    {
      if(player.position.distanceTo(snacks[i]!.position) <60)
      {
        removeSnack(snacks[i]!);
        addSnack(i);
        updatePlayOnSnackEaten(player);
      }

      else
      {
        enemies.forEach((element) { 
                if(element.position.distanceTo(snacks[i]!.position) <60)
                {
                  removeSnack(snacks[i]!);
                  addSnack(i);
                  updatePlayOnSnackEaten(element);
                }
        });
      }
    }
  }

  void updatePlayOnSnackEaten(CaterPillar caterpillar)
  {
    caterpillar.snackCount++;
    caterpillar.addCaterpillarSegemntRequest();
    if(caterpillar.lastSegment!=null)
    {
      world.onSegmentAddedToPlayer(caterpillar.lastSegment!.index);
    }
  }

  Future calculateSnacksIsolate() async
  {
    isCalculatingSnacks = true;
    isolate(checkAllSnacks, SnackDistanceArgs(snackData, player.position)).then(_updateSnackOmIsolateResult);
    isCalculatingSnacks =false;
  }

  void _updateSnackOmIsolateResult(List<int> result)
  {
    for(int i  = 0; i<result.length;i++)
    {
      removeSnack(snacks[result[i]]!);
      addSnack(result[i]);
      updatePlayOnSnackEaten(player);    
    }
  }

  void resetPlayerOnMapEnd()
  {
    if(player.transform.position.x.abs() >mapSize/2 || player.transform.position.y.abs() >mapSize/2)
    {
      player.transform.position = Vector2.all(0);
    }

    for(int i = 0; i<enemies.length ;i++)
    {
      {Vector2 enemyPos = enemies[i].transform.position;
        if(enemyPos.x.abs() >mapSize/2 || enemyPos.y.abs() >mapSize/2)
        {
          enemies[i].transform.position = Vector2.all(0);
        }
      }
    }
    
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
    //snacks.remove(snack.index);
   // snackData.remove(snack.index);
    snack.removeFromParent();
  }

  void addEnemy(CaterPillar enemyCaterpillar)
  {
    enemies.add(enemyCaterpillar);
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
        enemies.forEach((element) {
            element.onMoveDirectionChange(player.position);
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
    parallax?.baseVelocity = player.velocity; 
   }
}

//Isolate Distance chack

List<int> checkAllSnacks(SnackDistanceArgs args)
{
  List<int> snacksToRemove = List.empty(growable: true);

  args.allSnacks.forEach((k, v) => 
  {
    if(args.playerPos.distanceTo(v) <60)
      {
        snacksToRemove.add(k)
      }   
  });
  return snacksToRemove;
}

class SnackDistanceArgs
{
  Map<int,Vector2> allSnacks;
  Vector2 playerPos;

  SnackDistanceArgs(this.allSnacks, this.playerPos);

}