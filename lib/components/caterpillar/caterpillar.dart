import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillar/caterpillarSegment.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/caterpillarData.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';

import 'caterpillarElement.dart';

class CaterPillar extends CaterpillarElement {
  bool isMoving = true;
  bool isOnHold = false;
  bool isRemovingSegment = false;

  static const double fullCircle = 2 * pi;

  double rotationSpeed;

  late double angleToLerpTo;
  late double scaledAnchorYPos;

  CaterpillarSegment? lastSegment;
  late int entriesNeeded;
  int fixIterationPerFrame =
      1; //how much need to be fixed - the higher the more
  double tolerance = 20; //how tolerant should be segment distance differnces?

  List<CaterpillarSegment> segmentsToRemove = List.empty();

  int snackCount = 0;

  CaterPillar(super.caterpillardata, super.gameWorld, this.rotationSpeed);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = caterpillardata.finalSize;
    finalSize = caterpillardata.finalSize;
    final data = SpriteAnimationData.sequenced(
      textureSize: caterpillardata.spriteSize,
      amount: caterpillardata.animationSprites,
      stepTime: 0.1,
    );
    animation = SpriteAnimationComponent.fromFrameData(
        await imageLoader.load(caterpillardata.imagePath), data,
        scale: Vector2(finalSize.x / caterpillardata.spriteSize.x,
            finalSize.y / caterpillardata.spriteSize.y));

    final double anchorPos =
        (caterpillardata.anchorPosY / caterpillardata.spriteSize.y);
    anchor = Anchor(0.5, anchorPos);
    angleToLerpTo = angle;
    add(animation);
    priority = 10000;
    index = 0;
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
    updateLerpToAngle(dt);
    if (isMoving) {
      startUpdateAngleQueue(dt);
    }
    updateOnHold();
  }

  void startUpdateAngleQueue(double dt) {
    orientation = Vector2(1 * sin(angle), -1 * cos(angle)).normalized();
    if (!isOnHold) {
      position += orientation * velocity * speedMultiplier;
    }
    entriesNeeded = calcSteptToReachDistance(dt);
    Vector2 currentPos = absolutePositionOfAnchor(anchor);
    angleQueue.addFirst(MovementTransferData(
        orientation: orientation, position: currentPos, angle: angle));
    correctListLength(fixIterationPerFrame, entriesNeeded);
    if (nextSegment != null) {
      if (currentPos.distanceTo(
              nextSegment!.absolutePositionOfAnchor(nextSegment!.anchor)) >
          fixedDistToSegment + tolerance) {
        fixIterationPerFrame = 3;
      } else {
        fixIterationPerFrame = 1;
      }
      nextSegment?.updateAngleQueue(fixIterationPerFrame, entriesNeeded);
      nextSegment?.angle = angleQueue.last.angle;
      nextSegment?.position = angleQueue.last.position;
    }
  }

  ///Checks the Position with the Previous Segment if Caterpillar is on Hold and marks it Ready For Deletion
  void updateOnHold() {
    if (!isOnHold || nextSegment == null || isRemovingSegment) {
      return;
    }
    if (position.distanceTo(nextSegment!.position).abs() < 0.01) {
      if (nextSegment!.parent == null) return;
      print(
          "DIST ${position.distanceTo(nextSegment!.position).abs()} from segment ${nextSegment!.index}");
      print("POS ${position} from segment pos ${nextSegment!.position}");

      nextSegment!.segemntOnHold = true;
      if (nextSegment != null) {
        print("NEXT ${nextSegment!.index}");
        //TODO: Refine removement
        removeSegment(nextSegment!);
      }

      return;
    }
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    position = gameSize / 2;
  }

  void updateLerpToAngle(double dt) {
    double diff = transform.angle - angleToLerpTo;
    if (diff.abs() < 0.1) {
      transform.angle = angleToLerpTo;
      return;
    }
    int direction = 1;
    if ((diff > 0 && diff < pi) || diff < -pi) {
      direction = -1;
    }

    double lerpSpeedDt = dt * rotationSpeed * direction * speedMultiplier;
    transform.angle += lerpSpeedDt;

    //fix error from 0 to 360 degrees
    angle = angle % (fullCircle);
    if (angle < 0) {
      angle = fullCircle + (angle % (fullCircle));
    }
  }

  void onMoveDirectionChange(Vector2 pointToMoveTo) {
    angleToLerpTo = FlameGameUtils.getAngleFromUp(pointToMoveTo);
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

  void setSegmentToRemove() {}

  void removeSegment(CaterpillarSegment segment) {
    if(lastSegment!.index == segment.index)
    {
       lastSegment = null;
    }
    if (segment.nextSegment != null)
      print(
          "CURRENT ${nextSegment!.index} NEXT: ${segment.nextSegment!.index}");

    nextSegment = segment.nextSegment;
    if (nextSegment != null) {
      nextSegment!.previousSegment = this;
      angleQueue = segment.angleQueue;
      
    }
    isRemovingSegment = true;
    gameWorld.world.remove(segment);
  }
}
