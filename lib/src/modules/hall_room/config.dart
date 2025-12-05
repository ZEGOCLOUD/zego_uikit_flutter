// Project imports:
import 'package:zego_uikit/src/services/defines/defines.dart';
import 'model.dart';

class ZegoUIKitHallRoomListConfig {
  /// configuration parameters for audio and video streaming, such as Resolution, Frame rate, Bit rate..
  /// default is ZegoUIKitVideoConfig.preset180P()
  final ZegoUIKitVideoConfig? video;

  final ZegoUIKitHallRoomStreamMode streamMode;

  /// audio video resource mode
  final ZegoUIKitStreamResourceMode? audioVideoResourceMode;

  const ZegoUIKitHallRoomListConfig({
    this.streamMode = ZegoUIKitHallRoomStreamMode.preloaded,
    this.audioVideoResourceMode = ZegoUIKitStreamResourceMode.OnlyRTC,
    this.video,
  });

  @override
  String toString() {
    return '{'
        'streamMode:$streamMode, '
        'audioVideoResourceMode:$audioVideoResourceMode, '
        'video:$video, '
        '}';
  }
}
