import 'dart:math';

import 'package:caterpillar_crawl/models/view_models/action_distance_weapon_view_model.dart';
import 'package:caterpillar_crawl/models/view_models/action_melee_button_view_model.dart';
import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:caterpillar_crawl/ui/elements/action_image_button_widget.dart';
import 'package:flutter/material.dart';

class ActionWeaponButtonWidget extends StatelessWidget {
  final ActionMeleeButtonViewModel actionWeaponButtonViewModel;
  final double size;
  final double posX;
  final double posY;

  const ActionWeaponButtonWidget({
    super.key,
    required this.actionWeaponButtonViewModel,
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
                  actionWeaponButtonViewModel.weaponDuration /
                      actionWeaponButtonViewModel.maxWeaponDuration,
                  actionWeaponButtonViewModel.weaponDuration /
                      actionWeaponButtonViewModel.maxWeaponDuration
                ],
                tileMode: TileMode.decal,
                transform: GradientRotation(-pi / 2)),
            color: Colors.blue,
          ),
          clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Container(
              width: size,
              height: size,
              //clipBehavior: Clip.hardEdge,
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
  final ActionDistanceWeaponViewModel actionWeaponButtonViewModel;

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
