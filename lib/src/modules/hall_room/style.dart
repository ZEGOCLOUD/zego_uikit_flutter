// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/services/services.dart';

/// view style
class ZegoUIKitHallRoomListStyle {
  /// loading builder, return Container() if you want hide it
  final Widget? Function(BuildContext context)? loadingBuilder;

  ///  item style
  final ZegoUIKitHallRoomListItemStyle item;

  const ZegoUIKitHallRoomListStyle({
    this.loadingBuilder,
    this.item = const ZegoUIKitHallRoomListItemStyle(),
  });

  @override
  String toString() {
    return '{'
        'loadingBuilder:$loadingBuilder, '
        'item:$item, '
        '}';
  }
}

/// item style
class ZegoUIKitHallRoomListItemStyle {
  /// foreground builder, you can display something you want on top of the view,
  /// foreground will always show
  final Widget Function(
    BuildContext context,
    Size size,
    ZegoUIKitUser? user,
    String roomID,
  )? foregroundBuilder;

  /// background builder, you can display something when user close camera
  final Widget Function(
    BuildContext context,
    Size size,
    ZegoUIKitUser? user,
    String roomID,
  )? backgroundBuilder;

  /// loading builder, return Container() if you want hide it
  final Widget? Function(
    BuildContext context,
    ZegoUIKitUser? user,
    String roomID,
  )? loadingBuilder;

  /// custom avatar
  final ZegoAvatarConfig? avatar;

  const ZegoUIKitHallRoomListItemStyle({
    this.backgroundBuilder,
    this.foregroundBuilder,
    this.loadingBuilder,
    this.avatar,
  });

  @override
  String toString() {
    return '{'
        'backgroundBuilder:$backgroundBuilder, '
        'foregroundBuilder:$foregroundBuilder, '
        'loadingBuilder:$loadingBuilder, '
        'avatar:$avatar, '
        '}';
  }
}
