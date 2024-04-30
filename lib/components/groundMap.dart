import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillar/caterpillar.dart';
import 'package:caterpillar_crawl/components/enemy.dart';
import 'package:caterpillar_crawl/components/snack.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/enemy_data.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

class GroundMap extends PositionComponent {
  double mapSize;
  int snackCount;
  int enemyCount;
  int enemyIndexer = 1;
  // double secondCounter = 0;

  CaterpillarCrawlMain world;

  bool hasEnemies = false;
  bool calcDist = false;

  Map<int, Vector2> snackData = {};
  Map<int, Snack> snacks = {};

  CaterPillar player;
  Map<int, Enemy> enemies = {};

  bool isCalculatingSnacks = false;

  GroundMap(
      {required this.mapSize,
      required this.player,
      required this.world,
      required this.snackCount,
      required this.enemyCount})
      : super(size: Vector2.all(mapSize));

  @override
  Future<void> onLoad() async {
    priority = 1;
    add(GroundMapFloorParallax(player, super.size / 6));
    add(SpriteComponent(
        sprite: await Sprite.load('leafGround01.png'),
        size: Vector2.all(mapSize)));
    anchor = Anchor.center;
    player.transform.position = Vector2.all(0);
    await fillWithSnacks(snackCount);
    await fillWithEnemies(enemyCount);
  }

  @override
  Future onMount() async {}

  @override
  void update(double dt) {
    super.update(dt);
    resetPlayerOnMapEnd();
    // updateEnemydirection(dt, 3);
    calculateSnacks();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  void calculateSnacks() {
    for (int i = 0; i < snacks.length; i++) {
      if (player.position.distanceTo(snacks[i]!.position) < 60) {
        removeSnack(snacks[i]!);
        addSnack(i);
        updatePlayOnSnackEaten();
      }
    }
  }

  bool coolDownForNextSpeedChange = false;

  void updatePlayOnSnackEaten() {
    player.addCaterpillarSegemntRequest();
    // if (player.lastSegment != null) {
    //   world.onSegmentAddedToPlayer(player.lastSegment!.index);
    // }
  }

  void resetPlayerOnMapEnd() {
    if (player.transform.position.x.abs() > mapSize / 2 ||
        player.transform.position.y.abs() > mapSize / 2) {
      player.transform.position = Vector2.all(0);
    }
  }

  Future<void> fillWithSnacks(int snackCount) async {
    for (int i = 0; i < snackCount; i++) {
      addSnack(i);
    }
  }

  Future<void> fillWithEnemies(int enemyCount) async {
    for (int i = 0; i < enemyCount; i++) {
      addEnemy(Enemy(enemyData: EnemyData.createEnemeyData(), map: this));
    }
  }

  Snack addSnack(int index) {
    double randomSize = (Random().nextDouble() + 8) * 2;
    double randomAngle = Random().nextDouble() * 360;
    Snack newSnack = Snack(
        snackSize: randomSize,
        snackAngle: randomAngle,
        snackPosition: getRandomPositionInMap(),
        groundMap: this,
        index: index);
    snacks[index] = newSnack;
    snackData[index] = newSnack.position;
    world.world.add(newSnack);
    return newSnack;
  }

  Vector2 getRandomPositionInMap() {
    return Vector2(Random().nextDouble(), Random().nextDouble()) * mapSize -
        size / 2;
  }

  void removeSnack(Snack snack) {
    snack.removeFromParent();
  }

  void addEnemy(Enemy enemy) {
    enemies[enemyIndexer] = enemy;
    enemies[enemyIndexer]!.transform.position = getRandomPositionInMap();
    hasEnemies = true;
    enemyIndexer++;
    world.world.add(enemy);
  }

//   bool updateEnemydirection(double dt, double frameDuration) {
//     if (hasEnemies) {
//       secondCounter += dt;
//       if (secondCounter >= frameDuration) {
//         secondCounter = 0;
//         enem.forEach((key, value) {
//           if (key > 0) //0 is player
//           {
//             value.onMoveDirectionChange(player.position);
//           }
//         });
//       }
//     }
//     return false;
//   }
}

class GroundMapFloorParallax extends ParallaxComponent<CaterpillarCrawlMain> {
  CaterPillar player;
  Vector2 tileSize;

  GroundMapFloorParallax(this.player, this.tileSize);

  @override
  Future<void> onLoad() async {
    parallax = await game.loadParallax([
      ParallaxImageData('leafGround03.png'),
      ParallaxImageData('leafGround02.png'),
    ],
        baseVelocity: Vector2(0.1, 0.1),
        velocityMultiplierDelta: Vector2(4, 4),
        filterQuality: FilterQuality.none,
        repeat: ImageRepeat.repeat,
        size: tileSize);
  }

  @override
  void update(double dt) {
    super.update(dt);
    parallax?.baseVelocity = player.orientation * player.baseSpeed * dt;
  }
}
