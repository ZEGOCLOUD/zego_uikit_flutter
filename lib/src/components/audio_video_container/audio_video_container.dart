// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
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
    super.key,
    required this.roomID,
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
  });

  final String roomID;
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
  final userListNotifier = ValueNotifier<List<ZegoUIKitUser>>([]);
  List<ZegoUIKitUser> virtualUsers = [];
  List<StreamSubscription<dynamic>?> subscriptions = [];

  var defaultScreenSharingViewController = ZegoScreenSharingViewController();

  ZegoScreenSharingViewController get screenSharingController =>
      widget.screenSharingViewController ?? defaultScreenSharingViewController;

  bool get userDebugMode => false && kDebugMode;

  @override
  void initState() {
    super.initState();

    if (widget.sources.contains(ZegoAudioVideoContainerSource.user)) {
      subscriptions.add(
        ZegoUIKit()
            .getUserListStream(targetRoomID: widget.roomID)
            .listen(onUserListUpdated),
      );
    }

    if (widget.sources.contains(ZegoAudioVideoContainerSource.audioVideo)) {
      subscriptions.add(
        ZegoUIKit()
            .getAudioVideoListStream(targetRoomID: widget.roomID)
            .listen(onStreamListUpdated),
      );
    }

    if (widget.sources.contains(ZegoAudioVideoContainerSource.screenSharing)) {
      subscriptions.add(
        ZegoUIKit()
            .getScreenSharingListStream(targetRoomID: widget.roomID)
            .listen(onStreamListUpdated),
      );
    }

    if (widget.sources.contains(ZegoAudioVideoContainerSource.virtualUser)) {
      virtualUsers = widget.virtualUsersNotifier?.value ?? [];
      widget.virtualUsersNotifier?.addListener(onVirtualUsersUpdated);
    }

    List<ZegoUIKitUser> streamUsers = [];
    if (widget.sources.contains(ZegoAudioVideoContainerSource.user)) {
      streamUsers.addAll(ZegoUIKit().getAllUsers(targetRoomID: widget.roomID));
    }
    if (widget.sources.contains(ZegoAudioVideoContainerSource.audioVideo) ||
        widget.sources.contains(ZegoAudioVideoContainerSource.screenSharing)) {
      streamUsers.addAll(ZegoUIKit().getAudioVideoList(
        targetRoomID: widget.roomID,
      ));
    }
    userListNotifier.value = streamUsers;

    ZegoLoggerService.logInfo(
      'hashCode:$hashCode, '
      'room id:${widget.roomID}, '
      'userList:${userListNotifier.value.map((e) => "${e.toString()}, ")}, ',
      tag: 'uikit.component.audio-video-container',
      subTag: 'init state',
    );
  }

  @override
  void dispose() {
    super.dispose();

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }
    widget.virtualUsersNotifier?.removeListener(onVirtualUsersUpdated);

    ZegoLoggerService.logInfo(
      'hashCode:$hashCode, '
      'room id:${widget.roomID}, ',
      tag: 'uikit.component.audio-video-container',
      subTag: 'dispose',
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawWidget = ValueListenableBuilder<ZegoUIKitUser?>(
      valueListenable: screenSharingController.fullscreenUserNotifier,
      builder: (BuildContext context, fullscreenUser, _) {
        if (fullscreenUser != null &&
            (widget.layout is ZegoLayoutGalleryConfig) &&
            (widget.layout as ZegoLayoutGalleryConfig)
                .showNewScreenSharingViewInFullscreenMode) {
          return ZegoScreenSharingView(
            roomID: widget.roomID,
            user: fullscreenUser,
            foregroundBuilder: widget.foregroundBuilder,
            backgroundBuilder: widget.backgroundBuilder,
            controller: widget.screenSharingViewController ??
                defaultScreenSharingViewController,
            showFullscreenModeToggleButtonRules: (widget.layout
                    is ZegoLayoutGalleryConfig)
                ? (widget.layout as ZegoLayoutGalleryConfig)
                    .showScreenSharingFullscreenModeToggleButtonRules
                : ZegoShowFullscreenModeToggleButtonRules.showWhenScreenPressed,
          );
        } else {
          return StreamBuilder<List<ZegoUIKitUser>>(
            stream: ZegoUIKit().getAudioVideoListStream(
              targetRoomID: widget.roomID,
            ),
            builder: (context, snapshot) {
              if (widget.layout is ZegoLayoutPictureInPictureConfig) {
                return pictureInPictureLayout();
              } else if (widget.layout is ZegoLayoutGalleryConfig) {
                return galleryLayout();
              }
              assert(false, 'Unimplemented layout');
              return Container();
            },
          );
        }
      },
    );

    return userDebugMode
        ? Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: rawWidget,
          )
        : rawWidget;
  }

  /// picture in picture
  Widget pictureInPictureLayout() {
    return ValueListenableBuilder(
      valueListenable: userListNotifier,
      builder: (context, userList, _) {
        ZegoLoggerService.logInfo(
          'hashCode:$hashCode, '
          'room id:${widget.roomID}, '
          'userList:${userList.map((e) => "${e.toString()}, ")}, ',
          tag: 'uikit.component.audio-video-container',
          subTag: 'pip layout',
        );
        return ZegoLayoutPictureInPicture(
          roomID: widget.roomID,
          layoutConfig: widget.layout as ZegoLayoutPictureInPictureConfig,
          backgroundBuilder: widget.backgroundBuilder,
          foregroundBuilder: widget.foregroundBuilder,
          userList: userList,
          avatarConfig: widget.avatarConfig,
        );
      },
    );
  }

  /// gallery
  Widget galleryLayout() {
    return ValueListenableBuilder(
      valueListenable: userListNotifier,
      builder: (context, userList, _) {
        ZegoLoggerService.logInfo(
          'hashCode:$hashCode, '
          'room id:${widget.roomID}, '
          'userList:${userList.map((e) => "${e.toString()}, ")}, ',
          tag: 'uikit.component.audio-video-container',
          subTag: 'gallery layout',
        );

        return ZegoLayoutGallery(
          roomID: widget.roomID,
          layoutConfig: widget.layout as ZegoLayoutGalleryConfig,
          backgroundBuilder: widget.backgroundBuilder,
          foregroundBuilder: widget.foregroundBuilder,
          userList: userList,
          maxItemCount: 8,
          avatarConfig: widget.avatarConfig,
          screenSharingViewController: widget.screenSharingViewController ??
              defaultScreenSharingViewController,
        );
      },
    );
  }

  void onUserListUpdated(List<ZegoUIKitUser> users) {
    updateUserList();
  }

  void onStreamListUpdated(List<ZegoUIKitUser> streamUsers) {
    if (screenSharingController.private.defaultFullScreen) {
      screenSharingController.fullscreenUserNotifier.value = ZegoUIKit()
              .getScreenSharingList(targetRoomID: widget.roomID)
              .isEmpty
          ? null
          : ZegoUIKit().getScreenSharingList(targetRoomID: widget.roomID).first;
    }

    updateUserList();
  }

  void onVirtualUsersUpdated() {
    virtualUsers = widget.virtualUsersNotifier?.value ?? [];

    updateUserList();
  }

  void updateUserList() {
    List<ZegoUIKitUser> updateUserList = List.from(userListNotifier.value);
    final streamUsers =
        ZegoUIKit().getAudioVideoList(targetRoomID: widget.roomID) +
            ZegoUIKit().getScreenSharingList(targetRoomID: widget.roomID);

    /// remove if not in stream
    updateUserList.removeWhere((user) =>
        -1 == streamUsers.indexWhere((streamUser) => user.id == streamUser.id));

    /// add if in stream
    for (final streamUser in streamUsers) {
      if (-1 == updateUserList.indexWhere((user) => user.id == streamUser.id)) {
        updateUserList.add(streamUser);
      }
    }

    if (widget.sources.contains(ZegoAudioVideoContainerSource.user)) {
      /// add in list even though use is not in stream
      ZegoUIKit().getAllUsers(targetRoomID: widget.roomID).forEach((user) {
        if (-1 != updateUserList.indexWhere((e) => e.id == user.id)) {
          /// in user list
          return;
        }

        if (-1 != streamUsers.indexWhere((e) => e.id == user.id)) {
          /// in stream list
          return;
        }

        updateUserList.add(user);
      });
    }

    if (widget.sources.contains(ZegoAudioVideoContainerSource.virtualUser)) {
      /// add in list even though use is not in stream
      for (var virtualUser in virtualUsers) {
        if (-1 != updateUserList.indexWhere((e) => e.id == virtualUser.id)) {
          /// in user list
          continue;
        }

        if (-1 != streamUsers.indexWhere((e) => e.id == virtualUser.id)) {
          /// in stream list
          continue;
        }

        updateUserList.add(virtualUser);
      }
    }

    updateUserList =
        widget.sortAudioVideo?.call(updateUserList) ?? updateUserList;

    updateUserList =
        widget.filterAudioVideo?.call(updateUserList) ?? updateUserList;

    userListNotifier.value = updateUserList;
    widget.onUserListUpdated?.call(updateUserList);
  }
}
