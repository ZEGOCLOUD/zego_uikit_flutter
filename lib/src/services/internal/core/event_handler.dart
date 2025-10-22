// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/services/internal/core/data/stream.dart';
import 'package:zego_uikit/src/services/internal/internal.dart';
import 'package:zego_uikit/src/services/services.dart';

/// @nodoc
mixin ZegoUIKitCoreEventHandler {
  final _eventHandlerImpl = ZegoUIKitCoreEventHandlerImpl();

  ZegoUIKitCoreEventHandlerImpl get eventHandler => _eventHandlerImpl;
}

/// @nodoc
class ZegoUIKitCoreEventHandlerImpl extends ZegoUIKitExpressEventInterface {
  final Connectivity _connectivity = Connectivity();

  Future<void> initConnectivity() async {
    ZegoLoggerService.logInfo(
      'initConnectivity, ',
      tag: 'uikit-service-core',
      subTag: 'event',
    );

    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      ZegoLoggerService.logInfo(
        'initConnectivity exception:$e',
        tag: 'uikit-service-core',
        subTag: 'event',
      );

      return;
    }

    _onConnectivityChanged(result);

    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  Future<void> _onConnectivityChanged(List<ConnectivityResult> result) async {
    ZegoLoggerService.logInfo(
      'onConnectivityChanged, '
      'result:$result, '
      'network state:${coreData.networkStateNotifier.value}',
      tag: 'uikit-service-core',
      subTag: 'event',
    );

    coreData.networkStateNotifier.value =
        (result.contains(ConnectivityResult.mobile) ||
                result.contains(ConnectivityResult.wifi) ||
                result.contains(ConnectivityResult.ethernet))
            ? ZegoUIKitNetworkState.online
            : ZegoUIKitNetworkState.offline;

    coreData.networkStateStreamCtrl?.add(coreData.networkStateNotifier.value);
  }

  ZegoUIKitCoreData get coreData => ZegoUIKitCore.shared.coreData;

  ZegoUIKitCoreDataErrorImpl get error => ZegoUIKitCore.shared.error;

  @override
  void onEngineStateUpdate(ZegoEngineState state) {
    ZegoLoggerService.logInfo(
      'onEngineStateUpdate, '
      'state:$state, ',
      tag: 'uikit-service-core',
      subTag: 'event',
    );

    coreData.engineState = ZegoUIKitExpressEngineStateExtension.fromSDK(state);

    coreData.engineStateStreamCtrl.add(coreData.engineState);

    if (ZegoEngineState.Start == state) {
      ZegoExpressEngine.instance.getAudioRouteType().then((value) {
        ZegoLoggerService.logInfo(
          'update audio route by onEngineStateUpdate, '
          'state:$state, ',
          tag: 'uikit-service-core',
          subTag: 'event',
        );

        coreData.localUser.initAudioRoute(value);
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
      'onRoomStreamUpdate, roomID:$roomID, update type:$updateType'
      ", stream list:${streamList.map((e) => e.toStringX())},"
      ' extended data:$extendedData',
      tag: 'uikit-service-core',
      subTag: 'event',
    );

    if (updateType == ZegoUpdateType.Add) {
      for (final stream in streamList) {
        coreData.streamDic[stream.streamID] = ZegoUIKitCoreDataStreamData(
          userID: stream.user.userID,
          playerState: ZegoPlayerState.NoPlay,
        );
        ZegoLoggerService.logInfo(
          'stream dict add ${stream.streamID} for ${stream.user.userID}, '
          'dict: ${coreData.streamDic}',
          tag: 'uikit-service-core',
          subTag: 'event',
        );

        late ZegoUIKitCoreUser targetUser;
        var targetUserIndex = coreData.remoteUsersList
            .indexWhere((user) => stream.user.userID == user.id);
        if (-1 == targetUserIndex) {
          /// user is not exist before stream added
          ZegoLoggerService.logInfo(
            "stream's user ${stream.user.userID}  ${stream.user.userName} is not exist, create",
            tag: 'uikit-service-core',
            subTag: 'event',
          );

          targetUser = ZegoUIKitCoreUser.fromZego(stream.user);
          coreData.remoteUsersList.add(targetUser);
        } else {
          targetUser = coreData.remoteUsersList[targetUserIndex];
        }

        final streamType = coreData.getStreamTypeByID(stream.streamID);
        coreData.getUserStreamChannel(targetUser, streamType)
          ..streamID = stream.streamID
          ..streamTimestamp = coreData.networkDateTime_.millisecondsSinceEpoch;

        if (coreData.isAllPlayStreamAudioVideoMuted) {
          ZegoLoggerService.logInfo(
            'audio video is not play enabled, user id:${stream.user.userID}, stream id:${stream.streamID}',
            tag: 'uikit-service-core',
            subTag: 'event',
          );
        } else {
          await coreData.startPlayingStreamQueue(
            stream.streamID,
            stream.user.userID,
          );
        }
      }

      onRoomStreamExtraInfoUpdate(roomID, streamList);
    } else {
      for (final stream in streamList) {
        coreData.stopPlayingStream(stream.streamID);
      }
    }

    final streamIDs = streamList.map((e) => e.streamID).toList();
    if (-1 !=
        streamIDs.indexWhere(
            (streamID) => streamID.endsWith(ZegoStreamType.main.text))) {
      coreData.audioVideoListStreamCtrl?.add(coreData.getAudioVideoList());
    }
    if (-1 !=
        streamIDs.indexWhere((streamID) =>
            streamID.endsWith(ZegoStreamType.screenSharing.text))) {
      coreData.screenSharingListStreamCtrl?.add(
          coreData.getAudioVideoList(streamType: ZegoStreamType.screenSharing));
    }
    if (-1 !=
        streamIDs.indexWhere(
            (streamID) => streamID.endsWith(ZegoStreamType.media.text))) {
      coreData.media.mediaListStreamCtrl
          ?.add(coreData.getAudioVideoList(streamType: ZegoStreamType.media));
    }
  }

  @override
  void onRoomUserUpdate(
    String roomID,
    ZegoUpdateType updateType,
    List<ZegoUser> userList,
  ) {
    ZegoLoggerService.logInfo(
      'onRoomUserUpdate, room id:"$roomID", update type:$updateType'
      "user list:${userList.map((user) => '"${user.userID}":${user.userName}, ')}",
      tag: 'uikit-service-core',
      subTag: 'event',
    );

    if (updateType == ZegoUpdateType.Add) {
      for (final user in userList) {
        final targetUserIndex =
            coreData.remoteUsersList.indexWhere((e) => user.userID == e.id);
        if (-1 != targetUserIndex) {
          continue;
        }

        coreData.remoteUsersList.add(ZegoUIKitCoreUser.fromZego(user));
      }

      if (coreData.remoteUsersList.length >= 499) {
        /// turn to be a large room after more than 500 people, even if less than 500 people behind
        ZegoLoggerService.logInfo(
          'users is more than 500, turn to be a large room',
          tag: 'uikit-service-core',
          subTag: 'event',
        );
        coreData.room.isLargeRoom = true;
      }

      coreData.userJoinStreamCtrl?.add(
        userList.map(ZegoUIKitCoreUser.fromZego).toList(),
      );
    } else {
      for (final user in userList) {
        coreData.removeUser(user.userID);
      }

      coreData.userLeaveStreamCtrl
          ?.add(userList.map(ZegoUIKitCoreUser.fromZego).toList());
    }

    final allUserList = [coreData.localUser, ...coreData.remoteUsersList];
    coreData.userListStreamCtrl?.add(allUserList);
  }

  @override
  void onRoomTokenWillExpire(
    String roomID,
    int remainTimeInSecond,
  ) {
    ZegoLoggerService.logInfo(
      'onRoomTokenWillExpire, room ID:$roomID, remainTimeInSecond:$remainTimeInSecond',
      tag: 'uikit-service-core',
      subTag: 'event',
    );

    if (coreData.room.id == roomID) {
      coreData.room.tokenExpiredStreamCtrl?.add(remainTimeInSecond);
    } else {
      ZegoLoggerService.logWarn(
        'onRoomTokenWillExpire, room ID($roomID) is not same as current room id(${coreData.room.id})',
        tag: 'uikit-service-core',
        subTag: 'event',
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
    ZegoLoggerService.logInfo(
      'onPublisherStateUpdate, stream id:$streamID, state:$state, errorCode:$errorCode, extendedData:$extendedData',
      tag: 'uikit-service-core',
      subTag: 'event',
    );

    coreData.streamDic[streamID]?.publisherState = state;

    if (ZegoErrorCode.CommonSuccess != errorCode &&
        ZegoErrorCode.RoomManualKickedOut != errorCode) {
      error.errorStreamCtrl?.add(
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
    coreData
        .getUserStreamChannel(
          ZegoUIKitCore.shared.coreData.localUser,
          coreData.getStreamTypeByID(streamID),
        )
        .qualityNotifier
        .value = quality.toUIKit();
  }

  @override
  void onPublisherCapturedAudioFirstFrame() {
    coreData
        .getUserStreamChannel(
          ZegoUIKitCore.shared.coreData.localUser,
          ZegoStreamType.main,
        )
        .isCapturedAudioFirstFrameNotifier
        .value = true;
  }

  @override
  void onPublisherCapturedVideoFirstFrame(ZegoPublishChannel channel) {
    coreData
        .getUserStreamChannel(
          ZegoUIKitCore.shared.coreData.localUser,
          coreData.getStreamTypeByZegoPublishChannel(
            ZegoUIKitCore.shared.coreData.localUser,
            channel,
          ),
        )
        .isCapturedVideoFirstFrameNotifier
        .value = true;

    try {
      /// onPublisherRenderVideoFirstFrame only once callback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        coreData
            .getUserStreamChannel(
              ZegoUIKitCore.shared.coreData.localUser,
              coreData.getStreamTypeByZegoPublishChannel(
                ZegoUIKitCore.shared.coreData.localUser,
                channel,
              ),
            )
            .isRenderedVideoFirstFrameNotifier
            .value = true;
      });
    } catch (e) {
      ZegoLoggerService.logInfo(
        'set isRenderedVideoFirstFrame error:$e',
        tag: 'uikit-component',
        subTag: 'audio video view',
      );
    }
  }

  @override
  void onPublisherRenderVideoFirstFrame(ZegoPublishChannel channel) {
    coreData
        .getUserStreamChannel(
          ZegoUIKitCore.shared.coreData.localUser,
          coreData.getStreamTypeByZegoPublishChannel(
            ZegoUIKitCore.shared.coreData.localUser,
            channel,
          ),
        )
        .isRenderedVideoFirstFrameNotifier
        .value = true;
  }

  @override
  void onPublisherSendAudioFirstFrame(ZegoPublishChannel channel) {
    coreData
        .getUserStreamChannel(
          ZegoUIKitCore.shared.coreData.localUser,
          coreData.getStreamTypeByZegoPublishChannel(
            ZegoUIKitCore.shared.coreData.localUser,
            channel,
          ),
        )
        .isSendAudioFirstFrameNotifier
        .value = true;
  }

  @override
  void onPublisherSendVideoFirstFrame(ZegoPublishChannel channel) {
    coreData
        .getUserStreamChannel(
          ZegoUIKitCore.shared.coreData.localUser,
          coreData.getStreamTypeByZegoPublishChannel(
            ZegoUIKitCore.shared.coreData.localUser,
            channel,
          ),
        )
        .isSendVideoFirstFrameNotifier
        .value = true;
  }

  @override
  void onPlayerStateUpdate(
    String streamID,
    ZegoPlayerState state,
    int errorCode,
    Map<String, dynamic> extendedData,
  ) {
    ZegoLoggerService.logInfo(
      'onPlayerStateUpdate, '
      'stream id:$streamID, '
      'state:$state, '
      'errorCode:$errorCode, '
      'extendedData:$extendedData, '
      'isAllPlayStreamAudioVideoMuted:${coreData.isAllPlayStreamAudioVideoMuted}, '
      'isAllPlayStreamAudioMuted:${coreData.isAllPlayStreamAudioMuted}, ',
      tag: 'uikit-service-core',
      subTag: 'event',
    );

    (coreData.playerStateUpdateCallbackList[streamID] ?? []).map(
      (cb) => cb.call(
        ZegoUIKitPlayerStateExtension.fromZego(state),
        errorCode,
        extendedData,
      ),
    );
    if (ZegoPlayerState.NoPlay == state) {
      coreData.playerStateUpdateCallbackList.remove(streamID);
    }

    coreData.streamDic[streamID]?.playerState = state;

    if (ZegoStreamType.media == coreData.getStreamTypeByID(streamID)) {
      coreData.media.onMediaPlayerStreamStateUpdated(
        streamID,
        state,
        errorCode,
        extendedData,
      );
    }

    if (ZegoErrorCode.CommonSuccess != errorCode &&
        ZegoErrorCode.RoomManualKickedOut != errorCode) {
      error.errorStreamCtrl?.add(
        ZegoUIKitError(
          code: errorCode,
          message: 'state:${state.name}, extended data:$extendedData',
          method: 'express-api:onPlayerStateUpdate',
        ),
      );
    }

    if (coreData.isAllPlayStreamAudioVideoMuted) {
      ZegoLoggerService.logInfo(
        'audio video is not play enabled, stream id:$streamID need stop play',
        tag: 'uikit-service-core',
        subTag: 'event',
      );

      if (ZegoPlayerState.Playing == state) {
        coreData.stopPlayingStream(streamID, removeDic: false);
      }
    }
  }

  @override
  void onLocalDeviceExceptionOccurred(
    ZegoDeviceExceptionType exceptionType,
    ZegoDeviceType deviceType,
    String deviceID,
  ) {
    ZegoLoggerService.logInfo(
      'onLocalDeviceExceptionOccurred, '
      'exceptionType:$exceptionType, '
      'deviceType:$deviceType, '
      'deviceID:deviceID, ',
      tag: 'uikit-service-core',
      subTag: 'event',
    );

    switch (deviceType) {
      case ZegoDeviceType.Camera:
        coreData.localUser.cameraException.value =
            ZegoUIKitDeviceExceptionTypeExtension.fromSDKValue(exceptionType);
        break;
      case ZegoDeviceType.Microphone:
        coreData.localUser.microphoneException.value =
            ZegoUIKitDeviceExceptionTypeExtension.fromSDKValue(exceptionType);
        break;
      default:
        break;
    }
  }

  @override
  void onRemoteCameraStateUpdate(String streamID, ZegoRemoteDeviceState state) {
    ZegoLoggerService.logInfo(
      'onRemoteCameraStateUpdate, '
      'stream id:$streamID, '
      'state:{$state,${state.name}}',
      tag: 'uikit-service-core',
      subTag: 'event',
    );

    final streamType = coreData.getStreamTypeByID(streamID);
    if (ZegoStreamType.main != streamType) {
      ZegoLoggerService.logInfo(
        'onRemoteCameraStateUpdate, stream type is not main',
        tag: 'uikit-service-core',
        subTag: 'event',
      );

      return;
    }

    /// update users' camera state

    if (!coreData.streamDic.containsKey(streamID)) {
      ZegoLoggerService.logInfo(
        'onRemoteCameraStateUpdate, stream $streamID is not exist',
        tag: 'uikit-service-core',
        subTag: 'event',
      );
      return;
    }

    final targetUserIndex = coreData.remoteUsersList
        .indexWhere((user) => coreData.streamDic[streamID]!.userID == user.id);
    if (-1 == targetUserIndex) {
      ZegoLoggerService.logInfo(
        'onRemoteCameraStateUpdate, stream user $streamID is not exist',
        tag: 'uikit-service-core',
        subTag: 'event',
      );
      return;
    }

    final targetUser = coreData.remoteUsersList[targetUserIndex];
    final oldCameraValue = targetUser.camera.value;
    final oldCameraMuteValue = targetUser.cameraMuteMode.value;
    ZegoLoggerService.logInfo(
      'onRemoteCameraStateUpdate, '
      'stream id:$streamID, user:$targetUser, state:$state, '
      'old value:$oldCameraValue, '
      'old mute value:$oldCameraMuteValue',
      tag: 'uikit-service-core',
      subTag: 'event',
    );
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
      /// notify outside to update audio video list
      coreData.notifyStreamListControl(coreData.getStreamTypeByID(streamID));
    }

    coreData.syncCanvasViewCreateQueue(streamType: streamType);

    targetUser.cameraException.value =
        ZegoUIKitDeviceExceptionTypeExtension.fromDeviceState(state);
  }

  @override
  void onRemoteMicStateUpdate(String streamID, ZegoRemoteDeviceState state) {
    ZegoLoggerService.logInfo(
      'onRemoteMicStateUpdate, stream $streamID, state:$state',
      tag: 'uikit-service-core',
      subTag: 'event',
    );

    final streamType = coreData.getStreamTypeByID(streamID);
    if (ZegoStreamType.main != streamType) {
      ZegoLoggerService.logInfo(
        'onRemoteMicStateUpdate, stream type is not main',
        tag: 'uikit-service-core',
        subTag: 'event',
      );

      return;
    }

    /// update users' camera state

    if (!coreData.streamDic.containsKey(streamID)) {
      ZegoLoggerService.logInfo(
        'onRemoteMicStateUpdate, stream $streamID is not exist',
        tag: 'uikit-service-core',
        subTag: 'event',
      );
      return;
    }

    final targetUserIndex = coreData.remoteUsersList
        .indexWhere((user) => coreData.streamDic[streamID]!.userID == user.id);
    if (-1 == targetUserIndex) {
      ZegoLoggerService.logInfo(
        'onRemoteMicStateUpdate, stream user $streamID is not exist',
        tag: 'uikit-service-core',
        subTag: 'event',
      );
      return;
    }

    final targetUser = coreData.remoteUsersList[targetUserIndex];
    ZegoLoggerService.logInfo(
      'onRemoteMicStateUpdate, stream id:$streamID, user:$targetUser, state:$state',
      tag: 'uikit-service-core',
      subTag: 'event',
    );
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
      /// notify outside to update audio video list
      coreData.notifyStreamListControl(coreData.getStreamTypeByID(streamID));
    }

    targetUser.microphoneException.value =
        ZegoUIKitDeviceExceptionTypeExtension.fromDeviceState(state);
  }

  @override
  void onRemoteSoundLevelUpdate(Map<String, double> soundLevels) {
    soundLevels.forEach((streamID, soundLevel) {
      if (!coreData.streamDic.containsKey(streamID)) {
        if (coreData.mixerStreamDic.containsKey(streamID)) {
          return;
        }
        // ZegoLoggerService.logInfo(
        //   'stream dic does not contain $streamID',
        //   tag: 'uikit-service-core',
        //   subTag: 'event',
        // );
        return;
      }

      final targetUserID = coreData.streamDic[streamID]!.userID;
      final targetUserIndex = coreData.remoteUsersList
          .indexWhere((user) => targetUserID == user.id);
      if (-1 == targetUserIndex) {
        // ZegoLoggerService.logInfo(
        //   'remote user does not contain $targetUserID',
        //   tag: 'uikit-service-core',
        //   subTag: 'event',
        // );
        return;
      }

      coreData
          .getUserStreamChannel(coreData.remoteUsersList[targetUserIndex],
              coreData.getStreamTypeByID(streamID))
          .soundLevelStream
          ?.add(soundLevel);
    });
  }

  @override
  void onCapturedSoundLevelUpdate(double soundLevel) {
    if (coreData.localUser.microphoneMuteMode.value) {
      return;
    }

    coreData.localUser.mainChannel.soundLevelStream?.add(soundLevel);
  }

  @override
  void onMixerSoundLevelUpdate(Map<int, double> soundLevels) {
    /// 0.0 ~ 100.0
    if (coreData.mixerStreamDic.values.isEmpty) {
      return;
    }

    final targetMixerStream = coreData.mixerStreamDic.values.first;
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

  @override
  void onAudioRouteChange(ZegoAudioRoute audioRoute) {
    ZegoLoggerService.logInfo(
      'onAudioRouteChange, audioRoute: ${audioRoute.name}',
      tag: 'uikit-service-core',
      subTag: 'event',
    );

    coreData.localUser.audioRoute.value =
        ZegoUIKitAudioRouteExtension.fromSDKValue(audioRoute);
  }

  @override
  void onPlayerVideoSizeChanged(String streamID, int width, int height) {
    if (!coreData.streamDic.containsKey(streamID)) {
      ZegoLoggerService.logInfo(
        'onPlayerVideoSizeChanged, stream $streamID is not exist',
        tag: 'uikit-service-core',
        subTag: 'event',
      );
      return;
    }
    final targetUserIndex = coreData.remoteUsersList
        .indexWhere((user) => coreData.streamDic[streamID]!.userID == user.id);
    if (-1 == targetUserIndex) {
      ZegoLoggerService.logInfo(
        'onPlayerVideoSizeChanged, stream user $streamID is not exist',
        tag: 'uikit-service-core',
        subTag: 'event',
      );
      return;
    }

    final targetUser = coreData.remoteUsersList[targetUserIndex];
    ZegoLoggerService.logInfo(
      'onPlayerVideoSizeChanged streamID: $streamID width: $width height: $height',
      tag: 'uikit-service-core',
      subTag: 'event',
    );
    final size = Size(width.toDouble(), height.toDouble());
    final targetUserStreamChannel = coreData.getUserStreamChannel(
        targetUser, coreData.getStreamTypeByID(streamID));
    if (targetUserStreamChannel.viewSizeNotifier.value != size) {
      targetUserStreamChannel.viewSizeNotifier.value = size;
    }
  }

  @override
  void onRoomStateChanged(
    String roomID,
    ZegoRoomStateChangedReason reason,
    int errorCode,
    Map<String, dynamic> extendedData,
  ) {
    ZegoLoggerService.logInfo(
      'onRoomStateChanged roomID: $roomID, reason: $reason, errorCode: $errorCode, extendedData: $extendedData',
      tag: 'uikit-service-core',
      subTag: 'event',
    );

    coreData.room.state.value =
        ZegoUIKitRoomState(reason, errorCode, extendedData);

    if (reason == ZegoRoomStateChangedReason.KickOut) {
      ZegoLoggerService.logInfo(
        'local user had been kick out by room state changed',
        tag: 'uikit-service-core',
        subTag: 'event',
      );

      coreData.meRemovedFromRoomStreamCtrl?.add('');
    }

    if (ZegoErrorCode.CommonSuccess != errorCode &&
        ZegoErrorCode.RoomManualKickedOut != errorCode) {
      error.errorStreamCtrl?.add(
        ZegoUIKitError(
          code: errorCode,
          message: 'reason:${reason.name}, extended data:$extendedData',
          method: 'express-api:onRoomStateChanged',
        ),
      );
    }
  }

  @override
  void onRoomExtraInfoUpdate(
    String roomID,
    List<ZegoRoomExtraInfo> roomExtraInfoList,
  ) {
    coreData.room.roomExtraInfoHadArrived = true;

    final roomExtraInfoString = roomExtraInfoList.map((info) =>
        'key:${info.key}, value:${info.value}'
        ' update user:${info.updateUser.userID},${info.updateUser.userName}, '
        'update time:${info.updateTime}');
    ZegoLoggerService.logInfo(
      'onRoomExtraInfoUpdate roomID: $roomID,roomExtraInfoList: $roomExtraInfoString',
      tag: 'uikit-service-core',
      subTag: 'event',
    );

    for (final extraInfo in roomExtraInfoList) {
      if (extraInfo.key == 'extra_info') {
        final properties = jsonDecode(extraInfo.value) as Map<String, dynamic>;

        ZegoLoggerService.logInfo(
          'update room properties: $properties',
          tag: 'uikit-service-core',
          subTag: 'event',
        );

        final updateProperties = <String, RoomProperty>{};

        properties.forEach((key, v) {
          final value = v as String;

          if (coreData.room.properties.containsKey(key) &&
              coreData.room.properties[key]!.value == value) {
            ZegoLoggerService.logInfo(
              'room property not need update, key:$key, value:$value',
              tag: 'uikit-service-core',
              subTag: 'event',
            );
            return;
          }

          ZegoLoggerService.logInfo(
            'room property update, key:$key, value:$value',
            tag: 'uikit-service-core',
            subTag: 'event',
          );
          if (coreData.room.properties.containsKey(key)) {
            final property = coreData.room.properties[key]!;
            if (extraInfo.updateTime > property.updateTime) {
              coreData.room.properties[key]!.oldValue =
                  coreData.room.properties[key]!.value;
              coreData.room.properties[key]!.value = value;
              coreData.room.properties[key]!.updateTime = extraInfo.updateTime;
              coreData.room.properties[key]!.updateUserID =
                  extraInfo.updateUser.userID;
              coreData.room.properties[key]!.updateFromRemote = true;
            }
          } else {
            coreData.room.properties[key] = RoomProperty(
              key,
              value,
              extraInfo.updateTime,
              extraInfo.updateUser.userID,
              true,
            );
          }
          updateProperties[key] = coreData.room.properties[key]!;
          coreData.room.propertyUpdateStream
              ?.add(coreData.room.properties[key]!);
        });

        if (updateProperties.isNotEmpty) {
          coreData.room.propertiesUpdatedStream?.add(updateProperties);
        }
      }
    }
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
      "onRoomStreamExtraInfoUpdate, roomID:$roomID, stream list:${streamList.map((e) => "stream id:${e.streamID}, extra info${e.extraInfo}, user id:${e.user.userID}")}",
      tag: 'uikit-service-core',
      subTag: 'event',
    );
    for (final stream in streamList) {
      parseStreamExtraInfo(
        streamID: stream.streamID,
        extraInfo: stream.extraInfo,
      );
    }
  }

  void parseStreamExtraInfo({
    required String streamID,
    required String extraInfo,
  }) {
    if (extraInfo.isEmpty) {
      ZegoLoggerService.logInfo(
        'onRoomStreamExtraInfoUpdate extra info is empty',
        tag: 'uikit-service-core',
        subTag: 'event',
      );

      return;
    }

    coreData.streamExtraInfo[streamID] = extraInfo;

    ZegoLoggerService.logInfo(
      'try parse stream extra info($extraInfo)',
      tag: 'uikit-service-core',
      subTag: 'event',
    );

    var extraInfos = {};
    try {
      extraInfos = jsonDecode(extraInfo) as Map<String, dynamic>? ?? {};
    } catch (e) {
      ZegoLoggerService.logError(
        'parse stream extra info($extraInfo) error: $e',
        tag: 'uikit-service-core',
        subTag: 'event',
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
      'onIMReceiveCustomCommand roomID: $roomID, reason: ${fromUser.userID} ${fromUser.userName}, command:$command',
      tag: 'uikit-service-core',
      subTag: 'event',
    );

    coreData.customCommandReceivedStreamCtrl?.add(ZegoInRoomCommandReceivedData(
      fromUser: ZegoUIKitUser.fromZego(fromUser),
      command: command,
    ));
  }

  @override
  void onPlayerRecvVideoFirstFrame(String streamID) {
    coreData.mixerStreamDic[streamID]?.loaded.value = true;
  }

  @override
  void onPlayerRecvAudioFirstFrame(String streamID) {
    coreData.mixerStreamDic[streamID]?.loaded.value = true;
  }

  @override
  void onPlayerRecvSEI(String streamID, Uint8List data) {
    final dataJson = utf8.decode(data.toList());
    try {
      final dataMap = jsonDecode(dataJson) as Map<String, dynamic>;
      final typeIdentifier =
          dataMap[ZegoUIKitSEIDefines.keyTypeIdentifier] as String;
      final sei = dataMap[ZegoUIKitSEIDefines.keySEI] as Map<String, dynamic>;
      final uid = dataMap[ZegoUIKitSEIDefines.keyUserID] as String;

      if (typeIdentifier == ZegoUIKitInnerSEIType.mixerDeviceState.name) {
        _updateMixerDeviceStateBySEI(streamID, uid, sei);
      } else if (typeIdentifier == ZegoUIKitInnerSEIType.mediaSyncInfo.name) {
        coreData.media.onMediaPlayerRecvSEIFromSDK(
          streamID,
          uid,
          sei,
        );
      }

      coreData.receiveSEIStreamCtrl?.add(
        ZegoUIKitReceiveSEIEvent(
          senderID: uid,
          streamID: streamID,
          streamType: coreData.getStreamTypeByID(streamID),
          typeIdentifier: typeIdentifier,
          sei: sei,
        ),
      );
    } catch (e) {
      ZegoLoggerService.logWarn(
        'onPlayerReceiveSEI, decode sei failed, sei: $dataJson, stream id:$streamID',
        tag: 'uikit-service-core',
        subTag: 'event',
      );
    }
  }

  void _updateMixerDeviceStateBySEI(
    String streamID,
    String userID,
    Map<String, dynamic> sei,
  ) {
    bool stateChanged = false;
    final cameraValue = sei[ZegoUIKitSEIDefines.keyCamera] ?? false;
    final microphoneValue = sei[ZegoUIKitSEIDefines.keyMicrophone] ?? false;
    if (coreData.mixerStreamDic.containsKey(streamID)) {
      final userIndex = coreData.mixerStreamDic[streamID]!.usersNotifier.value
          .indexWhere((user) => user.id == userID);
      if (userIndex == -1) {
        final user = ZegoUIKitCoreUser(userID, '');
        user.camera.value = cameraValue;
        user.microphone.value = microphoneValue;
        coreData.mixerStreamDic[streamID]!.addUser(user);

        stateChanged = true;
      } else {
        final user =
            coreData.mixerStreamDic[streamID]!.usersNotifier.value[userIndex];

        stateChanged = cameraValue != user.camera.value ||
            microphoneValue != user.microphone.value;

        user.camera.value = cameraValue;
        user.microphone.value = microphoneValue;
      }
    } else {
      final targetUserIndex =
          coreData.remoteUsersList.indexWhere((user) => userID == user.id);
      if (-1 != targetUserIndex) {
        stateChanged = cameraValue !=
                coreData.remoteUsersList[targetUserIndex].camera.value ||
            microphoneValue !=
                coreData.remoteUsersList[targetUserIndex].microphone.value;

        coreData.remoteUsersList[targetUserIndex].camera.value = cameraValue;
        coreData.remoteUsersList[targetUserIndex].microphone.value =
            microphoneValue;
      }
    }

    if (stateChanged) {
      /// notify outside to update audio video list
      coreData.notifyStreamListControl(coreData.getStreamTypeByID(streamID));
    }
  }
}
