// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/services/core/data/user.dart';
import 'package:zego_uikit/src/services/services.dart';
import '../core.dart';

/// 单房间的房间信息
/// @nodoc
class ZegoUIKitCoreDataSingleRoom {
  ZegoUIKitCoreDataSingleRoom(this.id) {
    ZegoLoggerService.logInfo(
      'room id:$id, ',
      tag: 'uikit-rooms-room',
      subTag: 'create',
    );
  }

  @override
  String toString() {
    return 'id:$id, '
        'state:${state.value.reason}, ';
  }

  bool get isLogin =>
      state.value.reason == ZegoUIKitSRoomStateChangedReason.Logining ||
      state.value.reason == ZegoUIKitSRoomStateChangedReason.Logined ||
      state.value.reason == ZegoUIKitSRoomStateChangedReason.Reconnecting ||
      state.value.reason == ZegoUIKitSRoomStateChangedReason.Reconnected;

  String id = '';

  bool isLargeRoom = false;
  bool markAsLargeRoom = false;

  ValueNotifier<ZegoUIKitRoomState> state = ValueNotifier<ZegoUIKitRoomState>(
    ZegoUIKitRoomState(ZegoRoomStateChangedReason.Logout, 0, {}),
  );

  bool roomExtraInfoHadArrived = false;
  Map<String, RoomProperty> properties = {};
  bool propertiesAPIRequesting = false;
  Map<String, String> pendingProperties = {};

  StreamController<RoomProperty>? propertyUpdateStream;
  StreamController<Map<String, RoomProperty>>? propertiesUpdatedStream;
  StreamController<int>? tokenExpiredStreamCtrl;

  ZegoUIKitCoreDataUser get _userCommonData =>
      ZegoUIKitCore.shared.coreData.user;

  void init() {
    ZegoLoggerService.logInfo(
      'room id:$id, ',
      tag: 'uikit-rooms-room',
      subTag: 'init',
    );

    propertyUpdateStream ??= StreamController<RoomProperty>.broadcast();
    propertiesUpdatedStream ??=
        StreamController<Map<String, RoomProperty>>.broadcast();
    tokenExpiredStreamCtrl ??= StreamController<int>.broadcast();
  }

  void uninit() {
    ZegoLoggerService.logInfo(
      'room id:$id, ',
      tag: 'uikit-rooms-room',
      subTag: 'uninit',
    );

    propertyUpdateStream?.close();
    propertyUpdateStream = null;

    propertiesUpdatedStream?.close();
    propertiesUpdatedStream = null;

    tokenExpiredStreamCtrl?.close();
    tokenExpiredStreamCtrl = null;
  }

  void clear() {
    ZegoLoggerService.logInfo(
      'room id:$id, ',
      tag: 'uikit-rooms-room',
      subTag: 'clear',
    );

    properties.clear();
    propertiesAPIRequesting = false;
    pendingProperties.clear();
  }

  Future<ZegoRoomLoginResult> join({
    required String targetRoomID,
    String token = '',
    bool markAsLargeRoom = false,
    bool isSimulated = false,
  }) async {
    this.markAsLargeRoom = markAsLargeRoom;

    ZegoLoggerService.logInfo(
      'joining, '
      'room id:"$id", '
      'markAsLargeRoom:$markAsLargeRoom, '
      'isSimulated:$isSimulated, ',
      tag: 'uikit-rooms-room',
      subTag: 'join',
    );

    if (isSimulated) {
      state.value.reason = ZegoUIKitSRoomStateChangedReason.Logined;
      return ZegoRoomLoginResult(0, {});
    }

    state.value.reason = ZegoUIKitSRoomStateChangedReason.Logining;
    final result = await ZegoExpressEngine.instance.loginRoom(
      targetRoomID,
      _userCommonData.localUser.toZegoUser(),
      config: ZegoRoomConfig(0, true, token),
    );
    ZegoLoggerService.logInfo(
      'result:${result.errorCode},'
      'extendedData:${result.extendedData}',
      tag: 'uikit-rooms-room',
      subTag: 'join',
    );

    return result;
  }

  Future<ZegoRoomLogoutResult> leave() async {
    ZegoLoggerService.logInfo(
      'leaving, '
      'room id:"$id", ',
      tag: 'uikit-rooms-room',
      subTag: 'leave',
    );

    final result = await ZegoExpressEngine.instance.logoutRoom(id);
    ZegoLoggerService.logInfo(
      'result:${result.errorCode},'
      'extendedData:${result.extendedData}',
      tag: 'uikit-rooms-room',
      subTag: 'leave',
    );

    if (result.errorCode == ZegoUIKitExpressErrorCode.CommonSuccess) {
      state.value.reason = ZegoUIKitSRoomStateChangedReason.Logout;
    }

    return result;
  }

  ZegoUIKitRoom toUIKitRoom() {
    return ZegoUIKitRoom(id: id);
  }
}
