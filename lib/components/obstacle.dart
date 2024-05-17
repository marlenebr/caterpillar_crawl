import 'package:caterpillar_crawl/components/enemy.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';

class Obstacle extends PositionComponent {
  late SpriteComponent _spriteComponent;
  String spritePath;
  Vector2 obstacleSize;
  int devideCalculations = 3;

  int index;

  CaterpillarCrawlMain caterpillarWorld;
  Vector2 playerPosition = Vector2.zero();

  Obstacle({
    required this.caterpillarWorld,
    required this.spritePath,
    required this.obstacleSize,
    required this.index,
  }) {
    playerPosition = caterpillarWorld.groundMap.player.transform.position;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(obstacleSize.x, obstacleSize.y);
    Sprite sprite = await Sprite.load(spritePath);
    _spriteComponent = SpriteComponent(size: size, sprite: sprite);
    anchor = Anchor.center;
    add(_spriteComponent);
    priority = 1001;
  }

  @override
  void update(double dt) {}

  bool calculateOnTick() {
    return (caterpillarWorld.frameTicks + index) % devideCalculations == 0
        ? true
        : false;
  }

  void updateHurtEnemies() {
    for (Enemy enemy in caterpillarWorld.groundMap.enemies.values) {
      if (enemy.position.distanceTo(position) < size.x / 2) {
        enemy.onEnemyHit(5, false);
      }
    }
  }

  void updateHurtPlayer() {
    if (position.distanceTo(playerPosition) < size.x / 2) {
      caterpillarWorld.groundMap.player.hurt();
    }
  }
}

class BombObstacle extends Obstacle {
  BombObstacle(
      {required super.caterpillarWorld,
      required super.obstacleSize,
      super.spritePath = "bombobstacle.png",
      required super.index});

  @override
  void update(double dt) {
    if (calculateOnTick()) {
      updateHurtPlayer();
      updateHurtEnemies();
    }
  }
}

class UltiObstacle extends Obstacle {
  bool stoppedMoving = false;
  double shootingSpeed = 10;
  double flyTime;

  UltiObstacle(
      {required this.flyTime,
      required super.caterpillarWorld,
      super.spritePath = "",
      required super.obstacleSize,
      required super.index}) {
    spritePath = "segment_single_color${getSpriteIndex()}.png";
  }

  String getSpriteIndex() {
    return "0${(index % 3) + 1}";
  }

  @override
  void update(double dt) {
    if (!stoppedMoving) {
      CaterpillarCrawlUtils.updatePosition(
          dt, transform, shootingSpeed * flyTime, angle);
      flyTime -= dt;
      if (flyTime < 0) {
        stoppedMoving = true;
        return;
      }
    }
    if (calculateOnTick()) {
      updateHurtEnemies();
    }
  }
}

class PlayerHurtObstacle extends Obstacle {
  PlayerHurtObstacle(
      {required super.caterpillarWorld,
      super.spritePath = "segment_single_dead_128.png",
      required super.obstacleSize,
      required super.index});

  @override
  void update(double dt) {
    if (calculateOnTick()) {
      updateHurtPlayer();
    }
  }
}
