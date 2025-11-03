import 'package:flutter/services.dart';
import 'package:zego_uikit/src/services/defines/express.dart';

/// @nodoc
// video config
class ZegoUIKitVideoInternalConfig {
  ZegoUIKitVideoInternalConfig({
    this.resolution = ZegoPresetResolution.Preset360P,
    this.orientation = DeviceOrientation.portraitUp,
  });

  ZegoPresetResolution resolution;
  DeviceOrientation orientation;

  bool needUpdateOrientation(ZegoUIKitVideoInternalConfig newConfig) {
    return orientation != newConfig.orientation;
  }

  bool needUpdateVideoConfig(ZegoUIKitVideoInternalConfig newConfig) {
    return (resolution != newConfig.resolution) ||
        (orientation != newConfig.orientation);
  }

  ZegoUIKitVideoConfig toZegoVideoConfig() {
    final config = ZegoUIKitVideoConfig.preset(resolution);
    if (orientation == DeviceOrientation.landscapeLeft ||
        orientation == DeviceOrientation.landscapeRight) {
      var tmp = config.captureHeight;
      config
        ..captureHeight = config.captureWidth
        ..captureWidth = tmp;

      tmp = config.encodeHeight;
      config
        ..encodeHeight = config.encodeWidth
        ..encodeWidth = tmp;
    }
    return config;
  }

  ZegoUIKitVideoInternalConfig copyWith({
    ZegoPresetResolution? resolution,
    DeviceOrientation? orientation,
  }) =>
      ZegoUIKitVideoInternalConfig(
        resolution: resolution ?? this.resolution,
        orientation: orientation ?? this.orientation,
      );
}
