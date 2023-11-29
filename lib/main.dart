import 'dart:async';
import 'dart:math';

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
  late Timer _interval;


  double angleToLerpTo = 0;
  double rotationSpeed = 2;
  int snackCount = 5800;
  double mapSize = 2000;
  bool usingIsolates = false;

  CaterpillarCrawlMain();


  @override
  Future<void> onLoad() async {
    await super.onLoad();  
    world = World();
    add(FpsTextComponent());
    _gameUI = CaterpillarGameUI(mainGame: this);
    add(_gameUI);
    createAndAddCaterillar(mapSize);
    camera.viewfinder.zoom = 1;
    camera.follow(_caterPillar);
    debugMode = false;
    if(debugMode)
    {
      print("DEBUG IS ON");
    }
    //  _interval = Timer(6, repeat: true, onTick: spawnEnemy)
    //   ..start();
  }  

  @override
  void update(double dt) {
    // TODO: implement update
    //_interval.update(dt);
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
      movingspeed: 120,
      refinedSegmentDistance: 0.45,
      animationSprites: 4,
      caterpillarSegment: 
      CaterpillarSegmentData(
        imagePath: 'segment_single64.png',
        spriteSize: Vector2.all(64),
        finalSize: Vector2(64,64)
),
      finalSize: Vector2(64,64)
    );
  }

    CaterpillarData createEnemyData()
  {
    //Data for enemy Caterpillar - Orange horned
    return  CaterpillarData(
      imagePath: 'enemy_head_anim.png', 
      spriteSize: Vector2.all(128), 
      anchorPosY: 106, 
      movingspeed: 60,
      refinedSegmentDistance: 0.3,
      animationSprites: 3,
      caterpillarSegment: 
      CaterpillarSegmentData(
        imagePath: 'enemy_segment.png',
        spriteSize: Vector2.all(128),
        finalSize: Vector2(64,64)
),
      finalSize: Vector2(64,64)
    );
  }

  void createAndAddCaterillar(double mapSize)
  {
    CaterpillarData mainPlayerCaterpillar = createCaterpillarData();
    _caterPillar = CaterPillar(mainPlayerCaterpillar, this,rotationSpeed);
    _caterPillar.transform.position = Vector2.all(mapSize) - Vector2(50,50);

    _groundMap = GroundMap(mapSize, _caterPillar,this,snackCount);
    world.add(_groundMap);
    world.add(_caterPillar);
    //spawnEnemy();
  }

  void spawnEnemy()
  {
    print("Spawn enemy");
    CaterpillarData enemyCaterpillar = createEnemyData();
    CaterPillar _enemy = CaterPillar(enemyCaterpillar, this,rotationSpeed);
     world.add(_enemy);
    _groundMap.addEnemy(_enemy);

    if(_groundMap.enemyIndexer > 4)
    {
      _interval.stop();
    }
  }

  void onSegmentAddedToPlayer(int segmentCount)
  {
      _gameUI.setSegmentCountUi(segmentCount);
  }

    void onSegmentAddedToEnemy(int segmentCount)
  {
      _gameUI.setEnemySegmentCountUi(segmentCount);
  }
}