import 'package:caterpillar_crawl/components/enemy/enemy.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/data/obstacle_data.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';

class Obstacle extends PositionComponent {
  ObstacleData obstacleData;

  int index;

  CaterpillarCrawlMain caterpillarWorld;
  Vector2 playerPosition = Vector2.zero();

  bool isDamaging = true;
  late SpriteComponent _spriteComponent;

  Obstacle({
    required this.caterpillarWorld,
    required this.obstacleData,
    required this.index,
  }) {
    playerPosition = caterpillarWorld.groundMap.player.transform.position;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2.all(obstacleData.size);
    Sprite sprite = await Sprite.load(obstacleData.pathToDefaultSprite);
    _spriteComponent =
        SpriteComponent(size: Vector2.all(obstacleData.size), sprite: sprite);
    anchor = Anchor.center;
    add(_spriteComponent);
    priority = 1001;
  }

  @override
  void update(double dt) {
    if (!isDamaging) {
      return;
    }
    if (!calculateOnTick()) {
      return;
    }
    switch (obstacleData.damageTowards) {
      case DamageTowards.damageToEnemy:
        _updateHurtEnemies();
      case DamageTowards.damageToPlayer:
        _updateHurtPlayer();
      case DamageTowards.all:
        _updateHurtEnemies();
        _updateHurtPlayer();
    }
  }

  bool calculateOnTick() {
    return (caterpillarWorld.frameTicks + index) %
                obstacleData.calculateOnFrame ==
            0
        ? true
        : false;
  }

  void _updateHurtEnemies() {
    for (Enemy enemy in caterpillarWorld.groundMap.enemies.values) {
      if (enemy.position.distanceTo(position) < size.x / 2) {
        enemy.onEnemyHit(5, false);
      }
    }
  }

  void _updateHurtPlayer() {
    if (position.distanceTo(playerPosition) < size.x / 2) {
      caterpillarWorld.groundMap.player.hurt();
    }
  }
}

class ThrowableObstacle extends Obstacle {
  final ThrowableObstacleData throwableObstacleData;

  late SpriteComponent _spriteAfterTransformation;
  late SpriteAnimationComponent _spriteTranformingAnimation;
  double flyTime;

  ThrowableObstacleState state = ThrowableObstacleState.flying;

  ThrowableObstacle({
    required this.throwableObstacleData,
    required super.caterpillarWorld,
    required super.index,
    required this.flyTime,
    required super.obstacleData,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();
    Sprite sprite = await Sprite.load(
        throwableObstacleData.transformingAnimation.imagePath);
    _spriteAfterTransformation = SpriteComponent(
        size: Vector2.all(throwableObstacleData.obstacleData.size),
        sprite: sprite);
    SpriteAnimation transformAnimation =
        await CaterpillarCrawlUtils.createAnimation(
            animationData: throwableObstacleData.transformingAnimation,
            loopAnimation: false);
    _spriteTranformingAnimation = SpriteAnimationComponent(
        animation: transformAnimation,
        size: throwableObstacleData.transformingAnimation.finalSize);
  }

  @override
  void update(double dt) {
    super.update(dt);
    switch (state) {
      case ThrowableObstacleState.flying:
        CaterpillarCrawlUtils.updatePosition(
            dt, transform, -throwableObstacleData.throwSpeed * flyTime, angle);
        flyTime -= dt;
        if (flyTime < 0) {
          isDamaging = true;
          remove(_spriteComponent);
          add(_spriteTranformingAnimation);
          state = ThrowableObstacleState.transforming;
        }
      case ThrowableObstacleState.transforming:
        if (_spriteTranformingAnimation.playing &&
            _spriteTranformingAnimation.isLoaded) {
          return;
        } else {
          remove(_spriteTranformingAnimation);
          add(_spriteAfterTransformation);
          state = ThrowableObstacleState.landed;
        }
      case ThrowableObstacleState.landed:
    }
  }
}

class BombObstacle extends Obstacle {
  BombObstacle({
    required super.caterpillarWorld,
    required super.index,
    required super.obstacleData,
  });
}

enum DamageTowards {
  damageToEnemy,
  damageToPlayer,
  all,
}

enum ThrowableObstacleState { flying, transforming, landed }
