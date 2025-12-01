// Dart imports:
import 'dart:async';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/services/core/core.dart';
import 'package:zego_uikit/src/services/core/defines/defines.dart';
import 'package:zego_uikit/src/services/services.dart';
import 'canvas_view_create_queue.dart';
import 'room.dart';
import 'room_map.dart';
import 'stream.room.dart';
import 'user.dart';

/// Stream related information for multiple rooms
class ZegoUIKitCoreDataStream {
  final canvasViewCreateQueue = ZegoStreamCanvasViewCreateQueue();
  bool isPreviewing = false;
  bool isEnablePlatformView = false;
  bool isEnableCustomVideoProcessing = false;
  bool isEnableCustomVideoRender = false;
  bool isUsingFrontCameraRequesting = false;
  bool useVideoViewAspectFill = false;
  bool playingStreamInPIPUnderIOS = false;
  bool isEnableSwitchRoomNotStopPlay = false;
  ZegoUIKitVideoInternalConfig pushVideoConfig = ZegoUIKitVideoInternalConfig();

  ZegoUIKitStreamResourceMode playerResourceMode =
      ZegoUIKitStreamResourceMode.Default;
  ZegoUIKitCDNConfig? playerCDNConfig;
  ZegoUIKitVideoCodecID playerVideoCodecID = ZegoUIKitVideoCodecID.Default;

  ZegoUIKitCoreDataRoom get _roomCommonData =>
      ZegoUIKitCore.shared.coreData.room;

  ZegoUIKitCoreDataUser get _userCommonData =>
      ZegoUIKitCore.shared.coreData.user;

  var roomStreams = ZegoUIKitCoreRoomMap<ZegoUIKitCoreDataRoomStream>(
    name: 'stream',
    createDefault: (
      String roomID,
    ) {
      final roomStream = ZegoUIKitCoreDataRoomStream(roomID);
      roomStream.init();
      return roomStream;
    },
    onUpgradeEmptyRoom: (ZegoUIKitCoreDataRoomStream emptyRoomStream, roomID) {
      // When prepared room is upgraded, update its roomID
      emptyRoomStream.roomID = roomID;
      ZegoLoggerService.logInfo(
        'empty room(${emptyRoomStream.hashCode}) has update id to $roomID, ',
        tag: 'uikit.streams',
        subTag: 'room-map',
      );
    },
  );

  void init({
    bool? enablePlatformView,
    bool playingStreamInPIPUnderIOS = false,
  }) {
    ZegoLoggerService.logInfo(
      'init, '
      'playingStreamInPIPUnderIOS:$playingStreamInPIPUnderIOS, '
      'enablePlatformView:$enablePlatformView, ',
      tag: 'uikit.streams',
      subTag: 'uninit',
    );

    this.playingStreamInPIPUnderIOS = playingStreamInPIPUnderIOS;
    isEnablePlatformView = enablePlatformView ?? false;

    roomStreams.forEachSync((roomID, streamInfo) {
      streamInfo.init();
    });
  }

  void uninit() {
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'uikit.streams',
      subTag: 'uninit',
    );

    isEnableCustomVideoRender = false;
    isEnableCustomVideoProcessing = false;

    isEnablePlatformView = false;
    canvasViewCreateQueue.clear();
    isPreviewing = false;

    roomStreams.forEachSync((roomID, streamInfo) {
      streamInfo.uninit();
    });
  }

  void clear({
    required String targetRoomID,
    required bool stopPublishAllStream,
    required bool stopPlayAllStream,
  }) {
    ZegoLoggerService.logInfo(
      'clear, '
      'room id:$targetRoomID, ',
      tag: 'uikit.streams',
      subTag: 'uninit',
    );

    isUsingFrontCameraRequesting = false;

    if (roomStreams.containsRoom(targetRoomID)) {
      final streamInfo = roomStreams.getRoom(targetRoomID);
      streamInfo.clear(
        stopPublishAllStream: stopPublishAllStream,
        stopPlayAllStream: stopPlayAllStream,
      );
      streamInfo.isAllPlayStreamAudioVideoMuted = false;
      streamInfo.isAllPlayStreamAudioMuted = false;
      streamInfo.clearDict();
      streamInfo.extraInfo.clear();
    }
  }

  String? queryRoomIDByStreamID(String streamID) {
    String? queryRoomID;
    roomStreams.forEachSync((roomID, roomStream) {
      if (roomStream.streamDicNotifier.value.containsKey(streamID) ||
          roomStream.mixerStreamDic.containsKey(streamID)) {
        queryRoomID = roomID;
      }
    });

    return queryRoomID;
  }

  bool get isCanvasViewCreateByQueue {
    if (Platform.isAndroid) {
      return false;
    }

    return isEnablePlatformView;
  }

  Future<void> startPreview({
    required String targetRoomID,
  }) async {
    ZegoLoggerService.logInfo(
      'start preview',
      tag: 'uikit.streams',
      subTag: 'start preview',
    );

    await createLocalUserVideoViewQueue(
      targetRoomID: targetRoomID,
      streamType: ZegoStreamType.main,
      onViewCreated: onViewCreatedByStartPreview,
    );
  }

  Future<void> onViewCreatedByStartPreview(ZegoStreamType streamType) async {
    ZegoLoggerService.logInfo(
      'start preview, on view created,'
      'view id:${_userCommonData.localUser.mainChannel.viewIDNotifier.value}, ',
      tag: 'uikit.streams',
      subTag: 'onViewCreatedByStartPreview',
    );

    assert(_userCommonData.localUser.mainChannel.viewIDNotifier.value != -1);

    final previewCanvas = ZegoCanvas(
      _userCommonData.localUser.mainChannel.viewIDNotifier.value ?? -1,
      viewMode: useVideoViewAspectFill
          ? ZegoViewMode.AspectFill
          : ZegoViewMode.AspectFit,
    );

    ZegoLoggerService.logInfo(
      'call express startPreview, for trace enableCustomVideoRender, '
      'isEnableCustomVideoRender:$isEnableCustomVideoRender',
      tag: 'uikit.streams',
      subTag: 'onViewCreatedByStartPreview',
    );
    await ZegoExpressEngine.instance
        .enableCamera(_userCommonData.localUser.camera.value);
    await ZegoExpressEngine.instance
        .startPreview(canvas: previewCanvas)
        .then((_) {
      isPreviewing = true;
    });
  }

  Future<void> stopPreview() async {
    ZegoLoggerService.logInfo(
      'stop preview',
      tag: 'uikit.streams',
      subTag: 'stop preview',
    );

    /// It is necessary to cancel the queue waiting in start preview and the
    /// corresponding state that may exist, otherwise it may not render next
    /// time
    final queueKey = generateStreamID(
      _userCommonData.localUser.id,
      _roomCommonData.currentID,
      ZegoStreamType.main,
    );
    if (canvasViewCreateQueue.currentTaskKey == queueKey) {
      ZegoLoggerService.logInfo(
        'stopped canvas view queue',
        tag: 'uikit.streams',
        subTag: 'stop preview',
      );

      canvasViewCreateQueue.completeCurrentTask();

      ZegoUIKitStreamHelper.getUserStreamChannel(
        _userCommonData.localUser,
        ZegoStreamType.main,
      ).viewCreatingNotifier.value = false;
    }

    await _userCommonData.localUser.destroyTextureRenderer(
      streamType: ZegoStreamType.main,
    );

    await ZegoExpressEngine.instance.stopPreview().then((_) {
      isPreviewing = false;
    });

    ZegoLoggerService.logInfo(
      'done',
      tag: 'uikit.streams',
      subTag: 'stop preview',
    );
  }

  Future<Widget?> createCanvasViewByExpressWithCompleter(
    Function(int viewID) onViewCreated, {
    Key? key,
  }) async {
    Key? canvasViewKey;
    if (Platform.isIOS && isEnablePlatformView) {
      /// iOS & platform view, express view id not callback sometimes, or call random
      /// This will trigger the issue of duplicate keys, and there is no problem after removing it for testing
      // canvasViewKey = key;
    }

    ZegoLoggerService.logInfo(
      'with express with key:$canvasViewKey(${canvasViewKey.toString()})',
      tag: 'uikit.streams',
      subTag: 'create canvas view',
    );

    return await ZegoExpressEngine.instance.createCanvasView(
      (int viewID) async {
        ZegoLoggerService.logInfo(
          'createCanvasView onViewCreated, '
          'viewID:$viewID, ',
          tag: 'uikit.streams',
          subTag: 'create canvas view',
        );

        if (isCanvasViewCreateByQueue) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onViewCreated.call(viewID);

            canvasViewCreateQueue.completeCurrentTask();
          });
        } else {
          onViewCreated.call(viewID);
        }
      },
      key: canvasViewKey,
    );
  }

  Future<void> createLocalUserVideoViewQueue({
    required String targetRoomID,
    required ZegoStreamType streamType,
    required void Function(ZegoStreamType) onViewCreated,
  }) async {
    final localStreamChannel = ZegoUIKitStreamHelper.getUserStreamChannel(
      _userCommonData.localUser,
      streamType,
    );
    if (localStreamChannel.viewCreatingNotifier.value) {
      ZegoLoggerService.logInfo(
        'view is creating, ignore',
        tag: 'uikit.streams',
        subTag: 'create local user video view',
      );

      return;
    }

    if (isCanvasViewCreateByQueue) {
      if (localStreamChannel.viewIDNotifier.value != -1 &&
          localStreamChannel.viewNotifier.value != null) {
        await createLocalUserVideoView(
          targetRoomID: targetRoomID,
          streamType: streamType,
          onViewCreated: onViewCreated,
        );
      } else {
        ZegoLoggerService.logInfo(
          'add to queue',
          tag: 'uikit.streams',
          subTag: 'create local user video view',
        );

        canvasViewCreateQueue.addTask(
          uniqueKey: generateStreamID(
            _userCommonData.localUser.id,
            targetRoomID,
            streamType,
          ),
          task: () async {
            await createLocalUserVideoView(
              targetRoomID: targetRoomID,
              streamType: streamType,
              onViewCreated: onViewCreated,
            );
          },
        );
      }
    } else {
      await createLocalUserVideoView(
        targetRoomID: targetRoomID,
        streamType: streamType,
        onViewCreated: onViewCreated,
      );
    }
  }

  Future<void> createLocalUserVideoView({
    required String targetRoomID,
    required ZegoStreamType streamType,
    required void Function(ZegoStreamType) onViewCreated,
  }) async {
    final localStreamChannel = ZegoUIKitStreamHelper.getUserStreamChannel(
      _userCommonData.localUser,
      streamType,
    );
    ZegoLoggerService.logInfo(
      'current streamChannel, '
      'streamType:$streamType, '
      'view id:${localStreamChannel.viewIDNotifier.value},'
      'view:${localStreamChannel.viewNotifier}, '
      'view hashCode:${localStreamChannel.viewNotifier.hashCode}',
      tag: 'uikit.streams',
      subTag: 'create local user video view',
    );

    if (localStreamChannel.viewIDNotifier.value != -1 &&
        localStreamChannel.viewNotifier.value != null) {
      ZegoLoggerService.logInfo(
        'user view had created, directly call callback, '
        'view id:${localStreamChannel.viewIDNotifier.value},'
        'view:${localStreamChannel.viewNotifier}',
        tag: 'uikit.streams',
        subTag: 'create local user video view',
      );

      if (isCanvasViewCreateByQueue) {
        canvasViewCreateQueue.completeCurrentTask();
      }

      onViewCreated(streamType);
    } else {
      localStreamChannel.viewCreatingNotifier.value = true;

      await createCanvasViewByExpressWithCompleter(
        (viewID) async {
          ZegoLoggerService.logInfo(
            'view id done, '
            'streamType:$streamType, '
            'viewID:$viewID',
            tag: 'uikit.streams',
            subTag: 'create local user video view',
          );

          localStreamChannel.viewCreatingNotifier.value = false;

          localStreamChannel.viewIDNotifier.value = viewID;

          onViewCreated(streamType);
        },
        key: streamType == ZegoStreamType.main
            ? localStreamChannel.globalMainStreamChannelKeyNotifier.value
            : localStreamChannel.globalAuxStreamChannelKeyNotifier.value,
      ).then((widget) {
        ZegoLoggerService.logInfo(
          'widget done, '
          'streamType:$streamType, '
          'widget:$widget ${widget.hashCode}',
          tag: 'uikit.streams',
          subTag: 'create local user video view',
        );

        localStreamChannel.viewNotifier.value = widget;

        roomStreams.getRoom(targetRoomID).notifyStreamListControl(streamType);
      });
    }
  }

  /// Attribute–Value Pair of sound wave for each single stream in the mixed stream
  /// key: the soundLevelID of each single stream
  /// value: the corresponding sound wave value of the single stream
  void processMixerSoundLevelUpdate(Map<int, double> soundLevels) {
    roomStreams.forEachSync((roomID, roomStream) {
      roomStream.processMixerSoundLevelUpdate(soundLevels);
    });
  }
}
