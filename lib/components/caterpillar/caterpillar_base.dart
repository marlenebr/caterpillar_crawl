import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillar/caterpillarSegment.dart';
import 'package:caterpillar_crawl/components/player_controller.dart';
import 'package:caterpillar_crawl/components/snack.dart';
import 'package:caterpillar_crawl/components/tutorial_builder.dart';
import 'package:caterpillar_crawl/models/data/caterpillar_data.dart';
import 'package:caterpillar_crawl/models/view_models/caterpillar_state_view_model.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';

import 'caterpillarElement.dart';

enum CaterpillarState { crawling, chargingUp, idle }

class CaterpillarBase extends CaterpillarElement {
  CaterpillarStateViewModel caterpillarStateViewModel;
  CaterpillarStatsViewModel caterpillarStatsViewModel;

  PlayerController playerController;

  bool isDroppingsegments = false;

  CaterpillarSegment? lastSegment;
  List<CaterpillarSegment> allSegments = [];

  late int entriesNeeded;

  late SpriteAnimationGroupComponent<CaterpillarState> caterPillarAnimations;

  late SpriteAnimation headAnimation;
  late SpriteAnimation wobbleAnimation;

  static const double fullCircle = 2 * pi;

  double rotationSpeed;
  double baseSpeed;

  double dieCoolDownTime = 1.2;
  double dieCoolDownTimer = 0;
  double timeSinceLastEnemyKilled = 0;

  late double angleToLerpTo;
  late double scaledAnchorYPos;

  int segmentToRemoveBeforeEgg = 1;
  int segmentToEggCounter = 0;

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

  CaterpillarBase(super.caterpillardata, super.gameWorld,
      {required this.rotationSpeed,
      required this.playerController,
      required this.caterpillarStateViewModel,
      required this.caterpillarStatsViewModel})
      : baseSpeed = caterpillardata.movingspeed;

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
          CaterpillarState.chargingUp: wobbleAnimation,
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
    startCrawling();
  }

  @override
  void update(double dt) {
    super.update(dt);
    CaterpillarCrawlUtils.updateLerpToAngle(
        dt,
        transform,
        CaterpillarCrawlUtils.getAngleFromUp(playerController.currentDelta),
        rotationSpeed);
    updateOnHold();
    startUpdateAngleQueue(dt);
    timeSinceLastEnemyKilled += dt;
  }

  void startCrawling() {
    setCaterpillarState(CaterpillarState.crawling);
    segmentToEggCounter = 0;
  }

  setCaterpillarState(CaterpillarState state) {
    if (caterpillarStatsViewModel.currentState == state) {
      return;
    }
    if (state == CaterpillarState.crawling ||
        state == CaterpillarState.chargingUp ||
        state == CaterpillarState.idle) {
      caterPillarAnimations.current = state;
    }
    caterpillarStatsViewModel.setCaterpillarstate(state);
  }

  ///Checks the Position with the Previous Segment if Caterpillar is on Hold and marks it Ready For Deletion
  void updateOnHold() {
    if (caterpillarStateViewModel.isRemovingSegments) {
      return;
    }
    if (caterpillarStatsViewModel.currentState == CaterpillarState.chargingUp &&
        nextSegment != null) {
      if (position.distanceTo(nextSegment!.position).abs() < 0.01) {
        if (nextSegment!.parent == null) return;
        removeSegment(nextSegment!);
        segmentToEggCounter++;
        setCaterpillarState(CaterpillarState.idle);
      }
      if (segmentToEggCounter >= segmentToRemoveBeforeEgg) {
        gameWorld.tutorialBuilder
            .onConditionReached(TutorialConditions.activateBomb, null);
        return;
      }
    }
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
    if (caterpillarStatsViewModel.currentState == CaterpillarState.idle) {
      return;
    }
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

  void removeSegment(CaterpillarSegment segment) {
    if (segment.isFallenOff) {
      return;
    }
    if (lastSegment!.index == segment.index) {
      lastSegment = null;
      //baseDistanceWeapon?.setWeapon(null);
      setCaterpillarState(CaterpillarState.crawling);
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
    onSegmentAddedOrRemoved(segment, true);
  }

  void addSegment(SnackType snackType) {
    if (lastSegment != null) {
      if (caterpillarStatsViewModel.segmentCount >
          gameWorld.maxCaterpillarLength.value) {
        return;
      }

      lastSegment!.addCaterPillarSegment(this, snackType);
    } else {
      addCaterPillarSegment(this, snackType);
    }
    // gameWorld.tutorialBuilder
    //     .onConditionReached(TutorialConditions.getLong, lastSegment!.index);
  }

  void onSegmentAddedOrRemoved(CaterpillarSegment segment, bool isRemoving) {
    // speedMultiplier = 0.5 + (caterpillarStatsViewModel.segmentCount / 400);
    isRemoving ? allSegments.remove(segment) : allSegments.add(segment);
    setSegmentCount();

    // //DEBUG
    // gameWorld.distanceActionButtonViewModel.onChangeType(
    //
    //
    //   'assets/images/bomb_128_button.png', () => toggleUseEgg());
  }

  void setSegmentCount() {
    caterpillarStatsViewModel.setSegmentCount(allSegments.length);
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

  void fallOffLastSegments(bool isUlti) {
    if (!isDroppingsegments && nextSegment != null && lastSegment != null) {
      isDroppingsegments = true;
      CaterpillarElement newLastSegment = lastSegment!.previousSegment;
      lastSegment!.falloff(isUlti);
      setSegmentCount();
      if (!isUlti) {
        gameWorld.groundMap.obstacleSnapshot.renderSnapshotOnNextFrame();
      }
      lastSegment =
          newLastSegment is CaterpillarSegment ? newLastSegment : null;
      isDroppingsegments = false;
    }
  }
}
