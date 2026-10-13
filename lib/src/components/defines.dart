// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/services/services.dart';

/// Describes the icon resources for Zego UIKit.
class ButtonIcon {
  /// The icon widget, which can be any widget.
  Widget? icon;

  /// The background color of the icon.
  Color? backgroundColor;

  ButtonIcon({this.icon, this.backgroundColor});
}

/// Specifies the alignment of an avatar.
enum ZegoAvatarAlignment {
  /// The avatar is centered.
  center,

  /// The avatar is aligned to the start.
  start,

  /// The avatar is aligned to the end.
  end,
}

/// A typedef for the avatar builder function.
///
/// This function is responsible for building the avatar widget based on the provided parameters.
///
/// - [context]: The build context.
/// - [size]: The size of the avatar.
/// - [user]: The ZegoUIKitUser representing the user associated with the avatar.
/// - [extraInfo]: Additional information as a key-value map.
///
/// The function should return a widget representing the avatar.
typedef ZegoAvatarBuilder =
    Widget? Function(
      BuildContext context,
      Size size,
      ZegoUIKitUser? user,
      Map<String, dynamic> extraInfo,
    );

/// Specifies the rules for showing the fullscreen mode toggle button.
enum ZegoShowFullscreenModeToggleButtonRules {
  /// The fullscreen mode toggle button is shown when press the the video widget.
  showWhenScreenPressed,

  /// The fullscreen mode toggle button is always shown.
  alwaysShow,

  /// The fullscreen mode toggle button is always hidden.
  alwaysHide,
}

/// Configuration for the avatar in Zego UI Kit.
class ZegoAvatarConfig {
  /// Determines whether the avatar should be shown in audio mode.
  final bool? showInAudioMode;

  /// Determines whether sound waves should be shown in audio mode.
  final bool? showSoundWavesInAudioMode;

  /// The vertical alignment of the avatar.
  final ZegoAvatarAlignment verticalAlignment;

  /// The size of the avatar.
  final Size? size;

  /// The color of the sound waves.
  final Color? soundWaveColor;

  /// The builder function for the avatar widget.
  final ZegoAvatarBuilder? builder;

  const ZegoAvatarConfig({
    this.showInAudioMode,
    this.showSoundWavesInAudioMode,
    this.verticalAlignment = ZegoAvatarAlignment.center,
    this.size,
    this.soundWaveColor,
    this.builder,
  });
}
