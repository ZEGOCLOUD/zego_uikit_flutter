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
