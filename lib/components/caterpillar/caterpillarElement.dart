import 'dart:collection';

import 'package:caterpillar_crawl/components/caterpillar/caterpillar.dart';
import 'package:caterpillar_crawl/components/caterpillar/caterpillarSegment.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/caterpillar_data.dart';
import 'package:flame/components.dart';

class CaterpillarElement extends PositionComponent {
  CaterpillarSegment? nextSegment;
  CaterpillarData caterpillardata;
  CaterpillarCrawlMain gameWorld;

  double distToCollide = 20;

  Queue<MovementTransferData> angleQueue =
      Queue<MovementTransferData>(); // ListQueue() by default
  bool isInitializing = true;
  late int index;

  double secondCounter = 0;
  double timeSinceInit = 0;

  bool segemntAddRequest = false;
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

  void addCaterPillarSegment(CaterPillar caterpillar) {
    if (caterpillardata.maxElementCount <= index) {
      return;
    }
    nextSegment = CaterpillarSegment(caterpillardata, gameWorld,
        previousSegment: this, caterpillar: caterpillar);
    nextSegment?.position = position;
    gameWorld.world.add(nextSegment!);
    caterpillar.lastSegment = nextSegment;
    nextSegment?.previousSegment = this;
    nextSegment?.priority = priority - 1;
    nextSegment?.index = index + 1;
    caterpillar.segmentCount++;
    caterpillar.onChangePlayerPoints();
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
            gameWorld.groundMap.player.speedMultiplier);

    double stepsToReachDist = fixedDistToSegment / distPerFrame;
    return (stepsToReachDist).toInt();
  }

  void setMovementQueue(Queue<MovementTransferData> newMovementQueue) {
    angleQueue = newMovementQueue;
  }
}
