import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/view_models/game_state_view_model.dart';
import 'package:caterpillar_crawl/models/view_models/level_settings_view_model.dart';
import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:caterpillar_crawl/ui/debug_menu_widget.dart';
import 'package:caterpillar_crawl/ui/settings_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameMenuWidget extends StatefulWidget {
  final CaterpillarCrawlMain game;

  const GameMenuWidget({required this.game, super.key});

  @override
  createState() => _OptionsMenuwidget();
}

class _OptionsMenuwidget extends State<GameMenuWidget> {
  late GameStateViewModel gameStateViewModel;
  late SnackCountValue snackountViewmodel;

  @override
  void initState() {
    super.initState();
    gameStateViewModel = widget.game.gameStateViewModel;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameStateViewModel>(
      create: (context) => widget.game.gameStateViewModel,
      child: Consumer<GameStateViewModel>(
          builder: (context, value, child) => Offstage(
                offstage: (gameStateViewModel.pauseType == PauseType.none),
                child: Material(
                  color: UiColors.enemyUiColor,
                  child: Container(
                      width: 260,
                      height: 260,
                      color: UiColors.segmentColor,
                      child: Column(
                        children: [content()],
                      )),
                ),
              )),
    );
  }

  Widget content() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Offstage(
                offstage:
                    widget.game.gameStateViewModel.pauseType != PauseType.debug,
                child: DebugMenuWidget(
                  game: widget.game,
                )),
            Offstage(
              offstage: widget.game.gameStateViewModel.pauseType !=
                  PauseType.settings,
              child: SettingsMenuWidget(game: widget.game),
            ),
          ],
        ),
      ),
    );
  }

  double test = 5;

  @override
  void dispose() {
    super.dispose();
  }
}
