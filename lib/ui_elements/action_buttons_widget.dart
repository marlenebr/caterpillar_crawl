import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillar/caterpillar.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/view_models/caterpillar_state_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActionButtons extends StatefulWidget {
  CaterpillarCrawlMain game;
  ActionButtons({required this.game, super.key});
  @override
  _ActionButtons createState() => _ActionButtons(game: game);
}

class _ActionButtons extends State<ActionButtons> {
  CaterpillarCrawlMain game;

  late CaterpillarStatsViewModel caterpillarStateViewModel;
  String pathToEggButtonImage = 'assets/images/bomb_128_button.png';
  String pathToUltiButtonImage = 'assets/images/segment_single_color02.png';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    caterpillarStateViewModel = game.caterpillarStatsViewModel;
  }

  late CaterpillarStatsViewModel caterpillarStareViewModel;
  _ActionButtons({required this.game});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CaterpillarStatsViewModel>(
        create: (context) => game.caterpillarStatsViewModel,
        child: Consumer<CaterpillarStatsViewModel>(
          builder: (context, cart, child) =>
              actionButtonsBuilder(context, game),
        ));
  }

  Widget actionButtonsBuilder(
      BuildContext buildContext, CaterpillarCrawlMain game) {
    CaterpillarStatsViewModel caterpillarStatsViewModel =
        game.caterpillarStatsViewModel;
    String buttonImagePath = '';
    Function onButtonTap;

    if (caterpillarStatsViewModel.currentState ==
        CaterpillarState.readyForUlti) {
      buttonImagePath = pathToUltiButtonImage;
      onButtonTap = () => game.onUltiTap();
    } else {
      buttonImagePath = pathToEggButtonImage;
      onButtonTap = () => game.onLayEggTap();
    }

    return Align(
      alignment: Alignment.bottomRight,
      child: SizedBox(
        width: game.actionButtonSize * 2 + game.gapRightSide,
        height: game.actionButtonSize * 1.5 + game.gapRightSide,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              eggAndUltiButton(caterpillarStatsViewModel, game.actionButtonSize,
                  0, game.actionButtonSize / 2, onButtonTap, buttonImagePath),
              regularWeaponButton(
                  game.actionButtonSize,
                  game.actionButtonSize,
                  0,
                  () => game.onPewPewButtonclicked(),
                  'assets/images/pewpew_128_button.png'),
            ],
          ),
        ),
      ),
    );
  }

  Widget regularWeaponButton(double size, double posX, double posY,
      Function onTap, String pathToImage) {
    return Positioned(
      top: posY,
      left: posX,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: imageButton(pathToImage, onTap, size),
      ),
    );
  }

  Widget eggAndUltiButton(
      CaterpillarStatsViewModel caterpillarStatsViewModel,
      double size,
      double posX,
      double posY,
      Function onTap,
      String pathToImage) {
    return Positioned(
      top: posY,
      left: posX,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
                startAngle: 0,
                colors: [
                  ActionButtonColors.segmentsToUltiRingColor!,
                  ActionButtonColors.buttonColor!
                ],
                stops: [
                  caterpillarStatsViewModel.segmentCount / game.segmentsToUlti,
                  caterpillarStatsViewModel.segmentCount / game.segmentsToUlti
                ],
                tileMode: TileMode.decal,
                transform: GradientRotation(-pi / 2))
            // color: Colors.blue,
            ),
        // color: Colors.blue,
        clipBehavior: Clip.hardEdge,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                    startAngle: 0,
                    colors: [
                      ActionButtonColors.enemyToUltiRingColor!,
                      ActionButtonColors.buttonColor!
                    ],
                    stops: [
                      caterpillarStatsViewModel.enemyKilledSinceUlti /
                          game.enemyKillsToUlti,
                      caterpillarStatsViewModel.enemyKilledSinceUlti /
                          game.enemyKillsToUlti
                    ],
                    tileMode: TileMode.decal,
                    transform: GradientRotation(-pi / 2))
                // color: Colors.blue,
                ),
            // color: Colors.blue,
            clipBehavior: Clip.hardEdge,
            child: imageButton(pathToImage, onTap, size),
          ),
        ),
      ),
    );
  }

  Widget imageButton(String imagePath, Function onTap, double size) {
    return InkWell(
      onTap: () {
        onTap();
      },
      highlightColor: const Color.fromARGB(255, 21, 24, 21),
      splashColor: ActionButtonColors.tapColor,
      borderRadius: BorderRadius.all(Radius.circular(size / 2)),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ActionButtonColors.buttonColor,
          ),
          // clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Image(
              image: AssetImage(imagePath),
            ),
            // ),
          ),
        ),
      ),
    );
  }
}

//TODO: FINISH
class IndicatorRing extends StatefulWidget {
  final CaterpillarCrawlMain game;
  final Widget child;

  final double size;

  const IndicatorRing(
      {required this.game, required this.child, required this.size, super.key});

  @override
  State<StatefulWidget> createState() =>
      _IndicatorRing(game: game, child: child, size: size);
}

class _IndicatorRing extends State<IndicatorRing> {
  Widget child;
  CaterpillarCrawlMain game;
  double size;

  late CaterpillarStatsViewModel caterpillarStateViewModel;

  @override
  void initState() {
    super.initState();
    caterpillarStateViewModel = game.caterpillarStatsViewModel;
  }

  late CaterpillarStatsViewModel caterpillarStatsViewModel;
  _IndicatorRing({required this.game, required this.child, required this.size});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
                startAngle: 0,
                colors: [Colors.green, Colors.transparent],
                stops: [
                  caterpillarStatsViewModel.segmentCount / 30,
                  caterpillarStatsViewModel.segmentCount / 30
                ],
                tileMode: TileMode.decal,
                transform: GradientRotation(-pi / 2))
            // color: Colors.blue,
            ),
        // color: Colors.blue,
        clipBehavior: Clip.hardEdge,
        child: child);
  }
}

class ActionButtonColors {
  static Color? enemyToUltiRingColor = Colors.orange[700];
  static Color? segmentsToUltiRingColor = Colors.lightGreenAccent[400];
  static Color? buttonColor = Colors.lightBlue[400];
  static Color? tapColor = Colors.lime;
}
