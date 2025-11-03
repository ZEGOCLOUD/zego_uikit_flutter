part of 'event.dart';

mixin ZegoUIKitExpressEvent {
  final _expressImpl = ZegoUIKitExpressEventImpl();

  ZegoUIKitExpressEventImpl get express => _expressImpl;
}

class ZegoUIKitExpressEventImpl {
  List<ZegoUIKitExpressEventInterface> events = [];

  void register(ZegoUIKitExpressEventInterface event) {
    if (events.contains(event)) {
      ZegoLoggerService.logInfo(
        '${event.hashCode} has registered',
        tag: 'uikit-event',
        subTag: 'express',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'register, ${event.hashCode}',
      tag: 'uikit-event',
      subTag: 'express',
    );

    events.add(event);
  }

  void unregister(ZegoUIKitExpressEventInterface event) {
    ZegoLoggerService.logInfo(
      'unregister, ${event.hashCode}',
      tag: 'uikit-event',
      subTag: 'express',
    );

    events.remove(event);
  }

  void init() {
    ZegoExpressEngine.onDebugError = onDebugError;
    ZegoExpressEngine.onApiCalledResult = onApiCalledResult;
    ZegoExpressEngine.onEngineStateUpdate = onEngineStateUpdate;
    ZegoExpressEngine.onRecvExperimentalAPI = onRecvExperimentalAPI;
    ZegoExpressEngine.onFatalError = onFatalError;
    ZegoExpressEngine.onRoomStateUpdate = onRoomStateUpdate;
    ZegoExpressEngine.onRoomStateChanged = onRoomStateChanged;
    ZegoExpressEngine.onRoomUserUpdate = onRoomUserUpdate;
    ZegoExpressEngine.onRoomOnlineUserCountUpdate = onRoomOnlineUserCountUpdate;
    ZegoExpressEngine.onRoomStreamUpdate = onRoomStreamUpdate;
    ZegoExpressEngine.onRoomStreamExtraInfoUpdate = onRoomStreamExtraInfoUpdate;
    ZegoExpressEngine.onRoomExtraInfoUpdate = onRoomExtraInfoUpdate;
    ZegoExpressEngine.onRoomTokenWillExpire = onRoomTokenWillExpire;
    ZegoExpressEngine.onPublisherStateUpdate = onPublisherStateUpdate;
    ZegoExpressEngine.onPublisherQualityUpdate = onPublisherQualityUpdate;
    ZegoExpressEngine.onPublisherCapturedAudioFirstFrame =
        onPublisherCapturedAudioFirstFrame;
    ZegoExpressEngine.onPublisherCapturedVideoFirstFrame =
        onPublisherCapturedVideoFirstFrame;
    ZegoExpressEngine.onPublisherSendAudioFirstFrame =
        onPublisherSendAudioFirstFrame;
    ZegoExpressEngine.onPublisherSendVideoFirstFrame =
        onPublisherSendVideoFirstFrame;
    ZegoExpressEngine.onPublisherRenderVideoFirstFrame =
        onPublisherRenderVideoFirstFrame;
    ZegoExpressEngine.onPublisherVideoSizeChanged = onPublisherVideoSizeChanged;
    ZegoExpressEngine.onPublisherRelayCDNStateUpdate =
        onPublisherRelayCDNStateUpdate;
    ZegoExpressEngine.onPublisherVideoEncoderChanged =
        onPublisherVideoEncoderChanged;
    ZegoExpressEngine.onPublisherStreamEvent = onPublisherStreamEvent;
    ZegoExpressEngine.onVideoObjectSegmentationStateChanged =
        onVideoObjectSegmentationStateChanged;
    ZegoExpressEngine.onPublisherLowFpsWarning = onPublisherLowFpsWarning;
    ZegoExpressEngine.onPublisherDummyCaptureImagePathError =
        onPublisherDummyCaptureImagePathError;
    ZegoExpressEngine.onPlayerStateUpdate = onPlayerStateUpdate;
    ZegoExpressEngine.onPlayerQualityUpdate = onPlayerQualityUpdate;
    ZegoExpressEngine.onPlayerMediaEvent = onPlayerMediaEvent;
    ZegoExpressEngine.onPlayerRecvAudioFirstFrame = onPlayerRecvAudioFirstFrame;
    ZegoExpressEngine.onPlayerRecvVideoFirstFrame = onPlayerRecvVideoFirstFrame;
    ZegoExpressEngine.onPlayerRenderVideoFirstFrame =
        onPlayerRenderVideoFirstFrame;
    ZegoExpressEngine.onPlayerRenderCameraVideoFirstFrame =
        onPlayerRenderCameraVideoFirstFrame;
    ZegoExpressEngine.onPlayerVideoSizeChanged = onPlayerVideoSizeChanged;
    ZegoExpressEngine.onPlayerRecvSEI = onPlayerRecvSEI;
    ZegoExpressEngine.onPlayerRecvMediaSideInfo = onPlayerRecvMediaSideInfo;
    ZegoExpressEngine.onPlayerRecvAudioSideInfo = onPlayerRecvAudioSideInfo;
    ZegoExpressEngine.onPlayerLowFpsWarning = onPlayerLowFpsWarning;
    ZegoExpressEngine.onPlayerStreamEvent = onPlayerStreamEvent;
    ZegoExpressEngine.onPlayerVideoSuperResolutionUpdate =
        onPlayerVideoSuperResolutionUpdate;
    ZegoExpressEngine.onMixerRelayCDNStateUpdate = onMixerRelayCDNStateUpdate;
    ZegoExpressEngine.onMixerSoundLevelUpdate = onMixerSoundLevelUpdate;
    ZegoExpressEngine.onAutoMixerSoundLevelUpdate = onAutoMixerSoundLevelUpdate;
    ZegoExpressEngine.onAudioDeviceStateChanged = onAudioDeviceStateChanged;
    ZegoExpressEngine.onAudioDeviceVolumeChanged = onAudioDeviceVolumeChanged;
    ZegoExpressEngine.onVideoDeviceStateChanged = onVideoDeviceStateChanged;
    ZegoExpressEngine.onCapturedSoundLevelUpdate = onCapturedSoundLevelUpdate;
    ZegoExpressEngine.onCapturedSoundLevelInfoUpdate =
        onCapturedSoundLevelInfoUpdate;
    ZegoExpressEngine.onRemoteSoundLevelUpdate = onRemoteSoundLevelUpdate;
    ZegoExpressEngine.onRemoteSoundLevelInfoUpdate =
        onRemoteSoundLevelInfoUpdate;
    ZegoExpressEngine.onCapturedAudioSpectrumUpdate =
        onCapturedAudioSpectrumUpdate;
    ZegoExpressEngine.onRemoteAudioSpectrumUpdate = onRemoteAudioSpectrumUpdate;
    ZegoExpressEngine.onLocalDeviceExceptionOccurred =
        onLocalDeviceExceptionOccurred;
    ZegoExpressEngine.onRemoteCameraStateUpdate = onRemoteCameraStateUpdate;
    ZegoExpressEngine.onRemoteMicStateUpdate = onRemoteMicStateUpdate;
    ZegoExpressEngine.onRemoteSpeakerStateUpdate = onRemoteSpeakerStateUpdate;
    ZegoExpressEngine.onAudioRouteChange = onAudioRouteChange;
    ZegoExpressEngine.onAudioVADStateUpdate = onAudioVADStateUpdate;
    ZegoExpressEngine.onReceiveRealTimeSequentialData =
        onReceiveRealTimeSequentialData;
    ZegoExpressEngine.onRecvRoomTransparentMessage =
        onRecvRoomTransparentMessage;
    ZegoExpressEngine.onIMRecvBroadcastMessage = onIMRecvBroadcastMessage;
    ZegoExpressEngine.onIMRecvBarrageMessage = onIMRecvBarrageMessage;
    ZegoExpressEngine.onIMRecvCustomCommand = onIMRecvCustomCommand;
    ZegoExpressEngine.onAudioEffectPlayStateUpdate =
        onAudioEffectPlayStateUpdate;
    ZegoExpressEngine.onCapturedDataRecordStateUpdate =
        onCapturedDataRecordStateUpdate;
    ZegoExpressEngine.onCapturedDataRecordProgressUpdate =
        onCapturedDataRecordProgressUpdate;
    ZegoExpressEngine.onPerformanceStatusUpdate = onPerformanceStatusUpdate;
    ZegoExpressEngine.onNetworkSpeedTestError = onNetworkSpeedTestError;
    ZegoExpressEngine.onNetworkSpeedTestQualityUpdate =
        onNetworkSpeedTestQualityUpdate;
    ZegoExpressEngine.onNetworkQuality = onNetworkQuality;
    ZegoExpressEngine.onNetworkTimeSynchronized = onNetworkTimeSynchronized;
    ZegoExpressEngine.onRequestDumpData = onRequestDumpData;
    ZegoExpressEngine.onRequestUploadDumpData = onRequestUploadDumpData;
    ZegoExpressEngine.onStartDumpData = onStartDumpData;
    ZegoExpressEngine.onStopDumpData = onStopDumpData;
    ZegoExpressEngine.onUploadDumpData = onUploadDumpData;
    ZegoExpressEngine.onProcessCapturedAudioData = onProcessCapturedAudioData;
    ZegoExpressEngine.onProcessCapturedAudioDataAfterUsedHeadphoneMonitor =
        onProcessCapturedAudioDataAfterUsedHeadphoneMonitor;
    ZegoExpressEngine.onAlignedAudioAuxData = onAlignedAudioAuxData;
    ZegoExpressEngine.onProcessRemoteAudioData = onProcessRemoteAudioData;
    ZegoExpressEngine.onProcessPlaybackAudioData = onProcessPlaybackAudioData;
    ZegoExpressEngine.onCapturedAudioData = onCapturedAudioData;
    ZegoExpressEngine.onPlaybackAudioData = onPlaybackAudioData;
    ZegoExpressEngine.onMixedAudioData = onMixedAudioData;
    ZegoExpressEngine.onPlayerAudioData = onPlayerAudioData;
    ZegoExpressEngine.onRangeAudioMicrophoneStateUpdate =
        onRangeAudioMicrophoneStateUpdate;
    ZegoExpressEngine.onDownloadProgressUpdate = onDownloadProgressUpdate;
    ZegoExpressEngine.onCurrentPitchValueUpdate = onCurrentPitchValueUpdate;
    ZegoExpressEngine.onAIVoiceChangerInit = onAIVoiceChangerInit;
    ZegoExpressEngine.onAIVoiceChangerUpdate = onAIVoiceChangerUpdate;
    ZegoExpressEngine.onAIVoiceChangerGetSpeakerList =
        onAIVoiceChangerGetSpeakerList;

    /// screen sharing
    ZegoExpressEngine.onExceptionOccurred = onScreenCaptureExceptionOccurred;
    ZegoExpressEngine.onWindowStateChanged = onScreenCaptureWindowStateChanged;
    ZegoExpressEngine.onRectChanged = onScreenCaptureSourceRectChanged;
    ZegoExpressEngine.onMobileScreenCaptureExceptionOccurred =
        onMobileScreenCaptureExceptionOccurred;
  }

  void uninit() {
    onEngineStateUpdate(ZegoEngineState.Stop);

    ZegoExpressEngine.onDebugError = null;
    ZegoExpressEngine.onApiCalledResult = null;
    ZegoExpressEngine.onEngineStateUpdate = null;
    ZegoExpressEngine.onRecvExperimentalAPI = null;
    ZegoExpressEngine.onFatalError = null;
    ZegoExpressEngine.onRoomStateUpdate = null;
    ZegoExpressEngine.onRoomStateChanged = null;
    ZegoExpressEngine.onRoomUserUpdate = null;
    ZegoExpressEngine.onRoomOnlineUserCountUpdate = null;
    ZegoExpressEngine.onRoomStreamUpdate = null;
    ZegoExpressEngine.onRoomStreamExtraInfoUpdate = null;
    ZegoExpressEngine.onRoomExtraInfoUpdate = null;
    ZegoExpressEngine.onRoomTokenWillExpire = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;
    ZegoExpressEngine.onPublisherQualityUpdate = null;
    ZegoExpressEngine.onPublisherCapturedAudioFirstFrame = null;
    ZegoExpressEngine.onPublisherCapturedVideoFirstFrame = null;
    ZegoExpressEngine.onPublisherSendAudioFirstFrame = null;
    ZegoExpressEngine.onPublisherSendVideoFirstFrame = null;
    ZegoExpressEngine.onPublisherRenderVideoFirstFrame = null;
    ZegoExpressEngine.onPublisherVideoSizeChanged = null;
    ZegoExpressEngine.onPublisherRelayCDNStateUpdate = null;
    ZegoExpressEngine.onPublisherVideoEncoderChanged = null;
    ZegoExpressEngine.onPublisherStreamEvent = null;
    ZegoExpressEngine.onVideoObjectSegmentationStateChanged = null;
    ZegoExpressEngine.onPublisherLowFpsWarning = null;
    ZegoExpressEngine.onPublisherDummyCaptureImagePathError = null;
    ZegoExpressEngine.onPlayerStateUpdate = null;
    ZegoExpressEngine.onPlayerQualityUpdate = null;
    ZegoExpressEngine.onPlayerMediaEvent = null;
    ZegoExpressEngine.onPlayerRecvAudioFirstFrame = null;
    ZegoExpressEngine.onPlayerRecvVideoFirstFrame = null;
    ZegoExpressEngine.onPlayerRenderVideoFirstFrame = null;
    ZegoExpressEngine.onPlayerRenderCameraVideoFirstFrame = null;
    ZegoExpressEngine.onPlayerVideoSizeChanged = null;
    ZegoExpressEngine.onPlayerRecvSEI = null;
    ZegoExpressEngine.onPlayerRecvMediaSideInfo = null;
    ZegoExpressEngine.onPlayerRecvAudioSideInfo = null;
    ZegoExpressEngine.onPlayerLowFpsWarning = null;
    ZegoExpressEngine.onPlayerStreamEvent = null;
    ZegoExpressEngine.onPlayerVideoSuperResolutionUpdate = null;
    ZegoExpressEngine.onMixerRelayCDNStateUpdate = null;
    ZegoExpressEngine.onMixerSoundLevelUpdate = null;
    ZegoExpressEngine.onAutoMixerSoundLevelUpdate = null;
    ZegoExpressEngine.onAudioDeviceStateChanged = null;
    ZegoExpressEngine.onAudioDeviceVolumeChanged = null;
    ZegoExpressEngine.onVideoDeviceStateChanged = null;
    ZegoExpressEngine.onCapturedSoundLevelUpdate = null;
    ZegoExpressEngine.onCapturedSoundLevelInfoUpdate = null;
    ZegoExpressEngine.onRemoteSoundLevelUpdate = null;
    ZegoExpressEngine.onRemoteSoundLevelInfoUpdate = null;
    ZegoExpressEngine.onCapturedAudioSpectrumUpdate = null;
    ZegoExpressEngine.onRemoteAudioSpectrumUpdate = null;
    ZegoExpressEngine.onLocalDeviceExceptionOccurred = null;
    ZegoExpressEngine.onRemoteCameraStateUpdate = null;
    ZegoExpressEngine.onRemoteMicStateUpdate = null;
    ZegoExpressEngine.onRemoteSpeakerStateUpdate = null;
    ZegoExpressEngine.onAudioRouteChange = null;
    ZegoExpressEngine.onAudioVADStateUpdate = null;
    ZegoExpressEngine.onReceiveRealTimeSequentialData = null;
    ZegoExpressEngine.onRecvRoomTransparentMessage = null;
    ZegoExpressEngine.onIMRecvBroadcastMessage = null;
    ZegoExpressEngine.onIMRecvBarrageMessage = null;
    ZegoExpressEngine.onIMRecvCustomCommand = null;
    ZegoExpressEngine.onAudioEffectPlayStateUpdate = null;
    ZegoExpressEngine.onCapturedDataRecordStateUpdate = null;
    ZegoExpressEngine.onCapturedDataRecordProgressUpdate = null;
    ZegoExpressEngine.onPerformanceStatusUpdate = null;
    ZegoExpressEngine.onNetworkSpeedTestError = null;
    ZegoExpressEngine.onNetworkSpeedTestQualityUpdate = null;
    ZegoExpressEngine.onNetworkQuality = null;
    ZegoExpressEngine.onNetworkTimeSynchronized = null;
    ZegoExpressEngine.onRequestDumpData = null;
    ZegoExpressEngine.onRequestUploadDumpData = null;
    ZegoExpressEngine.onStartDumpData = null;
    ZegoExpressEngine.onStopDumpData = null;
    ZegoExpressEngine.onUploadDumpData = null;
    ZegoExpressEngine.onProcessCapturedAudioData = null;
    ZegoExpressEngine.onProcessCapturedAudioDataAfterUsedHeadphoneMonitor =
        null;
    ZegoExpressEngine.onAlignedAudioAuxData = null;
    ZegoExpressEngine.onProcessRemoteAudioData = null;
    ZegoExpressEngine.onProcessPlaybackAudioData = null;
    ZegoExpressEngine.onCapturedAudioData = null;
    ZegoExpressEngine.onPlaybackAudioData = null;
    ZegoExpressEngine.onMixedAudioData = null;
    ZegoExpressEngine.onPlayerAudioData = null;
    ZegoExpressEngine.onRangeAudioMicrophoneStateUpdate = null;
    ZegoExpressEngine.onDownloadProgressUpdate = null;
    ZegoExpressEngine.onCurrentPitchValueUpdate = null;
    ZegoExpressEngine.onExceptionOccurred = null;
    ZegoExpressEngine.onWindowStateChanged = null;
    ZegoExpressEngine.onRectChanged = null;
    ZegoExpressEngine.onMobileScreenCaptureExceptionOccurred = null;
    ZegoExpressEngine.onAIVoiceChangerInit = null;
    ZegoExpressEngine.onAIVoiceChangerUpdate = null;
    ZegoExpressEngine.onAIVoiceChangerGetSpeakerList = null;
  }

  void onDebugError(
    int errorCode,
    String funcName,
    String info,
  ) {
    for (var event in events) {
      event.onDebugError(errorCode, funcName, info);
    }
  }

  void onApiCalledResult(
    int errorCode,
    String funcName,
    String info,
  ) {
    for (var event in events) {
      event.onApiCalledResult(errorCode, funcName, info);
    }
  }

  void onEngineStateUpdate(
    ZegoEngineState state,
  ) {
    for (var event in events) {
      event.onEngineStateUpdate(state);
    }
  }

  void onRecvExperimentalAPI(
    String content,
  ) {
    for (var event in events) {
      event.onRecvExperimentalAPI(content);
    }
  }

  void onFatalError(
    int errorCode,
  ) {
    for (var event in events) {
      event.onFatalError(errorCode);
    }
  }

  void onRoomStateUpdate(
    String roomID,
    ZegoRoomState state,
    int errorCode,
    Map<String, dynamic> extendedData,
  ) {
    for (var event in events) {
      event.onRoomStateUpdate(roomID, state, errorCode, extendedData);
    }
  }

  void onRoomStateChanged(
    String roomID,
    ZegoRoomStateChangedReason reason,
    int errorCode,
    Map<String, dynamic> extendedData,
  ) {
    for (var event in events) {
      event.onRoomStateChanged(roomID, reason, errorCode, extendedData);
    }
  }

  void onRoomUserUpdate(
    String roomID,
    ZegoUpdateType updateType,
    List<ZegoUser> userList,
  ) {
    for (var event in events) {
      event.onRoomUserUpdate(roomID, updateType, userList);
    }
  }

  void onRoomOnlineUserCountUpdate(
    String roomID,
    int count,
  ) {
    for (var event in events) {
      event.onRoomOnlineUserCountUpdate(roomID, count);
    }
  }

  void onRoomStreamUpdate(
    String roomID,
    ZegoUpdateType updateType,
    List<ZegoStream> streamList,
    Map<String, dynamic> extendedData,
  ) {
    for (var event in events) {
      event.onRoomStreamUpdate(roomID, updateType, streamList, extendedData);
    }
  }

  void onRoomStreamExtraInfoUpdate(
    String roomID,
    List<ZegoStream> streamList,
  ) {
    for (var event in events) {
      event.onRoomStreamExtraInfoUpdate(roomID, streamList);
    }
  }

  void onRoomExtraInfoUpdate(
    String roomID,
    List<ZegoRoomExtraInfo> roomExtraInfoList,
  ) {
    for (var event in events) {
      event.onRoomExtraInfoUpdate(roomID, roomExtraInfoList);
    }
  }

  void onRoomTokenWillExpire(
    String roomID,
    int remainTimeInSecond,
  ) {
    for (var event in events) {
      event.onRoomTokenWillExpire(roomID, remainTimeInSecond);
    }
  }

  void onPublisherStateUpdate(
    String streamID,
    ZegoPublisherState state,
    int errorCode,
    Map<String, dynamic> extendedData,
  ) {
    for (var event in events) {
      event.onPublisherStateUpdate(streamID, state, errorCode, extendedData);
    }
  }

  void onPublisherQualityUpdate(
    String streamID,
    ZegoPublishStreamQuality quality,
  ) {
    for (var event in events) {
      event.onPublisherQualityUpdate(streamID, quality);
    }
  }

  void onPublisherCapturedAudioFirstFrame() {
    for (var event in events) {
      event.onPublisherCapturedAudioFirstFrame();
    }
  }

  void onPublisherCapturedVideoFirstFrame(ZegoPublishChannel channel) {
    for (var event in events) {
      event.onPublisherCapturedVideoFirstFrame(channel);
    }
  }

  void onPublisherSendAudioFirstFrame(
    ZegoPublishChannel channel,
  ) {
    for (var event in events) {
      event.onPublisherSendAudioFirstFrame(channel);
    }
  }

  void onPublisherSendVideoFirstFrame(
    ZegoPublishChannel channel,
  ) {
    for (var event in events) {
      event.onPublisherSendVideoFirstFrame(channel);
    }
  }

  void onPublisherRenderVideoFirstFrame(
    ZegoPublishChannel channel,
  ) {
    for (var event in events) {
      event.onPublisherRenderVideoFirstFrame(channel);
    }
  }

  void onPublisherVideoSizeChanged(
    int width,
    int height,
    ZegoPublishChannel channel,
  ) {
    for (var event in events) {
      event.onPublisherVideoSizeChanged(width, height, channel);
    }
  }

  void onPublisherRelayCDNStateUpdate(
    String streamID,
    List<ZegoStreamRelayCDNInfo> infoList,
  ) {
    for (var event in events) {
      event.onPublisherRelayCDNStateUpdate(streamID, infoList);
    }
  }

  void onPublisherVideoEncoderChanged(
    ZegoVideoCodecID fromCodecID,
    ZegoVideoCodecID toCodecID,
    ZegoPublishChannel channel,
  ) {
    for (var event in events) {
      event.onPublisherVideoEncoderChanged(fromCodecID, toCodecID, channel);
    }
  }

  void onPublisherStreamEvent(
    ZegoStreamEvent eventID,
    String streamID,
    String extraInfo,
  ) {
    for (var event in events) {
      event.onPublisherStreamEvent(eventID, streamID, extraInfo);
    }
  }

  void onVideoObjectSegmentationStateChanged(
    ZegoObjectSegmentationState state,
    ZegoPublishChannel channel,
    int errorCode,
  ) {
    for (var event in events) {
      event.onVideoObjectSegmentationStateChanged(state, channel, errorCode);
    }
  }

  void onPublisherLowFpsWarning(
    ZegoVideoCodecID codecID,
    ZegoPublishChannel channel,
  ) {
    for (var event in events) {
      event.onPublisherLowFpsWarning(codecID, channel);
    }
  }

  void onPublisherDummyCaptureImagePathError(
    int errorCode,
    String path,
    ZegoPublishChannel channel,
  ) {
    for (var event in events) {
      event.onPublisherDummyCaptureImagePathError(errorCode, path, channel);
    }
  }

  void onPlayerStateUpdate(
    String streamID,
    ZegoPlayerState state,
    int errorCode,
    Map<String, dynamic> extendedData,
  ) {
    for (var event in events) {
      event.onPlayerStateUpdate(streamID, state, errorCode, extendedData);
    }
  }

  void onPlayerQualityUpdate(
    String streamID,
    ZegoPlayStreamQuality quality,
  ) {
    for (var event in events) {
      event.onPlayerQualityUpdate(streamID, quality);
    }
  }

  void onPlayerMediaEvent(
    String streamID,
    ZegoPlayerMediaEvent mediaEvent,
  ) {
    for (var event in events) {
      event.onPlayerMediaEvent(streamID, mediaEvent);
    }
  }

  void onPlayerRecvAudioFirstFrame(
    String streamID,
  ) {
    for (var event in events) {
      event.onPlayerRecvAudioFirstFrame(streamID);
    }
  }

  void onPlayerRecvVideoFirstFrame(
    String streamID,
  ) {
    for (var event in events) {
      event.onPlayerRecvVideoFirstFrame(streamID);
    }
  }

  void onPlayerRenderVideoFirstFrame(
    String streamID,
  ) {
    for (var event in events) {
      event.onPlayerRenderVideoFirstFrame(streamID);
    }
  }

  void onPlayerRenderCameraVideoFirstFrame(
    String streamID,
  ) {
    for (var event in events) {
      event.onPlayerRenderCameraVideoFirstFrame(streamID);
    }
  }

  void onPlayerVideoSizeChanged(
    String streamID,
    int width,
    int height,
  ) {
    for (var event in events) {
      event.onPlayerVideoSizeChanged(streamID, width, height);
    }
  }

  void onPlayerRecvSEI(
    String streamID,
    Uint8List data,
  ) {
    for (var event in events) {
      event.onPlayerRecvSEI(streamID, data);
    }
  }

  void onPlayerRecvMediaSideInfo(
    ZegoMediaSideInfo info,
  ) {
    for (var event in events) {
      event.onPlayerRecvMediaSideInfo(info);
    }
  }

  void onPlayerRecvAudioSideInfo(
    String streamID,
    Uint8List data,
  ) {
    for (var event in events) {
      event.onPlayerRecvAudioSideInfo(streamID, data);
    }
  }

  void onPlayerLowFpsWarning(
    ZegoVideoCodecID codecID,
    String streamID,
  ) {
    for (var event in events) {
      event.onPlayerLowFpsWarning(codecID, streamID);
    }
  }

  void onPlayerStreamEvent(
    ZegoStreamEvent eventID,
    String streamID,
    String extraInfo,
  ) {
    for (var event in events) {
      event.onPlayerStreamEvent(eventID, streamID, extraInfo);
    }
  }

  void onPlayerVideoSuperResolutionUpdate(
    String streamID,
    ZegoSuperResolutionState state,
    int errorCode,
  ) {
    for (var event in events) {
      event.onPlayerVideoSuperResolutionUpdate(streamID, state, errorCode);
    }
  }

  void onMixerRelayCDNStateUpdate(
    String taskID,
    List<ZegoStreamRelayCDNInfo> infoList,
  ) {
    for (var event in events) {
      event.onMixerRelayCDNStateUpdate(taskID, infoList);
    }
  }

  void onMixerSoundLevelUpdate(
    Map<int, double> soundLevels,
  ) {
    for (var event in events) {
      event.onMixerSoundLevelUpdate(soundLevels);
    }
  }

  void onAutoMixerSoundLevelUpdate(
    Map<String, double> soundLevels,
  ) {
    for (var event in events) {
      event.onAutoMixerSoundLevelUpdate(soundLevels);
    }
  }

  void onAudioDeviceStateChanged(
    ZegoUpdateType updateType,
    ZegoAudioDeviceType deviceType,
    ZegoDeviceInfo deviceInfo,
  ) {
    for (var event in events) {
      event.onAudioDeviceStateChanged(updateType, deviceType, deviceInfo);
    }
  }

  void onAudioDeviceVolumeChanged(
    ZegoAudioDeviceType deviceType,
    String deviceID,
    int volume,
  ) {
    for (var event in events) {
      event.onAudioDeviceVolumeChanged(deviceType, deviceID, volume);
    }
  }

  void onVideoDeviceStateChanged(
    ZegoUpdateType updateType,
    ZegoDeviceInfo deviceInfo,
  ) {
    for (var event in events) {
      event.onVideoDeviceStateChanged(updateType, deviceInfo);
    }
  }

  void onCapturedSoundLevelUpdate(
    double soundLevel,
  ) {
    for (var event in events) {
      event.onCapturedSoundLevelUpdate(soundLevel);
    }
  }

  void onCapturedSoundLevelInfoUpdate(
    ZegoSoundLevelInfo soundLevelInfo,
  ) {
    for (var event in events) {
      event.onCapturedSoundLevelInfoUpdate(soundLevelInfo);
    }
  }

  void onRemoteSoundLevelUpdate(
    Map<String, double> soundLevels,
  ) {
    for (var event in events) {
      event.onRemoteSoundLevelUpdate(soundLevels);
    }
  }

  void onRemoteSoundLevelInfoUpdate(
    Map<String, ZegoSoundLevelInfo> soundLevelInfos,
  ) {
    for (var event in events) {
      event.onRemoteSoundLevelInfoUpdate(soundLevelInfos);
    }
  }

  void onCapturedAudioSpectrumUpdate(
    List<double> audioSpectrum,
  ) {
    for (var event in events) {
      event.onCapturedAudioSpectrumUpdate(audioSpectrum);
    }
  }

  void onRemoteAudioSpectrumUpdate(
    Map<String, List<double>> audioSpectrums,
  ) {
    for (var event in events) {
      event.onRemoteAudioSpectrumUpdate(audioSpectrums);
    }
  }

  void onLocalDeviceExceptionOccurred(
    ZegoDeviceExceptionType exceptionType,
    ZegoDeviceType deviceType,
    String deviceID,
  ) {
    for (var event in events) {
      event.onLocalDeviceExceptionOccurred(exceptionType, deviceType, deviceID);
    }
  }

  void onRemoteCameraStateUpdate(
    String streamID,
    ZegoRemoteDeviceState state,
  ) {
    for (var event in events) {
      event.onRemoteCameraStateUpdate(streamID, state);
    }
  }

  void onRemoteMicStateUpdate(
    String streamID,
    ZegoRemoteDeviceState state,
  ) {
    for (var event in events) {
      event.onRemoteMicStateUpdate(streamID, state);
    }
  }

  void onRemoteSpeakerStateUpdate(
    String streamID,
    ZegoRemoteDeviceState state,
  ) {
    for (var event in events) {
      event.onRemoteSpeakerStateUpdate(streamID, state);
    }
  }

  void onAudioRouteChange(
    ZegoAudioRoute audioRoute,
  ) {
    for (var event in events) {
      event.onAudioRouteChange(audioRoute);
    }
  }

  void onAudioVADStateUpdate(
    ZegoAudioVADStableStateMonitorType type,
    ZegoAudioVADType state,
  ) {
    for (var event in events) {
      event.onAudioVADStateUpdate(type, state);
    }
  }

  void onReceiveRealTimeSequentialData(
    ZegoRealTimeSequentialDataManager manager,
    Uint8List data,
    String streamID,
  ) {
    for (var event in events) {
      event.onReceiveRealTimeSequentialData(manager, data, streamID);
    }
  }

  void onRecvRoomTransparentMessage(
    String roomID,
    ZegoRoomRecvTransparentMessage message,
  ) {
    for (var event in events) {
      event.onRecvRoomTransparentMessage(roomID, message);
    }
  }

  void onIMRecvBroadcastMessage(
    String roomID,
    List<ZegoBroadcastMessageInfo> messageList,
  ) {
    for (var event in events) {
      event.onIMRecvBroadcastMessage(roomID, messageList);
    }
  }

  void onIMRecvBarrageMessage(
    String roomID,
    List<ZegoBarrageMessageInfo> messageList,
  ) {
    for (var event in events) {
      event.onIMRecvBarrageMessage(roomID, messageList);
    }
  }

  void onIMRecvCustomCommand(
    String roomID,
    ZegoUser fromUser,
    String command,
  ) {
    for (var event in events) {
      event.onIMRecvCustomCommand(roomID, fromUser, command);
    }
  }

  void onAudioEffectPlayStateUpdate(
    ZegoAudioEffectPlayer audioEffectPlayer,
    int audioEffectID,
    ZegoAudioEffectPlayState state,
    int errorCode,
  ) {
    for (var event in events) {
      event.onAudioEffectPlayStateUpdate(
          audioEffectPlayer, audioEffectID, state, errorCode);
    }
  }

  void onCapturedDataRecordStateUpdate(
    ZegoDataRecordState state,
    int errorCode,
    ZegoDataRecordConfig config,
    ZegoPublishChannel channel,
  ) {
    for (var event in events) {
      event.onCapturedDataRecordStateUpdate(state, errorCode, config, channel);
    }
  }

  void onCapturedDataRecordProgressUpdate(
    ZegoDataRecordProgress progress,
    ZegoDataRecordConfig config,
    ZegoPublishChannel channel,
  ) {
    for (var event in events) {
      event.onCapturedDataRecordProgressUpdate(progress, config, channel);
    }
  }

  void onPerformanceStatusUpdate(
    ZegoPerformanceStatus status,
  ) {
    for (var event in events) {
      event.onPerformanceStatusUpdate(status);
    }
  }

  void onNetworkModeChanged(
    ZegoNetworkMode mode,
  ) {
    for (var event in events) {
      event.onNetworkModeChanged(mode);
    }
  }

  void onNetworkSpeedTestError(
    int errorCode,
    ZegoNetworkSpeedTestType type,
  ) {
    for (var event in events) {
      event.onNetworkSpeedTestError(errorCode, type);
    }
  }

  void onNetworkSpeedTestQualityUpdate(
    ZegoNetworkSpeedTestQuality quality,
    ZegoNetworkSpeedTestType type,
  ) {
    for (var event in events) {
      event.onNetworkSpeedTestQualityUpdate(quality, type);
    }
  }

  void onNetworkQuality(
    String userID,
    ZegoStreamQualityLevel upstreamQuality,
    ZegoStreamQualityLevel downstreamQuality,
  ) {
    for (var event in events) {
      event.onNetworkQuality(userID, upstreamQuality, downstreamQuality);
    }
  }

  void onNetworkTimeSynchronized() {
    for (var event in events) {
      event.onNetworkTimeSynchronized();
    }
  }

  void onRequestDumpData() {
    for (var event in events) {
      event.onRequestDumpData();
    }
  }

  void onRequestUploadDumpData(
    String dumpDir,
    bool takePhoto,
  ) {
    for (var event in events) {
      event.onRequestUploadDumpData(dumpDir, takePhoto);
    }
  }

  void onStartDumpData(
    int errorCode,
  ) {
    for (var event in events) {
      event.onStartDumpData(errorCode);
    }
  }

  void onStopDumpData(
    int errorCode,
    String dumpDir,
  ) {
    for (var event in events) {
      event.onStopDumpData(errorCode, dumpDir);
    }
  }

  void onUploadDumpData(
    int errorCode,
  ) {
    for (var event in events) {
      event.onUploadDumpData(errorCode);
    }
  }

  void onProcessCapturedAudioData(
    Uint8List data,
    int dataLength,
    ZegoAudioFrameParam param,
    double timestamp,
  ) {
    for (var event in events) {
      event.onProcessCapturedAudioData(data, dataLength, param, timestamp);
    }
  }

  void onProcessCapturedAudioDataAfterUsedHeadphoneMonitor(
    Uint8List data,
    int dataLength,
    ZegoAudioFrameParam param,
    double timestamp,
  ) {
    for (var event in events) {
      event.onProcessCapturedAudioDataAfterUsedHeadphoneMonitor(
        data,
        dataLength,
        param,
        timestamp,
      );
    }
  }

  void onAlignedAudioAuxData(
    Uint8List data,
    ZegoAudioFrameParam param,
  ) {
    for (var event in events) {
      event.onAlignedAudioAuxData(data, param);
    }
  }

  void onProcessRemoteAudioData(
    Uint8List data,
    int dataLength,
    ZegoAudioFrameParam param,
    String streamID,
    double timestamp,
  ) {
    for (var event in events) {
      event.onProcessRemoteAudioData(
          data, dataLength, param, streamID, timestamp);
    }
  }

  void onProcessPlaybackAudioData(
    Uint8List data,
    int dataLength,
    ZegoAudioFrameParam param,
    double timestamp,
  ) {
    for (var event in events) {
      event.onProcessPlaybackAudioData(data, dataLength, param, timestamp);
    }
  }

  void onCapturedAudioData(
    Uint8List data,
    int dataLength,
    ZegoAudioFrameParam param,
  ) {
    for (var event in events) {
      event.onCapturedAudioData(data, dataLength, param);
    }
  }

  void onPlaybackAudioData(
    Uint8List data,
    int dataLength,
    ZegoAudioFrameParam param,
  ) {
    for (var event in events) {
      event.onPlaybackAudioData(data, dataLength, param);
    }
  }

  void onMixedAudioData(
    Uint8List data,
    int dataLength,
    ZegoAudioFrameParam param,
  ) {
    for (var event in events) {
      event.onMixedAudioData(data, dataLength, param);
    }
  }

  void onPlayerAudioData(
    Uint8List data,
    int dataLength,
    ZegoAudioFrameParam param,
    String streamID,
  ) {
    for (var event in events) {
      event.onPlayerAudioData(data, dataLength, param, streamID);
    }
  }

  void onRangeAudioMicrophoneStateUpdate(
    ZegoRangeAudio rangeAudio,
    ZegoRangeAudioMicrophoneState state,
    int errorCode,
  ) {
    for (var event in events) {
      event.onRangeAudioMicrophoneStateUpdate(rangeAudio, state, errorCode);
    }
  }

  void onDownloadProgressUpdate(
    ZegoCopyrightedMusic copyrightedMusic,
    String resourceID,
    double progressRate,
  ) {
    for (var event in events) {
      event.onDownloadProgressUpdate(
          copyrightedMusic, resourceID, progressRate);
    }
  }

  void onCurrentPitchValueUpdate(
    ZegoCopyrightedMusic copyrightedMusic,
    String resourceID,
    int currentDuration,
    int pitchValue,
  ) {
    for (var event in events) {
      event.onCurrentPitchValueUpdate(
          copyrightedMusic, resourceID, currentDuration, pitchValue);
    }
  }

  void onScreenCaptureExceptionOccurred(
    ZegoScreenCaptureSource source,
    ZegoScreenCaptureSourceExceptionType exceptionType,
  ) {
    debugPrint('111 onScreenCaptureExceptionOccurred, '
        'source:$source, '
        'exceptionType:$exceptionType, ');
    for (var event in events) {
      event.onScreenCaptureExceptionOccurred(source, exceptionType);
    }
  }

  void onScreenCaptureWindowStateChanged(
    ZegoScreenCaptureSource source,
    ZegoScreenCaptureWindowState windowState,
    Rect windowRect,
  ) {
    debugPrint('111 onScreenCaptureWindowStateChanged, '
        'source:$source, '
        'windowState:$windowState, '
        'windowRect:$windowRect, '
        '');

    for (var event in events) {
      event.onScreenCaptureWindowStateChanged(source, windowState, windowRect);
    }
  }

  void onScreenCaptureSourceRectChanged(
    ZegoScreenCaptureSource source,
    Rect captureRect,
  ) {
    debugPrint('111 onScreenCaptureSourceRectChanged, '
        'source:$source, '
        'captureRect:$captureRect, ');
    for (var event in events) {
      event.onScreenCaptureSourceRectChanged(source, captureRect);
    }
  }

  void onMobileScreenCaptureExceptionOccurred(
    ZegoScreenCaptureExceptionType exceptionType,
  ) {
    debugPrint('111 onMobileScreenCaptureExceptionOccurred $exceptionType');
    for (var event in events) {
      event.onMobileScreenCaptureExceptionOccurred(exceptionType);
    }
  }

  void onAIVoiceChangerInit(
    ZegoAIVoiceChanger aiVoiceChanger,
    int errorCode,
  ) {
    for (var event in events) {
      event.onAIVoiceChangerInit(aiVoiceChanger, errorCode);
    }
  }

  void onAIVoiceChangerUpdate(
    ZegoAIVoiceChanger aiVoiceChanger,
    int errorCode,
  ) {
    for (var event in events) {
      event.onAIVoiceChangerUpdate(aiVoiceChanger, errorCode);
    }
  }

  void onAIVoiceChangerGetSpeakerList(
    ZegoAIVoiceChanger aiVoiceChanger,
    int errorCode,
    List<ZegoAIVoiceChangerSpeakerInfo> speakerList,
  ) {
    for (var event in events) {
      event.onAIVoiceChangerGetSpeakerList(
        aiVoiceChanger,
        errorCode,
        speakerList,
      );
    }
  }
}
