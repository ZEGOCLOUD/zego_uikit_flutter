// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
// Project imports:
import 'package:zego_uikit/src/services/core/core.dart';
import 'package:zego_uikit/src/services/services.dart';

import 'data/data.dart';
import 'data/stream.data.dart';
import 'defines/defines.dart';

/// @nodoc
mixin ZegoUIKitCoreEventHandler {
  final _eventHandlerImpl = ZegoUIKitCoreEventHandlerImpl();

  ZegoUIKitCoreEventHandlerImpl get eventHandler => _eventHandlerImpl;
}

/// @nodoc
class ZegoUIKitCoreEventHandlerImpl extends ZegoUIKitExpressEventInterface {
  final Connectivity _connectivity = Connectivity();

  ZegoUIKitCoreData get coreData => ZegoUIKitCore.shared.coreData;

  Future<void> initConnectivity() async {
    ZegoLoggerService.logInfo(
      ', ',
      tag: 'uikit.service.event-handler',
      subTag: 'initConnectivity',
    );

    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      ZegoLoggerService.logInfo(
        'exception:$e',
        tag: 'uikit.service.event-handler',
        subTag: 'initConnectivity',
      );

      return;
    }

    _onConnectivityChanged(result);

    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  Future<void> _onConnectivityChanged(List<ConnectivityResult> result) async {
    ZegoLoggerService.logInfo(
      'result:$result, '
      'network state:${coreData.networkStateNotifier.value}',
      tag: 'uikit.service.event-handler',
      subTag: 'onConnectivityChanged',
    );

    coreData.networkStateNotifier.value =
        (result.contains(ConnectivityResult.mobile) ||
                result.contains(ConnectivityResult.wifi) ||
                result.contains(ConnectivityResult.ethernet))
            ? ZegoUIKitNetworkState.online
            : ZegoUIKitNetworkState.offline;

    coreData.networkStateStreamCtrl?.add(coreData.networkStateNotifier.value);
  }

  @override
  void onEngineStateUpdate(ZegoEngineState state) {
    ZegoLoggerService.logInfo(
      'state:$state, ',
      tag: 'uikit.service.event-handler',
      subTag: 'onEngineStateUpdate',
    );

    coreData.engine.stateNotifier.value = state;

    coreData.engine.stateStreamCtrl.add(coreData.engine.stateNotifier.value);

    if (ZegoEngineState.Start == state) {
      ZegoExpressEngine.instance.getAudioRouteType().then((value) {
        ZegoLoggerService.logInfo(
          'update audio route by onEngineStateUpdate, '
          'state:$state, ',
          tag: 'uikit.service.event-handler',
          subTag: 'onEngineStateUpdate',
        );

        coreData.user.localUser.initAudioRoute(value);
      });
    }
  }

  @override
  Future<void> onRoomStreamUpdate(
    String roomID,
    ZegoUpdateType updateType,
    List<ZegoStream> streamList,
    Map<String, dynamic> extendedData,
  ) async {
    ZegoLoggerService.logInfo(
      'roomID:$roomID, update type:$updateType'
      ", stream list:${streamList.map((e) => e.toStringX())},"
      ' extended data:$extendedData',
      tag: 'uikit.service.event-handler',
      subTag: 'onRoomStreamUpdate',
    );

    final targetRoomStreamInfo = coreData.stream.roomStreams.getRoom(roomID);
    if (updateType == ZegoUpdateType.Add) {
      for (final stream in streamList) {
        var targetUser = coreData.user.roomUsers.getRoom(roomID).query(
              stream.user.userID,
            );
        if (targetUser.isEmpty) {
          targetUser = ZegoUIKitCoreUser.fromZego(
            stream.user,
            roomID: roomID,
            isAnotherRoomUser: coreData.room.currentID != roomID,
          );
        }
        if (targetUser.name.isEmpty) {
          targetUser.name = stream.user.userName;
        }
        targetRoomStreamInfo.addPlayingStreamDataInDict(
          streamUser: targetUser,
          streamData: ZegoUIKitCoreDataStreamData(
            id: stream.streamID,
            roomID: roomID,
            userID: stream.user.userID,
            userName: stream.user.userName,
            fromAnotherRoom: false,
          ),
          isFromAnotherRoom: false,
        );

        if (targetRoomStreamInfo.isAllPlayStreamAudioVideoMuted) {
          ZegoLoggerService.logInfo(
            'audio video is not play enabled, user id:${stream.user.userID}, stream id:${stream.streamID}',
            tag: 'uikit.service.event-handler',
            subTag: 'onRoomStreamUpdate',
          );
        } else {
          await targetRoomStreamInfo.startPlayingStreamQueue(
            stream.streamID,
            stream.user.userID,
          );
        }
      }

      onRoomStreamExtraInfoUpdate(roomID, streamList);
    } else {
      for (final stream in streamList) {
        targetRoomStreamInfo.stopPlayingStream(stream.streamID);
      }
    }

    final streamIDs = streamList.map((e) => e.streamID).toList();
    if (-1 !=
        streamIDs.indexWhere(
            (streamID) => streamID.endsWith(ZegoStreamType.main.text))) {
      targetRoomStreamInfo.audioVideoListStreamCtrl
          ?.add(targetRoomStreamInfo.getAudioVideoList());
    }
    if (-1 !=
        streamIDs.indexWhere((streamID) =>
            streamID.endsWith(ZegoStreamType.screenSharing.text))) {
      coreData.screenSharing.screenSharingListStreamCtrl
          ?.add(targetRoomStreamInfo.getAudioVideoList(
        streamType: ZegoStreamType.screenSharing,
      ));
    }
    if (-1 !=
        streamIDs.indexWhere(
            (streamID) => streamID.endsWith(ZegoStreamType.media.text))) {
      coreData.media.mediaListStreamCtrl
          ?.add(targetRoomStreamInfo.getAudioVideoList(
        streamType: ZegoStreamType.media,
      ));
    }
  }

  @override
  void onRoomUserUpdate(
    String roomID,
    ZegoUpdateType updateType,
    List<ZegoUser> userList,
  ) {
    final targetRoomInfo = coreData.room.rooms.getRoom(roomID);

    ZegoLoggerService.logInfo(
      'room id:"$roomID", '
      'update type:$updateType, '
      "user list:${userList.map((user) => '"${user.userID}":${user.userName}, ')}",
      tag: 'uikit.service.event-handler',
      subTag: 'onRoomUserUpdate',
    );

    final targetRoomUserInfo = coreData.user.roomUsers.getRoom(roomID);
    if (updateType == ZegoUpdateType.Add) {
      for (final user in userList) {
        final targetUserIndex = targetRoomUserInfo.remoteUsers
            .indexWhere((e) => user.userID == e.id);
        if (-1 != targetUserIndex) {
          continue;
        }

        targetRoomUserInfo.remoteUsers.add(ZegoUIKitCoreUser.fromZego(
          user,
          roomID: roomID,
          isAnotherRoomUser: coreData.room.currentID != roomID,
        ));
      }

      if (targetRoomUserInfo.remoteUsers.length >= 499) {
        /// turn to be a large room after more than 500 people, even if less than 500 people behind
        ZegoLoggerService.logInfo(
          'users is more than 500, turn to be a large room',
          tag: 'uikit.service.event-handler',
          subTag: 'onRoomUserUpdate',
        );
        targetRoomInfo.isLargeRoom = true;
      }

      targetRoomUserInfo.joinStreamCtrl?.add(
        userList
            .map((e) => ZegoUIKitCoreUser.fromZego(
                  e,
                  roomID: roomID,
                  isAnotherRoomUser: coreData.room.currentID != roomID,
                ))
            .toList(),
      );
    } else {
      for (final user in userList) {
        coreData.user.removeUser(
          user.userID,
          targetRoomID: roomID,
        );
      }

      targetRoomUserInfo.leaveStreamCtrl?.add(userList
          .map((e) => ZegoUIKitCoreUser.fromZego(
                e,
                roomID: roomID,
                isAnotherRoomUser: coreData.room.currentID != roomID,
              ))
          .toList());
    }

    final allUserList = [
      coreData.user.localUser,
      ...targetRoomUserInfo.remoteUsers
    ];
    targetRoomUserInfo.listStreamCtrl?.add(allUserList);
  }

  @override
  void onRoomTokenWillExpire(
    String roomID,
    int remainTimeInSecond,
  ) {
    final targetRoomInfo = coreData.room.rooms.getRoom(roomID);

    ZegoLoggerService.logInfo(
      'room id:$roomID, '
      'remainTimeInSecond:$remainTimeInSecond',
      tag: 'uikit.service.event-handler',
      subTag: 'onRoomTokenWillExpire',
    );

    if (targetRoomInfo.id == roomID) {
      targetRoomInfo.tokenExpiredStreamCtrl?.add(remainTimeInSecond);
    } else {
      ZegoLoggerService.logWarn(
        'room ID($roomID) is not same as current room id(${targetRoomInfo.id})',
        tag: 'uikit.service.event-handler',
        subTag: 'onRoomTokenWillExpire',
      );
    }
  }

  @override
  void onPublisherStateUpdate(
    String streamID,
    ZegoPublisherState state,
    int errorCode,
    Map<String, dynamic> extendedData,
  ) {
    final targetRoomID = coreData.stream.queryRoomIDByStreamID(streamID) ??
        coreData.room.currentID;
    final targetRoomStream = coreData.stream.roomStreams.getRoom(targetRoomID);

    ZegoLoggerService.logInfo(
      'room id:$targetRoomID, '
      'stream id:$streamID, '
      'state:$state, '
      'errorCode:$errorCode, '
      'extendedData:$extendedData',
      tag: 'uikit.service.event-handler',
      subTag: 'onPublisherStateUpdate',
    );

    targetRoomStream.updatePublisherStateInDict(streamID, state);

    if (ZegoErrorCode.CommonSuccess != errorCode &&
        ZegoErrorCode.RoomManualKickedOut != errorCode) {
      coreData.error.errorStreamCtrl?.add(
        ZegoUIKitError(
          code: errorCode,
          message: 'state:${state.name}, extended data:$extendedData',
          method: 'express-api:onPublisherStateUpdate',
        ),
      );
    }
  }

  @override
  void onPublisherQualityUpdate(
    String streamID,
    ZegoPublishStreamQuality quality,
  ) {
    ZegoUIKitStreamHelper.getUserStreamChannel(
      ZegoUIKitCore.shared.coreData.user.localUser,
      ZegoUIKitStreamHelper.getStreamTypeByID(streamID),
    ).qualityNotifier.value = quality;
  }

  @override
  void onPublisherCapturedAudioFirstFrame() {
    ZegoUIKitStreamHelper.getUserStreamChannel(
      ZegoUIKitCore.shared.coreData.user.localUser,
      ZegoStreamType.main,
    ).isCapturedAudioFirstFrameNotifier.value = true;
  }

  @override
  void onPublisherCapturedVideoFirstFrame(ZegoPublishChannel channel) {
    ZegoUIKitStreamHelper.getUserStreamChannel(
      ZegoUIKitCore.shared.coreData.user.localUser,
      ZegoUIKitStreamHelper.getStreamTypeByZegoPublishChannel(
        ZegoUIKitCore.shared.coreData.user.localUser,
        channel,
      ),
    ).isCapturedVideoFirstFrameNotifier.value = true;

    try {
      /// onPublisherRenderVideoFirstFrame only once callback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ZegoUIKitStreamHelper.getUserStreamChannel(
          ZegoUIKitCore.shared.coreData.user.localUser,
          ZegoUIKitStreamHelper.getStreamTypeByZegoPublishChannel(
            ZegoUIKitCore.shared.coreData.user.localUser,
            channel,
          ),
        ).isRenderedVideoFirstFrameNotifier.value = true;
      });
    } catch (e) {
      ZegoLoggerService.logInfo(
        'set isRenderedVideoFirstFrame error:$e',
        tag: 'uikit.component',
        subTag: 'onPublisherCapturedVideoFirstFrame',
      );
    }
  }

  @override
  void onPublisherRenderVideoFirstFrame(ZegoPublishChannel channel) {
    ZegoUIKitStreamHelper.getUserStreamChannel(
      ZegoUIKitCore.shared.coreData.user.localUser,
      ZegoUIKitStreamHelper.getStreamTypeByZegoPublishChannel(
        ZegoUIKitCore.shared.coreData.user.localUser,
        channel,
      ),
    ).isRenderedVideoFirstFrameNotifier.value = true;
  }

  @override
  void onPublisherSendAudioFirstFrame(ZegoPublishChannel channel) {
    ZegoUIKitStreamHelper.getUserStreamChannel(
      ZegoUIKitCore.shared.coreData.user.localUser,
      ZegoUIKitStreamHelper.getStreamTypeByZegoPublishChannel(
        ZegoUIKitCore.shared.coreData.user.localUser,
        channel,
      ),
    ).isSendAudioFirstFrameNotifier.value = true;
  }

  @override
  void onPublisherSendVideoFirstFrame(ZegoPublishChannel channel) {
    ZegoUIKitStreamHelper.getUserStreamChannel(
      ZegoUIKitCore.shared.coreData.user.localUser,
      ZegoUIKitStreamHelper.getStreamTypeByZegoPublishChannel(
        ZegoUIKitCore.shared.coreData.user.localUser,
        channel,
      ),
    ).isSendVideoFirstFrameNotifier.value = true;
  }

  @override
  void onPlayerStateUpdate(
    String streamID,
    ZegoPlayerState state,
    int errorCode,
    Map<String, dynamic> extendedData,
  ) {
    final outputLog =
        errorCode != ZegoUIKitExpressErrorCode.PlayerErrorNetworkInterrupt;
    if (outputLog) {
      /// PlayerErrorNetworkInterrupt is thrown too frequently, don't print log
      ZegoLoggerService.logInfo(
        'stream id:$streamID, '
        'state:$state, '
        'errorCode:$errorCode, '
        'extendedData:$extendedData, ',
        tag: 'uikit.service.event-handler',
        subTag: 'onPlayerStateUpdate',
      );
    }

    coreData.stream.roomStreams.forEachSync((roomID, roomStream) {
      /// Stream may have been copied or transferred to other rooms, so update all
      if (!roomStream.streamDicNotifier.value.containsKey(streamID)) {
        return;
      }

      if (outputLog) {
        /// PlayerErrorNetworkInterrupt is thrown too frequently, don't print log
        ZegoLoggerService.logInfo(
          'isAllPlayStreamAudioVideoMuted:${roomStream.isAllPlayStreamAudioVideoMuted}, '
          'isAllPlayStreamAudioMuted:${roomStream.isAllPlayStreamAudioMuted}, ',
          tag: 'uikit.service.event-handler',
          subTag: 'onPlayerStateUpdate',
        );
      }

      (roomStream.playerStateUpdateCallbackList[streamID] ?? []).map(
        (cb) => cb.call(
          state,
          errorCode,
          extendedData,
        ),
      );
      if (ZegoPlayerState.NoPlay == state) {
        roomStream.playerStateUpdateCallbackList.remove(streamID);
      }

      roomStream.updatePlayerStateInDict(streamID, state);

      if (roomStream.isAllPlayStreamAudioVideoMuted) {
        if (outputLog) {
          ZegoLoggerService.logInfo(
            'audio video is not play enabled, stream id:$streamID need stop play',
            tag: 'uikit.service.event-handler',
            subTag: 'onPlayerStateUpdate',
          );
        }

        if (ZegoPlayerState.Playing == state) {
          roomStream.stopPlayingStream(streamID, removeDic: false);
        }
      }
    });

    if (ZegoStreamType.media ==
        ZegoUIKitStreamHelper.getStreamTypeByID(streamID)) {
      coreData.media.onMediaPlayerStreamStateUpdated(
        streamID,
        state,
        errorCode,
        extendedData,
      );
    }

    if (ZegoErrorCode.CommonSuccess != errorCode &&
        ZegoErrorCode.RoomManualKickedOut != errorCode) {
      coreData.error.errorStreamCtrl?.add(
        ZegoUIKitError(
          code: errorCode,
          message: 'state:${state.name}, extended data:$extendedData',
          method: 'express-api:onPlayerStateUpdate',
        ),
      );
    }
  }

  @override
  void onLocalDeviceExceptionOccurred(
    ZegoDeviceExceptionType exceptionType,
    ZegoDeviceType deviceType,
    String deviceID,
  ) {
    ZegoLoggerService.logInfo(
      'exceptionType:$exceptionType, '
      'deviceType:$deviceType, '
      'deviceID:deviceID, ',
      tag: 'uikit.service.event-handler',
      subTag: 'onLocalDeviceExceptionOccurred',
    );

    switch (deviceType) {
      case ZegoDeviceType.Camera:
        coreData.user.localUser.cameraException.value
            ?.localDeviceExceptionType = exceptionType;
        break;
      case ZegoDeviceType.Microphone:
        coreData.user.localUser.microphoneException.value
            ?.localDeviceExceptionType = exceptionType;
        break;
      default:
        break;
    }
  }

  @override
  void onRemoteCameraStateUpdate(String streamID, ZegoRemoteDeviceState state) {
    ZegoLoggerService.logInfo(
      'stream id:$streamID, '
      'state:{$state,${state.name}}',
      tag: 'uikit.service.event-handler',
      subTag: 'onRemoteCameraStateUpdate',
    );

    coreData.stream.roomStreams.forEachSync((roomID, roomStream) {
      if (!roomStream.streamDicNotifier.value.containsKey(streamID)) {
        return;
      }

      final streamType = ZegoUIKitStreamHelper.getStreamTypeByID(streamID);
      if (ZegoStreamType.main != streamType) {
        ZegoLoggerService.logInfo(
          'stream type is not main',
          tag: 'uikit.service.event-handler',
          subTag: 'onRemoteCameraStateUpdate',
        );

        return;
      }

      final targetRemoteUserList =
          coreData.user.roomUsers.getRoom(roomID).remoteUsers;

      /// update users' camera state

      if (!roomStream.streamDicNotifier.value.containsKey(streamID)) {
        ZegoLoggerService.logInfo(
          'stream $streamID is not exist',
          tag: 'uikit.service.event-handler',
          subTag: 'onRemoteCameraStateUpdate',
        );
        return;
      }

      final targetUserIndex = targetRemoteUserList.indexWhere((user) =>
          roomStream.streamDicNotifier.value[streamID]!.userID == user.id);
      if (-1 == targetUserIndex) {
        ZegoLoggerService.logInfo(
          'stream user $streamID is not exist',
          tag: 'uikit.service.event-handler',
          subTag: 'onRemoteCameraStateUpdate',
        );
        return;
      }

      final targetUser = targetRemoteUserList[targetUserIndex];
      final oldCameraValue = targetUser.camera.value;
      final oldCameraMuteValue = targetUser.cameraMuteMode.value;
      switch (state) {
        case ZegoRemoteDeviceState.Open:
          targetUser.camera.value = true;
          targetUser.cameraMuteMode.value = false;
          break;
        case ZegoRemoteDeviceState.NoAuthorization:
          targetUser.camera.value = true;
          targetUser.cameraMuteMode.value = false;
          break;
        case ZegoRemoteDeviceState.Mute:
          targetUser.camera.value = false;
          targetUser.cameraMuteMode.value = true;
          break;
        case ZegoRemoteDeviceState.Interruption:
          if (Platform.isIOS) {
            /// Frequent switching of the camera will be considered interrupted on the ios side,
            /// and the camera status will not be modified at this time.
          } else {
            targetUser.camera.value = false;
          }
          break;
        default:
          // disable or errors
          targetUser.camera.value = false;
      }

      if (oldCameraValue != targetUser.camera.value ||
          oldCameraMuteValue != targetUser.cameraMuteMode.value) {
        ZegoLoggerService.logInfo(
          'changed, '
          'old:{camera:$oldCameraValue, mute:$oldCameraMuteValue}, '
          'now:{camera:${targetUser.camera.value}, mute:${targetUser.cameraMuteMode.value}, ',
          tag: 'uikit.service.event-handler',
          subTag: 'onRemoteCameraStateUpdate',
        );

        /// notify outside to update audio video list
        roomStream.notifyStreamListControl(
          ZegoUIKitStreamHelper.getStreamTypeByID(streamID),
        );
      } else {
        ZegoLoggerService.logInfo(
          'not need changed, '
          'old:{camera:$oldCameraValue, mute:$oldCameraMuteValue}, ',
          tag: 'uikit.service.event-handler',
          subTag: 'onRemoteCameraStateUpdate',
        );
      }

      roomStream.syncCanvasViewCreateQueue(streamType: streamType);

      targetUser.cameraException.value?.remoteDeviceState = state;
    });
  }

  @override
  void onRemoteMicStateUpdate(String streamID, ZegoRemoteDeviceState state) {
    ZegoLoggerService.logInfo(
      'stream id:$streamID, '
      'state:$state',
      tag: 'uikit.service.event-handler',
      subTag: 'onRemoteMicStateUpdate',
    );

    coreData.stream.roomStreams.forEachSync((roomID, roomStream) {
      if (!roomStream.streamDicNotifier.value.containsKey(streamID)) {
        return;
      }

      final streamType = ZegoUIKitStreamHelper.getStreamTypeByID(streamID);
      if (ZegoStreamType.main != streamType) {
        ZegoLoggerService.logInfo(
          'stream type is not main',
          tag: 'uikit.service.event-handler',
          subTag: 'onRemoteMicStateUpdate',
        );

        return;
      }

      final targetRemoteUserList =
          coreData.user.roomUsers.getRoom(roomID).remoteUsers;

      /// update users' camera state

      if (!roomStream.streamDicNotifier.value.containsKey(streamID)) {
        ZegoLoggerService.logInfo(
          'stream $streamID is not exist',
          tag: 'uikit.service.event-handler',
          subTag: 'onRemoteMicStateUpdate',
        );
        return;
      }

      final targetUserIndex = targetRemoteUserList.indexWhere((user) =>
          roomStream.streamDicNotifier.value[streamID]!.userID == user.id);
      if (-1 == targetUserIndex) {
        ZegoLoggerService.logInfo(
          'stream user $streamID is not exist',
          tag: 'uikit.service.event-handler',
          subTag: 'onRemoteMicStateUpdate',
        );
        return;
      }

      final targetUser = targetRemoteUserList[targetUserIndex];
      final oldMicrophoneValue = targetUser.microphone.value;
      final oldMicrophoneMuteValue = targetUser.microphone.value;
      switch (state) {
        case ZegoRemoteDeviceState.Open:
          targetUser.microphone.value = true;

          /// remote user turn on microphone, does not affect the local user's mute status for remote user's stream.
          /// targetUser.microphoneMuteMode.value = false;
          break;
        case ZegoRemoteDeviceState.NoAuthorization:
          targetUser.microphone.value = true;
          targetUser.microphoneMuteMode.value = false;
          break;
        case ZegoRemoteDeviceState.Mute:
          targetUser.microphone.value = false;
          targetUser.microphoneMuteMode.value = true;
          break;
        default:
          // disable or errors
          targetUser.microphone.value = false;
      }

      if (!targetUser.microphone.value) {
        targetUser.mainChannel.soundLevelStream?.add(0);
      }

      if (oldMicrophoneValue != targetUser.microphone.value ||
          oldMicrophoneMuteValue != targetUser.microphoneMuteMode.value) {
        ZegoLoggerService.logInfo(
          'changed, '
          'old:{mic:$oldMicrophoneValue, mute:$oldMicrophoneMuteValue}, '
          'now:{mic:${targetUser.microphone.value}, mute:${targetUser.microphoneMuteMode.value}, ',
          tag: 'uikit.service.event-handler',
          subTag: 'onRemoteCameraStateUpdate',
        );

        /// notify outside to update audio video list
        roomStream.notifyStreamListControl(
          ZegoUIKitStreamHelper.getStreamTypeByID(streamID),
        );
      } else {
        ZegoLoggerService.logInfo(
          'not need changed, '
          'old:{mic:$oldMicrophoneValue, mute:$oldMicrophoneMuteValue}, ',
          tag: 'uikit.service.event-handler',
          subTag: 'onRemoteCameraStateUpdate',
        );
      }

      targetUser.microphoneException.value?.remoteDeviceState = state;
    });
  }

  @override
  void onRemoteSoundLevelUpdate(Map<String, double> soundLevels) {
    soundLevels.forEach((streamID, soundLevel) {
      coreData.stream.roomStreams.forEachSync((roomID, roomStream) {
        if (!roomStream.streamDicNotifier.value.containsKey(streamID)) {
          return;
        }

        if (!roomStream.streamDicNotifier.value.containsKey(streamID)) {
          if (roomStream.mixerStreamDic.containsKey(streamID)) {
            return;
          }
          return;
        }

        final targetRemoteUserList =
            coreData.user.roomUsers.getRoom(roomID).remoteUsers;

        final targetUserID =
            roomStream.streamDicNotifier.value[streamID]!.userID;
        final targetUserIndex =
            targetRemoteUserList.indexWhere((user) => targetUserID == user.id);
        if (-1 == targetUserIndex) {
          return;
        }

        ZegoUIKitStreamHelper.getUserStreamChannel(
                targetRemoteUserList[targetUserIndex],
                ZegoUIKitStreamHelper.getStreamTypeByID(streamID))
            .soundLevelStream
            ?.add(soundLevel);
      });
    });
  }

  @override
  void onCapturedSoundLevelUpdate(double soundLevel) {
    if (coreData.user.localUser.microphoneMuteMode.value) {
      return;
    }

    coreData.user.localUser.mainChannel.soundLevelStream?.add(soundLevel);
  }

  /// Attribute–Value Pair of sound wave for each single stream in the mixed stream
  /// key: the soundLevelID of each single stream
  /// value: the corresponding sound wave value of the single stream
  @override
  void onMixerSoundLevelUpdate(Map<int, double> soundLevels) {
    coreData.stream.processMixerSoundLevelUpdate(soundLevels);
  }

  @override
  void onAudioRouteChange(ZegoAudioRoute audioRoute) {
    ZegoLoggerService.logInfo(
      'audioRoute: ${audioRoute.name}',
      tag: 'uikit.service.event-handler',
      subTag: 'onAudioRouteChange',
    );

    coreData.user.localUser.audioRoute.value = audioRoute;
  }

  @override
  void onPlayerVideoSizeChanged(String streamID, int width, int height) {
    coreData.stream.roomStreams.forEachSync((roomID, roomStream) {
      if (!roomStream.streamDicNotifier.value.containsKey(streamID)) {
        return;
      }

      final targetRemoteUserList =
          coreData.user.roomUsers.getRoom(roomID).remoteUsers;
      final targetUserIndex = targetRemoteUserList.indexWhere((user) =>
          roomStream.streamDicNotifier.value[streamID]!.userID == user.id);
      if (-1 == targetUserIndex) {
        ZegoLoggerService.logInfo(
          'stream user $streamID is not exist in $roomID ',
          tag: 'uikit.service.event-handler',
          subTag: 'onPlayerVideoSizeChanged',
        );
        return;
      }

      final targetUser = targetRemoteUserList[targetUserIndex];
      ZegoLoggerService.logInfo(
        'streamID: $streamID width: $width height: '
        '$height',
        tag: 'uikit.service.event-handler',
        subTag: 'onPlayerVideoSizeChanged',
      );
      final size = Size(width.toDouble(), height.toDouble());
      final targetUserStreamChannel =
          ZegoUIKitStreamHelper.getUserStreamChannel(
              targetUser, ZegoUIKitStreamHelper.getStreamTypeByID(streamID));
      if (targetUserStreamChannel.viewSizeNotifier.value != size) {
        targetUserStreamChannel.viewSizeNotifier.value = size;
      }
    });
  }

  @override
  void onRoomStateChanged(
    String roomID,
    ZegoRoomStateChangedReason reason,
    int errorCode,
    Map<String, dynamic> extendedData,
  ) {
    final targetRoomInfo = coreData.room.rooms.getRoom(roomID);

    ZegoLoggerService.logInfo(
      'room id: $roomID, '
      'reason: $reason, '
      'errorCode: $errorCode, '
      'extendedData: $extendedData',
      tag: 'uikit.service.event-handler',
      subTag: 'onRoomStateChanged',
    );

    targetRoomInfo.state.value = ZegoUIKitRoomState(
      reason,
      errorCode,
      extendedData,
    );
    coreData.room.syncRoomsState();

    if (reason == ZegoRoomStateChangedReason.KickOut) {
      ZegoLoggerService.logInfo(
        'local user had been kick out by room state changed',
        tag: 'uikit.service.event-handler',
        subTag: 'onRoomStateChanged',
      );

      coreData.user.roomUsers
          .getRoom(roomID)
          .meRemovedFromRoomStreamCtrl
          ?.add('');
    }

    if (ZegoErrorCode.CommonSuccess != errorCode &&
        ZegoErrorCode.RoomManualKickedOut != errorCode) {
      coreData.error.errorStreamCtrl?.add(
        ZegoUIKitError(
          code: errorCode,
          message: 'reason:${reason.name}, extended data:$extendedData',
          method: 'express-api:onRoomStateChanged',
        ),
      );
    }
  }

  @override
  void onRoomStateUpdate(
    String roomID,
    ZegoRoomState state,
    int errorCode,
    Map<String, dynamic> extendedData,
  ) {
    ZegoLoggerService.logInfo(
      'room id: $roomID, '
      'state: $state, '
      'errorCode: $errorCode, '
      'extendedData: $extendedData',
      tag: 'uikit.service.event-handler',
      subTag: 'onRoomStateUpdate',
    );
  }

  @override
  void onRoomExtraInfoUpdate(
    String roomID,
    List<ZegoRoomExtraInfo> roomExtraInfoList,
  ) {
    final targetRoomInfo = coreData.room.rooms.getRoom(roomID);

    targetRoomInfo.roomExtraInfoHadArrived = true;

    final roomExtraInfoString = roomExtraInfoList.map((info) =>
        'key:${info.key}, value:${info.value}'
        ' update user:${info.updateUser.userID},${info.updateUser.userName}, '
        'update time:${info.updateTime}');
    ZegoLoggerService.logInfo(
      'room id: $roomID,'
      'roomExtraInfoList: $roomExtraInfoString',
      tag: 'uikit.service.event-handler',
      subTag: 'onRoomExtraInfoUpdate',
    );

    for (final extraInfo in roomExtraInfoList) {
      if (extraInfo.key == 'extra_info') {
        final properties = jsonDecode(extraInfo.value) as Map<String, dynamic>;

        ZegoLoggerService.logInfo(
          'update room properties: $properties',
          tag: 'uikit.service.event-handler',
          subTag: 'onRoomExtraInfoUpdate',
        );

        final updateProperties = <String, RoomProperty>{};

        properties.forEach((key, v) {
          final value = v as String;

          if (targetRoomInfo.properties.containsKey(key) &&
              targetRoomInfo.properties[key]!.value == value) {
            ZegoLoggerService.logInfo(
              'room property not need update, key:$key, value:$value',
              tag: 'uikit.service.event-handler',
              subTag: 'onRoomExtraInfoUpdate',
            );
            return;
          }

          ZegoLoggerService.logInfo(
            'room property update, key:$key, value:$value',
            tag: 'uikit.service.event-handler',
            subTag: 'onRoomExtraInfoUpdate',
          );
          if (targetRoomInfo.properties.containsKey(key)) {
            final property = targetRoomInfo.properties[key]!;
            if (extraInfo.updateTime > property.updateTime) {
              targetRoomInfo.properties[key]!.oldValue =
                  targetRoomInfo.properties[key]!.value;
              targetRoomInfo.properties[key]!.value = value;
              targetRoomInfo.properties[key]!.updateTime = extraInfo.updateTime;
              targetRoomInfo.properties[key]!.updateUserID =
                  extraInfo.updateUser.userID;
              targetRoomInfo.properties[key]!.updateFromRemote = true;
            }
          } else {
            targetRoomInfo.properties[key] = RoomProperty(
              key,
              value,
              extraInfo.updateTime,
              extraInfo.updateUser.userID,
              true,
            );
          }
          updateProperties[key] = targetRoomInfo.properties[key]!;
          targetRoomInfo.propertyUpdateStream
              ?.add(targetRoomInfo.properties[key]!);
        });

        if (updateProperties.isNotEmpty) {
          targetRoomInfo.propertiesUpdatedStream?.add(updateProperties);
        }
      }
    }

    ZegoLoggerService.logInfo(
      'after properties:${targetRoomInfo.properties}, ',
      tag: 'uikit.service.event-handler',
      subTag: 'onRoomExtraInfoUpdate',
    );
  }

  @override
  void onRoomStreamExtraInfoUpdate(String roomID, List<ZegoStream> streamList) {
    /*
    * {
    * "isCameraOn": true,
    * "isMicrophoneOn": true,
    * "hasAudio": true,
    * "hasVideo": true,
    * }
    * */

    ZegoLoggerService.logInfo(
      "roomID:$roomID, stream list:${streamList.map((e) => "stream id:${e.streamID}, extra info${e.extraInfo}, user id:${e.user.userID}")}",
      tag: 'uikit.service.event-handler',
      subTag: 'onRoomStreamExtraInfoUpdate',
    );
    for (final stream in streamList) {
      parseStreamExtraInfo(
        roomID: roomID,
        streamID: stream.streamID,
        extraInfo: stream.extraInfo,
      );
    }
  }

  void parseStreamExtraInfo({
    required String roomID,
    required String streamID,
    required String extraInfo,
  }) {
    if (extraInfo.isEmpty) {
      ZegoLoggerService.logInfo(
        'extra info is empty',
        tag: 'uikit.service.event-handler',
        subTag: 'onRoomStreamExtraInfoUpdate-parseStreamExtraInfo',
      );

      return;
    }

    final targetRoomStream = coreData.stream.roomStreams.getRoom(roomID);

    targetRoomStream.extraInfo[streamID] = extraInfo;

    ZegoLoggerService.logInfo(
      'try parse stream extra info($extraInfo),'
      'room id:$roomID, ',
      tag: 'uikit.service.event-handler',
      subTag: 'onRoomStreamExtraInfoUpdate-parseStreamExtraInfo',
    );

    var extraInfos = {};
    try {
      extraInfos = jsonDecode(extraInfo) as Map<String, dynamic>? ?? {};
    } catch (e) {
      ZegoLoggerService.logError(
        'parse stream extra info($extraInfo) error: $e',
        tag: 'uikit.service.event-handler',
        subTag: 'onRoomStreamExtraInfoUpdate-parseStreamExtraInfo',
      );
    }

    if (extraInfos.containsKey(streamExtraInfoCameraKey)) {
      onRemoteCameraStateUpdate(
        streamID,
        extraInfos[streamExtraInfoCameraKey]!
            ? ZegoRemoteDeviceState.Open
            : ZegoRemoteDeviceState.Mute,
      );
    }

    if (extraInfos.containsKey(streamExtraInfoMicrophoneKey)) {
      onRemoteMicStateUpdate(
        streamID,
        extraInfos[streamExtraInfoMicrophoneKey]!
            ? ZegoRemoteDeviceState.Open
            : ZegoRemoteDeviceState.Mute,
      );
    }

    if (extraInfos.containsKey(ZegoUIKitSEIDefines.keyMediaType)) {
      coreData.media.onRemoteMediaTypeUpdate(
        streamID,
        extraInfos[ZegoUIKitSEIDefines.keyMediaType] as int? ??
            ZegoUIKitMediaType.pureAudio.index,
      );
    }
  }

  @override
  void onIMRecvCustomCommand(
    String roomID,
    ZegoUser fromUser,
    String command,
  ) {
    ZegoLoggerService.logInfo(
      'roomID: $roomID, '
      'reason: ${fromUser.userID} ${fromUser.userName}, '
      'command:$command',
      tag: 'uikit.service.event-handler',
      subTag: 'onIMRecvCustomCommand',
    );

    coreData.customCommandReceivedStreamCtrl?.add(ZegoInRoomCommandReceivedData(
      roomID: roomID,
      fromUser: ZegoUIKitUser.fromZego(
        fromUser,
        roomID,
        coreData.room.currentID == roomID,
      ),
      command: command,
    ));
  }

  @override
  void onPlayerRecvVideoFirstFrame(String streamID) {
    coreData.stream.roomStreams.forEachSync((roomID, roomStream) {
      if (!roomStream.streamDicNotifier.value.containsKey(streamID)) {
        return;
      }

      roomStream.mixerStreamDic[streamID]?.loaded.value = true;
    });
  }

  @override
  void onPlayerRecvAudioFirstFrame(String streamID) {
    coreData.stream.roomStreams.forEachSync((roomID, roomStream) {
      if (!roomStream.streamDicNotifier.value.containsKey(streamID)) {
        return;
      }

      roomStream.mixerStreamDic[streamID]?.loaded.value = true;
    });
  }

  @override
  void onPlayerRecvSEI(String streamID, Uint8List data) {
    coreData.stream.roomStreams.forEachSync((roomID, roomStream) {
      if (!roomStream.streamDicNotifier.value.containsKey(streamID)) {
        return;
      }

      final dataJson = utf8.decode(data.toList());
      try {
        final dataMap = jsonDecode(dataJson) as Map<String, dynamic>;
        final typeIdentifier =
            dataMap[ZegoUIKitSEIDefines.keyTypeIdentifier] as String;
        final sei = dataMap[ZegoUIKitSEIDefines.keySEI] as Map<String, dynamic>;
        final uid = dataMap[ZegoUIKitSEIDefines.keyUserID] as String;

        if (typeIdentifier == ZegoUIKitInnerSEIType.mixerDeviceState.name) {
          _updateMixerDeviceStateBySEI(roomID, streamID, uid, sei);
        } else if (typeIdentifier == ZegoUIKitInnerSEIType.mediaSyncInfo.name) {
          coreData.media.onMediaPlayerRecvSEIFromSDK(
            streamID,
            uid,
            sei,
          );
        }

        roomStream.receiveSEIStreamCtrl?.add(
          ZegoUIKitReceiveSEIEvent(
            senderID: uid,
            streamID: streamID,
            streamType: ZegoUIKitStreamHelper.getStreamTypeByID(streamID),
            typeIdentifier: typeIdentifier,
            sei: sei,
          ),
        );
      } catch (e) {
        ZegoLoggerService.logWarn(
          'decode sei failed, sei: $dataJson, stream id:$streamID',
          tag: 'uikit.service.event-handler',
          subTag: 'onPlayerRecvSEI',
        );
      }
    });
  }

  void _updateMixerDeviceStateBySEI(
    String roomID,
    String streamID,
    String userID,
    Map<String, dynamic> sei,
  ) {
    final targetRoomStream = coreData.stream.roomStreams.getRoom(roomID);

    bool stateChanged = false;
    final cameraValue = sei[ZegoUIKitSEIDefines.keyCamera] ?? false;
    final microphoneValue = sei[ZegoUIKitSEIDefines.keyMicrophone] ?? false;
    if (targetRoomStream.mixerStreamDic.containsKey(streamID)) {
      final userIndex = targetRoomStream
          .mixerStreamDic[streamID]!.usersNotifier.value
          .indexWhere((user) => user.id == userID);
      if (userIndex == -1) {
        final user = ZegoUIKitCoreUser(
          userID,
          '',
          roomID,
          coreData.room.currentID != roomID,
        );
        user.camera.value = cameraValue;
        user.microphone.value = microphoneValue;
        targetRoomStream.mixerStreamDic[streamID]!.addUser(user);

        stateChanged = true;
      } else {
        final user = targetRoomStream
            .mixerStreamDic[streamID]!.usersNotifier.value[userIndex];

        stateChanged = cameraValue != user.camera.value ||
            microphoneValue != user.microphone.value;

        user.camera.value = cameraValue;
        user.microphone.value = microphoneValue;
      }
    } else {
      final targetRemoteUserList =
          coreData.user.roomUsers.getRoom(roomID).remoteUsers;
      final targetUserIndex =
          targetRemoteUserList.indexWhere((user) => userID == user.id);
      if (-1 != targetUserIndex) {
        stateChanged =
            cameraValue != targetRemoteUserList[targetUserIndex].camera.value ||
                microphoneValue !=
                    targetRemoteUserList[targetUserIndex].microphone.value;

        targetRemoteUserList[targetUserIndex].camera.value = cameraValue;
        targetRemoteUserList[targetUserIndex].microphone.value =
            microphoneValue;
      }
    }

    if (stateChanged) {
      /// notify outside to update audio video list
      targetRoomStream.notifyStreamListControl(
        ZegoUIKitStreamHelper.getStreamTypeByID(streamID),
      );
    }
  }
}
