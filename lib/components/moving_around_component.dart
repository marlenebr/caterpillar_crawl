import 'dart:math';

import 'package:caterpillar_crawl/components/map/ground_map.dart';
import 'package:caterpillar_crawl/models/moving_data.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';

class MovingAroundComponent extends PositionComponent {
  GroundMap map;
  MovingData movingdata;
  late double _fractionAngle;

  late Vector2 _lastPointPos;
  late double _goToAngle;
  double _baseAngle = 0;

  double timeToChangeRandomDirection = 8;
  double randomDirectionCounter = 0;

  double timeToRecoil = 2;
  double recoilCounter = 0;
  bool doRecoil = false;

  bool disAllowMoving = false;
  bool _moveToPlayer = false;

  MovingAroundComponent({required this.map, required this.movingdata}) {
    _fractionAngle = (2 * pi) / movingdata.angleSteps.toDouble();
    _goToAngle = _fractionAngle + angle;
  }
  @override
  Future<void> onLoad() async {
    super.onLoad();
    _baseAngle = angle;
    _goToAngle = _baseAngle + _fractionAngle;
  }

  @override
  Future<void> onMount() async {
    super.onMount();
    Vector2.copy(position);
    _lastPointPos = Vector2(position.x, position.y);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (disAllowMoving) {
      return;
    }
    if (updateRecoil(dt)) {
      return;
    }
    if (CaterpillarCrawlUtils.isOnOnMapEnd(this, map.size.x)) {
      doRecoil = true;
      print("DECOIL");
      return;
    }

    if (map.player.position.distanceTo(position) <
        movingdata.distToFollowPlayer) {
      _moveToPlayer = true;
    } else {
      _moveToPlayer = false;
    }

    if (!_moveToPlayer) {
      if (movingdata.movingStatus == MovingMode.walkInCircles) {
        updateWalkInCircles(dt);
      } else if (movingdata.movingStatus == MovingMode.moveRandom) {
        updateMoveRandom(dt);
      }
    } else {
      updateMoveToPlayer(dt);
    }
  }

  void updateMoveToPlayer(double dt) {
    //ROTATE TOWARDS
    Vector2 lookTo = map.player.position - position;
    double lookAngle = CaterpillarCrawlUtils.getAngleFromUp(-lookTo);
    if (movingdata.movingStatus == MovingMode.moveRandom) {
      CaterpillarCrawlUtils.updatePosition(
          dt, transform, movingdata.huntSpeed, lookAngle);
    } else {
      CaterpillarCrawlUtils.updatePosition(
          dt, transform, movingdata.huntSpeed, angle);
      CaterpillarCrawlUtils.updateLerpToAngle(
          dt, transform, lookAngle, movingdata.huntRotationSpeed);
    }
  }

  bool angleReached = false;

  void updateWalkInCircles(double dt) {
    if (!angleReached) {
      angleReached =
          CaterpillarCrawlUtils.updateLerpToAngle(dt, transform, _goToAngle, 2);
    } else {
      CaterpillarCrawlUtils.updatePosition(
          dt, transform, movingdata.baseSpeed, angle);
      if (position.distanceTo(_lastPointPos) >= 60) {
        _lastPointPos = Vector2(position.x, position.y);
        _baseAngle = angle;
        _goToAngle = (_baseAngle + _fractionAngle) % (2 * pi);
        angleReached = false;
      }
    }
  }

  bool updateRecoil(double dt) {
    if (!doRecoil) {
      return false;
    }
    recoilCounter += dt;
    if (recoilCounter > timeToRecoil) {
      recoilCounter = 0;
      doRecoil = false;
      _baseAngle = angle;
      return false;
    }
    lookAt(Vector2.all(0));
    CaterpillarCrawlUtils.updatePosition(
        dt, transform, movingdata.huntSpeed, angle);
    return true;
  }

  void updateMoveRandom(double dt) {
    randomDirectionCounter += dt;
    if (randomDirectionCounter > timeToChangeRandomDirection) {
      _goToAngle = CaterpillarCrawlUtils.getRandomAngle();
      randomDirectionCounter = 0;
    }
    CaterpillarCrawlUtils.updatePosition(
        dt, transform, movingdata.baseSpeed, _goToAngle);
  }
}
