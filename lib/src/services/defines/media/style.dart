// Flutter imports:
import 'package:flutter/material.dart';

/// Style configuration for media player UI elements.
///
/// Allows customization of icons and text styles for the media player controls.
class ZegoUIKitMediaPlayerStyle {
  /// Custom close icon widget.
  final Widget? closeIcon;

  /// Custom more options icon widget.
  final Widget? moreIcon;

  /// Custom play icon widget.
  final Widget? playIcon;

  /// Custom pause icon widget.
  final Widget? pauseIcon;

  /// Custom volume icon widget.
  final Widget? volumeIcon;

  /// Custom volume mute icon widget.
  final Widget? volumeMuteIcon;

  /// Text style for duration display.
  final TextStyle? durationTextStyle;

  const ZegoUIKitMediaPlayerStyle({
    this.closeIcon,
    this.moreIcon,
    this.playIcon,
    this.pauseIcon,
    this.volumeIcon,
    this.volumeMuteIcon,
    this.durationTextStyle,
  });
}
