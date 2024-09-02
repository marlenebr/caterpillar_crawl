import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/view_models/caterpillar_state_view_model.dart';
import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class PlayerStatsWidget extends StatefulWidget {
  final CaterpillarCrawlMain game;

  const PlayerStatsWidget({required this.game, super.key});
  @override
  createState() => _PlayerStatsWidget();
}

class _PlayerStatsWidget extends State<PlayerStatsWidget> {
  late CaterpillarStatsViewModel caterpillarStatsViewModel;

  _PlayerStatsWidget();

  @override
  void initState() {
    super.initState();
    caterpillarStatsViewModel = widget.game.caterpillarStatsViewModel;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CaterpillarStatsViewModel>(
        create: (context) => widget.game.caterpillarStatsViewModel,
        child: Consumer<CaterpillarStatsViewModel>(
          builder: (context, cart, child) =>
              _playerStatsWidgetBuilder(context, widget.game),
        ));
  }

  Widget _playerStatsWidgetBuilder(
      BuildContext buildContext, CaterpillarCrawlMain game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text(
            'Points',
            style: TextStyles.uiLabelTextStyle,
          ),
          _statsElement(
              'level_icon.png', caterpillarStatsViewModel.points.toString()),
          SizedBox(
            height: 1,
            width: game.gapRightSide,
          )
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text(
            'Enemies',
            style: TextStyles.uiLabelTextStyle,
          ),
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
