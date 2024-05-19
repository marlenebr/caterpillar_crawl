import 'dart:math';

import 'package:caterpillar_crawl/components/caterpillar/caterpillar.dart';
import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/view_models/caterpillar_state_view_model.dart';
import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActionButtons extends StatefulWidget {
  final CaterpillarCrawlMain game;
  const ActionButtons({required this.game, super.key});
  @override
  _ActionButtons createState() => _ActionButtons(game: game);
}

class _ActionButtons extends State<ActionButtons> {
  CaterpillarCrawlMain game;

  _ActionButtons({required this.game});

  late CaterpillarStatsViewModel caterpillarStateViewModel;
  String pathToEggButtonImage = 'assets/images/bomb_128_button.png';
  String pathToUltiButtonImage = 'assets/images/segment_single_color02.png';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    caterpillarStateViewModel = game.caterpillarStatsViewModel;
  }

  @override
  Widget build(BuildContext context) {
    return _actionButtonsBuilder(context, game);
  }

  Widget _actionButtonsBuilder(
      BuildContext buildContext, CaterpillarCrawlMain game) {
    CaterpillarStatsViewModel caterpillarStatsViewModel =
        game.caterpillarStatsViewModel;

    return Stack(
      children: [
        ChangeNotifierProvider<CaterpillarStatsViewModel>(
          create: (context) => game.caterpillarStatsViewModel,
          child: Consumer<CaterpillarStatsViewModel>(
            builder: (context, cart, child) => eggAndUltiButton(
                caterpillarStatsViewModel,
                game.actionButtonSize,
                0,
                game.actionButtonSize / 2),
          ),
        ),
        regularWeaponButton(
            game.actionButtonSize,
            game.actionButtonSize,
            0,
            () => game.onPewPewButtonclicked(),
            'assets/images/pewpew_128_button.png'),
      ],
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

  Widget eggAndUltiButton(CaterpillarStatsViewModel caterpillarStatsViewModel,
      double size, double posX, double posY) {
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
                  colors: [UiColors.segmentColor!, UiColors.buttonColor!],
                  stops: [
                    caterpillarStatsViewModel.segmentCount /
                        game.segmentsToUlti,
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
                      colors: [UiColors.enemyUiColor!, UiColors.buttonColor!],
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
              child: imageButton(buttonImagePath, onButtonTap, size),
            ),
          ),
        ));
  }

  Widget imageButton(String imagePath, Function onTap, double size) {
    return InkWell(
      onTap: () {
        onTap();
      },
      highlightColor: const Color.fromARGB(255, 21, 24, 21),
      splashColor: UiColors.tapColor,
      borderRadius: BorderRadius.all(Radius.circular(size / 2)),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: UiColors.buttonColor,
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

// //TODO: FINISH
// class IndicatorRing extends StatefulWidget {
//   final CaterpillarCrawlMain game;
//   final Widget child;

//   final double size;

//   const IndicatorRing(
//       {required this.game, required this.child, required this.size, super.key});

//   @override
//   State<StatefulWidget> createState() =>
//       _IndicatorRing(game: game, child: child, size: size);
// }

// class _IndicatorRing extends State<IndicatorRing> {
//   Widget child;
//   CaterpillarCrawlMain game;
//   double size;

//   late CaterpillarStatsViewModel caterpillarStateViewModel;

//   @override
//   void initState() {
//     super.initState();
//     caterpillarStateViewModel = game.caterpillarStatsViewModel;
//   }

//   late CaterpillarStatsViewModel caterpillarStatsViewModel;
//   _IndicatorRing({required this.game, required this.child, required this.size});

//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return Container(
//         width: size,
//         height: size,
//         decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             gradient: SweepGradient(
//                 startAngle: 0,
//                 colors: [Colors.green, Colors.transparent],
//                 stops: [
//                   caterpillarStatsViewModel.segmentCount / 30,
//                   caterpillarStatsViewModel.segmentCount / 30
//                 ],
//                 tileMode: TileMode.decal,
//                 transform: GradientRotation(-pi / 2))
//             // color: Colors.blue,
//             ),
//         // color: Colors.blue,
//         clipBehavior: Clip.hardEdge,
//         child: child);
//   }
// }