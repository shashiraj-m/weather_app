import 'package:flutter/material.dart';

class CustomText extends StatefulWidget {
  final String? text;
  final Color? color;
  final double? textSize;
  final FontWeight? fontWeight;
  final double? letterSpacing;
  final TextAlign? textAlign;
  final double? height;
  final TextDecoration? decoration;

  const CustomText({
    required this.text,
    Key? key,
    this.color,
    this.textSize,
    this.fontWeight,
    this.letterSpacing,
    this.textAlign,
    this.height,
    this.decoration,
  }) : super(key: key);

  @override
  State<CustomText> createState() => _CustomText();
}

class _CustomText extends State<CustomText> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text ?? '',
      textAlign: widget.textAlign ?? TextAlign.start,
      style: TextStyle(
        color: widget.color,
        fontSize: widget.textSize ?? ColorsConst.instance.textMedium,
        fontWeight: widget.fontWeight ?? FontWeight.normal,
        letterSpacing: widget.letterSpacing ?? 0,
        // fontFamily: 'Nunito',
        height: widget.height,
        decoration: widget.decoration,
      ),
    );
  }
}

class ColorsConst {
  ColorsConst._();

  static final instance = ColorsConst._();

  /// Font family
  String fontFamily = 'Nunito';

  /// Font size
  double textSmall = 12.0;
  double textMedium = 14.0;
  double textLarge = 16.0;
  double header = 30.0;
}
