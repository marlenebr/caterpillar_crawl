import 'dart:async';

import 'package:caterpillar_crawl/components/caterpillar.dart';
import 'package:caterpillar_crawl/components/caterpillarGameUI.dart';
import 'package:caterpillar_crawl/components/groundMap.dart';
import 'package:caterpillar_crawl/models/caterpillarData.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';


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
  late CaterpillarGameUI _gameUI;

  double angleToLerpTo = 0;
  double rotationSpeed = 2;
  double movingSpeed = 120;
  double travelTimePerSegment = 0;
  // Vector2 caterpillarSize = Vector2(32,128);
  // Vector2 caterpillarSegmentSize = Vector2(32,128);

  //value between 0 and 1 - more higher is more accurate but the segment distance to another is lower
  //eg. ist needs mor segments for a longer caterpillar
  double accuracy = 0.45;

  CaterpillarCrawlMain();


  @override
  Future<void> onLoad() async {
    await super.onLoad();  
    world = World();
    add(FpsTextComponent());
    _gameUI = CaterpillarGameUI(mainGame: this);
    add(_gameUI);
    createAndAddCaterillar(2000);
    camera.viewfinder.zoom = 1;
    camera.follow(_caterPillar);
    debugMode = false;
    if(debugMode)
    {
      print("DEBUG IS ON");
    }
  }  

  @override
  void update(double dt) {
    // TODO: implement update
    super.update(dt);

  }

  @override
  void render(Canvas canvas) {
    canvas.drawPaint(Paint()..color = Color.fromARGB(255, 120, 155, 117));
    super.render(canvas);
  }

  @override
  void onTapDown(TapDownEvent event) {
    moveCaterpillarOnTap(event.localPosition);
  }

  double _calcTimeForSegmentTravel(double distance, double speed)
  {
    return distance/speed;
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
        finalSize: Vector2(64,64)
),
      finalSize: Vector2(64,64)
    );
  }

  void createAndAddCaterillar(double mapSize)
  {
    CaterpillarData mainPlayerCaterpillar = createCaterpillarData();
    double refinedSegmentDistance = mainPlayerCaterpillar.caterpillarSegment.finalSize.y *accuracy; //segments are overlapping a bit - depent on the desing another value could be better
    travelTimePerSegment = _calcTimeForSegmentTravel(refinedSegmentDistance,movingSpeed);
    print("time for segment: $travelTimePerSegment");
    _caterPillar = CaterPillar(mainPlayerCaterpillar,this,rotationSpeed,movingSpeed,travelTimePerSegment);
    _caterPillar.transform.position = Vector2(40,100);

    _groundMap = GroundMap(mapSize, _caterPillar,world);
    world.add(_groundMap);
    world.add(_caterPillar);
    //world.priority =100;
  }

  void onSegmentAddedToPlayer(int segmentCount)
  {
      _gameUI.setSegmentCountUi(segmentCount);
  }
}