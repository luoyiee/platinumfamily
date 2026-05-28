import 'package:flutter/material.dart';

class HorizontalGradientText extends StatelessWidget {
  const HorizontalGradientText(this.text, {
        super.key,
        required this.colors,
        this.style,
        this.textAlign,
      });

  final String text;
  final List<Color> colors;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        textAlign: textAlign,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
      ),
    );
  }
}