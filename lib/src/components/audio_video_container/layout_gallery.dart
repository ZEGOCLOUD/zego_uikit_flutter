// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/components/audio_video/audio_video_view.dart';
import 'package:zego_uikit/src/components/audio_video/defines.dart';
import 'package:zego_uikit/src/components/audio_video/screen_sharing/controller.dart';
import 'package:zego_uikit/src/components/audio_video/screen_sharing/view.dart';
import 'package:zego_uikit/src/components/audio_video_container/gallery/grid_layout_delegate.dart';
import 'package:zego_uikit/src/components/audio_video_container/gallery/layout_gallery_last_item.dart';
import 'package:zego_uikit/src/components/audio_video_container/layout.dart';
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/components/screen_util/screen_util.dart';
import 'package:zego_uikit/src/services/services.dart';

/// layout config of gallery
class ZegoLayoutGalleryConfig extends ZegoLayout {
  /// true: show audio video view only open camera or microphone
  bool showOnlyOnAudioVideo;

  /// whether to display rounded corners and spacing between views
  bool addBorderRadiusAndSpacingBetweenView;

  /// The margin of layout, the layout will display center
  /// so you can display your widgets around empty spaces
  EdgeInsetsGeometry margin;

  /// screen sharing configs
  bool showNewScreenSharingViewInFullscreenMode;

  ///
  ZegoShowFullscreenModeToggleButtonRules
      showScreenSharingFullscreenModeToggleButtonRules;

  ZegoLayoutGalleryConfig({
    this.showOnlyOnAudioVideo = false,
    this.margin = const EdgeInsets.all(2.0),
    this.addBorderRadiusAndSpacingBetweenView = true,
    this.showNewScreenSharingViewInFullscreenMode = true,
    this.showScreenSharingFullscreenModeToggleButtonRules =
        ZegoShowFullscreenModeToggleButtonRules.showWhenScreenPressed,
  }) : super.internal();
}

/// picture in picture layout
class ZegoLayoutGallery extends StatefulWidget {
  const ZegoLayoutGallery({
    Key? key,
    required this.roomID,
    required this.maxItemCount,
    required this.userList,
    required this.layoutConfig,
    this.backgroundColor = const Color(0xff171821),
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.avatarConfig,
    this.screenSharingViewController,
  }) : super(key: key);
  final String roomID;
  final int maxItemCount;
  final List<ZegoUIKitUser> userList;
  final ZegoLayoutGalleryConfig layoutConfig;

  final Color backgroundColor;
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  /// avatar etc.
  final ZegoAvatarConfig? avatarConfig;

  final ZegoScreenSharingViewController? screenSharingViewController;

  @override
  State<ZegoLayoutGallery> createState() => _ZegoLayoutGalleryState();
}

class _ZegoLayoutGalleryState extends State<ZegoLayoutGallery> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final itemsConfig = getLayoutItemsConfig();

    final columnCount = itemsConfig.hasScreenSharing
        ? (itemsConfig.layoutItems.length > 1 ? 2 : 1)
        : (itemsConfig.layoutItems.length > 2 ? 2 : 1);
    final layoutItemsContainer = CustomMultiChildLayout(
      delegate: GridLayoutDelegate.autoFill(
        autoFillItems: itemsConfig.layoutItems,
        columnCount: columnCount,
        layoutPadding: widget.layoutConfig.margin,
        lastRowAlignment: GridLayoutAlignment.start,
        itemPadding: widget.layoutConfig.addBorderRadiusAndSpacingBetweenView
            ? Size(10.0.zR, 10.0.zR)
            : Size.zero,
      ),
      children: itemsConfig.layoutItems,
    );

    return LayoutBuilder(builder: (context, constraints) {
      final rowCountWithScreenSharing =
          (itemsConfig.layoutItems.length / columnCount).ceil() + 1;
      return Container(
        color: widget.backgroundColor,
        child: itemsConfig.hasScreenSharing
            ? Column(
                children: [
                  Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight / rowCountWithScreenSharing,
                    padding:
                        widget.layoutConfig.addBorderRadiusAndSpacingBetweenView
                            ? EdgeInsets.symmetric(
                                horizontal: 10.0.zR,
                                vertical: 10.0.zR,
                              )
                            : EdgeInsets.zero,
                    child: itemsConfig.topScreenSharing,
                  ),
                  SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight -
                        (constraints.maxHeight / rowCountWithScreenSharing),
                    child: layoutItemsContainer,
                  ),
                ],
              )
            : layoutItemsContainer,
      );
    });
  }

  _ZegoLayoutGalleryItemsConfig getLayoutItemsConfig() {
    final itemsConfig = _ZegoLayoutGalleryItemsConfig.empty(
      hasScreenSharing: false,
      layoutItems: [],
    );

    /// TODO: play in rotation
    final layoutUsers = List<ZegoUIKitUser>.from(widget.userList);

    var lastUsers = <ZegoUIKitUser>[];

    final screenSharingLayoutItems = <LayoutId>[];
    final audioVideoListUserIDs = ZegoUIKit()
        .getAudioVideoList(targetRoomID: widget.roomID)
        .map((e) => e.id)
        .toList();
    final screenSharingListUserIDs = ZegoUIKit()
        .getScreenSharingList(targetRoomID: widget.roomID)
        .map((e) => e.id)
        .toList();
    for (var index = 0; index < layoutUsers.length; index++) {
      final layoutUser = layoutUsers.elementAt(index);

      /// audio video
      if (audioVideoListUserIDs.contains(layoutUser.id) ||

          /// show even if user is not publish
          !widget.layoutConfig.showOnlyOnAudioVideo) {
        final audioVideoView = LayoutBuilder(builder: (context, constraints) {
          return ZegoAudioVideoView(
            roomID: widget.roomID,
            user: layoutUser,
            backgroundBuilder: widget.backgroundBuilder,
            foregroundBuilder: widget.foregroundBuilder,
            borderRadius:
                widget.layoutConfig.addBorderRadiusAndSpacingBetweenView
                    ? 18.0.zW
                    : null,
            borderColor: Colors.transparent,
            avatarConfig: widget.avatarConfig,
          );
        });
        itemsConfig.layoutItems.add(LayoutId(
          id: layoutUser.id,
          child: audioVideoView,
        ));
      }

      /// screen sharing
      if (screenSharingListUserIDs.contains(layoutUser.id)) {
        final audioVideoView = LayoutBuilder(builder: (context, constraints) {
          return ZegoScreenSharingView(
            roomID: widget.roomID,
            user: layoutUser,
            backgroundBuilder: widget.backgroundBuilder,
            foregroundBuilder: widget.foregroundBuilder,
            borderRadius:
                widget.layoutConfig.addBorderRadiusAndSpacingBetweenView
                    ? 18.0.zW
                    : null,
            borderColor: Colors.transparent,
            controller: widget.screenSharingViewController,
            showFullscreenModeToggleButtonRules: widget
                .layoutConfig.showScreenSharingFullscreenModeToggleButtonRules,
          );
        });

        if (!itemsConfig.hasScreenSharing) {
          itemsConfig.topScreenSharing = audioVideoView;
        } else {
          screenSharingLayoutItems.add(LayoutId(
            id: layoutUser.id,
            child: audioVideoView,
          ));
        }

        itemsConfig.hasScreenSharing = true;
      }

      final currentItemsCount = itemsConfig.layoutItems.length +
          screenSharingLayoutItems.length +

          /// The top screen takes up two squares
          (itemsConfig.topScreenSharing != null ? 2 : 0);
      if (currentItemsCount >= widget.maxItemCount - 1) {
        if (index != layoutUsers.length - 1) {
          lastUsers = List<ZegoUIKitUser>.from(layoutUsers.sublist(index + 1));
        }
        break;
      }
    }

    if (lastUsers.isNotEmpty) {
      itemsConfig.layoutItems.add(LayoutId(
        id: 'sbs_last_users',
        child: ZegoLayoutGalleryLastItem(
          users: lastUsers,
          backgroundColor: const Color(0xff4A4B4D),
          borderRadius: widget.layoutConfig.addBorderRadiusAndSpacingBetweenView
              ? 18.0.zW
              : null,
          borderColor: Colors.transparent,
        ),
      ));
    }

    if (screenSharingLayoutItems.isNotEmpty) {
      itemsConfig.layoutItems.insertAll(0, screenSharingLayoutItems);
    }

    return itemsConfig;
  }
}

class _ZegoLayoutGalleryItemsConfig {
  bool hasScreenSharing;

  Widget? topScreenSharing;
  List<LayoutId> layoutItems;

  _ZegoLayoutGalleryItemsConfig({
    required this.hasScreenSharing,
    required this.topScreenSharing,
    required this.layoutItems,
  });

  _ZegoLayoutGalleryItemsConfig.empty({
    this.hasScreenSharing = false,
    this.layoutItems = const [],
  });
}
