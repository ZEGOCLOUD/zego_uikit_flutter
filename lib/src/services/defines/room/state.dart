import 'package:zego_express_engine/zego_express_engine.dart';

class ZegoUIKitRoomState {
  ///  Room state change reason.
  ZegoRoomStateChangedReason reason;

  /// Error code, please refer to the error codes document https://doc-en.zego.im/en/5548.html for details.
  int errorCode;

  /// Extended Information with state updates. When the room login is successful, the key "room_session_id" can be used to obtain the unique RoomSessionID of each audio and video communication, which identifies the continuous communication from the first user in the room to the end of the audio and video communication. It can be used in scenarios such as call quality scoring and call problem diagnosis.
  Map<String, dynamic> extendedData;

  ZegoUIKitRoomState(this.reason, this.errorCode, this.extendedData);

  @override
  String toString() {
    return 'ZegoUIKitRoomState:{'
        'reason:$reason, '
        'error code:$errorCode, '
        'extended data:$extendedData, '
        '}';
  }
}
