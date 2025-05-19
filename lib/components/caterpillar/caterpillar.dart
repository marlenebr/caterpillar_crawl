import 'package:caterpillar_crawl/components/caterpillar/caterpillarSegment.dart';
import 'package:caterpillar_crawl/components/caterpillar/caterpillar_base.dart';
import 'package:caterpillar_crawl/components/particles/magic_around_particles.dart';
import 'package:caterpillar_crawl/components/snack.dart';
import 'package:caterpillar_crawl/components/tutorial_builder.dart';
import 'package:caterpillar_crawl/components/weapons/distance/multi_distance_wepaon.dart';
import 'package:caterpillar_crawl/components/weapons/melee/base_melee_weapon.dart';
import 'package:caterpillar_crawl/components/weapons/melee/mini_sword.dart';
import 'package:caterpillar_crawl/models/data/weapon_data.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';

class CaterPillar extends CaterpillarBase {
  BaseMeleeWeapon? baseMeleeWeapon;
  MultiDistanceWeapon? baseDistanceWeapon;

  double ultiTimer = 0;

  late MagicAroundParticles magicAround;

  int fixIterationPerFrame =
      1; //how much need to be fixed - the higher the more
  double tolerance = 3; //how tolerant should be segment distance differnces?

  // CaterpillarState currentState = CaterpillarState.crawling;

  CaterPillar(super.caterpillardata, super.gameWorld,
      {required super.rotationSpeed,
      required super.playerController,
      required super.caterpillarStateViewModel,
      required super.caterpillarStatsViewModel}) {
    lives = gameWorld.playerLifeCount;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await createMultiWeapon();
    magicAround = MagicAroundParticles(
      parentPosComp: this,
      particlePerTick: 3,
      timeForTick: 0.3,
      world: gameWorld,
    );
    await gameWorld.groundMap.add(magicAround);
    priority = 950;
    magicAround.priority = 1000;
  }

  @override
  void onMount() {
    super.onMount();
    position = Vector2.zero();
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateCoolDownDead(dt);
    timeSinceLastEnemyKilled += dt;
  }

  @override
  void addSegment(SnackType snackType) {
    if (nextSegment == null) {
      baseDistanceWeapon?.setWeapon(snackType);
    }
    super.addSegment(snackType);
  }

  @override
  void removeSegment(CaterpillarSegment segment) {
    super.removeSegment(segment);
    if (segment.nextSegment == null) {
      baseDistanceWeapon?.setWeapon(null);
    }
  }

  Future<void> createMultiWeapon() async {
    baseDistanceWeapon = MultiDistanceWeapon(
        allDistanceWeaponData: DistanceWeaponData.createMultiWeaponData01(),
        map: gameWorld.groundMap);
    //Fix DEBUG

    await add(baseDistanceWeapon!);
    baseDistanceWeapon!.position = Vector2(position.x + size.x / 2, position.y);
  }

  bool isInUlti = false;

  void levelUp() {
    removeAllSegments();
  }

  void updateUlti(double dt) {
    if (isInUlti) {
      ultiTimer += dt;
      if (ultiTimer > gameWorld.timeToUlti + 1) {
        isInUlti = false;
        gameWorld.groundMap.obstacleSnapshot.renderSnapshotOnNextFrame();
        ultiTimer = 0;
      }
    }
  }

  void removeAllSegments() {
    // setCaterpillarState(CaterpillarState.idle);
    if (lastSegment != null) {
      lastSegment!.removeOnNextFrame = true;
    }
    nextSegment?.fallOff();
    onAllSegmentsRemoved();
  }

  void onAllSegmentsRemoved() {
    setSegmentCount();
    lastSegment = null;
    nextSegment = null;
  }

  void updateCoolDownDead(double dt) {
    if (caterpillarStatsViewModel.isHurt) {
      dieCoolDownTimer += dt;
      if (dieCoolDownTimer > dieCoolDownTime) {
        dieCoolDownTimer = 0;
        caterpillarStatsViewModel.setIsHurt(false);
      }
    }
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    //position = gameSize / 2;
  }

  void onMoveDirectionChange(Vector2 pointToMoveTo) {
    angleToLerpTo = CaterpillarCrawlUtils.getAngleFromUp(pointToMoveTo);
  }

  void toggleUseEgg() {
    if (caterpillarStatsViewModel.currentState == CaterpillarState.chargingUp) {
      startCrawling();
      return;
    }
    angleToLerpTo = angle;
    //After Button click eg.
    if (caterpillarStatsViewModel.currentState == CaterpillarState.crawling) {
      if (caterpillarStatsViewModel.segmentCount < segmentToRemoveBeforeEgg) {
        return;
      }
      setCaterpillarState(CaterpillarState.chargingUp);
    } else if (caterpillarStatsViewModel.currentState ==
        CaterpillarState.idle) {
      startCrawling();
      ShootEgg();
    }

    if (nextSegment == null) {
      baseDistanceWeapon?.setWeapon(null);
      startCrawling();
      return;
    }
  }

  Future<void> ShootEgg() async {
    baseDistanceWeapon?.shoot();
    if (nextSegment != null) {
      baseDistanceWeapon?.setWeapon(nextSegment!.snackType);
    } else {
      baseDistanceWeapon?.setWeapon(null);
    }
  }

  void onPewPew() {
    baseMeleeWeapon?.startAttacking();
    gameWorld.tutorialBuilder
        .onConditionReached(TutorialConditions.useMelee, null);
  }

  Future<void> addMeleeWeapon() async {
    baseMeleeWeapon = MiniSword(
        weaponData: MeleeWeaponData.createSwordData(),
        map: gameWorld.groundMap);
    await add(baseMeleeWeapon!);
    baseMeleeWeapon!.position = Vector2(size.x / 2, 30);
  }

  void removeMeleeWeapon() {
    baseMeleeWeapon?.removeFromParent();
    baseMeleeWeapon = null;
  }

  void onEnemyKilled() {
    caterpillarStatsViewModel.onEnemyKilled(getTimeBonus());
    gameWorld.tutorialBuilder
        .onConditionReached(TutorialConditions.killEnemy, null);
    print("LASTENEMY: $timeSinceLastEnemyKilled");
    timeSinceLastEnemyKilled = 0;
  }

  int getTimeBonus() {
    if (timeSinceLastEnemyKilled < 1.0) {
      return 20;
    } else if (timeSinceLastEnemyKilled < 3.0) {
      return 10;
    } else if (timeSinceLastEnemyKilled < 5.0) {
      return 5;
    } else if (timeSinceLastEnemyKilled <= 10.0) {
      return 2;
    }
    return 1;
  }

  void removeCompletly() {
    super.reset();
    removeFromParent();
  }
}
