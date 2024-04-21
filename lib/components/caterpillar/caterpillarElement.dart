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

  Queue<MovementTransferData> angleQueue =
      Queue<MovementTransferData>(); // ListQueue() by default
  bool isInitializing = true;
  late int index;

  double secondCounter = 0;
  double timeSinceInit = 0;

  bool segemntAddRequest = false;
  late Vector2 finalSize;

  Vector2 orientation = Vector2.zero();
  double velocity = 1;
  double speedMultiplier = 0.5;

  late double fixedDistToSegment;
  late Vector2 initPosition;

  CaterpillarElement(this.caterpillardata, this.gameWorld);

  @override
  void update(double dt) {
    super.update(dt);
    velocity = dt * caterpillardata.movingspeed;

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
    return;
  }

  void updateAngleQueue(int fixIterations, int entriesNeeded) {
    angleQueue.addFirst(MovementTransferData(
        orientation: orientation,
        position: absolutePositionOfAnchor(anchor),
        angle: angle));
    correctListLength(fixIterations, entriesNeeded);

    if (nextSegment != null) {
      nextSegment?.angle = angleQueue.last.angle;
      nextSegment?.position = angleQueue.last.position;
      nextSegment?.updateAngleQueue(fixIterations, entriesNeeded);
    }
  }

  void correctListLength(int fixIt, int entriesNeeded) {
    for (int i = 0; i < fixIt; i++) {
      if (angleQueue.length > entriesNeeded + 1) {
        // for(int i = debugLeN; i >entriesNeeded; i--)
        // {
        angleQueue.removeLast();
        //}
      } else {
        return;
      }
    }
  }

  void initSegment() {
    if (isInitializing &&
        initPosition.distanceTo(position) > fixedDistToSegment) {
      //kommt einmal vor
      isInitializing = false;
      // print("init of segment done $index");
    }
  }

  //the size the queue has to be right now
  int calcSteptToReachDistance(double dt) {
    double finalTimeInSec =
        fixedDistToSegment / (caterpillardata.movingspeed * speedMultiplier);
    if (dt == 0) {
      return 0;
    }
    double fps = 1 / dt;
    return (finalTimeInSec * fps).toInt();
  }

  void setMovementQueue(Queue<MovementTransferData> newMovementQueue) {
    angleQueue = newMovementQueue;
  }
}
