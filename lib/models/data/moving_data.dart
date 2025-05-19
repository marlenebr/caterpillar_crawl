class MovingData {
  double baseSpeed;
  double huntSpeed;
  double baseRotationSpeed;
  double huntRotationSpeed;
  int angleSteps;
  double distToFollowPlayer;
  MovingMode movingStatus;

  MovingData(
      {required this.baseSpeed,
      required this.huntSpeed,
      required this.baseRotationSpeed,
      required this.huntRotationSpeed,
      required this.angleSteps,
      required this.distToFollowPlayer,
      required this.movingStatus});

  static MovingData createenemyMovingData() {
    return MovingData(
        baseSpeed: 0.3,
        huntSpeed: 0.8,
        baseRotationSpeed: 4,
        huntRotationSpeed: 8,
        angleSteps: 3,
        distToFollowPlayer: 120,
        movingStatus: MovingMode.walkInCircles);
  }

  static MovingData createItemMovingdata() {
    return MovingData(
        baseSpeed: 0.2,
        huntSpeed: 2,
        baseRotationSpeed: 4,
        huntRotationSpeed: 12,
        angleSteps: 3,
        distToFollowPlayer: 75,
        movingStatus: MovingMode.moveRandom);
  }
}

enum MovingMode { walkInCircles, moveRandom }
