// Flutter imports:
import 'package:flutter/cupertino.dart';

/// @nodoc
Size getTextSize(String text, TextStyle textStyle) {
  final textPainter = TextPainter(
    text: TextSpan(text: text, style: textStyle),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}
