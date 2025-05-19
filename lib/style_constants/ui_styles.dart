import 'dart:ui';

import 'package:flutter/material.dart';

class UiColors {
  static Color? enemyUiColor = Colors.orange[700];
  static Color? levelColor = Colors.pink;

  static Color? segmentColor = Colors.lightGreenAccent[400];
  static Color? buttonColor = Colors.lightBlue[400];
  static Color? tapColor = Colors.lime;

  static Color? darkLineColor = const Color.fromARGB(96, 41, 11, 241);
}

class TextStyles {
  static double textSizeBig = UIConstants.iconSize;
  static double textSizeMedium = 16;
  static double textSizeSmall = 12;

  static double iconSize = UIConstants.iconSize;
  static Color textColor = Colors.white;

  static TextStyle uiLabelTextStyle =
      TextStyle(fontSize: TextStyles.textSizeBig, color: TextStyles.textColor);

  static TextStyle infoLabelTextStyle = TextStyle(
      fontSize: TextStyles.textSizeMedium, color: UiColors.darkLineColor);
}

class UIConstants {
  static double iconSize = 24;
  static double iconSizeMedium = 32;

  static double imageSizeSmall = 64;

  static double endOfScreenPadding = 3;
  static double defaultPaddingMedium = 5;

  static double defaultBorderRadius = 8;
}
