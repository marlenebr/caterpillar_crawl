import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillar/caterpillarSegment.dart';
import 'package:caterpillar_crawl/components/player_controller.dart';
import 'package:caterpillar_crawl/components/weapons/egg.dart';
import 'package:caterpillar_crawl/components/weapons/pellet.dart';
import 'package:caterpillar_crawl/models/data/caterpillar_data.dart';
import 'package:caterpillar_crawl/models/data/egg_data.dart';
import 'package:caterpillar_crawl/models/view_models/caterpillar_state_view_model.dart';
import 'package:caterpillar_crawl/ui_elements/caterpillar_joystick.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import 'caterpillarElement.dart';

enum CaterpillarState { crawling, onHoldForEgg, readyForUlti }

class CaterPillar extends CaterpillarElement {
  CaterpillarStateViewModel caterpillarStateViewModel;
  CaterpillarStatsViewModel caterpillarStatsViewModel;

  // bool isRemovingSegment = false;
  // bool isHurt = false;

  // bool readyToEgg = false;
  int segmentToRemoveBeforeEgg = 1;
  int segmentToEggCounter = 0; //How many segments should me removed untill egg

  double ultiTimer = 0;

  static const double fullCircle = 2 * pi;

  double rotationSpeed;
  double speedMultiplier = 0.5;
  double baseSpeed = 1;

  double dieCoolDownTime = 1.2;
  double dieCoolDownTimer = 0;

  late double angleToLerpTo;
  late double scaledAnchorYPos;

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
    if (value > gameWorld.playerLifeCount) {}
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
      required this.caterpillarStatsViewModel}) {
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
          //TODO: ReadyForUlti
        },
        scale: Vector2(finalSize.x / caterpillardata.idleAnimation.spriteSize.x,
            finalSize.y / caterpillardata.idleAnimation.spriteSize.y),
        current: caterpillarStatsViewModel.currentState);
    final double anchorPos = (caterpillardata.anchorPosY /
        caterpillardata.idleAnimation.spriteSize.y);
    anchor = Anchor(0.5, anchorPos);
    angleToLerpTo = angle;
    add(caterPillarAnimations);
    priority = 10000;
    index = 0;
    baseSpeed = caterpillardata.movingspeed;
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
  }

  // void updateUlti() {
  //   if (segmentCount == countToUlti) {
  //     ulti();
  //   }
  // }

  void startUpdateAngleQueue(double dt) {
    orientation = Vector2(1 * sin(angle), -1 * cos(angle)).normalized();
    if (caterpillarStatsViewModel.currentState !=
        CaterpillarState.onHoldForEgg) {
      position += orientation * baseSpeed * dt * speedMultiplier;
    }
    Vector2 currentPos = absolutePositionOfAnchor(anchor);
    angleQueue.addFirst(MovementTransferData(
        orientation: orientation, position: currentPos, angle: angle));
    correctListLength(entriesNeeded);

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
        caterpillarStatsViewModel.setIsReadyToEgg(true);
        return;
      }
    }
  }

  bool isInUlti = false;

  void ulti() {
    isInUlti = true;
    fallOffAllSegments(true);
    lives = gameWorld.playerLifeCount;
    caterpillarStatsViewModel.onUlti();
    startCrawling();
  }

  void grow() {
    final effect = ScaleEffect.by(
      Vector2.all(1.05),
      EffectController(duration: 0.2),
    );
    add(effect);
    baseSpeed += 0.2;
    caterpillarStatsViewModel.setLevelUp();
    gameWorld.zoomOut(caterpillarStatsViewModel.level);
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

  void fallOffAllSegments(bool isUlti) {
    if (!isDroppingsegments && nextSegment != null) {
      isDroppingsegments = true;
      nextSegment!.falloff(isUlti);
      caterpillarStatsViewModel.setSegmentCount(0);
      if (!isUlti) {
        gameWorld.groundMap.obstacleSnapshot.renderSnapshotOnNextFrame();
      }
      lastSegment = null;
      nextSegment = null;
      isDroppingsegments = false;
    }
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
    if (caterpillarStatsViewModel.isHurt) {
      return;
    }
    caterpillarStatsViewModel.setIsHurt(true);
    lives = lives - 1;
    fallOffAllSegments(false);
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
    if (!isInitializing) {
      addSegment();
    } else {
      segemntAddRequest = true;
    }
  }

  void addSegment() {
    if (lastSegment != null) {
      lastSegment!.addCaterpillarSegemntRequest();
    } else {
      super.addCaterPillarSegment(this);
    }
    segemntAddRequest = false;

    checkReadyForUlti();

    onSegmentAddedOrRemoved();
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
    gameWorld.world.remove(segment);
    caterpillarStatsViewModel.onRemoveSegment();
    onSegmentAddedOrRemoved();
  }

  void checkReadyForUlti() {
    if (caterpillarStatsViewModel.segmentCount >= gameWorld.segmentsToUlti &&
        caterpillarStatsViewModel.enemyKilledSinceUlti >=
            gameWorld.enemyKillsToUlti) {
      // ulti();
      setCaterpillarState(CaterpillarState.readyForUlti);
    }
  }

  void toggleEggAndCrawl() {
    if (caterpillarStatsViewModel.currentState ==
        CaterpillarState.readyForUlti) {
      return;
    }
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

  void ShootEgg() {
    EggData eggData = EggData.createEggData();
    Egg egg = Egg(eggData: eggData, gameWorld: gameWorld, shootingSpeed: 4);
    gameWorld.world.add(egg);
    egg.position = absolutePositionOfAnchor(anchor);
    egg.angle = angle;
    egg.shoot();
  }

  void onPewPew() {
    Pellet.shootMultiplePellets(
        gameWorld, position, angle, caterpillarStatsViewModel.level + 1);
  }

  void onSegmentAddedOrRemoved() {
    speedMultiplier = 0.5 + (caterpillarStatsViewModel.segmentCount / 400);
    gameWorld.caterpillarStatsViewModel
        .setSegmentCount(caterpillarStatsViewModel.segmentCount);
  }

  void onEnemyKilled() {
    caterpillarStatsViewModel.onEnemyKilled();
    checkReadyForUlti();
  }

  setCaterpillarState(CaterpillarState state) {
    caterpillarStatsViewModel.setCaterpillarstate(state);
    if (state == CaterpillarState.crawling ||
        state == CaterpillarState.onHoldForEgg) {
      caterPillarAnimations.current = state;
    }
    // if (state == CaterpillarState.readyForUlti) {
    //   onReadyForulti();
    // }
  }

  // void onReadyForulti()
  // {
  // }

  void removeCompletly() {
    super.reset();
    removeFromParent();
  }
}
