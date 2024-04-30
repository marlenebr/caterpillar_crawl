import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillar/caterpillarSegment.dart';
import 'package:caterpillar_crawl/components/egg.dart';
import 'package:caterpillar_crawl/components/enemy.dart';
import 'package:caterpillar_crawl/components/pellet.dart';
import 'package:caterpillar_crawl/models/caterpillar_data.dart';
import 'package:caterpillar_crawl/models/egg_data.dart';
import 'package:caterpillar_crawl/ui_elements/caterpillar_joystick.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/input.dart';

import 'caterpillarElement.dart';

enum CaterpillarState { crawling, onHold, readyToEgg, shooting, grow }

class CaterPillar extends CaterpillarElement {
  bool isMoving = true;
  bool isRemovingSegment = false;

  static const double fullCircle = 2 * pi;

  double rotationSpeed;
  double speedMultiplier = 0.5;
  double baseSpeed = 1;

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
  int enemyKilled = 0;
  int loadToEgg = 1;

  int lengthToCollapse = 30;
  int collapseIndex = 3;

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
    updateEnemyNearBy();
    //updateCollapse();
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
    entriesNeeded = calcSteptToReachDistance(dt);
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
      nextSegment?.updateAngleQueue(entriesNeeded);
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
    if (nextSegment == null) {
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

  void updateCollapse() {
    if (snackCount >= lengthToCollapse) {
      if (collapseIndex <= 0) {
        return;
      }
      currentState = CaterpillarState.grow;
    }
    if (nextSegment == null) {
      if (currentState == CaterpillarState.grow) {
        //GROW!!!!!!!!!!!!!!!
        grow();
        collapseIndex--;
      }
      return;
    }
  }

  void grow() {
    final effect = ScaleEffect.by(
      Vector2.all(1.2),
      EffectController(duration: 0.2),
    );
    add(effect);
    baseSpeed += 0.2;
    gameWorld.zoomOut();

    // scale = scale * 1.2;
  }

  // void setState(CaterpillarState caterPillarState) {
  //   if(currentState == CaterpillarState.grow)
  //   {
  //     if(caterPillarState == CaterpillarState.crawling)
  //     {
  //       caterPillarState = CaterpillarState.crawling;
  //     }
  //     return;
  //   }
  //   if(currentState == CaterpillarState.readyToEgg)
  //   {
  //     gameWorld.onCaterPillarReadyToEgg();
  //   }

  //   currentState = caterPillarState;
  //   //when GROW dann kann nicht mehr gewechselt werden
  // }

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

  void dead() {
    print("DEAD");
    position = Vector2.zero(); //DEBUG
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
    onChangeSegmentCount(-1);
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
    Pellet pellet = Pellet(
        forwardAngle: angle,
        gameWorld: gameWorld,
        lifeTime: 1.5,
        shootingSpeed: 300);
    gameWorld.world.add(pellet);
    pellet.position = Vector2(position.x, position.y);
  }

  void onChangeSegmentCount(int changeCount) {
    snackCount += changeCount;
    speedMultiplier = 0.5 + (snackCount / 400);
    gameWorld.onSegmentAddedToPlayer(snackCount);
  }

  void onEnemyKilled() {
    enemyKilled += 1;
    gameWorld.onEnemyKilled(enemyKilled);
  }
}
