// Dart imports:
import 'dart:async';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:zego_express_engine_for_uikit/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/channel/platform_interface.dart';
import 'package:zego_uikit/src/services/internal/core/data/canvas_view_create_queue.dart';
import 'package:zego_uikit/src/services/internal/internal.dart';
import 'package:zego_uikit/src/services/services.dart';

/// Starts media playback before serializing the platform-view canvas creation.
/// Audio playback does not depend on a video view being attached to a window.
class StreamStartRequestCoordinator {
  int _nextToken = 0;
  final Map<String, int> _requests = {};

  int? reserve(String streamID) {
    if (_requests.containsKey(streamID)) {
      return null;
    }

    final token = ++_nextToken;
    _requests[streamID] = token;
    return token;
  }

  bool isCurrent(String streamID, int token) => _requests[streamID] == token;

  void release(String streamID, int token) {
    if (isCurrent(streamID, token)) {
      _requests.remove(streamID);
    }
  }

  void cancel(String streamID) => _requests.remove(streamID);

  void clear() => _requests.clear();
}

Future<void> enqueueCanvasCreationAfterStreamStarts({
  required String streamID,
  required ZegoStreamCanvasViewCreateQueue queue,
  required Future<void> Function() startPlayback,
  required Future<void> Function() createCanvas,
  bool Function()? isRequestCurrent,
  void Function()? onRequestFinished,
  void Function()? onRequestStale,
  void Function()? onStaleTask,
}) async {
  await startPlayback();
  if (isRequestCurrent != null && !isRequestCurrent()) {
    onRequestFinished?.call();
    onRequestStale?.call();
    return;
  }

  await queue.addTask(
    uniqueKey: streamID,
    task: () async {
      if (isRequestCurrent != null && !isRequestCurrent()) {
        onRequestFinished?.call();
        onRequestStale?.call();
        onStaleTask?.call();
        return;
      }

      onRequestFinished?.call();
      await createCanvas();
    },
  );
}

void completeCanvasQueueTaskIfCurrent({
  required ZegoStreamCanvasViewCreateQueue queue,
  required bool Function() isCurrent,
}) {
  if (isCurrent()) {
    queue.completeCurrentTask();
  }
}

bool isLocalCanvasQueueTaskCurrent({
  required ZegoStreamCanvasViewCreateQueue queue,
  required String queuedTaskKey,
  required int expectedGeneration,
  required int currentGeneration,
}) =>
    queue.currentTaskKey == queuedTaskKey &&
    currentGeneration == expectedGeneration;

bool isCanvasQueueTaskCurrent({
  required ZegoStreamCanvasViewCreateQueue queue,
  required String streamID,
  required int expectedGeneration,
  required int currentGeneration,
  required String channelStreamID,
  required Iterable<Object> currentUsers,
  required Object targetUser,
  required bool isStreamRecordCurrent,
}) =>
    queue.currentTaskKey == streamID &&
    currentGeneration == expectedGeneration &&
    channelStreamID == streamID &&
    currentUsers.any((user) => identical(user, targetUser)) &&
    isStreamRecordCurrent;

Future<bool> startStreamPlaybackWithCanvasQueue({
  required StreamStartRequestCoordinator requests,
  required String streamID,
  required ZegoStreamCanvasViewCreateQueue queue,
  required void Function() onRequestReserved,
  required bool Function() isCanvasStateCurrent,
  required Future<void> Function() startPlayback,
  required Future<void> Function() createCanvas,
  void Function()? onRequestStale,
  void Function()? onStaleTask,
  required void Function(Object error, StackTrace stackTrace) onError,
}) async {
  final requestToken = requests.reserve(streamID);
  if (requestToken == null) {
    return false;
  }

  try {
    onRequestReserved();
    await enqueueCanvasCreationAfterStreamStarts(
      streamID: streamID,
      queue: queue,
      startPlayback: startPlayback,
      createCanvas: createCanvas,
      isRequestCurrent: () =>
          requests.isCurrent(streamID, requestToken) && isCanvasStateCurrent(),
      onRequestFinished: () => requests.release(streamID, requestToken),
      onRequestStale: onRequestStale,
      onStaleTask: onStaleTask,
    );
  } catch (error, stackTrace) {
    requests.release(streamID, requestToken);
    onError(error, stackTrace);
  }

  return true;
}

/// Release the queue only after asynchronous binding in the canvas-created
/// callback completes, so the next creation cannot interleave with this one.
/// The queue orders Flutter-side creation and binding; it does not mean the
/// native UIView has been attached to a window.
Future<void> completeCanvasViewCreationCallback(
  FutureOr<void> Function() callback, {
  required void Function() onCompleted,
}) async {
  try {
    await callback();
  } finally {
    onCompleted();
  }
}

class ZegoUIKitCoreDataStreamData {
  String userID;
  ZegoPlayerState playerState;
  ZegoPublisherState publisherState;

  ZegoUIKitCoreDataStreamData({
    required this.userID,
    this.playerState = ZegoPlayerState.NoPlay,
    this.publisherState = ZegoPublisherState.NoPublish,
  });

  @override
  String toString() {
    return 'user id:$userID, '
        'player state:$playerState, '
        'publisher state:$publisherState';
  }
}

mixin ZegoUIKitCoreDataStream {
  static const _updatePlayingCanvasNoTextureRenderer =
      'UPDATEPLAYINGCANVAS_NO_TEXTURERENDERER';

  final _streamStartRequests = StreamStartRequestCoordinator();

  bool isEnablePlatformView = false;
  final canvasViewCreateQueue = ZegoStreamCanvasViewCreateQueue();
  bool isPlayingStream = false;
  bool isPublishingStream = false;
  bool isPreviewing = false;
  int? _previewCanvasViewID;
  final Map<int, Future<void>> _startingPreviewCanvasBindings = {};
  // Retain enqueue-time keys so stopPreview can cancel local tasks even if
  // the room ID changes while a canvas view is being created.
  final _localMainCanvasQueueTaskTracker =
      ZegoStreamCanvasViewCreateQueueTaskTracker();
  bool isEnableCustomVideoRender = false;
  final Set<ZegoStreamType> startingPublishingStreamTypes = {};
  bool isUsingFrontCameraRequesting = false;
  bool isSyncDeviceStatusBySEI = true;
  Map<ZegoStreamType, ZegoUIKitAudioConfig> channelAudioConfig = {};

  Map<String, List<PlayerStateUpdateCallback>> playerStateUpdateCallbackList =
      {};

  bool get isCanvasViewCreateByQueue {
    if (Platform.isAndroid) {
      return false;
    }

    return isEnablePlatformView;
  }

  String _describeCanvasState(
    ZegoUIKitCoreUser user,
    ZegoStreamType streamType,
  ) {
    final streamChannel = getUserStreamChannel(user, streamType);
    return 'user:${user.id}, streamID:${streamChannel.streamID}, '
        'streamType:$streamType, generation:${streamChannel.viewCreationGeneration}, '
        'viewID:${streamChannel.viewIDNotifier.value}, '
        'viewCreating:${streamChannel.viewCreatingNotifier.value}, '
        'widgetHash:${streamChannel.viewNotifier.value?.hashCode}, '
        'camera:${user.camera.value}';
  }

  String _describeStreamCanvasState(String streamID) {
    final streamData = streamDic[streamID];
    if (streamData == null) {
      return 'streamID:$streamID, streamData:(missing)';
    }

    final localUser = ZegoUIKitCore.shared.coreData.localUser;
    if (localUser.id == streamData.userID) {
      return _describeCanvasState(localUser, getStreamTypeByID(streamID));
    }

    final userIndex = ZegoUIKitCore.shared.coreData.remoteUsersList
        .indexWhere((user) => user.id == streamData.userID);
    if (userIndex == -1) {
      return 'streamID:$streamID, userID:${streamData.userID}, '
          'streamData:present, user:(not in room list)';
    }

    return _describeCanvasState(
      ZegoUIKitCore.shared.coreData.remoteUsersList[userIndex],
      getStreamTypeByID(streamID),
    );
  }

  final Map<String, ZegoUIKitCoreMixerStream> mixerStreamDic =
      {}; // key:stream_id

  final Map<String, ZegoUIKitCoreDataStreamData> streamDic =
      {}; // stream_id:user_id

  final Map<String, String> streamExtraInfo = {}; // stream_id:extra info

  ZegoAudioVideoResourceMode playResourceMode =
      ZegoAudioVideoResourceMode.defaultMode;

  bool isAllPlayStreamAudioVideoMuted = false;
  bool isAllPlayStreamAudioMuted = false;

  StreamController<List<ZegoUIKitCoreUser>>? audioVideoListStreamCtrl;
  StreamController<String>? turnOnYourCameraRequestStreamCtrl;
  StreamController<ZegoUIKitReceiveTurnOnLocalMicrophoneEvent>?
      turnOnYourMicrophoneRequestStreamCtrl;
  StreamController<ZegoUIKitReceiveSEIEvent>? receiveSEIStreamCtrl;

  bool useVideoViewAspectFill = false;
  ZegoUIKitVideoInternalConfig pushVideoConfig = ZegoUIKitVideoInternalConfig();

  void initStream() {
    ZegoLoggerService.logInfo(
      'init stream',
      tag: 'uikit-stream',
      subTag: 'init',
    );

    audioVideoListStreamCtrl ??=
        StreamController<List<ZegoUIKitCoreUser>>.broadcast();
    turnOnYourCameraRequestStreamCtrl ??= StreamController<String>.broadcast();
    turnOnYourMicrophoneRequestStreamCtrl ??= StreamController<
        ZegoUIKitReceiveTurnOnLocalMicrophoneEvent>.broadcast();
    receiveSEIStreamCtrl ??=
        StreamController<ZegoUIKitReceiveSEIEvent>.broadcast();
  }

  void uninitStream() {
    ZegoLoggerService.logInfo(
      'uninit stream',
      tag: 'uikit-stream',
      subTag: 'uninit',
    );

    isEnableCustomVideoRender = false;

    isEnablePlatformView = false;
    canvasViewCreateQueue.clear();
    _localMainCanvasQueueTaskTracker.clear();
    _streamStartRequests.clear();
    for (final user in [
      ZegoUIKitCore.shared.coreData.localUser,
      ...ZegoUIKitCore.shared.coreData.remoteUsersList,
    ]) {
      for (final channel in [user.mainChannel, user.auxChannel]) {
        channel.viewCreationGeneration++;
        channel.viewCreatingNotifier.value = false;
      }
    }

    audioVideoListStreamCtrl?.close();
    audioVideoListStreamCtrl = null;

    turnOnYourCameraRequestStreamCtrl?.close();
    turnOnYourCameraRequestStreamCtrl = null;

    turnOnYourMicrophoneRequestStreamCtrl?.close();
    turnOnYourMicrophoneRequestStreamCtrl = null;

    receiveSEIStreamCtrl?.close();
    receiveSEIStreamCtrl = null;

    isPreviewing = false;
    _previewCanvasViewID = null;
    isPublishingStream = false;
    isPlayingStream = false;
    startingPublishingStreamTypes.clear();
  }

  String getLocalStreamID(ZegoStreamType streamType) {
    return getLocalStreamChannel(streamType).streamID;
  }

  ZegoUIKitCoreStreamInfo getLocalStreamChannel(ZegoStreamType streamType) {
    return getUserStreamChannel(
      ZegoUIKitCore.shared.coreData.localUser,
      streamType,
    );
  }

  ZegoUIKitCoreStreamInfo getUserStreamChannel(
    ZegoUIKitCoreUser user,
    ZegoStreamType streamType,
  ) {
    switch (streamType) {
      case ZegoStreamType.main:
        return user.mainChannel;
      case ZegoStreamType.media:
      case ZegoStreamType.screenSharing:
      case ZegoStreamType.mix:
        return user.auxChannel;
      // return user.thirdChannel;
    }
  }

  ZegoStreamType getStreamTypeByZegoPublishChannel(
    ZegoUIKitCoreUser user,
    ZegoPublishChannel channel,
  ) {
    switch (channel) {
      case ZegoPublishChannel.Main:
        return ZegoStreamType.main;
      case ZegoPublishChannel.Aux:
        return getStreamTypeByID(user.auxChannel.streamID);
      default:
        break;
    }

    assert(false);
    return ZegoStreamType.main;
  }

  ZegoStreamType getStreamTypeByID(String streamID) {
    if (streamID.endsWith(ZegoStreamType.main.text)) {
      return ZegoStreamType.main;
    } else if (streamID.endsWith(ZegoStreamType.media.text)) {
      return ZegoStreamType.media;
    } else if (streamID.endsWith(ZegoStreamType.screenSharing.text)) {
      return ZegoStreamType.screenSharing;
    } else if (streamID.endsWith(ZegoStreamType.mix.text)) {
      return ZegoStreamType.mix;
    }

    assert(false);
    return ZegoStreamType.main;
  }

  void clearStream() {
    ZegoLoggerService.logInfo(
      'clear stream',
      tag: 'uikit-stream',
      subTag: 'clearStream',
    );

    if (ZegoUIKitCore.shared.coreData.isScreenSharing.value) {
      ZegoUIKitCore.shared.coreData.stopSharingScreen();
    }

    for (final user in ZegoUIKitCore.shared.coreData.remoteUsersList) {
      if (user.mainChannel.streamID.isNotEmpty) {
        stopPlayingStream(user.mainChannel.streamID);
      }
      user.destroyTextureRenderer(streamType: ZegoStreamType.main);

      if (user.auxChannel.streamID.isNotEmpty) {
        stopPlayingStream(user.auxChannel.streamID);
      }
      user.destroyTextureRenderer(streamType: ZegoStreamType.screenSharing);
    }

    if (ZegoUIKitCore
        .shared.coreData.localUser.mainChannel.streamID.isNotEmpty) {
      stopPublishingStream(streamType: ZegoStreamType.main);
      ZegoUIKitCore.shared.coreData.localUser
          .destroyTextureRenderer(streamType: ZegoStreamType.main);
    }
    if (ZegoUIKitCore
        .shared.coreData.localUser.auxChannel.streamID.isNotEmpty) {
      stopPublishingStream(streamType: ZegoStreamType.screenSharing);
      ZegoUIKitCore.shared.coreData.localUser
          .destroyTextureRenderer(streamType: ZegoStreamType.screenSharing);
    }

    isPublishingStream = false;
    isPlayingStream = false;
    isUsingFrontCameraRequesting = false;
  }

  Future<void> startPreview() async {
    final localStreamChannel = getLocalStreamChannel(ZegoStreamType.main);
    ZegoLoggerService.logInfo(
      'request startPreview, roomID:${ZegoUIKitCore.shared.coreData.room.id}, '
      'viewID:${localStreamChannel.viewIDNotifier.value}, '
      'generation:${localStreamChannel.viewCreationGeneration}, '
      'viewCreating:${localStreamChannel.viewCreatingNotifier.value}, '
      'platformView:$isEnablePlatformView, '
      'pipUnderIOS:${ZegoUIKitCore.shared.playingStreamInPIPUnderIOS}, '
      'customRender:$isEnableCustomVideoRender, '
      'camera:${ZegoUIKitCore.shared.coreData.localUser.camera.value}',
      tag: 'uikit-stream',
      subTag: 'start preview',
    );

    await createLocalUserVideoViewQueue(
      streamType: ZegoStreamType.main,
      onViewCreated: onViewCreatedByStartPreview,
    );
  }

  Future<void> onViewCreatedByStartPreview(ZegoStreamType streamType) async {
    ZegoLoggerService.logInfo(
      'start preview, on view created,'
      'view id:${ZegoUIKitCore.shared.coreData.localUser.mainChannel.viewIDNotifier.value}, '
      'generation:${ZegoUIKitCore.shared.coreData.localUser.mainChannel.viewCreationGeneration}, '
      'camera:${ZegoUIKitCore.shared.coreData.localUser.camera.value}, '
      'pipUnderIOS:${ZegoUIKitCore.shared.playingStreamInPIPUnderIOS}, ',
      tag: 'uikit-stream',
      subTag: 'onViewCreatedByStartPreview',
    );

    assert(ZegoUIKitCore
            .shared.coreData.localUser.mainChannel.viewIDNotifier.value !=
        -1);

    final previewViewID = ZegoUIKitCore
            .shared.coreData.localUser.mainChannel.viewIDNotifier.value ??
        -1;
    await _startPreviewOnView(previewViewID);
  }

  Future<void> _startPreviewOnView(int previewViewID) async {
    // isPreviewing does not guarantee that preview is still bound to the current
    // UIView. PiP or a page rebuild can produce a new ViewID, so rebind preview
    // when the ID changes and skip only when it is already bound to this ID.
    if (isPreviewing && _previewCanvasViewID == previewViewID) {
      ZegoLoggerService.logInfo(
        'skip duplicate startPreview, already bound viewID:$previewViewID',
        tag: 'uikit-stream',
        subTag: 'start preview',
      );
      return;
    }

    final inProgressBinding = _startingPreviewCanvasBindings[previewViewID];
    if (inProgressBinding != null) {
      ZegoLoggerService.logInfo(
        'wait duplicate startPreview binding, '
        'viewID:$previewViewID',
        tag: 'uikit-stream',
        subTag: 'start preview',
      );
      await inProgressBinding;
      return;
    }

    final bindingCompleter = Completer<void>();
    _startingPreviewCanvasBindings[previewViewID] = bindingCompleter.future;
    try {
      final previewCanvas = ZegoCanvas(
        previewViewID,
        viewMode: useVideoViewAspectFill
            ? ZegoViewMode.AspectFill
            : ZegoViewMode.AspectFit,
      );
      ZegoLoggerService.logInfo(
        'call express startPreview, viewID:$previewViewID, '
        'generation:${ZegoUIKitCore.shared.coreData.localUser.mainChannel.viewCreationGeneration}, '
        'platformView:$isEnablePlatformView, '
        'pipUnderIOS:${ZegoUIKitCore.shared.playingStreamInPIPUnderIOS}, '
        'camera:${ZegoUIKitCore.shared.coreData.localUser.camera.value}, '
        'isEnableCustomVideoRender:'
        '${ZegoUIKitCore.shared.coreData.isEnableCustomVideoRender}',
        tag: 'uikit-stream',
        subTag: 'start preview',
      );

      await ZegoExpressEngine.instance
          .enableCamera(ZegoUIKitCore.shared.coreData.localUser.camera.value);
      await ZegoExpressEngine.instance.startPreview(canvas: previewCanvas);
      _previewCanvasViewID = previewViewID;
      isPreviewing = true;
      ZegoLoggerService.logInfo(
        'startPreview completed, viewID:$previewViewID, '
        'camera:${ZegoUIKitCore.shared.coreData.localUser.camera.value}',
        tag: 'uikit-stream',
        subTag: 'start preview',
      );
    } catch (error) {
      ZegoLoggerService.logError(
        'startPreview failed, viewID:$previewViewID, error:$error',
        tag: 'uikit-stream',
        subTag: 'start preview',
      );
    } finally {
      _startingPreviewCanvasBindings.remove(previewViewID);
      bindingCompleter.complete();
    }
  }

  Future<void> stopPreview() async {
    final localStreamChannel = getLocalStreamChannel(ZegoStreamType.main);
    final previousViewID = localStreamChannel.viewIDNotifier.value ?? -1;
    final previousGeneration = localStreamChannel.viewCreationGeneration;
    ZegoLoggerService.logInfo(
      'request stopPreview, viewID:$previousViewID, '
      'generation:$previousGeneration, previewing:$isPreviewing, '
      'platformView:$isEnablePlatformView, '
      'pipUnderIOS:${ZegoUIKitCore.shared.playingStreamInPIPUnderIOS}',
      tag: 'uikit-stream',
      subTag: 'stop preview',
    );

    /// It is necessary to cancel the queue waiting in startpreview and the corresponding state that may exist,
    /// otherwise it may not render next time
    if (_localMainCanvasQueueTaskTracker.cancelAll(canvasViewCreateQueue)) {
      ZegoLoggerService.logInfo(
        'stopped canvas view queue',
        tag: 'uikit-stream',
        subTag: 'publish stream',
      );
      getLocalStreamChannel(
        ZegoStreamType.main,
      ).viewCreatingNotifier.value = false;
    }

    await ZegoUIKitCore.shared.coreData.localUser
        .destroyTextureRenderer(streamType: ZegoStreamType.main);

    ZegoLoggerService.logInfo(
      'preview canvas destroy completed, previousViewID:$previousViewID, '
      'generation:$previousGeneration->${localStreamChannel.viewCreationGeneration}, '
      'currentViewID:${localStreamChannel.viewIDNotifier.value}',
      tag: 'uikit-stream',
      subTag: 'stop preview',
    );

    await ZegoExpressEngine.instance.stopPreview().then((_) {
      isPreviewing = false;
      _previewCanvasViewID = null;
      ZegoLoggerService.logInfo(
        'Express stopPreview completed, previousViewID:$previousViewID, '
        'generation:${localStreamChannel.viewCreationGeneration}, '
        'previewing:$isPreviewing',
        tag: 'uikit-stream',
        subTag: 'stop preview',
      );
    });
  }

  Future<void> startPublishingStream({
    required ZegoStreamType streamType,
  }) async {
    final targetStreamID = getLocalStreamID(streamType);
    if (targetStreamID.isNotEmpty) {
      ///  stream id had generated, that mean is publishing
      ZegoLoggerService.logWarn(
        'local user stream id($targetStreamID) of $streamType is not empty',
        tag: 'uikit-stream',
        subTag: 'start publish stream',
      );
      return;
    }

    if (startingPublishingStreamTypes.contains(streamType)) {
      ZegoLoggerService.logWarn(
        'start publishing is already running, ignore duplicate request, '
        'streamType:$streamType',
        tag: 'uikit-stream',
        subTag: 'start publish stream',
      );
      return;
    }
    startingPublishingStreamTypes.add(streamType);

    final localTargetStreamViewID =
        getLocalStreamChannel(streamType).viewIDNotifier.value ?? -1;
    ZegoLoggerService.logInfo(
      'updateConfigBeforeStartPublishingStream, '
      'view id:$localTargetStreamViewID, ',
      tag: 'uikit-stream',
      subTag: 'start publish stream',
    );

    final audioConfig = channelAudioConfig[streamType];
    if (null != audioConfig) {
      ZegoLoggerService.logInfo(
        'setAudioConfig, '
        'audioConfig:$audioConfig, ',
        tag: 'uikit-stream',
        subTag: 'start publish stream',
      );

      await ZegoExpressEngine.instance.setAudioConfig(
        audioConfig,
        channel: streamType.channel,
      );
    }

    /// advance config
    switch (streamType) {
      case ZegoStreamType.main:
        await ZegoExpressEngine.instance
            .enableCamera(ZegoUIKitCore.shared.coreData.localUser.camera.value);
        await ZegoExpressEngine.instance.muteMicrophone(
          !ZegoUIKitCore.shared.coreData.localUser.microphone.value,
        );
        break;
      case ZegoStreamType.media:
        await ZegoExpressEngine.instance.setVideoSource(
          ZegoVideoSourceType.Player,
          instanceID:
              ZegoUIKitCore.shared.coreData.media.currentPlayer!.getIndex(),
          channel: streamType.channel,
        );
        await ZegoExpressEngine.instance.setAudioSource(
          ZegoAudioSourceType.MediaPlayer,
          channel: streamType.channel,
        );

        await ZegoExpressEngine.instance.setVideoConfig(
          ZegoUIKitCore.shared.coreData.media.getPreferVideoConfig(),
          channel: streamType.channel,
        );
        break;
      case ZegoStreamType.screenSharing:
        await ZegoExpressEngine.instance.setVideoSource(
          ZegoVideoSourceType.ScreenCapture,
          instanceID:
              ZegoUIKitCore.shared.coreData.screenCaptureSource!.getIndex(),
          channel: streamType.channel,
        );
        await ZegoExpressEngine.instance.setAudioSource(
          ZegoAudioSourceType.ScreenCapture,
          channel: streamType.channel,
        );

        await ZegoExpressEngine.instance.setVideoConfig(
          ZegoVideoConfig.preset(ZegoVideoConfigPreset.Preset540P),
          channel: streamType.channel,
        );
        break;
      case ZegoStreamType.mix:
        await ZegoExpressEngine.instance.setVideoConfig(
          ZegoVideoConfig.preset(ZegoVideoConfigPreset.Preset540P),
          channel: streamType.channel,
        );
        break;
    }

    /// generate stream id
    getLocalStreamChannel(streamType)
      ..streamID = generateStreamID(
        ZegoUIKitCore.shared.coreData.localUser.id,
        ZegoUIKitCore.shared.coreData.room.id,
        streamType,
      )
      ..streamTimestamp =
          ZegoUIKitCore.shared.coreData.networkDateTime_.millisecondsSinceEpoch;
    streamDic[getLocalStreamChannel(streamType).streamID] =
        ZegoUIKitCoreDataStreamData(
      userID: ZegoUIKitCore.shared.coreData.localUser.id,
      publisherState: ZegoPublisherState.NoPublish,
    );

    ZegoLoggerService.logInfo(
      'stream dict add $streamType ${getLocalStreamChannel(streamType).streamID} for ${ZegoUIKitCore.shared.coreData.localUser.id}, '
      'now stream dict:$streamDic',
      tag: 'uikit-stream',
      subTag: 'start publish stream',
    );

    ZegoLoggerService.logInfo(
      'start publish, '
      '${getLocalStreamChannel(streamType).streamID}, '
      'network state:${ZegoUIKit().getNetworkState()}, ',
      tag: 'uikit-stream',
      subTag: 'start publish stream',
    );

    if (Platform.isIOS) {
      // The preview canvas may have been returned before Flutter has mounted
      // its UiKitView. Re-emit the same widget so the existing platform-view
      // instance gets a chance to complete its ID callback. Do not clear or
      // recreate it here: doing so can leave two native views pending and
      // drop both callbacks on iOS.
      final localStreamChannel = getLocalStreamChannel(streamType);
      if (localStreamChannel.viewIDNotifier.value == -1 &&
          localStreamChannel.viewNotifier.value != null) {
        ZegoLoggerService.logInfo(
          'force update view to get view id before start publishing, '
          'streamType:$streamType, ',
          tag: 'uikit-stream',
          subTag: 'start publish stream',
        );
        notifyStreamListControl(streamType);
      }
    }

    ZegoLoggerService.logInfo(
      'call express startPublishingStream, for trace enableCustomVideoRender, '
      'isEnableCustomVideoRender:${ZegoUIKitCore.shared.coreData.isEnableCustomVideoRender}',
      tag: 'uikit-stream',
      subTag: 'start publish stream',
    );
    try {
      await ZegoExpressEngine.instance
          .startPublishingStream(
        getLocalStreamID(streamType),
        channel: streamType.channel,
      )
          .then((_) {
        isPublishingStream = true;
        ZegoLoggerService.logInfo(
          'publisher start API completed, '
          'streamID:${getLocalStreamID(streamType)}, '
          'roomID:${ZegoUIKitCore.shared.coreData.room.id}, '
          'microphone:${ZegoUIKitCore.shared.coreData.localUser.microphone.value}, '
          'capturedAudioFirstFrame:${ZegoUIKitCore.shared.coreData.localUser.mainChannel.isCapturedAudioFirstFrameNotifier.value}',
          tag: 'uikit-stream',
          subTag: 'start publish stream',
        );
      });
    } finally {
      startingPublishingStreamTypes.remove(streamType);
    }

    notifyStreamListControl(streamType);
  }

  Future<void> onViewCreatedByStartPublishingStream(
    ZegoStreamType streamType,
  ) async {
    final localTargetStreamViewID =
        getLocalStreamChannel(streamType).viewIDNotifier.value ?? -1;
    ZegoLoggerService.logInfo(
      'onViewCreatedByStartPublishingStream, '
      'view id:$localTargetStreamViewID, ',
      tag: 'uikit-stream',
      subTag: 'start publish stream',
    );

    /// advance config
    switch (streamType) {
      case ZegoStreamType.main:
        assert(localTargetStreamViewID != -1);
        final canvas = ZegoCanvas(
          localTargetStreamViewID,
          viewMode: useVideoViewAspectFill
              ? ZegoViewMode.AspectFill
              : ZegoViewMode.AspectFit,
        );
        ZegoLoggerService.logInfo(
          'call express startPreview, for trace enableCustomVideoRender, '
          'isEnableCustomVideoRender:${ZegoUIKitCore.shared.coreData.isEnableCustomVideoRender}',
          tag: 'uikit-stream',
          subTag: 'start publish stream',
        );
        await _startPreviewOnView(canvas.view);
        break;
      case ZegoStreamType.media:
        final canvas = ZegoCanvas(
          localTargetStreamViewID,
          viewMode: ZegoViewMode.AspectFit,
        );
        ZegoUIKitCore.shared.coreData.media.currentPlayer!
            .setPlayerCanvas(canvas);
        break;
      case ZegoStreamType.screenSharing:
        break;
      case ZegoStreamType.mix:
        break;
    }
  }

  Future<void> stopPublishingStream({
    required ZegoStreamType streamType,
  }) async {
    final targetStreamID = getLocalStreamID(streamType);
    ZegoLoggerService.logInfo(
      'stop $streamType $targetStreamID}, '
      'network state:${ZegoUIKit().getNetworkState()}, ',
      tag: 'uikit-stream',
      subTag: 'stop publish stream',
    );

    if (targetStreamID.isEmpty) {
      ZegoLoggerService.logInfo(
        'stream id is empty',
        tag: 'uikit-stream',
        subTag: 'stop publish stream',
      );

      return;
    }

    if (canvasViewCreateQueue.currentTaskKey == targetStreamID) {
      ZegoLoggerService.logInfo(
        'stopped canvas view queue',
        tag: 'uikit-stream',
        subTag: 'stop publish stream',
      );

      canvasViewCreateQueue.completeCurrentTask();
    }

    streamDic.remove(targetStreamID);
    ZegoLoggerService.logInfo(
      'stream dict remove $targetStreamID, now stream dict:$streamDic',
      tag: 'uikit-stream',
      subTag: 'stop publish stream',
    );

    getLocalStreamChannel(streamType)
      ..streamID = ''
      ..viewCreatingNotifier.value = false
      ..streamTimestamp = 0;

    ZegoUIKitCore.shared.coreData.localUser
        .destroyTextureRenderer(streamType: streamType);

    switch (streamType) {
      case ZegoStreamType.main:
        await ZegoExpressEngine.instance.stopPreview().then((_) {
          isPreviewing = false;
        });
        break;
      case ZegoStreamType.media:
        await ZegoExpressEngine.instance.setVideoSource(
          ZegoVideoSourceType.None,
          channel: streamType.channel,
        );
        await ZegoExpressEngine.instance.setAudioSource(
          ZegoAudioSourceType.Default,
          channel: streamType.channel,
        );
        break;
      case ZegoStreamType.screenSharing:
        await ZegoExpressEngine.instance.setVideoSource(
          ZegoVideoSourceType.None,
          channel: streamType.channel,
        );
        await ZegoExpressEngine.instance.setAudioSource(
          ZegoAudioSourceType.Default,
          channel: streamType.channel,
        );
        break;
      default:
        break;
    }

    await ZegoExpressEngine.instance
        .stopPublishingStream(channel: streamType.channel)
        .then((value) {
      isPublishingStream = false;

      audioVideoListStreamCtrl?.add(getAudioVideoList());
      ZegoUIKitCore.shared.coreData.screenSharingListStreamCtrl
          ?.add(getAudioVideoList(streamType: ZegoStreamType.screenSharing));
      ZegoUIKitCore.shared.coreData.media.mediaListStreamCtrl
          ?.add(getAudioVideoList(streamType: ZegoStreamType.media));
    });
  }

  Future<void> startPublishOrNot() async {
    if (ZegoUIKitCore.shared.coreData.room.id.isEmpty) {
      ZegoLoggerService.logWarn(
        'room id is empty',
        tag: 'uikit-stream',
        subTag: 'publish stream',
      );
      return;
    }

    if (ZegoUIKitCore.shared.coreData.localUser.camera.value ||
        ZegoUIKitCore.shared.coreData.localUser.cameraMuteMode.value ||
        ZegoUIKitCore.shared.coreData.localUser.microphone.value ||
        ZegoUIKitCore.shared.coreData.localUser.microphoneMuteMode.value) {
      /// start publish first
      await startPublishingStream(
        streamType: ZegoStreamType.main,
      );

      /// create canvas if need
      if (ZegoUIKitCore.shared.coreData.localUser.camera.value ||
          ZegoUIKitCore.shared.coreData.localUser.cameraMuteMode.value) {
        await createLocalUserVideoViewQueue(
          streamType: ZegoStreamType.main,
          onViewCreated: onViewCreatedByStartPublishingStream,
        );
      }
    } else {
      if (ZegoUIKitCore
          .shared.coreData.localUser.mainChannel.streamID.isNotEmpty) {
        stopPublishingStream(
          streamType: ZegoStreamType.main,
        );
      }
    }
  }

  Future<void> syncRoomStream() async {
    final currentRoomID = ZegoUIKitCore.shared.coreData.room.id;
    if (currentRoomID.isEmpty) {
      ZegoLoggerService.logInfo(
        'not in room',
        tag: 'uikit-stream',
        subTag: 'syncRoomStream',
      );

      return;
    }

    await ZegoExpressEngine.instance
        .getRoomStreamList(
      ZegoUIKitCore.shared.coreData.room.id,
      ZegoRoomStreamListType.Play,
    )
        .then((streamList) {
      ZegoLoggerService.logInfo(
        'publishStreamList list, ${streamList.publishStreamList.map((e) => e.toStringX())},  '
        'playStreamList list, ${streamList.playStreamList.map((e) => e.toStringX())}',
        tag: 'uikit-stream',
        subTag: 'syncRoomStream',
      );

      ZegoLoggerService.logInfo(
        'put play stream list to onRoomStreamUpdate',
        tag: 'uikit-stream',
        subTag: 'syncRoomStream',
      );
      ZegoUIKitCore.shared.eventHandler.onRoomStreamUpdate(
        currentRoomID,
        ZegoUpdateType.Add,
        streamList.playStreamList,
        {},
      );
    });
  }

  Future<Widget?> createCanvasViewByExpressWithCompleter(
    FutureOr<void> Function(int viewID) onViewCreated, {
    Key? key,
    bool Function()? isQueueTaskCurrent,
  }) async {
    Key? canvasViewKey;
    if (Platform.isIOS && isEnablePlatformView) {
      // During PiP/layout transitions, one canvas can briefly appear in multiple
      // subtrees. Forwarding a GlobalKey can make Flutter detach the native view
      // due to a duplicate key; use a ValueKey to preserve canvas identity
      // without reusing a GlobalKey across subtrees.
      if (key != null) {
        canvasViewKey = ValueKey<int>(identityHashCode(key));
      }
    }

    ZegoLoggerService.logInfo(
      'with express with key:$canvasViewKey(${canvasViewKey.toString()})',
      tag: 'uikit-stream',
      subTag: 'create canvas view',
    );

    return await ZegoExpressEngine.instance.createCanvasView(
      (int viewID) async {
        ZegoLoggerService.logInfo(
          'createCanvasView onViewCreated, '
          'viewID:$viewID, ',
          tag: 'uikit-stream',
          subTag: 'create canvas view',
        );

        if (isCanvasViewCreateByQueue) {
          // Wait for the current Flutter frame before binding the UIKit ViewID,
          // and release the next creation only after that asynchronous binding
          // completes. A completed frame does not mean the native UIView is in a window.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            unawaited(
              completeCanvasViewCreationCallback(
                () => onViewCreated.call(viewID),
                onCompleted: () => completeCanvasQueueTaskIfCurrent(
                  queue: canvasViewCreateQueue,
                  isCurrent: () => isQueueTaskCurrent?.call() ?? true,
                ),
              ),
            );
          });
        } else {
          await onViewCreated.call(viewID);
        }
      },
      key: canvasViewKey,
    );
  }

  Future<void> createLocalUserVideoViewQueue({
    required ZegoStreamType streamType,
    required FutureOr<void> Function(ZegoStreamType) onViewCreated,
  }) async {
    final localStreamChannel = getLocalStreamChannel(streamType);
    final queueTaskKey = generateStreamID(
      ZegoUIKitCore.shared.coreData.localUser.id,
      ZegoUIKitCore.shared.coreData.room.id,
      streamType,
    );
    if (localStreamChannel.viewCreatingNotifier.value) {
      ZegoLoggerService.logInfo(
        'view is creating, ignore',
        tag: 'uikit-stream',
        subTag: 'create local user video view',
      );

      return;
    }

    if (isCanvasViewCreateByQueue) {
      if (localStreamChannel.viewIDNotifier.value != -1 &&
          localStreamChannel.viewNotifier.value != null) {
        await createLocalUserVideoView(
          streamType: streamType,
          onViewCreated: onViewCreated,
          queueTaskKey: queueTaskKey,
        );
      } else {
        ZegoLoggerService.logInfo(
          'add to queue',
          tag: 'uikit-stream',
          subTag: 'create local user video view',
        );

        if (streamType == ZegoStreamType.main) {
          // Keep the exact key used below; joining can change the room ID
          // before this queued task is released or stopPreview is called.
          _localMainCanvasQueueTaskTracker.track(queueTaskKey);
        }

        canvasViewCreateQueue.addTask(
          uniqueKey: queueTaskKey,
          task: () async {
            await createLocalUserVideoView(
              streamType: streamType,
              onViewCreated: onViewCreated,
              queueTaskKey: queueTaskKey,
            );
          },
        );
      }
    } else {
      await createLocalUserVideoView(
        streamType: streamType,
        onViewCreated: onViewCreated,
        queueTaskKey: queueTaskKey,
      );
    }
  }

  Future<void> createLocalUserVideoView({
    required ZegoStreamType streamType,
    required FutureOr<void> Function(ZegoStreamType) onViewCreated,
    String? queueTaskKey,
  }) async {
    final localStreamChannel = getLocalStreamChannel(streamType);
    ZegoLoggerService.logInfo(
      'current streamChannel, '
      'streamType:$streamType, '
      'view id:${localStreamChannel.viewIDNotifier.value},'
      'view:${localStreamChannel.viewNotifier}, '
      'view hashCode:${localStreamChannel.viewNotifier.hashCode}',
      tag: 'uikit-stream',
      subTag: 'create local user video view',
    );

    if (localStreamChannel.viewIDNotifier.value != -1 &&
        localStreamChannel.viewNotifier.value != null) {
      final callbackGeneration = localStreamChannel.viewCreationGeneration;
      final callbackViewID = localStreamChannel.viewIDNotifier.value;
      final expectedQueueTaskKey = queueTaskKey;
      ZegoLoggerService.logInfo(
        'user view had created, directly call callback, '
        'view id:${localStreamChannel.viewIDNotifier.value},'
        'view:${localStreamChannel.viewNotifier}',
        tag: 'uikit-stream',
        subTag: 'create local user video view',
      );

      if (isCanvasViewCreateByQueue &&
          expectedQueueTaskKey != null &&
          canvasViewCreateQueue.currentTaskKey == expectedQueueTaskKey) {
        await completeCanvasViewCreationCallback(
          () => onViewCreated(streamType),
          onCompleted: () => completeCanvasQueueTaskIfCurrent(
            queue: canvasViewCreateQueue,
            isCurrent: () =>
                isLocalCanvasQueueTaskCurrent(
                  queue: canvasViewCreateQueue,
                  queuedTaskKey: expectedQueueTaskKey,
                  expectedGeneration: callbackGeneration,
                  currentGeneration: localStreamChannel.viewCreationGeneration,
                ) &&
                localStreamChannel.viewIDNotifier.value == callbackViewID,
          ),
        );
      } else {
        await onViewCreated(streamType);
      }
    } else {
      // Increment the generation for each local canvas recreation. A delayed
      // callback or Widget result from an older UiKitView must not overwrite
      // the state of the current canvas.
      final creationGeneration = ++localStreamChannel.viewCreationGeneration;
      localStreamChannel.viewCreatingNotifier.value = true;

      await createCanvasViewByExpressWithCompleter(
        (viewID) async {
          if (creationGeneration != localStreamChannel.viewCreationGeneration) {
            ZegoLoggerService.logWarn(
              'ignore stale local canvas callback, '
              'streamType:$streamType, viewID:$viewID, '
              'generation:$creationGeneration, '
              'currentGeneration:${localStreamChannel.viewCreationGeneration}',
              tag: 'uikit-stream',
              subTag: 'create local user video view',
            );
            return;
          }

          ZegoLoggerService.logInfo(
            'view id done, '
            'streamType:$streamType, '
            'viewID:$viewID',
            tag: 'uikit-stream',
            subTag: 'create local user video view',
          );

          localStreamChannel.viewCreatingNotifier.value = false;

          localStreamChannel.viewIDNotifier.value = viewID;

          await onViewCreated(streamType);
        },
        key: streamType == ZegoStreamType.main
            ? localStreamChannel.globalMainStreamChannelKeyNotifier.value
            : localStreamChannel.globalAuxStreamChannelKeyNotifier.value,
        isQueueTaskCurrent: () =>
            queueTaskKey != null &&
            isLocalCanvasQueueTaskCurrent(
              queue: canvasViewCreateQueue,
              queuedTaskKey: queueTaskKey,
              expectedGeneration: creationGeneration,
              currentGeneration: localStreamChannel.viewCreationGeneration,
            ),
      ).then((widget) {
        if (creationGeneration != localStreamChannel.viewCreationGeneration) {
          ZegoLoggerService.logWarn(
            'ignore stale local canvas widget, '
            'streamType:$streamType, generation:$creationGeneration, '
            'currentGeneration:${localStreamChannel.viewCreationGeneration}',
            tag: 'uikit-stream',
            subTag: 'create local user video view',
          );
          return;
        }

        ZegoLoggerService.logInfo(
          'widget done, '
          'streamType:$streamType, '
          'widget:$widget ${widget.hashCode}',
          tag: 'uikit-stream',
          subTag: 'create local user video view',
        );

        localStreamChannel.viewNotifier.value = widget;

        notifyStreamListControl(streamType);
      });
    }
  }

  Future<bool> mutePlayStreamAudioVideo(
    String userID,
    bool mute, {
    bool forAudio = true,
    bool forVideo = true,
  }) async {
    ZegoLoggerService.logInfo(
      'userID: $userID, mute: $mute, '
      'for audio:$forAudio, for video:$forVideo',
      tag: 'uikit-stream',
      subTag: 'mute play stream audio video',
    );

    final targetUserIndex = ZegoUIKitCore.shared.coreData.remoteUsersList
        .indexWhere((user) => userID == user.id);
    if (-1 == targetUserIndex) {
      ZegoLoggerService.logError(
        "can't find $userID",
        tag: 'uikit-stream',
        subTag: 'mute play stream audio video',
      );
      return false;
    }

    final targetUser =
        ZegoUIKitCore.shared.coreData.remoteUsersList[targetUserIndex];
    if (targetUser.mainChannel.streamID.isEmpty) {
      ZegoLoggerService.logError(
        "can't find $userID's stream",
        tag: 'uikit-stream',
        subTag: 'mute play stream audio video',
      );
      return false;
    }

    if (forAudio) {
      targetUser.microphoneMuteMode.value = mute;
      await ZegoExpressEngine.instance.mutePlayStreamAudio(
        targetUser.mainChannel.streamID,
        mute,
      );
    }

    if (forVideo) {
      targetUser.cameraMuteMode.value = mute;
      await ZegoExpressEngine.instance.mutePlayStreamVideo(
        targetUser.mainChannel.streamID,
        mute,
      );
    }

    return true;
  }

  Future<void> muteAllPlayStreamAudioVideo(bool isMuted) async {
    ZegoLoggerService.logInfo(
      'muted: $isMuted, streamDic:$streamDic',
      tag: 'uikit-stream',
      subTag: 'mute all play stream audio video',
    );

    isAllPlayStreamAudioVideoMuted = isMuted;
    await ZegoExpressEngine.instance
        .muteAllPlayStreamVideo(isAllPlayStreamAudioVideoMuted);
    await ZegoExpressEngine.instance
        .muteAllPlayStreamAudio(isAllPlayStreamAudioVideoMuted);

    streamDic.forEach((streamID, streamInfo) async {
      if (isMuted) {
        if (ZegoPlayerState.Playing == streamInfo.playerState) {
          await stopPlayingStream(streamID, removeDic: false);
        } else {
          ZegoLoggerService.logInfo(
            'stream id($streamID) not playing(${streamInfo.playerState}) now, waiting player state update',
            tag: 'uikit-stream',
            subTag: 'mute all play stream audio video',
          );
        }
      } else {
        if (ZegoUIKitCore.shared.coreData.localUser.id != streamInfo.userID &&
            streamInfo.playerState == ZegoPlayerState.NoPlay) {
          final previousStreamExtraInfo =
              ZegoUIKitCore.shared.coreData.streamExtraInfo[streamID] ?? '';
          final targetUserIndex = ZegoUIKitCore.shared.coreData.remoteUsersList
              .indexWhere((user) => streamInfo.userID == user.id);
          ZegoLoggerService.logInfo(
            'test, attempt to restore previous stream additional information, '
            'previousStreamExtraInfo:$previousStreamExtraInfo, '
            'targetUserIndex:$targetUserIndex',
            tag: 'uikit-stream',
            subTag: 'mute all play stream audio video',
          );
          if (previousStreamExtraInfo.isNotEmpty) {
            /// 先加载之前的流附加信息
            ZegoUIKitCore.shared.eventHandler.parseStreamExtraInfo(
              streamID: streamID,
              extraInfo: previousStreamExtraInfo,
            );
          }

          await startPlayingStreamQueue(streamID, streamInfo.userID);
        }
      }
    });
  }

  Future<void> muteAllPlayStreamAudio(bool isMuted) async {
    ZegoLoggerService.logInfo(
      'muted: $isMuted, streamDic:$streamDic',
      tag: 'uikit-stream',
      subTag: 'mute all play stream audio',
    );

    isAllPlayStreamAudioMuted = isMuted;
    await ZegoExpressEngine.instance
        .muteAllPlayStreamAudio(isAllPlayStreamAudioMuted);
  }

  Future<void> startPlayingStreamQueue(
    String streamID,
    String streamUserID,
  ) async {
    final targetUserIndex = ZegoUIKitCore.shared.coreData.remoteUsersList
        .indexWhere((user) => streamUserID == user.id);
    if (-1 == targetUserIndex) {
      ZegoLoggerService.logInfo(
        'targetUserIndex is invalid, '
        'stream id: $streamID, '
        'user id:$streamUserID, ',
        tag: 'uikit-stream',
        subTag: 'start play stream',
      );

      return;
    }

    final targetUser =
        ZegoUIKitCore.shared.coreData.remoteUsersList[targetUserIndex];
    final streamType = getStreamTypeByID(streamID);

    final targetUserStreamChannel =
        getUserStreamChannel(targetUser, streamType);

    ZegoLoggerService.logInfo(
      'start pull stream request, streamID:$streamID, userID:$streamUserID, '
      '${_describeCanvasState(targetUser, streamType)}, '
      'platformView:$isEnablePlatformView, '
      'pipUnderIOS:${ZegoUIKitCore.shared.playingStreamInPIPUnderIOS}, '
      'customRender:$isEnableCustomVideoRender',
      tag: 'uikit-stream',
      subTag: 'start play stream',
    );

    if (targetUserStreamChannel.viewCreatingNotifier.value) {
      ZegoLoggerService.logInfo(
        'stream id: $streamID, user id:$streamUserID, '
        'view is creating, ignore, '
        'generation:${targetUserStreamChannel.viewCreationGeneration}, '
        'viewID:${targetUserStreamChannel.viewIDNotifier.value}, '
        'widgetHash:${targetUserStreamChannel.viewNotifier.value?.hashCode}',
        tag: 'uikit-stream',
        subTag: 'start play stream',
      );

      return;
    }

    if (isCanvasViewCreateByQueue) {
      if (targetUserStreamChannel.viewIDNotifier.value != -1 &&
          targetUserStreamChannel.viewNotifier.value != null) {
        await startPlayingStream(streamID, streamUserID);
      } else {
        ZegoLoggerService.logInfo(
          'stream id: $streamID, user id:$streamUserID, '
          'add to queue',
          tag: 'uikit-stream',
          subTag: 'start play stream',
        );

        ZegoLoggerService.logInfo(
          'start playback before canvas creation queue, streamID:$streamID',
          tag: 'uikit-stream',
          subTag: 'start play stream',
        );
        var requestGeneration = targetUserStreamChannel.viewCreationGeneration;
        final accepted = await startStreamPlaybackWithCanvasQueue(
          requests: _streamStartRequests,
          streamID: streamID,
          queue: canvasViewCreateQueue,
          onRequestReserved: () {
            requestGeneration =
                ++targetUserStreamChannel.viewCreationGeneration;
            targetUserStreamChannel.streamID = streamID;
            targetUserStreamChannel.viewCreatingNotifier.value = true;
          },
          isCanvasStateCurrent: () =>
              targetUserStreamChannel.viewCreationGeneration ==
                  requestGeneration &&
              targetUserStreamChannel.streamID == streamID &&
              streamDic.containsKey(streamID) &&
              ZegoUIKitCore.shared.coreData.remoteUsersList
                  .any((user) => identical(user, targetUser)),
          startPlayback: () => playStreamOnViewWillCreated(
            streamID: streamID,
          ),
          createCanvas: () => startPlayingStream(
            streamID,
            streamUserID,
            startPlayback: false,
          ),
          onRequestStale: () {
            if (targetUserStreamChannel.viewCreationGeneration ==
                requestGeneration) {
              targetUserStreamChannel.viewCreatingNotifier.value = false;
            }
          },
          onStaleTask: () {
            if (canvasViewCreateQueue.currentTaskKey == streamID) {
              canvasViewCreateQueue.completeCurrentTask();
            }
          },
          onError: (error, stackTrace) {
            if (targetUserStreamChannel.viewCreationGeneration ==
                requestGeneration) {
              targetUserStreamChannel.viewCreatingNotifier.value = false;
            }
            ZegoLoggerService.logError(
              'failed to start stream before canvas creation, '
              'streamID:$streamID, error:$error\n$stackTrace',
              tag: 'uikit-stream',
              subTag: 'start play stream',
            );
          },
        );
        if (!accepted) {
          ZegoLoggerService.logInfo(
            'stream start already pending, ignore duplicate request, '
            'streamID:$streamID',
            tag: 'uikit-stream',
            subTag: 'start play stream',
          );
        }
      }
    } else {
      await startPlayingStream(streamID, streamUserID);
    }
  }

  /// will change data variables
  Future<void> startPlayingStream(
    String streamID,
    String streamUserID, {
    bool startPlayback = true,
  }) async {
    ZegoLoggerService.logInfo(
      'stream id: $streamID, user id:$streamUserID',
      tag: 'uikit-stream',
      subTag: 'start play stream',
    );

    final targetUserIndex = ZegoUIKitCore.shared.coreData.remoteUsersList
        .indexWhere((user) => streamUserID == user.id);
    assert(-1 != targetUserIndex);
    final targetUser =
        ZegoUIKitCore.shared.coreData.remoteUsersList[targetUserIndex];
    final streamType = getStreamTypeByID(streamID);

    getUserStreamChannel(targetUser, streamType)
      ..streamID = streamID
      ..streamTimestamp =
          ZegoUIKitCore.shared.coreData.networkDateTime_.millisecondsSinceEpoch;

    final targetUserStreamChannel =
        getUserStreamChannel(targetUser, streamType);
    final creationGeneration = targetUserStreamChannel.viewCreationGeneration;
    ZegoLoggerService.logInfo(
      'current stream channel, '
      'stream id:$streamID, user id:$streamUserID, stream type:$streamType, '
      'view id:${targetUserStreamChannel.viewIDNotifier.value},'
      'view:${targetUserStreamChannel.viewNotifier}, '
      'view creating:${targetUserStreamChannel.viewCreatingNotifier.value}, '
      'generation:$creationGeneration, '
      'platformView:$isEnablePlatformView, '
      'pipUnderIOS:${ZegoUIKitCore.shared.playingStreamInPIPUnderIOS}, '
      'customRender:$isEnableCustomVideoRender',
      tag: 'uikit-stream',
      subTag: 'start play stream',
    );

    if (startPlayback) {
      await playStreamOnViewWillCreated(
        streamID: streamID,
      );
    } else {
      ZegoLoggerService.logInfo(
        'playback already started before canvas creation, streamID:$streamID',
        tag: 'uikit-stream',
        subTag: 'start play stream',
      );
    }

    if (targetUserStreamChannel.viewIDNotifier.value != -1 &&
        targetUserStreamChannel.viewNotifier.value != null) {
      final viewID =
          getUserStreamChannel(targetUser, streamType).viewIDNotifier.value ??
              -1;

      ZegoLoggerService.logInfo(
        'canvas view had created before, directly call callback, '
        'viewID:$viewID, '
        'generation:$creationGeneration, '
        'user id:$streamUserID, '
        'stream id:$streamID, ',
        tag: 'uikit-stream',
        subTag: 'start play stream',
      );

      if (isCanvasViewCreateByQueue) {
        completeCanvasQueueTaskIfCurrent(
          queue: canvasViewCreateQueue,
          isCurrent: () => isCanvasQueueTaskCurrent(
            queue: canvasViewCreateQueue,
            streamID: streamID,
            expectedGeneration: creationGeneration,
            currentGeneration: targetUserStreamChannel.viewCreationGeneration,
            channelStreamID: targetUserStreamChannel.streamID,
            currentUsers: ZegoUIKitCore.shared.coreData.remoteUsersList,
            targetUser: targetUser,
            isStreamRecordCurrent: streamDic[streamID]?.userID == streamUserID,
          ),
        );
      }

      await updatePlayStreamViewOnViewCreated(
        streamID: streamID,
        viewID: viewID,
        streamType: streamType,
        viewCreationGeneration: creationGeneration,
      );
    } else {
      getUserStreamChannel(targetUser, streamType).viewCreatingNotifier.value =
          true;

      ZegoLoggerService.logInfo(
        'begin canvas creation, streamID:$streamID, userID:$streamUserID, '
        'generation:$creationGeneration, '
        'oldViewID:${targetUserStreamChannel.viewIDNotifier.value}, '
        'pipUnderIOS:${ZegoUIKitCore.shared.playingStreamInPIPUnderIOS}, '
        'platformView:$isEnablePlatformView',
        tag: 'uikit-stream',
        subTag: 'start play stream',
      );

      var createdViewID = -1;
      await createCanvasViewByExpressWithCompleter(
        (viewID) async {
          if (creationGeneration !=
                  targetUserStreamChannel.viewCreationGeneration ||
              targetUserStreamChannel.streamID != streamID ||
              !streamDic.containsKey(streamID) ||
              !ZegoUIKitCore.shared.coreData.remoteUsersList
                  .any((user) => identical(user, targetUser))) {
            ZegoLoggerService.logWarn(
              'ignore stale remote canvas callback, '
              'streamID:$streamID, viewID:$viewID, '
              'generation:$creationGeneration, '
              'currentGeneration:'
              '${targetUserStreamChannel.viewCreationGeneration}, '
              'channelStreamID:${targetUserStreamChannel.streamID}, '
              'streamExists:${streamDic.containsKey(streamID)}, '
              'userStillPresent:${ZegoUIKitCore.shared.coreData.remoteUsersList.any((user) => identical(user, targetUser))}',
              tag: 'uikit-stream',
              subTag: 'start play stream',
            );
            return;
          }

          ZegoLoggerService.logInfo(
            'canvas view id done '
            'viewID:$viewID, '
            'generation:$creationGeneration, '
            'currentGeneration:${targetUserStreamChannel.viewCreationGeneration}, '
            'user id:$streamUserID, '
            'stream id:$streamID, ',
            tag: 'uikit-stream',
            subTag: 'start play stream',
          );

          createdViewID = viewID;
          getUserStreamChannel(targetUser, streamType)
              .viewCreatingNotifier
              .value = false;
          getUserStreamChannel(targetUser, streamType).viewIDNotifier.value =
              viewID;

          await updatePlayStreamViewOnViewCreated(
            streamID: streamID,
            viewID: viewID,
            streamType: streamType,
            viewCreationGeneration: creationGeneration,
          );
        },
        key: streamType == ZegoStreamType.main
            ? targetUserStreamChannel.globalMainStreamChannelKeyNotifier.value
            : targetUserStreamChannel.globalAuxStreamChannelKeyNotifier.value,
        isQueueTaskCurrent: () =>
            canvasViewCreateQueue.currentTaskKey == streamID &&
            targetUserStreamChannel.viewCreationGeneration ==
                creationGeneration &&
            targetUserStreamChannel.streamID == streamID &&
            streamDic.containsKey(streamID) &&
            ZegoUIKitCore.shared.coreData.remoteUsersList
                .any((user) => identical(user, targetUser)),
      ).then((widget) {
        ZegoLoggerService.logInfo(
          'widget done, '
          'widget:$widget ${widget.hashCode}, '
          'generation:$creationGeneration, '
          'currentGeneration:${targetUserStreamChannel.viewCreationGeneration}, '
          'user id:$streamUserID, '
          'stream id:$streamID, ',
          tag: 'uikit-stream',
          subTag: 'start play stream',
        );

        final streamChannel = getUserStreamChannel(targetUser, streamType);
        if (streamChannel.viewCreationGeneration == creationGeneration &&
            streamChannel.streamID == streamID &&
            streamDic.containsKey(streamID) &&
            ZegoUIKitCore.shared.coreData.remoteUsersList
                .any((user) => identical(user, targetUser)) &&
            streamChannel.viewIDNotifier.value == createdViewID) {
          streamChannel.viewNotifier.value = widget;
        } else {
          ZegoLoggerService.logInfo(
            'ignore stale canvas widget, '
            'created viewID:$createdViewID, '
            'current viewID:${streamChannel.viewIDNotifier.value}, '
            'generation:$creationGeneration, '
            'currentGeneration:${streamChannel.viewCreationGeneration}, '
            'user id:$streamUserID, stream id:$streamID',
            tag: 'uikit-stream',
            subTag: 'start play stream',
          );
        }

        notifyStreamListControl(streamType);
      });
    }
  }

  Future<void> startPlayingStreamByExpress({
    required String streamID,
    ZegoPlayerConfig? config,
    PlayerStateUpdateCallback? onPlayerStateUpdated,
  }) async {
    bool startPlayingStreamInIOSPIP = false;
    if (Platform.isIOS) {
      startPlayingStreamInIOSPIP =
          ZegoUIKitCore.shared.playingStreamInPIPUnderIOS;
    }

    ZegoLoggerService.logInfo(
      'streamID:$streamID, '
      'startPlayingStreamInIOSPIP:$startPlayingStreamInIOSPIP, '
      '${_describeStreamCanvasState(streamID)}, '
      'platformView:$isEnablePlatformView, '
      'customRender:$isEnableCustomVideoRender',
      tag: 'uikit-stream',
      subTag: 'start play stream by express',
    );

    if (null != onPlayerStateUpdated) {
      if (playerStateUpdateCallbackList.containsKey(streamID)) {
        playerStateUpdateCallbackList[streamID]!.add(onPlayerStateUpdated);
      } else {
        playerStateUpdateCallbackList[streamID] = [onPlayerStateUpdated];
      }
    }

    ZegoLoggerService.logInfo(
      'call express startPlayingStream, for trace enableCustomVideoRender, '
      'isEnableCustomVideoRender:${ZegoUIKitCore.shared.coreData.isEnableCustomVideoRender}',
      tag: 'uikit-stream',
      subTag: 'start play stream',
    );
    if (startPlayingStreamInIOSPIP) {
      Map<String, dynamic>? cdnConfigMap;
      if (config?.cdnConfig != null) {
        cdnConfigMap = {
          'url': config!.cdnConfig!.url,
          if (config.cdnConfig!.authParam != null)
            'authParam': config.cdnConfig!.authParam,
          if (config.cdnConfig!.protocol != null)
            'protocol': config.cdnConfig!.protocol,
          if (config.cdnConfig!.quicVersion != null)
            'quicVersion': config.cdnConfig!.quicVersion,
          if (config.cdnConfig!.httpdns != null)
            'httpdns': config.cdnConfig!.httpdns,
          if (config.cdnConfig!.quicConnectMode != null)
            'quicConnectMode': config.cdnConfig!.quicConnectMode,
          if (config.cdnConfig!.customParams != null)
            'customParams': config.cdnConfig!.customParams,
        };
      }

      await ZegoUIKitPluginPlatform.instance
          .startPlayingStreamInPIP(
        streamID,
        resourceMode: config?.resourceMode.index,
        roomID: config?.roomID,
        cdnConfig: cdnConfigMap,
        videoCodecID: config?.videoCodecID?.index,
      )
          .then((_) {
        isPlayingStream = true;

        ZegoLoggerService.logInfo(
          'finish play stream in ios with pip, '
          'stream id: $streamID, ${_describeStreamCanvasState(streamID)}',
          tag: 'uikit-stream',
          subTag: 'start play stream',
        );
      }, onError: (Object error, StackTrace stackTrace) {
        ZegoLoggerService.logError(
          'startPlayingStreamInPIP failed, streamID:$streamID, '
          '${_describeStreamCanvasState(streamID)}, error:$error\n$stackTrace',
          tag: 'uikit-stream',
          subTag: 'start play stream',
        );
        Error.throwWithStackTrace(error, stackTrace);
      });
    } else {
      await ZegoExpressEngine.instance
          .startPlayingStream(
        streamID,
        canvas: null,
        config: config,
      )
          .then((value) {
        isPlayingStream = true;

        ZegoLoggerService.logInfo(
          'finish play, '
          'stream id: $streamID, ${_describeStreamCanvasState(streamID)}',
          tag: 'uikit-stream',
          subTag: 'start play stream',
        );
      }, onError: (Object error, StackTrace stackTrace) {
        ZegoLoggerService.logError(
          'Express startPlayingStream failed, streamID:$streamID, '
          '${_describeStreamCanvasState(streamID)}, error:$error\n$stackTrace',
          tag: 'uikit-stream',
          subTag: 'start play stream',
        );
        Error.throwWithStackTrace(error, stackTrace);
      });
    }
  }

  Future<void> stopPlayingStreamByExpress(String streamID) async {
    bool stopPlayingStreamInIOSPIP = false;
    if (Platform.isIOS) {
      stopPlayingStreamInIOSPIP =
          ZegoUIKitCore.shared.playingStreamInPIPUnderIOS;
    }

    ZegoLoggerService.logInfo(
      'streamID:$streamID, '
      'stopPlayingStreamInIOSPIP:$stopPlayingStreamInIOSPIP, '
      '${_describeStreamCanvasState(streamID)}, '
      'platformView:$isEnablePlatformView, '
      'customRender:$isEnableCustomVideoRender',
      tag: 'uikit-stream',
      subTag: 'stop play stream by express',
    );

    if (stopPlayingStreamInIOSPIP) {
      ZegoUIKitPluginPlatform.instance.stopPlayingStreamInPIP(streamID).then(
          (_) {
        ZegoLoggerService.logInfo(
          'stop play done in ios with pip, '
          'stream id: $streamID, ${_describeStreamCanvasState(streamID)}',
          tag: 'uikit-stream',
          subTag: 'stop play stream',
        );
      }, onError: (Object error, StackTrace stackTrace) {
        ZegoLoggerService.logError(
          'stopPlayingStreamInPIP failed, streamID:$streamID, '
          '${_describeStreamCanvasState(streamID)}, error:$error\n$stackTrace',
          tag: 'uikit-stream',
          subTag: 'stop play stream',
        );
        Error.throwWithStackTrace(error, stackTrace);
      });
    } else {
      await ZegoExpressEngine.instance.stopPlayingStream(streamID).then((_) {
        ZegoLoggerService.logInfo(
          'stop play done, '
          'stream id: $streamID, ${_describeStreamCanvasState(streamID)}',
          tag: 'uikit-stream',
          subTag: 'stop play stream',
        );
      }, onError: (Object error, StackTrace stackTrace) {
        ZegoLoggerService.logError(
          'Express stopPlayingStream failed, streamID:$streamID, '
          '${_describeStreamCanvasState(streamID)}, error:$error\n$stackTrace',
          tag: 'uikit-stream',
          subTag: 'stop play stream',
        );
        Error.throwWithStackTrace(error, stackTrace);
      });
    }
  }

  Future<void> updatePlayStreamViewOnViewCreated({
    required String streamID,
    required int viewID,
    ZegoStreamType? streamType,
    ZegoCanvas? canvas,
    int? viewCreationGeneration,
  }) async {
    final viewMode = ZegoStreamType.main == streamType
        ? (useVideoViewAspectFill
            ? ZegoViewMode.AspectFill
            : ZegoViewMode.AspectFit)

        /// screen share/media default AspectFit
        : ZegoViewMode.AspectFit;
    final canvas = ZegoCanvas(
      viewID,
      viewMode: viewMode,
    );

    bool startPlayingStreamInIOSPIP = false;
    if (Platform.isIOS) {
      startPlayingStreamInIOSPIP =
          ZegoUIKitCore.shared.playingStreamInPIPUnderIOS;

      ZegoLoggerService.logInfo(
        'isPlayingStreamInIOSPIP:$startPlayingStreamInIOSPIP, ',
        tag: 'uikit-stream',
        subTag: 'start play stream',
      );
    }

    ZegoLoggerService.logInfo(
      'ready start, '
      'stream id: $streamID, '
      'view id:$viewID, stream type:$streamType, '
      'generation:$viewCreationGeneration, '
      'platformView:$isEnablePlatformView, '
      'customRender:$isEnableCustomVideoRender, '
      '${_describeStreamCanvasState(streamID)}, '
      'view mode:$viewMode(${viewMode.index}), ',
      tag: 'uikit-stream',
      subTag: 'start play stream',
    );

    if (startPlayingStreamInIOSPIP) {
      ZegoUIKitPluginPlatform.instance
          .updatePlayingStreamViewInPIP(viewID, streamID, viewMode.index)
          .then((_) {
        ZegoLoggerService.logInfo(
          'finish update stream view/canvas in ios with pip, '
          'stream id:$streamID, '
          'view id:$viewID, ${_describeStreamCanvasState(streamID)}',
          tag: 'uikit-stream',
          subTag: 'start play stream',
        );
      }, onError: (Object error, StackTrace stackTrace) {
        ZegoLoggerService.logError(
          'updatePlayingStreamViewInPIP failed, streamID:$streamID, '
          'viewID:$viewID, generation:$viewCreationGeneration, '
          '${_describeStreamCanvasState(streamID)}, error:$error\n$stackTrace',
          tag: 'uikit-stream',
          subTag: 'start play stream',
        );
        Error.throwWithStackTrace(error, stackTrace);
      });
    } else {
      try {
        await ZegoExpressEngine.instance.updatePlayingCanvas(streamID, canvas);
        ZegoLoggerService.logInfo(
          'finish update stream view/canvas, '
          'stream id: $streamID, '
          'canvas:$canvas, ',
          tag: 'uikit-stream',
          subTag: 'start play stream',
        );
      } on PlatformException catch (error) {
        ZegoLoggerService.logError(
          'updatePlayingCanvas failed, '
          'stream id:$streamID, viewID:$viewID, stream type:$streamType, '
          'error code:${error.code}, error message:${error.message}, '
          'error details:${error.details}',
          tag: 'uikit-stream',
          subTag: 'update playing canvas',
        );

        if (error.code != _updatePlayingCanvasNoTextureRenderer) {
          rethrow;
        }

        await _recoverStalePlayingCanvas(
          streamID: streamID,
          viewID: viewID,
          error: error,
        );
      }
    }
  }

  /// A view leaving or rebuilding can destroy a canvas after Dart checks its ID
  /// but before updatePlayingCanvas reaches the native side. Reset only the
  /// matching stale channel and let the regular path create a fresh
  /// TextureRenderer; do nothing if the stream was removed or a newer canvas exists.
  Future<void> _recoverStalePlayingCanvas({
    required String streamID,
    required int viewID,
    required PlatformException error,
  }) async {
    final streamData = streamDic[streamID];
    if (streamData == null) {
      ZegoLoggerService.logWarn(
        'stale TextureRenderer recovery skipped: stream was removed, '
        'stream id:$streamID, viewID:$viewID',
        tag: 'uikit-stream',
        subTag: 'update playing canvas',
      );
      return;
    }

    final targetUserIndex = ZegoUIKitCore.shared.coreData.remoteUsersList
        .indexWhere((user) => user.id == streamData.userID);
    if (targetUserIndex == -1) {
      ZegoLoggerService.logWarn(
        'stale TextureRenderer recovery skipped: user was removed, '
        'stream id:$streamID, viewID:$viewID, user id:${streamData.userID}',
        tag: 'uikit-stream',
        subTag: 'update playing canvas',
      );
      return;
    }

    final streamType = getStreamTypeByID(streamID);
    final streamChannel = getUserStreamChannel(
      ZegoUIKitCore.shared.coreData.remoteUsersList[targetUserIndex],
      streamType,
    );
    if (streamChannel.streamID != streamID ||
        streamChannel.viewIDNotifier.value != viewID) {
      ZegoLoggerService.logWarn(
        'stale TextureRenderer recovery skipped: channel has changed, '
        'stream id:$streamID, requested viewID:$viewID, '
        'current stream id:${streamChannel.streamID}, '
        'current viewID:${streamChannel.viewIDNotifier.value}',
        tag: 'uikit-stream',
        subTag: 'update playing canvas',
      );
      return;
    }

    ZegoLoggerService.logWarn(
      'stale TextureRenderer while updating canvas; recreate it, '
      'stream id:$streamID, viewID:$viewID, error:$error',
      tag: 'uikit-stream',
      subTag: 'update playing canvas',
    );

    streamChannel.clearViewInfo();
    ZegoLoggerService.logInfo(
      'stale TextureRenderer state cleared; restart canvas creation, '
      'stream id:$streamID, old viewID:$viewID, user id:${streamData.userID}',
      tag: 'uikit-stream',
      subTag: 'update playing canvas',
    );
    await startPlayingStreamQueue(streamID, streamData.userID);
  }

  Future<void> playStreamOnViewWillCreated({
    required String streamID,
    PlayerStateUpdateCallback? onPlayerStateUpdated,
  }) async {
    final playConfig = ZegoPlayerConfig(
      ZegoUIKitCore.shared.coreData.playResourceMode.toSdkValue,
    );

    ZegoLoggerService.logInfo(
      'ready start, stream id: $streamID',
      tag: 'uikit-stream',
      subTag: 'start play stream',
    );

    await startPlayingStreamByExpress(
      streamID: streamID,
      config: playConfig,
      onPlayerStateUpdated: onPlayerStateUpdated,
    );
  }

  void notifyStreamListControl(ZegoStreamType streamType) {
    final users = getAudioVideoList(streamType: streamType);
    final canvasStates =
        users.map((user) => _describeCanvasState(user, streamType)).join(' | ');
    ZegoLoggerService.logInfo(
      'notify Flutter stream list, streamType:$streamType, '
      'users:${users.length}, canvases:[$canvasStates], '
      'platformView:$isEnablePlatformView, '
      'pipUnderIOS:${ZegoUIKitCore.shared.playingStreamInPIPUnderIOS}',
      tag: 'uikit-stream',
      subTag: 'notify stream list',
    );

    switch (streamType) {
      case ZegoStreamType.main:
        audioVideoListStreamCtrl?.add(users);
        break;
      case ZegoStreamType.media:
        ZegoUIKitCore.shared.coreData.media.mediaListStreamCtrl?.add(users);
        break;
      case ZegoStreamType.screenSharing:
        ZegoUIKitCore.shared.coreData.screenSharingListStreamCtrl?.add(users);
        break;
      case ZegoStreamType.mix:
        break;
    }
  }

  void syncCanvasViewCreateQueue({
    ZegoStreamType streamType = ZegoStreamType.main,
  }) {
    getAudioVideoList(streamType: streamType).forEach((user) {
      if (canvasViewCreateQueue.currentTaskKey ==
          getUserStreamChannel(user, streamType).streamID) {
        if (user.camera.value) {
          return;
        }

        ZegoLoggerService.logInfo(
          'user($user) camera is close, try stopped canvas view queue',
          tag: 'uikit-stream',
          subTag: 'syncCanvasViewCreateQueue',
        );

        canvasViewCreateQueue.completeCurrentTask();
      }
    });
  }

  /// will change data variables
  Future<void> stopPlayingStream(
    String streamID, {
    bool removeDic = true,
  }) async {
    _streamStartRequests.cancel(streamID);
    if (canvasViewCreateQueue.currentTaskKey == streamID) {
      canvasViewCreateQueue.completeCurrentTask();
    }

    final stoppingStreamData = streamDic[streamID];
    if (stoppingStreamData != null) {
      final stoppingUserIndex = ZegoUIKitCore.shared.coreData.remoteUsersList
          .indexWhere((user) => user.id == stoppingStreamData.userID);
      if (stoppingUserIndex != -1) {
        final stoppingUser =
            ZegoUIKitCore.shared.coreData.remoteUsersList[stoppingUserIndex];
        final stoppingChannel = getUserStreamChannel(
          stoppingUser,
          getStreamTypeByID(streamID),
        );
        stoppingChannel.viewCreationGeneration++;
      }
    }

    ZegoLoggerService.logInfo(
      'ready stop stream id: $streamID, '
      '${_describeStreamCanvasState(streamID)}, '
      'pipUnderIOS:${ZegoUIKitCore.shared.playingStreamInPIPUnderIOS}, '
      'platformView:$isEnablePlatformView',
      tag: 'uikit-stream',
      subTag: 'stop play stream',
    );
    assert(streamID.isNotEmpty);

    // stop playing stream
    await stopPlayingStreamByExpress(streamID);

    final targetUserID =
        streamDic.containsKey(streamID) ? streamDic[streamID]!.userID : '';
    ZegoLoggerService.logInfo(
      'stopped, stream id $streamID, user id  is: $targetUserID',
      tag: 'uikit-stream',
      subTag: 'stop play stream',
    );
    final targetUserIndex = ZegoUIKitCore.shared.coreData.remoteUsersList
        .indexWhere((user) => targetUserID == user.id);
    if (-1 != targetUserIndex) {
      final targetUser =
          ZegoUIKitCore.shared.coreData.remoteUsersList[targetUserIndex];
      final streamType = getStreamTypeByID(streamID);
      final streamChannel = getUserStreamChannel(targetUser, streamType);
      final oldViewID = streamChannel.viewIDNotifier.value;
      final oldGeneration = streamChannel.viewCreationGeneration;

      ZegoLoggerService.logInfo(
        'destroy remote canvas, streamID:$streamID, userID:$targetUserID, '
        'streamType:$streamType, viewID:$oldViewID, '
        'generation:$oldGeneration, '
        'widgetHash:${streamChannel.viewNotifier.value?.hashCode}, '
        'viewCreating:${streamChannel.viewCreatingNotifier.value}',
        tag: 'uikit-stream',
        subTag: 'stop play stream',
      );

      getUserStreamChannel(targetUser, streamType)
        ..streamID = ''
        ..viewCreatingNotifier.value = false
        ..streamTimestamp = 0;
      targetUser.destroyTextureRenderer(streamType: streamType);
      ZegoLoggerService.logInfo(
        'remote canvas destroy requested, streamID:$streamID, '
        'userID:$targetUserID, oldViewID:$oldViewID, '
        'generation:$oldGeneration->${streamChannel.viewCreationGeneration}, '
        'currentViewID:${streamChannel.viewIDNotifier.value}, '
        'widgetHash:${streamChannel.viewNotifier.value?.hashCode}',
        tag: 'uikit-stream',
        subTag: 'stop play stream',
      );
      if (streamType == ZegoStreamType.main) {
        targetUser
          ..camera.value = false
          ..cameraMuteMode.value = false
          ..microphone.value = false
          ..microphoneMuteMode.value = false;
      }

      notifyStreamListControl(streamType);
    }

    if (removeDic) {
      // clear streamID
      streamDic.remove(streamID);
      ZegoLoggerService.logInfo(
        'stream dict remove $streamID, $streamDic',
        tag: 'uikit-stream',
        subTag: 'stop play stream',
      );
    }
  }

  List<ZegoUIKitCoreUser> getAudioVideoList({
    ZegoStreamType streamType = ZegoStreamType.main,
  }) {
    return ZegoUIKitCore.shared.coreData.streamDic.entries
        .where((value) => value.key.endsWith(streamType.text))
        .map((entry) {
      final targetUserID = entry.value.userID;
      if (targetUserID == ZegoUIKitCore.shared.coreData.localUser.id) {
        return ZegoUIKitCore.shared.coreData.localUser;
      }
      return ZegoUIKitCore.shared.coreData.remoteUsersList.firstWhere(
          (user) => targetUserID == user.id,
          orElse: ZegoUIKitCoreUser.empty);
    }).where((user) {
      if (user.id.isEmpty) {
        ZegoLoggerService.logInfo(
          'test, user id empty',
          tag: 'uikit-stream',
          subTag: 'getAudioVideoList',
        );

        return false;
      }

      if (streamType == ZegoStreamType.main) {
        /// if camera is in mute mode, same as open state
        final isCameraOpen = user.camera.value || user.cameraMuteMode.value;

        /// if microphone is in mute mode, same as open state
        final isMicrophoneOpen =
            user.microphone.value || user.microphoneMuteMode.value;

        /// only open camera or microphone
        return isCameraOpen || isMicrophoneOpen;
      }

      return true;
    }).toList();
  }

  Future<void> startPlayAnotherRoomAudioVideo(
    String roomID,
    String userID,
    String userName, {
    PlayerStateUpdateCallback? onPlayerStateUpdated,
  }) async {
    var targetUserIndex = ZegoUIKitCore.shared.coreData.remoteUsersList
        .indexWhere((user) => userID == user.id);
    final isUserExist = -1 != targetUserIndex;
    if (!isUserExist) {
      ZegoUIKitCore.shared.coreData.remoteUsersList
          .add(ZegoUIKitCoreUser(userID, userName)..isAnotherRoomUser = true);

      ZegoLoggerService.logInfo(
        'add $userID, now remote list:${ZegoUIKitCore.shared.coreData.remoteUsersList}',
        tag: 'uikit-stream',
        subTag: 'start play another room stream',
      );
    }
    targetUserIndex = ZegoUIKitCore.shared.coreData.remoteUsersList
        .indexWhere((user) => userID == user.id);

    final streamID = generateStreamID(userID, roomID, ZegoStreamType.main);
    streamDic[streamID] = ZegoUIKitCoreDataStreamData(
      userID: userID,
      playerState: ZegoPlayerState.NoPlay,
    );
    ZegoUIKitCore.shared.coreData.remoteUsersList[targetUserIndex]
      ..mainChannel.streamID = streamID
      ..mainChannel.streamTimestamp =
          ZegoUIKitCore.shared.coreData.networkDateTime_.millisecondsSinceEpoch;

    ZegoLoggerService.logInfo(
      'roomID:$roomID, '
      'userID:$userID, userName:$userName, '
      'streamID:$streamID, '
      'targetUserIndex:$targetUserIndex, ',
      tag: 'uikit-stream',
      subTag: 'start play another room stream',
    );

    await playStreamOnViewWillCreated(
      streamID: streamID,
      onPlayerStateUpdated: onPlayerStateUpdated,
    );

    await ZegoExpressEngine.instance.createCanvasView((viewID) async {
      var targetUserIndex = ZegoUIKitCore.shared.coreData.remoteUsersList
          .indexWhere((user) => userID == user.id);

      if (-1 == targetUserIndex) {
        ZegoLoggerService.logInfo(
          'createCanvasView onViewCreated, '
          'but user can not find now! '
          'userID:$userID, targetUserIndex:$targetUserIndex, ',
          tag: 'uikit-stream',
          subTag: 'start play another room stream',
        );

        return;
      }

      ZegoLoggerService.logInfo(
        'createCanvasView onViewCreated, '
        'viewID:$viewID, '
        'remote user list:${ZegoUIKitCore.shared.coreData.remoteUsersList}, '
        'userID:$userID, userName:$userName, targetUserIndex:$targetUserIndex, ',
        tag: 'uikit-stream',
        subTag: 'start play another room stream',
      );

      ZegoUIKitCore.shared.coreData.remoteUsersList[targetUserIndex].mainChannel
          .viewIDNotifier.value = viewID;

      final canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
      await updatePlayStreamViewOnViewCreated(
        streamID: streamID,
        viewID: viewID,
        canvas: canvas,
      );
    }).then((widget) {
      var targetUserIndex = ZegoUIKitCore.shared.coreData.remoteUsersList
          .indexWhere((user) => userID == user.id);

      if (-1 == targetUserIndex) {
        ZegoLoggerService.logInfo(
          'createCanvasView done, '
          'but user can not find now! '
          'userID:$userID, targetUserIndex:$targetUserIndex, ',
          tag: 'uikit-stream',
          subTag: 'start play another room stream',
        );

        return;
      }

      ZegoLoggerService.logInfo(
        'createCanvasView done, '
        'widget:$widget, '
        'roomID:$roomID, '
        'userID:$userID, userName:$userName, targetUserIndex:$targetUserIndex, '
        'streamID:$streamID, ',
        tag: 'uikit-stream',
        subTag: 'start play another room stream',
      );

      assert(widget != null);
      ZegoUIKitCore.shared.coreData.remoteUsersList[targetUserIndex].mainChannel
          .viewNotifier.value = widget;

      notifyStreamListControl(ZegoStreamType.main);
      if (!isUserExist) {
        ZegoUIKitCore.shared.coreData.notifyUserListStreamControl();
      }
    });
  }

  Future<void> stopPlayAnotherRoomAudioVideo(String userID) async {
    ZegoLoggerService.logInfo(
      'userID:$userID',
      tag: 'uikit-stream',
      subTag: 'stop play another room stream',
    );

    final targetUserIndex = ZegoUIKitCore.shared.coreData.remoteUsersList
        .indexWhere((user) => userID == user.id);
    if (-1 == targetUserIndex) {
      ZegoLoggerService.logWarn(
        "can't find this user, userID:$userID",
        tag: 'uikit-stream',
        subTag: 'stop play another room stream',
      );

      return;
    }

    final targetUser =
        ZegoUIKitCore.shared.coreData.remoteUsersList[targetUserIndex];

    final streamID = ZegoUIKitCore
        .shared.coreData.remoteUsersList[targetUserIndex].mainChannel.streamID;
    _streamStartRequests.cancel(streamID);
    targetUser.mainChannel.viewCreationGeneration++;
    await stopPlayingStreamByExpress(streamID);

    targetUser
      ..mainChannel.streamID = ''
      ..mainChannel.viewCreatingNotifier.value = false
      ..mainChannel.streamTimestamp = 0
      ..destroyTextureRenderer(streamType: ZegoStreamType.main)
      ..camera.value = false
      ..cameraMuteMode.value = false
      ..microphone.value = false
      ..microphoneMuteMode.value = false
      ..mainChannel.soundLevelStream?.add(0);

    streamDic.remove(streamID);
    ZegoUIKitCore.shared.coreData.remoteUsersList
        .removeWhere((user) => userID == user.id);
    ZegoLoggerService.logInfo(
      'stopped, userID:$userID, streamID:$streamID',
      tag: 'uikit-stream',
      subTag: 'stop play another room stream',
    );

    notifyStreamListControl(ZegoStreamType.main);
    ZegoUIKitCore.shared.coreData.notifyUserListStreamControl();
  }

  Future<void> startPlayMixAudioVideo(
    String mixerID,
    List<ZegoUIKitCoreUser> users,
    Map<String, int> userSoundIDs, {
    PlayerStateUpdateCallback? onPlayerStateUpdated,
  }) async {
    ZegoLoggerService.logInfo(
      'mixerID:$mixerID, users:$users, userSoundIDs:$userSoundIDs',
      tag: 'uikit-mixstream',
      subTag: 'start play mix audio video',
    );

    if (mixerStreamDic.containsKey(mixerID)) {
      for (var user in users) {
        if (-1 ==
            mixerStreamDic[mixerID]!
                .usersNotifier
                .value
                .indexWhere((e) => e.id == user.id)) {
          mixerStreamDic[mixerID]!.addUser(user);
        }
      }
      mixerStreamDic[mixerID]!.userSoundIDs.addAll(userSoundIDs);
    } else {
      mixerStreamDic[mixerID] = ZegoUIKitCoreMixerStream(
        mixerID,
        userSoundIDs,
        users,
      );

      await playStreamOnViewWillCreated(
        streamID: mixerID,
        onPlayerStateUpdated: onPlayerStateUpdated,
      );

      ZegoExpressEngine.instance.createCanvasView((viewID) async {
        ZegoLoggerService.logInfo(
          'createCanvasView onViewCreated, '
          'viewID:$viewID, ',
          tag: 'uikit-stream',
          subTag: 'start play mix audio video',
        );

        mixerStreamDic[mixerID]!.viewID = viewID;

        final canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
        await updatePlayStreamViewOnViewCreated(
          streamID: mixerID,
          viewID: viewID,
          canvas: canvas,
        );

        Future.delayed(const Duration(seconds: 3), () {
          mixerStreamDic[mixerID]?.loaded.value = true;
        });
      }).then((widget) {
        assert(widget != null);
        mixerStreamDic[mixerID]!.view.value = widget;

        notifyStreamListControl(ZegoStreamType.main);
      });
    }
  }

  Future<void> stopPlayMixAudioVideo(String mixerID) async {
    ZegoLoggerService.logInfo(
      'mixerID:$mixerID',
      tag: 'uikit-mixstream',
      subTag: 'stop play mix audio video',
    );

    stopPlayingStreamByExpress(mixerID);

    mixerStreamDic[mixerID]?.destroyTextureRenderer();
    mixerStreamDic.remove(mixerID);
  }
}
