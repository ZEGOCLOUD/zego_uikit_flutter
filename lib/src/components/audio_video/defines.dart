// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/services/services.dart';

/// type of audio video view foreground builder
typedef ZegoAudioVideoViewForegroundBuilder =
    Widget Function(
      BuildContext context,
      Size size,
      ZegoUIKitUser? user,

      /// {ZegoViewBuilderMapExtraInfoKey:value}
      /// final value = extraInfo[ZegoViewBuilderMapExtraInfoKey.key.name]
      Map<String, dynamic> extraInfo,
    );

/// type of audio video view background builder
typedef ZegoAudioVideoViewBackgroundBuilder =
    Widget Function(
      BuildContext context,
      Size size,
      ZegoUIKitUser? user,

      /// {ZegoViewBuilderMapExtraInfoKey:value}
      /// final value = extraInfo[ZegoViewBuilderMapExtraInfoKey.key.name]
      Map<String, dynamic> extraInfo,
    );

/// sort
typedef ZegoAudioVideoViewSorter =
    List<ZegoUIKitUser> Function(List<ZegoUIKitUser>);

/// sort
typedef ZegoAudioVideoViewFilter =
    List<ZegoUIKitUser> Function(List<ZegoUIKitUser>);

enum ZegoViewBuilderMapExtraInfoKey {
  isScreenSharingView,
  isFullscreen,
  isVirtualUser,
}

enum ZegoShowToggleFullscreenButtonMode {
  showWhenScreenPressed,
  alwaysShow,
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
