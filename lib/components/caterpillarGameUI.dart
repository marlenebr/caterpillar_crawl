import 'package:caterpillar_crawl/main.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

///The body segments to be added behind the previous one (or the head)
class CaterpillarGameUI extends PositionComponent
{

  late TextComponent? _segmentCounterText;
  late TextComponent? _enemySegmentCounterText;

  late TextPaint regularTextPaint;

  CaterpillarCrawlMain mainGame;

  late HudButtonComponent loadUpButton;

  CaterpillarGameUI({required this.mainGame, super.priority});

   @override
  Future<void> onLoad() async {
    await super.onLoad();  
    super.priority = double.maxFinite.toInt();
    size = mainGame.size;

    double textLength = 250;

    createRegularTextStyle();
    _segmentCounterText  = TextBoxComponent(
      position: Vector2(super.size.x - textLength/2,0),
      size: Vector2(textLength,40),
      textRenderer: regularTextPaint,
      anchor: Anchor.topCenter,
      align: Anchor.topRight,
      text: "-1");
    add(_segmentCounterText!);

      _enemySegmentCounterText  = TextBoxComponent(
      position: Vector2((super.size.x) - textLength/2,0 +40),
      size: Vector2(textLength,40),
      textRenderer: regularTextPaint,
      anchor: Anchor.topCenter,
      align: Anchor.topRight,
      text: "-1");
    add(_enemySegmentCounterText!);
    loadUpButton  =caterpillarLoadUpButton();
    add(loadUpButton);
  }

  void setSegmentCountUi(int segmentCount)
  {
    _segmentCounterText?.text = "Player: " + segmentCount.toString();
  }

    void setEnemySegmentCountUi(int segmentCount)
  {
    _enemySegmentCounterText?.text = "Enemy: " + segmentCount.toString();
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

  HudButtonComponent caterpillarLoadUpButton()
  {
    return HudButtonComponent(
      onPressed: ()  => OnCaterPillarFatRoundButtonClick(),
      button: CreateCircleLoadUpButton(BasicPalette.darkGreen.paint())
  );
  }

  CircleComponent CreateCircleLoadUpButton(Paint color)
  {
    return CircleComponent(
        radius: 50, 
        position: Vector2.all(70), 
        anchor: Anchor.center, 
        paint:color);
  }
  
  void OnCaterPillarFatRoundButtonClick()
  {
        print('Fat Round Button');
        mainGame.onFatRounButtonClick();

  }

  void OnCaterpillarCrawling()
  {
    loadUpButton.button = CreateCircleLoadUpButton(BasicPalette.darkGreen.paint());
  }

    void OnCaterpillarReadyToEgg()
  {
    loadUpButton.button = CreateCircleLoadUpButton(BasicPalette.darkRed.paint());  
  }

}