import 'package:flutter/material.dart';

// This class is a widget that formats the text in a nice manner/
class TextWidget extends StatelessWidget {
  const TextWidget(
      {Key? key,
      required this.label,
      this.fontSize = 18,
      this.color,
      this.fontWeight})
      : super(key: key);

  final String label;
  final double fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: color ?? Colors.black,
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.w300,
      ),
    );
  }
}
