// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/components/widgets/slider.dart';
import 'package:zego_uikit/src/services/services.dart';

/// @nodoc
class ZegoBeautyEffectSlider extends StatefulWidget {
  final BeautyEffectType effectType;
  final int defaultValue;

  final double? thumpHeight;
  final double? trackHeight;
  final String Function(int)? labelFormatFunc;

  /// the style of the text displayed on the Slider's thumb
  final TextStyle? textStyle;

  /// the background color of the text displayed on the Slider's thumb.
  final Color? textBackgroundColor;

  ///  the color of the track that is active when sliding the Slider.
  final Color? activeTrackColor;

  /// the color of the track that is inactive when sliding the Slider.
  final Color? inactiveTrackColor;

  /// the color of the Slider's thumb.
  final Color? thumbColor;

  /// the radius of the Slider's thumb.
  final double? thumbRadius;

  const ZegoBeautyEffectSlider({
    super.key,
    required this.effectType,
    required this.defaultValue,
    this.thumpHeight,
    this.trackHeight,
    this.labelFormatFunc,
    this.textStyle,
    this.textBackgroundColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.thumbRadius,
  });

  @override
  State<ZegoBeautyEffectSlider> createState() => _ZegoBeautyEffectSliderState();
}

/// @nodoc
class _ZegoBeautyEffectSliderState extends State<ZegoBeautyEffectSlider> {
  @override
  Widget build(BuildContext context) {
    return ZegoSlider(
      defaultValue: widget.defaultValue,
      onChanged: (double value) {
        ZegoUIKit().setBeautifyValue(value.toInt(), widget.effectType);
      },
      thumpHeight: widget.thumpHeight,
      trackHeight: widget.trackHeight,
      labelFormatFunc: widget.labelFormatFunc,
      textStyle: widget.textStyle,
      textBackgroundColor: widget.textBackgroundColor,
      activeTrackColor: widget.activeTrackColor,
      inactiveTrackColor: widget.inactiveTrackColor,
      thumbColor: widget.thumbColor,
      thumbRadius: widget.thumbRadius,
    );
  }
}
