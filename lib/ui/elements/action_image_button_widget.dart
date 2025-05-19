import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:flutter/material.dart';

class ActionImageButtonWidget extends StatelessWidget {
  final String? imagePath;
  final Function? onTap;
  final double size;

  const ActionImageButtonWidget(
      {required this.imagePath, super.key, this.onTap, required this.size});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        (onTap != null) ? onTap!() : null;
      },
      highlightColor: const Color.fromARGB(255, 21, 24, 21),
      splashColor: UiColors.tapColor,
      borderRadius: BorderRadius.all(Radius.circular(size / 2)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: UiColors.buttonColor,
          ),
          // clipBehavior: Clip.hardEdge,
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: (imagePath != null && imagePath != "")
                  ? Image(image: AssetImage('assets/images/${imagePath!}'))
                  //const Icon(Icons.opacity)
                  : const Icon(Icons.close)),
        ),
      ),
    );
  }
}
