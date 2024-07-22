import 'package:caterpillar_crawl/main.dart';
import 'package:caterpillar_crawl/models/view_models/tutorial_item_view_model.dart';
import 'package:caterpillar_crawl/models/view_models/tutorial_mode_view_model.dart';
import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:caterpillar_crawl/ui/elements/hud_overlay_attention_marker.dart';
import 'package:caterpillar_crawl/ui/elements/hud_overlay_info_label.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TutorialOverlayWidget extends StatefulWidget {
  final CaterpillarCrawlMain game;

  TutorialOverlayWidget({required this.game, super.key});

  @override
  State<TutorialOverlayWidget> createState() => _TutorialOverlayWidgetState();
}

class _TutorialOverlayWidgetState extends State<TutorialOverlayWidget> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TutorialModeViewModel>(
      create: (context) => widget.game.tutorialModeViewModel,
      child: Consumer<TutorialModeViewModel>(
        builder: (context, cart, child) => Offstage(
          offstage: !widget.game.tutorialModeViewModel.isInTutorialMode,
          child: ChangeNotifierProvider<TutorialItemViewModel>(
            create: (context) => widget.game.tutorialItemViewModel,
            child: Consumer<TutorialItemViewModel>(
              builder: (context, cart, child) => Stack(children: [
                OverlayInfoLabel(
                    xPos: 150,
                    yPos: 60,
                    itemColor:
                        widget.game.tutorialItemViewModel.conditionReached
                            ? UiColors.segmentColor!
                            : UiColors.enemyUiColor!,
                    annotationText:
                        widget.game.tutorialItemViewModel.annotationText,
                    onConfirm: () async {
                      if (widget.game.tutorialItemViewModel.conditionReached) {
                        await widget
                            .game.tutorialItemViewModel.callbackToConfirm!();
                      }
                    }),
                if (widget.game.tutorialItemViewModel
                        .absolutePositionOfAttentionWidget !=
                    null) ...[
                  OverlayAttentionMarkerWidget(
                    shakeKey: widget.game.tutorialItemViewModel.shakeKey,
                    xPos: widget.game.tutorialItemViewModel
                        .absolutePositionOfAttentionWidget!.x,
                    yPos: widget.game.tutorialItemViewModel
                        .absolutePositionOfAttentionWidget!.y,
                  )
                ]
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
