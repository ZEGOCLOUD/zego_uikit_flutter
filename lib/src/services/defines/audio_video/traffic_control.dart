/// Traffic control property (bitmask enumeration).
enum ZegoUIKitTrafficControlProperty {
  /// Basic (Adaptive (reduce) video bitrate)
  basic,

  /// Adaptive (reduce) video FPS
  adaptiveFPS,

  /// Adaptive (reduce) video resolution
  adaptiveResolution,

  /// Adaptive (reduce) audio bitrate
  adaptiveAudioBitrate,
}

extension ZegoUIKitTrafficControlPropertyExtension
    on ZegoUIKitTrafficControlProperty {
  int get value {
    switch (this) {
      case ZegoUIKitTrafficControlProperty.basic:
        return 0;
      case ZegoUIKitTrafficControlProperty.adaptiveFPS:
        return 1;
      case ZegoUIKitTrafficControlProperty.adaptiveResolution:
        return 1 << 1;
      case ZegoUIKitTrafficControlProperty.adaptiveAudioBitrate:
        return 1 << 2;
    }
  }
}
