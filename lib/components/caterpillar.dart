import 'dart:math';

import 'package:caterpillar_crawl/components/snack.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class CaterPillar extends SpriteComponent with CollisionCallbacks
{
  static const double fullCircle = 2*pi;

  late double initRotation;
  double rotationSpeed;
  double movingSpeed;

  late double angleToLerpTo;
  late Vector2 directionPoint;


  CaterPillar(this.rotationSpeed, this.movingSpeed) : super(size: Vector2.all(32));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('TestBug.png');
    anchor = Anchor.center;
    initRotation = angle;
    angleToLerpTo = angle;
    directionPoint  = Vector2(0, 0);
    add(RectangleHitbox());

  }

  @override
  void update(double dt) {
    super.update(dt);

    updateLerpToAngle(dt);
    updateMoveOn(dt);

    angle = angle%(fullCircle);
    if(angle <0)
    {
      angle = fullCircle+(angle%(fullCircle));
    }
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    position = gameSize / 2;
  }

@override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points,other);

    if (other is Snack) {
      print('snack!: -> $other');     
    }
  }

  void updateLerpToAngle(double dt)
  {
    double diff = transform.angle - angleToLerpTo;
    if(diff.abs() < 0.1)
    {
      transform.angle = angleToLerpTo;
      initRotation  = angleToLerpTo;
      return;
    }
    int direction = 1;
    if((diff>0  && diff<pi) || diff<-pi)
    {
      direction = -1;
    }

    double lerpSpeedDt = dt*rotationSpeed*direction;
    transform.angle += lerpSpeedDt;   
  }

  void onMoveDirectionChange(Vector2 pointToMoveTo)
  {
    angleToLerpTo = FlameGameUtils.getAngleFromUp(pointToMoveTo);
  }

  void updateMoveOn(double dt)
  { 
    //based on rotation implementation but without the x part (start calculate from up vector where x is 0)
    Vector2 direction = Vector2( 1 * sin(angle), -1 * cos(angle)).normalized();
    position += direction * dt  *movingSpeed;
  }
}