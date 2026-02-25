// Flutter imports:
import 'package:flutter/material.dart';

/// Settings for countdown stop behavior in screen sharing.
///
/// Used to configure countdown timer that stops screen sharing after a specified duration.
class ZegoScreenSharingCountDownStopSettings {
  /// Whether to support countdown stop feature.
  bool support = false;

  /// Tips displayed during countdown.
  String tips = 'screen sharing may have ended and will automatically stop';

  /// Countdown duration in seconds.
  int seconds = 10;

  /// Text color for countdown display.
  Color? textColor;

  /// Progress color for countdown indicator.
  Color? progressColor;

  /// Font size for seconds display.
  double? secondFontSize;

  /// Font size for tips display.
  double? tipsFontSize;

  /// Notifier to control countdown start.
  final countDownStartNotifier = ValueNotifier<bool>(false);

  /// Callback when countdown finishes.
  VoidCallback? onCountDownFinished;
}

/// Settings for auto stop behavior in screen sharing.
///
/// Used to configure automatic stop of screen sharing based on validity checks.
class ZegoScreenSharingAutoStopSettings {
  /// Count of the check fails before automatically end the screen sharing
  int invalidCount = 3;

  /// Determines whether to end;
  /// returns false if you don't want to end
  bool Function()? canEnd;
}
