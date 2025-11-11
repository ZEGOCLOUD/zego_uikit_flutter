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

/// 由于多房间的当前ID不可知，需要外部指定
typedef CurrentRoomIDQueryFuncInMultiRoomMode = String Function(List<String>);
