// Dart imports:
import 'dart:async';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/foundation.dart';
// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';
// Project imports:
import 'package:zego_uikit/src/channel/platform_interface.dart';
import 'package:zego_uikit/src/services/core/core.dart';
import 'package:zego_uikit/src/services/core/defines/defines.dart';
import 'package:zego_uikit/src/services/services.dart';

import 'data.dart';
import 'room.dart';
import 'screen_sharing.dart';
import 'stream.dart';
import 'stream.data.dart';
import 'user.dart';

/// Stream related information for a room
class ZegoUIKitCoreDataRoomStream {
  String roomID;

  ZegoUIKitCoreDataRoomStream(this.roomID);

  @override
  String toString() {
    return '{'
        'id:$roomID, '
        'streamDic keys:${streamDicNotifier.value.keys}, '
        'mixerStreamDic keys:${mixerStreamDic.keys}, '
        '}';
  }

  ZegoUIKitCoreData get _commonData => ZegoUIKitCore.shared.coreData;

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
  final streamDicNotifier =
      ValueNotifier<Map<String, ZegoUIKitCoreDataStreamData>>({});

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
      'room id:$roomID, '
      'init',
      tag: 'uikit.streams.room',
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
      'room id:$roomID, '
      'uninit',
      tag: 'uikit.streams.room',
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

  void clear({
    required bool stopPublishAllStream,
    required bool stopPlayAllStream,
  }) {
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'clear',
      tag: 'uikit.streams.room',
      subTag: 'clearStream',
    );

    if (_screenSharingCommonData.isScreenSharing.value) {
      _screenSharingCommonData.stopSharingScreen(
        targetRoomID: roomID,
      );
    }

    if (stopPlayAllStream) {
      stopPlayingAllStream();
    }

    if (stopPublishAllStream) {
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
    }

    isPublishing = false;
    isPlaying = false;
  }

  void clearDict() {
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'current keys:{${streamDicNotifier.value.keys}}, ',
      tag: 'uikit.streams.room',
      subTag: 'clearDict',
    );

    streamDicNotifier.value.clear();
  }

  ZegoUIKitCoreUser queryUser(String streamID) {
    final streamData = queryStream(streamID);
    if (streamData.isEmpty) {
      return ZegoUIKitCoreUser.empty();
    }

    return _userCommonData.roomUsers.getRoom(roomID).query(streamData.userID);
  }

  ZegoUIKitCoreDataStreamData queryStream(String streamID) {
    return streamDicNotifier.value[streamID] ??
        ZegoUIKitCoreDataStreamData.empty();
  }

  void addDataInDict(String streamID, ZegoUIKitCoreDataStreamData data) {
    final isExist = streamDicNotifier.value.keys.contains(streamID);

    streamDicNotifier.value[streamID] = data;

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'streamID:$streamID, '
      'data:{$data}, '
      'is exist now:$isExist, '
      'current keys:{${streamDicNotifier.value.keys}}, ',
      tag: 'uikit.streams.room',
      subTag: 'addDataInDict',
    );
  }

  void removeDataInDict(String streamID) {
    final previousKeys = streamDicNotifier.value.keys;

    streamDicNotifier.value.remove(streamID);

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'streamID:$streamID, '
      'previous keys:$previousKeys, '
      'current keys:{${streamDicNotifier.value}}, ',
      tag: 'uikit.streams.room',
      subTag: 'removeDataInDict',
    );
  }

  void removeDatasInDict(List<String> streamIDs) {
    final previousKeys = streamDicNotifier.value.keys;

    streamDicNotifier.value.removeWhere((key, data) => streamIDs.contains(key));

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'streamIDs:$streamIDs, '
      'previous keys:$previousKeys, '
      'current keys:{${streamDicNotifier.value.keys}}, ',
      tag: 'uikit.streams.room',
      subTag: 'removeDatasInDict',
    );
  }

  void updatePlayerStateInDict(String streamID, ZegoPlayerState playerState) {
    final streamUser = queryUser(streamID);
    final streamChannel = ZegoUIKitStreamHelper.getUserStreamChannel(
        streamUser, ZegoUIKitStreamHelper.getStreamTypeByID(streamID));
    if (playerState == streamChannel.playerStateNotifier.value) {
      return;
    }

    final previousState = streamChannel.playerStateNotifier.value;
    streamChannel.playerStateNotifier.value = playerState;

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'streamID:$streamID, '
      'playerState:$playerState, '
      'previous state:$previousState, '
      'current state:{${streamChannel.playerStateNotifier.value}, ',
      tag: 'uikit.streams.room',
      subTag: 'updatePlayerStateInDict',
    );

    /// notify outside to update audio video list
    ZegoUIKitCore.shared.coreData.stream.roomStreams
        .getRoom(roomID)
        .notifyStreamListControl(
          ZegoUIKitStreamHelper.getStreamTypeByID(streamID),
        );
  }

  void updatePublisherStateInDict(
    String streamID,
    ZegoPublisherState publisherState,
  ) {
    final streamUser = queryUser(streamID);
    final streamChannel = ZegoUIKitStreamHelper.getUserStreamChannel(
        streamUser, ZegoUIKitStreamHelper.getStreamTypeByID(streamID));
    if (publisherState == streamChannel.publisherStateNotifier.value) {
      return;
    }

    final previousState = streamChannel.publisherStateNotifier.value;
    streamChannel.publisherStateNotifier.value = publisherState;

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'streamID:$streamID, '
      'publisherState:$publisherState, '
      'previous state:$previousState, '
      'current state:{${streamChannel.publisherStateNotifier.value}}, ',
      tag: 'uikit.streams.room',
      subTag: 'updatePublisherStateInDict',
    );

    /// notify outside to update audio video list
    ZegoUIKitCore.shared.coreData.stream.roomStreams
        .getRoom(roomID)
        .notifyStreamListControl(
          ZegoUIKitStreamHelper.getStreamTypeByID(streamID),
        );
  }

  void updateIsAnotherRoomUserInDict(String streamID, bool isAnotherRoomUser) {
    final previousValue = streamDicNotifier.value[streamID]?.fromAnotherRoom;

    streamDicNotifier.value[streamID]?.fromAnotherRoom = isAnotherRoomUser;

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'streamID:$streamID, '
      'isAnotherRoomUser:$isAnotherRoomUser, '
      'previous value:$previousValue, '
      'current stream:{${streamDicNotifier.value[streamID]?.fromAnotherRoom}}, ',
      tag: 'uikit.streams.room',
      subTag: 'updateIsAnotherRoomUserInDict',
    );
  }

  Future<void> startPublishingStream({
    required ZegoStreamType streamType,
  }) async {
    final localUserStreamChannel = ZegoUIKitStreamHelper.getUserStreamChannel(
      _userCommonData.localUser,
      streamType,
    );

    if (isPublishing) {
      ///  stream id had generated, that mean is publishing
      ZegoLoggerService.logWarn(
        'hash:$hashCode, '
        'local user is publishing,'
        'channel:$localUserStreamChannel, ',
        tag: 'uikit.streams.room',
        subTag: 'start publish stream',
      );
      return;
    }

    isPublishing = true;

    final localUserStreamViewID =
        localUserStreamChannel.viewIDNotifier.value ?? -1;
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'updateConfigBeforeStartPublishingStream, '
      'view id:$localUserStreamViewID, ',
      tag: 'uikit.streams.room',
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
    addDataInDict(
        localUserStreamChannel.streamID,
        ZegoUIKitCoreDataStreamData(
          id: localUserStreamChannel.streamID,
          roomID: roomID,
          userID: _userCommonData.localUser.id,
          userName: _userCommonData.localUser.name,
        ));

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'stream dict add $streamType ${localUserStreamChannel.streamID} for ${_userCommonData.localUser.id}, '
      'now stream dict:${streamDicNotifier.value}, '
      'try start publish, '
      '${localUserStreamChannel.streamID}, '
      'network state:${ZegoUIKit().getNetworkState()}, '
      'isEnableCustomVideoRender:${_streamCommonData.isEnableCustomVideoRender}',
      tag: 'uikit.streams.room',
      subTag: 'start publish stream',
    );
    await ZegoExpressEngine.instance.startPublishingStream(
      localUserStreamChannel.streamID,
      channel: streamType.channel,
      config: ZegoPublisherConfig(roomID: roomID),
    );

    notifyStreamListControl(streamType);
  }

  Future<void> onViewCreatedByStartPublishingStream(
    ZegoStreamType streamType,
  ) async {
    final localTargetStreamViewID = ZegoUIKitStreamHelper.getUserStreamChannel(
          _userCommonData.localUser,
          streamType,
        ).viewIDNotifier.value ??
        -1;
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'onViewCreatedByStartPublishingStream, '
      'view id:$localTargetStreamViewID, ',
      tag: 'uikit.streams.room',
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
          'room id:$roomID, '
          'call express startPreview, for trace enableCustomVideoRender, '
          'isEnableCustomVideoRender:${_streamCommonData.isEnableCustomVideoRender}',
          tag: 'uikit.streams.room',
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

  Future<void> stopPublishingAllStream() async {
    for (var streamType in [
      ZegoStreamType.main,
      ZegoStreamType.media,
      ZegoStreamType.screenSharing,
      ZegoStreamType.mix,
    ]) {
      await stopPublishingStream(streamType: streamType);
    }
  }

  Future<void> stopPublishingStream({
    required ZegoStreamType streamType,
  }) async {
    final localUserStreamChannel = ZegoUIKitStreamHelper.getUserStreamChannel(
      _userCommonData.localUser,
      streamType,
    );
    final targetStreamID = localUserStreamChannel.streamID;
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'stop $streamType $targetStreamID}, '
      'network state:${ZegoUIKit().getNetworkState()}, ',
      tag: 'uikit.streams.room',
      subTag: 'stop publish stream',
    );

    if (targetStreamID.isEmpty) {
      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'room id:$roomID, '
        'stream id is empty',
        tag: 'uikit.streams.room',
        subTag: 'stop publish stream',
      );

      return;
    }

    if (_streamCommonData.canvasViewCreateQueue.currentTaskKey ==
        targetStreamID) {
      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'room id:$roomID, '
        'stopped canvas view queue',
        tag: 'uikit.streams.room',
        subTag: 'stop publish stream',
      );

      _streamCommonData.canvasViewCreateQueue.completeCurrentTask();
    }

    removeDataInDict(targetStreamID);
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'stream dict remove $targetStreamID, now stream dict:${streamDicNotifier.value}',
      tag: 'uikit.streams.room',
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
        'room is not login, '
        'room id: $roomID, '
        'state:${roomInfo.state}, ',
        tag: 'uikit.streams.room',
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
        'room id:$roomID, '
        'publishStreamList list, ${streamList.publishStreamList.map((e) => e.toStringX())},  '
        'playStreamList list, ${streamList.playStreamList.map((e) => e.toStringX())}',
        tag: 'uikit.streams.room',
        subTag: 'syncRoomStream',
      );

      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'room id:$roomID, '
        'put play stream list to onRoomStreamUpdate',
        tag: 'uikit.streams.room',
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
      'room id:$roomID, '
      'user id:  $userID, mute: $mute, '
      'for audio:$forAudio, for video:$forVideo',
      tag: 'uikit.streams.room',
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
        tag: 'uikit.streams.room',
        subTag: 'mute play stream audio video',
      );
      return false;
    }

    final targetUser = targetRoomRemoteUserList[targetUserIndex];
    if (targetUser.mainChannel.streamID.isEmpty) {
      ZegoLoggerService.logError(
        'hash:$hashCode, '
        "can't find $userID's stream",
        tag: 'uikit.streams.room',
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
      'room id:$roomID, '
      'muted: $isMuted, streamDic:${streamDicNotifier.value}',
      tag: 'uikit.streams.room',
      subTag: 'mute all play stream audio video',
    );

    isAllPlayStreamAudioVideoMuted = isMuted;
    await ZegoExpressEngine.instance
        .muteAllPlayStreamVideo(isAllPlayStreamAudioVideoMuted);
    await ZegoExpressEngine.instance
        .muteAllPlayStreamAudio(isAllPlayStreamAudioVideoMuted);

    for (var entry in streamDicNotifier.value.entries) {
      final streamID = entry.key;
      final streamInfo = entry.value;
      final streamUser = queryUser(streamID);
      final streamChannel = ZegoUIKitStreamHelper.getUserStreamChannel(
          streamUser, ZegoUIKitStreamHelper.getStreamTypeByID(streamID));

      if (isMuted) {
        if (ZegoPlayerState.Playing ==
            streamChannel.playerStateNotifier.value) {
          await stopPlayingStream(
            streamID,
            removeDic: false,
          );
        } else {
          ZegoLoggerService.logInfo(
            'hash:$hashCode, '
            'room id:$roomID, '
            'stream id($streamID) not playing(${streamChannel.playerStateNotifier.value}) now, waiting player state update',
            tag: 'uikit.streams.room',
            subTag: 'mute all play stream audio video',
          );
        }
      } else {
        if (_userCommonData.localUser.id != streamInfo.userID &&
            streamChannel.playerStateNotifier.value == ZegoPlayerState.NoPlay) {
          final previousStreamExtraInfo = extraInfo[streamID] ?? '';
          final targetUserIndex = _userCommonData.roomUsers
              .getRoom(roomID)
              .remoteUsers
              .indexWhere((user) => streamInfo.userID == user.id);
          ZegoLoggerService.logInfo(
            'hash:$hashCode, '
            'room id:$roomID, '
            'test, attempt to restore previous stream additional information, '
            'previousStreamExtraInfo:$previousStreamExtraInfo, '
            'targetUserIndex:$targetUserIndex',
            tag: 'uikit.streams.room',
            subTag: 'mute all play stream audio video',
          );
          if (previousStreamExtraInfo.isNotEmpty) {
            /// Load previous stream extra info first
            ZegoUIKitCore.shared.eventHandler.parseStreamExtraInfo(
              roomID: roomID,
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
      'room id:$roomID, '
      'muted: $isMuted, streamDic:${streamDicNotifier.value}',
      tag: 'uikit.streams.room',
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
        'room id:$roomID, '
        'targetUserIndex is invalid, '
        'streamID: $streamID, '
        'user id: $streamUserID, ',
        tag: 'uikit.streams.room',
        subTag: 'start play stream',
      );

      return;
    }

    final targetUser = targetRoomRemoteUserList[targetUserIndex];
    final streamType = ZegoUIKitStreamHelper.getStreamTypeByID(streamID);

    final targetUserStreamChannel = ZegoUIKitStreamHelper.getUserStreamChannel(
      targetUser,
      streamType,
    );

    if (targetUserStreamChannel.viewCreatingNotifier.value ||
        targetUserStreamChannel.viewIDNotifier.value != -1 ||
        targetUserStreamChannel.viewNotifier.value != null) {
      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'room id:$roomID, '
        'streamID: $streamID, '
        'userID: $streamUserID, '
        'view:${targetUserStreamChannel.viewNotifier.value}, '
        'viewID:${targetUserStreamChannel.viewIDNotifier.value}, '
        'viewCreating:${targetUserStreamChannel.viewCreatingNotifier.value}, '
        'view is create, ignore',
        tag: 'uikit.streams.room',
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
          'room id:$roomID, '
          'streamID: $streamID, userID: $streamUserID, '
          'add to queue',
          tag: 'uikit.streams.room',
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
      'room id:$roomID, '
      'streamID: $streamID, '
      'user id: $streamUserID, ',
      tag: 'uikit.streams.room',
      subTag: 'start play stream',
    );

    final remoteUserList =
        _userCommonData.roomUsers.getRoom(roomID).remoteUsers;
    final targetUserIndex =
        remoteUserList.indexWhere((user) => streamUserID == user.id);
    assert(-1 != targetUserIndex);
    final targetUser = remoteUserList[targetUserIndex];
    final streamType = ZegoUIKitStreamHelper.getStreamTypeByID(streamID);

    final targetUserStreamChannel = ZegoUIKitStreamHelper.getUserStreamChannel(
      targetUser,
      streamType,
    );
    targetUserStreamChannel
      ..streamID = streamID
      ..streamTimestamp =
          ZegoUIKitCore.shared.coreData.timestamp.now.millisecondsSinceEpoch;

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'current stream channel, '
      'view id:${targetUserStreamChannel.viewIDNotifier.value},'
      'view:${targetUserStreamChannel.viewNotifier}',
      tag: 'uikit.streams.room',
      subTag: 'start play stream',
    );

    await playStreamOnViewWillCreated(streamChannel: targetUserStreamChannel);

    if (targetUserStreamChannel.viewIDNotifier.value != -1 &&
        targetUserStreamChannel.viewNotifier.value != null) {
      final viewID = targetUserStreamChannel.viewIDNotifier.value ?? -1;

      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'room id:$roomID, '
        'canvas view had created before, directly call callback, '
        'viewID:$viewID, '
        'user id: $streamUserID, '
        'stream id:$streamID, ',
        tag: 'uikit.streams.room',
        subTag: 'start play stream',
      );

      if (_streamCommonData.isCanvasViewCreateByQueue) {
        _streamCommonData.canvasViewCreateQueue.completeCurrentTask();
      }

      await updatePlayingStreamViewCanvasOnViewCreated(
        streamID: streamID,
        viewID: viewID,
        streamType: streamType,
      );
    } else {
      targetUserStreamChannel.viewCreatingNotifier.value = true;

      await _streamCommonData.createCanvasViewByExpressWithCompleter(
        (viewID) async {
          ZegoLoggerService.logInfo(
            'hash:$hashCode, '
            'room id:$roomID, '
            'canvas view id done '
            'viewID:$viewID, '
            'user id: $streamUserID, '
            'stream id:$streamID, ',
            tag: 'uikit.streams.room',
            subTag: 'start play stream',
          );

          ZegoUIKitStreamHelper.getUserStreamChannel(targetUser, streamType)
            ..viewCreatingNotifier.value = false
            ..viewIDNotifier.value = viewID;

          await updatePlayingStreamViewCanvasOnViewCreated(
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
          'room id:$roomID, '
          'widget done, '
          'widget:$widget ${widget.hashCode}, '
          'user id: $streamUserID, '
          'stream id:$streamID, ',
          tag: 'uikit.streams.room',
          subTag: 'start play stream',
        );

        ZegoUIKitStreamHelper.getUserStreamChannel(
          targetUser,
          streamType,
        ).viewNotifier.value = widget;

        notifyStreamListControl(streamType);
      });
    }
  }

  Future<void> startPlayingStreamByExpress({
    required ZegoUIKitCoreStreamInfo streamChannel,
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
      'room id:$roomID, '
      'channel:$streamChannel, '
      'startPlayingStreamInIOSPIP:$startPlayingStreamInIOSPIP, ',
      tag: 'uikit.streams.room',
      subTag: 'start play stream by express',
    );

    if (null != onPlayerStateUpdated) {
      if (playerStateUpdateCallbackList.containsKey(streamChannel.streamID)) {
        playerStateUpdateCallbackList[streamChannel.streamID]!
            .add(onPlayerStateUpdated);
      } else {
        playerStateUpdateCallbackList[streamChannel.streamID] = [
          onPlayerStateUpdated
        ];
      }
    }

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'call express startPlayingStream, for trace enableCustomVideoRender, '
      'isEnableCustomVideoRender:${_streamCommonData.isEnableCustomVideoRender}',
      tag: 'uikit.streams.room',
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
        streamChannel.streamID,
        resourceMode: config?.resourceMode.index,
        roomID: config?.roomID,
        cdnConfig: cdnConfigMap,
        videoCodecID: config?.videoCodecID?.index,
      )
          .then(
        (_) {
          ZegoLoggerService.logInfo(
            'hash:$hashCode, '
            'room id:$roomID, '
            'finish play stream in ios with pip, '
            'channel: $streamChannel, ',
            tag: 'uikit.streams.room',
            subTag: 'start play stream',
          );
        },
      );
    } else {
      await ZegoExpressEngine.instance
          .startPlayingStream(
        streamChannel.streamID,
        canvas: null,
        config: config,
      )
          .then((value) {
        isPlaying = true;

        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'room id:$roomID, '
          'finish play, '
          'channel: $streamChannel, ',
          tag: 'uikit.streams.room',
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
      'room id:$roomID, '
      'stream id:$streamID, '
      'stopPlayingStreamInIOSPIP:$stopPlayingStreamInIOSPIP, ',
      tag: 'uikit.streams.room',
      subTag: 'stop play stream by express',
    );

    if (stopPlayingStreamInIOSPIP) {
      ZegoUIKitPluginPlatform.instance
          .stopPlayingStreamInPIP(streamID)
          .then((_) {
        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'room id:$roomID, '
          'stop play done in ios with pip, '
          'streamID: $streamID, ',
          tag: 'uikit.streams.room',
          subTag: 'stop play stream',
        );
      });
    } else {
      await ZegoExpressEngine.instance.stopPlayingStream(streamID).then((_) {
        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'room id:$roomID, '
          'stop play done, '
          'streamID: $streamID, ',
          tag: 'uikit.streams.room',
          subTag: 'stop play stream',
        );
      });
    }
  }

  Future<void> updatePlayingStreamViewCanvasOnViewCreated({
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
    final updateCanvas = canvas ??
        ZegoCanvas(
          viewID,
          viewMode: viewMode,
        );

    bool startPlayingStreamInIOSPIP = false;
    if (Platform.isIOS) {
      startPlayingStreamInIOSPIP =
          ZegoUIKitCore.shared.coreData.stream.playingStreamInPIPUnderIOS;

      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'room id:$roomID, '
        'isPlayingStreamInIOSPIP:$startPlayingStreamInIOSPIP, ',
        tag: 'uikit.streams.room',
        subTag: 'start play stream',
      );
    }

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'ready start, '
      'streamID: $streamID, '
      'view mode:$viewMode(${viewMode.index}), ',
      tag: 'uikit.streams.room',
      subTag: 'start play stream',
    );

    if (startPlayingStreamInIOSPIP) {
      ZegoUIKitPluginPlatform.instance
          .updatePlayingStreamViewInPIP(viewID, streamID, viewMode.index)
          .then((_) {
        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'room id:$roomID, '
          'finish update stream view/canvas in ios with pip, '
          'stream id:$streamID, '
          'view id:$viewID, ',
          tag: 'uikit.streams.room',
          subTag: 'start play stream',
        );
      });
    } else {
      await ZegoExpressEngine.instance
          .updatePlayingCanvas(streamID, updateCanvas)
          .then((value) {
        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'room id:$roomID, '
          'finish update stream view/canvas, '
          'streamID: $streamID, '
          'canvas:$updateCanvas, ',
          tag: 'uikit.streams.room',
          subTag: 'start play stream',
        );
      });
    }
  }

  Future<void> playStreamOnViewWillCreated({
    required ZegoUIKitCoreStreamInfo streamChannel,
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
      'room id:$roomID, '
      'ready start, '
      'channel: $streamChannel',
      tag: 'uikit.streams.room',
      subTag: 'start play stream',
    );

    await startPlayingStreamByExpress(
      streamChannel: streamChannel,
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
          ZegoUIKitStreamHelper.getUserStreamChannel(user, streamType)
              .streamID) {
        if (user.camera.value) {
          return;
        }

        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'room id:$roomID, '
          'user($user) camera is close, try stopped canvas view queue',
          tag: 'uikit.streams.room',
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
      'room id:$roomID, '
      'ready stop streamID: $streamID',
      tag: 'uikit.streams.room',
      subTag: 'stop play stream',
    );
    assert(streamID.isNotEmpty);

    // stop playing stream
    await stopPlayingStreamByExpress(streamID);

    final targetUserID = streamDicNotifier.value.containsKey(streamID)
        ? streamDicNotifier.value[streamID]!.userID
        : '';
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'stopped, stream id $streamID, user id  is: $targetUserID',
      tag: 'uikit.streams.room',
      subTag: 'stop play stream',
    );

    final targetRoomRemoteUserList =
        _userCommonData.roomUsers.getRoom(roomID).remoteUsers;
    final targetUserIndex =
        targetRoomRemoteUserList.indexWhere((user) => targetUserID == user.id);
    if (-1 != targetUserIndex) {
      final targetUser = targetRoomRemoteUserList[targetUserIndex];
      final streamType = ZegoUIKitStreamHelper.getStreamTypeByID(streamID);

      if (_streamCommonData.canvasViewCreateQueue.currentTaskKey ==
          ZegoUIKitStreamHelper.getUserStreamChannel(
            targetUser,
            streamType,
          ).streamID) {
        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'room id:$roomID, '
          'stopped canvas view queue',
          tag: 'uikit.streams.room',
          subTag: 'stop play stream',
        );

        _streamCommonData.canvasViewCreateQueue.completeCurrentTask();
      }

      ZegoUIKitStreamHelper.getUserStreamChannel(targetUser, streamType)
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
      removeDataInDict(streamID);
      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'room id:$roomID, '
        'stream dict remove $streamID, ${streamDicNotifier.value}',
        tag: 'uikit.streams.room',
        subTag: 'stop play stream',
      );
    }
  }

  List<ZegoUIKitCoreUser> getAudioVideoList({
    ZegoStreamType streamType = ZegoStreamType.main,
    bool onlyCurrentRoom = true,
  }) {
    return streamDicNotifier.value.entries
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
        return false;
      }

      if (onlyCurrentRoom) {
        if (user.fromAnotherRoom) {
          return false;
        }
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

  void addPlayingStreamDataInDict({
    required ZegoUIKitCoreDataStreamData streamData,
    required ZegoUIKitCoreUser streamUser,
    required bool isFromAnotherRoom,
  }) {
    addDataInDict(streamData.id, streamData);
    updateIsAnotherRoomUserInDict(streamData.id, isFromAnotherRoom);

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'stream dict add/update ${streamData.id} for ${streamData.userID}, '
      'dict: ${streamDicNotifier.value}',
      tag: 'uikit.streams.room',
      subTag: 'addPlayingStreamDataInDict',
    );

    final targetRemoteUserList =
        _userCommonData.roomUsers.getRoom(roomID).remoteUsers;
    var targetUserIndex =
        targetRemoteUserList.indexWhere((user) => streamData.userID == user.id);
    if (-1 != targetUserIndex) {
      /// Update
      streamUser.copyAttributesFromOther(targetRemoteUserList[targetUserIndex]);
      targetRemoteUserList.removeAt(targetUserIndex);
    }
    streamUser.fromAnotherRoom = isFromAnotherRoom;
    targetRemoteUserList.add(streamUser);

    final streamType = ZegoUIKitStreamHelper.getStreamTypeByID(streamData.id);
    final targetUserStreamChannel = ZegoUIKitStreamHelper.getUserStreamChannel(
      streamUser,
      streamType,
    );
    targetUserStreamChannel.streamID = streamData.id;
    if (targetUserStreamChannel.streamTimestamp <= 0) {
      targetUserStreamChannel.streamTimestamp =
          _commonData.timestamp.now.millisecondsSinceEpoch;
    }
  }

  Future<void> stopPlayingAllStream({
    List<String> ignoreStreamIDs = const [],
  }) async {
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'ignoreStreamIDs:$ignoreStreamIDs, ',
      tag: 'uikit.streams.room',
      subTag: 'stop play all stream',
    );

    final currentRoomUserInfo = _userCommonData.roomUsers.getRoom(roomID);
    for (final user in currentRoomUserInfo.remoteUsers) {
      if (!ignoreStreamIDs.contains(user.mainChannel.streamID)) {
        if (user.mainChannel.streamID.isNotEmpty) {
          stopPlayingStream(user.mainChannel.streamID);
        }
        user.destroyTextureRenderer(streamType: ZegoStreamType.main);
      }

      if (!ignoreStreamIDs.contains(user.auxChannel.streamID)) {
        if (user.auxChannel.streamID.isNotEmpty) {
          stopPlayingStream(user.auxChannel.streamID);
        }
        user.destroyTextureRenderer(streamType: ZegoStreamType.screenSharing);
      }
    }

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'dict:${streamDicNotifier.value}, ',
      tag: 'uikit.streams.room',
      subTag: 'stop play all stream',
    );
  }

  void transferToAnotherRoom({
    required List<String> fromStreamIDs,
    required String toRoomID,
    required bool isFromAnotherRoom,
    required bool isMove,
  }) {
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'fromStreamIDs:$fromStreamIDs, '
      'toRoomID:$toRoomID, '
      'isMove:$isMove, '
      'before dict:${streamDicNotifier.value}, ',
      tag: 'uikit.streams.room',
      subTag: 'transfer to another room',
    );

    final currentRoomUserInfo = _userCommonData.roomUsers.getRoom(roomID);
    for (var fromStreamID in fromStreamIDs) {
      final fromStreamData = streamDicNotifier.value[fromStreamID];
      if (null == fromStreamData) {
        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'room id:$roomID, '
          'fromStreamID is not exist, ',
          tag: 'uikit.streams.room',
          subTag: 'transfer to another room',
        );

        continue;
      }

      final currentRoomUser = currentRoomUserInfo.query(fromStreamData.userID);
      _streamCommonData.roomStreams
          .getRoom(toRoomID)
          .addPlayingStreamDataInDict(
            /// copy object
            streamData: fromStreamData,
            streamUser: currentRoomUser,
            isFromAnotherRoom: isFromAnotherRoom,
          );
      if (isMove) {
        fromStreamData.roomID = toRoomID;
        currentRoomUser.roomID = toRoomID;

        currentRoomUserInfo.remove(fromStreamData.userID);
        removeDataInDict(fromStreamID);
      }
    }
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'after dict:${streamDicNotifier.value}, ',
      tag: 'uikit.streams.room',
      subTag: 'transfer to another room',
    );
  }

  Future<void> startPlayingAnotherRoomStream(
    String streamRoomID,
    String streamUserID,
    String streamUserName, {
    PlayerStateUpdateCallback? onPlayerStateUpdated,
  }) async {
    final streamID = generateStreamID(
      streamUserID,
      streamRoomID,
      ZegoStreamType.main,
    );

    /// addPlayingStreamDataInDict will add user
    addPlayingStreamDataInDict(
      streamUser: ZegoUIKitCoreUser(
        streamUserID,
        streamUserName,
        streamRoomID,
        roomID != streamRoomID,
      ),
      streamData: ZegoUIKitCoreDataStreamData(
        id: streamID,
        roomID: streamRoomID,
        userID: streamUserID,
        userName: streamUserName,
        fromAnotherRoom: streamRoomID != roomID,
      ),
      isFromAnotherRoom: roomID != streamRoomID,
    );

    var streamUser =
        _userCommonData.roomUsers.getRoom(roomID).query(streamUserID);
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'stream id:$streamID, '
      'stream user:$streamUser,  '
      'stream room id:$streamRoomID, '
      'playerState:${streamUser.mainChannel.playerStateNotifier.value}'
      'view:${streamUser.mainChannel.viewNotifier.value}, '
      'viewID:${streamUser.mainChannel.viewIDNotifier.value}',
      tag: 'uikit.streams.room',
      subTag: 'start play another room stream',
    );

    if (null == streamUser.mainChannel.viewNotifier.value ||
        -1 == streamUser.mainChannel.viewIDNotifier.value) {
      /// Not pulling stream
      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'room id:$roomID, '
        'stream id:$streamID, '
        'stream user:$streamUser,  '
        'stream room id:$streamRoomID, ',
        tag: 'uikit.streams.room',
        subTag: 'start play another room stream',
      );

      await playStreamOnViewWillCreated(
        streamChannel: ZegoUIKitStreamHelper.getUserStreamChannel(
          streamUser,
          ZegoStreamType.main,
        ),
        onPlayerStateUpdated: onPlayerStateUpdated,
      );

      await ZegoExpressEngine.instance.createCanvasView((viewID) async {
        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'room id:$roomID, '
          'stream id:$streamID, '
          'stream user:$streamUser,  '
          'stream room id:$streamRoomID, '
          'createCanvasView onViewCreated, '
          'viewID:$viewID, ',
          tag: 'uikit.streams.room',
          subTag: 'start play another room stream',
        );

        streamUser.mainChannel.viewIDNotifier.value = viewID;

        final canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
        await updatePlayingStreamViewCanvasOnViewCreated(
          streamID: streamID,
          viewID: viewID,
          canvas: canvas,
        );
      }).then((widget) {
        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'room id:$roomID, '
          'stream id:$streamID, '
          'stream user:$streamUser,  '
          'stream room id:$streamRoomID, '
          'createCanvasView done, '
          'widget:$widget, ',
          tag: 'uikit.streams.room',
          subTag: 'start play another room stream',
        );

        assert(widget != null);
        streamUser.mainChannel.viewNotifier.value = widget;

        notifyStreamListControl(ZegoStreamType.main);
        _userCommonData.notifyUserListStreamControl(
          targetRoomID: roomID,
        );
      });
    } else {
      /// Already pulling stream
      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'room id:$roomID, '
        'stream id:$streamID, '
        'stream user:$streamUser,  '
        'stream room id:$streamRoomID, '
        'stream is playing',
        tag: 'uikit.streams.room',
        subTag: 'start play another room stream',
      );
    }
  }

  Future<void> stopPlayingAnotherRoomStream(
    String userID,
  ) async {
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'user id: $userID',
      tag: 'uikit.streams.room',
      subTag: 'stop play another room stream',
    );

    final currentRoomRemoteUserList =
        _userCommonData.roomUsers.getRoom(roomID).remoteUsers;

    final remoteUserCurrentRoomListIndex = currentRoomRemoteUserList.indexWhere(
      (user) => userID == user.id,
    );
    if (-1 == remoteUserCurrentRoomListIndex) {
      ZegoLoggerService.logWarn(
        'hash:$hashCode, '
        "can't find this user, userID: $userID",
        tag: 'uikit.streams.room',
        subTag: 'stop play another room stream',
      );

      return;
    }

    final targetUser =
        currentRoomRemoteUserList[remoteUserCurrentRoomListIndex];

    final streamID = currentRoomRemoteUserList[remoteUserCurrentRoomListIndex]
        .mainChannel
        .streamID;
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

    removeDataInDict(streamID);
    currentRoomRemoteUserList.removeWhere((user) => userID == user.id);
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'stopped, userID: $userID, stream id:$streamID',
      tag: 'uikit.streams.room',
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
      'room id:$roomID, '
      'mixerID:$mixerID, users:$users, userSoundIDs:$userSoundIDs',
      tag: 'uikit.mixstream',
      subTag: 'start play mix audio video',
    );

    if (mixerStreamDic.containsKey(mixerID)) {
      for (ZegoUIKitCoreUser user in users) {
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
        streamChannel: ZegoUIKitCoreStreamInfo.empty()..streamID = mixerID,
        onPlayerStateUpdated: onPlayerStateUpdated,
      );

      ZegoExpressEngine.instance.createCanvasView((viewID) async {
        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'room id:$roomID, '
          'createCanvasView onViewCreated, '
          'viewID:$viewID, ',
          tag: 'uikit.mixstream',
          subTag: 'start play mix audio video',
        );

        mixerStreamDic[mixerID]!.viewID = viewID;

        final canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
        await updatePlayingStreamViewCanvasOnViewCreated(
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
    if (!mixerStreamDic.containsKey(mixerID)) {
      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'not contain, ignore, ',
        tag: 'uikit.mixstream',
        subTag: 'stop play mix audio video',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID, '
      'mixerID:$mixerID',
      tag: 'uikit.mixstream',
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
