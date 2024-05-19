import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/view_models/caterpillar_state_view_model.dart';
import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class PlayerStatsWidget extends StatefulWidget {
  final CaterpillarCrawlMain game;

  const PlayerStatsWidget({required this.game, super.key});
  @override
  _PlayerStatsWidget createState() => _PlayerStatsWidget(game: game);
}

class _PlayerStatsWidget extends State<PlayerStatsWidget> {
  CaterpillarCrawlMain game;

  late CaterpillarStatsViewModel caterpillarStatsViewModel;

  _PlayerStatsWidget({required this.game});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    caterpillarStatsViewModel = game.caterpillarStatsViewModel;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CaterpillarStatsViewModel>(
        create: (context) => game.caterpillarStatsViewModel,
        child: Consumer<CaterpillarStatsViewModel>(
          builder: (context, cart, child) =>
              _playerStatsWidgetBuilder(context, game),
        ));
  }

  Widget _playerStatsWidgetBuilder(
      BuildContext buildContext, CaterpillarCrawlMain game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text(
            'Enemies',
            style: TextStyles.uiLabelTextStyle,
          ),
          // _statsElement(iconPath,), //TODO: POINTS
          _statsElement('kill_icon.png',
              caterpillarStatsViewModel.enemyKilled.toString()),
          _statsElement('enemy_icon.png',
              caterpillarStatsViewModel.enemiesInGame.toString()),
          SizedBox(
            height: 1,
            width: game.gapRightSide,
          )
        ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // _statsElement(iconPath,), //TODO: POINTS
            _statsElement('segment_icon.png',
                caterpillarStatsViewModel.segmentCount.toString()),
            _statsElement(
                'level_icon.png', caterpillarStatsViewModel.level.toString()),
            SizedBox(
              height: 1,
              width: game.gapRightSide,
            )
          ],
        )
      ],
    );
  }

  Widget _statsElement(String iconImagePath, String value) {
    String pathToIcons = 'assets/icons/';
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Image(
        image: AssetImage(pathToIcons + iconImagePath),
        width: UIConstants.iconSize,
        height: UIConstants.iconSize,
      ),
      Text(
        value,
        style: TextStyles.uiLabelTextStyle,
      )
    ]);
  }
}
