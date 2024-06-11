import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/view_models/game_state_view_model.dart';
import 'package:caterpillar_crawl/models/view_models/level_settings_view_model.dart';
import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

class OptionsMenuWidget extends StatefulWidget {
  final CaterpillarCrawlMain game;

  const OptionsMenuWidget({required this.game, super.key});

  @override
  createState() => _OptionsMenuwidget();
}

class _OptionsMenuwidget extends State<OptionsMenuWidget> {
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
          builder: (context, value, child) => _optionsMenu(),
        ));
  }

  double test = 5;

  Widget _optionsMenu() {
    return Offstage(
        offstage: !gameStateViewModel.isPaused,
        child: Material(
          color: UiColors.enemyUiColor,
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Container(
              width: 260,
              color: UiColors.segmentColor,
              child: Column(
                children: [
                  SettingsNumberPicker<SnackCountValue>(
                    game: widget.game,
                    viewModel: widget.game.snackCountSettingsViewModel,
                    text: "Snack Count",
                    minValue: 50,
                    maxValue: 300,
                  ),
                  SettingsNumberPicker<EnemyCountValue>(
                    game: widget.game,
                    viewModel: widget.game.enemyCountViewModel,
                    text: "Enemy Count",
                    minValue: 1,
                    maxValue: 100,
                  ),
                  SettingsNumberPicker<MaxLevelCountValue>(
                    game: widget.game,
                    viewModel: widget.game.maxLevelValue,
                    text: "Enemy Count",
                    minValue: 1,
                    maxValue: 10,
                  ),
                  IconButton.filled(
                    onPressed: () => {widget.game.onGameRestart()},
                    icon: const Icon(Icons.loop),
                    color: UiColors.segmentColor,
                  )
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }
  // return const SizedBox(
  //   width: 0,
  //   height: 0,
  // );
}

// get onChanged => print("SLIDE");

//NUMBER PICKER
class SettingsNumberPicker<ChangableIntValue> extends StatefulWidget {
  final CaterpillarCrawlMain game;
  final ChangableIntValue viewModel;
  final int minValue;
  final int maxValue;

  final String text;

  const SettingsNumberPicker(
      {super.key,
      required this.game,
      required this.viewModel,
      required this.text,
      required this.minValue,
      required this.maxValue});
  @override
  createState() => _SettingsNumberPicker();
}

class _SettingsNumberPicker extends State<SettingsNumberPicker> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChangableIntValue>(
        create: (context) => widget.viewModel,
        child: Consumer<ChangableIntValue>(
            builder: (context, cart, child) => Column(
                  children: <Widget>[
                    Text(widget.text, style: TextStyles.uiLabelTextStyle),
                    NumberPicker(
                      value: widget.viewModel.value,
                      axis: Axis.horizontal,
                      itemHeight: 30,
                      minValue: widget.minValue,
                      maxValue: widget.maxValue,
                      onChanged: (value) =>
                          setState(() => widget.viewModel.setValue(value)),
                    ),
                    //Text('Current value: $widget.viewModel.value'),
                  ],
                )));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
