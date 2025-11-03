// Project imports:
import 'package:zego_uikit/src/services/defines/user/user.dart';

/// The keys below are not allowed to be modified because they are compatible with the web.

const removeUserInRoomCommandKey = 'zego_remove_user';

const turnCameraOnInRoomCommandKey = 'zego_turn_camera_on';

const turnCameraOffInRoomCommandKey = 'zego_turn_camera_off';

const turnMicrophoneOnInRoomCommandKey = 'zego_turn_microphone_on';

const turnMicrophoneOffInRoomCommandKey = 'zego_turn_microphone_off';

const clearMessageInRoomCommandKey = 'zego_clear_message';

const userIDCommandKey = 'zego_user_id';

const muteModeCommandKey = 'zego_mute_mode';

class ZegoInRoomCommandReceivedData {
  String roomID;
  ZegoUIKitUser fromUser;
  String command;

  ZegoInRoomCommandReceivedData({
    required this.roomID,
    required this.fromUser,
    required this.command,
  });
}
