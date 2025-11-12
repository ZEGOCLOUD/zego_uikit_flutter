// Dart imports:
import 'dart:async';
import 'dart:io' show Platform;

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/channel/platform_interface.dart';
import 'package:zego_uikit/src/services/core/core.dart';
import 'package:zego_uikit/src/services/core/defines/defines.dart';
import 'package:zego_uikit/src/services/defines/express_extension.dart';
import 'package:zego_uikit/src/services/services.dart';

import 'screen_sharing.dart';
import 'stream.dart';
import 'stream.data.dart';
import 'stream.helper.dart';
import 'user.dart';
import 'room.dart';

/// 一个房间的流相关信息
class ZegoUIKitCoreDataRoomStream {
  String roomID;
  ZegoUIKitCoreDataRoomStream(this.roomID);

  ZegoUIKitCoreDataRoom get _roomCommonData =>
      ZegoUIKitCore.shared.coreData.room;
  ZegoUIKitCoreDataUser get _userCommonData =>
      ZegoUIKitCore.shared.coreData.user;
  ZegoUIKitCoreDataStream get _streamCommonData =>
      ZegoUIKitCore.shared.coreData.stream;
  ZegoUIKitCoreDataScreenSharing get _screenSharingCommonData =>
      ZegoUIKitCore.shared.coreData.screenSharing;

  bool isPlaying = false;
  bool isPublishing = false;

  Map<String, List<PlayerStateUpdateCallback>> playerStateUpdateCallbackList =
      {};

  /// {stream id:mix stream data}
  final Map<String, ZegoUIKitCoreMixerStream> mixerStreamDic = {};

  /// {stream id:stream data}
  final Map<String, ZegoUIKitCoreDataStreamData> streamDic = {};

  final Map<String, String> extraInfo = {}; // stream_id:extra info

  bool isAllPlayStreamAudioVideoMuted = false;
  bool isAllPlayStreamAudioMuted = false;

  StreamController<List<ZegoUIKitCoreUser>>? audioVideoListStreamCtrl;

  StreamController<String>? turnOnYourCameraRequestStreamCtrl;
  StreamController<ZegoUIKitReceiveTurnOnLocalMicrophoneEvent>?
      turnOnYourMicrophoneRequestStreamCtrl;

  StreamController<ZegoUIKitReceiveSEIEvent>? receiveSEIStreamCtrl;

  void init() {
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'init',
      tag: 'uikit-streams-room',
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

  void uninit() {
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'uninit',
      tag: 'uikit-streams-room',
      subTag: 'uninit',
    );

    audioVideoListStreamCtrl?.close();
    audioVideoListStreamCtrl = null;

    turnOnYourCameraRequestStreamCtrl?.close();
    turnOnYourCameraRequestStreamCtrl = null;

    turnOnYourMicrophoneRequestStreamCtrl?.close();
    turnOnYourMicrophoneRequestStreamCtrl = null;

    receiveSEIStreamCtrl?.close();
    receiveSEIStreamCtrl = null;

    isPublishing = false;
    isPlaying = false;
  }

  void clear() {
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'clear',
      tag: 'uikit-streams-room',
      subTag: 'clearStream',
    );

    if (_screenSharingCommonData.isScreenSharing.value) {
      _screenSharingCommonData.stopSharingScreen(
        targetRoomID: roomID,
      );
    }

    for (final user in _userCommonData.roomUsers.getRoom(roomID).remoteUsers) {
      if (user.mainChannel.streamID.isNotEmpty) {
        stopPlayingStream(user.mainChannel.streamID);
      }
      user.destroyTextureRenderer(streamType: ZegoStreamType.main);

      if (user.auxChannel.streamID.isNotEmpty) {
        stopPlayingStream(user.auxChannel.streamID);
      }
      user.destroyTextureRenderer(streamType: ZegoStreamType.screenSharing);
    }

    if (_userCommonData.localUser.mainChannel.streamID.isNotEmpty) {
      stopPublishingStream(streamType: ZegoStreamType.main);
      _userCommonData.localUser.destroyTextureRenderer(
        streamType: ZegoStreamType.main,
      );
    }
    if (_userCommonData.localUser.auxChannel.streamID.isNotEmpty) {
      stopPublishingStream(streamType: ZegoStreamType.screenSharing);
      _userCommonData.localUser.destroyTextureRenderer(
        streamType: ZegoStreamType.screenSharing,
      );
    }

    isPublishing = false;
    isPlaying = false;
  }

  Future<void> startPublishingStream({
    required ZegoStreamType streamType,
  }) async {
    final localUserStreamChannel =
        ZegoUIKitCoreDataStreamHelper.getUserStreamChannel(
      _userCommonData.localUser,
      streamType,
    );

    if (localUserStreamChannel.streamID.isNotEmpty) {
      ///  stream id had generated, that mean is publishing
      ZegoLoggerService.logWarn(
        'hash:$hashCode, '
        'local user stream id(${localUserStreamChannel.streamID}) of $streamType is not empty, '
        'local user is publishing...',
        tag: 'uikit-streams-room',
        subTag: 'start publish stream',
      );
      return;
    }

    final localUserStreamViewID =
        localUserStreamChannel.viewIDNotifier.value ?? -1;
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'updateConfigBeforeStartPublishingStream, '
      'view id:$localUserStreamViewID, ',
      tag: 'uikit-streams-room',
      subTag: 'start publish stream',
    );

    /// advance config
    switch (streamType) {
      case ZegoStreamType.main:
        await ZegoExpressEngine.instance
            .enableCamera(_userCommonData.localUser.camera.value);
        await ZegoExpressEngine.instance.muteMicrophone(
          !_userCommonData.localUser.microphone.value,
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
          instanceID: _screenSharingCommonData.screenCaptureSource!.getIndex(),
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
    localUserStreamChannel
      ..streamID = generateStreamID(
        _userCommonData.localUser.id,
        roomID,
        streamType,
      )
      ..streamTimestamp =
          ZegoUIKitCore.shared.coreData.timestamp.now.millisecondsSinceEpoch;
    streamDic[localUserStreamChannel.streamID] = ZegoUIKitCoreDataStreamData(
      roomID: roomID,
      userID: _userCommonData.localUser.id,
      publisherState: ZegoPublisherState.NoPublish,
    );

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'stream dict add $streamType ${localUserStreamChannel.streamID} for ${_userCommonData.localUser.id}, '
      'now stream dict:$streamDic',
      tag: 'uikit-streams-room',
      subTag: 'start publish stream',
    );

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'start publish, '
      '${localUserStreamChannel.streamID}, '
      'network state:${ZegoUIKit().getNetworkState()}, ',
      tag: 'uikit-streams-room',
      subTag: 'start publish stream',
    );

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'call express startPublishingStream, for trace enableCustomVideoRender, '
      'isEnableCustomVideoRender:${_streamCommonData.isEnableCustomVideoRender}',
      tag: 'uikit-streams-room',
      subTag: 'start publish stream',
    );
    await ZegoExpressEngine.instance
        .startPublishingStream(
      localUserStreamChannel.streamID,
      channel: streamType.channel,
      config: ZegoPublisherConfig(roomID: roomID),
    )
        .then((_) {
      isPublishing = true;
    });

    notifyStreamListControl(streamType);
  }

  Future<void> onViewCreatedByStartPublishingStream(
    ZegoStreamType streamType,
  ) async {
    final localTargetStreamViewID =
        ZegoUIKitCoreDataStreamHelper.getUserStreamChannel(
              _userCommonData.localUser,
              streamType,
            ).viewIDNotifier.value ??
            -1;
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'onViewCreatedByStartPublishingStream, '
      'view id:$localTargetStreamViewID, ',
      tag: 'uikit-streams-room',
      subTag: 'start publish stream',
    );

    /// advance config
    switch (streamType) {
      case ZegoStreamType.main:
        assert(localTargetStreamViewID != -1);
        final canvas = ZegoCanvas(
          localTargetStreamViewID,
          viewMode: _streamCommonData.useVideoViewAspectFill
              ? ZegoViewMode.AspectFill
              : ZegoViewMode.AspectFit,
        );
        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'call express startPreview, for trace enableCustomVideoRender, '
          'isEnableCustomVideoRender:${_streamCommonData.isEnableCustomVideoRender}',
          tag: 'uikit-streams-room',
          subTag: 'start publish stream',
        );
        await ZegoExpressEngine.instance.startPreview(canvas: canvas).then((_) {
          _streamCommonData.isPreviewing = true;
        });
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
    final localUserStreamChannel =
        ZegoUIKitCoreDataStreamHelper.getUserStreamChannel(
      _userCommonData.localUser,
      streamType,
    );
    final targetStreamID = localUserStreamChannel.streamID;
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'stop $streamType $targetStreamID}, '
      'network state:${ZegoUIKit().getNetworkState()}, ',
      tag: 'uikit-streams-room',
      subTag: 'stop publish stream',
    );

    if (targetStreamID.isEmpty) {
      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'stream id is empty',
        tag: 'uikit-streams-room',
        subTag: 'stop publish stream',
      );

      return;
    }

    if (_streamCommonData.canvasViewCreateQueue.currentTaskKey ==
        targetStreamID) {
      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'stopped canvas view queue',
        tag: 'uikit-streams-room',
        subTag: 'stop publish stream',
      );

      _streamCommonData.canvasViewCreateQueue.completeCurrentTask();
    }

    streamDic.remove(targetStreamID);
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'stream dict remove $targetStreamID, now stream dict:$streamDic',
      tag: 'uikit-streams-room',
      subTag: 'stop publish stream',
    );

    localUserStreamChannel
      ..streamID = ''
      ..viewCreatingNotifier.value = false
      ..streamTimestamp = 0;

    _userCommonData.localUser.destroyTextureRenderer(streamType: streamType);

    switch (streamType) {
      case ZegoStreamType.main:
        await ZegoExpressEngine.instance.stopPreview().then((_) {
          _streamCommonData.isPreviewing = false;
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
      isPublishing = false;

      audioVideoListStreamCtrl?.add(getAudioVideoList());
      _screenSharingCommonData.screenSharingListStreamCtrl
          ?.add(getAudioVideoList(streamType: ZegoStreamType.screenSharing));
      ZegoUIKitCore.shared.coreData.media.mediaListStreamCtrl
          ?.add(getAudioVideoList(streamType: ZegoStreamType.media));
    });
  }

  Future<void> startPublishOrNot() async {
    final roomInfo = _roomCommonData.rooms.getRoom(roomID);
    if (!roomInfo.isLogin) {
      ZegoLoggerService.logWarn(
        'hash:$hashCode, '
        'room id: $roomID, state:${roomInfo.state}, '
        'room is not login',
        tag: 'uikit-streams-room',
        subTag: 'publish stream',
      );
      return;
    }

    if (_userCommonData.localUser.camera.value ||
        _userCommonData.localUser.cameraMuteMode.value ||
        _userCommonData.localUser.microphone.value ||
        _userCommonData.localUser.microphoneMuteMode.value) {
      /// start publish first
      await startPublishingStream(
        streamType: ZegoStreamType.main,
      );

      /// create canvas if need
      if (_userCommonData.localUser.camera.value ||
          _userCommonData.localUser.cameraMuteMode.value) {
        await _streamCommonData.createLocalUserVideoViewQueue(
          targetRoomID: roomID,
          streamType: ZegoStreamType.main,
          onViewCreated: onViewCreatedByStartPublishingStream,
        );
      }
    } else {
      if (_userCommonData.localUser.mainChannel.streamID.isNotEmpty) {
        stopPublishingStream(streamType: ZegoStreamType.main);
      }
    }
  }

  Future<void> syncRoomStream() async {
    await ZegoExpressEngine.instance
        .getRoomStreamList(
      roomID,
      ZegoRoomStreamListType.Play,
    )
        .then((streamList) {
      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'publishStreamList list, ${streamList.publishStreamList.map((e) => e.toStringX())},  '
        'playStreamList list, ${streamList.playStreamList.map((e) => e.toStringX())}',
        tag: 'uikit-streams-room',
        subTag: 'syncRoomStream',
      );

      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'put play stream list to onRoomStreamUpdate',
        tag: 'uikit-streams-room',
        subTag: 'syncRoomStream',
      );
      ZegoUIKitCore.shared.eventHandler.onRoomStreamUpdate(
        roomID,
        ZegoUpdateType.Add,
        streamList.playStreamList,
        {},
      );
    });
  }

  Future<bool> mutePlayStreamAudioVideo(
    String userID,
    bool mute, {
    bool forAudio = true,
    bool forVideo = true,
  }) async {
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'userID: $userID, mute: $mute, '
      'for audio:$forAudio, for video:$forVideo',
      tag: 'uikit-streams-room',
      subTag: 'mute play stream audio video',
    );

    final targetRoomRemoteUserList =
        _userCommonData.roomUsers.getRoom(roomID).remoteUsers;

    final targetUserIndex =
        targetRoomRemoteUserList.indexWhere((user) => userID == user.id);
    if (-1 == targetUserIndex) {
      ZegoLoggerService.logError(
        'hash:$hashCode, '
        "can't find $userID",
        tag: 'uikit-streams-room',
        subTag: 'mute play stream audio video',
      );
      return false;
    }

    final targetUser = targetRoomRemoteUserList[targetUserIndex];
    if (targetUser.mainChannel.streamID.isEmpty) {
      ZegoLoggerService.logError(
        'hash:$hashCode, '
        "can't find $userID's stream",
        tag: 'uikit-streams-room',
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

  Future<void> muteAllPlayStreamAudioVideo(
    bool isMuted,
  ) async {
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'muted: $isMuted, streamDic:$streamDic',
      tag: 'uikit-streams-room',
      subTag: 'mute all play stream audio video',
    );

    isAllPlayStreamAudioVideoMuted = isMuted;
    await ZegoExpressEngine.instance
        .muteAllPlayStreamVideo(isAllPlayStreamAudioVideoMuted);
    await ZegoExpressEngine.instance
        .muteAllPlayStreamAudio(isAllPlayStreamAudioVideoMuted);

    for (var entry in streamDic.entries) {
      final streamID = entry.key;
      final streamInfo = entry.value;
      if (isMuted) {
        if (ZegoPlayerState.Playing == streamInfo.playerState) {
          await stopPlayingStream(
            streamID,
            removeDic: false,
          );
        } else {
          ZegoLoggerService.logInfo(
            'hash:$hashCode, '
            'stream id($streamID) not playing(${streamInfo.playerState}) now, waiting player state update',
            tag: 'uikit-streams-room',
            subTag: 'mute all play stream audio video',
          );
        }
      } else {
        if (_userCommonData.localUser.id != streamInfo.userID &&
            streamInfo.playerState == ZegoPlayerState.NoPlay) {
          final previousStreamExtraInfo = extraInfo[streamID] ?? '';
          final targetUserIndex = _userCommonData.roomUsers
              .getRoom(roomID)
              .remoteUsers
              .indexWhere((user) => streamInfo.userID == user.id);
          ZegoLoggerService.logInfo(
            'hash:$hashCode, '
            'test, attempt to restore previous stream additional information, '
            'previousStreamExtraInfo:$previousStreamExtraInfo, '
            'targetUserIndex:$targetUserIndex',
            tag: 'uikit-streams-room',
            subTag: 'mute all play stream audio video',
          );
          if (previousStreamExtraInfo.isNotEmpty) {
            /// 先加载之前的流附加信息
            ZegoUIKitCore.shared.eventHandler.parseStreamExtraInfo(
              streamID: streamID,
              extraInfo: previousStreamExtraInfo,
            );
          }

          await startPlayingStreamQueue(
            streamID,
            streamInfo.userID,
          );
        }
      }
    }
  }

  Future<void> muteAllPlayStreamAudio(bool isMuted) async {
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'muted: $isMuted, streamDic:$streamDic',
      tag: 'uikit-streams-room',
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
    final targetRoomRemoteUserList =
        _userCommonData.roomUsers.getRoom(roomID).remoteUsers;

    final targetUserIndex =
        targetRoomRemoteUserList.indexWhere((user) => streamUserID == user.id);
    if (-1 == targetUserIndex) {
      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'targetUserIndex is invalid, '
        'stream id: $streamID, '
        'user id:$streamUserID, ',
        tag: 'uikit-streams-room',
        subTag: 'start play stream',
      );

      return;
    }

    final targetUser = targetRoomRemoteUserList[targetUserIndex];
    final streamType =
        ZegoUIKitCoreDataStreamHelper.getStreamTypeByID(streamID);

    final targetUserStreamChannel =
        ZegoUIKitCoreDataStreamHelper.getUserStreamChannel(
      targetUser,
      streamType,
    );

    if (targetUserStreamChannel.viewCreatingNotifier.value) {
      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'stream id: $streamID, user id:$streamUserID, '
        'view is creating, ignore',
        tag: 'uikit-streams-room',
        subTag: 'start play stream',
      );

      return;
    }

    if (_streamCommonData.isCanvasViewCreateByQueue) {
      if (targetUserStreamChannel.viewIDNotifier.value != -1 &&
          targetUserStreamChannel.viewNotifier.value != null) {
        await startPlayingStream(
          streamID,
          streamUserID,
        );
      } else {
        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'stream id: $streamID, user id:$streamUserID, '
          'add to queue',
          tag: 'uikit-streams-room',
          subTag: 'start play stream',
        );

        _streamCommonData.canvasViewCreateQueue.addTask(
          uniqueKey: streamID,
          task: () async {
            await startPlayingStream(
              streamID,
              streamUserID,
            );
          },
        );
      }
    } else {
      await startPlayingStream(
        streamID,
        streamUserID,
      );
    }
  }

  /// will change data variables
  Future<void> startPlayingStream(String streamID, String streamUserID) async {
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'stream id: $streamID, '
      'user id:$streamUserID, '
      'room id:$roomID,',
      tag: 'uikit-streams-room',
      subTag: 'start play stream',
    );

    final targetRoomRemoteUserList =
        _userCommonData.roomUsers.getRoom(roomID).remoteUsers;
    final targetUserIndex =
        targetRoomRemoteUserList.indexWhere((user) => streamUserID == user.id);
    assert(-1 != targetUserIndex);
    final targetUser = targetRoomRemoteUserList[targetUserIndex];
    final streamType =
        ZegoUIKitCoreDataStreamHelper.getStreamTypeByID(streamID);

    ZegoUIKitCoreDataStreamHelper.getUserStreamChannel(targetUser, streamType)
      ..streamID = streamID
      ..streamTimestamp =
          ZegoUIKitCore.shared.coreData.timestamp.now.millisecondsSinceEpoch;

    final targetUserStreamChannel =
        ZegoUIKitCoreDataStreamHelper.getUserStreamChannel(
            targetUser, streamType);
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'current stream channel, '
      'view id:${targetUserStreamChannel.viewIDNotifier.value},'
      'view:${targetUserStreamChannel.viewNotifier}',
      tag: 'uikit-streams-room',
      subTag: 'start play stream',
    );

    await playStreamOnViewWillCreated(
      streamID: streamID,
    );

    if (targetUserStreamChannel.viewIDNotifier.value != -1 &&
        targetUserStreamChannel.viewNotifier.value != null) {
      final viewID = ZegoUIKitCoreDataStreamHelper.getUserStreamChannel(
                  targetUser, streamType)
              .viewIDNotifier
              .value ??
          -1;

      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'canvas view had created before, directly call callback, '
        'viewID:$viewID, '
        'user id:$streamUserID, '
        'stream id:$streamID, ',
        tag: 'uikit-streams-room',
        subTag: 'start play stream',
      );

      if (_streamCommonData.isCanvasViewCreateByQueue) {
        _streamCommonData.canvasViewCreateQueue.completeCurrentTask();
      }

      await updatePlayStreamViewOnViewCreated(
        streamID: streamID,
        viewID: viewID,
        streamType: streamType,
      );
    } else {
      ZegoUIKitCoreDataStreamHelper.getUserStreamChannel(targetUser, streamType)
          .viewCreatingNotifier
          .value = true;

      await _streamCommonData.createCanvasViewByExpressWithCompleter(
        (viewID) async {
          ZegoLoggerService.logInfo(
            'hash:$hashCode, '
            'canvas view id done '
            'viewID:$viewID, '
            'user id:$streamUserID, '
            'stream id:$streamID, ',
            tag: 'uikit-streams-room',
            subTag: 'start play stream',
          );

          ZegoUIKitCoreDataStreamHelper.getUserStreamChannel(
                  targetUser, streamType)
              .viewCreatingNotifier
              .value = false;
          ZegoUIKitCoreDataStreamHelper.getUserStreamChannel(
                  targetUser, streamType)
              .viewIDNotifier
              .value = viewID;

          await updatePlayStreamViewOnViewCreated(
            streamID: streamID,
            viewID: viewID,
            streamType: streamType,
          );
        },
        key: streamType == ZegoStreamType.main
            ? targetUserStreamChannel.globalMainStreamChannelKeyNotifier.value
            : targetUserStreamChannel.globalAuxStreamChannelKeyNotifier.value,
      ).then((widget) {
        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'widget done, '
          'widget:$widget ${widget.hashCode}, '
          'user id:$streamUserID, '
          'stream id:$streamID, ',
          tag: 'uikit-streams-room',
          subTag: 'start play stream',
        );

        ZegoUIKitCoreDataStreamHelper.getUserStreamChannel(
                targetUser, streamType)
            .viewNotifier
            .value = widget;

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
          ZegoUIKitCore.shared.coreData.stream.playingStreamInPIPUnderIOS;
    }

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'streamID:$streamID, '
      'startPlayingStreamInIOSPIP:$startPlayingStreamInIOSPIP, ',
      tag: 'uikit-streams-room',
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
      'hash:$hashCode, '
      'call express startPlayingStream, for trace enableCustomVideoRender, '
      'isEnableCustomVideoRender:${_streamCommonData.isEnableCustomVideoRender}',
      tag: 'uikit-streams-room',
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

      ZegoUIKitPluginPlatform.instance
          .startPlayingStreamInPIP(
        streamID,
        resourceMode: config?.resourceMode.index,
        roomID: config?.roomID,
        cdnConfig: cdnConfigMap,
        videoCodecID: config?.videoCodecID?.index,
      )
          .then(
        (_) {
          isPlaying = true;

          ZegoLoggerService.logInfo(
            'hash:$hashCode, '
            'finish play stream in ios with pip, '
            'stream id: $streamID, ',
            tag: 'uikit-streams-room',
            subTag: 'start play stream',
          );
        },
      );
    } else {
      await ZegoExpressEngine.instance
          .startPlayingStream(
        streamID,
        canvas: null,
        config: config,
      )
          .then((value) {
        isPlaying = true;

        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'finish play, '
          'stream id: $streamID, ',
          tag: 'uikit-streams-room',
          subTag: 'start play stream',
        );
      });
    }
  }

  Future<void> stopPlayingStreamByExpress(String streamID) async {
    bool stopPlayingStreamInIOSPIP = false;
    if (Platform.isIOS) {
      stopPlayingStreamInIOSPIP =
          ZegoUIKitCore.shared.coreData.stream.playingStreamInPIPUnderIOS;
    }

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'streamID:$streamID, '
      'stopPlayingStreamInIOSPIP:$stopPlayingStreamInIOSPIP, ',
      tag: 'uikit-streams-room',
      subTag: 'stop play stream by express',
    );

    if (stopPlayingStreamInIOSPIP) {
      ZegoUIKitPluginPlatform.instance
          .stopPlayingStreamInPIP(streamID)
          .then((_) {
        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'stop play done in ios with pip, '
          'stream id: $streamID, ',
          tag: 'uikit-streams-room',
          subTag: 'stop play stream',
        );
      });
    } else {
      await ZegoExpressEngine.instance.stopPlayingStream(streamID).then((_) {
        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'stop play done, '
          'stream id: $streamID, ',
          tag: 'uikit-streams-room',
          subTag: 'stop play stream',
        );
      });
    }
  }

  Future<void> updatePlayStreamViewOnViewCreated({
    required String streamID,
    required int viewID,
    ZegoStreamType? streamType,
    ZegoCanvas? canvas,
  }) async {
    final viewMode = ZegoStreamType.main == streamType
        ? (_streamCommonData.useVideoViewAspectFill
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
          ZegoUIKitCore.shared.coreData.stream.playingStreamInPIPUnderIOS;

      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'isPlayingStreamInIOSPIP:$startPlayingStreamInIOSPIP, ',
        tag: 'uikit-streams-room',
        subTag: 'start play stream',
      );
    }

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'ready start, '
      'stream id: $streamID, '
      'view mode:$viewMode(${viewMode.index}), ',
      tag: 'uikit-streams-room',
      subTag: 'start play stream',
    );

    if (startPlayingStreamInIOSPIP) {
      ZegoUIKitPluginPlatform.instance
          .updatePlayingStreamViewInPIP(viewID, streamID, viewMode.index)
          .then((_) {
        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'finish update stream view/canvas in ios with pip, '
          'stream id:$streamID, '
          'view id:$viewID, ',
          tag: 'uikit-streams-room',
          subTag: 'start play stream',
        );
      });
    } else {
      await ZegoExpressEngine.instance
          .updatePlayingCanvas(streamID, canvas)
          .then((value) {
        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'finish update stream view/canvas, '
          'stream id: $streamID, '
          'canvas:$canvas, ',
          tag: 'uikit-streams-room',
          subTag: 'start play stream',
        );
      });
    }
  }

  Future<void> playStreamOnViewWillCreated({
    required String streamID,
    PlayerStateUpdateCallback? onPlayerStateUpdated,
  }) async {
    final playConfig = ZegoPlayerConfig(
      _streamCommonData.playerResourceMode,
      roomID: roomID,
      cdnConfig: _streamCommonData.playerCDNConfig,
      videoCodecID: _streamCommonData.playerVideoCodecID,
    );

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'ready start, stream id: $streamID',
      tag: 'uikit-streams-room',
      subTag: 'start play stream',
    );

    await startPlayingStreamByExpress(
      streamID: streamID,
      config: playConfig,
      onPlayerStateUpdated: onPlayerStateUpdated,
    );
  }

  void notifyStreamListControl(
    ZegoStreamType streamType,
  ) {
    switch (streamType) {
      case ZegoStreamType.main:
        audioVideoListStreamCtrl?.add(getAudioVideoList());
        break;
      case ZegoStreamType.media:
        ZegoUIKitCore.shared.coreData.media.mediaListStreamCtrl
            ?.add(getAudioVideoList(streamType: streamType));
        break;
      case ZegoStreamType.screenSharing:
        _screenSharingCommonData.screenSharingListStreamCtrl
            ?.add(getAudioVideoList(streamType: streamType));
        break;
      case ZegoStreamType.mix:
        break;
    }
  }

  void syncCanvasViewCreateQueue({
    ZegoStreamType streamType = ZegoStreamType.main,
  }) {
    getAudioVideoList(streamType: streamType).forEach((user) {
      if (_streamCommonData.canvasViewCreateQueue.currentTaskKey ==
          ZegoUIKitCoreDataStreamHelper.getUserStreamChannel(user, streamType)
              .streamID) {
        if (user.camera.value) {
          return;
        }

        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'user($user) camera is close, try stopped canvas view queue',
          tag: 'uikit-streams-room',
          subTag: 'syncCanvasViewCreateQueue',
        );

        _streamCommonData.canvasViewCreateQueue.completeCurrentTask();
      }
    });
  }

  /// will change data variables
  Future<void> stopPlayingStream(
    String streamID, {
    bool removeDic = true,
  }) async {
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'ready stop stream id: $streamID',
      tag: 'uikit-streams-room',
      subTag: 'stop play stream',
    );
    assert(streamID.isNotEmpty);

    // stop playing stream
    await stopPlayingStreamByExpress(streamID);

    final targetUserID =
        streamDic.containsKey(streamID) ? streamDic[streamID]!.userID : '';
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'stopped, stream id $streamID, user id  is: $targetUserID',
      tag: 'uikit-streams-room',
      subTag: 'stop play stream',
    );

    final targetRoomRemoteUserList =
        _userCommonData.roomUsers.getRoom(roomID).remoteUsers;
    final targetUserIndex =
        targetRoomRemoteUserList.indexWhere((user) => targetUserID == user.id);
    if (-1 != targetUserIndex) {
      final targetUser = targetRoomRemoteUserList[targetUserIndex];
      final streamType =
          ZegoUIKitCoreDataStreamHelper.getStreamTypeByID(streamID);

      if (_streamCommonData.canvasViewCreateQueue.currentTaskKey ==
          ZegoUIKitCoreDataStreamHelper.getUserStreamChannel(
                  targetUser, streamType)
              .streamID) {
        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'stopped canvas view queue',
          tag: 'uikit-streams-room',
          subTag: 'stop play stream',
        );

        _streamCommonData.canvasViewCreateQueue.completeCurrentTask();
      }

      ZegoUIKitCoreDataStreamHelper.getUserStreamChannel(targetUser, streamType)
        ..streamID = ''
        ..viewCreatingNotifier.value = false
        ..streamTimestamp = 0;
      targetUser.destroyTextureRenderer(streamType: streamType);
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
        'hash:$hashCode, '
        'stream dict remove $streamID, $streamDic',
        tag: 'uikit-streams-room',
        subTag: 'stop play stream',
      );
    }
  }

  List<ZegoUIKitCoreUser> getAudioVideoList({
    ZegoStreamType streamType = ZegoStreamType.main,
  }) {
    return streamDic.entries
        .where((value) => value.key.endsWith(streamType.text))
        .map((entry) {
      final targetUserID = entry.value.userID;
      if (targetUserID == _userCommonData.localUser.id) {
        return _userCommonData.localUser;
      }
      return _userCommonData.roomUsers.getRoom(roomID).remoteUsers.firstWhere(
          (user) => targetUserID == user.id,
          orElse: ZegoUIKitCoreUser.empty);
    }).where((user) {
      if (user.id.isEmpty) {
        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'test, user id empty',
          tag: 'uikit-streams-room',
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
    final targetRoomRemoteUserList =
        _userCommonData.roomUsers.getRoom(this.roomID).remoteUsers;
    var targetUserIndex = _userCommonData.roomUsers
        .getRoom(this.roomID)
        .remoteUsers
        .indexWhere((user) => userID == user.id);
    final isUserExist = -1 != targetUserIndex;
    if (!isUserExist) {
      targetRoomRemoteUserList
          .add(ZegoUIKitCoreUser(userID, userName)..isAnotherRoomUser = true);

      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'add $userID, now remote list:$targetRoomRemoteUserList',
        tag: 'uikit-streams-room',
        subTag: 'start play another room stream',
      );
    }
    targetUserIndex =
        targetRoomRemoteUserList.indexWhere((user) => userID == user.id);

    final streamID = generateStreamID(userID, roomID, ZegoStreamType.main);
    streamDic[streamID] = ZegoUIKitCoreDataStreamData(
      roomID: roomID,
      userID: userID,
      playerState: ZegoPlayerState.NoPlay,
    );
    targetRoomRemoteUserList[targetUserIndex]
      ..mainChannel.streamID = streamID
      ..mainChannel.streamTimestamp =
          ZegoUIKitCore.shared.coreData.timestamp.now.millisecondsSinceEpoch;

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'current room id:${this.roomID}, '
      'target room id:$roomID, '
      'userID:$userID, userName:$userName, '
      'streamID:$streamID, '
      'targetUserIndex:$targetUserIndex, ',
      tag: 'uikit-streams-room',
      subTag: 'start play another room stream',
    );

    await playStreamOnViewWillCreated(
      streamID: streamID,
      onPlayerStateUpdated: onPlayerStateUpdated,
    );

    await ZegoExpressEngine.instance.createCanvasView((viewID) async {
      var targetUserIndex =
          targetRoomRemoteUserList.indexWhere((user) => userID == user.id);

      if (-1 == targetUserIndex) {
        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'createCanvasView onViewCreated, '
          'but user can not find now! '
          'userID:$userID, targetUserIndex:$targetUserIndex, ',
          tag: 'uikit-streams-room',
          subTag: 'start play another room stream',
        );

        return;
      }

      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'createCanvasView onViewCreated, '
        'viewID:$viewID, '
        'remote user list:$targetRoomRemoteUserList, '
        'userID:$userID, userName:$userName, targetUserIndex:$targetUserIndex, ',
        tag: 'uikit-streams-room',
        subTag: 'start play another room stream',
      );

      targetRoomRemoteUserList[targetUserIndex]
          .mainChannel
          .viewIDNotifier
          .value = viewID;

      final canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
      await updatePlayStreamViewOnViewCreated(
        streamID: streamID,
        viewID: viewID,
        canvas: canvas,
      );
    }).then((widget) {
      var targetUserIndex =
          targetRoomRemoteUserList.indexWhere((user) => userID == user.id);

      if (-1 == targetUserIndex) {
        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'createCanvasView done, '
          'but user can not find now! '
          'userID:$userID, targetUserIndex:$targetUserIndex, ',
          tag: 'uikit-streams-room',
          subTag: 'start play another room stream',
        );

        return;
      }

      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'createCanvasView done, '
        'widget:$widget, '
        'roomID:$roomID, '
        'userID:$userID, userName:$userName, targetUserIndex:$targetUserIndex, '
        'streamID:$streamID, ',
        tag: 'uikit-streams-room',
        subTag: 'start play another room stream',
      );

      assert(widget != null);
      targetRoomRemoteUserList[targetUserIndex].mainChannel.viewNotifier.value =
          widget;

      notifyStreamListControl(ZegoStreamType.main);
      if (!isUserExist) {
        _userCommonData.notifyUserListStreamControl(
          targetRoomID: this.roomID,
        );
      }
    });
  }

  Future<void> stopPlayAnotherRoomAudioVideo(
    String userID,
  ) async {
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'userID:$userID',
      tag: 'uikit-streams-room',
      subTag: 'stop play another room stream',
    );

    final targetRoomRemoteUserList =
        _userCommonData.roomUsers.getRoom(roomID).remoteUsers;

    final targetUserIndex =
        targetRoomRemoteUserList.indexWhere((user) => userID == user.id);
    if (-1 == targetUserIndex) {
      ZegoLoggerService.logWarn(
        'hash:$hashCode, '
        "can't find this user, userID:$userID",
        tag: 'uikit-streams-room',
        subTag: 'stop play another room stream',
      );

      return;
    }

    final targetUser = targetRoomRemoteUserList[targetUserIndex];

    final streamID =
        targetRoomRemoteUserList[targetUserIndex].mainChannel.streamID;
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
    targetRoomRemoteUserList.removeWhere((user) => userID == user.id);
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'stopped, userID:$userID, streamID:$streamID',
      tag: 'uikit-streams-room',
      subTag: 'stop play another room stream',
    );

    notifyStreamListControl(ZegoStreamType.main);
    _userCommonData.notifyUserListStreamControl(
      targetRoomID: roomID,
    );
  }

  Future<void> startPlayMixAudioVideo(
    String mixerID,
    List<ZegoUIKitCoreUser> users,
    Map<String, int> userSoundIDs, {
    PlayerStateUpdateCallback? onPlayerStateUpdated,
  }) async {
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
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
          'hash:$hashCode, '
          'createCanvasView onViewCreated, '
          'viewID:$viewID, ',
          tag: 'uikit-mixstream',
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
      'hash:$hashCode, '
      'mixerID:$mixerID',
      tag: 'uikit-mixstream',
      subTag: 'stop play mix audio video',
    );

    stopPlayingStreamByExpress(mixerID);

    mixerStreamDic[mixerID]?.destroyTextureRenderer();
    mixerStreamDic.remove(mixerID);
  }

  /// Attribute–Value Pair of sound wave for each single stream in the mixed stream
  /// key: the soundLevelID of each single stream
  /// value: the corresponding sound wave value of the single stream
  void processMixerSoundLevelUpdate(Map<int, double> soundLevels) {
    /// 0.0 ~ 100.0
    if (mixerStreamDic.values.isEmpty) {
      return;
    }

    final targetMixerStream = mixerStreamDic.values.first;
    soundLevels.forEach((fromSoundLevelID, soundLevel) {
      targetMixerStream.userSoundIDs.forEach((userID, soundLevelID) {
        if (soundLevelID != fromSoundLevelID) {
          return;
        }

        final index = targetMixerStream.usersNotifier.value
            .indexWhere((user) => userID == user.id);
        if (-1 == index) {
          return;
        }

        targetMixerStream.usersNotifier.value
            .elementAt(index)
            .mainChannel
            .soundLevelStream
            ?.add(soundLevel);
      });
    });

    targetMixerStream.soundLevels?.add(soundLevels);
  }
}
