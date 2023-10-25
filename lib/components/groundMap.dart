import 'package:caterpillar_crawl/components/caterpillar.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GroundMap extends SpriteComponent
{

  double mapSize;
  CaterPillar player;

  GroundMap(this.mapSize, this.player) : super(size: Vector2.all(mapSize));


  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('BackgroundTile.png');
    anchor = Anchor.center;
    player.transform.position = Vector2.all(0);

  }

    @override
  void update(double dt) {    
    super.update(dt);
    resetPlayerOnMapEnd();
  }

  @override
  void render(Canvas canvas) {
    // TODO: implement render
    canvas.drawPaint(Paint()..color = Color.fromARGB(255, 158, 179, 139));
    super.render(canvas);

  }

  void resetPlayerOnMapEnd()
  {
    if(player.transform.position.x.abs() >mapSize/2 || player.transform.position.y.abs() >mapSize/2)
    {
      player.transform.position = Vector2.all(0);
    }
  }

}