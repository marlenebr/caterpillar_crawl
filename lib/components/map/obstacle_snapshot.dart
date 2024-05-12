import 'package:caterpillar_crawl/components/obstacle.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:flame/components.dart';

class ObstacleSnapshot extends PositionComponent with Snapshot {
  double mapSize;
  CaterpillarCrawlMain world;

  Map<int, Obstacle> obstacles = {};
  List<Obstacle> temporaryObstacles = [];

  ObstacleSnapshot({required this.mapSize, required this.world});

  @override
  Future<void> onLoad() async {
    priority = 2;
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateRenderSnapshot();
  }

  Obstacle addObstacle<T extends Obstacle>(
    Vector2 position,
    Vector2 size,
    double angle,
    int? index,
  ) {
    int newIndex = 0;
    if (index == null) {
      newIndex = obstacles.length;
    } else {
      newIndex = index;
    }

    Obstacle? obstacle;
    if (T == UltiObstacle) {
      obstacle = UltiObstacle(
          flyTime: world.timeToUlti,
          caterpillarWorld: world,
          index: newIndex,
          obstacleSize: size);
    } else if (T == BombObstacle) {
      obstacle = BombObstacle(
          caterpillarWorld: world, index: newIndex, obstacleSize: size);
    } else if (T == PlayerHurtObstacle) {
      obstacle = PlayerHurtObstacle(
          caterpillarWorld: world, index: newIndex, obstacleSize: size);
      temporaryObstacles.add(obstacle);
    }
    obstacle!.position = position;
    obstacle.angle = angle;
    obstacles[newIndex] = obstacle;
    add(obstacle);

    return obstacle;
  }

  void addObstacleAndRenderSnapshot<T extends Obstacle>(
      Vector2 position, Vector2 size, double angle, bool isDead) {
    addObstacle<T>(position, size, angle, null);
    renderSnapshotOnNextFrame();
  }

  void renderSnapshotOnNextFrame() {
    renderSnapshot = true;
  }

  void updateRenderSnapshot() {
    if (renderSnapshot) {
      takeSnapshot();
      renderSnapshot = false;
    }
  }

  void removeTemporaryObstacles() {
    for (int i = 0; i < temporaryObstacles.length; i++) {
      obstacles.remove(temporaryObstacles[i].index);
      temporaryObstacles[i].removeFromParent();
    }
    temporaryObstacles = [];
    renderSnapshotOnNextFrame();
  }
}
