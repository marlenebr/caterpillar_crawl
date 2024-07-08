import 'dart:async';

import 'package:caterpillar_crawl/components/caterpillar/caterpillar.dart';
import 'package:caterpillar_crawl/components/player_controller.dart';
import 'package:caterpillar_crawl/models/view_models/caterpillar_state_view_model.dart';
import 'package:caterpillar_crawl/models/view_models/game_state_view_model.dart';
import 'package:caterpillar_crawl/models/view_models/health_status_view_model.dart';
import 'package:caterpillar_crawl/models/view_models/level_settings_view_model.dart';
import 'package:caterpillar_crawl/components/map/ground_map.dart';
import 'package:caterpillar_crawl/models/data/caterpillar_data.dart';
import 'package:caterpillar_crawl/ui/enemy_indicator.dart';
import 'package:caterpillar_crawl/ui/game_over_widget.dart';
import 'package:caterpillar_crawl/ui/game_won_widget.dart';
import 'package:caterpillar_crawl/ui/hud/hud.dart';
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
const String gameWonOverlayIdentifier = 'GameWon';

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
        return GameOverWidget(game: game);
      },
      gameWonOverlayIdentifier:
          (BuildContext context, CaterpillarCrawlMain game) {
        return GameWonWidget(game: game);
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
  late PlayerController _playerController;
  late EnemyIndicatorHUD enemyIndicatorHUD;

  //View Models - Singletons
  CaterpillarStateViewModel caterpillarStateViewModel;
  CaterpillarStatsViewModel caterpillarStatsViewModel;
  HealthStatusViewModel healthStatusViewModel;
  GameStateViewModel gameStateViewModel;
  SnackCountValue snackCountSettingsViewModel;
  EnemyCountValue enemyCountViewModel;
  MaxLevelCountValue maxLevelValue;
  MapSizeValue mapSizeValue;

  double angleToLerpTo = 0;
  double rotationSpeed = 5;
  int healthUpCount = 1;
  int remainingEnemiesToLevelUp = 0;
  int segmentsToUlti = 20; //30
  int enemyKillsToUlti = 10; //15
  int enemyCountOnIndicator = 15;

  //UI
  double actionButtonSize = 100;
  double gapRightSide = 14;
  double joystickKnobRadius = 40;
  double joystickBackgroundRadius = 90;

  int playerLifeCount = 6;
  double timeToUlti = 0.8;

  late Timer interval;
  //Frame Ticks to reset at 10
  int frameTicks = 0;

  CaterpillarCrawlMain()
      : caterpillarStateViewModel = CaterpillarStateViewModel(),
        caterpillarStatsViewModel = CaterpillarStatsViewModel(),
        healthStatusViewModel = HealthStatusViewModel(),
        gameStateViewModel = GameStateViewModel(),
        snackCountSettingsViewModel = SnackCountValue(100),
        enemyCountViewModel = EnemyCountValue(15),
        maxLevelValue = MaxLevelCountValue(10),
        mapSizeValue = MapSizeValue(1200);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // world = World();
    await add(
        FpsTextComponent(position: Vector2(200, 0), scale: Vector2.all(0.4)));
    enemyIndicatorHUD = EnemyIndicatorHUD(world: this);
    await add(enemyIndicatorHUD);

    await initPlayerController();
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
    camera.viewfinder.zoom = 1;
    debugMode = false;
    if (debugMode) {
      print("DEBUG IS ON");
    }
    world.debugMode = debugMode;

    await createMap();
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
    double correct = level / maxLevelValue.value;
    double zoomRatio = 1.0 - (correct * 0.05);
    final effect = ScaleEffect.by(
      Vector2.all(zoomRatio),
      EffectController(duration: 0.6),
    );
    camera.viewfinder.add(effect);
  }

  void createAndAddCaterillar(int mapSiz, PlayerController playerController) {
    CaterpillarData mainPlayerCaterpillar =
        CaterpillarData.createCaterpillarData();
    _caterPillar = CaterPillar(mainPlayerCaterpillar, this,
        rotationSpeed: rotationSpeed,
        playerController: playerController,
        caterpillarStateViewModel: caterpillarStateViewModel,
        caterpillarStatsViewModel: caterpillarStatsViewModel);
  }

  Future<void> createMap() async {
    createAndAddCaterillar(mapSizeValue.value, _playerController);

    groundMap = GroundMap(
        mapSize: mapSizeValue.value,
        player: _caterPillar,
        world: this,
        snackCount: snackCountSettingsViewModel.value,
        enemyCount: enemyCountViewModel.value,
        healthUpCount: healthUpCount);
    await world.add(groundMap);
    camera.world = world;
    camera.follow(_caterPillar);
    _caterPillar.priority = 900;
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
    healthStatusViewModel.setHealthStatus(lifeCount);
    if (lifeCount == 0) {
      onGameOver();
    }
  }

  Future<void> onGameRestart(PauseType pauseType) async {
    enemyIndicatorHUD.reset();
    _caterPillar.removeCompletly();
    groundMap.removeComnpletly();
    await initializeMapAndView();
    overlays.remove(gameOverOverlayIdentifier);
    overlays.remove(gameWonOverlayIdentifier);
    caterpillarStatsViewModel.reset();
    onGamePause(pauseType);
  }

  void onGameOver() {
    paused = true;
    overlays.add(gameOverOverlayIdentifier);
  }

  void onGameWon() {
    paused = true;
    overlays.add(gameWonOverlayIdentifier);
  }

  void onGamePause(PauseType pauseType) {
    paused = pauseType != PauseType.none;
    gameStateViewModel.setGamePause(pauseType);
    groundMap.setGamePause(paused);
  }
}
