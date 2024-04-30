import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/ui_elements/caterpillar_joystick.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/layout.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

///The body segments to be added behind the previous one (or the head)
class CaterpillarGameUI extends PositionComponent {
  late TextComponent _segmentCounterText;
  late TextComponent _enemykilledText;
  late TextComponent _collapseText;

  late CaterpillarJoystick joystick;

  CaterpillarCrawlMain mainGame;

  late HudButtonComponent loadUpButton;
  late HudButtonComponent pewPewButton;

  CaterpillarGameUI({required this.mainGame, super.priority}) {
    joystick = CaterpillarJoystick(
      knob: CircleComponent(radius: 20, paint: BasicPalette.yellow.paint()),
      background:
          CircleComponent(radius: 50, paint: BasicPalette.green.paint()),
      margin: const EdgeInsets.only(left: 10, bottom: 10),
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    super.priority = double.maxFinite.toInt();
    size = mainGame.size;

    double textLength = 250;
    double textHeight = 30;

    _segmentCounterText = TextComponent(
        position: Vector2(super.size.x, 0),
        size: Vector2(textLength, 40),
        textRenderer: createRegularTextStyle(Colors.white),
        anchor: Anchor.topRight,
        text: "Segments: 000");

    add(_segmentCounterText);

    _enemykilledText = TextComponent(
        position: Vector2(super.size.x, textHeight),
        size: Vector2(textLength, 40),
        textRenderer: createRegularTextStyle(Colors.white),
        anchor: Anchor.topRight,
        text: "Kills: 000");

    add(_enemykilledText);

    _collapseText = TextComponent(
        position: Vector2(super.size.x, textHeight * 2),
        size: Vector2(textLength, 40),
        textRenderer: createRegularTextStyle(Colors.white),
        anchor: Anchor.topRight,
        text: "Eat and Grow");

    add(_collapseText);

    PositionComponent buttonContainer = PositionComponent(
      size: Vector2(400, 50),
    );
    loadUpButton = caterpillarLoadUpButton();
    pewPewButton = shootButton();
    buttonContainer.add(joystick);
    buttonContainer.add(loadUpButton);
    buttonContainer.add(pewPewButton);

    AlignComponent buttonAlign = AlignComponent(
      child: buttonContainer,
      alignment: Anchor.bottomLeft,
    );

    add(buttonAlign);
  }

  void setSegmentCountUi(int segmentCount) {
    _segmentCounterText?.text = "Segments: " + segmentCount.toString();
    if (segmentCount > mainGame.groundMap.player.lengthToCollapse - 10) {
      _collapseText.textRenderer = createRegularTextStyle(Colors.red);
      _collapseText.text =
          "Collapse on ${mainGame.groundMap.player.lengthToCollapse - segmentCount} more Snacks";
    } else if (segmentCount <=
        mainGame.groundMap.player.lengthToCollapse - 10) {
      _segmentCounterText!.textRenderer = createRegularTextStyle(Colors.white);
      _collapseText.text = "Eat and Grow";
    }
  }

  void setEnemyKilledUi(int killCount) {
    _enemykilledText?.text = "Kills: " + killCount.toString();
  }

  TextPaint createRegularTextStyle(Color color) {
    return TextPaint(
      style: TextStyle(
        fontSize: 24.0,
        color: color,
      ),
    );
  }

  HudButtonComponent caterpillarLoadUpButton() {
    return HudButtonComponent(
        onPressed: () => onCaterPillarFatRoundButtonClick(),
        position: Vector2(100, 0),
        button: CreateCircleActionButton(30, BasicPalette.darkGreen.paint()));
  }

  HudButtonComponent shootButton() {
    return HudButtonComponent(
        onPressed: () => onPewPewButtonclicked(),
        position: Vector2(160, 0),
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
