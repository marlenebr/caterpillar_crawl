import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class SettingsButtonWidget extends StatelessWidget {
  String text;
  Function onTab;
  SettingsButtonWidget({required this.text, required this.onTab, super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
        onPressed: () => onTab(),
        label: Text(text),
        icon: const Icon(Icons.accessibility_sharp));
  }
}
