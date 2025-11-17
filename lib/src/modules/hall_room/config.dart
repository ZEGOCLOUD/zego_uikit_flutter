// Project imports:
import 'package:zego_uikit/src/services/defines/defines.dart';

class ZegoUIKitHallRoomListConfig {
  /// configuration parameters for audio and video streaming, such as Resolution, Frame rate, Bit rate..
  /// default is ZegoUIKitVideoConfig.preset180P()
  final ZegoUIKitVideoConfig? video;

  /// audio video resource mode
  final ZegoUIKitStreamResourceMode? audioVideoResourceMode;

  const ZegoUIKitHallRoomListConfig({
    this.audioVideoResourceMode = ZegoUIKitStreamResourceMode.OnlyRTC,
    this.video,
  });
}
