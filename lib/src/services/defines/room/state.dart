// Package imports:

// Project imports:
import 'package:zego_uikit/src/services/defines/express.dart';

/// multi room state
class ZegoUIKitRoomsState {
  /// < roomID, state >
  Map<String, ZegoUIKitRoomState> states = {};
}

/// single room state
class ZegoUIKitRoomState {
  ///  Room state change reason.
  ZegoUIKitRoomStateChangedReason reason;

  /// Error code, please refer to the error codes document https://doc-en.zego.im/en/5548.html for details.
  int errorCode;

  /// Extended Information with state updates. When the room login is successful, the key "room_session_id" can be used to obtain the unique RoomSessionID of each audio and video communication, which identifies the continuous communication from the first user in the room to the end of the audio and video communication. It can be used in scenarios such as call quality scoring and call problem diagnosis.
  Map<String, dynamic> extendedData;

  ZegoUIKitRoomState(this.reason, this.errorCode, this.extendedData);

  bool get isInternalLogin =>
      reason == ZegoUIKitRoomStateChangedReason.Logining ||
      reason == ZegoUIKitRoomStateChangedReason.Logined ||
      reason == ZegoUIKitRoomStateChangedReason.Reconnected;

  bool get isLogin2 =>
      reason == ZegoUIKitRoomStateChangedReason.Logined ||
      reason == ZegoUIKitRoomStateChangedReason.Reconnected;

  @override
  String toString() {
    return 'ZegoUIKitRoomState:{'
        'reason:$reason, '
        'error code:$errorCode, '
        'extended data:$extendedData, '
        '}';
  }
}
