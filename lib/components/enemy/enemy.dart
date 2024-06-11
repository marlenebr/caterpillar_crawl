import 'dart:math';

import 'package:caterpillar_crawl/components/damage_indicator.dart';
import 'package:caterpillar_crawl/components/moving_around_component.dart';
import 'package:caterpillar_crawl/components/particles/splash_out_particles.dart';
import 'package:caterpillar_crawl/components/weapons/base_weapon.dart';
import 'package:caterpillar_crawl/components/weapons/distance/dung_ball.dart';
import 'package:caterpillar_crawl/models/data/enemy_data.dart';
import 'package:caterpillar_crawl/models/data/weapon_data.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';

class Enemy extends MovingAroundComponent {
  EnemyData enemyData;
  int index;
  late SpriteAnimation _idleAnimation;
  late SpriteAnimation _deadAnimation;
  late SpriteAnimationGroupComponent _enemyAnimations;

  BaseWeapon? enemyWeapon;

  double _timeToDie = 0.8;
  double _timeToCooldown;

  double shootIntervall = 4;
  double _shootIntervallTimer = 0;

  int hitPoints = 5;
  bool _isInCoolDown = false;
  double _distToShowDamage = 0;

  bool hasWeapon = false;

  EnemyStatus enemyStatus = EnemyStatus.alive;

  late DamageIndicator _damageIndicator;

  late int wayIndex;

  Enemy({
    required this.enemyData,
    required this.index,
    required super.map,
  })  : _timeToCooldown = enemyData.hitCooldownTime,
        super(movingdata: enemyData.movingData);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _distToShowDamage = movingdata.distToFollowPlayer * 1.5;
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
    await add(_enemyAnimations);
    _damageIndicator =
        DamageIndicator(maxHealthValue: hitPoints, parentToTakeDamage: this);
    await add(_damageIndicator);
    priority = 1000;
    _damageIndicator.priority = 1001;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (enemyStatus == EnemyStatus.dead) {
      updateDying(dt);
    } else {
      updateHitCooldown(dt);
      updateKickDungBall(dt);
      if (map.player.position.distanceTo(position) < map.player.size.x / 2) {
        map.player.hurt();
        return;
      } else if (map.player.position.distanceTo(position) <
          movingdata.distToFollowPlayer) {
        moveToPlayer = true;
        return;
      } else if (map.player.position.distanceTo(position) < _distToShowDamage) {
        moveToPlayer = false;
        _damageIndicator.show();
      } else {
        _damageIndicator.hide();
      }
    }
  }

  void updateHitCooldown(double dt) {
    if (!_isInCoolDown) {
      return;
    }
    _timeToCooldown -= dt;
    if (_timeToCooldown < 0) {
      _timeToCooldown = enemyData.hitCooldownTime;
      _isInCoolDown = false;
    }
  }

  void onEnemyHit(int damage, bool respaOnOnKill) {
    if (enemyStatus == EnemyStatus.dead) {
      return;
    }
    if (_isInCoolDown) {
      return;
    }
    hitPoints -= damage;
    SplashOutParticles hitSplash = SplashOutParticles();
    add(hitSplash);
    hitSplash.position = Vector2(size.x / 2, size.y / 2);

    if (hitPoints <= 0) {
      hitPoints = 0;
      setEnemyState(EnemyStatus.dead);
    } else {
      _isInCoolDown = true;
    }
    _damageIndicator.setHealth(hitPoints);
  }

  void updateDying(double dt) {
    _timeToDie -= dt;
    if (_timeToDie < 0) {
      map.killEnemy(this);
      removeFromParent();
    }
  }

  void updateKickDungBall(double dt) {
    if (hasWeapon) {
      _shootIntervallTimer += dt;
      if (_shootIntervallTimer >= shootIntervall) {
        shootIntervall = 4;
        enemyWeapon!.startAttacking();
        _shootIntervallTimer = 0;
      }
    }
  }

  void createEnemyWeoapon() {
    enemyWeapon = DungBallShooter(
        weaponData: DistanceWeaponData.createDungBall(), map: map);
    add(enemyWeapon!);
    enemyWeapon!.position = Vector2(size.x / 2, size.y / 4);
    enemyWeapon!.weaponHolder = WeaponHolder.enemy;
    shootIntervall = Random().nextDouble() * shootIntervall;
    hasWeapon = true;
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
