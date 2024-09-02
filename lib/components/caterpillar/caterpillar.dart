import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillar/caterpillarSegment.dart';
import 'package:caterpillar_crawl/components/particles/magic_around_particles.dart';
import 'package:caterpillar_crawl/components/player_controller.dart';
import 'package:caterpillar_crawl/components/tutorial_builder.dart';
import 'package:caterpillar_crawl/components/weapons/distance/base_distance_weapon.dart';
import 'package:caterpillar_crawl/components/weapons/distance/eggy_bomb.dart';
import 'package:caterpillar_crawl/components/weapons/egg.dart';
import 'package:caterpillar_crawl/components/weapons/melee/base_melee_weapon.dart';
import 'package:caterpillar_crawl/components/weapons/melee/mini_sword.dart';
import 'package:caterpillar_crawl/models/data/animation_data.dart';
import 'package:caterpillar_crawl/models/data/caterpillar_data.dart';
import 'package:caterpillar_crawl/models/data/egg_data.dart';
import 'package:caterpillar_crawl/models/data/weapon_data.dart';
import 'package:caterpillar_crawl/models/view_models/caterpillar_state_view_model.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';

import 'caterpillarElement.dart';

enum CaterpillarState { crawling, onHoldForEgg, readyForUlti, idle }

class CaterPillar extends CaterpillarElement {
  CaterpillarStateViewModel caterpillarStateViewModel;
  CaterpillarStatsViewModel caterpillarStatsViewModel;

  BaseMeleeWeapon? baseMeleeWeapon;
  BaseDistanceWeapon? baseDistanceWeapon;

  // bool isRemovingSegment = false;
  // bool isHurt = false;

  // bool readyToEgg = false;
  int segmentToRemoveBeforeEgg = 1;
  int segmentToEggCounter = 0; //How many segments should me removed untill egg

  double ultiTimer = 0;

  static const double fullCircle = 2 * pi;

  double rotationSpeed;
  double baseSpeed;

  double dieCoolDownTime = 1.2;
  double dieCoolDownTimer = 0;
  double timeSinceLastEnemyKilled = 0;

  late double angleToLerpTo;
  late double scaledAnchorYPos;
  late MagicAroundParticles magicAround;

  PlayerController playerController;

  CaterpillarSegment? lastSegment;
  late int entriesNeeded;
  int fixIterationPerFrame =
      1; //how much need to be fixed - the higher the more
  double tolerance = 3; //how tolerant should be segment distance differnces?

  int _lives = 0;
  int get lives {
    return _lives;
  }

  set lives(int value) {
    _lives = value;
    if (value <= 0) {
      _lives = 0;
    }
    if (value > gameWorld.playerLifeCount) {
      _lives = gameWorld.playerLifeCount;
    }
    gameWorld.onLifeCountChanged(_lives);
  }

  late SpriteAnimationGroupComponent<CaterpillarState> caterPillarAnimations;

  late SpriteAnimation headAnimation;
  late SpriteAnimation wobbleAnimation;

  // CaterpillarState currentState = CaterpillarState.crawling;

  CaterPillar(super.caterpillardata, super.gameWorld,
      {required this.rotationSpeed,
      required this.playerController,
      required this.caterpillarStateViewModel,
      required this.caterpillarStatsViewModel})
      : baseSpeed = caterpillardata.movingspeed {
    lives = gameWorld.playerLifeCount;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    entriesNeeded = calcSteptToReachDistance();
    size = caterpillardata.idleAnimation.finalSize;
    finalSize = caterpillardata.idleAnimation.finalSize;
    headAnimation = await CaterpillarCrawlUtils.createAnimation(
        animationData: caterpillardata.idleAnimation);
    wobbleAnimation = await CaterpillarCrawlUtils.createAnimation(
        animationData: caterpillardata.wobbleAnimation!);

    caterPillarAnimations = SpriteAnimationGroupComponent<CaterpillarState>(
        animations: {
          CaterpillarState.crawling: headAnimation,
          CaterpillarState.onHoldForEgg: wobbleAnimation,
          CaterpillarState.idle: headAnimation,
          //TODO: ReadyForUlti
        },
        scale: Vector2(finalSize.x / caterpillardata.idleAnimation.spriteSize.x,
            finalSize.y / caterpillardata.idleAnimation.spriteSize.y),
        current: caterpillarStatsViewModel.currentState);
    final double anchorPos = (caterpillardata.anchorPosY /
        caterpillardata.idleAnimation.spriteSize.y);
    anchor = Anchor(0.5, anchorPos);
    angleToLerpTo = angle;
    await add(caterPillarAnimations);
    // await addMeleeWeapon();
    index = 0;
    baseSpeed = caterpillardata.movingspeed;
    await createEgg();
    startCrawling();
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
    if (!isInitializing) {
      if (segemntAddRequest) {
        addSegment();
      }
    }
    CaterpillarCrawlUtils.updateLerpToAngle(
        dt,
        transform,
        CaterpillarCrawlUtils.getAngleFromUp(playerController.currentDelta),
        rotationSpeed);
    if (caterpillarStatsViewModel.isReadyToEgg) {
      return;
    }
    updateOnHold();
    updateUlti(dt);
    startUpdateAngleQueue(dt);
    updateCoolDownDead(dt);
    timeSinceLastEnemyKilled += dt;
  }

  void startUpdateAngleQueue(double dt) {
    orientation = Vector2(1 * sin(angle), -1 * cos(angle)).normalized();
    if (caterpillarStatsViewModel.currentState == CaterpillarState.crawling) {
      position += orientation *
          baseSpeed *
          dt *
          gameWorld.movingSpeedMultiplierValue.value;
    }
    Vector2 currentPos = absolutePositionOfAnchor(anchor);
    angleQueue.addFirst(MovementTransferData(
        orientation: orientation, position: currentPos, angle: angle));
    correctListLength(entriesNeeded);
    if (caterpillarStatsViewModel.currentState == CaterpillarState.idle) {
      return;
    }
    if (nextSegment != null) {
      nextSegment?.absolutePositionOfAnchor(nextSegment!.anchor);
      if (!isDroppingsegments) {
        nextSegment?.updateAngleQueue(entriesNeeded);
      }
      nextSegment?.angle = angleQueue.last.angle;
      nextSegment?.position = angleQueue.last.position;
    }
  }

  ///Checks the Position with the Previous Segment if Caterpillar is on Hold and marks it Ready For Deletion
  void updateOnHold() {
    if (caterpillarStateViewModel.isRemovingSegments) {
      return;
    }
    if (caterpillarStatsViewModel.currentState ==
            CaterpillarState.onHoldForEgg &&
        nextSegment != null) {
      if (position.distanceTo(nextSegment!.position).abs() < 0.01) {
        if (nextSegment!.parent == null) return;
        removeSegment(nextSegment!);
        segmentToEggCounter++;
      }
      if (segmentToEggCounter >= segmentToRemoveBeforeEgg) {
        gameWorld.tutorialBuilder
            .onConditionReached(TutorialConditions.activateBomb, null);
        caterpillarStatsViewModel.setIsReadyToEgg(true);
        return;
      }
    }
  }

  bool isInUlti = false;

  // void ulti() {
  //   isInUlti = true;
  //   fallOffAllSegments(true);
  //   magicAround.stopSparkling();

  //   lives = gameWorld.playerLifeCount;
  //   caterpillarStatsViewModel.onUlti();
  //   startCrawling();
  //   gameWorld.tutorialBuilder
  //       .onConditionReached(TutorialConditions.makeUlti, null);
  // }

  void levelUp() {
    // gameWorld.zoomOut(caterpillarStatsViewModel.level);
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

  bool isDroppingsegments = false;

  void removeAllSegments() {
    // setCaterpillarState(CaterpillarState.idle);
    if (lastSegment != null) {
      lastSegment!.removeOnNextFrame = true;
    }
    nextSegment?.fallOff();
    onAllSegmentsRemoved();
  }

  void onAllSegmentsRemoved() {
    _setSegmentCount(0);
    lastSegment = null;
    nextSegment = null;
    // isDroppingsegments = false;
    //setCaterpillarState(CaterpillarState.crawling);
  }

  void fallOffLastSegments(bool isUlti) {
    if (!isDroppingsegments && nextSegment != null && lastSegment != null) {
      isDroppingsegments = true;
      CaterpillarElement newLastSegment = lastSegment!.previousSegment;
      lastSegment!.falloff(isUlti);
      _setSegmentCount(caterpillarStatsViewModel.segmentCount - 1);
      if (!isUlti) {
        gameWorld.groundMap.obstacleSnapshot.renderSnapshotOnNextFrame();
      }
      lastSegment =
          newLastSegment is CaterpillarSegment ? newLastSegment : null;
      isDroppingsegments = false;
    }
  }

  void _setSegmentCount(int segmentCount) {
    caterpillarStatsViewModel.setSegmentCount(segmentCount);
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

  void hurt() {
    if (caterpillarStatsViewModel.isHurt ||
        gameWorld.tutorialModeViewModel.isInTutorialMode) {
      return;
    }
    caterpillarStatsViewModel.setIsHurt(true);
    lives = lives - 1;
    fallOffLastSegments(false);
    startCrawling();
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    //position = gameSize / 2;
  }

  void onMoveDirectionChange(Vector2 pointToMoveTo) {
    angleToLerpTo = CaterpillarCrawlUtils.getAngleFromUp(pointToMoveTo);
  }

  void addCaterpillarSegemntRequest() {
    segemntAddRequest = true;
  }

  void addSegment() {
    segemntAddRequest = false;

    if (lastSegment != null) {
      if (caterpillarStatsViewModel.segmentCount >
          gameWorld.maxCaterpillarLength.value) {
        return;
      }

      lastSegment!.addCaterPillarSegment(this);
    } else {
      addCaterPillarSegment(this);
    }
    onSegmentAddedOrRemoved();

    gameWorld.tutorialBuilder
        .onConditionReached(TutorialConditions.getLong, lastSegment!.index);
  }

  void removeSegment(CaterpillarSegment segment) {
    if (segment.isFallenOff) {
      return;
    }
    if (lastSegment!.index == segment.index) {
      lastSegment = null;
    }
    // if (segment.nextSegment != null)
    nextSegment = segment.nextSegment;
    if (nextSegment != null) {
      nextSegment!.previousSegment = this;
      angleQueue = segment.angleQueue;
    }
    caterpillarStateViewModel.setIsRemovingSegment(true);
    gameWorld.groundMap.remove(segment);
    caterpillarStatsViewModel.onRemoveSegment();
    onSegmentAddedOrRemoved();
  }

  void toggleUseEgg() {
    // if (caterpillarStatsViewModel.currentState ==
    //     CaterpillarState.readyForUlti) {
    //   return;
    // }
    //stop rotatiing head
    angleToLerpTo = angle;
    //After Button click eg.
    if (caterpillarStatsViewModel.currentState == CaterpillarState.crawling) {
      if (caterpillarStatsViewModel.segmentCount < segmentToRemoveBeforeEgg) {
        return;
      }
      setCaterpillarState(CaterpillarState.onHoldForEgg);
    } else if (caterpillarStatsViewModel.isReadyToEgg) {
      ShootEgg();
      startCrawling();
      caterpillarStatsViewModel.setIsReadyToEgg(false);
    }
  }

  void startCrawling() {
    setCaterpillarState(CaterpillarState.crawling);
    segmentToEggCounter = 0;
  }

  Future<void> createEgg() async {
    DistanceWeaponData explodingEgg = DistanceWeaponData.createExplodingEgg();
    //Fix DEBUG
    explodingEgg.explodingAnimation = AnimationData(
        animationstepCount: 11,
        finalSize: Vector2.all(128),
        imagePath: "bombanimexplode.png",
        spriteSize: Vector2.all(128));
    baseDistanceWeapon =
        EggyBomb(map: gameWorld.groundMap, weaponData: explodingEgg);
    await add(baseDistanceWeapon!);
    baseDistanceWeapon!.position = Vector2(position.x + size.x / 2, position.y);
  }

  Future<void> ShootEgg() async {
    baseDistanceWeapon?.startAttacking();
    gameWorld.tutorialBuilder
        .onConditionReached(TutorialConditions.useBomb, null);
  }

  void onPewPew() {
    // Pellet.shootMultiplePellets(
    //     gameWorld, position, angle, caterpillarStatsViewModel.level + 1);
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
    print(baseMeleeWeapon!.position);
  }

  void RemoveMeleeWeapon() {
    baseMeleeWeapon?.removeFromParent();
  }

  void onSegmentAddedOrRemoved() {
    // speedMultiplier = 0.5 + (caterpillarStatsViewModel.segmentCount / 400);
    _setSegmentCount(caterpillarStatsViewModel.segmentCount);
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

  setCaterpillarState(CaterpillarState state) {
    if (caterpillarStatsViewModel.currentState == state) {
      return;
    }
    if (state == CaterpillarState.crawling ||
        state == CaterpillarState.onHoldForEgg ||
        state == CaterpillarState.idle) {
      caterPillarAnimations.current = state;
    }
    if (state == CaterpillarState.readyForUlti) {
      gameWorld.distanceActionButtonViewModel
          .onChangeType('assets/images/segment_single_color02.png', () => ());
    } else if (caterpillarStatsViewModel.currentState ==
            CaterpillarState.readyForUlti &&
        state != CaterpillarState.readyForUlti) {
      gameWorld.distanceActionButtonViewModel.onChangeType(
          'assets/images/bomb_128_button.png', () => gameWorld.onLayEggTap());
    }
    caterpillarStatsViewModel.setCaterpillarstate(state);
  }

  void removeCompletly() {
    super.reset();
    removeFromParent();
  }
}
