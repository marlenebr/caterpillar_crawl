import 'package:caterpillar_crawl/main.dart';
import 'package:flutter/material.dart';

Widget actionButtonsBuilder(
    BuildContext buildContext, CaterpillarCrawlMain game) {
  return Align(
    alignment: Alignment.bottomRight,
    child: SizedBox(
      width: game.actionButtonSize * 2 + game.gapRightSide,
      height: game.actionButtonSize * 1.5 + game.gapRightSide,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            circularActionButton(
                game.actionButtonSize,
                0,
                game.actionButtonSize / 2,
                () => game.onFatRounButtonClick(),
                'assets/images/bomb_128_button.png'),
            circularActionButton(
                game.actionButtonSize,
                game.actionButtonSize,
                0,
                () => game.onPewPewButtonclicked(),
                'assets/images/pewpew_128_button.png'),
          ],
        ),
      ),
      // circularActionButton(),
      // circularActionButton(),
    ),
  );
}

Widget circularActionButton(
    double size, double posX, double posY, Function onTap, String pathToImage) {
  return Positioned(
    top: posY,
    left: posX,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          onTap();
        },
        borderRadius: BorderRadius.all(Radius.circular(size / 2)),
        child: IgnorePointer(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.lightGreen,
              ),
              // clipBehavior: Clip.hardEdge,
              child: Image(image: AssetImage(pathToImage)),
            ),
          ),
        ),
      ),
    ),
  );
}
