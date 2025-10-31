// Project imports:
import 'package:zego_uikit/src/modules/outside_room_audio_video/controller.dart';
import 'package:zego_uikit/src/services/defines/defines.dart';

/// play mode
enum ZegoOutsideRoomAudioVideoViewListPlayMode {
  /// All streams (video and audio) in visible area will be automatically played internally.
  autoPlay,

  /// Control the play timing by yourself, and you need to manually call the API to play the stream (video and audio).
  /// [ZegoOutsideRoomAudioVideoViewListController]
  /// - startPlayOne
  /// - stopPlayOne
  /// - startPlayAll
  /// - stopPlayAll
  manualPlay,
}

class ZegoOutsideRoomAudioVideoViewListConfig {
  /// mode, default autoplay
  /// If you want to manually control, set it to manualPlay, and call the APIs of [ZegoOutsideRoomAudioVideoViewListController] to control it.
  final ZegoOutsideRoomAudioVideoViewListPlayMode playMode;

  /// configuration parameters for audio and video streaming, such as Resolution, Frame rate, Bit rate..
  /// default is ZegoUIKitVideoConfig.preset180P()
  final ZegoUIKitVideoConfig? video;

  /// audio video resource mode
  final ZegoAudioVideoResourceMode? audioVideoResourceMode;

  const ZegoOutsideRoomAudioVideoViewListConfig({
    this.playMode = ZegoOutsideRoomAudioVideoViewListPlayMode.autoPlay,
    this.audioVideoResourceMode = ZegoAudioVideoResourceMode.onlyRTC,
    this.video,
  });
}
