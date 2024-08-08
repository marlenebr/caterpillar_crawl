import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/view_models/action_melee_button_view_model.dart';
import 'package:caterpillar_crawl/models/view_models/action_distance_weapon_view_model.dart';
import 'package:caterpillar_crawl/ui/elements/action_weapon_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActionWeaponButtonView extends StatefulWidget {
  final ActionMeleeButtonViewModel meleeButtonViewModel;
  final ActionDistanceWeaponViewModel distanceWeaponViewModel;

  final CaterpillarCrawlMain mainGame;
  final double actionButtonSize;

  const ActionWeaponButtonView({
    required this.meleeButtonViewModel,
    super.key,
    required this.distanceWeaponViewModel,
    required this.mainGame,
    required this.actionButtonSize,
  });
  @override
  createState() => _ActionWeaponButtonViewState();
}

class _ActionWeaponButtonViewState extends State<ActionWeaponButtonView> {
  _ActionWeaponButtonViewState();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ChangeNotifierProvider<ActionDistanceWeaponViewModel>(
          create: (context) => widget.distanceWeaponViewModel,
          child: Consumer<ActionDistanceWeaponViewModel>(
            builder: (context, cart, child) => SimpleActionButtonWidget(
              key: widget.distanceWeaponViewModel.globalKey,
              actionWeaponButtonViewModel: widget.distanceWeaponViewModel,
              size: widget.actionButtonSize,
              posX: 0,
              posY: widget.actionButtonSize / 2,
            ),
          ),
        ),
        ChangeNotifierProvider<ActionMeleeButtonViewModel>(
          create: (context) => widget.meleeButtonViewModel,
          child: Consumer<ActionMeleeButtonViewModel>(
            builder: (context, cart, child) => ActionWeaponButtonWidget(
              key: widget.meleeButtonViewModel.globalKey,
              actionWeaponButtonViewModel: widget.meleeButtonViewModel,
              size: widget.actionButtonSize,
              posX: widget.actionButtonSize,
              posY: 0,
            ),
          ),
        ),
      ],
    );
  }
}
