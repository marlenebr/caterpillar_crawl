import 'dart:math';

import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/animation_data.dart';
import 'package:caterpillar_crawl/models/enemy_data.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';

class Enemy extends PositionComponent {
  EnemyData enemyData;
  late SpriteAnimation enemyAnimation;
  double secondCounter = 0;
  int moveToPosIndex = 0;
  double velocity = 1;
  late Vector2 initPos;

  static const double fullCircle = 2 * pi;
  double rotationSpeed = 4;

  Enemy({required this.enemyData});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = enemyData.idleAnimation.finalSize;

    anchor = Anchor.center;
    SpriteAnimationComponent animation =
        await CaterpillarCrawlUtils.createAnimationComponent(
            enemyData.idleAnimation);
    add(animation);
    // angleToLerpTo = angle;
    priority = 10000;
  }

  @override
  Future<void> onMount() async {
    super.onMount();
    initPos = position;
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateLerpToAngle(dt);
    velocity = dt * enemyData.movingspeed;

    Vector2 orientation = Vector2(1 * sin(angle), -1 * cos(angle)).normalized();
    position += orientation * velocity * 56.5;
    if (position
            .distanceTo(initPos + enemyData.moveToPositions[moveToPosIndex]) <
        0.5) {
      moveToPosIndex++;
      if (moveToPosIndex > enemyData.moveToPositions.length) {
        moveToPosIndex = 0;
      }
    }
  }

  void updateLerpToAngle(double dt) {
    double angleToLerpTo = CaterpillarCrawlUtils.getAngleFromUp(
        enemyData.moveToPositions[moveToPosIndex]);

    double diff = transform.angle - angleToLerpTo;
    if (diff.abs() < 0.1) {
      transform.angle = angleToLerpTo;
      return;
    }
    int direction = 1;
    if ((diff > 0 && diff < pi) || diff < -pi) {
      direction = -1;
    }

    double lerpSpeedDt = dt * rotationSpeed * direction * 0.5;
    transform.angle += lerpSpeedDt;

    //fix error from 0 to 360 degrees
    angle = angle % (fullCircle);
    if (angle < 0) {
      angle = fullCircle + (angle % (fullCircle));
    }

    // bool updateEnemydirection(double dt, double frameDuration) {

    //     secondCounter += dt;
    //     if (secondCounter >= frameDuration) {
    //       secondCounter = 0;
    //       .forEach((key, value) {
    //         if (key > 0) //0 is player
    //         enem{
    //           value.onMoveDirectionChange(player.position);
    //         }
    //       });
    //     }

    //   return false;
    // }
  }
}
