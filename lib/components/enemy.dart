import 'dart:math';

import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/animation_data.dart';
import 'package:caterpillar_crawl/models/enemy_data.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';

class Enemy extends PositionComponent {
  EnemyData enemyData;
  late SpriteAnimation enemyAnimation;
  double velocity = 1;
  late Vector2 _lastPointPos;
  late int angleIndex = 0;

  EnemyMovementStatus _enemyMovementStatus = EnemyMovementStatus.rotating;

  late int wayIndex;

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
    //animation.anchor = Anchor.center;
    add(animation);
    // angleToLerpTo = angle;
    priority = 10000;
  }

  @override
  Future<void> onMount() async {
    super.onMount();
    Vector2.copy(position);
    _lastPointPos = Vector2(position.x,position.y);
  }

  @override
  void update(double dt) {
    super.update(dt);
    switch (_enemyMovementStatus) {
      case EnemyMovementStatus.rotating:
        bool hasReachedAngle = CaterpillarCrawlUtils.updateLerpToAngle(
            dt, transform, enemyData.angleList[angleIndex], 2);
        if (hasReachedAngle) {
          _enemyMovementStatus = EnemyMovementStatus.movingForward;
        }
      case EnemyMovementStatus.movingForward:
        velocity = dt * enemyData.movingspeed;
        Vector2 orientation =
            Vector2(1 * sin(angle), -1 * cos(angle)).normalized();
        position += orientation * velocity * 56.5;
        if(position.distanceTo(_lastPointPos) >= enemyData.wayDistance)
        {
          _lastPointPos = Vector2(position.x,position.y);
          angleIndex++;
          if(angleIndex>enemyData.angleList.length-1)
          {
            angleIndex = 0;
          }
          print(angleIndex);
          _enemyMovementStatus = EnemyMovementStatus.rotating;
        }
    }

    // TODO: Handle this case.
    /*  if (position
            .distanceTo(initPos + enemyData.moveToPositions[moveToPosIndex]) <
        0.5) {
      moveToPosIndex++;
      if (moveToPosIndex > enemyData.moveToPositions.length) {
        moveToPosIndex = 0;
      }
    } */
  }
}

enum EnemyMovementStatus {
  rotating,
  movingForward,
}
