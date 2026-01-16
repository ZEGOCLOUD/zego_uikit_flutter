// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/components/audio_video/audio_video_view.dart';
import 'package:zego_uikit/src/components/audio_video/defines.dart';
import 'package:zego_uikit/src/components/audio_video_container/picture_in_picture/defines.dart';
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/components/screen_util/screen_util.dart';
import 'package:zego_uikit/src/services/services.dart';

//
class ZegoLayoutPIPSmallItemList extends StatefulWidget {
  const ZegoLayoutPIPSmallItemList({
    super.key,
    required this.roomID,
    required this.targetUsers,
    required this.defaultPosition,
    required this.showOnlyVideo,
    required this.onTap,
    this.visibleItemCount = 3,
    this.scrollable = true,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.borderRadius,
    this.spacingBetweenSmallViews,
    this.size,
    this.margin,
    this.avatarConfig,
  });

  final String roomID;
  final bool showOnlyVideo;
  final bool scrollable;
  final int visibleItemCount;

  final List<ZegoUIKitUser> targetUsers;
  final ZegoViewPosition defaultPosition;
  final void Function(ZegoUIKitUser user) onTap;
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  final double? borderRadius;
  final EdgeInsets? spacingBetweenSmallViews;
  final EdgeInsets? margin;
  final Size? size;

  /// avatar etc.
  final ZegoAvatarConfig? avatarConfig;

  @override
  State<ZegoLayoutPIPSmallItemList> createState() =>
      _ZegoLayoutPIPSmallItemListState();
}

class _ZegoLayoutPIPSmallItemListState
    extends State<ZegoLayoutPIPSmallItemList> {
  late ZegoViewPosition currentPosition;
  var displayUsersNotifier = ValueNotifier<List<ZegoUIKitUser>>([]);

  Size get designedSize => widget.size ?? Size(248.5.zW, 248.0.zH);

  double get designedRatio => 1.0; //9.0 / 16.0;

  double get itemsSpacing => 5.zR;

  double get itemSpacing => 2.zR;

  @override
  void initState() {
    super.initState();

    currentPosition = widget.defaultPosition;

    listenUsersCameraState();
    onUserCameraStateChanged();
  }

  @override
  void dispose() {
    super.dispose();

    removeListenUsersCameraState();
  }

  @override
  void didUpdateWidget(covariant ZegoLayoutPIPSmallItemList oldWidget) {
    super.didUpdateWidget(oldWidget);

    removeListenUsersCameraState();

    listenUsersCameraState();
    onUserCameraStateChanged();
  }

  @override
  Widget build(BuildContext context) {
    removeListenUsersCameraState();

    listenUsersCameraState();
    onUserCameraStateChanged();

    final visibleItemCount = getVisibleItemCount();
    return calculatePosition(
      child: ValueListenableBuilder<List<ZegoUIKitUser>>(
        valueListenable: displayUsersNotifier,
        builder: (context, displayUsers, _) {
          final hasInvisibleUsers =
              widget.scrollable && displayUsers.length > visibleItemCount;
          return ConstrainedBox(
            constraints: BoxConstraints.loose(
              Size(
                designedSize.width,
                (visibleItemCount - 1) * itemsSpacing +
                    visibleItemCount * designedSize.height +

                    /// make user can see the last item's head area, so he can
                    /// know scrollable
                    (hasInvisibleUsers ? itemsSpacing * 3 : 0),
              ),
            ),
            //  remove listview padding
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: listview(List<ZegoUIKitUser>.from(displayUsers)),
            ),
          );
        },
      ),
    );
  }

  int getVisibleItemCount() {
    var visibleItemCount = widget.visibleItemCount;

    final mediaQueryData = MediaQuery.of(context);
    final screenHeight = mediaQueryData.size.height -
        mediaQueryData.padding.top -
        mediaQueryData.padding.bottom;
    final maxItemCount =
        (screenHeight + itemsSpacing) ~/ (itemsSpacing + designedSize.height);

    if (visibleItemCount < 0) {
      visibleItemCount = maxItemCount;
    } else {
      final displayHeight = (widget.visibleItemCount - 1) * itemsSpacing +
          widget.visibleItemCount * designedSize.height;
      if (displayHeight > screenHeight) {
        visibleItemCount = maxItemCount;

        ZegoLoggerService.logInfo(
          'visible item count(${widget.visibleItemCount}) too large, will cause the display to exceed the screen, change to $visibleItemCount',
          tag: 'uikit.component',
          subTag: 'pip small item list',
        );
      }
    }

    return visibleItemCount;
  }

  Widget listview(List<ZegoUIKitUser> userItems) {
    return ListView.builder(
      shrinkWrap: true,
      physics: widget.scrollable ? null : const NeverScrollableScrollPhysics(),
      itemCount: userItems.length,
      itemBuilder: (context, index) {
        final targetUser = userItems[index];
        return Padding(
          padding: widget.spacingBetweenSmallViews ??
              EdgeInsets.fromLTRB(
                widget.spacingBetweenSmallViews?.left ?? 0,
                widget.spacingBetweenSmallViews?.top ?? 0,
                widget.spacingBetweenSmallViews?.right ?? 0,
                (index == userItems.length - 1)
                    ? 0
                    : widget.spacingBetweenSmallViews?.bottom ?? itemsSpacing,
              ),
          child: Container(
            width: designedSize.width,
            height: designedSize.height,
            padding: EdgeInsets.all(itemSpacing),
            color: Colors.black.withAlpha(80),
            child: calculateSize(
              user: targetUser,
              child: ZegoAudioVideoView(
                roomID: widget.roomID,
                user: targetUser,
                onTap: (user) {
                  if (user != null) {
                    widget.onTap(user);
                  }
                },
                borderRadius: widget.borderRadius ?? 6.0.zW,
                backgroundBuilder: widget.backgroundBuilder,
                foregroundBuilder: widget.foregroundBuilder,
                avatarConfig: widget.avatarConfig,
              ),
            ),
          ),
        );
      },
    );
  }

  /// calculates smallView's size based on current screen
  Widget calculateSize({required ZegoUIKitUser? user, required Widget child}) {
    final portraitBaseSize =
        Size(designedSize.height, designedSize.width); // vertical
    final landscapeBaseSize = designedSize; //  horizontal

    if (user == null) {
      final defaultSize = Size(
          landscapeBaseSize.height * designedRatio, landscapeBaseSize.height);
      return SizedBox.fromSize(size: defaultSize, child: child);
    } else {
      return ValueListenableBuilder<Size>(
        valueListenable: ZegoUIKit().getVideoSizeNotifier(
          targetRoomID: widget.roomID,
          user.id,
        ),
        builder: (context, Size size, _) {
          late double width, height;
          if (size.width > size.height) {
            width = portraitBaseSize.width;
            height = portraitBaseSize.width * designedRatio;
          } else {
            width = landscapeBaseSize.height * designedRatio;
            height = landscapeBaseSize.height;
          }

          return SizedBox(width: width, height: height, child: child);
        },
      );
    }
  }

  /// position container, calculates the coordinates based on current position
  Widget calculatePosition({required Widget child}) {
    final paddingSpace = widget.margin ??
        EdgeInsets.only(left: 24.zR, top: 144.zR, right: 24.zR, bottom: 144.zR);

    double? left, top, right, bottom;
    switch (currentPosition) {
      case ZegoViewPosition.topLeft:
        left = paddingSpace.left;
        top = paddingSpace.top;
        break;
      case ZegoViewPosition.topRight:
        right = paddingSpace.right;
        top = paddingSpace.top;
        break;
      case ZegoViewPosition.bottomLeft:
        left = paddingSpace.left;
        bottom = paddingSpace.bottom;
        break;
      case ZegoViewPosition.bottomRight:
        right = paddingSpace.right;
        bottom = paddingSpace.bottom;
        break;
    }

    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: child,
    );
  }

  void listenUsersCameraState() {
    if (widget.showOnlyVideo) {
      for (final user in widget.targetUsers) {
        ZegoUIKit()
            .getCameraStateNotifier(targetRoomID: widget.roomID, user.id)
            .addListener(onUserCameraStateChanged);
      }
    }
  }

  void removeListenUsersCameraState() {
    if (widget.showOnlyVideo) {
      for (final user in widget.targetUsers) {
        ZegoUIKit()
            .getCameraStateNotifier(targetRoomID: widget.roomID, user.id)
            .removeListener(onUserCameraStateChanged);
      }
    }
  }

  void onUserCameraStateChanged() {
    if (widget.showOnlyVideo) {
      final targetUsers = List<ZegoUIKitUser>.from(widget.targetUsers)
        ..removeWhere((user) {
          /// hide if user's camera close
          return !ZegoUIKit()
              .getCameraStateNotifier(targetRoomID: widget.roomID, user.id)
              .value;
        });

      displayUsersNotifier.value = targetUsers;
    } else {
      displayUsersNotifier.value = List.from(widget.targetUsers);
    }
  }
}
