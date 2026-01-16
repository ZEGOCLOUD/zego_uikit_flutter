// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:loop_page_view/loop_page_view.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

// Project imports:
import 'package:zego_uikit/src/components/components.dart';
import 'package:zego_uikit/src/components/internal/internal.dart';
import 'package:zego_uikit/src/modules/hall_room/config.dart';
import 'package:zego_uikit/src/modules/hall_room/controller.dart';
import 'package:zego_uikit/src/modules/hall_room/style.dart';
import 'package:zego_uikit/src/services/services.dart';
import 'defines.dart';
import 'model.dart';

/// display user audio and video information without join room(live/conference),
/// and z order of widget(from bottom to top) is:
/// 1. background view
/// 2. video view
/// 3. foreground view
class ZegoUIKitHallRoomList extends StatefulWidget {
  const ZegoUIKitHallRoomList({
    super.key,
    required this.appID,
    required this.userID,
    required this.userName,
    required this.controller,
    this.appSign = '',
    this.token = '',
    this.model,
    this.modelDelegate,
    this.scenario = ZegoUIKitScenario.Default,
    ZegoUIKitHallRoomListStyle? style,
    ZegoUIKitHallRoomListConfig? config,
  })  : style = style ?? const ZegoUIKitHallRoomListStyle(),
        config = config ?? const ZegoUIKitHallRoomListConfig();

  /// You can create a project and obtain an appID from the [ZEGOCLOUD Admin Console](https://console.zegocloud.com).
  final int appID;

  /// log in by using [appID] + [appSign].
  ///
  /// You can create a project and obtain an appSign from the [ZEGOCLOUD Admin Console](https://console.zegocloud.com).
  ///
  /// Of course, you can also log in by using [appID] + [token]. For details, see [token].
  final String appSign;

  /// log in by using [appID] + [token].
  ///
  /// The token issued by the developer's business server is used to ensure security.
  /// Please note that if you want to use [appID] + [token] login, do not assign a value to [appSign]
  ///
  /// For the generation rules, please refer to [Using Token Authentication] (https://doc-zh.zego.im/article/10360), the default is an empty string, that is, no authentication.
  ///
  /// if appSign is not passed in or if appSign is empty, this parameter must be set for authentication when logging in to a room.
  final String token;

  /// The ID of the currently logged-in user.
  /// It can be any valid string.
  /// Typically, you would use the ID from your own user system, such as Firebase.
  final String userID;

  /// The name of the currently logged-in user.
  /// It can be any valid string.
  /// Typically, you would use the name from your own user system, such as Firebase.
  final String userName;

  ///
  final ZegoUIKitScenario scenario;

  ///  style
  final ZegoUIKitHallRoomListStyle style;

  /// config
  final ZegoUIKitHallRoomListConfig config;

  /// model
  /// list of [host id && live id]
  /// When swiping up or down, the corresponding LIVE information will be returned via this [model]
  final ZegoUIKitHallRoomListModel? model;

  /// If you want to manage data yourself, please refer to [ZegoUIKitHallRoomListModel],
  /// then cancel the setting of [model], and then set [modelDelegate]
  final ZegoUIKitHallRoomListModelDelegate? modelDelegate;

  /// controller
  final ZegoUIKitHallRoomListController controller;

  @override
  State<ZegoUIKitHallRoomList> createState() => _ZegoUIKitHallRoomListState();
}

class _ZegoUIKitHallRoomListState extends State<ZegoUIKitHallRoomList> {
  Future<bool>? _initFuture;

  int currentPageIndex = 0;
  late final LoopPageController pageController;

  /// Track mute state for previous/next pages during scrolling
  bool _isPreviousUnmuted = false;
  bool _isNextUnmuted = false;

  /// Track last pixels value to calculate scroll direction
  double? _lastPixels;

  /// Accumulated offset from current page
  double _accumulatedOffset = 0.0;

  /// Track if page has changed via onPageChanged to filter stale scroll updates
  bool _pageChangedFlag = false;

  int get startIndex => 0;

  int get endIndex => 2;

  int get pageCount => (endIndex - startIndex) + 1;

  ZegoUIKitHallRoomListStreamUser? get previousStreamUser =>
      widget.model?.activeContext?.previous ??
      widget.modelDelegate?.activeContext.previous;

  ZegoUIKitHallRoomListStreamUser? get currentStreamUser =>
      widget.model?.activeRoom ?? widget.modelDelegate?.activeRoom;

  ZegoUIKitHallRoomListStreamUser? get nextStreamUser =>
      widget.model?.activeContext?.next ??
      widget.modelDelegate?.activeContext.next;

  ZegoUIKitHallRoomStreamMode get streamMode => widget.config.streamMode;

  @override
  void initState() {
    super.initState();

    currentPageIndex = startIndex;
    pageController = LoopPageController(initialPage: startIndex);

    widget.controller.private.setData(
      appID: widget.appID,
      appSign: widget.appSign,
      token: widget.token,
      scenario: widget.scenario,
      config: widget.config,
    );

    widget.controller.private.updateNotifier.addListener(onUpdateRequest);
  }

  @override
  void dispose() {
    super.dispose();

    pageController.dispose();

    widget.controller.private.updateNotifier.removeListener(onUpdateRequest);

    if (widget.controller.private.uninitOnDispose) {
      widget.controller.private.uninit().then((_) {
        widget.controller.private.clearData();
      });
    } else {
      /// 在ZegoLiveStreamingSwipingLifeCycle中会处理
      /// clearData 和 switch room
    }
  }

  @override
  Widget build(BuildContext context) {
    _initFuture ??= widget.controller.private
        .init(
      localUser: ZegoUIKitUser(
        id: widget.userID,
        name: widget.userName,
        roomID: widget.controller.roomID,
        isAnotherRoomUser: false,
      ),
    )
        .then((success) async {
      ZegoLoggerService.logInfo(
        'controller init, success:$success, ',
        tag: 'uikit.hall-room-view',
        subTag: 'build',
      );

      if (success) {
        playStreams();
      }
      return success;
    });

    return ZegoScreenUtilInit(
      designSize: const Size(750, 1334),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return FutureBuilder<bool>(
          future: _initFuture,
          builder: (context, snapshot) {
            ZegoLoggerService.logInfo(
              'wait future, snapshot data:${snapshot.data}, ',
              tag: 'uikit.hall-room-view',
              subTag: 'build',
            );

            if (snapshot.connectionState == ConnectionState.waiting ||
                !snapshot.hasData ||
                !snapshot.data!) {
              return Center(
                child: widget.style.loadingBuilder?.call(context) ??
                    const CircularProgressIndicator(),
              );
            }

            return sdkInitWrapper(
              child: roomLoginWrapper(
                child: pageView(),
              ),
            );
          },
        );
      },
    );
  }

  Widget pageView() {
    return NotificationListener<ScrollNotification>(
      onNotification: onScrollNotification,
      child: LoopPageView.builder(
        controller: pageController,
        scrollDirection: Axis.vertical,

        /// allowImplicitScrolling: true,
        onPageChanged: onPageChanged,
        itemCount: pageCount,
        itemBuilder: (context, pageIndex) {
          ZegoUIKitHallRoomListStreamUser? itemStreamUser;

          if (pageIndex == currentPageIndex) {
            itemStreamUser =
                widget.model?.activeRoom ?? widget.modelDelegate?.activeRoom;
          } else {
            bool toNext = false;
            if (currentPageIndex == startIndex && pageIndex == endIndex) {
              toNext = false;
            } else if (currentPageIndex == endIndex &&
                pageIndex == startIndex) {
              toNext = true;
            } else {
              toNext = pageIndex > currentPageIndex;
            }

            itemStreamUser = toNext ? nextStreamUser : previousStreamUser;
          }

          itemStreamUser ??= ZegoUIKitHallRoomListStreamUser.empty();

          ZegoLoggerService.logInfo(
            'user:$itemStreamUser, ',
            tag: 'uikit.hall-room-view',
            subTag: 'itemBuilder',
          );

          return Stack(
            children: [
              background(itemStreamUser),
              videoView(itemStreamUser),
              foreground(itemStreamUser),
            ],
          );
        },
      ),
    );
  }

  bool onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      _handleScrollUpdate(notification);
    } else if (notification is ScrollEndNotification) {
      _handleScrollEnd();
    }
    return false;
  }

  void _handleScrollUpdate(ScrollNotification notification) {
    final metrics = notification.metrics;

    /// Check if metrics has pixels and viewport dimension
    if (!metrics.hasPixels || !metrics.hasContentDimensions) {
      return;
    }

    final currentPixels = metrics.pixels;

    /// Initialize lastPixels if not set
    if (_lastPixels == null) {
      _lastPixels = currentPixels;
      return;
    }

    /// Calculate offset based on pixels change relative to viewport
    /// For LoopPageView, pixels can be very large, so we calculate relative offset
    final pixelsDelta = currentPixels - _lastPixels!;
    final incrementalOffset = pixelsDelta / metrics.viewportDimension;

    /// Check if page has changed via onPageChanged to filter stale scroll updates
    /// If onPageChanged has already triggered, skip this stale update
    if (_pageChangedFlag) {
      /// Reset tracking variables and clear the flag
      _lastPixels = null;
      _pageChangedFlag = false;
      return;
    }

    /// Accumulate offset to track total scroll distance from current page
    /// >0.5 next page&onPageChanged happened
    /// <-0.5 previous page&onPageChanged happened
    _accumulatedOffset += incrementalOffset;

    /// Update lastPixels for next calculation
    _lastPixels = currentPixels;

    /// Calculate if previous/next page is visible
    /// When accumulatedOffset > 0, scrolling down (next page visible)
    /// When accumulatedOffset < 0, scrolling up (previous page visible)
    /// Threshold: if accumulatedOffset > 0.01, next page is visible; if accumulatedOffset < -0.01, previous page is visible
    const threshold = 0.01;

    final isNextVisible = _accumulatedOffset > threshold;
    final isPreviousVisible = _accumulatedOffset < -threshold;

    /// Unmute next page if visible and not already unmuted
    if (isNextVisible && !_isNextUnmuted && nextStreamUser != null) {
      _unmuteStreamUser(nextStreamUser!);
      _isNextUnmuted = true;
      ZegoLoggerService.logInfo(
        'unmute next page during scroll, accumulatedOffset:$_accumulatedOffset',
        tag: 'uikit.hall-room-view',
        subTag: 'scroll',
      );
    } else if (!isNextVisible && _isNextUnmuted && nextStreamUser != null) {
      /// Mute next page if not visible and currently unmuted
      _muteStreamUser(nextStreamUser!);
      _isNextUnmuted = false;
      ZegoLoggerService.logInfo(
        'mute next page during scroll, accumulatedOffset:$_accumulatedOffset',
        tag: 'uikit.hall-room-view',
        subTag: 'scroll',
      );
    }

    /// Unmute previous page if visible and not already unmuted
    if (isPreviousVisible &&
        !_isPreviousUnmuted &&
        previousStreamUser != null) {
      _unmuteStreamUser(previousStreamUser!);
      _isPreviousUnmuted = true;
      ZegoLoggerService.logInfo(
        'unmute previous page during scroll, accumulatedOffset:$_accumulatedOffset',
        tag: 'uikit.hall-room-view',
        subTag: 'scroll',
      );
    } else if (!isPreviousVisible &&
        _isPreviousUnmuted &&
        previousStreamUser != null) {
      /// Mute previous page if not visible and currently unmuted
      _muteStreamUser(previousStreamUser!);
      _isPreviousUnmuted = false;
      ZegoLoggerService.logInfo(
        'mute previous page during scroll, accumulatedOffset:$_accumulatedOffset',
        tag: 'uikit.hall-room-view',
        subTag: 'scroll',
      );
    }
  }

  void _handleScrollEnd() {
    /// Reset tracking variables when scroll ends
    _lastPixels = null;
    _accumulatedOffset = 0.0;

    /// When scroll ends (user releases finger), re-mute any unmuted pages
    /// that are not the current page
    if (_isNextUnmuted && nextStreamUser != null) {
      _muteStreamUser(nextStreamUser!);
      _isNextUnmuted = false;
      ZegoLoggerService.logInfo(
        'mute next page on scroll end',
        tag: 'uikit.hall-room-view',
        subTag: 'scroll',
      );
    }
    if (_isPreviousUnmuted && previousStreamUser != null) {
      _muteStreamUser(previousStreamUser!);
      _isPreviousUnmuted = false;
      ZegoLoggerService.logInfo(
        'mute previous page on scroll end',
        tag: 'uikit.hall-room-view',
        subTag: 'scroll',
      );
    }
  }

  Future<void> _muteStreamUser(
      ZegoUIKitHallRoomListStreamUser streamUser) async {
    if (streamMode == ZegoUIKitHallRoomStreamMode.preloaded) {
      /// use mute/unmute
      await ZegoUIKit().muteUserAudioVideo(
        streamUser.user.id,
        true, // mute
        targetRoomID: widget.controller.roomID,
      );
    } else {
      /// stop playing stream to avoid extra costs
      widget.controller.private.playOne(streamUser: streamUser, toPlay: false);
    }
  }

  Future<void> _unmuteStreamUser(
    ZegoUIKitHallRoomListStreamUser streamUser,
  ) async {
    if (streamMode == ZegoUIKitHallRoomStreamMode.preloaded) {
      /// only enable video;
      /// audio should only be enabled when the page is actually switched to onPageChanged.
      await ZegoUIKit().muteUserVideo(
        streamUser.user.id,
        false, // unmute
        targetRoomID: widget.controller.roomID,
      );
    } else {
      /// start playing stream
      widget.controller.private.playOne(streamUser: streamUser, toPlay: true);
      await ZegoUIKit().muteUserAudio(
        streamUser.user.id,
        true,
        targetRoomID: widget.controller.roomID,
      );
    }
  }

  void onPageChanged(int pageIndex) {
    ZegoLoggerService.logInfo(
      'current page index:$currentPageIndex, '
      'page index:$pageIndex, ',
      tag: 'uikit.hall-room-view',
      subTag: 'onPageChanged',
    );

    if (currentPageIndex == pageIndex) {
      return;
    }

    bool toNext = false;
    if (currentPageIndex == startIndex && pageIndex == endIndex) {
      /// Boundary point swipe up
      toNext = false;
    } else if (currentPageIndex == endIndex && pageIndex == startIndex) {
      /// Boundary point swipe down
      toNext = true;
    } else {
      toNext = pageIndex > currentPageIndex;
    }

    final oldCurrentPageIndex = currentPageIndex;
    currentPageIndex = pageIndex;

    /// Reset scroll mute state when page actually changes
    _lastPixels = null;

    /// Set flag to filter stale scroll updates that may arrive after onPageChanged
    _pageChangedFlag = true;

    if (toNext) {
      widget.model?.next();
    } else {
      widget.model?.previous();
    }
    widget.modelDelegate?.delegate?.call(toNext);

    ZegoLoggerService.logInfo(
      'page index:{now:$pageIndex, previous:$oldCurrentPageIndex},'
      'previous stream:$previousStreamUser, '
      'current stream:$currentStreamUser, '
      'next stream:$nextStreamUser, ',
      tag: 'uikit.hall-room-view',
      subTag: 'onPageChanged',
    );

    playStreams();
  }

  void playStreams() {
    widget.controller.private.playOnly(
      currentStreamUser: currentStreamUser,
      previousStreamUser: previousStreamUser,
      nextStreamUser: nextStreamUser,
    );
  }

  void onUpdateRequest() {
    setState(() {
      playStreams();
    });
  }

  Widget sdkInitWrapper({required Widget child}) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.controller.sdkInitNotifier,
      builder: (context, isInit, _) {
        ZegoLoggerService.logInfo(
          'wait sdk init, isInit:$isInit, ',
          tag: 'uikit.hall-room-view',
          subTag: 'build',
        );

        return isInit
            ? child
            : Center(
                child: widget.style.loadingBuilder?.call(context) ??
                    const CircularProgressIndicator(),
              );
      },
    );
  }

  Widget roomLoginWrapper({required Widget child}) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.controller.roomLoginNotifier,
      builder: (context, isLogin, _) {
        ZegoLoggerService.logInfo(
          'wait room login, isLogin:$isLogin, ',
          tag: 'uikit.hall-room-view',
          subTag: 'build',
        );

        return isLogin
            ? child
            : Center(
                child: widget.style.loadingBuilder?.call(context) ??
                    const CircularProgressIndicator(),
              );
      },
    );
  }

  Widget videoView(ZegoUIKitHallRoomListStreamUser stream) {
    return StreamBuilder<List<ZegoUIKitUser>>(
      stream: ZegoUIKit().getAudioVideoListStream(
        targetRoomID: widget.controller.roomID,
      ),
      builder: (context, snapshot) {
        final queryIndex = ZegoUIKit()
            .getAudioVideoList(
              targetRoomID: widget.controller.roomID,
              onlyTargetRoom: false,
              streamType: stream.streamType,
            )
            .indexWhere((e) => e.id == stream.user.id);
        if (-1 == queryIndex) {
          return loading(stream);
        }

        final streamUser = ZegoUIKit().getUser(
          targetRoomID: widget.controller.roomID,
          stream.user.id,
        );
        return streamUser.isEmpty()
            ? loading(stream)
            : cameraUserStreamWidget(stream);
      },
    );
  }

  Widget loading(ZegoUIKitHallRoomListStreamUser stream) {
    return Center(
      child: widget.style.item.loadingBuilder?.call(
            context,
            stream.user,
            stream.roomID,
          ) ??
          const CircularProgressIndicator(),
    );
  }

  Widget cameraUserStreamWidget(ZegoUIKitHallRoomListStreamUser stream) {
    return ValueListenableBuilder<bool>(
      valueListenable: ZegoUIKit().getCameraStateNotifier(
        targetRoomID: widget.controller.roomID,
        stream.user.id,
      ),
      builder: (context, isCameraOn, _) {
        if (!isCameraOn) {
          ZegoLoggerService.logInfo(
            '${stream.user.id}\'s camera is not open',
            tag: 'uikit.component',
            subTag: 'uikit.hall-room-view',
          );

          return Container();
        }

        return Container(
          decoration: BoxDecoration(color: Colors.black),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ValueListenableBuilder<Widget?>(
                valueListenable: ZegoUIKit().getAudioVideoViewNotifier(
                  stream.user.id,
                  targetRoomID: widget.controller.roomID,
                  streamType: stream.streamType,
                ),
                builder: (context, userView, _) {
                  if (userView == null) {
                    ZegoLoggerService.logError(
                      '${stream.user.id}\'s view is null',
                      tag: 'uikit.component',
                      subTag: 'uikit.hall-room-view',
                    );

                    return Center(
                      child: widget.style.item.loadingBuilder?.call(
                            context,
                            stream.user,
                            stream.roomID,
                          ) ??
                          const CircularProgressIndicator(),
                    );
                  }

                  ZegoLoggerService.logInfo(
                    'render ${stream.user.id}\'s view',
                    tag: 'uikit.component',
                    subTag: 'uikit.hall-room-view',
                  );

                  return videoViewWithAspectRatio(
                    stream: stream,
                    constraints: constraints,
                    child: deviceOrientationListenerBuilder(
                      child: userView,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget videoViewWithAspectRatio({
    required ZegoUIKitHallRoomListStreamUser stream,
    required BoxConstraints constraints,
    required Widget child,
  }) {
    final videoSizeNotifier = ZegoUIKit().getVideoSizeNotifier(
      stream.user.id,
      targetRoomID: widget.controller.roomID,
      streamType: stream.streamType,
    );

    return ValueListenableBuilder<Size>(
      valueListenable: videoSizeNotifier,
      builder: (context, videoSize, _) {
        var videoWidth = videoSize.width;
        var videoHeight = videoSize.height;
        if (videoWidth <= 0 || videoHeight <= 0) {
          videoWidth = constraints.maxWidth;
          videoHeight = constraints.maxHeight;
        }

        final videoRatio = videoWidth / videoHeight;

        var displayWidth = constraints.maxWidth;
        var displayHeight = displayWidth / videoRatio;

        if (displayHeight > constraints.maxHeight) {
          displayHeight = constraints.maxHeight;
          displayWidth = displayHeight * videoRatio;
        }

        return Center(
          child: SizedBox(
            width: displayWidth,
            height: displayHeight,
            child: child,
          ),
        );
      },
    );
  }

  Widget deviceOrientationListenerBuilder({
    required Widget child,
  }) {
    return StreamBuilder(
      stream: NativeDeviceOrientationCommunicator().onOrientationChanged(),
      builder: (context, AsyncSnapshot<NativeDeviceOrientation> asyncResult) {
        if (asyncResult.hasData) {
          /// Do not update ui when ui is building !!!
          /// use postFrameCallback to update videoSize
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ///  notify sdk to update video render orientation
            ZegoUIKit().updateAppOrientation(
              deviceOrientationMap(asyncResult.data!),
            );
          });
        }

        return child;
      },
    );
  }

  Widget background(ZegoUIKitHallRoomListStreamUser stream) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            ValueListenableBuilder(
              valueListenable: ZegoUIKitUserPropertiesNotifier(
                roomID: widget.controller.roomID,
                stream.user,
              ),
              builder: (context, _, __) {
                return widget.style.item.backgroundBuilder?.call(
                      context,
                      Size(constraints.maxWidth, constraints.maxHeight),
                      stream.user,
                      stream.roomID,
                    ) ??
                    Container(color: Colors.transparent);
              },
            ),
            avatar(stream, constraints.maxWidth, constraints.maxHeight),
          ],
        );
      },
    );
  }

  Widget foreground(ZegoUIKitHallRoomListStreamUser stream) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return widget.style.item.foregroundBuilder?.call(
              context,
              Size(constraints.maxWidth, constraints.maxHeight),
              stream.user,
              stream.roomID,
            ) ??
            Container(color: Colors.transparent);
      },
    );
  }

  Widget avatar(
    ZegoUIKitHallRoomListStreamUser stream,
    double maxWidth,
    double maxHeight,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallView = maxHeight < screenSize.height / 2;
    final avatarSize =
        isSmallView ? Size(110.zR, 110.zR) : Size(258.zR, 258.zR);

    var sizedWidth = widget.style.item.avatar?.size?.width ?? avatarSize.width;
    var sizedHeight =
        widget.style.item.avatar?.size?.height ?? avatarSize.width;
    if (sizedWidth > maxWidth) {
      sizedWidth = maxWidth;
    }
    if (sizedHeight > maxHeight) {
      sizedHeight = maxHeight;
    }

    final queryIndex = ZegoUIKit()
        .getAudioVideoList(
          targetRoomID: widget.controller.roomID,
          onlyTargetRoom: false,
          streamType: stream.streamType,
        )
        .indexWhere((e) => e.id == stream.user.id);
    if (-1 == queryIndex) {
      return Container();
    }

    return Positioned(
      top: getAvatarTop(maxWidth, maxHeight, sizedHeight),
      left: (maxWidth - sizedWidth) / 2,
      child: SizedBox(
        width: sizedWidth,
        height: sizedHeight,
        child: ZegoAvatar(
          roomID: widget.controller.roomID,
          avatarSize: widget.style.item.avatar?.size ?? avatarSize,
          user: stream.user,
          showAvatar: widget.style.item.avatar?.showInAudioMode ?? true,
          showSoundLevel:
              widget.style.item.avatar?.showSoundWavesInAudioMode ?? true,
          avatarBuilder: widget.style.item.avatar?.builder,
          soundLevelSize: widget.style.item.avatar?.size,
          soundLevelColor: widget.style.item.avatar?.soundWaveColor,
        ),
      ),
    );
  }

  double getAvatarTop(double maxWidth, double maxHeight, double avatarHeight) {
    switch (widget.style.item.avatar?.verticalAlignment ??
        ZegoAvatarAlignment.center) {
      case ZegoAvatarAlignment.center:
        return (maxHeight - avatarHeight) / 2;
      case ZegoAvatarAlignment.start:
        return 15.zR;

      ///  sound level height
      case ZegoAvatarAlignment.end:
        return maxHeight - avatarHeight;
    }
  }
}
