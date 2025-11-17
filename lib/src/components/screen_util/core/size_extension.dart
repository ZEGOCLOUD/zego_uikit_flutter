// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/components/screen_util/core/screen_util.dart';

/// @nodoc
extension ZegoSizeExtension on num {
  ///[ZegoScreenUtil.setWidth]
  double get zW => ZegoScreenUtil().setWidth(this);

  ///[ZegoScreenUtil.setHeight]
  double get zH => ZegoScreenUtil().setHeight(this);

  ///[ZegoScreenUtil.radius]
  double get zR => ZegoScreenUtil().radius(this);

  ///[ZegoScreenUtil.diagonal]
  double get zDG => ZegoScreenUtil().diagonal(this);

  ///[ZegoScreenUtil.diameter]
  double get zDM => ZegoScreenUtil().diameter(this);

  ///[ZegoScreenUtil.setSp]
  double get zSP => ZegoScreenUtil().setSp(this);

  ///smart size :  it check your value - if it is bigger than your value it will set your value
  ///for example, you have set 16.sm() , if for your screen 16.sp() is bigger than 16 , then it will set 16 not 16.sp()
  ///I think that it is good for save size balance on big sizes of screen
  double get zSPMin => min(toDouble(), zSP);

  @Deprecated('use spMin instead')
  double get zSM => min(toDouble(), zSP);

  double get zSPMax => max(toDouble(), zSP);

  /// Multiple of screen width
  ///Multiple of screen width
  double get zSW => ZegoScreenUtil().screenWidth * this;

  /// Multiple of screen height
  ///Multiple of screen height
  double get zSH => ZegoScreenUtil().screenHeight * this;

  ///[ZegoScreenUtil.setHeight]
  SizedBox get zVerticalSpace => ZegoScreenUtil().setVerticalSpacing(this);

  ///[ZegoScreenUtil.setVerticalSpacingFromWidth]
  SizedBox get zVerticalSpaceFromWidth =>
      ZegoScreenUtil().setVerticalSpacingFromWidth(this);

  ///[ZegoScreenUtil.setWidth]
  SizedBox get zHorizontalSpace => ZegoScreenUtil().setHorizontalSpacing(this);

  ///[ZegoScreenUtil.radius]
  SizedBox get zHorizontalSpaceRadius =>
      ZegoScreenUtil().setHorizontalSpacingRadius(this);

  ///[ZegoScreenUtil.radius]
  SizedBox get zVerticalSpacingRadius =>
      ZegoScreenUtil().setVerticalSpacingRadius(this);

  ///[ZegoScreenUtil.diameter]
  SizedBox get zHorizontalSpaceDiameter =>
      ZegoScreenUtil().setHorizontalSpacingDiameter(this);

  ///[ZegoScreenUtil.diameter]
  SizedBox get zVerticalSpacingDiameter =>
      ZegoScreenUtil().setVerticalSpacingDiameter(this);

  ///[ZegoScreenUtil.diagonal]
  SizedBox get zHorizontalSpaceDiagonal =>
      ZegoScreenUtil().setHorizontalSpacingDiagonal(this);

  ///[ZegoScreenUtil.diagonal]
  SizedBox get zVerticalSpacingDiagonal =>
      ZegoScreenUtil().setVerticalSpacingDiagonal(this);
}

/// @nodoc
extension ZegoEdgeInsetsExtension on EdgeInsets {
  /// Creates adapt insets using r [ZegoSizeExtension].
  EdgeInsets get zR => copyWith(
        top: top.zR,
        bottom: bottom.zR,
        right: right.zR,
        left: left.zR,
      );

  EdgeInsets get dm => copyWith(
        top: top.zDM,
        bottom: bottom.zDM,
        right: right.zDM,
        left: left.zDM,
      );

  EdgeInsets get dg => copyWith(
        top: top.zDG,
        bottom: bottom.zDG,
        right: right.zDG,
        left: left.zDG,
      );

  EdgeInsets get w => copyWith(
        top: top.zW,
        bottom: bottom.zW,
        right: right.zW,
        left: left.zW,
      );

  EdgeInsets get h => copyWith(
        top: top.zH,
        bottom: bottom.zH,
        right: right.zH,
        left: left.zH,
      );
}

/// @nodoc
extension ZegoBorderRaduisExtension on BorderRadius {
  /// Creates adapt BorderRadius using r [ZegoSizeExtension].
  BorderRadius get r => copyWith(
        bottomLeft: bottomLeft.zR,
        bottomRight: bottomRight.zR,
        topLeft: topLeft.zR,
        topRight: topRight.zR,
      );

  BorderRadius get w => copyWith(
        bottomLeft: bottomLeft.zW,
        bottomRight: bottomRight.zW,
        topLeft: topLeft.zW,
        topRight: topRight.zW,
      );

  BorderRadius get h => copyWith(
        bottomLeft: bottomLeft.zH,
        bottomRight: bottomRight.zH,
        topLeft: topLeft.zH,
        topRight: topRight.zH,
      );
}

/// @nodoc
extension ZegoRaduisExtension on Radius {
  /// Creates adapt Radius using r [ZegoSizeExtension].
  Radius get zR => Radius.elliptical(x.zR, y.zR);

  Radius get zDM => Radius.elliptical(
        x.zDM,
        y.zDM,
      );

  Radius get zDG => Radius.elliptical(
        x.zDG,
        y.zDG,
      );

  Radius get zW => Radius.elliptical(x.zW, y.zW);

  Radius get zH => Radius.elliptical(x.zH, y.zH);
}

/// @nodoc
extension ZegoBoxConstraintsExtension on BoxConstraints {
  /// Creates adapt BoxConstraints using r [ZegoSizeExtension].
  BoxConstraints get zR => copyWith(
        maxHeight: maxHeight.zR,
        maxWidth: maxWidth.zR,
        minHeight: minHeight.zR,
        minWidth: minWidth.zR,
      );

  /// Creates adapt BoxConstraints using h-w [ZegoSizeExtension].
  BoxConstraints get zHW => copyWith(
        maxHeight: maxHeight.zH,
        maxWidth: maxWidth.zW,
        minHeight: minHeight.zH,
        minWidth: minWidth.zW,
      );

  BoxConstraints get zW => copyWith(
        maxHeight: maxHeight.zW,
        maxWidth: maxWidth.zW,
        minHeight: minHeight.zW,
        minWidth: minWidth.zW,
      );

  BoxConstraints get zH => copyWith(
        maxHeight: maxHeight.zH,
        maxWidth: maxWidth.zH,
        minHeight: minHeight.zH,
        minWidth: minWidth.zH,
      );
}
