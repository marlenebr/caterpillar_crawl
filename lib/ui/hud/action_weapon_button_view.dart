import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/view_models/action_weapon_button_view_model.dart';
import 'package:caterpillar_crawl/ui/elements/action_weapon_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActionWeaponButtonView extends StatefulWidget {
  final ActionMeleeWeaponButtonViewModel meleeButtonViewModel;
  final ActionUltiAndDistanceButtonViewModel ultiButtonViewModel;

  final CaterpillarCrawlMain mainGame;
  final double actionButtonSize;

  const ActionWeaponButtonView({
    required this.meleeButtonViewModel,
    super.key,
    required this.ultiButtonViewModel,
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
        ChangeNotifierProvider<ActionUltiAndDistanceButtonViewModel>(
          create: (context) => widget.ultiButtonViewModel,
          child: Consumer<ActionUltiAndDistanceButtonViewModel>(
            builder: (context, cart, child) => ActionWeaponButtonWidget(
              key: widget.ultiButtonViewModel.globalKey,
              actionWeaponButtonViewModel: widget.ultiButtonViewModel,
              enemyKillsToUlti: widget.mainGame.enemyKillsToUlti,
              segmentsToUlti: widget.mainGame.segmentsToUlti,
              size: widget.actionButtonSize,
              posX: 0,
              posY: widget.actionButtonSize / 2,
            ),
          ),
        ),
        ChangeNotifierProvider<ActionMeleeWeaponButtonViewModel>(
          create: (context) => widget.meleeButtonViewModel,
          child: Consumer<ActionMeleeWeaponButtonViewModel>(
            builder: (context, cart, child) => SimpleActionButtonWidget(
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
