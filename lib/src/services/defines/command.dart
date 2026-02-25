// Project imports:
import 'package:zego_uikit/src/services/defines/user/user.dart';

/// The keys below are not allowed to be modified because they are compatible with the web.

/// Command key for removing a user from room.
const removeUserInRoomCommandKey = 'zego_remove_user';

/// Command key for turning camera on.
const turnCameraOnInRoomCommandKey = 'zego_turn_camera_on';

/// Command key for turning camera off.
const turnCameraOffInRoomCommandKey = 'zego_turn_camera_off';

/// Command key for turning microphone on.
const turnMicrophoneOnInRoomCommandKey = 'zego_turn_microphone_on';

/// Command key for turning microphone off.
const turnMicrophoneOffInRoomCommandKey = 'zego_turn_microphone_off';

/// Command key for clearing room message.
const clearMessageInRoomCommandKey = 'zego_clear_message';

/// Command key for user ID.
const userIDCommandKey = 'zego_user_id';

/// Command key for mute mode.
const muteModeCommandKey = 'zego_mute_mode';

/// Data class for received in-room commands.
class ZegoInRoomCommandReceivedData {
  /// Room ID where the command was received.
  String roomID;

  /// User who sent the command.
  ZegoUIKitUser fromUser;

  /// The command content.
  String command;

  ZegoInRoomCommandReceivedData({
    required this.roomID,
    required this.fromUser,
    required this.command,
  });
}
