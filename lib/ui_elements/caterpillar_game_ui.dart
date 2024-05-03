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
  late TextComponent _remainingEnemies;
  late TextComponent _levelText;

  late CaterpillarJoystick joystick;

  CaterpillarCrawlMain mainGame;
  int playerLifeCount;

  late HudButtonComponent loadUpButton;
  late HudButtonComponent pewPewButton;

  late LifeBar liveBar;

  CaterpillarGameUI(
      {required this.mainGame, required this.playerLifeCount, super.priority}) {
    joystick = CaterpillarJoystick(
      knob: CircleComponent(radius: 30, paint: BasicPalette.yellow.paint()),
      background:
          CircleComponent(radius: 80, paint: BasicPalette.green.paint()),
      margin: const EdgeInsets.only(left: 10, bottom: 10),
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    super.priority = double.maxFinite.toInt();
    size = Vector2(mainGame.size.y, mainGame.size.x);

    double textLength = 250;
    double textHeight = 20;

    _segmentCounterText = TextComponent(
        position: Vector2(size.x, 0),
        size: Vector2(textLength, textHeight + 8),
        textRenderer: createRegularTextStyle(Colors.white, textHeight - 4),
        anchor: Anchor.topRight,
        text: "Segments: 000");

    add(_segmentCounterText);

    _enemykilledText = TextComponent(
        position: Vector2(super.size.x, textHeight),
        size: Vector2(textLength, textHeight + 8),
        textRenderer: createRegularTextStyle(Colors.white, textHeight - 4),
        anchor: Anchor.topRight,
        text: "Kills: 000");

    add(_enemykilledText);

    _remainingEnemies = TextComponent(
        position: Vector2(super.size.x, textHeight * 2),
        size: Vector2(textLength, textHeight + 8),
        textRenderer: createRegularTextStyle(Colors.white, textHeight - 4),
        anchor: Anchor.topRight,
        text: "Remaining enem: 000");

    add(_remainingEnemies);

    _levelText = TextComponent(
        position: Vector2(super.size.x, textHeight * 3),
        size: Vector2(textLength, textHeight + 8),
        textRenderer: createRegularTextStyle(Colors.white, textHeight - 4),
        anchor: Anchor.topRight,
        text: "Level: 0");

    add(_levelText);

    PositionComponent buttonContainer = PositionComponent(
      size: Vector2(220, 120),
    );
    loadUpButton = caterpillarLoadUpButton();
    pewPewButton = shootButton();
    buttonContainer.add(loadUpButton);
    loadUpButton.position += Vector2(0, 50);
    buttonContainer.add(pewPewButton);

    AlignComponent leftControl = AlignComponent(
      child: joystick,
      alignment: Anchor.bottomLeft,
    );

    AlignComponent rightControl = AlignComponent(
      child: buttonContainer,
      alignment: Anchor.bottomRight,
    );

    add(leftControl);
    add(rightControl);

    liveBar = LifeBar(
        maxLifeCount: playerLifeCount,
        iconSize: 24,
        barPosition: Vector2(0, 30));
    add(liveBar);
  }

  void setSegmentCountUi(int segmentCount) {
    _segmentCounterText.text = "Segments: " + segmentCount.toString();
  }

  void setEnemyKilledUi(int killCount) {
    _enemykilledText.text = "Kills: " + killCount.toString();
  }

  void setRemainingEnemiesdUi(int enemyCount) {
    _remainingEnemies.text = "Remaining: $enemyCount";
  }

  void setLevelUp(int level) {
    _levelText.text = "Level: $level";
  }

  TextPaint createRegularTextStyle(Color color, double fontsize) {
    return TextPaint(
      style: TextStyle(
        fontSize: fontsize,
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

  void onLifeCountChanged(int lifeCount) {
    liveBar.setLiveCount(lifeCount);
  }
}

class LifeBar extends PositionComponent {
  int maxLifeCount;

  final String _heartIconSpritePath = "heartgreen_64.png";
  final String _emptyheartIconSpritePath = "heartempty_64.png";

  late Sprite fullHeart;
  late Sprite emptyHeart;

  double iconSize;
  Vector2 barPosition;
  List<SpriteComponent> lifeIcons = [];

  LifeBar(
      {required this.maxLifeCount,
      required this.iconSize,
      required this.barPosition});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2.all(iconSize);
    fullHeart = await Sprite.load(_heartIconSpritePath);
    // fullHeart.srcSize = Vector2.all(iconSize);
    emptyHeart = await Sprite.load(_emptyheartIconSpritePath);
    position = barPosition;
    anchor = Anchor.topLeft;
    initHealthStatus();
  }

  Future<void> initHealthStatus() async {
    for (int i = 0; i < maxLifeCount; i++) {
      SpriteComponent heartIcon = createLifeComponent(true);
      heartIcon.position = Vector2(i * iconSize, 0);
      add(heartIcon);
      lifeIcons.add(heartIcon);
    }
  }

  SpriteComponent createLifeComponent(bool isFullHeart) {
    Sprite sprite;
    sprite = isFullHeart ? fullHeart : emptyHeart;
    SpriteComponent spriteComponent =
        SpriteComponent(size: Vector2.all(iconSize), sprite: sprite);
    return spriteComponent;
  }

  void setLiveCount(int lifeCount) {
    int i = 0;
    for (SpriteComponent lifeIcon in lifeIcons) {
      lifeIcon.sprite = i < lifeCount ? fullHeart : emptyHeart;
      i++;
    }
  }
}
