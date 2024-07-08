import 'dart:math';

import 'package:caterpillar_crawl/components/obstacle.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/data/obstacle_data.dart';
import 'package:flame/components.dart';

class ObstacleSnapshot extends PositionComponent with Snapshot {
  double mapSize;
  CaterpillarCrawlMain world;

  Map<int, Obstacle> obstacles = {};
  List<Obstacle> temporaryObstacles = [];
  List<BombObstacle> eggSplashes = [];

  ObstacleSnapshot({required this.mapSize, required this.world});

  @override
  Future<void> onLoad() async {
    priority = 3;
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateRenderSnapshot();
  }

  Obstacle addObstacle<T extends Obstacle>(
    Vector2 position,
    double angle,
    int? index,
    ObstacleType obstacleType,
  ) {
    int newIndex = 0;
    if (index == null) {
      newIndex = obstacles.length;
    } else {
      newIndex = index;
    }

    Obstacle? obstacle;
    if (obstacleType == ObstacleType.ultiSegment) {
      ThrowableObstacleData throwableObstacleData =
          ThrowableObstacleData.createUltiSegmentObstacle();
      obstacle = ThrowableObstacle(
          throwableObstacleData: throwableObstacleData,
          flyTime: world.timeToUlti,
          caterpillarWorld: world,
          index: newIndex,
          obstacleData: throwableObstacleData.obstacleData);
    } else if (obstacleType == ObstacleType.bomb) {
      obstacle = BombObstacle(
          caterpillarWorld: world,
          index: newIndex,
          obstacleData: ObstacleData.createBombObstacle());
      eggSplashes.add(obstacle as BombObstacle);
    } else if (obstacleType == ObstacleType.deadSegment) {
      ThrowableObstacleData throwableObstacleData =
          ThrowableObstacleData.createDeadSegmentObstacle();
      obstacle = ThrowableObstacle(
          throwableObstacleData: throwableObstacleData,
          flyTime: world.timeToUlti,
          caterpillarWorld: world,
          index: newIndex,
          obstacleData: throwableObstacleData.obstacleData);
      temporaryObstacles.add(obstacle);
    }
    obstacle!.position = position;
    obstacle.angle = angle;
    obstacles[newIndex] = obstacle;
    add(obstacle);

    return obstacle;
  }

  void addObstacleAndRenderSnapshot<T extends Obstacle>(Vector2 position,
      Vector2 size, double angle, bool isDead, ObstacleType type) {
    addObstacle<T>(position, angle, null, type);
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

  void onLevelUp(int percentageToRemoveSplashes) {
    removeEggSplashesPercentual(percentageToRemoveSplashes);
    removeTemporaryObstacles();
    renderSnapshotOnNextFrame();
  }

  void removeEggSplashesPercentual(int percantage) {
    List<BombObstacle> temp = List<BombObstacle>.from(eggSplashes);
    for (BombObstacle eggSplash in temp) {
      double randomVal = Random().nextDouble();
      if (randomVal <= percantage / 100) {
        //Remove
        eggSplashes.remove(eggSplash);
        eggSplash.removeFromParent();
      }
    }
    temp.clear();
  }

  void removeTemporaryObstacles() {
    for (int i = 0; i < temporaryObstacles.length; i++) {
      obstacles.remove(temporaryObstacles[i].index);
      temporaryObstacles[i].removeFromParent();
    }
    temporaryObstacles = [];
  }
}

enum ObstacleType {
  deadSegment,
  ultiSegment,
  bomb,
}
