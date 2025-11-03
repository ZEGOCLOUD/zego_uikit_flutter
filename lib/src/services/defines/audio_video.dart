// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

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

enum ZegoUIKitInnerSEIType {
  mixerDeviceState,
  mediaSyncInfo,
  custom,
}

/// receive SEI from remote
class ZegoUIKitReceiveSEIEvent {
  final String typeIdentifier;

  final String senderID;
  final Map<String, dynamic> sei;

  final String streamID;
  final ZegoStreamType streamType;

  ZegoUIKitReceiveSEIEvent({
    required this.streamID,
    required this.typeIdentifier,
    required this.senderID,
    required this.sei,
    required this.streamType,
  });

  @override
  String toString() {
    return 'ZegoUIKitReceiveSEIEvent{'
        'streamID:$streamID, '
        'streamType:$streamType, '
        'senderID:$senderID, '
        'typeIdentifier:$typeIdentifier, '
        'sei:$sei, '
        '}';
  }
}

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

enum ZegoStreamType {
  main,
  media,
  screenSharing,
  mix,
}

const zegoStreamTypeMediaText = 'player';
const zegoStreamTypeScreenSharingText = 'screensharing';

extension ZegoStreamTypeExtension on ZegoStreamType {
  String get text {
    switch (this) {
      case ZegoStreamType.main:
      case ZegoStreamType.mix:
        return name;
      case ZegoStreamType.media:
        return zegoStreamTypeMediaText;
      case ZegoStreamType.screenSharing:
        return zegoStreamTypeScreenSharingText;
    }
  }

  ZegoPublishChannel get channel {
    switch (this) {
      case ZegoStreamType.main:
        return ZegoPublishChannel.Main;
      case ZegoStreamType.media:
      case ZegoStreamType.screenSharing:
      case ZegoStreamType.mix:
        return ZegoPublishChannel.Aux;
    }
  }
}

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

enum ZegoUIKitDeviceExceptionType {
  /// Unknown device exception.
  unknown,

  /// Generic device exception.
  generic,

  /// Invalid device ID exception.
  invalidId,

  /// Device permission is not granted.
  permissionNotGranted,

  /// The capture frame rate of the device is 0.
  zeroCaptureFps,

  /// The device is being occupied.
  deviceOccupied,

  /// The device is unplugged (not plugged in).
  deviceUnplugged,

  /// The device requires the system to restart before it can work (Windows platform only).
  rebootRequired,

  /// The system media service is unavailable, e.g. when the iOS system detects that the current pressure is huge (such as playing a lot of animation), it is possible to disable all media related services (Apple platform only).
  mediaServicesWereLost,

  /// The device is being occupied by Siri (Apple platform only).
  siriIsRecording,

  /// The device captured sound level is too low (Windows platform only).
  soundLevelTooLow,

  /// The device is being occupied, and maybe cause by iPad magnetic case (Apple platform only).
  magneticCase,

  /// Audio session deactivate (Apple platform only).
  audioSessionDeactivate,

  /// Audio session category change (Apple platform only).
  audioSessionCategoryChange,

  /// The device is interrupted, such as a phone call interruption, etc.
  interruption,

  /// There are multiple apps at the same time in the foreground, such as the iPad app split screen, the system will prohibit all apps from using the camera.
  inBackground,

  /// CDN server actively disconnected
  multiForegroundApp,

  /// The system is under high load pressure and may cause abnormal equipment.
  bySystemPressure,
}

extension ZegoUIKitDeviceExceptionTypeExtension
    on ZegoUIKitDeviceExceptionType {
  static ZegoUIKitDeviceExceptionType fromSDKValue(
    ZegoDeviceExceptionType value,
  ) {
    switch (value) {
      case ZegoDeviceExceptionType.Unknown:
        return ZegoUIKitDeviceExceptionType.unknown;
      case ZegoDeviceExceptionType.Generic:
        return ZegoUIKitDeviceExceptionType.generic;
      case ZegoDeviceExceptionType.InvalidId:
        return ZegoUIKitDeviceExceptionType.invalidId;
      case ZegoDeviceExceptionType.PermissionNotGranted:
        return ZegoUIKitDeviceExceptionType.permissionNotGranted;
      case ZegoDeviceExceptionType.ZeroCaptureFps:
        return ZegoUIKitDeviceExceptionType.zeroCaptureFps;
      case ZegoDeviceExceptionType.DeviceOccupied:
        return ZegoUIKitDeviceExceptionType.deviceOccupied;
      case ZegoDeviceExceptionType.DeviceUnplugged:
        return ZegoUIKitDeviceExceptionType.deviceUnplugged;
      case ZegoDeviceExceptionType.RebootRequired:
        return ZegoUIKitDeviceExceptionType.rebootRequired;
      case ZegoDeviceExceptionType.MediaServicesWereLost:
        return ZegoUIKitDeviceExceptionType.mediaServicesWereLost;
      case ZegoDeviceExceptionType.SiriIsRecording:
        return ZegoUIKitDeviceExceptionType.siriIsRecording;
      case ZegoDeviceExceptionType.SoundLevelTooLow:
        return ZegoUIKitDeviceExceptionType.soundLevelTooLow;
      case ZegoDeviceExceptionType.MagneticCase:
        return ZegoUIKitDeviceExceptionType.magneticCase;
      case ZegoDeviceExceptionType.AudioSessionDeactive:
        return ZegoUIKitDeviceExceptionType.audioSessionDeactivate;
      case ZegoDeviceExceptionType.AudioSessionCategoryChange:
        return ZegoUIKitDeviceExceptionType.audioSessionCategoryChange;
    }
  }

  static ZegoUIKitDeviceExceptionType? fromDeviceState(
    ZegoRemoteDeviceState value,
  ) {
    switch (value) {
      case ZegoRemoteDeviceState.GenericError:
        return ZegoUIKitDeviceExceptionType.generic;
      case ZegoRemoteDeviceState.InvalidID:
        return ZegoUIKitDeviceExceptionType.invalidId;
      case ZegoRemoteDeviceState.NoAuthorization:
        return ZegoUIKitDeviceExceptionType.permissionNotGranted;
      case ZegoRemoteDeviceState.ZeroFPS:
        return ZegoUIKitDeviceExceptionType.zeroCaptureFps;
      case ZegoRemoteDeviceState.InUseByOther:
        return ZegoUIKitDeviceExceptionType.deviceOccupied;
      case ZegoRemoteDeviceState.Unplugged:
        return ZegoUIKitDeviceExceptionType.deviceUnplugged;
      case ZegoRemoteDeviceState.RebootRequired:
        return ZegoUIKitDeviceExceptionType.rebootRequired;
      case ZegoRemoteDeviceState.SystemMediaServicesLost:
        return ZegoUIKitDeviceExceptionType.mediaServicesWereLost;
      case ZegoRemoteDeviceState.Interruption:
        return ZegoUIKitDeviceExceptionType.interruption;
      case ZegoRemoteDeviceState.InBackground:
        return ZegoUIKitDeviceExceptionType.inBackground;
      case ZegoRemoteDeviceState.MultiForegroundApp:
        return ZegoUIKitDeviceExceptionType.multiForegroundApp;
      case ZegoRemoteDeviceState.BySystemPressure:
        return ZegoUIKitDeviceExceptionType.bySystemPressure;
      case ZegoRemoteDeviceState.NotSupport:
      case ZegoRemoteDeviceState.Open:
      case ZegoRemoteDeviceState.Disable:
      case ZegoRemoteDeviceState.Mute:
        // not error
        return null;
    }
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
