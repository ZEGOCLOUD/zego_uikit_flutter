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

  ZegoUIKitRoom({required this.id});

  @override
  String toString() {
    return 'ZegoUIKitRoom:{'
        'id:$id, '
        '}';
  }
}

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

class RoomProperty {
  String key = '';
  String value = '';
  String? oldValue;
  int updateTime = 0;
  String updateUserID = '';
  bool updateFromRemote = false;

  RoomProperty(
    this.key,
    this.value,
    this.updateTime,
    this.updateUserID,
    this.updateFromRemote,
  );

  RoomProperty.copyFrom(RoomProperty property)
      : key = property.key,
        value = property.value,
        oldValue = property.oldValue,
        updateTime = property.updateTime,
        updateUserID = property.updateUserID,
        updateFromRemote = property.updateFromRemote;

  void copyFrom(RoomProperty property) {
    key = property.key;
    value = property.value;
    oldValue = property.oldValue;
    updateTime = property.updateTime;
    updateUserID = property.updateUserID;
    updateFromRemote = property.updateFromRemote;
  }

  @override
  String toString() {
    return 'key:$key, value:$value, old value:$oldValue, update time:$updateTime, update user id:$updateUserID, update from remote:$updateFromRemote';
  }
}

enum RoomPropertyKey {
  host,
  liveStatus,
  liveDuration,
}

extension RoomPropertyKeyExtension on RoomPropertyKey {
  static Map<String, RoomPropertyKey> textValues = {
    'host': RoomPropertyKey.host,
    'live_status': RoomPropertyKey.liveStatus,
    'ld': RoomPropertyKey.liveDuration,
  };

  String get text {
    final mapValues = {
      RoomPropertyKey.host: 'host',
      RoomPropertyKey.liveStatus: 'live_status',
      RoomPropertyKey.liveDuration: 'ld',
    };

    return mapValues[this]!;
  }
}
