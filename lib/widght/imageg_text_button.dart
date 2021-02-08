import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IconTextButton extends StatelessWidget {
  const IconTextButton({
    required this.icon,
    this.iconSize = 20.0,
    this.text,
    this.textStyle,
    this.onTap,
    this.orientation = WidgetOrientation.vertical,
  });

  final GestureTapCallback? onTap;
  final IconData? icon;
  final double iconSize;
  final String? text;
  final TextStyle? textStyle;
  final WidgetOrientation? orientation;

  @override
  Widget build(BuildContext context) {
    var defaultTextStyle =
        textStyle ?? TextStyle(color: Colors.white, fontSize: 13);
    var iconWidget = Icon(icon, size: iconSize, color: Colors.white);
    return CupertinoButton(
      onPressed: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        child: orientation == WidgetOrientation.horizontal
            ? Row(children: [
                iconWidget,
                const SizedBox(width: 10),
                Text(text ?? "", style: defaultTextStyle),
              ])
            : Column(children: [
                iconWidget,
                const SizedBox(height: 10),
                Text(text ?? "", style: defaultTextStyle),
              ]),
      ),
      // customBorder: CircleBorder(),
    );
  }
}

enum WidgetOrientation { horizontal, vertical }
