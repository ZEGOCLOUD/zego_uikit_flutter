// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/services/services.dart';

/// type of audio video view foreground builder
typedef ZegoAudioVideoViewForegroundBuilder = Widget Function(
  BuildContext context,
  Size size,
  ZegoUIKitUser? user,

  /// {ZegoViewBuilderMapExtraInfoKey:value}
  /// final value = extraInfo[ZegoViewBuilderMapExtraInfoKey.key.name]
  Map<String, dynamic> extraInfo,
);

/// type of audio video view background builder
typedef ZegoAudioVideoViewBackgroundBuilder = Widget Function(
  BuildContext context,
  Size size,
  ZegoUIKitUser? user,

  /// {ZegoViewBuilderMapExtraInfoKey:value}
  /// final value = extraInfo[ZegoViewBuilderMapExtraInfoKey.key.name]
  Map<String, dynamic> extraInfo,
);

/// sort
typedef ZegoAudioVideoViewSorter = List<ZegoUIKitUser> Function(
    List<ZegoUIKitUser>);

/// sort
typedef ZegoAudioVideoViewFilter = List<ZegoUIKitUser> Function(
    List<ZegoUIKitUser>);

/// Keys for extra information passed to audio video view builders.
///
/// Used to pass additional context to background and foreground builders.
enum ZegoViewBuilderMapExtraInfoKey {
  /// Whether the view is for screen sharing.
  isScreenSharingView,
  /// Whether the view is in fullscreen mode.
  isFullscreen,
  /// Whether the view is a virtual user (AI agent).
  isVirtualUser,
}

/// Mode for showing/hiding the fullscreen toggle button.
enum ZegoShowToggleFullscreenButtonMode {
  /// Show button when screen is pressed.
  showWhenScreenPressed,
  /// Always show the button.
  alwaysShow,
  /// Always hide the button.
  alwaysHide,
}

extension ZegoViewBuilderMapExtraInfoKeyExtension
    on ZegoViewBuilderMapExtraInfoKey {
  String get text {
    final mapValues = {
      ZegoViewBuilderMapExtraInfoKey.isScreenSharingView:
          'is_screen_sharing_view',
      ZegoViewBuilderMapExtraInfoKey.isFullscreen: 'is_fullscreen',
      ZegoViewBuilderMapExtraInfoKey.isVirtualUser: 'is_virtual_user',
    };

    return mapValues[this]!;
  }
}
