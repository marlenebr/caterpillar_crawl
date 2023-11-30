import 'dart:math';

import 'package:caterpillar_crawl/components/SpeedUpItem.dart';
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
  int snackCount;
  int enemyIndexer = 1;
  double secondCounter = 0;

  CaterpillarCrawlMain world;

  late SpeedUpItem speedUp;
  late SpeedUpItem speedDown;


  bool hasEnemies = false;
  bool calcDist  =false;

  //late List<Snack> allSnacks = List.filled(snackCount, Snack(snackSize: 0,snackAngle: 0, snackPosition: Vector2.zero(),groundMap: this));
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
    addSpeedItem();
  }

  @override
  Future onMount() async{
    await super.onMount();
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

    updateSpeedItems();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  void calculateSnacksForWeb()
  {
    for(int i  = 0; i<snacks.length;i++)
    {
      caterpillars.forEach((k,v) { 
              if(v.position.distanceTo(snacks[i]!.position) <60)
              {
                removeSnack(snacks[i]!);
                addSnack(i);
                updatePlayOnSnackEaten(v);
              }
      });     
    }
  }

  bool coolDownForNextSpeedChange = false;

  void updateSpeedItems()
  {
    if(player.position.distanceTo(speedUp.position)< 20)
    {
      if(player.speedMultiplier< 8)
      {
        player.speedMultiplier += 6;
      }
    }

    else if(player.position.distanceTo(speedDown.position)< 20)
    {
      if(player.speedMultiplier> 1)
      {
        player.speedMultiplier -= 1;
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
    Map<int,Vector2> caterpillarPoitionData = {};
    caterpillarPoitionData[0] = player.position;
    caterpillars.forEach((key, value) {caterpillarPoitionData[key]= value.position;});
    isolate(checkAllSnacks, SnackDistanceArgs(snackData, caterpillarPoitionData)).then(_updateSnackOmIsolateResult);
    isCalculatingSnacks =false;
  }

//first int player id, second int snack id
  void _updateSnackOmIsolateResult(Map<int,int> result)
  {
  result.forEach((key, value) {
      removeSnack(snacks[value]!);
      addSnack(value);
      updatePlayOnSnackEaten(caterpillars[key]!);
  });
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

  void addSpeedItem()
  {
    speedUp = SpeedUpItem(itemSize: 64, groundMap: this, index: 0);
    speedUp.position =  Vector2.all(400);
    world.world.add(speedUp);

    speedDown = SpeedUpItem(itemSize: 64, groundMap: this, index: 1);
    speedDown.position =  Vector2.all(-400);
    world.world.add(speedDown);
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

//Isolate Distance chack

Map<int,int> checkAllSnacks(SnackDistanceArgs args)
{
  Map<int,int> snacksToRemove = Map<int,int>();

  args.allSnacks.forEach((k, v) => 
  args.playerPos.forEach((key, value) { 
    if(value.distanceTo(v) <60)
    {
      snacksToRemove[key] = k;
    } 
  })
  
  );
  return snacksToRemove;
}

class SnackDistanceArgs
{
  Map<int,Vector2> allSnacks;
  Map<int,Vector2> playerPos;

  SnackDistanceArgs(this.allSnacks, this.playerPos);

}