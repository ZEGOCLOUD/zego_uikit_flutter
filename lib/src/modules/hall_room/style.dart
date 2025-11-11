// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/services/services.dart';

/// view style
class ZegoUIKitHallRoomListStyle {
  /// scroll direction, default is horizontal
  final Axis scrollDirection;

  /// How many rows and columns should be placed in the specified direction?
  /// For example, the horizontal direction represents how many rows there are, and the vertical direction represents how many columns there are
  final int scrollAxisCount;

  /// item aspect ratio
  final double itemAspectRatio;

  /// border radius
  final double borderRadius;

  /// border color
  final Color borderColor;

  /// border color opacity
  final double borderColorOpacity;

  /// background color
  final Color backgroundColor;

  /// background color opacity
  final double backgroundColorOpacity;

  /// loading builder, return Container() if you want hide it
  final Widget? Function(BuildContext context)? loadingBuilder;

  ///  item style
  final ZegoUIKitHallRoomListItemStyle item;

  const ZegoUIKitHallRoomListStyle({
    this.scrollDirection = Axis.horizontal,
    this.borderRadius = 0,
    this.borderColor = Colors.transparent,
    this.borderColorOpacity = 0.2,
    this.backgroundColor = Colors.white,
    this.backgroundColorOpacity = 0.5,
    this.loadingBuilder,
    this.scrollAxisCount = 1,
    this.itemAspectRatio = 16 / 9.0,
    this.item = const ZegoUIKitHallRoomListItemStyle(),
  });
}

/// item style
class ZegoUIKitHallRoomListItemStyle {
  /// Video view mode.
  ///
  /// Set it to true if you want the video view to scale proportionally to fill the entire view, potentially resulting in partial cropping.
  ///
  /// Set it to false if you want the video view to scale proportionally, potentially resulting in black borders.
  final bool useVideoViewAspectFill;

  /// Aspect ratio
  final double sizeAspectRatio;

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

  /// margin
  final EdgeInsetsGeometry margin;

  /// border radius
  final double borderRadius;

  /// border color
  final Color borderColor;

  /// borderColor opacity
  final double borderColorOpacity;

  /// loading builder, return Container() if you want hide it
  final Widget? Function(
    BuildContext context,
    ZegoUIKitUser? user,
    String roomID,
  )? loadingBuilder;

  /// custom avatar
  final ZegoAvatarConfig? avatar;

  const ZegoUIKitHallRoomListItemStyle({
    this.useVideoViewAspectFill = true,
    this.sizeAspectRatio = 16 / 9,
    this.backgroundBuilder,
    this.foregroundBuilder,
    this.loadingBuilder,
    this.borderRadius = 5,
    this.borderColor = Colors.black,
    this.borderColorOpacity = 0.2,
    this.avatar,
    this.margin = const EdgeInsets.all(5),
  });
}
