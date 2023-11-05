import 'dart:async';

import 'package:caterpillar_crawl/components/caterpillar.dart';
import 'package:caterpillar_crawl/components/groundMap.dart';
import 'package:caterpillar_crawl/models/caterpillarData.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


final Images imageLoader = Images();

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  runApp(
    GameWidget(
      game: CaterpillarCrawlMain(),
    )
  );
}

// class CaterPillarWorld extends World
// {
//   @override
//   FutureOr<void> onLoad() async {
//     // Load all the assets that are needed in this world
//     // and add components etc.
//   }
// }

class CaterpillarCrawlMain extends Forge2DGame with TapCallbacks, HasCollisionDetection  {

  late CaterPillar _caterPillar;
  late GroundMap _groundMap;
  double rotationDuration = 3.2;
  double angleToLerpTo = 0;
  double speed = 3;
  
  CaterpillarCrawlMain();


  @override
  Future<void> onLoad() async {
    await super.onLoad();   
    createAndAddCaterillar();
    camera.viewfinder.zoom = 1;
    camera.follow(_caterPillar);
  }  

  @override
  void update(double dt) {
    // TODO: implement update
    super.update(dt);

  }

  @override
  void render(Canvas canvas) {
    canvas.drawPaint(Paint()..color = Colors.orange.shade700);
    super.render(canvas);
  }

  @override
  void onTapDown(TapDownEvent event) {
    moveCaterpillarOnTap(event.localPosition);
  }

  void moveCaterpillarOnTap(Vector2 tapPosition)
  {
        Vector2 tapDirection = size/2 - tapPosition;
        _caterPillar.onMoveDirectionChange(tapDirection);
  }

  CaterpillarData createCaterpillarData()
  {
    //Data for first Caterpillar - Green Wobbly
    return  CaterpillarData(
      imagePath: 'caterPillar_head.png', 
      spriteSize: Vector2.all(128), 
      anchorPosY: 106, 
      caterpillarSegment: 
      CaterpillarSegmentData(
        imagePath: 'caterPillar_segment.png', 
        spriteSize: Vector2.all(128), 
        anchorPosYTop: 35,
        anchorPosYBottom: 100)
    );
  }

  void createAndAddCaterillar()
  {
    _caterPillar = CaterPillar(speed,60,createCaterpillarData(),world);
    _caterPillar.transform.position = Vector2(40,100);

    _groundMap = GroundMap(1000, _caterPillar);
    world.add(_groundMap);
    world.add(_caterPillar);
  }
}