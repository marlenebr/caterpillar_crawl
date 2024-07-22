import 'dart:math';

import 'package:caterpillar_crawl/models/view_models/action_weapon_button_view_model.dart';
import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:caterpillar_crawl/ui/elements/action_image_button_widget.dart';
import 'package:flutter/material.dart';

class ActionWeaponButtonWidget extends StatelessWidget {
  final ActionUltiAndDistanceButtonViewModel actionWeaponButtonViewModel;
  final double size;
  final double posX;
  final double posY;

  final int segmentsToUlti;
  final int enemyKillsToUlti;

  const ActionWeaponButtonWidget({
    super.key,
    required this.actionWeaponButtonViewModel,
    required this.segmentsToUlti,
    required this.enemyKillsToUlti,
    required this.size,
    required this.posX,
    required this.posY,
  });

  @override
  Widget build(BuildContext context) {
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
                    actionWeaponButtonViewModel.segmentCount / segmentsToUlti,
                    actionWeaponButtonViewModel.segmentCount / segmentsToUlti
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
                        actionWeaponButtonViewModel.enemyKilledSinceUlti /
                            enemyKillsToUlti,
                        actionWeaponButtonViewModel.enemyKilledSinceUlti /
                            enemyKillsToUlti
                      ],
                      tileMode: TileMode.decal,
                      transform: GradientRotation(-pi / 2))
                  // color: Colors.blue,
                  ),
              // color: Colors.blue,
              clipBehavior: Clip.hardEdge,
              child: ActionImageButtonWidget(
                imagePath: actionWeaponButtonViewModel.imagePath,
                onTap: actionWeaponButtonViewModel.onTab,
                size: size,
              ),
            ),
          ),
        ));
  }
}

class SimpleActionButtonWidget extends StatelessWidget {
  final ActionMeleeWeaponButtonViewModel actionWeaponButtonViewModel;

  final double posX;
  final double posY;
  final double size;

  const SimpleActionButtonWidget(
      {super.key,
      required this.posX,
      required this.posY,
      required this.size,
      required this.actionWeaponButtonViewModel});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: posY,
      left: posX,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: ActionImageButtonWidget(
          imagePath: actionWeaponButtonViewModel.imagePath,
          onTap: actionWeaponButtonViewModel.onTab,
          size: size,
        ),
      ),
    );
  }
}
