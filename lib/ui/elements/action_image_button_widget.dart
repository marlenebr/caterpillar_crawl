import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:flutter/material.dart';

class ActionImageButtonWidget extends StatelessWidget {
  final String imagePath;
  final Function onTap;
  final double size;

  const ActionImageButtonWidget(
      {required this.imagePath,
      super.key,
      required this.onTap,
      required this.size});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      highlightColor: const Color.fromARGB(255, 21, 24, 21),
      splashColor: UiColors.tapColor,
      borderRadius: BorderRadius.all(Radius.circular(size / 2)),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: UiColors.buttonColor,
          ),
          // clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Image(
              image: AssetImage(imagePath),
            ),
            // ),
          ),
        ),
      ),
    );
  }
}
