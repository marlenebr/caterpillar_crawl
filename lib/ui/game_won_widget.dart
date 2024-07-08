import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/view_models/game_state_view_model.dart';
import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:flutter/material.dart';

class GameWonWidget extends StatelessWidget {
  final CaterpillarCrawlMain game;

  GameWonWidget({required this.game});

  @override
  Widget build(Object context) {
    return Align(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            "You Won",
            style: TextStyles.uiLabelTextStyle,
          ),
          Padding(
            padding: EdgeInsets.all(UIConstants.defaultPaddingMedium),
            child: Image(
              image: const AssetImage("assets/images/heartgreen_64.png"),
              width: UIConstants.imageSizeSmall,
              height: UIConstants.imageSizeSmall,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(UIConstants.defaultPaddingMedium),
            child: Image(
              image: const AssetImage("assets/images/heartgreen_64.png"),
              width: UIConstants.imageSizeSmall,
              height: UIConstants.imageSizeSmall,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(UIConstants.defaultPaddingMedium),
            child: IconButton.filled(
              onPressed: () => {game.onGameRestart(PauseType.none)},
              icon: Icon(Icons.loop),
              color: UiColors.segmentColor,
            ),
          )
        ]),
      ),
    );
  }
}
