// Project imports:
import 'package:zego_uikit/src/services/defines/audio_video/audio_video.dart';

/// @nodoc
typedef ZegoUIKitUserAttributes = Map<String, String>;

/// @nodoc
extension ZegoUIKitUserAttributesExtension on ZegoUIKitUserAttributes {
  String get avatarURL {
    return this[attributeKeyAvatar] ?? '';
  }
}
