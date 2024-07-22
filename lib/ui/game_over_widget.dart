import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/view_models/game_state_view_model.dart';
import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:flutter/material.dart';

class GameOverWidget extends StatelessWidget {
  final CaterpillarCrawlMain game;

  GameOverWidget({required this.game});

  @override
  Widget build(Object context) {
    // TODO: implement build
    return Align(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            "Game Over",
            style: TextStyles.uiLabelTextStyle,
          ),
          IconButton.filled(
            onPressed: () => {game.onGameRestart()},
            icon: Icon(Icons.loop),
            color: UiColors.segmentColor,
          )
        ]),
      ),
    );
  }
}
