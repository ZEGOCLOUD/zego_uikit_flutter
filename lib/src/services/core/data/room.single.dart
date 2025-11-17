// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/services/services.dart';
import '../core.dart';
import 'user.dart';

/// Room information for single room
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
    return 'ZegoUIKitCoreDataSingleRoom{\n'
        'id:$id, '
        'state:${state.value.reason}, '
        '}\n';
  }

  bool get isLogin =>
      state.value.reason == ZegoUIKitRoomStateChangedReason.Logining ||
      state.value.reason == ZegoUIKitRoomStateChangedReason.Logined ||
      state.value.reason == ZegoUIKitRoomStateChangedReason.Reconnecting ||
      state.value.reason == ZegoUIKitRoomStateChangedReason.Reconnected;

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
      'hash:$hashCode, '
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
      'hash:$hashCode, '
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
      'hash:$hashCode, '
      'room id:$id, ',
      tag: 'uikit-rooms-room',
      subTag: 'clear',
    );

    properties.clear();
    propertiesAPIRequesting = false;
    pendingProperties.clear();
  }

  Future<ZegoUIKitRoomLoginResult> join({
    required String targetRoomID,
    String token = '',
    bool markAsLargeRoom = false,
    bool isSimulated = false,
  }) async {
    this.markAsLargeRoom = markAsLargeRoom;

    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:"$id", '
      'joining, '
      'markAsLargeRoom:$markAsLargeRoom, '
      'isSimulated:$isSimulated, ',
      tag: 'uikit-rooms-room',
      subTag: 'join room',
    );

    if (isSimulated) {
      state.value.reason = ZegoUIKitRoomStateChangedReason.Logined;
      return ZegoUIKitRoomLoginResult(
          ZegoUIKitExpressErrorCode.CommonSuccess, {});
    }

    state.value.reason = ZegoUIKitRoomStateChangedReason.Logining;
    final result = await ZegoExpressEngine.instance.loginRoom(
      targetRoomID,
      _userCommonData.localUser.toZegoUser(),
      config: ZegoRoomConfig(0, true, token),
    );
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:"$id", '
      'result:${result.errorCode},'
      'extendedData:${result.extendedData}',
      tag: 'uikit-rooms-room',
      subTag: 'join room',
    );

    return ZegoUIKitRoomLoginResult(result.errorCode, result.extendedData);
  }

  Future<ZegoRoomLogoutResult> leave() async {
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:"$id", '
      'leaving, ',
      tag: 'uikit-rooms-room',
      subTag: 'leave room',
    );

    if (ZegoUIKitRoomStateChangedReason.Logout == state.value.reason) {
      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'room id:"$id", '
        'room state is logout, ignore, ',
        tag: 'uikit-rooms-room',
        subTag: 'leave room',
      );

      return ZegoRoomLogoutResult(ZegoUIKitExpressErrorCode.CommonSuccess, {});
    }

    final result = await ZegoExpressEngine.instance.logoutRoom(id);
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:"$id", '
      'result:${result.errorCode},'
      'extendedData:${result.extendedData}',
      tag: 'uikit-rooms-room',
      subTag: 'leave room',
    );

    if (result.errorCode == ZegoUIKitExpressErrorCode.CommonSuccess) {
      state.value.reason = ZegoUIKitRoomStateChangedReason.Logout;
    } else {
      state.value.reason = ZegoUIKitRoomStateChangedReason.LogoutFailed;
    }

    return result;
  }

  ZegoUIKitRoom toUIKitRoom() {
    return ZegoUIKitRoom(
      id: id,
      isLogin: isLogin,
    );
  }
}
