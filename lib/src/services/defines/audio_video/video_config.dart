import 'package:zego_express_engine/zego_express_engine.dart';

extension ZegoVideoConfigExtension on ZegoVideoConfig {
  static ZegoVideoConfig preset180P() {
    return ZegoVideoConfig(
      180,
      320,
      180,
      320,
      15,
      300,
      ZegoVideoCodecID.Default,
    );
  }

  static ZegoVideoConfig preset270P() {
    return ZegoVideoConfig(
      270,
      480,
      270,
      480,
      15,
      400,
      ZegoVideoCodecID.Default,
    );
  }

  static ZegoVideoConfig preset360P() {
    return ZegoVideoConfig(
      360,
      640,
      360,
      640,
      15,
      600,
      ZegoVideoCodecID.Default,
    );
  }

  static ZegoVideoConfig preset540P() {
    return ZegoVideoConfig(
      540,
      960,
      540,
      960,
      15,
      1200,
      ZegoVideoCodecID.Default,
    );
  }

  static ZegoVideoConfig preset720P() {
    return ZegoVideoConfig(
      720,
      1280,
      720,
      1280,
      15,
      1500,
      ZegoVideoCodecID.Default,
    );
  }

  static ZegoVideoConfig preset1080P() {
    return ZegoVideoConfig(
      1080,
      1920,
      1080,
      1920,
      15,
      3000,
      ZegoVideoCodecID.Default,
    );
  }

  static ZegoVideoConfig preset2K() {
    return ZegoVideoConfig(
      1440,
      2560,
      1440,
      2560,
      15,
      6000,
      ZegoVideoCodecID.Default,
    );
  }

  static ZegoVideoConfig preset4K() {
    return ZegoVideoConfig(
      2160,
      3840,
      2160,
      3840,
      15,
      12000,
      ZegoVideoCodecID.Default,
    );
  }

  String toStringX() {
    return 'ZegoUIKitVideoConfig{'
        'fps:$fps, '
        'bitrate:$bitrate, '
        'captureWidth:$captureWidth, '
        'captureHeight:$captureHeight, '
        'encodeWidth:$encodeWidth, '
        'encodeHeight:$encodeHeight, '
        '}';
  }
}
