import 'dart:math';

import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:flutter/material.dart';

class OverlayAttentionMarkerWidget extends StatelessWidget {
  OverlayAttentionMarkerWidget(
      {super.key,
      required this.xPos,
      required this.yPos,
      required this.shakeKey});

  final double xPos;
  final double yPos;

  final GlobalKey<ShakeWidgetState> shakeKey;

  @override
  Widget build(BuildContext context) {
    shakeKey.currentState?.shake();
    // TODO: implement build
    return Positioned(
      left: xPos,
      top: yPos,
      child: IgnorePointer(
          child: SizedBox(
              width: 32,
              height: 32,
              child: ShakeWidget(
                key: shakeKey,
                child: Container(
                    color: UiColors.darkLineColor,
                    child: Icon(
                      Icons.star_purple500_sharp,
                      color: UiColors.tapColor,
                    )),
                shakeCount: 300,
                shakeOffset: 10,
                shakeDuration: Duration(seconds: 500),
              ))),
    );
  }
}

//------

abstract class AnimationControllerState<T extends StatefulWidget>
    extends State<T> with SingleTickerProviderStateMixin {
  AnimationControllerState(this.animationDuration);
  final Duration animationDuration;
  late final animationController =
      AnimationController(vsync: this, duration: animationDuration);

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

class ShakeWidget extends StatefulWidget {
  const ShakeWidget({
    Key? key,
    required this.child,
    required this.shakeOffset,
    this.shakeCount = 3,
    this.shakeDuration = const Duration(milliseconds: 400),
  }) : super(key: key);
  final Widget child;
  final double shakeOffset;
  final int shakeCount;
  final Duration shakeDuration;

  @override
  ShakeWidgetState createState() => ShakeWidgetState(shakeDuration);
}

class ShakeWidgetState extends AnimationControllerState<ShakeWidget> {
  ShakeWidgetState(Duration duration) : super(duration);

  @override
  void initState() {
    super.initState();
    shake();
  }

  void shake() {
    print("SHAKE");
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // 1. return an AnimatedBuilder
    return AnimatedBuilder(
      // 2. pass our custom animation as an argument
      animation: animationController,
      // 3. optimization: pass the given child as an argument
      child: widget.child,
      builder: (context, child) {
        final sineValue =
            sin(widget.shakeCount * 2 * pi * animationController.value);
        return Transform.translate(
          // 4. apply a translation as a function of the animation value
          offset: Offset(sineValue * widget.shakeOffset, 0),
          // 5. use the child widget
          child: child,
        );
      },
    );
  }
}

// class OverlayAttentionMarker extends StatelessWidget {
//   const OverlayAttentionMarker(
//       {super.key, required this.xPos, required this.yPos});

//   final double xPos;
//   final double yPos;

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       left: xPos,
//       top: yPos,
//       child: IgnorePointer(
//         child: Container(
//             color: UiColors.enemyUiColor,
//             width: 32,
//             height: 32,
//             child: Icon(Icons.star)),
//       ),
//     );
//   }
// }
