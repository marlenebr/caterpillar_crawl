import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillar.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:flame/components.dart';

///The body segments to be added behind the previous one (or the head)
class CaterpillarSegment extends CaterpillarElement
{
  CaterPillar caterpillar;
  CaterpillarElement previousSegment;
  late int index;


  CaterpillarSegment(super.caterpillardata, super.gameWorld, {required this.previousSegment, required this.caterpillar});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    finalSize = caterpillardata.caterpillarSegment.finalSize;
    size = previousSegment.size;
    anchor = Anchor(0.5,0.5);
    addSegmentSprite2();

  }

  @override
  void update(double dt) {
    super.update(dt); 
    initSegment();
  }
  

  Future<void> addSegmentSprite()
  async {
    final data = SpriteAnimationData.sequenced(
    textureSize: caterpillardata.caterpillarSegment.spriteSize,
    amount: 4,
    stepTime: 0.1,
    );

    animation = SpriteAnimationComponent.fromFrameData(
        await imageLoader.load(caterpillardata.caterpillarSegment.imagePath),
        data,
        scale: Vector2(finalSize.x/caterpillardata.caterpillarSegment.spriteSize.x,
        finalSize.y/caterpillardata.caterpillarSegment.spriteSize.y)
      );
    add(animation);
  }

  Future<void> addSegmentSprite2()
  async {
    Sprite segmentSprite = await Sprite.load(caterpillardata.caterpillarSegment.imagePath);
    SpriteComponent spritecomp = SpriteComponent(
      sprite: segmentSprite, 
      scale:Vector2(finalSize.x/caterpillardata.caterpillarSegment.spriteSize.x,
      finalSize.y/caterpillardata.caterpillarSegment.spriteSize.y)
      );
    add(spritecomp);
  }

  void updateLerpToAngle(double dt, double angleToLerpTo, double rotationSpeed)
  {
    double diff = transform.angle - angleToLerpTo;
    if(diff.abs() < 0.1)
    {
      transform.angle = angleToLerpTo;
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

  updateApplySpeedUp()
  {
    position += orientation * speedMultiplier;
  }

  void addCaterpillarSegemntRequest()
  {
    if(!isInitializing)
    {
      addCaterPillarSegment(caterpillar);
    }
    else
    {
      segemntAddRequest  =true;
    }
  }

}
