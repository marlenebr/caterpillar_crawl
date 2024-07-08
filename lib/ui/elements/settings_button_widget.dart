import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class SettingsButtonWidget extends StatelessWidget {
  String text;
  SettingsButtonWidget({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
        onPressed: () => (),
        label: Text(text),
        icon: const Icon(Icons.accessibility_sharp));
  }
}
