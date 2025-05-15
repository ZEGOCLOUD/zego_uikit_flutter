// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/components/audio_video/audio_video.dart';
import 'package:zego_uikit/src/components/audio_video/defines.dart';
import 'package:zego_uikit/src/components/audio_video_container/layout.dart';
import 'package:zego_uikit/src/components/audio_video_container/layout_gallery.dart';
import 'package:zego_uikit/src/components/audio_video_container/layout_picture_in_picture.dart';
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/services/services.dart';

enum AudioVideoViewFullScreeMode {
  none,
  normal,
  autoOrientation,
}

enum ZegoAudioVideoContainerSource {
  /// who in stream list
  audioVideo,
  screenSharing,

  /// who in room
  user,
  virtualUser,
}

/// container of audio video view,
/// it will layout views by layout mode and config
class ZegoAudioVideoContainer extends StatefulWidget {
  const ZegoAudioVideoContainer({
    Key? key,
    required this.layout,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.sortAudioVideo,
    this.filterAudioVideo,
    this.avatarConfig,
    this.screenSharingViewController,
    this.virtualUsersNotifier,
    this.sources = const [
      ZegoAudioVideoContainerSource.audioVideo,
      ZegoAudioVideoContainerSource.screenSharing,
    ],
    this.onUserListUpdated,
  }) : super(key: key);

  final ZegoLayout layout;

  /// foreground builder of audio video view
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;

  /// background builder of audio video view
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  /// sorter
  final ZegoAudioVideoViewSorter? sortAudioVideo;

  /// filter
  final ZegoAudioVideoViewFilter? filterAudioVideo;

  /// avatar etc.
  final ZegoAvatarConfig? avatarConfig;

  final ZegoScreenSharingViewController? screenSharingViewController;

  final List<ZegoAudioVideoContainerSource> sources;

  final ValueNotifier<List<ZegoUIKitUser>>? virtualUsersNotifier;

  final void Function(List<ZegoUIKitUser> userList)? onUserListUpdated;

  @override
  State<ZegoAudioVideoContainer> createState() =>
      _ZegoAudioVideoContainerState();
}

class _ZegoAudioVideoContainerState extends State<ZegoAudioVideoContainer> {
  List<ZegoUIKitUser> userList = [];
  List<ZegoUIKitUser> virtualUsers = [];
  List<StreamSubscription<dynamic>?> subscriptions = [];

  var defaultScreenSharingViewController = ZegoScreenSharingViewController();

  ZegoScreenSharingViewController get screenSharingController =>
      widget.screenSharingViewController ?? defaultScreenSharingViewController;

  @override
  void initState() {
    super.initState();

    if (widget.sources.contains(ZegoAudioVideoContainerSource.user)) {
      onUserListUpdated(ZegoUIKit().getAllUsers());
      subscriptions.add(
        ZegoUIKit().getUserListStream().listen(onUserListUpdated),
      );
    }
    if (widget.sources.contains(ZegoAudioVideoContainerSource.audioVideo)) {
      subscriptions.add(
        ZegoUIKit().getAudioVideoListStream().listen(onStreamListUpdated),
      );
    }
    if (widget.sources.contains(ZegoAudioVideoContainerSource.screenSharing)) {
      subscriptions.add(
        ZegoUIKit().getScreenSharingListStream().listen(onStreamListUpdated),
      );
    }
    if (widget.sources.contains(ZegoAudioVideoContainerSource.virtualUser)) {
      onVirtualUsersUpdated();
      widget.virtualUsersNotifier?.addListener(onVirtualUsersUpdated);
    }

    if (widget.sources.contains(ZegoAudioVideoContainerSource.audioVideo) ||
        widget.sources.contains(ZegoAudioVideoContainerSource.screenSharing)) {
      onStreamListUpdated(ZegoUIKit().getAudioVideoList());
    }
  }

  @override
  void dispose() {
    super.dispose();

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }
    widget.virtualUsersNotifier?.removeListener(onVirtualUsersUpdated);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ZegoUIKitUser?>(
        valueListenable: screenSharingController.fullscreenUserNotifier,
        builder: (BuildContext context, fullscreenUser, _) {
          if (fullscreenUser != null &&
              (widget.layout is ZegoLayoutGalleryConfig) &&
              (widget.layout as ZegoLayoutGalleryConfig)
                  .showNewScreenSharingViewInFullscreenMode) {
            return ZegoScreenSharingView(
              user: fullscreenUser,
              foregroundBuilder: widget.foregroundBuilder,
              backgroundBuilder: widget.backgroundBuilder,
              controller: widget.screenSharingViewController ??
                  defaultScreenSharingViewController,
              showFullscreenModeToggleButtonRules:
                  (widget.layout is ZegoLayoutGalleryConfig)
                      ? (widget.layout as ZegoLayoutGalleryConfig)
                          .showScreenSharingFullscreenModeToggleButtonRules
                      : ZegoShowFullscreenModeToggleButtonRules
                          .showWhenScreenPressed,
            );
          } else {
            updateUserList();

            return StreamBuilder<List<ZegoUIKitUser>>(
              stream: ZegoUIKit().getAudioVideoListStream(),
              builder: (context, snapshot) {
                if (widget.layout is ZegoLayoutPictureInPictureConfig) {
                  return pictureInPictureLayout(userList);
                } else if (widget.layout is ZegoLayoutGalleryConfig) {
                  return galleryLayout(userList);
                }
                assert(false, 'Unimplemented layout');
                return Container();
              },
            );
          }
        });
  }

  /// picture in picture
  Widget pictureInPictureLayout(List<ZegoUIKitUser> userList) {
    return ZegoLayoutPictureInPicture(
      layoutConfig: widget.layout as ZegoLayoutPictureInPictureConfig,
      backgroundBuilder: widget.backgroundBuilder,
      foregroundBuilder: widget.foregroundBuilder,
      userList: userList,
      avatarConfig: widget.avatarConfig,
    );
  }

  /// gallery
  Widget galleryLayout(List<ZegoUIKitUser> userList) {
    return ZegoLayoutGallery(
      layoutConfig: widget.layout as ZegoLayoutGalleryConfig,
      backgroundBuilder: widget.backgroundBuilder,
      foregroundBuilder: widget.foregroundBuilder,
      userList: userList,
      maxItemCount: 8,
      avatarConfig: widget.avatarConfig,
      screenSharingViewController: widget.screenSharingViewController ??
          defaultScreenSharingViewController,
    );
  }

  void onUserListUpdated(List<ZegoUIKitUser> users) {
    setState(() {
      updateUserList();
    });
  }

  void onStreamListUpdated(List<ZegoUIKitUser> streamUsers) {
    if (screenSharingController.private.defaultFullScreen) {
      screenSharingController.fullscreenUserNotifier.value =
          ZegoUIKit().getScreenSharingList().isEmpty
              ? null
              : ZegoUIKit().getScreenSharingList().first;
    }

    setState(() {
      updateUserList();
    });
  }

  void onVirtualUsersUpdated() {
    virtualUsers = widget.virtualUsersNotifier?.value ?? [];

    setState(() {
      updateUserList();
    });
  }

  void updateUserList() {
    final streamUsers =
        ZegoUIKit().getAudioVideoList() + ZegoUIKit().getScreenSharingList();

    /// remove if not in stream
    userList.removeWhere((user) =>
        -1 == streamUsers.indexWhere((streamUser) => user.id == streamUser.id));

    /// add if in stream
    for (final streamUser in streamUsers) {
      if (-1 == userList.indexWhere((user) => user.id == streamUser.id)) {
        userList.add(streamUser);
      }
    }

    if (widget.sources.contains(ZegoAudioVideoContainerSource.user)) {
      /// add in list even though use is not in stream
      ZegoUIKit().getAllUsers().forEach((user) {
        if (-1 != userList.indexWhere((e) => e.id == user.id)) {
          /// in user list
          return;
        }

        if (-1 != streamUsers.indexWhere((e) => e.id == user.id)) {
          /// in stream list
          return;
        }

        userList.add(user);
      });
    }

    if (widget.sources.contains(ZegoAudioVideoContainerSource.virtualUser)) {
      /// add in list even though use is not in stream
      for (var virtualUser in virtualUsers) {
        if (-1 != userList.indexWhere((e) => e.id == virtualUser.id)) {
          /// in user list
          continue;
        }

        if (-1 != streamUsers.indexWhere((e) => e.id == virtualUser.id)) {
          /// in stream list
          continue;
        }

        userList.add(virtualUser);
      }
    }

    userList =
        widget.sortAudioVideo?.call(List<ZegoUIKitUser>.from(userList)) ??
            userList;

    userList =
        widget.filterAudioVideo?.call(List<ZegoUIKitUser>.from(userList)) ??
            userList;

    widget.onUserListUpdated?.call(List<ZegoUIKitUser>.from(userList));
  }
}
