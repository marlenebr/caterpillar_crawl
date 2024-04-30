import 'dart:async';

import 'package:caterpillar_crawl/components/caterpillar/caterpillar.dart';
import 'package:caterpillar_crawl/components/caterpillar_game_ui.dart';
import 'package:caterpillar_crawl/components/groundMap.dart';
import 'package:caterpillar_crawl/models/caterpillar_data.dart';
import 'package:caterpillar_crawl/ui_elements/caterpillar_joystick.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

final Images imageLoader = Images();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  runApp(GameWidget(
    game: CaterpillarCrawlMain(),
  ));
}

class CaterpillarCrawlMain extends FlameGame
    with TapCallbacks, HasCollisionDetection {
  late CaterPillar _caterPillar;
  late GroundMap groundMap;
  late CaterpillarGameUI _gameUI;

  double angleToLerpTo = 0;
  double rotationSpeed = 5;
  int snackCount = 400;
  int enemyCount = 60;

  double mapSize = 2000;
  CaterpillarCrawlMain();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    world = World();
    add(FpsTextComponent());
    _gameUI = CaterpillarGameUI(mainGame: this);
    add(_gameUI);
    createAndAddCaterillar(mapSize, _gameUI.joystick);
    camera.viewfinder.zoom = 1;
    camera.follow(_caterPillar);
    debugMode = false;
    if (debugMode) {
      print("DEBUG IS ON");
    }
    world.debugMode = debugMode;
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPaint(Paint()..color = Color.fromARGB(255, 120, 155, 117));
    super.render(canvas);
  }

  void zoomOut() {
    final effect = ScaleEffect.by(
      camera.viewfinder.transform.scale * 0.9,
      EffectController(duration: 0.6),
    );
    camera.viewfinder.add(effect);
  }

  // @override
  // void onTapDown(TapDownEvent event) {
  //   moveCaterpillarOnTap(event.localPosition);
  // }

  // void moveCaterpillarOnTap(Vector2 tapPosition) {
  //   Vector2 tapDirection = size / 2 - tapPosition;
  //   _caterPillar.onMoveDirectionChange(tapDirection);
  // }

  void createAndAddCaterillar(double mapSiz, CaterpillarJoystick joystick) {
    CaterpillarData mainPlayerCaterpillar =
        CaterpillarData.createCaterpillarData();
    _caterPillar = CaterPillar(
        mainPlayerCaterpillar, this, rotationSpeed, _gameUI.joystick);
    _caterPillar.transform.position = Vector2.all(mapSize) - Vector2(50, 50);

    groundMap = GroundMap(
        mapSize: mapSize,
        player: _caterPillar,
        world: this,
        snackCount: snackCount,
        enemyCount: enemyCount);
    world.add(groundMap);
    world.add(_caterPillar);
    //spawnEnemy();
  }

  // void spawnEnemy() {
  //   print("Spawn enemy");
  //   EnemyData enemyCaterpillar = EnemyData.createEnemeyData();
  //   Enemy _enemy = Enemy(enemyData: enemyCaterpillar);
  //   world.add(_enemy);
  //   groundMap.addEnemy(_enemy);

  //   if (groundMap.enemyIndexer > 4) {
  //     _interval.stop();
  //   }
  // }

  void onFatRounButtonClick() {
    _caterPillar.onFatRoundButtonClick();
  }

  void onPewPewButtonclicked() {
    _caterPillar.onPewPew();
  }

  void onSegmentAddedToPlayer(int segmentCount) {
    _gameUI.setSegmentCountUi(segmentCount);
  }

  void onEnemyKilled(int enemyKilled) {
    _gameUI.setEnemyKilledUi(enemyKilled);
  }

  void onCaterPillarReadyToEgg() {
    _gameUI.onCaterpillarReadyToEgg();
  }
}
