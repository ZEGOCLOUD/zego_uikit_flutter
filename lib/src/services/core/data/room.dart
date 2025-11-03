import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:zego_uikit/src/services/core/data/room_map.dart';
import 'package:zego_uikit/src/services/services.dart';

mixin ZegoUIKitCoreDataRoom {
  /// 具体房间对象在multiRooms.getRoom(roomID) 获取
  String currentRoomId = '';

  var multiRooms = ZegoUIKitCoreRoomMap<ZegoUIKitCoreRoomInfo>((String roomID) {
    return ZegoUIKitCoreRoomInfo(roomID);
  });
}

/// @nodoc
// room
class ZegoUIKitCoreRoomInfo {
  ZegoUIKitCoreRoomInfo(this.id) {
    ZegoLoggerService.logInfo(
      'create $id',
      tag: 'uikit-service-core',
      subTag: 'core room',
    );
  }

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

  void init() {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'uikit-service-core',
      subTag: 'core room',
    );

    propertyUpdateStream ??= StreamController<RoomProperty>.broadcast();
    propertiesUpdatedStream ??=
        StreamController<Map<String, RoomProperty>>.broadcast();
    tokenExpiredStreamCtrl ??= StreamController<int>.broadcast();
  }

  void uninit() {
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'uikit-service-core',
      subTag: 'core room',
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
      'clear',
      tag: 'uikit-service-core',
      subTag: 'core room',
    );

    id = '';

    properties.clear();
    propertiesAPIRequesting = false;
    pendingProperties.clear();
  }

  ZegoUIKitRoom toUIKitRoom() {
    return ZegoUIKitRoom(id: id);
  }
}
