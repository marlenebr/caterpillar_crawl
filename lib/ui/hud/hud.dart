import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/view_models/game_state_view_model.dart';
import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:caterpillar_crawl/ui/hud/action_weapon_button_view.dart';
import 'package:caterpillar_crawl/ui/hud/health_status_widget.dart';
import 'package:caterpillar_crawl/ui/hud/player_stats_widget.dart';
import 'package:caterpillar_crawl/ui/game_menu_widget.dart';
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
          child: ActionWeaponButtonView(
            actionButtonSize: game.actionButtonSize,
            mainGame: game,
            meleeButtonViewModel: game.meleeButtonViewModel,
            distanceWeaponViewModel: game.distanceActionButtonViewModel,
          ),
        ),
      ),
    );
  }

  Widget getPlayerstats() {
    return Align(
      alignment: Alignment.topRight,
      child: SizedBox(
        width: 250,
        height: 115,
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
            width: 220,
            height: 100,
            child: Material(
                color: Colors.transparent,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.all(UIConstants.defaultPaddingMedium),
                        child: HealthStatusWidget(
                            game: game,
                            key: game.healthStatusViewModel.globalKey),
                      ),
                      Row(children: [
                        Padding(
                          padding:
                              EdgeInsets.all(UIConstants.defaultPaddingMedium),
                          child: IconButton.filled(
                            onPressed: () => {
                              game.gameStateViewModel.pauseType ==
                                      PauseType.debug
                                  ? game.onGamePause(PauseType.none)
                                  : game.onGamePause(PauseType.debug)
                            },
                            icon: const Icon(Icons.pause),
                            iconSize: UIConstants.iconSizeMedium,
                            color: UiColors.segmentColor,
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.all(UIConstants.defaultPaddingMedium),
                          child: IconButton.filled(
                            onPressed: () => {
                              game.gameStateViewModel.pauseType ==
                                      PauseType.settings
                                  ? game.onGamePause(PauseType.none)
                                  : game.onGamePause(PauseType.settings)
                            },
                            icon: const Icon(Icons.settings),
                            iconSize: UIConstants.iconSizeMedium,
                            color: UiColors.segmentColor,
                          ),
                        ),
                      ]),
                    ])),
          ),
          GameMenuWidget(game: game),
        ]));
  }
}

enum ViewType {
  healthBar,
  bombButton,
  meleeButton,
}
