import 'package:zego_uikit/src/services/defines/audio_video/stream_type.dart';

/// @nodoc
const streamExtraInfoCameraKey = 'isCameraOn';

/// @nodoc
const streamExtraInfoMicrophoneKey = 'isMicrophoneOn';

/// @nodoc
String generateStreamID(String userID, String roomID, ZegoStreamType type) {
  return '${roomID}_${userID}_${type.text}';
}
