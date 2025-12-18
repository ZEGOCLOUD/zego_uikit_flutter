// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
// Package imports:
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:zego_uikit/src/services/core/core.dart';
import 'package:zego_uikit/src/services/services.dart';

import 'data.dart';
import 'device.dart';
import 'room.single.dart';
import 'room_map.dart';
import 'stream.dart';
import 'user.dart';

/// Multi-room room information
/// @nodoc
class ZegoUIKitCoreDataRoom {
  /// Specific room object can be obtained via multiRooms.getRoom(roomID)
  bool isNeedDisableWakelock = false;

  String get currentID {
    String loginRoomID = '';
    rooms.forEachSync((roomID, roomInfo) {
      if (loginRoomID.isNotEmpty) {
        return;
      }
      if (roomInfo.isLogin) {
        loginRoomID = roomID;
      }
    });
    return loginRoomID;
  }

  bool get hasLogin => currentID.isNotEmpty;

  final roomsStateNotifier = ValueNotifier<Map<String, ZegoUIKitRoomState>>({});
  var rooms = ZegoUIKitCoreRoomMap<ZegoUIKitCoreDataSingleRoom>(
    name: 'core data room',
    createDefault: (String roomID) {
      final room = ZegoUIKitCoreDataSingleRoom(roomID);
      room.init();
      return room;
    },
    onUpgradeEmptyRoom: (ZegoUIKitCoreDataSingleRoom emptyRoom, roomID) {
      // When prepared room is upgraded, update its roomID
      emptyRoom.id = roomID;
      ZegoLoggerService.logInfo(
        'empty room(${emptyRoom.hashCode}) has update id to $roomID, ',
        tag: 'uikit.rooms',
        subTag: 'room-map',
      );
    },
  );

  ZegoUIKitCoreData get _coreData => ZegoUIKitCore.shared.coreData;

  ZegoUIKitCoreDataStream get _streamCommonData => _coreData.stream;

  ZegoUIKitCoreDataUser get _userCommonData => _coreData.user;

  ZegoUIKitCoreDataDevice get _deviceCommonData => _coreData.device;

  void init() {
    ZegoLoggerService.logInfo(
      'init, ',
      tag: 'uikit.rooms',
      subTag: 'uninit',
    );

    rooms.forEachSync((roomID, roomInfo) {
      roomInfo.init();
    });
  }

  Future<void> uninit() async {
    ZegoLoggerService.logInfo(
      'uninit, ',
      tag: 'uikit.rooms',
      subTag: 'uninit',
    );

    await rooms.forEachAsync((roomID, roomInfo) async {
      await roomInfo.leave();
      roomInfo.uninit();
    });
  }

  void clear({
    required String targetRoomID,
  }) {
    if (rooms.containsRoom(targetRoomID)) {
      rooms.getRoom(targetRoomID).clear();
    }
    rooms.removeRoom(targetRoomID);
  }

  Future<ZegoUIKitRoomLoginResult> join({
    required String targetRoomID,
    String token = '',
    bool markAsLargeRoom = false,
    bool keepWakeScreen = true,
    bool isSimulated = false,
    bool tryReLoginIfCountExceed = false,
  }) async {
    ZegoLoggerService.logInfo(
      'try join room, '
      'target room id:"$targetRoomID", '
      'current room id:$currentID, '
      'has token:${token.isNotEmpty}, '
      'markAsLargeRoom:$markAsLargeRoom, '
      'network state:${ZegoUIKit().getNetworkState()}, ',
      tag: 'uikit.rooms',
      subTag: 'join room',
    );

    if (targetRoomID.isEmpty) {
      ZegoLoggerService.logError(
        'target room id is empty',
        tag: 'uikit.rooms',
        subTag: 'join room',
      );

      return ZegoUIKitRoomLoginResult(ZegoUIKitErrorCode.paramsInvalid, {});
    }

    if (currentID == targetRoomID) {
      ZegoLoggerService.logInfo(
        'same room',
        tag: 'uikit.rooms',
        subTag: 'join room',
      );

      return ZegoUIKitRoomLoginResult(ZegoUIKitErrorCode.success, {});
    }

    if (currentID.isNotEmpty) {
      ZegoLoggerService.logInfo(
        'has join room($currentID), leaving first...',
        tag: 'uikit.rooms',
        subTag: 'join room',
      );

      await leave(targetRoomID: currentID);
    }

    final result = await rooms.getRoom(targetRoomID).join(
          targetRoomID: targetRoomID,
          token: token,
          markAsLargeRoom: markAsLargeRoom,
          isSimulated: isSimulated,
        );

    if (ZegoUIKitExpressErrorCode.CommonSuccess == result.errorCode) {
      enableWakeLock();

      await _streamCommonData.roomStreams
          .getRoom(targetRoomID)
          .startPublishOrNot();
      await _deviceCommonData.syncDeviceStatusByStreamExtraInfo(
        targetRoomID: targetRoomID,
        streamType: ZegoStreamType.main,
      );

      if (isSimulated) {
        /// at this time, express will not throw the stream event again,
        /// and it is necessary to actively obtain
        await _streamCommonData.roomStreams
            .getRoom(targetRoomID)
            .syncRoomStream();
      }

      await ZegoExpressEngine.instance.startSoundLevelMonitor();
    } else {
      if (result.errorCode == ZegoErrorCode.RoomCountExceed) {
        ZegoLoggerService.logInfo(
          'room count exceed',
          tag: 'uikit.rooms',
          subTag: 'join room',
        );

        await leave(targetRoomID: targetRoomID);
        return join(
          targetRoomID: targetRoomID,
          token: token,
          markAsLargeRoom: markAsLargeRoom,
          keepWakeScreen: keepWakeScreen,
          isSimulated: isSimulated,
          tryReLoginIfCountExceed: false,
        );
      }
    }

    return result;
  }

  Future<ZegoUIKitRoomLoginResult> switchTo({
    required String toRoomID,
    required bool stopPublishAllStream,
    required bool stopPlayAllStream,
    String token = '',
    bool clearStreamData = true,
    bool clearUserData = true,
  }) async {
    final fromRoomID = currentID;
    ZegoLoggerService.logInfo(
      'from room id:$fromRoomID, '
      'to room id:"$toRoomID", '
      'stopPublishAllStream:$stopPublishAllStream, '
      'stopPlayAllStream:$stopPlayAllStream, '
      'network state:${ZegoUIKit().getNetworkState()}, ',
      tag: 'uikit.rooms',
      subTag: 'switch room',
    );

    if (!rooms.getRoom(fromRoomID).isLogin) {
      ZegoLoggerService.logError(
        'current room is not login,',
        tag: 'uikit.rooms',
        subTag: 'switch room',
      );

      return ZegoUIKitRoomLoginResult(ZegoUIKitErrorCode.roomNotLogin, {});
    }

    if (toRoomID.isEmpty || fromRoomID == toRoomID) {
      ZegoLoggerService.logError(
        'room id is not valid',
        tag: 'uikit.rooms',
        subTag: 'switch room',
      );

      return ZegoUIKitRoomLoginResult(ZegoUIKitErrorCode.paramsInvalid, {});
    }

    rooms.getRoom(fromRoomID).state.value.reason =
        ZegoUIKitRoomStateChangedReason.Logout;
    rooms.getRoom(toRoomID).state.value.reason =
        ZegoUIKitRoomStateChangedReason.Logining;
    await ZegoExpressEngine.instance.switchRoom(
      fromRoomID,
      toRoomID,
      config: ZegoRoomConfig(0, true, token),
    );

    /// cannot clear user and stream,
    /// otherwise when sliding during the LIVE broadcast,
    /// it will be necessary to re-initiate pull-based streaming to construct the texture
    _coreData.clear(
      targetRoomID: fromRoomID,
      stopPublishAllStream: stopPublishAllStream,
      stopPlayAllStream: stopPlayAllStream,
      clearStream: clearStreamData,
      clearUser: clearUserData,
    );

    ZegoLoggerService.logInfo(
      'done, ',
      tag: 'uikit.rooms',
      subTag: 'switch room',
    );

    return ZegoUIKitRoomLoginResult(ZegoUIKitErrorCode.success, {});
  }

  Future<ZegoUIKitRoomLogoutResult> leave({
    required String targetRoomID,
  }) async {
    ZegoLoggerService.logInfo(
      'try leave room, '
      'target room id:"$targetRoomID", '
      'network state:${ZegoUIKit().getNetworkState()}, ',
      tag: 'uikit.rooms',
      subTag: 'leave room',
    );

    clearAfterLeave() async {
      _coreData.clear(
        targetRoomID: targetRoomID,
        stopPublishAllStream: true,
        stopPlayAllStream: true,
      );

      if (hasLogin) {
        /// Still have rooms in login state
      } else {
        /// No rooms in login state
        disableWakeLock();

        _userCommonData.localUser.clearRoomAttribute();
        _streamCommonData.canvasViewCreateQueue.clear();

        await ZegoExpressEngine.instance.stopSoundLevelMonitor();
      }
    }

    if (!rooms.allRoomIDs.contains(targetRoomID)) {
      ZegoLoggerService.logInfo(
        'room id is not exist, not need to leave',
        tag: 'uikit.rooms',
        subTag: 'leave room',
      );

      await clearAfterLeave();
      return ZegoUIKitRoomLogoutResult(ZegoUIKitErrorCode.success, {});
    }

    final result = await rooms.getRoom(targetRoomID).leave();

    await clearAfterLeave();
    return ZegoUIKitRoomLogoutResult(result.errorCode, result.extendedData);
  }

  Future<void> renewToken(
    String token, {
    required String targetRoomID,
  }) async {
    if (currentID.isEmpty) {
      ZegoLoggerService.logInfo(
        'not in room now',
        tag: 'uikit.rooms',
        subTag: 'renewToken',
      );
    }

    if (token.isEmpty) {
      ZegoLoggerService.logInfo(
        'token is empty',
        tag: 'uikit.rooms',
        subTag: 'renewToken',
      );
    }

    ZegoLoggerService.logInfo(
      'renew now',
      tag: 'uikit.rooms',
      subTag: 'renewToken',
    );

    await ZegoExpressEngine.instance.renewToken(
      targetRoomID,
      token,
    );
  }

  void syncRoomsState() {
    Map<String, ZegoUIKitRoomState> roomsState = {};
    rooms.forEachSync((roomID, room) {
      roomsState[roomID] = room.state.value;
    });

    roomsStateNotifier.value = roomsState;
  }

  Future<void> enableWakeLock() async {
    final originWakelockEnabled = await WakelockPlus.enabled;
    if (originWakelockEnabled) {
      isNeedDisableWakelock = false;
    } else {
      isNeedDisableWakelock = true;
      WakelockPlus.enable();
    }
  }

  void disableWakeLock() {
    if (isNeedDisableWakelock) {
      WakelockPlus.disable();

      isNeedDisableWakelock = false;
    }
  }
}
