// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/components/audio_video_container/layout_gallery.dart';
import 'package:zego_uikit/src/components/audio_video_container/layout_picture_in_picture.dart';
import 'package:zego_uikit/src/components/audio_video_container/picture_in_picture/defines.dart';
import 'package:zego_uikit/src/components/defines.dart';

/// layout config
/// 1. picture in picture
/// 2. gallery
class ZegoLayout {
  const ZegoLayout.internal();

  /// Picture-in-Picture (PiP) layout.
  factory ZegoLayout.pictureInPicture({
    /// the margin of PIP view
    ///  todo@3.0 rename to margin
    EdgeInsets? smallViewMargin,

    /// small video view is draggable if set true in one-on-one mode
    bool isSmallViewDraggable = true,

    ///  whether you can switch view's position by clicking on the small view
    bool switchLargeOrSmallViewByClick = true,

    /// whether to hide the local View when the local camera is closed
    ZegoViewPosition smallViewPosition = ZegoViewPosition.topRight,

    /// the size of every small view
    Size? smallViewSize,

    /// the space between small views in multi-users mode
    ///  todo@3.0 rename to paddings
    EdgeInsets? spacingBetweenSmallViews,

    /// small video views is scrollable if set true in multi-users mode
    bool isSmallViewsScrollable = true,

    /// the visible small views count in multi-users mode
    /// if the value is set to -1, it will attempt to display the maximum number of views.
    int visibleSmallViewsCount = 3,

    ///
    bool showNewScreenSharingViewInFullscreenMode = true,

    ///
    ZegoShowFullscreenModeToggleButtonRules
        showScreenSharingFullscreenModeToggleButtonRules =
        ZegoShowFullscreenModeToggleButtonRules.showWhenScreenPressed,

    /// User ID for Specifying Large View
    String? bigViewUserID,
  }) {
    return ZegoLayoutPictureInPictureConfig(
      margin: smallViewMargin,
      isSmallViewDraggable: isSmallViewDraggable,
      switchLargeOrSmallViewByClick: switchLargeOrSmallViewByClick,
      smallViewPosition: smallViewPosition,
      smallViewSize: smallViewSize,
      spacingBetweenSmallViews: spacingBetweenSmallViews,
      isSmallViewsScrollable: isSmallViewsScrollable,
      visibleSmallViewsCount: visibleSmallViewsCount,
      showNewScreenSharingViewInFullscreenMode:
          showNewScreenSharingViewInFullscreenMode,
      showScreenSharingFullscreenModeToggleButtonRules:
          showScreenSharingFullscreenModeToggleButtonRules,
      bigViewUserID: bigViewUserID,
    );
  }

  /// Gallery Layout
  factory ZegoLayout.gallery({
    /// true: show audio video view only open camera or microphone
    bool showOnlyOnAudioVideo = false,

    /// The margin of layout, the layout will display center
    /// so you can display your widgets around empty spaces
    EdgeInsetsGeometry margin = const EdgeInsets.all(2.0),

    /// whether to display rounded corners and spacing between views
    bool addBorderRadiusAndSpacingBetweenView = true,

    /// screen sharing configs
    bool showNewScreenSharingViewInFullscreenMode = true,

    /// screen sharing configs, display rule of full screen button
    ZegoShowFullscreenModeToggleButtonRules
        showScreenSharingFullscreenModeToggleButtonRules =
        ZegoShowFullscreenModeToggleButtonRules.showWhenScreenPressed,
  }) {
    return ZegoLayoutGalleryConfig(
      showOnlyOnAudioVideo: showOnlyOnAudioVideo,
      margin: margin,
      addBorderRadiusAndSpacingBetweenView:
          addBorderRadiusAndSpacingBetweenView,
      showNewScreenSharingViewInFullscreenMode:
          showNewScreenSharingViewInFullscreenMode,
      showScreenSharingFullscreenModeToggleButtonRules:
          showScreenSharingFullscreenModeToggleButtonRules,
    );
  }
}
