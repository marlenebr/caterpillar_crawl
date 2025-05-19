import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class OverlayInfoLabel extends StatelessWidget {
  final Color itemColor;

  final Function? onConfirm;
  final String annotationText;

  final double xPos;
  final double yPos;

  const OverlayInfoLabel(
      {required this.itemColor,
      this.onConfirm,
      super.key,
      required this.annotationText,
      required this.xPos,
      required this.yPos});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: xPos,
      top: yPos,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 250),
        child: Container(
            decoration: BoxDecoration(
                color: itemColor,
                borderRadius: BorderRadius.all(
                    Radius.circular(UIConstants.defaultBorderRadius))),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                    child: Padding(
                        padding:
                            EdgeInsets.all(UIConstants.defaultPaddingMedium),
                        child: Text(
                          annotationText,
                          style: TextStyles.infoLabelTextStyle,
                        ))),
                if (onConfirm != null) ...[
                  IconButton.filled(
                      onPressed: () => onConfirm!(),
                      icon: Icon(
                        Icons.check,
                        color: UiColors.segmentColor,
                      ))
                ]
              ],
            )),
      ),
    );
  }
}
