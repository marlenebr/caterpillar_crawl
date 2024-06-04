import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:flutter/material.dart';

class GameEndWidget extends StatelessWidget {
  final CaterpillarCrawlMain game;

  GameEndWidget({required this.game});

  @override
  Widget build(Object context) {
    // TODO: implement build
    return Align(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            "Game Over Or Won",
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
