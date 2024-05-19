import 'package:caterpillar_crawl/components/moving_around_component.dart';
import 'package:caterpillar_crawl/models/data/enemy_data.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';

class Enemy extends MovingAroundComponent {
  EnemyData enemyData;
  int index;
  late SpriteAnimation _idleAnimation;
  late SpriteAnimation _deadAnimation;
  late SpriteAnimationGroupComponent _enemyAnimations;

  double _timeToDie = 0.8;
  bool respawnOnKill = true;

  int hitPoints = 5;

  EnemyStatus enemyStatus = EnemyStatus.alive;

  late int wayIndex;

  Enemy({
    required this.enemyData,
    required this.index,
    required super.map,
  }) : super(movingdata: enemyData.movingData);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    angle = CaterpillarCrawlUtils.getRandomAngle();
    size = enemyData.idleAnimation.finalSize;
    _idleAnimation = await CaterpillarCrawlUtils.createAnimation(
        animationData: enemyData.idleAnimation);
    _deadAnimation = await CaterpillarCrawlUtils.createAnimation(
        animationData: enemyData.deadAnimation!, loopAnimation: false);
    anchor = Anchor.center;
    _enemyAnimations = SpriteAnimationGroupComponent<EnemyStatus>(
        animations: {
          EnemyStatus.dead: _deadAnimation,
          EnemyStatus.alive: _idleAnimation,
        },
        scale: Vector2(size.x / enemyData.idleAnimation.spriteSize.x,
            size.y / enemyData.idleAnimation.spriteSize.y),
        current: enemyStatus);
    add(_enemyAnimations);
    priority = 10000;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (enemyStatus == EnemyStatus.dead) {
      updateDying(dt);
    } else {
      if (map.player.position.distanceTo(position) < map.player.size.x / 2) {
        map.player.hurt();
      }
    }
  }

  void onEnemyHit(int damage, bool respaOnOnKill) {
    if (enemyStatus == EnemyStatus.dead) {
      return;
    }
    hitPoints -= damage;
    if (hitPoints <= 0) {
      setEnemyState(EnemyStatus.dead);
      respawnOnKill = respaOnOnKill;
    }
  }

  void updateDying(double dt) {
    _timeToDie -= dt;
    if (_timeToDie < 0) {
      map.killEnemy(this, respawnOnKill);
      removeFromParent();
    }
  }

  void setEnemyState(EnemyStatus state) {
    if (enemyStatus == EnemyStatus.dead) {
      return;
    }
    if (state == EnemyStatus.dead) {
      disAllowMoving = true;
    }
    enemyStatus = state;
    _enemyAnimations.current = enemyStatus;
  }
}

enum EnemyStatus { dead, alive }
