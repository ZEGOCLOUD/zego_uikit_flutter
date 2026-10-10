// Dart imports:
import 'dart:async';
import 'dart:core';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:native_device_orientation/native_device_orientation.dart';

// Project imports:
import 'package:zego_uikit/src/components/audio_video/avatar/avatar.dart';
import 'package:zego_uikit/src/components/audio_video/defines.dart';
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/components/internal/internal.dart';
import 'package:zego_uikit/src/components/screen_util/screen_util.dart';
import 'package:zego_uikit/src/components/widgets/flip_animation.dart';
import 'package:zego_uikit/src/services/internal/core/core.dart';
import 'package:zego_uikit/src/services/services.dart';

/// display user audio and video information,
/// and z order of widget(from bottom to top) is:
/// 1. background view
/// 2. video view
/// 3. foreground view
class ZegoAudioVideoView extends StatefulWidget {
  const ZegoAudioVideoView({
    Key? key,
    required this.user,
    this.backgroundBuilder,
    this.foregroundBuilder,
    this.borderRadius,
    this.borderColor,
    this.extraInfo,
    this.avatarConfig,
  }) : super(key: key);

  final ZegoUIKitUser? user;

  /// foreground builder, you can display something you want on top of the view,
  /// foreground will always show
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;

  /// background builder, you can display something when user close camera
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  final double? borderRadius;
  final Color? borderColor;
  final Map<String, dynamic>? extraInfo;

  final ZegoAvatarConfig? avatarConfig;

  @override
  State<ZegoAudioVideoView> createState() => _ZegoAudioVideoViewState();
}

class _ZegoAudioVideoViewState extends State<ZegoAudioVideoView> {
  Timer? viewIDGuardTimer;
  final isLocalUserFlippedNotifier = ValueNotifier<bool>(false);
  int lastLoggedViewHashCode = 0;
  BoxConstraints? lastLoggedPlatformViewConstraints;
  String? lastLoggedPlatformViewUserID;
  int? lastLoggedPlatformViewID;
  int? lastLoggedPlatformViewWidgetHashCode;
  bool? lastLoggedPlatformViewCameraState;
  Timer? platformViewConstraintsLogTimer;
  BoxConstraints? pendingPlatformViewConstraints;
  String? pendingPlatformViewUserID;
  int? pendingPlatformViewID;
  int? pendingPlatformViewWidgetHashCode;
  bool? pendingPlatformViewCameraState;

  int get userViewID =>
      ZegoUIKit().getAudioVideoViewIDNotifier(widget.user?.id ?? '').value ??
      -1;

  bool get userViewIDIsEmpty =>
      -1 ==
      ZegoUIKit().getAudioVideoViewIDNotifier(widget.user?.id ?? '').value;

  ZegoUIKitCoreUser get localUserData =>
      ZegoUIKitCore.shared.coreData.localUser;

  List<StreamSubscription<dynamic>?> subscriptions = [];

  bool get isRenderOnCameraOff {
    if (Platform.isAndroid) {
      return false;
    }

    return ZegoUIKitCore.shared.coreData.isEnablePlatformView;
  }

  bool get logEnabled => false;

  String renderObjectChain(BuildContext context) {
    if (!context.mounted) {
      return '(Element unmounted)';
    }

    final chain = <String>[];
    RenderObject? renderObject = context.findRenderObject();
    while (renderObject != null && chain.length < 12) {
      final size = renderObject is RenderBox
          ? (renderObject.hasSize ? '${renderObject.size}' : 'no-size')
          : 'n/a';
      final globalOrigin = renderObject is RenderBox && renderObject.hasSize
          ? renderObject.localToGlobal(Offset.zero)
          : 'n/a';
      chain.add(
        '${renderObject.runtimeType}(attached:${renderObject.attached}, '
        'size:$size, globalOrigin:$globalOrigin)',
      );
      renderObject = renderObject.parent;
    }
    return chain.isEmpty ? '(no RenderObject)' : chain.join(' <- ');
  }

  @override
  void initState() {
    super.initState();

    ZegoLoggerService.logInfo(
      'audio video view State init, state:${identityHashCode(this)}, '
      'user:${widget.user?.id}, viewID:$userViewID, '
      'platformView:${ZegoUIKitCore.shared.coreData.isEnablePlatformView}, '
      'camera:${ZegoUIKit().getCameraStateNotifier(widget.user?.id ?? '').value}',
      tag: 'uikit-component',
      subTag: 'audio video view',
    );

    subscriptions
      ..add(ZegoUIKit().getUserListStream().listen(onUserListUpdated))
      ..add(ZegoUIKit()
          .getAudioVideoListStream()
          .listen(onAudioVideoListUpdated));
  }

  @override
  void didUpdateWidget(covariant ZegoAudioVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldUserID = oldWidget.user?.id ?? '';
    final oldViewID =
        ZegoUIKit().getAudioVideoViewIDNotifier(oldUserID).value ?? -1;
    ZegoLoggerService.logInfo(
      'audio video view Widget update, state:${identityHashCode(this)}, '
      'oldUser:$oldUserID, oldViewID:$oldViewID, '
      'newUser:${widget.user?.id}, newViewID:$userViewID, '
      'oldKey:${oldWidget.key}, newKey:${widget.key}, '
      'platformView:${ZegoUIKitCore.shared.coreData.isEnablePlatformView}',
      tag: 'uikit-component',
      subTag: 'audio video view',
    );
  }

  @override
  void dispose() {
    final userID = widget.user?.id ?? '';
    ZegoLoggerService.logInfo(
      'audio video view State dispose, state:${identityHashCode(this)}, '
      'user:$userID, viewID:$userViewID, '
      'videoWidgetHash:${ZegoUIKit().getAudioVideoViewNotifier(userID).value?.hashCode}, '
      'platformView:${ZegoUIKitCore.shared.coreData.isEnablePlatformView}, '
      'renderObjects:${renderObjectChain(context)}',
      tag: 'uikit-component',
      subTag: 'audio video view',
    );
    viewIDGuardTimer?.cancel();
    cancelPlatformViewConstraintsLog();

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }

    super.dispose();
  }

  // This checks only Flutter Element/RenderObject attachment and size. It does
  // not prove that the native UIKit UIView is in a window or has video frames;
  // use Express lifecycle logs to inspect the native view hierarchy.
  void logPlatformViewConstraints({
    required BuildContext context,
    required String userID,
    required int viewID,
    required BoxConstraints constraints,
    required bool cameraOn,
    required int widgetHashCode,
  }) {
    lastLoggedPlatformViewConstraints = constraints;
    lastLoggedPlatformViewUserID = userID;
    lastLoggedPlatformViewID = viewID;
    lastLoggedPlatformViewWidgetHashCode = widgetHashCode;
    lastLoggedPlatformViewCameraState = cameraOn;
    ZegoLoggerService.logInfo(
      'PlatformView layout, user:$userID, viewID:$viewID, '
      'constraints:{minWidth:${constraints.minWidth}, '
      'maxWidth:${constraints.maxWidth}, '
      'minHeight:${constraints.minHeight}, '
      'maxHeight:${constraints.maxHeight}, '
      'hasBoundedWidth:${constraints.hasBoundedWidth}, '
      'hasBoundedHeight:${constraints.hasBoundedHeight}}, '
      'camera:$cameraOn, widgetHash:$widgetHashCode, '
      'layoutRenderObjects:${renderObjectChain(context)}',
      tag: 'uikit-component',
      subTag: 'audio video view',
    );
  }

  void schedulePlatformViewConstraintsLog({
    required BuildContext context,
    required String userID,
    required int viewID,
    required BoxConstraints constraints,
    required bool cameraOn,
    required int widgetHashCode,
  }) {
    final isSamePendingLog = pendingPlatformViewConstraints == constraints &&
        pendingPlatformViewUserID == userID &&
        pendingPlatformViewID == viewID &&
        pendingPlatformViewWidgetHashCode == widgetHashCode &&
        pendingPlatformViewCameraState == cameraOn;
    if (isSamePendingLog && platformViewConstraintsLogTimer?.isActive == true) {
      return;
    }

    platformViewConstraintsLogTimer?.cancel();
    pendingPlatformViewConstraints = constraints;
    pendingPlatformViewUserID = userID;
    pendingPlatformViewID = viewID;
    pendingPlatformViewWidgetHashCode = widgetHashCode;
    pendingPlatformViewCameraState = cameraOn;
    platformViewConstraintsLogTimer = Timer(
      const Duration(milliseconds: 500),
      () {
        platformViewConstraintsLogTimer = null;
        clearPendingPlatformViewConstraintsLog();
        if (!mounted ||
            !Platform.isIOS ||
            !ZegoUIKitCore.shared.coreData.isEnablePlatformView) {
          return;
        }
        logPlatformViewConstraints(
          context: context,
          userID: userID,
          viewID: viewID,
          constraints: constraints,
          cameraOn: cameraOn,
          widgetHashCode: widgetHashCode,
        );
      },
    );
  }

  void cancelPlatformViewConstraintsLog() {
    platformViewConstraintsLogTimer?.cancel();
    platformViewConstraintsLogTimer = null;
    clearPendingPlatformViewConstraintsLog();
  }

  void clearPendingPlatformViewConstraintsLog() {
    pendingPlatformViewConstraints = null;
    pendingPlatformViewUserID = null;
    pendingPlatformViewID = null;
    pendingPlatformViewWidgetHashCode = null;
    pendingPlatformViewCameraState = null;
  }

  void onUserListUpdated(List<ZegoUIKitUser> users) {
    setState(() {});
  }

  void onAudioVideoListUpdated(List<ZegoUIKitUser> users) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (ZegoUIKit().getUser(widget.user?.id ?? '').isEmpty()) {
      cancelPlatformViewConstraintsLog();
      ZegoLoggerService.logInfo(
        'use id:(${widget.user?.id}) is null',
        tag: 'uikit-component',
        subTag: 'audio video view',
      );

      return SizedBox.expand(
        child: Stack(
          children: [
            background(),
            foreground(),
          ],
        ),
      );
    }

    ZegoLoggerService.logInfo(
      '${widget.user?.id}\' build,',
      tag: 'uikit-component',
      subTag: 'audio video view',
    );

    return circleBorder(
      child: ValueListenableBuilder<bool>(
        valueListenable:
            ZegoUIKit().getCameraStateNotifier(widget.user?.id ?? ''),
        builder: (context, isCameraOn, _) {
          ZegoLoggerService.logInfo(
            '${widget.user?.id}\'s camera changed $isCameraOn,',
            tag: 'uikit-component',
            subTag: 'audio video view',
          );

          final isLocalUser = null != widget.user &&
              ZegoUIKit().getLocalUser().id == widget.user?.id;

          final content = isCameraOn
              ? Stack(
                  children: [
                    background(),
                    videoView(isCameraOn: true),
                    foreground(),
                    testViewID(),
                  ],
                )
              : Stack(
                  children: [
                    videoView(isCameraOn: false), //
                    background(),
                    foreground(),
                    testViewID(),
                  ],
                );

          return SizedBox.expand(
            child: (isLocalUser && isCameraOn)
                ? localCameraFlipAnimation(content)
                : content,
          );
        },
      ),
    );
  }

  Widget testViewID() {
    return Container();

    // if (kDebugMode) {
    //   return ValueListenableBuilder<int?>(
    //     valueListenable:
    //         ZegoUIKit().getAudioVideoViewIDNotifier(widget.user!.id),
    //     builder: (context, viewID, _) {
    //       return Align(
    //         alignment: Alignment.topRight,
    //         child: Text(
    //           "view id:$viewID",
    //           style: TextStyle(fontSize: 30.zR, color: Colors.red),
    //         ),
    //       );
    //     },
    //   );
    // }
    //
    // return Container();
  }

  Widget localCameraFlipAnimation(Widget child) {
    /// Camera-switch flip animation for the local user.
    // iOS PlatformViews are composited as native UIViews and may not remain
    // visible beneath a Flutter 3D Transform. Skip this flip in PiP to avoid
    // hiding the view while native frames continue rendering; native preview
    // handles camera orientation.
    if (Platform.isIOS && ZegoUIKitCore.shared.coreData.isEnablePlatformView) {
      return child;
    }

    return ValueListenableBuilder<bool>(
      valueListenable: localUserData.isFrontFacing,
      builder: (context, isReadyFrontFacing, _) {
        localUserData.mainChannel.isCapturedVideoFirstFrameNotifier
            .addListener(onCapturedVideoFirstFrameAfterSwitchCamera);

        return ZegoUIKitFlipTransition(
          key: ValueKey(localUserData.id),
          isFlippedNotifier: isLocalUserFlippedNotifier,
          isFrontTriggerByTurnOnCamera:
              localUserData.isFrontTriggerByTurnOnCamera,
          child: ValueListenableBuilder<bool>(
            valueListenable:
                localUserData.mainChannel.isRenderedVideoFirstFrameNotifier,
            builder: (context, isRenderedVideoFirstFrame, _) {
              return isRenderedVideoFirstFrame
                  ? child
                  : Stack(
                      children: [
                        child,

                        /// it was an overlay of the rendered frame, but the current video frame could not be obtained
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.withValues(alpha: 0.05),
                                Colors.black.withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    );
            },
          ),
        );
      },
    );
  }

  void onCapturedVideoFirstFrameAfterSwitchCamera() {
    ZegoUIKitCore
        .shared.coreData.localUser.mainChannel.isCapturedVideoFirstFrameNotifier
        .removeListener(onCapturedVideoFirstFrameAfterSwitchCamera);

    isLocalUserFlippedNotifier.value = !isLocalUserFlippedNotifier.value;

    if (logEnabled) {
      ZegoLoggerService.logInfo(
        'onCapturedVideoFirstFrameAfterSwitchCamera',
        tag: 'uikit-component',
        subTag: 'audio video view',
      );
    }
  }

  Widget videoView({
    required bool isCameraOn,
  }) {
    return userViewListenerBuilder(
      childBuilder: (Widget audioVideoView) {
        if (!isCameraOn) {
          viewIDGuardTimer?.cancel();
          viewIDGuardTimer = null;
        } else if (userViewIDIsEmpty) {
          runViewIDTimeGuard();
        }

        if (ZegoUIKit().getUser(widget.user!.id).isEmpty()) {
          cancelPlatformViewConstraintsLog();
          return Container();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            if (Platform.isIOS &&
                ZegoUIKitCore.shared.coreData.isEnablePlatformView) {
              final currentUserID = widget.user?.id ?? '';
              final currentViewID = userViewID;
              final currentWidgetHashCode = audioVideoView.hashCode;
              final previousConstraints = lastLoggedPlatformViewConstraints;
              final constraintsChanged = previousConstraints != constraints;
              final widthHasZeroExtent = constraints.maxWidth <= 0;
              final heightHasZeroExtent = constraints.maxHeight <= 0;
              final widthHadZeroExtent = previousConstraints != null &&
                  previousConstraints.maxWidth <= 0;
              final heightHadZeroExtent = previousConstraints != null &&
                  previousConstraints.maxHeight <= 0;
              final zeroExtentBoundaryChanged = previousConstraints != null &&
                  (widthHasZeroExtent != widthHadZeroExtent ||
                      heightHasZeroExtent != heightHadZeroExtent);
              final identityChanged =
                  lastLoggedPlatformViewUserID != currentUserID ||
                      lastLoggedPlatformViewID != currentViewID ||
                      lastLoggedPlatformViewWidgetHashCode !=
                          currentWidgetHashCode ||
                      lastLoggedPlatformViewCameraState != isCameraOn;
              final shouldLogFrameState = previousConstraints == null ||
                  identityChanged ||
                  zeroExtentBoundaryChanged;
              if (shouldLogFrameState) {
                cancelPlatformViewConstraintsLog();
                logPlatformViewConstraints(
                  context: context,
                  userID: currentUserID,
                  viewID: currentViewID,
                  constraints: constraints,
                  cameraOn: isCameraOn,
                  widgetHashCode: currentWidgetHashCode,
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final isContextMounted = context.mounted;
                  ZegoLoggerService.logInfo(
                    'audio video layout frame committed, '
                    'user:$currentUserID, viewID:$currentViewID, '
                    'widgetHash:$currentWidgetHashCode, camera:$isCameraOn, '
                    'stateMounted:$mounted, contextMounted:$isContextMounted, '
                    'renderObjects:${renderObjectChain(context)}',
                    tag: 'uikit-component',
                    subTag: 'audio video view',
                  );
                });
              } else if (constraintsChanged) {
                schedulePlatformViewConstraintsLog(
                  context: context,
                  userID: currentUserID,
                  viewID: currentViewID,
                  constraints: constraints,
                  cameraOn: isCameraOn,
                  widgetHashCode: currentWidgetHashCode,
                );
              } else {
                cancelPlatformViewConstraintsLog();
              }
            } else {
              cancelPlatformViewConstraintsLog();
            }

            if (logEnabled) {
              ZegoLoggerService.logInfo(
                '${widget.user?.id}\'s constraints changed,'
                'width:${constraints.maxWidth}, '
                'height:${constraints.maxHeight}, '
                'isCameraOn:$isCameraOn, ',
                tag: 'uikit-component',
                subTag: 'audio video view',
              );
            }

            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: isCameraOn
                  ? audioVideoView
                  : Container(color: Colors.transparent),
            );
          },
        );
      },
    );
  }

  Widget userViewListenerBuilder({
    required Widget Function(
      Widget audioVideoView,
    ) childBuilder,
  }) {
    return ValueListenableBuilder<Widget?>(
      valueListenable: ZegoUIKit().getAudioVideoViewNotifier(widget.user!.id),
      builder: (context, userView, _) {
        if (userView == null) {
          cancelPlatformViewConstraintsLog();
          ZegoLoggerService.logInfo(
            'PlatformView widget is absent from audio video view, '
            'user:${widget.user?.id}, viewID:$userViewID, '
            'state:${identityHashCode(this)}, '
            'platformView:${ZegoUIKitCore.shared.coreData.isEnablePlatformView}, '
            'renderObjects:${renderObjectChain(context)}',
            tag: 'uikit-component',
            subTag: 'audio video view',
          );
          ZegoLoggerService.logError(
            '${widget.user?.id}\'s view is null',
            tag: 'uikit-component',
            subTag: 'audio video view',
          );

          /// hide video view when use not found
          return Container(color: Colors.transparent);
        }

        final currentViewID = userViewID;
        if (lastLoggedViewHashCode != userView.hashCode) {
          lastLoggedViewHashCode = userView.hashCode;
          final stateHashAtBuild = identityHashCode(this);
          ZegoLoggerService.logInfo(
            'video widget enters audio video view, '
            'user:${widget.user?.id}, '
            'widgetHash:${userView.hashCode}, viewID:$currentViewID, '
            'state:$stateHashAtBuild, '
            'camera:${ZegoUIKit().getCameraStateNotifier(widget.user?.id ?? '').value}, '
            'platformView:${ZegoUIKitCore.shared.coreData.isEnablePlatformView}',
            tag: 'uikit-component',
            subTag: 'audio video view',
          );
        }

        if (logEnabled) {
          ZegoLoggerService.logInfo(
            'render ${widget.user?.id}\'s view ${userView.hashCode}',
            tag: 'uikit-component',
            subTag: 'audio video view',
          );
        }

        return deviceOrientationListenerBuilder(
          child: childBuilder(userView),
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

  Widget background() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            ValueListenableBuilder(
              valueListenable: ZegoUIKitUserPropertiesNotifier(
                widget.user ?? ZegoUIKitUser.empty(),
              ),
              builder: (context, _, __) {
                return widget.backgroundBuilder?.call(
                      context,
                      Size(constraints.maxWidth, constraints.maxHeight),
                      widget.user,
                      widget.extraInfo ?? {},
                    ) ??
                    Container(color: Colors.transparent);
              },
            ),
            avatar(constraints.maxWidth, constraints.maxHeight),
          ],
        );
      },
    );
  }

  Widget foreground() {
    if (widget.foregroundBuilder != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Stack(children: [
            ValueListenableBuilder(
              valueListenable: ZegoUIKitUserPropertiesNotifier(
                widget.user ?? ZegoUIKitUser.empty(),
              ),
              builder: (context, _, __) {
                return widget.foregroundBuilder!.call(
                  context,
                  Size(constraints.maxWidth, constraints.maxHeight),
                  widget.user,
                  widget.extraInfo ?? {},
                );
              },
            ),
          ]);
        },
      );
    }

    return Container(color: Colors.transparent);
  }

  Widget circleBorder({required Widget child}) {
    if (widget.borderRadius == null) {
      return child;
    }

    // Rounded clipping can place an iOS platform view above Flutter overlays.
    // Keep native video square-cornered so PIP controls remain visible.
    final clipBehavior =
        Platform.isIOS && ZegoUIKitCore.shared.coreData.isEnablePlatformView
            ? Clip.none
            : Clip.antiAlias;

    final decoration = BoxDecoration(
      border: Border.all(
          color: widget.borderColor ?? const Color(0xffA4A4A4), width: 1),
      borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius!)),
    );

    return Container(
      decoration: decoration,
      child: PhysicalModel(
        color: widget.borderColor ?? const Color(0xffA4A4A4),
        borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius!)),
        clipBehavior: clipBehavior,
        elevation: 6.0,
        shadowColor: (widget.borderColor ?? const Color(0xffA4A4A4))
            .withValues(alpha: 0.3),
        child: child,
      ),
    );
  }

  Widget avatar(double maxWidth, double maxHeight) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallView = maxHeight < screenSize.height / 2;
    final avatarSize =
        isSmallView ? Size(110.zR, 110.zR) : Size(258.zR, 258.zR);

    var sizedWidth = widget.avatarConfig?.size?.width ?? avatarSize.width;
    var sizedHeight = widget.avatarConfig?.size?.height ?? avatarSize.width;
    if (sizedWidth > maxWidth) {
      sizedWidth = maxWidth;
    }
    if (sizedHeight > maxHeight) {
      sizedHeight = maxHeight;
    }

    return Positioned(
      top: getAvatarTop(maxWidth, maxHeight, sizedHeight),
      left: (maxWidth - sizedWidth) / 2,
      child: SizedBox(
        width: sizedWidth,
        height: sizedHeight,
        child: ZegoAvatar(
          avatarSize: widget.avatarConfig?.size ?? avatarSize,
          user: widget.user,
          showAvatar: widget.avatarConfig?.showInAudioMode ?? true,
          showSoundLevel:
              widget.avatarConfig?.showSoundWavesInAudioMode ?? true,
          avatarBuilder: widget.avatarConfig?.builder,
          soundLevelSize: widget.avatarConfig?.size,
          soundLevelColor: widget.avatarConfig?.soundWaveColor,
        ),
      ),
    );
  }

  double getAvatarTop(double maxWidth, double maxHeight, double avatarHeight) {
    switch (
        widget.avatarConfig?.verticalAlignment ?? ZegoAvatarAlignment.center) {
      case ZegoAvatarAlignment.center:
        return (maxHeight - avatarHeight) / 2;
      case ZegoAvatarAlignment.start:
        return 15.zR; //  sound level height
      case ZegoAvatarAlignment.end:
        return maxHeight - avatarHeight;
    }
  }

  void runViewIDTimeGuard() {
    if (logEnabled) {
      ZegoLoggerService.logInfo(
        'guard run, ${widget.user?.id}\'s view id is:$userViewID',
        tag: 'uikit-component',
        subTag: 'audio video view',
      );
    }

    viewIDGuardTimer?.cancel();
    viewIDGuardTimer = null;

    viewIDGuardTimer ??=
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (logEnabled) {
        ZegoLoggerService.logInfo(
          'guard check, ${widget.user?.id}\'s view id is:$userViewID',
          tag: 'uikit-component',
          subTag: 'audio video view',
        );
      }

      if (!userViewIDIsEmpty) {
        viewIDGuardTimer?.cancel();
      } else {
        if (logEnabled) {
          ZegoLoggerService.logInfo(
            'guard check, ${widget.user?.id}\'s view-id($userViewID) is not valid now, force update',
            tag: 'uikit-component',
            subTag: 'audio video view',
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {});
        });
      }
    });
  }
}
