part of 'core.dart';

/// @nodoc
extension ZegoUIKitCoreBaseMedia on ZegoUIKitCore {
  Future<ZegoUIKitMediaPlayResult> playMedia({
    required String targetRoomID,
    required String filePathOrURL,
    bool enableRepeat = false,
    bool autoStart = true,
  }) async {
    if (null != coreData.media.currentPlayer) {
      await stopMedia(
        targetRoomID: targetRoomID,
      );
    }

    final playResult = await coreData.media.play(
      filePathOrURL: filePathOrURL,
      enableRepeat: enableRepeat,
      autoStart: autoStart,
    );

    if (ZegoUIKitErrorCode.success == playResult.errorCode) {
      ZegoLoggerService.logInfo(
        'finished, try start publish stream',
        tag: 'uikit.media',
        subTag: 'playMedia',
      );
      final roomStream = coreData.stream.roomStreams.getRoom(targetRoomID);

      await roomStream
          .startPublishingStream(streamType: ZegoStreamType.media)
          .then((value) async {
        /// sync media type via stream extra info
        final streamExtraInfo = <String, dynamic>{
          ZegoUIKitSEIDefines.keyMediaType:
              coreData.media.typeNotifier.value.index,
        };

        final extraInfo = jsonEncode(streamExtraInfo);
        ZegoExpressEngine.instance.setStreamExtraInfo(
          extraInfo,
          channel: ZegoStreamType.media.channel,
        );

        /// render
        await coreData.stream.createLocalUserVideoViewQueue(
          targetRoomID: targetRoomID,
          streamType: ZegoStreamType.media,
          onViewCreated: (ZegoStreamType streamType) {
            roomStream.onViewCreatedByStartPublishingStream(
              ZegoStreamType.media,
            );
          },
        );
      });
    }

    return playResult;
  }

  Future<void> startMedia() async {
    await coreData.media.start();
  }

  Future<void> stopMedia({
    required String targetRoomID,
  }) async {
    await coreData.media.stop();

    await coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .stopPublishingStream(
          streamType: ZegoStreamType.media,
        );
  }

  Future<void> destroyMedia({
    required String targetRoomID,
  }) async {
    await coreData.media.clear();

    await coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .stopPublishingStream(
          streamType: ZegoStreamType.media,
        );
  }

  Future<void> pauseMedia() async {
    return coreData.media.pause();
  }

  Future<void> resumeMedia() async {
    return coreData.media.resume();
  }

  Future<ZegoUIKitMediaSeekToResult> mediaSeekTo(int millisecond) async {
    return coreData.media.seekTo(millisecond);
  }

  Future<void> setMediaVolume(
    int volume, {
    bool isSyncToRemote = false,
  }) async {
    return coreData.media.setVolume(volume, isSyncToRemote);
  }

  int getMediaVolume() {
    return coreData.media.getVolume();
  }

  Future<void> muteMediaLocal(bool mute) async {
    return coreData.media.muteLocal(mute);
  }

  int getMediaTotalDuration() {
    return coreData.media.getTotalDuration();
  }

  int getMediaCurrentProgress() {
    return coreData.media.progressNotifier.value;
  }

  ZegoUIKitMediaType getMediaType() {
    return coreData.media.typeNotifier.value;
  }

  ValueNotifier<int> getMediaVolumeNotifier() {
    return coreData.media.volumeNotifier;
  }

  ValueNotifier<int> getMediaCurrentProgressNotifier() {
    return coreData.media.progressNotifier;
  }

  ValueNotifier<ZegoUIKitMediaType> getMediaTypeNotifier() {
    return coreData.media.typeNotifier;
  }

  ValueNotifier<ZegoUIKitMediaPlayState> getMediaPlayStateNotifier() {
    return coreData.media.stateNotifier;
  }

  ValueNotifier<bool> getMediaMuteNotifier() {
    return coreData.media.muteNotifier;
  }

  Future<List<ZegoUIKitPlatformFile>> pickPureAudioMediaFile() async {
    return coreData.media.pickMediaFiles(
      allowMultiple: false,
      allowedExtensions: coreData.media.pureAudioExtensions,
    );
  }

  Future<List<ZegoUIKitPlatformFile>> pickVideoMediaFile() async {
    return coreData.media.pickMediaFiles(
      allowMultiple: false,
      allowedExtensions: coreData.media.videoExtensions,
    );
  }

  Future<List<ZegoUIKitPlatformFile>> pickMediaFile({
    List<String>? allowedExtensions,
  }) async {
    return coreData.media.pickMediaFiles(
      allowMultiple: false,
      allowedExtensions: allowedExtensions,
    );
  }

  ZegoUIKitMediaPlayerMediaInfo getMediaInfo() {
    return coreData.media.mediaInfo ??
        ZegoUIKitMediaPlayerMediaInfo.defaultInfo();
  }
}
