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
    ZegoUIKitCore.shared.setAudioOutputToSpeaker(isSpeaker);
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
          return ZegoUIKitCore.shared.coreData.localUser.mainChannel.view;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return ZegoUIKitCore.shared.coreData.localUser.auxChannel.view;
      }
    } else {
      final targetUser = ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: ZegoUIKitCoreUser.empty);
      switch (streamType) {
        case ZegoStreamType.main:
          return targetUser.mainChannel.view;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return targetUser.auxChannel.view;
        // return targetUser.thirdChannel.view;
      }
    }
  }

  /// get audio video view id notifier
  int getAudioVideoViewID(
    String? userID, {
    ZegoStreamType streamType = ZegoStreamType.main,
  }) {
    if (userID == null ||
        userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      switch (streamType) {
        case ZegoStreamType.main:
          return ZegoUIKitCore.shared.coreData.localUser.mainChannel.viewID;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return ZegoUIKitCore.shared.coreData.localUser.auxChannel.viewID;
      }
    } else {
      final targetUser = ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: ZegoUIKitCoreUser.empty);
      switch (streamType) {
        case ZegoStreamType.main:
          return targetUser.mainChannel.viewID;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return targetUser.auxChannel.viewID;
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
          return ZegoUIKitCore.shared.coreData.localUser.mainChannel.quality;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return ZegoUIKitCore.shared.coreData.localUser.auxChannel.quality;
      }
    } else {
      final targetUser = ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: ZegoUIKitCoreUser.empty);
      switch (streamType) {
        case ZegoStreamType.main:
          return targetUser.mainChannel.quality;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return targetUser.auxChannel.quality;
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
              .shared.coreData.localUser.mainChannel.isCapturedAudioFirstFrame;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return ZegoUIKitCore
              .shared.coreData.localUser.auxChannel.isCapturedAudioFirstFrame;
      }
    } else {
      final targetUser = ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: ZegoUIKitCoreUser.empty);
      switch (streamType) {
        case ZegoStreamType.main:
          return targetUser.mainChannel.isCapturedAudioFirstFrame;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return targetUser.auxChannel.isCapturedAudioFirstFrame;
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
              .shared.coreData.localUser.mainChannel.isCapturedVideoFirstFrame;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return ZegoUIKitCore
              .shared.coreData.localUser.auxChannel.isCapturedVideoFirstFrame;
      }
    } else {
      final targetUser = ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: ZegoUIKitCoreUser.empty);
      switch (streamType) {
        case ZegoStreamType.main:
          return targetUser.mainChannel.isCapturedVideoFirstFrame;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return targetUser.auxChannel.isCapturedVideoFirstFrame;
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
              .shared.coreData.localUser.mainChannel.isSendAudioFirstFrame;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return ZegoUIKitCore
              .shared.coreData.localUser.auxChannel.isSendAudioFirstFrame;
      }
    } else {
      final targetUser = ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: ZegoUIKitCoreUser.empty);
      switch (streamType) {
        case ZegoStreamType.main:
          return targetUser.mainChannel.isSendAudioFirstFrame;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return targetUser.auxChannel.isSendAudioFirstFrame;
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
              .shared.coreData.localUser.mainChannel.isSendVideoFirstFrame;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return ZegoUIKitCore
              .shared.coreData.localUser.auxChannel.isSendVideoFirstFrame;
      }
    } else {
      final targetUser = ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: ZegoUIKitCoreUser.empty);
      switch (streamType) {
        case ZegoStreamType.main:
          return targetUser.mainChannel.isSendVideoFirstFrame;
        case ZegoStreamType.media:
        case ZegoStreamType.screenSharing:
        case ZegoStreamType.mix:
          return targetUser.auxChannel.isSendVideoFirstFrame;
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
            .soundLevel
            ?.stream ??
        const Stream.empty();
  }

  Stream<List<ZegoUIKitUser>> getAudioVideoListStream() {
    return ZegoUIKitCore.shared.coreData.audioVideoListStreamCtrl?.stream
            .map((users) => users.map((e) => e.toZegoUikitUser()).toList()) ??
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
    return ZegoUIKitCore.shared.coreData.media.mediaListStreamCtrl?.stream
            .map((users) => users.map((e) => e.toZegoUikitUser()).toList()) ??
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
    return ZegoUIKitCore.shared.coreData.startSharingScreen();
  }

  /// stop share screen
  Future<void> stopSharingScreen() async {
    return ZegoUIKitCore.shared.coreData.stopSharingScreen();
  }

  /// get video size notifier
  ValueNotifier<Size> getVideoSizeNotifier(String userID) {
    return ZegoUIKitCore.shared.coreData.getUser(userID).mainChannel.viewSize;
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
    return ZegoUIKitCore.shared.coreData.receiveSEIStreamCtrl?.stream
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
