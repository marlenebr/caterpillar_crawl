import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillar/caterpillar.dart';
import 'package:caterpillar_crawl/components/enemy.dart';
import 'package:caterpillar_crawl/components/map/obstacle_snapshot.dart';
import 'package:caterpillar_crawl/components/obstacle.dart';
import 'package:caterpillar_crawl/components/powerups/health_up_item.dart';
import 'package:caterpillar_crawl/components/snack.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/data/enemy_data.dart';
import 'package:caterpillar_crawl/models/data/moving_data.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

class GroundMap extends PositionComponent {
  double mapSize;
  int snackCount;
  int enemyCount;
  int healthUpCount;

  int enemyIndexer = 1;
  int level = 0;

  CaterpillarCrawlMain world;
  late ObstacleSnapshot obstacleSnapshot;

  bool hasEnemies = false;
  bool calcDist = false;

  Map<int, Vector2> snackData = {};
  Map<int, Snack> snacks = {};

  CaterPillar player;
  Map<int, Enemy> enemies = {};
  Map<int, Obstacle> temporaryOsbstacles = {};
  // Map<int, Pellet> pellets = {};

  List<HealthUpItem> powerUps = [];

  bool isCalculatingSnacks = false;

  GroundMap(
      {required this.mapSize,
      required this.player,
      required this.world,
      required this.snackCount,
      required this.enemyCount,
      required this.healthUpCount})
      : super(size: Vector2.all(mapSize));

  @override
  Future<void> onLoad() async {
    priority = 1;
    await add(GroundMapFloorParallax(player, super.size / 6));
    await add(SpriteComponent(
        sprite: await Sprite.load('leafGround01.png'),
        size: Vector2.all(mapSize)));
    anchor = Anchor.center;
    await _createMapContent();
    // //DEBUG: 55FPS
    // for (int i = 0; i < 1600; i++) {
    //   obstacleSnapshot.addObstacle(getRandomPositionInMap(), 0, i);
    // }
  }

  @override
  Future onMount() async {
    player.position = Vector2.zero();
  }

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
        _addSnack(i);
        player.addCaterpillarSegemntRequest();
      }
    }
  }

  bool coolDownForNextSpeedChange = false;

  void resetPlayerOnMapEnd() {
    if (CaterpillarCrawlUtils.isOnOnMapEnd(player, mapSize)) {
      player.hurt();
      player.angle = (player.angle + pi) % (2 * pi);
      player.angleToLerpTo = player.angle;
    }
  }

  Future<void> fillWithSnacks(int snackCount) async {
    for (int i = 0; i < snackCount; i++) {
      _addSnack(i);
    }
  }

  Future<void> fillWithEnemies(int enemyCount) async {
    for (int i = 0; i < enemyCount; i++) {
      await _addEnemy();
    }
    world.onEnemiesChanged();
  }

  Future<void> fillWithHealthUpItems(int itemCount) async {
    for (int i = 0; i < itemCount; i++) {
      _addHealthUp();
    }
  }

  Snack _addSnack(int index) {
    return addSnackOnPosition(getRandomPositionInMap(), index);
  }

  Snack addSnackOnPosition(Vector2 pos, int? index) {
    int newIndex;
    if (index == null) {
      newIndex = snackData.length;
    } else {
      newIndex = index;
    }
    double randomSize = (Random().nextDouble() + 8) * 2;
    Snack newSnack = Snack(
        snackSize: randomSize,
        snackPosition: pos,
        groundMap: this,
        index: newIndex);
    snacks[newIndex] = newSnack;
    snackData[newIndex] = newSnack.position;
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

  Future<void> _addEnemy() async {
    Vector2 randomPos = getRandomPositionInMap();
    while (randomPos.distanceTo(player.position) < 20) {
      randomPos = getRandomPositionInMap();
    }
    Enemy enemy = Enemy(
        enemyData: EnemyData.createEnemeyData(),
        map: this,
        index: enemyIndexer);
    enemies[enemyIndexer] = enemy;
    enemies[enemyIndexer]!.transform.position = randomPos;
    hasEnemies = true;
    enemyIndexer++;
    world.world.add(enemy);
    await world.enemyIndicatorHUD.onAddEnemy(enemy);
  }

  // void _removeObstacle(Obstacle obstacle) {
  //   obstacles.remove(obstacle.index);
  //   obstacle.rem
  // }

  void _addHealthUp() {
    Vector2 randomPos = getRandomPositionInMap();
    while (randomPos.distanceTo(player.position) < 20) {
      randomPos = getRandomPositionInMap();
    }
    HealthUpItem healthUp = HealthUpItem(
        iconSize: 32, map: this, movingdata: MovingData.createItemMovingdata());
    healthUp.position = randomPos;
    world.world.add(healthUp);
    powerUps.add(healthUp);
  }

  void healthUp(HealthUpItem healthUp) {
    player.lives++;
    powerUps.remove(healthUp);
    //Add new one?
    _addHealthUp();
  }

  Future<void> levelUp() async {
    level++;
    player.grow();
    print("LEVEL UP");
    await fillWithEnemies(world.enemyCount - world.remainingEnemiesToLevelUp);
    world.onLevelUp();
    obstacleSnapshot.onLevelUp(80);
  }

  void killEnemy(Enemy enemy, bool respawnNew) {
    player.onEnemyKilled();
    if (respawnNew) {
      _addEnemy();
    }
    world.enemyIndicatorHUD.onRemoveEnemy(enemy);
    enemies.remove(enemy.index);
    if (enemies.values.length <= world.remainingEnemiesToLevelUp) {
      levelUp();
    }
    world.onEnemiesChanged();
  }

  void cleanUp() {
    player.removeFromParent();
    enemyIndexer = 1;
    level = 0;
    obstacleSnapshot.removeFromParent();
    snackData.clear();
    for (Snack snack in snacks.values) {
      snack.removeFromParent();
    }
    snacks.clear();
    for (Enemy enemy in enemies.values) {
      enemy.removeFromParent();
    }
    enemies.clear();

    for (Obstacle obstacle in temporaryOsbstacles.values) {
      obstacle.removeFromParent();
    }
    temporaryOsbstacles.clear();

    for (HealthUpItem heart in powerUps) {
      heart.removeFromParent();
    }
    powerUps.clear();
  }

  void removeComnpletly() {
    cleanUp();
    removeFromParent();
  }

  // void reset(CaterPillar caterpillar) {
  //   cleanUp();
  //   _createMapContent();
  // }

  Future<void> _createMapContent() async {
    await fillWithSnacks(snackCount);
    await fillWithEnemies(enemyCount);
    await fillWithHealthUpItems(healthUpCount);
    obstacleSnapshot = ObstacleSnapshot(mapSize: mapSize, world: world);
    world.world.add(obstacleSnapshot);
  }
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
