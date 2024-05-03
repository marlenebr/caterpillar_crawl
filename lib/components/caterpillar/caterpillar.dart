import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillar/caterpillarSegment.dart';
import 'package:caterpillar_crawl/components/weapons/egg.dart';
import 'package:caterpillar_crawl/components/enemy.dart';
import 'package:caterpillar_crawl/components/weapons/pellet.dart';
import 'package:caterpillar_crawl/models/caterpillar_data.dart';
import 'package:caterpillar_crawl/models/egg_data.dart';
import 'package:caterpillar_crawl/ui_elements/caterpillar_joystick.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import 'caterpillarElement.dart';

enum CaterpillarState { crawling, onHoldForEgg }

class CaterPillar extends CaterpillarElement {
  bool isRemovingSegment = false;

  bool isHurt = false;

  bool readyToEgg = false;
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

  CaterpillarJoystick joystick;

  CaterpillarSegment? lastSegment;
  late int entriesNeeded;
  int fixIterationPerFrame =
      1; //how much need to be fixed - the higher the more
  double tolerance = 3; //how tolerant should be segment distance differnces?

  List<CaterpillarSegment> segmentsToRemove = List.empty();

  int snackCount = 0;
  int segmentCount = 0;
  int enemyKilled = 0;
  int countToGrow = 30;

  int playerPoints = 0;
  int growIndex = 0;

  int _lives = 0;
  int get lives {
    return _lives;
  }

  set lives(int value) {
    _lives = value;
    if (value <= 0) {
      print("DEAD");
      _lives = 0;
    }
    if (value > caterpillardata.lives) {
      print("CANT ADD MORE LIVES");
      _lives = caterpillardata.lives;
    }
    gameWorld.onLifeCountChanged(_lives);
  }

  // int lengthToCollapse = 30;
  int growCounter = 8;

  late SpriteAnimationGroupComponent<CaterpillarState> caterPillarAnimations;

  late SpriteAnimation headAnimation;
  late SpriteAnimation wobbleAnimation;

  CaterpillarState currentState = CaterpillarState.crawling;

  CaterPillar(super.caterpillardata, super.gameWorld, this.rotationSpeed,
      this.joystick) {
    _lives = caterpillardata.lives;
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
        },
        scale: Vector2(finalSize.x / caterpillardata.idleAnimation.spriteSize.x,
            finalSize.y / caterpillardata.idleAnimation.spriteSize.y),
        current: currentState);
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
        CaterpillarCrawlUtils.getAngleFromUp(joystick.currentDelta),
        rotationSpeed);
    if (readyToEgg) {
      return;
    }
    startUpdateAngleQueue(dt);
    updateOnHold();
    updateCoolDownDead(dt);
    updateGrowth();
    updateEnemyNearBy();
    updateUlti(dt);
  }

  void updateGrowth() {
    if (growCounter == 0) {
      return;
    }
    if (segmentCount == countToGrow) {
      grow();
    }
  }

  void startUpdateAngleQueue(double dt) {
    orientation = Vector2(1 * sin(angle), -1 * cos(angle)).normalized();
    if (currentState == CaterpillarState.crawling) {
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
    if (isRemovingSegment) {
      return;
    }
    if (currentState == CaterpillarState.onHoldForEgg) {
      if (position.distanceTo(nextSegment!.position).abs() < 0.01) {
        if (nextSegment!.parent == null) return;
        removeSegment(nextSegment!);
        segmentToEggCounter++;
      }
      if (segmentToEggCounter >= segmentToRemoveBeforeEgg) {
        readyToEgg = true;
        return;
      }
    }
  }

  bool didGrow = false;
  bool isInUlti = false;

  void grow() {
    if (didGrow) {
      return;
    }
    didGrow = true;
    isInUlti = true;
    playerPoints += segmentCount;
    final effect = ScaleEffect.by(
      Vector2.all(1.05),
      EffectController(duration: 0.2),
    );
    add(effect);
    baseSpeed += 0.2;
    gameWorld.zoomOut(growCounter);
    growCounter--;
    fallOffAllSegments(true);
    growIndex++;
    lives = caterpillardata.lives;
    gameWorld.onLevelUp(growIndex);
    // scale = scale * 1.2;
  }

  void updateUlti(double dt) {
    if (isInUlti) {
      ultiTimer += dt;
      if (ultiTimer > gameWorld.timeToUlti + 1) {
        isInUlti = false;
        print("RENDER ULTI");
        gameWorld.groundMap.obstacleSnapshot.renderSnapshotOnNextFrame();
        ultiTimer = 0;
      }
    }
  }

  bool isDroppingsegments = false;

  void fallOffAllSegments(bool isLevelUp) {
    if (!isDroppingsegments && nextSegment != null) {
      isDroppingsegments = true;
      nextSegment!.falloff(isLevelUp);
      lastSegment = null;
      segmentCount = 0;
      onChangePlayerPoints();
      if (!isLevelUp) {
        gameWorld.groundMap.obstacleSnapshot.renderSnapshotOnNextFrame();
      }
      nextSegment = null;
      isDroppingsegments = false;
    }
  }

  void updateEnemyNearBy() {
    for (Enemy enemy in gameWorld.groundMap.enemies.values) {
      if (enemy.position.distanceTo(position) < 200) {
        //ROTATE TOWARDS
        enemy.followCaterpillar(position);
        if (enemy.position.distanceTo(position) < 20 &&
            enemy.enemyMovementStatus != EnemyMovementStatus.dead) {
          hurt();
        }
      } else if (enemy.enemyMovementStatus ==
          EnemyMovementStatus.moveToCaterpillar) {
        enemy.disfollowCaterpillar();
      }
    }
  }

  void updateCoolDownDead(double dt) {
    if (isHurt) {
      dieCoolDownTimer += dt;
      if (dieCoolDownTimer > dieCoolDownTime) {
        dieCoolDownTimer = 0;
        isHurt = false;
      }
    }
  }

  void hurt() {
    if (isHurt) {
      return;
    }
    isHurt = true;
    print("HURT");
    //position = Vector2.zero(); //DEBUG
    lives = lives - 1;
    fallOffAllSegments(false);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    position = gameSize / 2;
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
      lastSegment?.addCaterpillarSegemntRequest();
    } else {
      super.addCaterPillarSegment(this);
    }
    segemntAddRequest = false;
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
    isRemovingSegment = true;
    gameWorld.world.remove(segment);
    segmentCount--;
    onChangePlayerPoints();
  }

  void toggleEggAndCrawl() {
    //stop rotatiing head
    angleToLerpTo = angle;
    //After Button click eg.
    if (currentState == CaterpillarState.crawling) {
      if (segmentCount < segmentToRemoveBeforeEgg) {
        return;
      }
      setCaterpillarState(CaterpillarState.onHoldForEgg);
    } else if (readyToEgg) {
      ShootEgg();
      startCrawling();
      readyToEgg = false;
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
    Pellet.shootMultiplePellets(gameWorld, position, angle, growIndex + 1);
  }

  void onChangePlayerPoints() {
    didGrow = false;
    speedMultiplier = 0.5 + (snackCount / 400);
    gameWorld.onSegmentAddedToPlayer(playerPoints + segmentCount);
  }

  void onEnemyKilled(bool spawnNewEnemy) {
    enemyKilled += 1;
    if (spawnNewEnemy) {
      gameWorld.groundMap.addEnemy();
    }
    gameWorld.onEnemyKilled(enemyKilled);
  }

  setCaterpillarState(CaterpillarState state) {
    currentState = state;
    if (state == CaterpillarState.crawling ||
        state == CaterpillarState.onHoldForEgg) {
      caterPillarAnimations.current = currentState;
    }
  }
}
