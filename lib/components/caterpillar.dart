import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillarSegment.dart';
import 'package:caterpillar_crawl/components/snack.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/caterpillarData.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class CaterpillarBody extends BodyComponent  
{
  CaterpillarBody();

  @override
  Future<void> onLoad() async { 
    super.onLoad();
    bodyDef = BodyDef(
        type: BodyType.kinematic);

    renderBody = true;
    debugMode = true;
  }
}

class CaterPillar extends PositionComponent with CollisionCallbacks
{
  static const double fullCircle = 2*pi;

  late double initRotation;
  double rotationSpeed;
  double movingSpeed;
  double finalSize;

  CaterpillarData caterpillardata;
  Forge2DWorld gameWorld;

  late double angleToLerpTo;
  late Vector2 directionPoint;
  late Vector2 velocity;
  late double scaledAnchorYPos;

  late CaterpillarSegment nextSegment;


  int snackCount = 0;


  CaterPillar(this.rotationSpeed, this.movingSpeed, this.caterpillardata, this.gameWorld, this.finalSize);

  @override
  Future<void> onLoad() async {
    //scale = Vector2.all(finalSize/caterpillardata.spriteSize.x);
    size = Vector2.all(finalSize);
    debugMode = true;
    final data = SpriteAnimationData.sequenced(
    textureSize: caterpillardata.spriteSize,
    amount: 4,
    stepTime: 0.1,
    );
    final animation = SpriteAnimationComponent.fromFrameData(
      await imageLoader.load(caterpillardata.imagePath),
      data,
      scale: Vector2.all(finalSize/caterpillardata.spriteSize.x)
    );
    add(animation);

    final double anchorPos = (caterpillardata.anchorPosY/caterpillardata.spriteSize.y);
    //scaledAnchorYPos = anchorPos *scale.y;

    anchor = Anchor(0.5,anchorPos);
    initRotation = angle;
    angleToLerpTo = angle;
    directionPoint  = Vector2(0, 0);
    velocity = Vector2(0, 0);
    add(RectangleHitbox());
    addCaterPillarSegment();

    //DEBUG
    add(FlameGameUtils.debugDrawAnchor(this));

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

    nextSegment.angle = -angle;
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
      snackCount++;
      print('snacks eaten!: -> $snackCount');     
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
    velocity = direction * dt  *movingSpeed;
    position += velocity;
  }

  void addCaterPillarSegment()
  {
    nextSegment = CaterpillarSegment(segmentData: caterpillardata.caterpillarSegment, gameWorld: gameWorld,previousSegment: this, finalSize: finalSize);
    add(nextSegment);
    setChildToAnchorPosition(nextSegment);
  }
}