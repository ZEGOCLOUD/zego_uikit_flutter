// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

typedef ZegoUIKitPlatformFile = PlatformFile;

List<String> zegoMediaVideoExtensions = const [
  "avi",
  "flv",
  "mkv",
  "mov",
  "mp4",
  "mpeg",
  "webm",
  "wmv",
];

List<String> zegoMediaAudioExtensions = const [
  "aac",
  "midi",
  "mp3",
  "ogg",
  "wav",
];

class ZegoUIKitMediaPlayerConfig {
  /// extensions of pick files,
  /// video: "avi","flv","mkv","mov","mp4","mpeg","webm","wmv",
  /// audio: "aac","midi","mp3","ogg","wav",
  final List<String>? allowedExtensions;

  /// can control or not, such as
  final bool canControl;

  /// repeat or not
  final bool enableRepeat;

  /// auto start play after pick or set media url
  final bool autoStart;

  /// can this media moveable on parent
  final bool isMovable;

  /// show big play button central on player, or show a small control button
  final bool isPlayButtonCentral;

  /// show surface(controls) or not, default is true
  final bool showSurface;

  /// auto hide surface after [hideSurfaceSecond], default is true
  final bool autoHideSurface;

  /// hide surface in seconds, default is 3 second
  final int hideSurfaceSecond;

  const ZegoUIKitMediaPlayerConfig({
    this.canControl = true,
    this.showSurface = true,
    this.autoStart = true,
    this.isMovable = true,
    this.autoHideSurface = true,
    this.hideSurfaceSecond = 3,
    this.enableRepeat = false,
    this.isPlayButtonCentral = true,
    this.allowedExtensions,
  });
}

class ZegoUIKitMediaPlayerStyle {
  final Widget? closeIcon;
  final Widget? moreIcon;
  final Widget? playIcon;
  final Widget? pauseIcon;
  final Widget? volumeIcon;
  final Widget? volumeMuteIcon;
  final TextStyle? durationTextStyle;

  const ZegoUIKitMediaPlayerStyle({
    this.closeIcon,
    this.moreIcon,
    this.playIcon,
    this.pauseIcon,
    this.volumeIcon,
    this.volumeMuteIcon,
    this.durationTextStyle,
  });
}

class ZegoUIKitMediaPlayerEvent {
  const ZegoUIKitMediaPlayerEvent({
    this.onPlayStateChanged,
  });

  /// play state callback
  final void Function(ZegoUIKitMediaPlayState)? onPlayStateChanged;
}

/// media type
enum ZegoUIKitMediaType {
  pureAudio,
  video,
  unknown,
}

/// media play result
class ZegoUIKitMediaPlayResult {
  int errorCode;
  String message;

  ZegoUIKitMediaPlayResult({
    required this.errorCode,
    this.message = '',
  });
}

/// seek result of media
class ZegoUIKitMediaSeekToResult {
  int errorCode;
  String message;

  ZegoUIKitMediaSeekToResult({
    required this.errorCode,
    this.message = '',
  });
}

/// media play state
/// normal process: noPlay->loadReady->playing->playEnded
enum ZegoUIKitMediaPlayState {
  /// Not playing
  noPlay,

  /// not start yet
  loadReady,

  /// Playing
  playing,

  /// Pausing
  pausing,

  /// End of play
  playEnded
}

extension ZegoUIKitMediaPlayStateExtension on ZegoUIKitMediaPlayState {
  static ZegoUIKitMediaPlayState fromZego(
      ZegoMediaPlayerState zegoMediaPlayerState) {
    switch (zegoMediaPlayerState) {
      case ZegoMediaPlayerState.NoPlay:
        return ZegoUIKitMediaPlayState.noPlay;
      case ZegoMediaPlayerState.Playing:
        return ZegoUIKitMediaPlayState.playing;
      case ZegoMediaPlayerState.Pausing:
        return ZegoUIKitMediaPlayState.pausing;
      case ZegoMediaPlayerState.PlayEnded:
        return ZegoUIKitMediaPlayState.playEnded;
    }
  }
}

/// Media Infomration of media file.
///
/// Meida information such as video resolution of media file.
class ZegoUIKitMediaInfo {
  /// Video resolution width.
  int width;

  /// Video resolution height.
  int height;

  /// Video frame rate.
  int frameRate;

  ZegoUIKitMediaInfo({
    required this.width,
    required this.height,
    required this.frameRate,
  });

  /// Constructs a media player information object by default.
  ZegoUIKitMediaInfo.defaultInfo()
      : width = 0,
        height = 0,
        frameRate = 0;

  ZegoUIKitMediaInfo.fromZego(ZegoMediaPlayerMediaInfo? zegoMediaInfo)
      : this(
          width: zegoMediaInfo?.width ?? 0,
          height: zegoMediaInfo?.height ?? 0,
          frameRate: zegoMediaInfo?.frameRate ?? 0,
        );
}

@Deprecated('Since 2.17.0, please use ZegoUIKitMediaInfo instead')
typedef MediaInfo = ZegoUIKitMediaInfo;
@Deprecated('Since 2.17.0, please use ZegoUIKitMediaPlayState instead')
typedef MediaPlayState = ZegoUIKitMediaPlayState;
@Deprecated('Since 2.17.0, please use ZegoUIKitMediaType instead')
typedef MediaType = ZegoUIKitMediaType;
@Deprecated('Since 2.17.0, please use ZegoUIKitMediaPlayResult instead')
typedef MediaPlayResult = ZegoUIKitMediaPlayResult;
@Deprecated('Since 2.17.0, please use ZegoUIKitMediaSeekToResult instead')
typedef MediaSeekToResult = ZegoUIKitMediaSeekToResult;
