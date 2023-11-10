import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillar.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/caterpillarData.dart';
import 'package:flame/components.dart';

///The body segments to be added behind the previous one (or the head)
class CaterpillarSegment extends CaterpillarElement
{
  CaterPillar caterpillar;
  CaterpillarElement previousSegment;
  late int index;

  CaterpillarSegment(super.finalSize, super.caterpillardata, super.gameWorld, {required this.previousSegment, required this.caterpillar});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = previousSegment.size;
    final double anchorPosY = (caterpillardata.caterpillarSegment.anchorPosYTop/caterpillardata.caterpillarSegment.spriteSize.y);
    anchor = Anchor(0.5,anchorPosY);
    index = caterpillar.snackCount;
    addSegmentSprite();
    //DEBUG
    //add(FlameGameUtils.debugDrawAnchor(this)); 
  }

  @override
  void update(double dt) {
    super.update(dt); 
    initSegment();
    updateAngleQueue();
  }

  void initSegment()
  {
    if(isInitializing && angleQueue.length >= previousSegment.angleQueue.length)
    {
      isInitializing =false;
      print("init of segment done $index");
      if(segemntAddRequest)
      {
        addCaterPillarSegment(caterpillar);
      }
    }
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
        scale: Vector2.all(finalSize/caterpillardata.caterpillarSegment.spriteSize.x)

      );
    add(animation);
  }

  void updateAngleQueue()
  {
    angleQueue.addFirst(MovementTransferData(angle: angle, position: absolutePositionOfAnchor(anchor)));
    if(!isInitializing)
    {
      nextSegment?.angle = angleQueue.last.angle;
      nextSegment?.position  = angleQueue.last.position;
      angleQueue.removeLast();
    }
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
