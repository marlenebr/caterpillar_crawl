import 'package:caterpillar_crawl/ui/elements/settings_button_widget.dart';
import 'package:flutter/material.dart';

class SettingsMenuWidget extends StatelessWidget {
  const SettingsMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsButtonWidget(text: "TEST"),
        SettingsButtonWidget(text: "TUT"),
        SettingsButtonWidget(text: "TTT"),
      ],
    );
  }
}
