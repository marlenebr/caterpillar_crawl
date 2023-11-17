import 'package:caterpillar_crawl/main.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

///The body segments to be added behind the previous one (or the head)
class CaterpillarGameUI extends PositionComponent
{

  late TextComponent? _segmentCounterText;

  late TextPaint regularTextPaint;

  CaterpillarCrawlMain mainGame;

  CaterpillarGameUI({required this.mainGame, super.priority});

   @override
  Future<void> onLoad() async {
    await super.onLoad();  
    super.priority = double.maxFinite.toInt();
    size = mainGame.size;

    double textLength = 150;

    createRegularTextStyle();
    _segmentCounterText  = TextBoxComponent(
      position: Vector2(super.size.x - textLength/2,0),
      size: Vector2(textLength,40),
      textRenderer: regularTextPaint,
      anchor: Anchor.topCenter,
      align: Anchor.topRight,
      text: "-1");
    add(_segmentCounterText!);
  }

  void setSegmentCountUi(int segmentCount)
  {
    _segmentCounterText?.text = "Len: " + segmentCount.toString();
  }

  void createRegularTextStyle()
  {
    regularTextPaint = TextPaint(
        style: TextStyle(
          fontSize: 24.0,
          color: BasicPalette.white.color,
        ),
      );
  }

}