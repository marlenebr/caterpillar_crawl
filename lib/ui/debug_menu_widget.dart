import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/view_models/game_state_view_model.dart';
import 'package:caterpillar_crawl/models/view_models/level_settings_view_model.dart';
import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:caterpillar_crawl/ui/elements/settings_number_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DebugMenuWidget extends StatefulWidget {
  final CaterpillarCrawlMain game;

  const DebugMenuWidget({required this.game, super.key});

  @override
  State<DebugMenuWidget> createState() => _DebugMenuWidgetState();
}

class _DebugMenuWidgetState extends State<DebugMenuWidget> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameStateViewModel>(
        create: (context) => widget.game.gameStateViewModel,
        child: Consumer<GameStateViewModel>(
          builder: (context, value, child) => Column(
            children: [
              SettingsNumberPicker<SnackCountValue>(
                viewModel: widget.game.snackCountSettingsViewModel,
                text: "Snack Count",
                minValue: 50,
                maxValue: 300,
                step: 10,
              ),
              SettingsNumberPicker<EnemyCountValue>(
                viewModel: widget.game.enemyCountViewModel,
                text: "Enemy Count",
                minValue: 1,
                maxValue: 100,
              ),
              SettingsNumberPicker<MaxLevelCountValue>(
                viewModel: widget.game.maxLevelValue,
                text: "Max Level",
                minValue: 1,
                maxValue: 10,
              ),
              SettingsNumberPicker<MapSizeValue>(
                viewModel: widget.game.mapSizeValue,
                text: "Map Size",
                minValue: 100,
                maxValue: 5000,
                step: 100,
              ),
              IconButton.filled(
                onPressed: () => {widget.game.onGameRestart(PauseType.none)},
                icon: const Icon(Icons.loop),
                color: UiColors.segmentColor,
              ),
            ],
          ),
        ));
  }
}
