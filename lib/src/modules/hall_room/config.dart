// Project imports:
import 'package:zego_uikit/src/modules/hall_room/controller.dart';
import 'package:zego_uikit/src/services/defines/defines.dart';

/// play mode
enum ZegoUIKitHallRoomListPlayMode {
  /// All streams (video and audio) in visible area will be automatically played internally.
  autoPlay,

  /// Control the play timing by yourself, and you need to manually call the API to play the stream (video and audio).
  /// [ZegoUIKitHallRoomListController]
  /// - startPlayOne
  /// - stopPlayOne
  /// - startPlayAll
  /// - stopPlayAll
  manualPlay,
}

class ZegoUIKitHallRoomListConfig {
  /// mode, default autoplay
  /// If you want to manually control, set it to manualPlay, and call the APIs of [ZegoUIKitHallRoomListController] to control it.
  final ZegoUIKitHallRoomListPlayMode playMode;

  /// configuration parameters for audio and video streaming, such as Resolution, Frame rate, Bit rate..
  /// default is ZegoUIKitVideoConfig.preset180P()
  final ZegoUIKitVideoConfig? video;

  /// audio video resource mode
  final ZegoUIKitStreamResourceMode? audioVideoResourceMode;

  const ZegoUIKitHallRoomListConfig({
    this.playMode = ZegoUIKitHallRoomListPlayMode.autoPlay,
    this.audioVideoResourceMode = ZegoUIKitStreamResourceMode.OnlyRTC,
    this.video,
  });
}
