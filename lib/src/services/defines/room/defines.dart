// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

/// Represents the room status result with ID and state change reason.
///
/// This class is used to return the current status of a room.
class ZegoUIKitRoomStatusResult {
  /// Room ID.
  String id;

  /// The reason for room state change.
  ZegoRoomStateChangedReason reason;

  ZegoUIKitRoomStatusResult({
    required this.id,
    required this.reason,
  });
}

/// Represents a Zego room with ID and login status.
///
/// This class contains basic information about a room.
class ZegoUIKitRoom {
  /// Room ID.
  String id = '';

  /// Whether the user is currently logged in to this room.
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
    return '{'
        'id:$id, '
        'isLogin:$isLogin, '
        '}';
  }
}

/// Since current ID in multi-room mode is unknown, needs to be specified externally
typedef CurrentRoomIDQueryFuncInMultiRoomMode = String Function(List<String>);
