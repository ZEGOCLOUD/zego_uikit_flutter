// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

class ZegoUIKitRoomStatusResult {
  String id;
  ZegoRoomStateChangedReason reason;

  ZegoUIKitRoomStatusResult({
    required this.id,
    required this.reason,
  });
}

class ZegoUIKitRoom {
  String id = '';
  bool isLogin = false;

  ZegoUIKitRoom({
    required this.id,
    required this.isLogin,
  });

  static ZegoUIKitRoom empty() {
    return ZegoUIKitRoom(
      id: '',
      isLogin: false,
    );
  }

  @override
  String toString() {
    return 'ZegoUIKitRoom:{'
        'id:$id, '
        'isLogin:$isLogin, '
        '}';
  }
}

/// Since current ID in multi-room mode is unknown, needs to be specified externally
typedef CurrentRoomIDQueryFuncInMultiRoomMode = String Function(List<String>);
