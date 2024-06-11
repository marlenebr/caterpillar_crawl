import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:caterpillar_crawl/ui_elements/hud/action_buttons_widget.dart';
import 'package:caterpillar_crawl/ui_elements/hud/health_status_widget.dart';
import 'package:caterpillar_crawl/ui_elements/hud/player_stats_widget.dart';
import 'package:caterpillar_crawl/ui_elements/options_menu_widget.dart';
import 'package:flutter/material.dart';

class GameHud extends StatelessWidget {
  final CaterpillarCrawlMain game;

  const GameHud({required this.game, super.key});

  @override
  Widget build(Object context) {
    return Stack(
      children: [
        getActionbuttonCorner(),
        getPlayerstats(),
        getLeftUpperCorner()
      ],
    );
  }

  Widget getActionbuttonCorner() {
    return Align(
      alignment: Alignment.bottomRight,
      child: SizedBox(
        width: game.actionButtonSize * 2 + game.gapRightSide,
        height: game.actionButtonSize * 1.5 + game.gapRightSide,
        child: Material(
          color: Colors.transparent,
          child: ActionButtons(game: game),
        ),
      ),
    );
  }

  Widget getPlayerstats() {
    return Align(
      alignment: Alignment.topRight,
      child: SizedBox(
        width: 250,
        height: 100,
        child: Material(
          color: Colors.transparent,
          child: PlayerStatsWidget(game: game),
        ),
      ),
    );
  }

  Widget getLeftUpperCorner() {
    return Align(
        alignment: Alignment.topLeft,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 200,
            height: 80,
            child: Material(
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HealthStatusWidget(game: game),
                    IconButton.filled(
                      onPressed: () => {game.onGamePause(null)},
                      icon: const Icon(Icons.pause),
                      iconSize: UIConstants.iconSizeMedium,
                      color: UiColors.segmentColor,
                    ),
                  ],
                )),
          ),
          OptionsMenuWidget(game: game),
        ]));
  }
}
