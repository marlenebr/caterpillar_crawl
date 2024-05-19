import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/view_models/caterpillar_state_model.dart';
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
      children: [
        Row(children: [
          Text(
            'Enemies',
            style: TextStyles.uiLabelTextStyle,
          ),
          // _statsElement(iconPath,), //TODO: POINTS
          _statsElement(Icons.kayaking, UiColors.enemyUiColor!,
              caterpillarStatsViewModel.enemyKilled.toString()),
          _statsElement(Icons.bug_report_sharp, UiColors.enemyUiColor!,
              caterpillarStatsViewModel.enemiesInGame.toString()),
        ]),
        Row(
          children: [
            // _statsElement(iconPath,), //TODO: POINTS
            _statsElement(Icons.auto_awesome_motion, UiColors.segmentColor!,
                caterpillarStatsViewModel.segmentCount.toString()),
            _statsElement(Icons.arrow_circle_up_rounded, UiColors.levelColor!,
                caterpillarStatsViewModel.level.toString()),
          ],
        )
      ],
    );
  }

  Widget _statsElement(IconData tempIcon, Color iconColor, String value) {
    return Row(children: [
      Icon(
        tempIcon,
        color: iconColor,
        size: TextStyles.iconSize,
      ),
      Text(
        value,
        style: TextStyles.uiLabelTextStyle,
      )
    ]);
  }
}
