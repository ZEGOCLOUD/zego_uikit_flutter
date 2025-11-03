part of 'uikit_service.dart';

mixin ZegoMediaService {
  void registerMediaEvent(ZegoUIKitMediaEventInterface event) {
    ZegoUIKitCore.shared.event.media.register(event);
  }

  void unregisterMediaEvent(ZegoUIKitMediaEventInterface event) {
    ZegoUIKitCore.shared.event.media.unregister(event);
  }

  /// Start playing.
  Future<ZegoUIKitMediaPlayResult> playMedia({
    required String filePathOrURL,
    bool enableRepeat = false,
    bool autoStart = true,
  }) async {
    final playResult = await ZegoUIKitCore.shared.playMedia(
      filePathOrURL: filePathOrURL,
      enableRepeat: enableRepeat,
      autoStart: autoStart,
    );

    if (ZegoUIKitErrorCode.success != playResult.errorCode) {
      ZegoUIKitCore.shared.error.errorStreamCtrl?.add(ZegoUIKitError(
        code: ZegoUIKitErrorCode.mediaPlayError,
        message: playResult.message,
        method: 'playMedia',
      ));
    }

    return playResult;
  }

  /// Start playing.
  Future<void> startMedia() async {
    return ZegoUIKitCore.shared.startMedia();
  }

  /// Stop playing.
  Future<void> stopMedia() async {
    return ZegoUIKitCore.shared.stopMedia();
  }

  /// Pause playing.
  Future<void> pauseMedia() async {
    return ZegoUIKitCore.shared.pauseMedia();
  }

  /// Resume playing.
  Future<void> resumeMedia() async {
    return ZegoUIKitCore.shared.resumeMedia();
  }

  /// Destroy current media
  Future<void> destroyMedia() async {
    return ZegoUIKitCore.shared.destroyMedia();
  }

  /// Set the specified playback progress, Unit is millisecond.
  ///
  /// - [millisecond] Point in time of specified playback progress
  Future<ZegoUIKitMediaSeekToResult> seekTo(int millisecond) async {
    final seekResult = await ZegoUIKitCore.shared.mediaSeekTo(millisecond);

    if (ZegoErrorCode.CommonSuccess != seekResult.errorCode) {
      ZegoUIKitCore.shared.error.errorStreamCtrl?.add(ZegoUIKitError(
        code: ZegoUIKitErrorCode.mediaSeekError,
        message: 'seek result:${seekResult.errorCode}',
        method: 'seekTo',
      ));
    }

    return seekResult;
  }

  /// Set media player volume.
  ///
  /// set [isSyncToRemote] to be true if you want to sync both the local play volume
  /// and the publish volume, if [isSyncToRemote] is false, that will only adjust the
  /// local play volume.
  ///
  /// - [volume] The range is 0 ~ 100. The default is 30.
  Future<void> setMediaVolume(
    int volume, {
    bool isSyncToRemote = false,
  }) async {
    return ZegoUIKitCore.shared.setMediaVolume(
      volume,
      isSyncToRemote: isSyncToRemote,
    );
  }

  int getMediaVolume() {
    return ZegoUIKitCore.shared.getMediaVolume();
  }

  Future<void> muteMediaLocal(bool mute) async {
    ZegoUIKitCore.shared.muteMediaLocal(mute);
  }

  ValueNotifier<bool> getMediaMuteNotifier() {
    return ZegoUIKitCore.shared.getMediaMuteNotifier();
  }

  ValueNotifier<int> getMediaVolumeNotifier() {
    return ZegoUIKitCore.shared.getMediaVolumeNotifier();
  }

  /// Get the total progress of your media resources, Returns Unit is millisecond.
  int getMediaTotalDuration() {
    return ZegoUIKitCore.shared.getMediaTotalDuration();
  }

  /// Get current playing progress.
  int getMediaCurrentProgress() {
    return ZegoUIKitCore.shared.getMediaCurrentProgress();
  }

  ValueNotifier<int> getMediaCurrentProgressNotifier() {
    return ZegoUIKitCore.shared.getMediaCurrentProgressNotifier();
  }

  ZegoUIKitMediaType getMediaType() {
    return ZegoUIKitCore.shared.getMediaType();
  }

  ValueNotifier<ZegoUIKitMediaType> getMediaTypeNotifier() {
    return ZegoUIKitCore.shared.getMediaTypeNotifier();
  }

  ValueNotifier<ZegoUIKitMediaPlayState> getMediaPlayStateNotifier() {
    return ZegoUIKitCore.shared.getMediaPlayStateNotifier();
  }

  Future<List<ZegoUIKitPlatformFile>> pickPureAudioMediaFile() async {
    return ZegoUIKitCore.shared.pickPureAudioMediaFile();
  }

  Future<List<ZegoUIKitPlatformFile>> pickVideoMediaFile() async {
    return ZegoUIKitCore.shared.pickVideoMediaFile();
  }

  /// If you want to specify the allowed formats, you can set them using [allowedExtensions].
  /// Currently, for video, we support "avi", "flv", "mkv", "mov", "mp4", "mpeg", "webm", "wmv".
  /// For audio, we support "aac", "midi", "mp3", "ogg", "wav".
  Future<List<ZegoUIKitPlatformFile>> pickMediaFile({
    List<String>? allowedExtensions,
  }) async {
    return ZegoUIKitCore.shared.pickMediaFile(
      allowedExtensions: allowedExtensions ??
          [
            ...zegoMediaVideoExtensions,
            ...zegoMediaAudioExtensions,
          ],
    );
  }

  ZegoUIKitMediaPlayerMediaInfo getMediaInfo() {
    return ZegoUIKitCore.shared.getMediaInfo();
  }
}
