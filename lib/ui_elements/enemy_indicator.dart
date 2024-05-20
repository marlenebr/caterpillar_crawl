import 'dart:async';

import 'package:caterpillar_crawl/components/enemy/enemy.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:flame/components.dart';

class EnemyIndicatorHUD extends PositionComponent with HasVisibility {
  CaterpillarCrawlMain world;

  Map<int, EnemyIndicator> enemyIndicators = {};

  EnemyIndicatorHUD({required this.world});

  String spritePath = "enemy_icon.png";
  double iconSize = 16;

  late SpriteComponent spriteComponent;

  @override
  Future<void> onLoad() async {
    super.priority = double.maxFinite.toInt();
    super.onLoad();
  }

  Future<void> onAddEnemy(Enemy enemy) async {
    await createAndAddIndicator(enemy);
    checkIndicator();
  }

  void onRemoveEnemy(Enemy enemy) {
    enemyIndicators[enemy.index]!.removeFromParent();
    enemyIndicators.remove(enemy.index);
    checkIndicator();
  }

  void checkIndicator() {
    if (world.groundMap.enemies.values.length <= world.enemyCountOnIndicator) {
      isVisible = true;
    } else if (world.groundMap.enemies.values.length >
        world.enemyCountOnIndicator) {
      isVisible = false;
    }
  }

  Future<void> createAndAddIndicator(Enemy enemy) async {
    EnemyIndicator indicator = EnemyIndicator(
        world: world,
        playerPosition: world.groundMap.player.position,
        enemy: enemy,
        spritePath: spritePath,
        iconSize: iconSize);
    await add(indicator);
    enemyIndicators[enemy.index] = indicator;
  }

  void reset() {
    for (EnemyIndicator indicator in enemyIndicators.values) {
      indicator.removeFromParent();
    }
    enemyIndicators.clear();
  }

  // void disableAllEnemyIndicators() {
  //   for (EnemyIndicator indicator in enemyIndicators.values) {
  //     indicator.isActive = false;
  //     print("INDICATOR disable ${indicator.enemy.index}");
  //   }
  // }

  // void enableAllEnemyIndicators() {
  //   for (EnemyIndicator indicator in enemyIndicators.values) {
  //     indicator.isActive = true;
  //     print("INDICATOR enable ${indicator.enemy.index}");
  //   }
  // }
}

class EnemyIndicator extends PositionComponent with HasVisibility {
  String spritePath;
  Vector2 playerPosition;
  Enemy enemy;

  CaterpillarCrawlMain world;

  double iconSize;

  double halfWidth;
  double halfHeight;

  EnemyIndicator(
      {required this.world,
      required this.playerPosition,
      required this.enemy,
      required this.spritePath,
      required this.iconSize})
      : halfWidth = world.size.x / 2,
        halfHeight = world.size.y / 2;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    priority = 20000;
    anchor = Anchor.center;
    Sprite sprite = await Sprite.load(spritePath);
    SpriteComponent spriteComponent =
        SpriteComponent(size: Vector2.all(iconSize), sprite: sprite);
    await add(spriteComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateIndicator();
  }

  void updateIndicator() {
    bool needsXIndicator = true;
    bool needsYIndicator = true;

    Vector2 hudWorldPos =
        Vector2(playerPosition.x - halfWidth, playerPosition.y - halfHeight);

    double xPos = enemy.position.x - hudWorldPos.x;
    double yPos = enemy.position.y - hudWorldPos.y;

    if (playerPosition.x + halfWidth < enemy.position.x) //
    {
      //on the right side - out of view
      xPos = world.size.x - iconSize;
    } else if (playerPosition.x - halfWidth > enemy.position.x) {
      //on the left side - out of view
      xPos = 0;
    } else {
      needsXIndicator = false;
    }

    if (playerPosition.y + halfHeight < enemy.position.y) //
    {
      //on the botton side - out of view
      yPos = world.size.y - iconSize;
    } else if (playerPosition.y - halfHeight > enemy.position.y) {
      //on the top side - out of view
      yPos = 0;
    } else {
      needsYIndicator = false;
    }
    if (!needsYIndicator && !needsXIndicator) {
      isVisible = false;
    } else {
      isVisible = true;
    }
    position = Vector2(xPos, yPos);
  }
}
