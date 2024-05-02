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
import 'package:flame/input.dart';

import 'caterpillarElement.dart';

enum CaterpillarState { crawling, onHold, readyToEgg, grow }

class CaterPillar extends CaterpillarElement {
  bool isMoving = true;
  bool isRemovingSegment = false;

  bool isHurt = false;

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
  int loadToEgg = 1;
  int countToGrow = 30;

  int playerPoints = 0;
  int growIndex = 0;

  // int lengthToCollapse = 30;
  int growCounter = 8;

  late int loadToEggCount; //How many segments should me removed untill egg

  late SpriteAnimationGroupComponent<CaterpillarState> caterPillarAnimations;

  late SpriteAnimation headAnimation;
  late SpriteAnimation wobbleAnimation;

  CaterpillarState currentState = CaterpillarState.crawling;

  CaterPillar(super.caterpillardata, super.gameWorld, this.rotationSpeed,
      this.joystick);

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
          CaterpillarState.onHold: wobbleAnimation,
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
    loadToEggCount = loadToEgg;
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
    // angle = joystick.delta.screenAngle();
    if (currentState == CaterpillarState.readyToEgg) {
      return;
    }
    if (isMoving) {
      startUpdateAngleQueue(dt);
    }
    updateOnHold();
    updateCoolDownDead(dt);
    updateGrowth();
    updateEnemyNearBy();
    //updateCollapse();
  }

  void updateGrowth() {
    if (growCounter == 0) {
      return;
    }
    if (segmentCount == countToGrow) {
      grow();
    }
  }

  // Future<SpriteAnimation> _createCaterpillarAnimation(
  //     String path, int amount) async {
  //   final data = SpriteAnimationData.sequenced(
  //     textureSize: caterpillardata.spriteSize,
  //     amount: amount,
  //     stepTime: 0.1,
  //   );
  //   SpriteAnimationComponent caterPillarAnim =
  //       SpriteAnimationComponent.fromFrameData(
  //     await imageLoader.load(path),
  //     data,
  //   );

  //   return caterPillarAnim.animation!;
  // }

  void startUpdateAngleQueue(double dt) {
    orientation = Vector2(1 * sin(angle), -1 * cos(angle)).normalized();
    if (currentState == CaterpillarState.crawling) {
      position += orientation * baseSpeed * dt * speedMultiplier;
    }
    Vector2 currentPos = absolutePositionOfAnchor(anchor);
    angleQueue.addFirst(MovementTransferData(
        orientation: orientation, position: currentPos, angle: angle));
    correctListLength(entriesNeeded);
    // angleQueue.removeLast();

    if (nextSegment != null) {
      // if (currentPos.distanceTo(
      //         nextSegment!.absolutePositionOfAnchor(nextSegment!.anchor)) >
      //     fixedDistToSegment + tolerance) {
      //   fixIterationPerFrame = 3;
      // } else {
      //   fixIterationPerFrame = 1;
      // }
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
    if ((currentState != CaterpillarState.onHold &&
            currentState != CaterpillarState.grow) ||
        isRemovingSegment) {
      return;
    }
    if (nextSegment == null || lastSegment == null) {
      startCrawling();
      return;
    }
    if (loadToEggCount < 1) {
      if (currentState != CaterpillarState.grow) {
        currentState = CaterpillarState.readyToEgg;
        gameWorld.onCaterPillarReadyToEgg();
        return;
      }
    }

    if (position.distanceTo(nextSegment!.position).abs() < 0.01) {
      if (nextSegment!.parent == null) return;
      nextSegment!.segemntOnHold = true;
      //TODO: Refine removement
      removeSegment(nextSegment!);
      return;
    }
  }

  // void updateCollapse() {
  //   if (snackCount >= lengthToCollapse) {
  //     if (collapseIndex <= 0) {
  //       return;
  //     }
  //   }
  //   if (nextSegment == null) {
  //     //GROW!!!!!!!!!!!!!!!
  //     grow();
  //     collapseIndex--;

  //     return;
  //   }
  // }

  bool didGrow = false;

  void grow() {
    if (didGrow) {
      return;
    }
    didGrow = true;
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
    gameWorld.onLevelUp(growIndex);

    // scale = scale * 1.2;
  }

  bool isDroppingsegments = false;

  void fallOffAllSegments(bool turnToSnack) {
    if (!isDroppingsegments && nextSegment != null) {
      isDroppingsegments = true;
      nextSegment!.falloff(turnToSnack);
      lastSegment = null;
      segmentCount = 0;
      onChangePlayerPoints();
      if (!turnToSnack) {
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
          dead();
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

  void dead() {
    if (isHurt) {
      return;
    }
    isHurt = true;
    print("DEAD");
    //position = Vector2.zero(); //DEBUG
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
    loadToEggCount--;
  }

  void onFatRoundButtonClick() {
    //stop rotatiing head
    angleToLerpTo = angle;
    if (currentState == CaterpillarState.grow) {
      return;
    }
    //After Button click eg.
    if (currentState == CaterpillarState.crawling) {
      currentState = CaterpillarState.onHold;
    }
    if (currentState == CaterpillarState.readyToEgg) {
      startCrawling();
      //SHOOT EGG
    }
    caterPillarAnimations.current = currentState;
  }

  void startCrawling() {
    if (currentState == CaterpillarState.readyToEgg) {
      ShootEgg();
    }
    currentState = CaterpillarState.crawling;
    loadToEggCount = loadToEgg;
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

    // Pellet pellet = Pellet(
    //     forwardAngle: angle,
    //     gameWorld: gameWorld,
    //     lifeTime: 1.5,
    //     shootingSpeed: 300);
    // gameWorld.world.add(pellet);
    // pellet.position = Vector2(position.x, position.y);
    // if (growIndex > 3) {
    // Pellet pellet1 = Pellet(
    //     forwardAngle: angle - 0.2,
    //     gameWorld: gameWorld,
    //     lifeTime: 1.5,
    //     shootingSpeed: 300);
    // gameWorld.world.add(pellet1);
    // pellet1.position = Vector2(position.x, position.y);

    // Pellet pellet2 = Pellet(
    //     forwardAngle: angle + 0.2,
    //     gameWorld: gameWorld,
    //     lifeTime: 1.5,
    //     shootingSpeed: 300);
    // gameWorld.world.add(pellet2);
    // pellet2.position = Vector2(position.x, position.y);
    // }
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
}
