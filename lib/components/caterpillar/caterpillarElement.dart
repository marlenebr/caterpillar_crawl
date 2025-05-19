import 'dart:collection';

import 'package:caterpillar_crawl/components/caterpillar/caterpillarSegment.dart';
import 'package:caterpillar_crawl/components/caterpillar/caterpillar_base.dart';
import 'package:caterpillar_crawl/components/snack.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/data/caterpillar_data.dart';
import 'package:flame/components.dart';

class CaterpillarElement extends PositionComponent {
  CaterpillarSegment? nextSegment;
  CaterpillarData caterpillardata;
  CaterpillarCrawlMain gameWorld;

  double distToCollide = 15;

  Queue<MovementTransferData> angleQueue =
      Queue<MovementTransferData>(); // ListQueue() by default
  bool isInitializing = true;
  int index = 0;

  double secondCounter = 0;
  double timeSinceInit = 0;

  late Vector2 finalSize;

  Vector2 orientation = Vector2.zero();

  late double fixedDistToSegment;
  late Vector2 initPosition;

  CaterpillarElement(this.caterpillardata, this.gameWorld);

  @override
  void update(double dt) {
    super.update(dt);
    initSegment();

    timeSinceInit += dt;
  }

  @override
  Future<void> onLoad() async {
    fixedDistToSegment = caterpillardata.refinedSegmentDistance *
        caterpillardata.segmentAnimation.finalSize.y;
  }

  @override
  void onMount() {
    super.onMount();
    initPosition = Vector2(position.x, position.y);
  }

  bool caterPillarFixedUpdate(double dt, double frameDuration) {
    secondCounter += dt;
    if (secondCounter >= frameDuration) {
      secondCounter = 0;
      return true;
    }
    return false;
  }

  Future<void> addCaterPillarSegment(
      CaterpillarBase caterpillar, SnackType snackType) async {
    if (caterpillardata.maxElementCount <= index) {
      return;
    }
    nextSegment = CaterpillarSegment(caterpillardata, gameWorld,
        snackType: snackType, previousSegment: this, caterpillar: caterpillar);
    nextSegment?.index = index + 1;
    caterpillar.lastSegment = nextSegment;
    nextSegment?.position = position;
    await gameWorld.groundMap.add(nextSegment!);
    nextSegment?.previousSegment = this;
    nextSegment?.priority = priority - 1;
    nextSegment?.angle = angle;
    caterpillar.caterpillarStatsViewModel.onAddSegment();
    gameWorld.groundMap.playerReachedFullLegnth(
        nextSegment!.index >= caterpillardata.maxElementCount);
    caterpillar.onSegmentAddedOrRemoved(nextSegment!, false);

    return;
  }

  void updateAngleQueue(int entriesNeeded) {
    angleQueue.addFirst(MovementTransferData(
        orientation: orientation,
        position: absolutePositionOfAnchor(anchor),
        angle: angle));
    correctListLength(entriesNeeded);

    if (nextSegment != null) {
      nextSegment?.angle = angleQueue.last.angle;
      nextSegment?.position = angleQueue.last.position;
      nextSegment?.updateAngleQueue(entriesNeeded);
    }
  }

  void correctListLength(int entriesNeeded) {
    if (angleQueue.length > entriesNeeded) {
      // for(int i = debugLeN; i >entriesNeeded; i--)
      // {
      angleQueue.removeLast();
      //}
    } else {
      return;
    }
  }

  void initSegment() {
    if (isInitializing &&
        initPosition.distanceTo(position) > fixedDistToSegment) {
      isInitializing = false;
    }
  }

  //the length of angeleQue based on speed
  int calcSteptToReachDistance() {
    double fixedDt = 1 / 60;
    double distPerFrame = fixedDt *
        (caterpillardata.movingspeed *
            gameWorld.movingSpeedMultiplierValue.value);

    double stepsToReachDist = fixedDistToSegment / distPerFrame;
    return (stepsToReachDist).toInt();
  }

  void setMovementQueue(Queue<MovementTransferData> newMovementQueue) {
    angleQueue = newMovementQueue;
  }

  void reset() {
    nextSegment?.reset();
    angleQueue.clear();
    isInitializing = true;
    secondCounter = 0;
    timeSinceInit = 0;
    orientation = Vector2.zero();
  }
}
