import 'dart:math';

import 'package:caterpillar_crawl/components/groundMap.dart';
import 'package:caterpillar_crawl/models/enemy_data.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';

class Enemy extends PositionComponent {
  EnemyData enemyData;
  GroundMap map;
  late SpriteAnimation _idleAnimation;
  late SpriteAnimation _deadAnimation;
  late SpriteAnimationGroupComponent _enemyAnimations;

  double velocity = 1;
  late Vector2 _lastPointPos;
  late double _fractionAngle;
  late double _goToAngle;
  double _timeToDie = 3;

  int hitPoints = 5;

  EnemyMovementStatus enemyMovementStatus = EnemyMovementStatus.rotating;

  late int wayIndex;

  double rotationSpeed = 4;

  Enemy({required this.enemyData, required this.map});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = enemyData.idleAnimation.finalSize;
    _fractionAngle = (2 * pi) / enemyData.angleFractions.toDouble();
    _goToAngle = _fractionAngle;
    _idleAnimation = await CaterpillarCrawlUtils.createAnimation(
        animationData: enemyData.idleAnimation);
    _deadAnimation = await CaterpillarCrawlUtils.createAnimation(
        animationData: enemyData.deadAnimation!, loopAnimation: false);
    anchor = Anchor.center;
    // add(SpriteAnimationComponent(animation: eggAnimation));
    _enemyAnimations = SpriteAnimationGroupComponent<EnemyMovementStatus>(
        animations: {
          EnemyMovementStatus.movingForward: _idleAnimation,
          EnemyMovementStatus.rotating: _idleAnimation,
          EnemyMovementStatus.dead: _deadAnimation,
        },
        scale: Vector2(size.x / enemyData.idleAnimation.spriteSize.x,
            size.y / enemyData.idleAnimation.spriteSize.y),
        // anchor: Anchor.center,
        current: enemyMovementStatus);
    add(_enemyAnimations);
    // angleToLerpTo = angle;
    priority = 10000;
  }

  @override
  Future<void> onMount() async {
    super.onMount();
    Vector2.copy(position);
    _lastPointPos = Vector2(position.x, position.y);
  }

  @override
  void update(double dt) {
    super.update(dt);
    switch (enemyMovementStatus) {
      case EnemyMovementStatus.rotating:
        bool hasReachedAngle = CaterpillarCrawlUtils.updateLerpToAngle(
            dt, transform, _goToAngle, 2);
        if (hasReachedAngle) {
          enemyMovementStatus = EnemyMovementStatus.movingForward;
        }
      case EnemyMovementStatus.movingForward:
        CaterpillarCrawlUtils.updatePosition(dt, transform, 40, angle);
        if (position.distanceTo(_lastPointPos) >= enemyData.wayDistance) {
          _lastPointPos = Vector2(position.x, position.y);
          if (enemyData.moveCircle) {
            _goToAngle = (_goToAngle + _fractionAngle) % (2 * pi);
          } else {
            _goToAngle = _goToAngle == _fractionAngle
                ? 2 * pi - _fractionAngle
                : _fractionAngle;
          }
        }
        enemyMovementStatus = EnemyMovementStatus.rotating;
      case EnemyMovementStatus.dead:
        updateDying(dt);
      case EnemyMovementStatus.moveToCaterpillar:
        Vector2 lookTo = map.player.position - position;
        double lookAngle = CaterpillarCrawlUtils.getAngleFromUp(-lookTo);
        CaterpillarCrawlUtils.updateLerpToAngle(
            dt, transform, lookAngle, rotationSpeed);
        CaterpillarCrawlUtils.updatePosition(dt, transform, 40, angle);
    }
  }

  void onEnemyHit(int damage) {
    hitPoints -= damage;
    if (hitPoints <= 0) {
      setCurrentEggState(EnemyMovementStatus.dead);
    }
  }

  void updateDying(double dt) {
    _timeToDie -= dt;
    if (_timeToDie < 0) {
      removeFromParent();
      map.player.onEnemyKilled();
    }
  }

  void setCurrentEggState(EnemyMovementStatus enemyState) {
    enemyMovementStatus = enemyState;
    _enemyAnimations.current = enemyMovementStatus;
  }

  void followCaterpillar(Vector2 headPos) {
    setEnemyState(EnemyMovementStatus.moveToCaterpillar);
  }

  void disfollowCaterpillar() {
    setEnemyState(EnemyMovementStatus.rotating);
  }

  void setEnemyState(EnemyMovementStatus state) {
    if (enemyMovementStatus == EnemyMovementStatus.dead) {
      return;
    }
    enemyMovementStatus = state;
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

enum EnemyMovementStatus { rotating, movingForward, dead, moveToCaterpillar }
