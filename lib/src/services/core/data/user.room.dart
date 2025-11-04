// Dart imports:
import 'dart:async';

// Project imports:
import 'package:zego_uikit/src/services/core/core.dart';
import 'package:zego_uikit/src/services/core/data/room_map.dart';
import 'package:zego_uikit/src/services/services.dart';
import '../defines/defines.dart';

class ZegoUIKitCoreDataRoomUser {
  String roomID;
  ZegoUIKitCoreDataRoomUser(this.roomID);

  final List<ZegoUIKitCoreUser> remoteUsers = [];

  StreamController<List<ZegoUIKitCoreUser>>? get joinStreamCtrl {
    _joinStreamCtrl ??= StreamController<List<ZegoUIKitCoreUser>>.broadcast();
    return _joinStreamCtrl;
  }

  StreamController<List<ZegoUIKitCoreUser>>? get leaveStreamCtrl {
    _leaveStreamCtrl ??= StreamController<List<ZegoUIKitCoreUser>>.broadcast();
    return _leaveStreamCtrl;
  }

  StreamController<List<ZegoUIKitCoreUser>>? get listStreamCtrl {
    _listStreamCtrl ??= StreamController<List<ZegoUIKitCoreUser>>.broadcast();
    return _listStreamCtrl;
  }

  /// local user been kick-out by some reason
  StreamController<String>? get meRemovedFromRoomStreamCtrl {
    _meRemovedFromRoomStreamCtrl ??= StreamController<String>.broadcast();
    return _meRemovedFromRoomStreamCtrl;
  }

  void init() {
    ZegoLoggerService.logInfo(
      'room id:$roomID',
      tag: 'uikit-users-room',
      subTag: 'init',
    );

    _joinStreamCtrl ??= StreamController<List<ZegoUIKitCoreUser>>.broadcast();
    _leaveStreamCtrl ??= StreamController<List<ZegoUIKitCoreUser>>.broadcast();
    _listStreamCtrl ??= StreamController<List<ZegoUIKitCoreUser>>.broadcast();
    _meRemovedFromRoomStreamCtrl ??= StreamController<String>.broadcast();
  }

  void uninit() {
    ZegoLoggerService.logInfo(
      'room id:$roomID',
      tag: 'uikit-users-room',
      subTag: 'uninit',
    );

    _joinStreamCtrl?.close();
    _joinStreamCtrl = null;

    _leaveStreamCtrl?.close();
    _leaveStreamCtrl = null;

    _listStreamCtrl?.close();
    _listStreamCtrl = null;

    _meRemovedFromRoomStreamCtrl?.close();
    _meRemovedFromRoomStreamCtrl = null;
  }

  void clear() {
    ZegoLoggerService.logInfo(
      'room id:$roomID',
      tag: 'uikit-users-room',
      subTag: 'clear',
    );
  }

  StreamController<List<ZegoUIKitCoreUser>>? _joinStreamCtrl;
  StreamController<List<ZegoUIKitCoreUser>>? _leaveStreamCtrl;
  StreamController<List<ZegoUIKitCoreUser>>? _listStreamCtrl;
  StreamController<String>? _meRemovedFromRoomStreamCtrl;
}
