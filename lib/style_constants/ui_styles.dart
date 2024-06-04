import 'dart:ui';

import 'package:flutter/material.dart';

class UiColors {
  static Color? enemyUiColor = Colors.orange[700];
  static Color? levelColor = Colors.pink;

  static Color? segmentColor = Colors.lightGreenAccent[400];
  static Color? buttonColor = Colors.lightBlue[400];
  static Color? tapColor = Colors.lime;
}

class TextStyles {
  static double textSize = 16;
  static double iconSize = 16;
  static Color textColor = Colors.white;

  static TextStyle uiLabelTextStyle =
      TextStyle(fontSize: TextStyles.textSize, color: TextStyles.textColor);
}

class UIConstants {
  static double iconSize = 16;
  static double iconSizeMedium = 32;

  static double endOfScreenPadding = 3;
}
