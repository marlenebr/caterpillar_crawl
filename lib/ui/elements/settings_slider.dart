import 'package:caterpillar_crawl/models/view_models/level_settings_view_model.dart';
import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsSlider<ChangableIntValue> extends StatefulWidget {
  const SettingsSlider(
      {required this.viewModel, required this.text, super.key});

  final ChangableIntValue viewModel;
  final String text;

  @override
  createState() => _SettingsSliderState();
}

class _SettingsSliderState extends State<SettingsSlider> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChangableIntValue>(
        create: (context) => widget.viewModel,
        child: Consumer<ChangableIntValue>(
            builder: (context, cart, child) => Column(
                  children: <Widget>[
                    Text(widget.text, style: TextStyles.uiLabelTextStyle),
                    Slider(
                        min: 1,
                        max: 5000,
                        value: double.parse(widget.viewModel.value.toString()),
                        onChanged: null)
                    //Text('Current value: $widget.viewModel.value'),
                  ],
                )));
  }
}
