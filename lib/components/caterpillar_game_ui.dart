import 'package:caterpillar_crawl/main.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

///The body segments to be added behind the previous one (or the head)
class CaterpillarGameUI extends PositionComponent {
  late TextComponent? _segmentCounterText;
  late TextComponent? _enemykilledText;

  late TextPaint regularTextPaint;

  CaterpillarCrawlMain mainGame;

  late HudButtonComponent loadUpButton;
  late HudButtonComponent pewPewButton;

  CaterpillarGameUI({required this.mainGame, super.priority});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    super.priority = double.maxFinite.toInt();
    size = mainGame.size;

    double textLength = 250;

    createRegularTextStyle();
    _segmentCounterText = TextBoxComponent(
        position: Vector2(super.size.x - textLength / 2, 0),
        size: Vector2(textLength, 40),
        textRenderer: regularTextPaint,
        anchor: Anchor.topCenter,
        align: Anchor.topRight,
        text: "-1");
    add(_segmentCounterText!);

    _enemykilledText = TextBoxComponent(
        position: Vector2((super.size.x) - textLength / 2, 0 + 40),
        size: Vector2(textLength, 40),
        textRenderer: regularTextPaint,
        anchor: Anchor.topCenter,
        align: Anchor.topRight,
        text: "-1");
    add(_enemykilledText!);
    loadUpButton = caterpillarLoadUpButton();
    add(loadUpButton);
    pewPewButton = shootButton();
    add(pewPewButton);
  }

  void setSegmentCountUi(int segmentCount) {
    _segmentCounterText?.text = "Segments: " + segmentCount.toString();
  }

  void setEnemyKilledUi(int killCount) {
    _enemykilledText?.text = "Kills: " + killCount.toString();
  }

  void createRegularTextStyle() {
    regularTextPaint = TextPaint(
      style: TextStyle(
        fontSize: 24.0,
        color: BasicPalette.white.color,
      ),
    );
  }

  HudButtonComponent caterpillarLoadUpButton() {
    return HudButtonComponent(
        onPressed: () => onCaterPillarFatRoundButtonClick(),
        position: Vector2(30, 10),
        button: CreateCircleActionButton(30, BasicPalette.darkGreen.paint()));
  }

  HudButtonComponent shootButton() {
    return HudButtonComponent(
        onPressed: () => onPewPewButtonclicked(),
        position: Vector2(90, 10),
        button: CreateCircleActionButton(30, BasicPalette.blue.paint()));
  }

  CircleComponent CreateCircleActionButton(double radius, Paint color) {
    return CircleComponent(radius: radius, paint: color);
  }

  void onCaterPillarFatRoundButtonClick() {
    mainGame.onFatRounButtonClick();
  }

  void onPewPewButtonclicked() {
    mainGame.onPewPewButtonclicked();
  }

  void onCaterpillarCrawling() {
    // loadUpButton.button =
    //     CreateCircleActionButton(BasicPalette.darkGreen.paint());
  }

  void onCaterpillarReadyToEgg() {
    // loadUpButton.button.
    //     CreateCircleActionButton(BasicPalette.darkRed.paint());
  }
}
