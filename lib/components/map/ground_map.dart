import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillar/caterpillar.dart';
import 'package:caterpillar_crawl/components/caterpillar/caterpillar_base.dart';
import 'package:caterpillar_crawl/components/enemy/enemy.dart';
import 'package:caterpillar_crawl/components/items/weapon_collect_item.dart';
import 'package:caterpillar_crawl/components/map/obstacle_snapshot.dart';
import 'package:caterpillar_crawl/components/obstacle.dart';
import 'package:caterpillar_crawl/components/items/health_up_item.dart';
import 'package:caterpillar_crawl/components/snack.dart';
import 'package:caterpillar_crawl/components/weapons/melee/base_melee_weapon.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/data/enemy_data.dart';
import 'package:caterpillar_crawl/models/data/level_data.dart';
import 'package:caterpillar_crawl/models/data/moving_data.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

class GroundMap extends PositionComponent {
  int mapSize;
  int snackCount;
  int enemyCount;
  int healthUpCount;

  int enemyIndexer = 1;
  int level = 0;
  late LevelData currentLevel;

  CaterpillarCrawlMain world;
  late ObstacleSnapshot obstacleSnapshot;

  bool hasEnemies = false;
  bool calcDist = false;

  bool playerReachedLength = false;
  bool allEnemiesKilled = false;

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
      : super(size: Vector2.all(mapSize.toDouble()));

  @override
  Future<void> onLoad() async {
    priority = 1;
    anchor = Anchor.center;
    await add(GroundMapFloorParallax(player, super.size / 6));
    await add(
      SpriteComponent(
        priority: 1,
        sprite: await Sprite.load('leafGround01.png'),
        size: Vector2.all(mapSize.toDouble()),
        anchor: Anchor.center,
      ),
    );
    currentLevel = LevelManager.getLevelData(0)!;
    await _createMapContent();
    position = Vector2.all(mapSize / 2);
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

  void calculateSnacks() {
    for (int i = 0; i < snacks.length; i++) {
      if (player.position.distanceTo(snacks[i]!.position) < 60) {
        player.addSegment(snacks[i]!.snackType);
        removeSnack(snacks[i]!);
        _addSnack(i);
      }
    }
  }

  bool coolDownForNextSpeedChange = false;

  void resetPlayerOnMapEnd() {
    if (CaterpillarCrawlUtils.isOnOnMapEnd(player, mapSize.toDouble())) {
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

  Future<void> fillWithEnemies(int enemyCount, bool holdWeapon) async {
    //Get random enemy to hold a hiding weapon
    int RandomWeaponHolderIndex = Random().nextInt(enemyCount);
    for (int i = 0; i < enemyCount; i++) {
      holdWeapon
          ? await _addEnemy(RandomWeaponHolderIndex == i)
          : await _addEnemy(false);
    }
    world.caterpillarStatsViewModel.setEnemiesInGame(enemies.values.length);
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
    int maxValue =
        currentLevel.possibleSnackTypes.contains(SnackType.red) ? 10 : 2;
    int snackTypeDistribution = Random().nextInt(maxValue);
    Snack newSnack;
    if (snackTypeDistribution < 7) {
      newSnack = Snack(
          snackSize: randomSize,
          snackPosition: pos,
          groundMap: this,
          index: newIndex,
          snackType: SnackType.green);
    } else {
      newSnack = Snack(
          snackSize: randomSize,
          snackPosition: pos,
          groundMap: this,
          index: newIndex,
          snackType: SnackType.red);
    }
    snacks[newIndex] = newSnack;
    snackData[newIndex] = newSnack.position;
    add(newSnack);
    return newSnack;
  }

  Vector2 getRandomPositionInMap() {
    return Vector2(Random().nextDouble(), Random().nextDouble()) *
            mapSize.toDouble() -
        size / 2;
  }

  void setGamePause(bool isPaused) {
    if (isPaused) player.startCrawling();
  }

  void removeSnack(Snack snack) {
    snack.removeFromParent();
  }

  Future<void> _addEnemy(bool isHoldingWeapon) async {
    Vector2 randomPos = getRandomPositionInMap();
    while (randomPos.distanceTo(player.position) < 20) {
      randomPos = getRandomPositionInMap();
    }
    MeleeWeaponType? meleeWeaponToHoldd =
        isHoldingWeapon ? MeleeWeaponType.miniSword : null;
    Enemy enemy = Enemy(
        enemyData: EnemyData.createEnemeyData(),
        hidingWeaponToDropOf: meleeWeaponToHoldd,
        map: this,
        index: enemyIndexer);
    enemies[enemyIndexer] = enemy;
    enemies[enemyIndexer]!.transform.position = randomPos;
    hasEnemies = true;
    enemyIndexer++;
    add(enemy);
    await world.enemyIndicatorHUD.onAddEnemy(enemy);
    if (level >= 0) {
      enemy.createEnemyWeoapon();
    }
  }

  void _addHealthUp() {
    Vector2 randomPos = getRandomPositionInMap();
    while (randomPos.distanceTo(player.position) < 20) {
      randomPos = getRandomPositionInMap();
    }
    HealthUpItem healthUp =
        HealthUpItem(map: this, movingdata: MovingData.createItemMovingdata());
    healthUp.position = randomPos;
    add(healthUp);
    powerUps.add(healthUp);
  }

  Future<void> _addWeaponColletibleItem(Vector2? spawnPos) async {
    Vector2 posToSpawn = spawnPos ?? getRandomPositionInMap();
    while (posToSpawn.distanceTo(player.position) < 20) {
      posToSpawn = getRandomPositionInMap();
    }
    WeaponCollectItem weaponItem = WeaponCollectItem(
        map: this, movingdata: MovingData.createItemMovingdata());
    weaponItem.position = posToSpawn;
    await add(weaponItem);
  }

  void healthUp(HealthUpItem healthUp) {
    player.lives++;
    powerUps.remove(healthUp);
    //Add new one?
    _addHealthUp();
  }

  Future<void> levelUp() async {
    allEnemiesKilled = false;
    if (world.tutorialModeViewModel.isInTutorialMode) return;
    level++;
    currentLevel = LevelManager.getLevelData(level)!;
    if (level >= world.maxLevelValue.value) {
      world.onGameWon();
      return;
    }
    player.levelUp();
    //world.movingSpeedMultiplierValue.goUp();
    await fillWithEnemies(
        world.enemyCountViewModel.value - world.remainingEnemiesToLevelUp,
        currentLevel.hiddenMelee != null);
    world.caterpillarStatsViewModel.setLevelUp();
    obstacleSnapshot.onLevelUp(10);
  }

  void playerReachedFullLegnth(bool reachedFullLength) {
    playerReachedLength = reachedFullLength;
    if (playerReachedLength && allEnemiesKilled) {
      levelUp();
    }
  }

  void createNewWave(int count) {
    fillWithEnemies(currentLevel.enemyWave, false);
  }

  Future<void> killEnemy(Enemy enemy) async {
    player.onEnemyKilled();

    if (world.caterpillarStatsViewModel.points >=
        currentLevel.pointsToLevelUp) {
      levelUp();
    }
    world.enemyIndicatorHUD.onRemoveEnemy(enemy);
    if (enemy.hidingWeaponToDropOf != null) {
      _addWeaponColletibleItem(enemy.position);
    }
    enemies.remove(enemy.index);
    // if (player.lastSegment == null ||
    //     (player.lastSegment != null &&
    //         player.lastSegment!.index < world.maxCaterpillarLength.value)) {
    //   await _addEnemy(false);
    // }

    if (enemies.values.length <= world.remainingEnemiesToLevelUp) {
      allEnemiesKilled = true;
      createNewWave(currentLevel.enemyWave);
    }

    if (playerReachedLength && allEnemiesKilled) {
      levelUp();
      world.caterpillarStatsViewModel.setEnemiesInGame(enemies.values.length);
    }
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

  Future<void> _createMapContent() async {
    await fillWithSnacks(snackCount);
    await fillWithEnemies(currentLevel.enemyWave, true);
    await fillWithHealthUpItems(healthUpCount);
    // await _addWeaponColletibleItem(null);
    // await _addWeaponColletibleItem(null);

    await add(player);
    player.position = size / 2;

    obstacleSnapshot =
        ObstacleSnapshot(mapSize: mapSize.toDouble(), world: world);
    add(obstacleSnapshot);
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
    priority = 0;
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (player.caterpillarStatsViewModel.currentState !=
        CaterpillarState.chargingUp) {
      parallax?.baseVelocity = player.orientation * player.baseSpeed * dt;
    } else {
      parallax?.baseVelocity = Vector2.zero();
    }
  }
}
