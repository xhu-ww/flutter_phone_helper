import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LabelPageSelector extends StatefulWidget {
  final List<String> labels;
  final ValueChanged<int> onSelectedChanged;
  final int groupValue;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? labelPadding;
  final Color? unselectedColor;
  final Color? selectedColor;
  final Color? borderColor;
  final Color? pressedColor;

  const LabelPageSelector(this.labels,
      {Key? key,
      required this.onSelectedChanged,
      this.unselectedColor,
      this.selectedColor,
      this.borderColor,
      this.pressedColor,
      this.height,
      this.borderRadius,
      this.labelPadding,
      this.groupValue = 0})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _LabelPageSelectorState();
}

class _LabelPageSelectorState extends State<LabelPageSelector> {
  Map<int, Widget> children = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.labels.length; i++) {
      children[i] = _buildLabelText(widget.labels[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoSegmentedControl<int>(
      onValueChanged: widget.onSelectedChanged,
      groupValue: widget.groupValue,
      borderColor: widget.borderColor,
      selectedColor: widget.selectedColor,
      unselectedColor: widget.unselectedColor,
      pressedColor: widget.pressedColor,
      children: children,
    );
  }

  Widget _buildLabelText(String content) {
    return Container(
      height: widget.height,
      alignment: Alignment.center,
      padding: widget.labelPadding,
      child: Text(content, style: TextStyle(color: Colors.white)),
    );
  }
}
