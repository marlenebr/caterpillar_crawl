import 'dart:math';

import 'package:caterpillar_crawl/components/enemy/enemy.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/utils/utils.dart';
import 'package:flame/components.dart';

class Pellet extends SpriteComponent {
  CaterpillarCrawlMain gameWorld;
  double shootingSpeed;
  double forwardAngle;
  double lifeTime;
  late SpriteAnimation _pelletAnimation;

  Pellet(
      {required this.gameWorld,
      required this.shootingSpeed,
      required this.forwardAngle,
      required this.lifeTime});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    int randomInt = Random().nextInt(2) + 1;
    sprite = await Sprite.load("snack00$randomInt.png");
    anchor = Anchor.center;
    priority = 1000;
    size = Vector2.all(16);
  }

  @override
  void update(double dt) {
    CaterpillarCrawlUtils.updatePosition(
        dt, transform, shootingSpeed, forwardAngle);
    lifeTime -= dt;
    updateAllEnemies();
    if (lifeTime < 0) {
      removeFromParent();
      // remove(this);
      return;
    }
  }

  void updateAllEnemies() {
    for (Enemy enemy in gameWorld.groundMap.enemies.values) {
      if (enemy.position.distanceTo(position) < 20) {
        enemy.onEnemyHit(1, false);
        return;
      }
    }
  }
}
