part of 'uikit_service.dart';

mixin ZegoAudioVideoService {
  /// start play all audio video
  Future<void> unmuteAllRemoteAudioVideo({
    required String targetRoomID,
  }) async {
    return ZegoUIKitCore.shared.coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .muteAllPlayStreamAudioVideo(false);
  }

  /// stop play all audio video
  Future<void> muteAllRemoteAudioVideo({
    required String targetRoomID,
  }) async {
    return ZegoUIKitCore.shared.coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .muteAllPlayStreamAudioVideo(
          true,
        );
  }

  /// start play all audio
  Future<void> unmuteAllRemoteAudio({
    required String targetRoomID,
  }) async {
    return ZegoUIKitCore.shared.coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .muteAllPlayStreamAudio(false);
  }

  /// stop play all audio
  Future<void> muteAllRemoteAudio({
    required String targetRoomID,
  }) async {
    await ZegoUIKitCore.shared.coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .muteAllPlayStreamAudio(true);
  }

  /// When the [mute] is set to true, it means that the device is not actually turned off, but muted.
  /// The default value is false, which means the device is turned off.
  /// When either the camera or the microphone is muted, the audio and video views will still be visible.
  Future<bool> muteUserAudioVideo(
    String userID,
    bool mute, {
    required String targetRoomID,
  }) async {
    return ZegoUIKitCore.shared.coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .mutePlayStreamAudioVideo(
          userID,
          mute,
          forAudio: true,
          forVideo: true,
        );
  }

  /// When the [mute] is set to true, it means that the device is not actually turned off, but muted.
  /// The default value is false, which means the device is turned off.
  /// When either the camera or the microphone is muted, the audio and video views will still be visible.
  Future<bool> muteUserAudio(
    String userID,
    bool mute, {
    required String targetRoomID,
  }) async {
    return ZegoUIKitCore.shared.coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .mutePlayStreamAudioVideo(
          userID,
          mute,
          forAudio: true,
          forVideo: false,
        );
  }

  /// When the [mute] is set to true, it means that the device is not actually turned off, but muted.
  /// The default value is false, which means the device is turned off.
  /// When either the camera or the microphone is muted, the audio and video views will still be visible.
  Future<bool> muteUserVideo(
    String userID,
    bool mute, {
    required String targetRoomID,
  }) async {
    return ZegoUIKitCore.shared.coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .mutePlayStreamAudioVideo(
          userID,
          mute,
          forAudio: false,
          forVideo: true,
        );
  }

  /// set audio output to speaker
  void setAudioOutputToSpeaker(bool isSpeaker) {
    ZegoUIKitCore.shared.setAudioRouteToSpeaker(isSpeaker);
  }

  /// update video config
  Future<void> setVideoConfig(
    ZegoUIKitVideoConfig config, {
    ZegoStreamType streamType = ZegoStreamType.main,
  }) async {
    await ZegoUIKitCore.shared.setVideoConfig(config, streamType);
  }

  Future<void> enableTrafficControl(
    bool enabled,
    List<ZegoUIKitTrafficControlProperty> properties, {
    required String targetRoomID,
    ZegoUIKitVideoConfig? minimizeVideoConfig,
    bool isFocusOnRemote = true,
    ZegoStreamType streamType = ZegoStreamType.main,
  }) async {
    await ZegoUIKitCore.shared.enableTrafficControl(
      enabled,
      properties,
      minimizeVideoConfig: minimizeVideoConfig,
      isFocusOnRemote: isFocusOnRemote,
      streamType: streamType,
    );
  }

  /// turn on/off camera
  Future<bool> turnCameraOn(
    bool isOn, {
    String? userID,
    required String targetRoomID,
  }) async {
    assert(targetRoomID.isNotEmpty);

    return await ZegoUIKitCore.shared.turnCameraOn(
      userID?.isEmpty ?? true
          ? ZegoUIKitCore.shared.coreData.user.localUser.id
          : userID!,
      isOn,
      targetRoomID: targetRoomID,
      onlyPreview: false,
    );
  }

  /// turn on/off camera only for preview
  void turnLocalCameraOnForPreview(bool isOn) {
    ZegoUIKitCore.shared.turnCameraOn(
      ZegoUIKitCore.shared.coreData.user.localUser.id,
      isOn,
      targetRoomID: '',
      onlyPreview: true,
    );
  }

  /// turn on/off microphone
  ///
  /// When the [muteMode] is set to true, it means that the device is not actually turned off, but muted.
  /// The default value is false, which means the device is turned off.
  /// When either the camera or the microphone is muted, the audio and video views will still be visible.
  Future<bool> turnMicrophoneOn(
    bool isOn, {
    required String targetRoomID,
    String? userID,
    bool muteMode = false,
  }) async {
    assert(targetRoomID.isNotEmpty);

    return await ZegoUIKitCore.shared.turnMicrophoneOn(
      userID?.isEmpty ?? true
          ? ZegoUIKitCore.shared.coreData.user.localUser.id
          : userID!,
      isOn,
      muteMode: muteMode,
      targetRoomID: targetRoomID,
      onlyPreview: false,
    );
  }

  /// turn on/off microphone only for preview
  ///
  /// When the [muteMode] is set to true, it means that the device is not actually turned off, but muted.
  /// The default value is false, which means the device is turned off.
  /// When either the camera or the microphone is muted, the audio and video views will still be visible.
  void turnLocalMicrophoneOnForPreview(
    bool isOn, {
    bool muteMode = false,
  }) {
    ZegoUIKitCore.shared.turnMicrophoneOn(
      ZegoUIKitCore.shared.coreData.user.localUser.id,
      isOn,
      muteMode: muteMode,
      targetRoomID: '',
      onlyPreview: true,
    );
  }

  /// local use front facing camera
  Future<bool> useFrontFacingCamera(
    bool isFrontFacing, {
    /// Whether to ignore the camera's open state;
    /// if not ignored, the operation will not be executed when the camera is not open
    bool ignoreCameraStatus = false,
  }) async {
    return ZegoUIKitCore.shared.useFrontFacingCamera(
      isFrontFacing,
      ignoreCameraStatus: ignoreCameraStatus,
    );
  }

  /// set video mirror mode
  void enableVideoMirroring(bool isVideoMirror) {
    ZegoUIKitCore.shared.enableVideoMirroring(isVideoMirror);
  }

  Future<void> stopPublishingAllStream({
    required String targetRoomID,
  }) async {
    await ZegoUIKitCore.shared.coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .stopPublishingAllStream();
  }

  Future<void> stopPlayingAllStream({
    required String targetRoomID,
    List<String> ignoreStreamIDs = const [],
  }) async {
    await ZegoUIKitCore.shared.coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .stopPlayingAllStream(ignoreStreamIDs: ignoreStreamIDs);
  }

  void setPlayerResourceMode(
    ZegoUIKitStreamResourceMode mode, {
    required String targetRoomID,
  }) {
    ZegoUIKitCore.shared.setPlayerResourceMode(
      mode,
      targetRoomID: targetRoomID,
    );
  }

  void setPlayerCDNConfig(
    ZegoUIKitCDNConfig? cdnConfig, {
    required String targetRoomID,
  }) {
    ZegoUIKitCore.shared.setPlayerCDNConfig(
      cdnConfig,
      targetRoomID: targetRoomID,
    );
  }

  /// MUST call after pushing the stream(turn on camera of microphone)
  /// SEI data will  transmit by the audio and video stream
  Future<bool> sendCustomSEI(
    Map<String, dynamic> seiData, {
    ZegoStreamType streamType = ZegoStreamType.main,
  }) async {
    return ZegoUIKitCore.shared.coreData.sendSEI(
      ZegoUIKitInnerSEIType.custom.name,
      seiData,
      streamType: streamType,
    );
  }

  /// After setting to true, switching room will not stop pulling streams (both RTC and CDN streams will not stop)
  Future<void> enableSwitchRoomNotStopPlay(bool enabled) async {
    return ZegoUIKitCore.shared.enableSwitchRoomNotStopPlay(enabled);
  }

  /// get audio video view notifier
  ValueNotifier<Widget?> getAudioVideoViewNotifier(
    String? userID, {
    required String targetRoomID,
    ZegoStreamType streamType = ZegoStreamType.main,
  }) {
    final targetUser = ZegoUIKitCore.shared.coreData.user.getUser(
      userID ?? '',
      targetRoomID: targetRoomID,
    );

    switch (streamType) {
      case ZegoStreamType.main:
        return targetUser.mainChannel.viewNotifier;
      case ZegoStreamType.media:
      case ZegoStreamType.screenSharing:
      case ZegoStreamType.mix:
        return targetUser.auxChannel.viewNotifier;
      // return targetUser.thirdChannel.view;
    }
  }

  /// get audio video view id notifier
  ValueNotifier<int?> getAudioVideoViewIDNotifier(
    String? userID, {
    required String targetRoomID,
    ZegoStreamType streamType = ZegoStreamType.main,
  }) {
    final targetUser = ZegoUIKitCore.shared.coreData.user.getUser(
      userID ?? '',
      targetRoomID: targetRoomID,
    );

    switch (streamType) {
      case ZegoStreamType.main:
        return targetUser.mainChannel.viewIDNotifier;
      case ZegoStreamType.media:
      case ZegoStreamType.screenSharing:
      case ZegoStreamType.mix:
        return targetUser.auxChannel.viewIDNotifier;
    }
  }

  ValueNotifier<ZegoUIKitPublishStreamQuality> getAudioVideoQualityNotifier(
    String? userID, {
    required String targetRoomID,
    ZegoStreamType streamType = ZegoStreamType.main,
  }) {
    final targetUser = ZegoUIKitCore.shared.coreData.user.getUser(
      userID ?? '',
      targetRoomID: targetRoomID,
    );

    switch (streamType) {
      case ZegoStreamType.main:
        return targetUser.mainChannel.qualityNotifier;
      case ZegoStreamType.media:
      case ZegoStreamType.screenSharing:
      case ZegoStreamType.mix:
        return targetUser.auxChannel.qualityNotifier;
    }
  }

  ValueNotifier<bool> getAudioVideoCapturedAudioFirstFrameNotifier(
    String? userID, {
    required String targetRoomID,
    ZegoStreamType streamType = ZegoStreamType.main,
  }) {
    final targetUser = ZegoUIKitCore.shared.coreData.user.getUser(
      userID ?? '',
      targetRoomID: targetRoomID,
    );

    switch (streamType) {
      case ZegoStreamType.main:
        return targetUser.mainChannel.isCapturedAudioFirstFrameNotifier;
      case ZegoStreamType.media:
      case ZegoStreamType.screenSharing:
      case ZegoStreamType.mix:
        return targetUser.auxChannel.isCapturedAudioFirstFrameNotifier;
    }
  }

  ValueNotifier<bool> getAudioVideoCapturedVideoFirstFrameNotifier(
    String? userID, {
    required String targetRoomID,
    ZegoStreamType streamType = ZegoStreamType.main,
  }) {
    final targetUser = ZegoUIKitCore.shared.coreData.user.getUser(
      userID ?? '',
      targetRoomID: targetRoomID,
    );

    switch (streamType) {
      case ZegoStreamType.main:
        return targetUser.mainChannel.isCapturedVideoFirstFrameNotifier;
      case ZegoStreamType.media:
      case ZegoStreamType.screenSharing:
      case ZegoStreamType.mix:
        return targetUser.auxChannel.isCapturedVideoFirstFrameNotifier;
    }
  }

  ValueNotifier<bool> getAudioVideoSendAudioFirstFrameNotifier(
    String? userID, {
    required String targetRoomID,
    ZegoStreamType streamType = ZegoStreamType.main,
  }) {
    final targetUser = ZegoUIKitCore.shared.coreData.user.getUser(
      userID ?? '',
      targetRoomID: targetRoomID,
    );

    switch (streamType) {
      case ZegoStreamType.main:
        return targetUser.mainChannel.isSendAudioFirstFrameNotifier;
      case ZegoStreamType.media:
      case ZegoStreamType.screenSharing:
      case ZegoStreamType.mix:
        return targetUser.auxChannel.isSendAudioFirstFrameNotifier;
    }
  }

  ValueNotifier<bool> getAudioVideoSendVideoFirstFrameNotifier(
    String? userID, {
    required String targetRoomID,
    ZegoStreamType streamType = ZegoStreamType.main,
  }) {
    final targetUser = ZegoUIKitCore.shared.coreData.user.getUser(
      userID ?? '',
      targetRoomID: targetRoomID,
    );

    switch (streamType) {
      case ZegoStreamType.main:
        return targetUser.mainChannel.isSendVideoFirstFrameNotifier;
      case ZegoStreamType.media:
      case ZegoStreamType.screenSharing:
      case ZegoStreamType.mix:
        return targetUser.auxChannel.isSendVideoFirstFrameNotifier;
    }
  }

  /// get camera state notifier
  ValueNotifier<bool> getCameraStateNotifier(
    String userID, {
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.user
        .getUser(
          userID,
          targetRoomID: targetRoomID,
        )
        .camera;
  }

  /// get front facing camera switch notifier
  ValueNotifier<bool> getUseFrontFacingCameraStateNotifier(
    String userID, {
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.user
        .getUser(
          userID,
          targetRoomID: targetRoomID,
        )
        .isFrontFacing;
  }

  /// get microphone state notifier
  ValueNotifier<bool> getMicrophoneStateNotifier(
    String userID, {
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.user
        .getUser(
          userID,
          targetRoomID: targetRoomID,
        )
        .microphone;
  }

  /// get audio output device notifier
  ValueNotifier<ZegoUIKitAudioRoute> getAudioOutputDeviceNotifier(
    String userID, {
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.user
        .getUser(
          userID,
          targetRoomID: targetRoomID,
        )
        .audioRoute;
  }

  /// get screen share notifier
  ValueNotifier<bool> getScreenSharingStateNotifier() {
    return ZegoUIKitCore.shared.coreData.screenSharing.isScreenSharing;
  }

  /// get sound level notifier
  Stream<double> getSoundLevelStream(
    String userID, {
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.user
            .getUser(
              userID,
              targetRoomID: targetRoomID,
            )
            .mainChannel
            .soundLevelStream
            ?.stream ??
        const Stream.empty();
  }

  void moveToAnotherRoom({
    required String fromRoomID,
    required List<String> fromStreamIDs,
    required String toRoomID,
    required bool isFromAnotherRoom,
  }) {
    ZegoUIKitCore.shared.coreData.stream.roomStreams
        .getRoom(fromRoomID)
        .transferToAnotherRoom(
          fromStreamIDs: fromStreamIDs,
          toRoomID: toRoomID,
          isFromAnotherRoom: isFromAnotherRoom,
          isMove: true,
        );
  }

  void copyToAnotherRoom({
    required String fromRoomID,
    required List<String> fromStreamIDs,
    required String toRoomID,
    required bool isFromAnotherRoom,
  }) {
    ZegoUIKitCore.shared.coreData.stream.roomStreams
        .getRoom(fromRoomID)
        .transferToAnotherRoom(
          fromStreamIDs: fromStreamIDs,
          toRoomID: toRoomID,
          isFromAnotherRoom: isFromAnotherRoom,
          isMove: false,
        );
  }

  Stream<List<ZegoUIKitUser>> getAudioVideoListStream({
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.stream.roomStreams
            .getRoom(
              targetRoomID,
            )
            .audioVideoListStreamCtrl
            ?.stream
            .map((users) => users.map((e) => e.toZegoUikitUser()).toList()) ??
        const Stream.empty();
  }

  /// get audio video list
  List<ZegoUIKitUser> getAudioVideoList({
    required String targetRoomID,
    bool onlyTargetRoom = true,
  }) {
    final list = ZegoUIKitCore.shared.coreData.stream.roomStreams
        .getRoom(
          targetRoomID,
        )
        .getAudioVideoList(onlyCurrentRoom: onlyTargetRoom);
    return list.map((e) => e.toZegoUikitUser()).toList();
  }

  Stream<List<ZegoUIKitUser>> getScreenSharingListStream({
    required String targetRoomID,
  }) {
    return ZegoUIKitCore
            .shared.coreData.screenSharing.screenSharingListStreamCtrl?.stream
            .map((users) => users.map((e) => e.toZegoUikitUser()).toList()) ??
        const Stream.empty();
  }

  /// get screen sharing list
  List<ZegoUIKitUser> getScreenSharingList({
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.stream.roomStreams
        .getRoom(
          targetRoomID,
        )
        .getAudioVideoList(
          streamType: ZegoStreamType.screenSharing,
        )
        .map((e) => e.toZegoUikitUser())
        .toList();
  }

  Stream<List<ZegoUIKitUser>> getMediaListStream({
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.media.mediaListStreamCtrl?.stream
            .map((users) => users.map((e) => e.toZegoUikitUser()).toList()) ??
        const Stream.empty();
  }

  /// get media list
  List<ZegoUIKitUser> getMediaList({
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.stream.roomStreams
        .getRoom(
          targetRoomID,
        )
        .getAudioVideoList(
          streamType: ZegoStreamType.media,
        )
        .map((e) => e.toZegoUikitUser())
        .toList();
  }

  /// start share screen
  Future<void> startSharingScreen({
    required String targetRoomID,
  }) async {
    return ZegoUIKitCore.shared.coreData.screenSharing.startSharingScreen(
      targetRoomID: targetRoomID,
    );
  }

  /// stop share screen
  Future<void> stopSharingScreen({
    required String targetRoomID,
  }) async {
    return ZegoUIKitCore.shared.coreData.screenSharing.stopSharingScreen(
      targetRoomID: targetRoomID,
    );
  }

  /// get video size notifier
  ValueNotifier<Size> getVideoSizeNotifier(
    String userID, {
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.user
        .getUser(
          userID,
          targetRoomID: targetRoomID,
        )
        .mainChannel
        .viewSizeNotifier;
  }

  ValueNotifier<ZegoUIKitPlayerState> getStreamPlayerStateNotifier(
    String userID, {
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.user
        .getUser(
          userID,
          targetRoomID: targetRoomID,
        )
        .mainChannel
        .playerStateNotifier;
  }

  /// update texture render orientation
  void updateTextureRendererOrientation(Orientation orientation) {
    ZegoUIKitCore.shared.updateTextureRendererOrientation(orientation);
  }

  /// update app orientation
  void updateAppOrientation(DeviceOrientation orientation) {
    ZegoUIKitCore.shared.updateAppOrientation(orientation);
  }

  /// update video view mode
  void updateVideoViewMode(bool useVideoViewAspectFill) {
    ZegoUIKitCore.shared.updateVideoViewMode(useVideoViewAspectFill);
  }

  Stream<ZegoUIKitReceiveSEIEvent> getReceiveSEIStream({
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.stream.roomStreams
            .getRoom(
              targetRoomID,
            )
            .receiveSEIStreamCtrl
            ?.stream ??
        const Stream.empty();
  }

  Stream<ZegoUIKitReceiveSEIEvent> getReceiveCustomSEIStream({
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.stream.roomStreams
            .getRoom(
              targetRoomID,
            )
            .receiveSEIStreamCtrl
            ?.stream
            .where((event) {
          return event.typeIdentifier == ZegoUIKitInnerSEIType.custom.name;
        }) ??
        const Stream.empty();
  }

  String getGeneratedStreamID(
    String userID,
    String roomID,
    ZegoStreamType type,
  ) {
    return generateStreamID(userID, roomID, type);
  }
}
