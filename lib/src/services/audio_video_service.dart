part of 'uikit_service.dart';

mixin ZegoAudioVideoService {
  /// start play all audio video
  Future<void> startPlayAllAudioVideo() async {
    return ZegoUIKitCore.shared.startPlayAllAudioVideo();
  }

  /// stop play all audio video
  Future<void> stopPlayAllAudioVideo() async {
    return ZegoUIKitCore.shared.stopPlayAllAudioVideo();
  }

  /// start play all audio
  Future<void> startPlayAllAudio() async {
    return ZegoUIKitCore.shared.startPlayAllAudio();
  }

  /// stop play all audio
  Future<void> stopPlayAllAudio() async {
    return ZegoUIKitCore.shared.stopPlayAllAudio();
  }

  /// When the [mute] is set to true, it means that the device is not actually turned off, but muted.
  /// The default value is false, which means the device is turned off.
  /// When either the camera or the microphone is muted, the audio and video views will still be visible.
  Future<bool> muteUserAudioVideo(String userID, bool mute) async {
    return ZegoUIKitCore.shared.muteUserAudioVideo(userID, mute);
  }

  /// When the [mute] is set to true, it means that the device is not actually turned off, but muted.
  /// The default value is false, which means the device is turned off.
  /// When either the camera or the microphone is muted, the audio and video views will still be visible.
  Future<bool> muteUserAudio(String userID, bool mute) async {
    return ZegoUIKitCore.shared.muteUserAudio(userID, mute);
  }

  /// When the [mute] is set to true, it means that the device is not actually turned off, but muted.
  /// The default value is false, which means the device is turned off.
  /// When either the camera or the microphone is muted, the audio and video views will still be visible.
  Future<bool> muteUserVideo(String userID, bool mute) async {
    return ZegoUIKitCore.shared.muteUserVideo(userID, mute);
  }

  /// set audio output to speaker
  void setAudioOutputToSpeaker(bool isSpeaker) {
    ZegoUIKitCore.shared.setAudioRouteToSpeaker(isSpeaker);
  }

  Future<void> setAudioConfig(
    ZegoUIKitAudioConfig config, {
    ZegoStreamType streamType = ZegoStreamType.main,
  }) async {
    await ZegoUIKitCore.shared.setAudioConfig(config, streamType: streamType);
  }

  /// Audio 3A - Enable/disable echo cancellation (AEC)
  ///
  /// After calling this method, the SDK will no longer automatically determine whether to enable echo cancellation.
  ///
  /// Call this method at: After joining a room
  ///
  /// @param enable true to enable echo cancellation, false to disable
  void enableAEC(bool enable) {
    ZegoUIKitCore.shared.enableAEC(enable);
  }

  /// Audio 3A - Enable/disable echo cancellation when using headphones
  ///
  /// Recommended for voice chat and gaming scenarios.
  ///
  /// Call this method at: After joining a room
  ///
  /// @param enable true to enable headphone AEC, false to disable (default)
  void enableHeadphoneAEC(bool enable) {
    ZegoUIKitCore.shared.enableHeadphoneAEC(enable);
  }

  /// Audio 3A - Set echo cancellation mode
  ///
  /// Call this method at: After enabling AEC (enableAEC(true))
  ///
  /// @param mode AEC mode: Aggressive, Medium, or Soft
  void setAECMode(ZegoAECMode mode) {
    ZegoUIKitCore.shared.setAECMode(mode);
  }

  /// Audio 3A - Enable/disable automatic gain control (AGC)
  ///
  /// Recommended to disable in music scenarios.
  ///
  /// Call this method at: After joining a room
  ///
  /// @param enable true to enable AGC, false to disable
  void enableAGC(bool enable) {
    ZegoUIKitCore.shared.enableAGC(enable);
  }

  /// Audio 3A - Enable/disable noise suppression (ANS)
  ///
  /// Helps make voice clearer.
  ///
  /// Call this method at: After joining a room
  ///
  /// @param enable true to enable ANS, false to disable
  void enableANS(bool enable) {
    ZegoUIKitCore.shared.enableANS(enable);
  }

  /// Audio 3A - Enable/disable transient noise suppression
  ///
  /// Helps suppress transient noises such as keyboard typing and tapping.
  ///
  /// Call this method at: After joining a room
  ///
  /// @param enable true to enable transient ANS, false to disable (default)
  void enableTransientANS(bool enable) {
    ZegoUIKitCore.shared.enableTransientANS(enable);
  }

  /// Audio 3A - Set noise suppression mode
  ///
  /// Call this method at: After enabling ANS (enableANS(true))
  ///
  /// @param mode ANS mode: Aggressive, Medium (default), or Soft
  void setANSMode(ZegoANSMode mode) {
    ZegoUIKitCore.shared.setANSMode(mode);
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
  void turnCameraOn(bool isOn, {String? userID}) {
    ZegoUIKitCore.shared.turnCameraOn(
      userID?.isEmpty ?? true
          ? ZegoUIKitCore.shared.coreData.localUser.id
          : userID!,
      isOn,
    );
  }

  /// turn on/off microphone
  ///
  /// When the [muteMode] is set to true, it means that the device is not actually turned off, but muted.
  /// The default value is false, which means the device is turned off.
  /// When either the camera or the microphone is muted, the audio and video views will still be visible.
  void turnMicrophoneOn(bool isOn, {String? userID, bool muteMode = false}) {
    ZegoUIKitCore.shared.turnMicrophoneOn(
      userID?.isEmpty ?? true
          ? ZegoUIKitCore.shared.coreData.localUser.id
          : userID!,
      isOn,
      muteMode: muteMode,
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

  void setAudioVideoResourceMode(ZegoAudioVideoResourceMode mode) {
    ZegoUIKitCore.shared.setAudioVideoResourceMode(mode);
  }

  void enableSyncDeviceStatusBySEI(bool value) {
    ZegoUIKitCore.shared.enableSyncDeviceStatusBySEI(value);
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

  /// get audio video view notifier
  ValueNotifier<Widget?> getAudioVideoViewNotifier(
    String? userID, {
    ZegoStreamType streamType = ZegoStreamType.main,
  }) {
    if (userID == null ||
        userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      switch (streamType) {
        case ZegoStreamType.main:
          return ZegoUIKitCore
              .shared
              .coreData
              .localUser
              .mainChannel
              .viewNotifier;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return ZegoUIKitCore
              .shared
              .coreData
              .localUser
              .auxChannel
              .viewNotifier;
      }
    } else {
      final targetUser = ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere(
            (user) => user.id == userID,
            orElse: ZegoUIKitCoreUser.empty,
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
  }

  /// get audio video view id notifier
  ValueNotifier<int?> getAudioVideoViewIDNotifier(
    String? userID, {
    ZegoStreamType streamType = ZegoStreamType.main,
  }) {
    if (userID == null ||
        userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      switch (streamType) {
        case ZegoStreamType.main:
          return ZegoUIKitCore
              .shared
              .coreData
              .localUser
              .mainChannel
              .viewIDNotifier;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return ZegoUIKitCore
              .shared
              .coreData
              .localUser
              .auxChannel
              .viewIDNotifier;
      }
    } else {
      final targetUser = ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere(
            (user) => user.id == userID,
            orElse: ZegoUIKitCoreUser.empty,
          );
      switch (streamType) {
        case ZegoStreamType.main:
          return targetUser.mainChannel.viewIDNotifier;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return targetUser.auxChannel.viewIDNotifier;
        // return targetUser.thirdChannel.view;
      }
    }
  }

  ValueNotifier<ZegoUIKitPublishStreamQuality> getAudioVideoQualityNotifier(
    String? userID, {
    ZegoStreamType streamType = ZegoStreamType.main,
  }) {
    if (userID == null ||
        userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      switch (streamType) {
        case ZegoStreamType.main:
          return ZegoUIKitCore
              .shared
              .coreData
              .localUser
              .mainChannel
              .qualityNotifier;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return ZegoUIKitCore
              .shared
              .coreData
              .localUser
              .auxChannel
              .qualityNotifier;
      }
    } else {
      final targetUser = ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere(
            (user) => user.id == userID,
            orElse: ZegoUIKitCoreUser.empty,
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
  }

  ValueNotifier<bool> getAudioVideoCapturedAudioFirstFrameNotifier(
    String? userID, {
    ZegoStreamType streamType = ZegoStreamType.main,
  }) {
    if (userID == null ||
        userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      switch (streamType) {
        case ZegoStreamType.main:
          return ZegoUIKitCore
              .shared
              .coreData
              .localUser
              .mainChannel
              .isCapturedAudioFirstFrameNotifier;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return ZegoUIKitCore
              .shared
              .coreData
              .localUser
              .auxChannel
              .isCapturedAudioFirstFrameNotifier;
      }
    } else {
      final targetUser = ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere(
            (user) => user.id == userID,
            orElse: ZegoUIKitCoreUser.empty,
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
  }

  ValueNotifier<bool> getAudioVideoCapturedVideoFirstFrameNotifier(
    String? userID, {
    ZegoStreamType streamType = ZegoStreamType.main,
  }) {
    if (userID == null ||
        userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      switch (streamType) {
        case ZegoStreamType.main:
          return ZegoUIKitCore
              .shared
              .coreData
              .localUser
              .mainChannel
              .isCapturedVideoFirstFrameNotifier;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return ZegoUIKitCore
              .shared
              .coreData
              .localUser
              .auxChannel
              .isCapturedVideoFirstFrameNotifier;
      }
    } else {
      final targetUser = ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere(
            (user) => user.id == userID,
            orElse: ZegoUIKitCoreUser.empty,
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
  }

  ValueNotifier<bool> getAudioVideoSendAudioFirstFrameNotifier(
    String? userID, {
    ZegoStreamType streamType = ZegoStreamType.main,
  }) {
    if (userID == null ||
        userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      switch (streamType) {
        case ZegoStreamType.main:
          return ZegoUIKitCore
              .shared
              .coreData
              .localUser
              .mainChannel
              .isSendAudioFirstFrameNotifier;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return ZegoUIKitCore
              .shared
              .coreData
              .localUser
              .auxChannel
              .isSendAudioFirstFrameNotifier;
      }
    } else {
      final targetUser = ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere(
            (user) => user.id == userID,
            orElse: ZegoUIKitCoreUser.empty,
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
  }

  ValueNotifier<bool> getAudioVideoSendVideoFirstFrameNotifier(
    String? userID, {
    ZegoStreamType streamType = ZegoStreamType.main,
  }) {
    if (userID == null ||
        userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      switch (streamType) {
        case ZegoStreamType.main:
          return ZegoUIKitCore
              .shared
              .coreData
              .localUser
              .mainChannel
              .isSendVideoFirstFrameNotifier;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return ZegoUIKitCore
              .shared
              .coreData
              .localUser
              .auxChannel
              .isSendVideoFirstFrameNotifier;
      }
    } else {
      final targetUser = ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere(
            (user) => user.id == userID,
            orElse: ZegoUIKitCoreUser.empty,
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
  }

  /// get camera state notifier
  ValueNotifier<bool> getCameraStateNotifier(String userID) {
    return ZegoUIKitCore.shared.coreData.getUser(userID).camera;
  }

  /// get front facing camera switch notifier
  ValueNotifier<bool> getUseFrontFacingCameraStateNotifier(String userID) {
    return ZegoUIKitCore.shared.coreData.getUser(userID).isFrontFacing;
  }

  /// get microphone state notifier
  ValueNotifier<bool> getMicrophoneStateNotifier(String userID) {
    return ZegoUIKitCore.shared.coreData.getUser(userID).microphone;
  }

  /// get audio output device notifier
  ValueNotifier<ZegoUIKitAudioRoute> getAudioOutputDeviceNotifier(
    String userID,
  ) {
    return ZegoUIKitCore.shared.coreData.getUser(userID).audioRoute;
  }

  /// get screen share notifier
  ValueNotifier<bool> getScreenSharingStateNotifier() {
    return ZegoUIKitCore.shared.coreData.isScreenSharing;
  }

  /// get sound level notifier
  Stream<double> getSoundLevelStream(String userID) {
    return ZegoUIKitCore.shared.coreData
            .getUser(userID)
            .mainChannel
            .soundLevelStream
            ?.stream ??
        const Stream.empty();
  }

  Stream<List<ZegoUIKitUser>> getAudioVideoListStream() {
    return ZegoUIKitCore.shared.coreData.audioVideoListStreamCtrl?.stream.map(
          (users) => users.map((e) => e.toZegoUikitUser()).toList(),
        ) ??
        const Stream.empty();
  }

  /// get audio video list
  List<ZegoUIKitUser> getAudioVideoList() {
    return ZegoUIKitCore.shared.coreData
        .getAudioVideoList()
        .map((e) => e.toZegoUikitUser())
        .toList();
  }

  Stream<List<ZegoUIKitUser>> getScreenSharingListStream() {
    return ZegoUIKitCore.shared.coreData.screenSharingListStreamCtrl?.stream
            .map((users) => users.map((e) => e.toZegoUikitUser()).toList()) ??
        const Stream.empty();
  }

  /// get screen sharing list
  List<ZegoUIKitUser> getScreenSharingList() {
    return ZegoUIKitCore.shared.coreData
        .getAudioVideoList(streamType: ZegoStreamType.screenSharing)
        .map((e) => e.toZegoUikitUser())
        .toList();
  }

  Stream<List<ZegoUIKitUser>> getMediaListStream() {
    return ZegoUIKitCore.shared.coreData.media.mediaListStreamCtrl?.stream.map(
          (users) => users.map((e) => e.toZegoUikitUser()).toList(),
        ) ??
        const Stream.empty();
  }

  /// get media list
  List<ZegoUIKitUser> getMediaList() {
    return ZegoUIKitCore.shared.coreData
        .getAudioVideoList(streamType: ZegoStreamType.media)
        .map((e) => e.toZegoUikitUser())
        .toList();
  }

  /// start share screen
  Future<void> startSharingScreen() async {
    await ZegoUIKitCore.shared.coreData.startSharingScreen();
    await ZegoUIKitCore.shared.syncDeviceStatusByStreamExtraInfo(
      streamType: ZegoStreamType.screenSharing,
      hardcodeCamera: true,
      hardcodeMicrophone: true,
    );
  }

  /// stop share screen
  Future<void> stopSharingScreen() async {
    return ZegoUIKitCore.shared.coreData.stopSharingScreen();
  }

  /// get video size notifier
  ValueNotifier<Size> getVideoSizeNotifier(String userID) {
    return ZegoUIKitCore.shared.coreData
        .getUser(userID)
        .mainChannel
        .viewSizeNotifier;
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

  Stream<ZegoUIKitReceiveSEIEvent> getReceiveSEIStream() {
    return ZegoUIKitCore.shared.coreData.receiveSEIStreamCtrl?.stream ??
        const Stream.empty();
  }

  Stream<ZegoUIKitReceiveSEIEvent> getReceiveCustomSEIStream() {
    return ZegoUIKitCore.shared.coreData.receiveSEIStreamCtrl?.stream.where((
          event,
        ) {
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
