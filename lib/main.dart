import 'dart:async';

import 'package:caterpillar_crawl/components/caterpillar.dart';
import 'package:caterpillar_crawl/components/groundMap.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  runApp(
    GameWidget(
      game: CaterpillarCrawlMain(),
    )
  );
}

class CaterPillarWorld extends World
{
  @override
  FutureOr<void> onLoad() async {
    // Load all the assets that are needed in this world
    // and add components etc.
  }
}

class CaterpillarCrawlMain extends FlameGame with TapCallbacks, HasCollisionDetection  {

  late CaterPillar _caterPillar;
  late GroundMap _groundMap;
  double rotationDuration = 3.2;
  double angleToLerpTo = 0;
  double speed = 3;
  
  CaterpillarCrawlMain();


  @override
  Future<void> onLoad() async {
    await super.onLoad();   
    _caterPillar = CaterPillar(speed,60);
    _groundMap = GroundMap(1000, _caterPillar);
    _caterPillar.transform.position = Vector2(40,100);
    
    world.add(_groundMap);
    world.add(_caterPillar);
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

}