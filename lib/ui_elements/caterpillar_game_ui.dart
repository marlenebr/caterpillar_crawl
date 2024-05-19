import 'package:caterpillar_crawl/main.dart';
import 'package:flame/components.dart';

class CaterpillarGameUI extends PositionComponent {
  CaterpillarCrawlMain mainGame;
  int playerLifeCount;

  late LifeBar liveBar;

  String innerJoystickSpritePath = "joystick_inner_128.png";
  String outerJoystickSpritePath = "joystick_outer_128.png";

  CaterpillarGameUI(
      {required this.mainGame, required this.playerLifeCount, super.priority});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    super.priority = double.maxFinite.toInt();
    size = Vector2(mainGame.size.y, mainGame.size.x);

    liveBar = LifeBar(
        maxLifeCount: playerLifeCount,
        iconSize: 24,
        barPosition: Vector2(0, 30));
    add(liveBar);
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
