import 'dart:async';

import 'package:caterpillar_crawl/components/caterpillar/caterpillar.dart';
import 'package:caterpillar_crawl/components/player_controller.dart';
import 'package:caterpillar_crawl/models/view_models/caterpillar_state_model.dart';
import 'package:caterpillar_crawl/ui_elements/caterpillar_game_ui.dart';
import 'package:caterpillar_crawl/components/map/ground_map.dart';
import 'package:caterpillar_crawl/models/data/caterpillar_data.dart';
import 'package:caterpillar_crawl/ui_elements/enemy_indicator.dart';
import 'package:caterpillar_crawl/ui_elements/game_over_menu.dart';
import 'package:caterpillar_crawl/ui_elements/hud/hud.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final Images imageLoader = Images();

const String pauseOverlayIdentifier = 'PauseMenu';
const String hudOverlayIdentifier = 'Hud';
const String gameOverOverlayIdentifier = 'GameOverMenu';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.setLandscape();
  Flame.device.fullScreen();
  runApp(
    GameWidget(game: CaterpillarCrawlMain(), overlayBuilderMap: {
      pauseOverlayIdentifier:
          (BuildContext context, CaterpillarCrawlMain game) {
        return const Text('A pause menu');
      },
      gameOverOverlayIdentifier:
          (BuildContext context, CaterpillarCrawlMain game) {
        return gameOverBuilder(context, game);
      },
      hudOverlayIdentifier: (BuildContext context, CaterpillarCrawlMain game) {
        return GameHud(game: game);
      }
    }),
  );
}

class CaterpillarCrawlMain extends FlameGame
    with TapCallbacks, HasKeyboardHandlerComponents {
  late CaterPillar _caterPillar;
  late GroundMap groundMap;
  late CaterpillarGameUI _gameUI;
  late PlayerController _playerController;
  late EnemyIndicatorHUD enemyIndicatorHUD;

  //View Models - Hopefully Singletons
  CaterpillarStateViewModel caterpillarStateViewModel;
  CaterpillarStatsViewModel caterpillarStatsViewModel;

  double angleToLerpTo = 0;
  double rotationSpeed = 5;
  int snackCount = 100; //300
  int enemyCount = 30; //60
  int healthUpCount = 1;
  int remainingEnemiesToLevelUp = 0;
  int segmentsToUlti = 30; //30
  int enemyKillsToUlti = 15; //15
  int maxLevelCount = 10;
  int enemyCountOnIndicator = 15;

  //UI
  double actionButtonSize = 100;
  double gapRightSide = 14;
  double joystickKnobRadius = 40;
  double joystickBackgroundRadius = 90;

  int playerLifeCount = 6;
  double timeToUlti = 0.8;

  double mapSize = 1200; //2000

  late Timer interval;
  //Frame Ticks to reset at 10
  int frameTicks = 0;

  CaterpillarCrawlMain()
      : caterpillarStateViewModel = CaterpillarStateViewModel(),
        caterpillarStatsViewModel = CaterpillarStatsViewModel();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    world = World();
    await add(FpsTextComponent());
    enemyIndicatorHUD = EnemyIndicatorHUD(world: this);
    await add(enemyIndicatorHUD);
    _gameUI =
        CaterpillarGameUI(mainGame: this, playerLifeCount: playerLifeCount);

    await initPlayerController();
    await add(_gameUI);
    overlays.add(hudOverlayIdentifier);

    await initializeMapAndView();
  }

  Future<void> initPlayerController() async {
    if (kIsWeb) {
      _playerController = WebPlayerController(mainGame: this);
    } else {
      _playerController = MobilePlayerController(mainGame: this);
    }
    await add(_playerController);
  }

  Future<void> initializeMapAndView() async {
    createAndAddCaterillar(mapSize, _playerController);
    camera.viewfinder.zoom = 1;
    camera.follow(_caterPillar);
    debugMode = false;
    if (debugMode) {
      print("DEBUG IS ON");
    }
    world.debugMode = debugMode;

    await createMap(_caterPillar);
    _caterPillar.position = Vector2.zero();
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateFrameTicks();
  }

  void updateFrameTicks() {
    frameTicks = (frameTicks + 1) % 10;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPaint(Paint()..color = Color.fromARGB(255, 120, 155, 117));
    super.render(canvas);
  }

  void zoomOut(level) {
    double correct = level / maxLevelCount;
    double zoomRatio = 1.0 - (correct * 0.05);
    final effect = ScaleEffect.by(
      Vector2.all(zoomRatio),
      EffectController(duration: 0.6),
    );
    camera.viewfinder.add(effect);
  }

  void createAndAddCaterillar(
      double mapSiz, PlayerController playerController) {
    CaterpillarData mainPlayerCaterpillar =
        CaterpillarData.createCaterpillarData();
    _caterPillar = CaterPillar(mainPlayerCaterpillar, this,
        rotationSpeed: rotationSpeed,
        playerController: playerController,
        caterpillarStateViewModel: caterpillarStateViewModel,
        caterpillarStatsViewModel: caterpillarStatsViewModel);
  }

  Future<void> createMap(CaterPillar caterpillar) async {
    groundMap = GroundMap(
        mapSize: mapSize,
        player: caterpillar,
        world: this,
        snackCount: snackCount,
        enemyCount: enemyCount,
        healthUpCount: healthUpCount);
    await world.add(groundMap);
    await world.add(_caterPillar);
  }

  void onLayEggTap() {
    _caterPillar.toggleEggAndCrawl();
  }

  void onUltiTap() {
    _caterPillar.ulti();
  }

  void onPewPewButtonclicked() {
    _caterPillar.onPewPew();
  }

  void onLifeCountChanged(int lifeCount) {
    _gameUI.onLifeCountChanged(lifeCount);
    if (lifeCount == 0) {
      onGameOver();
    }
  }

  Future<void> onGameRestart() async {
    _caterPillar.removeCompletly();
    groundMap.removeComnpletly();
    await initializeMapAndView();
    overlays.remove(gameOverOverlayIdentifier);
    paused = false;
  }

  void onGameOver() {
    paused = true;
    overlays.add(gameOverOverlayIdentifier);
    // _gameUI.reset();
    enemyIndicatorHUD.reset();
  }
}
