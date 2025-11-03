// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class ZegoUIKitMediaPlayerStyle {
  final Widget? closeIcon;
  final Widget? moreIcon;
  final Widget? playIcon;
  final Widget? pauseIcon;
  final Widget? volumeIcon;
  final Widget? volumeMuteIcon;
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
