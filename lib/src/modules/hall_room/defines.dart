// Project imports:
import 'package:zego_uikit/src/services/services.dart';

/// stream information to pull
class ZegoUIKitHallRoomListStreamUser {
  ZegoUIKitUser user;
  String roomID;

  ZegoUIKitHallRoomListStreamUser({
    required this.user,
    required this.roomID,
  });

  @override
  String toString() {
    return 'room id:$roomID, user id:${user.id}';
  }
}
