// Project imports:
import 'package:zego_uikit/src/services/services.dart';

/// stream information to pull
class ZegoOutsideRoomAudioVideoViewStreamUser {
  ZegoUIKitUser user;
  String roomID;

  ZegoOutsideRoomAudioVideoViewStreamUser({
    required this.user,
    required this.roomID,
  });

  @override
  String toString() {
    return 'room id:$roomID, user id:${user.id}';
  }
}
