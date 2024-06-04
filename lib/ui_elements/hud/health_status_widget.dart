import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/view_models/health_status_view_model.dart';
import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class HealthStatusWidget extends StatefulWidget {
  final CaterpillarCrawlMain game;

  const HealthStatusWidget({required this.game, super.key});
  @override
  createState() => _HealthStatusWidget();
}

class _HealthStatusWidget extends State<HealthStatusWidget> {
  String pathToFullHeartIcon = "assets/images/heartgreen_64.png";
  String pathToEmptyHeartIcon = "assets/images/heartempty_64.png";

  late HealthStatusViewModel healthStatsViewModel;

  _HealthStatusWidget();

  @override
  void initState() {
    super.initState();
    healthStatsViewModel = widget.game.healthStatusViewModel;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HealthStatusViewModel>(
        create: (context) => healthStatsViewModel,
        child: Consumer<HealthStatusViewModel>(
          builder: (context, cart, child) =>
              _healthStatuswidgetBuilder(context, widget.game),
        ));
  }

  Widget _healthStatuswidgetBuilder(
      BuildContext buildContext, CaterpillarCrawlMain game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            for (int i = 0; i < game.playerLifeCount; i++)
              Image(
                image: AssetImage(i <= healthStatsViewModel.lifeCount
                    ? pathToFullHeartIcon
                    : pathToEmptyHeartIcon),
                width: UIConstants.iconSizeMedium,
                height: UIConstants.iconSizeMedium,
              )
          ],
        ),
      ],
    );
  }
}
