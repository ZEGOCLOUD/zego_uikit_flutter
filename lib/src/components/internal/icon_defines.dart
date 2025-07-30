// Flutter imports:
import 'package:flutter/material.dart';

/// @nodoc
const controlBarButtonBackgroundColor = Colors.white;

/// @nodoc
final controlBarButtonCheckedBackgroundColor =
    const Color(0xff2C2F3E).withValues(alpha: 0.6);

/// @nodoc
class UIKitImage {
  static Image asset(
    String name, {
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return Image.asset(
      name,
      package: 'zego_uikit',
      width: width,
      height: height,
      fit: fit,
    );
  }
}

/// @nodoc
class StyleIconUrls {
  static const String iconS1ControlBarCameraNormal =
      'assets/icons/s1_ctrl_bar_camera_normal.png';
  static const String iconS1ControlBarCameraOff =
      'assets/icons/s1_ctrl_bar_camera_off.png';
  static const String iconS1ControlBarFlipCamera =
      'assets/icons/s1_ctrl_bar_flip_camera.png';
  static const String iconS1ControlBarMicrophoneNormal =
      'assets/icons/s1_ctrl_bar_mic_normal.png';
  static const String iconS1ControlBarMicrophoneOff =
      'assets/icons/s1_ctrl_bar_mic_off.png';

  static const String iconS1ControlBarEnd = 'assets/icons/s1_ctrl_bar_end.png';

  static const String iconS1ControlBarSpeakerNormal =
      'assets/icons/s1_ctrl_bar_speaker_normal.png';
  static const String iconS1ControlBarSpeakerOff =
      'assets/icons/s1_ctrl_bar_speaker_off.png';
  static const String iconS1ControlBarSpeakerBluetooth =
      'assets/icons/s1_ctrl_bar_speaker_bluetooth.png';

  static const String iconS1ControlBarMore =
      'assets/icons/s1_ctrl_bar_more_normal.png';
  static const String iconS1ControlBarMoreChecked =
      'assets/icons/s1_ctrl_bar_more_checked.png';

  static const String iconVideoViewCameraOff =
      'assets/icons/video_view_camera_off.png';
  static const String iconVideoViewCameraOn =
      'assets/icons/video_view_camera_on.png';
  static const String iconVideoViewMicrophoneOff =
      'assets/icons/video_view_mic_off.png';
  static const String iconVideoViewMicrophoneOn =
      'assets/icons/video_view_mic_on.png';
  static const String iconVideoViewMicrophoneSpeaking =
      'assets/icons/video_view_mic_speaking.png';
  static const String iconVideoViewWifi = 'assets/icons/video_view_wifi.png';

  static const String inviteVoice = 'assets/images/invite_voice.png';
  static const String inviteVideo = 'assets/images/invite_video.png';
  static const String inviteReject = 'assets/images/invite_reject.png';

  static const String iconNavClose = 'assets/icons/nav_close.png';
  static const String iconSend = 'assets/icons/send.png';
  static const String iconSendDisable = 'assets/icons/send_disable.png';

  static const String iconBack = 'assets/icons/back.png';

  static const String memberCameraNormal =
      'assets/icons/member_camera_normal.png';
  static const String memberCameraOff = 'assets/icons/member_camera_off.png';
  static const String memberMicNormal = 'assets/icons/member_mic_normal.png';
  static const String memberMicOff = 'assets/icons/member_mic_off.png';
  static const String memberMicSpeaking =
      'assets/icons/member_mic_speaking.png';

  static const String messageLoading = 'assets/icons/message_loading.png';
  static const String messageFail = 'assets/icons/message_fail.png';

  static const String iconScreenShareStart =
      'assets/icons/share_screen_start.png';
  static const String iconScreenShareStop =
      'assets/icons/share_screen_stop.png';

  static const String iconVideoViewFullScreenClose =
      'assets/icons/video_view_full_screen_close.png';
  static const String iconVideoViewFullScreenOpen =
      'assets/icons/video_view_full_screen_open.png';
}
