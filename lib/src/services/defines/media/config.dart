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
