import 'dart:async';

import 'package:caterpillar_crawl/components/caterpillar.dart';
import 'package:caterpillar_crawl/components/groundMap.dart';
import 'package:caterpillar_crawl/models/caterpillarData.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
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

class CaterpillarCrawlMain extends FlameGame with TapCallbacks, HasCollisionDetection {

  late CaterPillar _caterPillar;
  late GroundMap _groundMap;
  double angleToLerpTo = 0;
  double rotationSpeed = 2;
  double movingSpeed = 80;

  CaterpillarCrawlMain();


  @override
  Future<void> onLoad() async {
    await super.onLoad();  
    add(FpsTextComponent());
    createAndAddCaterillar(5000);
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
        imagePath: 'segment_single64.png',
        spriteSize: Vector2.all(64), 
        anchorPosYTop: 35,
        anchorPosYBottom: 100)
    );
  }

  void createAndAddCaterillar(double mapSize)
  {
    _caterPillar = CaterPillar(64,createCaterpillarData(),world,rotationSpeed,movingSpeed);
    _caterPillar.transform.position = Vector2(40,100);

    _groundMap = GroundMap(mapSize, _caterPillar,world);
    world.add(_groundMap);
    world.add(_caterPillar);

    // initializeCollisionDetection(
    //   mapDimensions: Rect.fromLTWH(0, 0, mapSize, mapSize),
    //   minimumDistance: 10,
    // );
  }
}