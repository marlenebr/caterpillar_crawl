import 'package:caterpillar_crawl/models/view_models/level_settings_view_model.dart';
import 'package:caterpillar_crawl/style_constants/ui_styles.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

class SettingsNumberPicker<ChangableIntValue> extends StatefulWidget {
  final ChangableIntValue viewModel;
  final int minValue;
  final int maxValue;

  final String text;

  final int step;

  const SettingsNumberPicker(
      {super.key,
      required this.viewModel,
      required this.text,
      required this.minValue,
      required this.maxValue,
      this.step = 1});
  @override
  createState() => _SettingsNumberPicker();
}

class _SettingsNumberPicker extends State<SettingsNumberPicker> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChangableIntValue>(
        create: (context) => widget.viewModel,
        child: Consumer<ChangableIntValue>(
            builder: (context, cart, child) => Column(
                  children: <Widget>[
                    Text(widget.text, style: TextStyles.uiLabelTextStyle),
                    NumberPicker(
                      value: widget.viewModel.value,
                      axis: Axis.horizontal,
                      itemHeight: 60,
                      minValue: widget.minValue,
                      maxValue: widget.maxValue,
                      onChanged: (value) =>
                          setState(() => widget.viewModel.setValue(value)),
                      step: widget.step,
                    ),
                    //Text('Current value: $widget.viewModel.value'),
                  ],
                )));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
