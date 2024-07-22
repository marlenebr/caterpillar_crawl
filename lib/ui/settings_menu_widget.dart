import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/ui/elements/settings_button_widget.dart';
import 'package:flutter/material.dart';

class SettingsMenuWidget extends StatelessWidget {
  final CaterpillarCrawlMain game;

  const SettingsMenuWidget({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsButtonWidget(
          text: "TUT",
          onTab: () => game.ToggleTutorial(),
        ),
      ],
    );
  }
}
