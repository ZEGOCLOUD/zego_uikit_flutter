// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

export 'stream_type.dart';
export 'sei.dart';
export 'traffic_control.dart';
export 'video_config.dart';

String get attributeKeyAvatar => 'avatar';

class ZegoUIKitReceiveTurnOnLocalMicrophoneEvent {
  final String fromUserID;
  final bool muteMode;

  ZegoUIKitReceiveTurnOnLocalMicrophoneEvent(this.fromUserID, this.muteMode);

  @override
  String toString() {
    return 'from user id:$fromUserID, mute mode:$muteMode';
  }
}

/// Published stream quality information.
///
/// Audio and video parameters and network quality, etc.
class ZegoUIKitPublishStreamQuality {
  /// Video capture frame rate. The unit of frame rate is f/s
  double videoCaptureFPS;

  /// Video encoding frame rate. The unit of frame rate is f/s
  double videoEncodeFPS;

  /// Video transmission frame rate. The unit of frame rate is f/s
  double videoSendFPS;

  /// Video bit rate in kbps
  double videoKBPS;

  /// Audio capture frame rate. The unit of frame rate is f/s
  double audioCaptureFPS;

  /// Audio transmission frame rate. The unit of frame rate is f/s
  double audioSendFPS;

  /// Audio bit rate in kbps
  double audioKBPS;

  /// Local to server delay, in milliseconds
  int rtt;

  /// Packet loss rate, in percentage, 0.0 ~ 1.0
  double packetLostRate;

  /// Published stream quality level
  ZegoStreamQualityLevel level;

  /// Whether to enable hardware encoding
  bool isHardwareEncode;

  /// Video codec ID (Available since 1.17.0)
  ZegoVideoCodecID videoCodecID;

  /// Total number of bytes sent, including audio, video, SEI
  double totalSendBytes;

  /// Number of audio bytes sent
  double audioSendBytes;

  /// Number of video bytes sent
  double videoSendBytes;

  ZegoUIKitPublishStreamQuality(
    this.videoCaptureFPS,
    this.videoEncodeFPS,
    this.videoSendFPS,
    this.videoKBPS,
    this.audioCaptureFPS,
    this.audioSendFPS,
    this.audioKBPS,
    this.rtt,
    this.packetLostRate,
    this.level,
    this.isHardwareEncode,
    this.videoCodecID,
    this.totalSendBytes,
    this.audioSendBytes,
    this.videoSendBytes,
  );
}

/// Playing stream status.
enum ZegoUIKitPlayerState {
  /// The state of the flow is not played, and it is in this state before the stream is played. If the steady flow anomaly occurs during the playing process, such as AppID or Token are incorrect, it will enter this state.
  noPlay,

  /// The state that the stream is being requested for playing. After the [startPlayingStream] function is successfully called, it will enter the state. The UI is usually displayed through this state. If the connection is interrupted due to poor network quality, the SDK will perform an internal retry and will return to the requesting state.
  playRequesting,

  /// The state that the stream is being playing, entering the state indicates that the stream has been successfully played, and the user can communicate normally.
  playing
}

extension ZegoUIKitPlayerStateExtension on ZegoUIKitPlayerState {
  static ZegoUIKitPlayerState fromZego(ZegoPlayerState playerState) {
    switch (playerState) {
      case ZegoPlayerState.NoPlay:
        return ZegoUIKitPlayerState.noPlay;
      case ZegoPlayerState.PlayRequesting:
        return ZegoUIKitPlayerState.playRequesting;
      case ZegoPlayerState.Playing:
        return ZegoUIKitPlayerState.playing;
    }
  }
}

typedef PlayerStateUpdateCallback = void Function(
  ZegoUIKitPlayerState state,
  int errorCode,
  Map<String, dynamic> extendedData,
);

/// Publish stream status.
enum ZegoUIKitPublisherState {
  /// The state is not published, and it is in this state before publishing the stream. If a steady-state exception occurs in the publish process, such as AppID or Token are incorrect, or if other users are already publishing the stream, there will be a failure and enter this state.
  noPublish,

  /// The state that it is requesting to publish the stream after the [startPublishingStream] function is successfully called. The UI is usually displayed through this state. If the connection is interrupted due to poor network quality, the SDK will perform an internal retry and will return to the requesting state.
  publishRequesting,

  /// The state that the stream is being published, entering the state indicates that the stream has been successfully published, and the user can communicate normally.
  publishing
}

extension ZegoUIKitPublisherStateExtension on ZegoUIKitPublisherState {
  static ZegoUIKitPublisherState fromZego(ZegoPublisherState publisherState) {
    switch (publisherState) {
      case ZegoPublisherState.NoPublish:
        return ZegoUIKitPublisherState.noPublish;
      case ZegoPublisherState.PublishRequesting:
        return ZegoUIKitPublisherState.publishRequesting;
      case ZegoPublisherState.Publishing:
        return ZegoUIKitPublisherState.publishing;
    }
  }
}

typedef PublisherStateUpdateCallback = void Function(
  ZegoUIKitPublisherState state,
  int errorCode,
  Map<String, dynamic> extendedData,
);
