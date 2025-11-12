// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/services/services.dart';
import 'package:zego_uikit/src/modules/hall_room/internal.dart';
import 'package:zego_uikit/src/services/core/core.dart';
import 'package:zego_uikit/src/services/core/defines/room.dart';

import 'room.single.dart';
import 'data.dart';
import 'device.dart';
import 'room_map.dart';
import 'stream.dart';
import 'user.dart';

/// 多房间的房间信息
/// @nodoc
class ZegoUIKitCoreDataRoom {
  /// 具体房间对象在multiRooms.getRoom(roomID) 获取
  ZegoUIKitRoomMode mode = ZegoUIKitRoomMode.SingleRoom;
  bool isNeedDisableWakelock = false;

  CurrentRoomIDQueryFuncInMultiRoomMode? currentIDQueryOfMultiRoom;
  String get currentID {
    final tempLoginRoomIDs = loginRoomIDs;
    if (mode == ZegoUIKitRoomMode.SingleRoom) {
      return tempLoginRoomIDs.isNotEmpty ? tempLoginRoomIDs.first : '';
    }

    assert(null != currentIDQueryOfMultiRoom);

    /// 多房间的当前ID不可知，需要外部指定
    return currentIDQueryOfMultiRoom?.call(tempLoginRoomIDs) ?? '';
  }

  final roomsStateNotifier = ValueNotifier<ZegoUIKitRoomsState>(
    ZegoUIKitRoomsState(),
  );
  var rooms = ZegoUIKitCoreRoomMap<ZegoUIKitCoreDataSingleRoom>(
    name: 'core data room',
    createDefault: (String roomID) {
      final room = ZegoUIKitCoreDataSingleRoom(roomID);
      room.init();
      return room;
    },
    onUpgradeEmptyRoom: (ZegoUIKitCoreDataSingleRoom emptyRoom, roomID) {
      // 当预备房间被升级时，更新其 roomID
      emptyRoom.id = roomID;
      ZegoLoggerService.logInfo(
        'empty room(${emptyRoom.hashCode}) has update id to $roomID, ',
        tag: 'uikit-rooms',
        subTag: 'room-map',
      );
    },
  );

  /// 缓存已登录的房间ID列表，避免频繁遍历
  List<String> _cachedLoginRoomIDs = [];

  /// 标记缓存是否有效
  bool _loginRoomIDsCacheDirty = true;

  bool get hasLogin => loginCount > 0;

  int get loginCount => loginRoomIDs.length;

  /// 获取已登录的房间ID列表（带缓存优化）
  List<String> get loginRoomIDs {
    if (!_loginRoomIDsCacheDirty) {
      return List.from(_cachedLoginRoomIDs); // 返回副本，避免外部修改
    }

    List<String> roomIDs = [];

    rooms.forEachSync((roomID, room) {
      if (room.isLogin) {
        roomIDs.add(roomID);
      }
    });

    _cachedLoginRoomIDs = roomIDs;
    _loginRoomIDsCacheDirty = false;

    return List.from(roomIDs); // 返回副本，避免外部修改
  }

  /// 标记登录房间列表缓存为脏，下次访问时重新计算
  void _markLoginRoomIDsCacheDirty() {
    _loginRoomIDsCacheDirty = true;
  }

  ZegoUIKitCoreData get _coreData => ZegoUIKitCore.shared.coreData;
  ZegoUIKitCoreDataStream get _streamCommonData => _coreData.stream;
  ZegoUIKitCoreDataUser get _userCommonData => _coreData.user;
  ZegoUIKitCoreDataDevice get _deviceCommonData => _coreData.device;

  void init({
    ZegoUIKitRoomMode roomMode = ZegoUIKitRoomMode.SingleRoom,
  }) {
    ZegoLoggerService.logInfo(
      'init, ',
      tag: 'uikit-rooms',
      subTag: 'uninit',
    );

    mode = roomMode;
    rooms.forEachSync((roomID, roomInfo) {
      roomInfo.init();
    });
  }

  Future<void> uninit() async {
    ZegoLoggerService.logInfo(
      'uninit, ',
      tag: 'uikit-rooms',
      subTag: 'uninit',
    );

    mode = ZegoUIKitRoomMode.SingleRoom;
    await rooms.forEachAsync((roomID, roomInfo) async {
      await roomInfo.leave();
      roomInfo.uninit();
    });

    // 所有房间都已退出，标记缓存失效
    _markLoginRoomIDsCacheDirty();
  }

  void clear({
    required String targetRoomID,
  }) {
    if (rooms.containsRoom(targetRoomID)) {
      rooms.getRoom(targetRoomID).clear();
    }

    // 房间状态可能改变，标记缓存失效
    _markLoginRoomIDsCacheDirty();
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
      'mode:$mode, '
      'target room id:"$targetRoomID", '
      'has token:${token.isNotEmpty}, '
      'markAsLargeRoom:$markAsLargeRoom, '
      'network state:${ZegoUIKit().getNetworkState()}, ',
      tag: 'uikit-rooms',
      subTag: 'join',
    );

    if (targetRoomID.isEmpty) {
      ZegoLoggerService.logError(
        'target room id is empty',
        tag: 'uikit-rooms',
        subTag: 'join',
      );

      return ZegoUIKitRoomLoginResult(ZegoUIKitErrorCode.paramsInvalid, {});
    }

    if (loginRoomIDs.contains(targetRoomID)) {
      ZegoLoggerService.logInfo(
        'already in room, ignore, '
        'room id:$targetRoomID, '
        'room:$rooms, ',
        tag: 'uikit-rooms',
        subTag: 'join',
      );

      return ZegoUIKitRoomLoginResult(ZegoUIKitErrorCode.success, {});
    }

    if (currentID.isNotEmpty && mode == ZegoRoomMode.SingleRoom) {
      /// clear old room data
      /// todo 转移host给直播大厅
      _coreData.clear(
        targetRoomID: currentID,
        stopPlayingAnotherRoomStream: true,
      );

      if (ZegoUIKitHallRoomIDHelper.isRandomRoomID(currentID)) {
        ZegoLoggerService.logInfo(
          'has join outside room, leaving first...',
          tag: 'uikit-rooms',
          subTag: 'join',
        );

        await leave(
          targetRoomID: currentID,
          stopPlayingAnotherRoomStream: false,
        );
      }
    }

    final hasRoomLoginBefore = hasLogin;

    // 房间登录状态可能改变，标记缓存失效
    _markLoginRoomIDsCacheDirty();

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
      await _deviceCommonData.syncDeviceStatusByStreamExtraInfo();

      if (isSimulated) {
        /// at this time, express will not throw the stream event again,
        /// and it is necessary to actively obtain
        await _streamCommonData.roomStreams
            .getRoom(targetRoomID)
            .syncRoomStream();
      }

      if (!hasRoomLoginBefore) {
        await ZegoExpressEngine.instance.startSoundLevelMonitor();
      }
    } else {
      if (result.errorCode == ZegoErrorCode.RoomCountExceed) {
        ZegoLoggerService.logInfo(
          'room count exceed',
          tag: 'uikit-rooms',
          subTag: 'join room',
        );

        if (ZegoUIKitRoomMode.SingleRoom == mode) {
          /// 单房间，退房重进
          await leave(
            targetRoomID: targetRoomID,
            stopPlayingAnotherRoomStream: true,
          );
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
    }

    return result;
  }

  Future<ZegoUIKitRoomLogoutResult> leave({
    required String targetRoomID,
    required bool stopPlayingAnotherRoomStream,
  }) async {
    ZegoLoggerService.logInfo(
      'try leave room, '
      'mode:$mode, '
      'target room id:"$targetRoomID", '
      'network state:${ZegoUIKit().getNetworkState()}, ',
      tag: 'uikit-rooms',
      subTag: 'leave',
    );

    clearAfterLeave() async {
      if (hasLogin) {
        /// 还有房间处于登录中
      } else {
        /// 没有任何房间登录中
        disableWakeLock();

        _userCommonData.localUser.clearRoomAttribute();
        _streamCommonData.canvasViewCreateQueue.clear();

        await ZegoExpressEngine.instance.stopSoundLevelMonitor();
      }
    }

    if (!rooms.allRoomIDs.contains(targetRoomID)) {
      ZegoLoggerService.logInfo(
        'room id is not exist, not need to leave',
        tag: 'uikit-rooms',
        subTag: 'leave',
      );

      await clearAfterLeave();
      return ZegoUIKitRoomLogoutResult(ZegoUIKitErrorCode.success, {});
    }

    /// todo 转移host给直播大厅
    _coreData.clear(
      targetRoomID: targetRoomID,
      stopPlayingAnotherRoomStream: stopPlayingAnotherRoomStream,
    );

    final result = await rooms.getRoom(targetRoomID).leave();
    rooms.removeRoom(targetRoomID);

    // 房间登录状态改变，标记缓存失效
    _markLoginRoomIDsCacheDirty();

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
        tag: 'uikit-rooms',
        subTag: 'renewToken',
      );
    }

    if (token.isEmpty) {
      ZegoLoggerService.logInfo(
        'token is empty',
        tag: 'uikit-rooms',
        subTag: 'renewToken',
      );
    }

    ZegoLoggerService.logInfo(
      'renew now',
      tag: 'uikit-rooms',
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

    roomsStateNotifier.value.states = roomsState;
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
