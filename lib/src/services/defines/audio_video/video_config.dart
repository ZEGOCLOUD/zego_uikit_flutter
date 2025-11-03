import 'package:zego_express_engine/zego_express_engine.dart';

///  configuration parameters for audio and video streaming, such as Resolution, Frame rate, Bit rate..
class ZegoUIKitVideoConfig {
  /// Frame rate, control the frame rate of the camera and the frame rate of the encoder.
  int fps;

  /// Bit rate in kbps.
  int bitrate;

  /// resolution width, control the image width of camera image acquisition or encoder when publishing stream.
  int width;

  /// resolution height, control the image height of camera image acquisition or encoder when publishing stream.
  int height;

  ZegoUIKitVideoConfig({
    required this.bitrate,
    required this.fps,
    required this.width,
    required this.height,
  });

  ZegoUIKitVideoConfig.preset180P()
      : width = 180,
        height = 320,
        bitrate = 300,
        fps = 15;

  ZegoUIKitVideoConfig.preset270P()
      : width = 270,
        height = 480,
        bitrate = 400,
        fps = 15;

  ZegoUIKitVideoConfig.preset360P()
      : width = 360,
        height = 640,
        bitrate = 600,
        fps = 15;

  ZegoUIKitVideoConfig.preset540P()
      : width = 540,
        height = 960,
        bitrate = 1200,
        fps = 15;

  ZegoUIKitVideoConfig.preset720P()
      : width = 720,
        height = 1280,
        bitrate = 1500,
        fps = 15;

  ZegoUIKitVideoConfig.preset1080P()
      : width = 1080,
        height = 1920,
        bitrate = 3000,
        fps = 15;

  ZegoUIKitVideoConfig.preset2K()
      : width = 1440,
        height = 2560,
        bitrate = 6000,
        fps = 15;

  ZegoUIKitVideoConfig.preset4K()
      : width = 2160,
        height = 3840,
        bitrate = 12000,
        fps = 15;

  ZegoVideoConfig get toSDK {
    final videoConfig = ZegoVideoConfig.preset(
      ZegoVideoConfigPreset.Preset360P,
    );

    videoConfig.bitrate = bitrate;
    videoConfig.fps = fps;

    videoConfig.encodeWidth = width;
    videoConfig.captureWidth = width;

    videoConfig.encodeHeight = height;
    videoConfig.captureHeight = height;

    return videoConfig;
  }

  @override
  String toString() {
    return 'ZegoUIKitVideoConfig{'
        'fps:$fps, '
        'bitrate:$bitrate, '
        'width:$width, '
        'height:$height, '
        '}';
  }
}
