// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:native_device_orientation/native_device_orientation.dart';

// Project imports:
import 'package:zego_uikit/src/components/components.dart';
import 'package:zego_uikit/src/components/internal/internal.dart';
import 'package:zego_uikit/src/services/services.dart';
import 'count_down.dart';

const isScreenSharingExtraInfoKey = 'isScreenSharing';

/// display user screensharing information,
/// and z order of widget(from bottom to top) is:
/// 1. background view
/// 2. screen sharing view
/// 3. foreground view
class ZegoScreenSharingView extends StatefulWidget {
  const ZegoScreenSharingView({
    super.key,
    required this.roomID,
    required this.user,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.borderRadius,
    this.borderColor = const Color(0xffA4A4A4),
    this.extraInfo = const {},
    this.showFullscreenModeToggleButtonRules =
        ZegoShowFullscreenModeToggleButtonRules.showWhenScreenPressed,
    this.controller,
  });

  final String roomID;
  final ZegoUIKitUser? user;

  /// foreground builder, you can display something you want on top of the view,
  /// foreground will always show
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;

  /// background builder, you can display something when user close camera
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  final double? borderRadius;
  final Color borderColor;
  final Map<String, dynamic> extraInfo;

  final ZegoShowFullscreenModeToggleButtonRules
      showFullscreenModeToggleButtonRules;
  final ZegoScreenSharingViewController? controller;

  @override
  State<ZegoScreenSharingView> createState() => _ZegoScreenSharingViewState();
}

class _ZegoScreenSharingViewState extends State<ZegoScreenSharingView> {
  var invalidQualityCount = 0;
  ValueNotifier<bool> isShowFullScreenButtonNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    ZegoUIKit()
        .getAudioVideoSendVideoFirstFrameNotifier(
          targetRoomID: widget.roomID,
          ZegoUIKit().getLocalUser().id,
          streamType: ZegoStreamType.screenSharing,
        )
        .addListener(onSendVideoFirstFrame);
    onSendVideoFirstFrame();
  }

  @override
  void dispose() {
    super.dispose();

    ZegoUIKit()
        .getAudioVideoSendVideoFirstFrameNotifier(
          targetRoomID: widget.roomID,
          ZegoUIKit().getLocalUser().id,
          streamType: ZegoStreamType.screenSharing,
        )
        .removeListener(onSendVideoFirstFrame);

    ZegoUIKit()
        .getAudioVideoQualityNotifier(
          targetRoomID: widget.roomID,
          ZegoUIKit().getLocalUser().id,
          streamType: ZegoStreamType.screenSharing,
        )
        .removeListener(onQualityUpdated);
  }

  @override
  Widget build(BuildContext context) {
    return circleBorder(
      child: GestureDetector(
        child: AbsorbPointer(
          absorbing: false,
          child: Stack(
            children: [
              background(),
              videoView(),
              foreground(),
              fullScreenButton(),
              countdown(),
              testViewID(),
            ],
          ),
        ),
        onTap: () {
          if (!isShowFullScreenButtonNotifier.value) {
            isShowFullScreenButtonNotifier.value = true;
            Future.delayed(const Duration(seconds: 3), () {
              isShowFullScreenButtonNotifier.value = false;
            });
          }
        },
      ),
    );
  }

  Widget testViewID() {
    return Container();

    // if (kDebugMode) {
    //   return ValueListenableBuilder<int?>(
    //     valueListenable: ZegoUIKit().getAudioVideoViewIDNotifier(
    //       widget.user!.id,
    //       streamType: ZegoStreamType.screenSharing,
    //     ),
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

  Widget videoView() {
    if (widget.user == null) {
      return Container(color: Colors.transparent);
    }

    return SizedBox.expand(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ValueListenableBuilder<Widget?>(
            valueListenable: ZegoUIKit().getAudioVideoViewNotifier(
              targetRoomID: widget.roomID,
              widget.user!.id,
              streamType: ZegoStreamType.screenSharing,
            ),
            builder: (context, userView, _) {
              if (userView == null) {
                /// hide view when use not found
                return Container(color: Colors.transparent);
              }

              return StreamBuilder(
                stream: NativeDeviceOrientationCommunicator()
                    .onOrientationChanged(),
                builder: (context,
                    AsyncSnapshot<NativeDeviceOrientation> asyncResult) {
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

                  return userView;
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget background() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            ValueListenableBuilder(
              valueListenable: ZegoUIKitUserPropertiesNotifier(
                roomID: widget.roomID,
                widget.user ?? ZegoUIKitUser.empty(),
              ),
              builder: (context, _, __) {
                return widget.backgroundBuilder?.call(
                      context,
                      Size(constraints.maxWidth, constraints.maxHeight),
                      widget.user,
                      {
                        ZegoViewBuilderMapExtraInfoKey.isScreenSharingView.name:
                            true,
                        ...widget.extraInfo
                      },
                    ) ??
                    Container(color: Colors.red);
              },
            ),
          ],
        );
      },
    );
  }

  Widget foreground() {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: widget.user?.id == ZegoUIKit().getLocalUser().id
              ? const Color(0xFF333438)
              : Colors.transparent,
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              child: userName(context, constraints),
            ),
            ValueListenableBuilder(
              valueListenable: ZegoUIKitUserPropertiesNotifier(
                roomID: widget.roomID,
                widget.user ?? ZegoUIKitUser.empty(),
              ),
              builder: (context, _, __) {
                return widget.foregroundBuilder?.call(
                      context,
                      Size(constraints.maxWidth, constraints.maxHeight),
                      widget.user,
                      {
                        ZegoViewBuilderMapExtraInfoKey.isScreenSharingView.name:
                            true,
                        ZegoViewBuilderMapExtraInfoKey.isFullscreen.text:
                            widget.controller?.fullscreenUserNotifier.value !=
                                null,
                        ...widget.extraInfo
                      },
                    ) ??
                    Container();
              },
            ),
            localScreenShareTipView(),
          ],
        ),
      );
    });
  }

  Widget userName(BuildContext context, BoxConstraints constraints) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth * 0.8,
            ),
            child: Text(
              widget.user?.name ?? '',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 24.0.zR,
                color: const Color(0xffffffff),
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget localScreenShareTipView() {
    final tipView = widget.user?.id == ZegoUIKit().getLocalUser().id
        ? Container(
            color: const Color(0x00242736),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.controller?.private.sharingTipText ??
                        'You are sharing screen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32.zR,
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 20.zR)),
                  GestureDetector(
                    onTap: () {
                      ZegoUIKit.instance.stopSharingScreen(
                        targetRoomID: widget.roomID,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(30.zR),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red,
                        ),
                        borderRadius: BorderRadius.circular(6.zR),
                      ),
                      child: Text(
                        widget.controller?.private.stopSharingButtonText ??
                            'Stop sharing',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 26.zR,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();

    return ValueListenableBuilder<bool>(
      valueListenable: ZegoUIKit().getScreenSharingStateNotifier(),
      builder: (context, isScreenSharing, _) {
        if (isScreenSharing &&
            widget.user?.id == ZegoUIKit().getLocalUser().id) {
          // if is sharing screen with is yourself audiovideoview show tip
          return tipView;
        }
        return Container();
      },
    );
  }

  Widget circleBorder({required Widget child}) {
    if (widget.borderRadius == null) {
      return child;
    }

    final decoration = BoxDecoration(
      border: Border.all(color: widget.borderColor, width: 1),
      borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius!)),
    );

    return Container(
      decoration: decoration,
      child: PhysicalModel(
        color: widget.borderColor,
        borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius!)),
        clipBehavior: Clip.antiAlias,
        elevation: 6.0,
        shadowColor: widget.borderColor.withValues(alpha: 0.3),
        child: child,
      ),
    );
  }

  Widget countdown() {
    final settings = widget.controller?.private.countDownStopSettings;
    if (settings == null) {
      return const SizedBox();
    }

    if (!settings.support) {
      return const SizedBox();
    }

    return ValueListenableBuilder<bool>(
      valueListenable: settings.countDownStartNotifier,
      builder: (context, isStarted, _) {
        return isStarted
            ? Center(
                child: ZegoScreenSharingCountdownTimer(
                  seconds: settings.seconds,
                  tips: settings.tips,
                  textColor: settings.textColor,
                  progressColor: settings.progressColor,
                  secondFontSize: settings.secondFontSize,
                  tipsFontSize: settings.tipsFontSize,
                  onCountDownFinished: settings.onCountDownFinished,
                ),
              )
            : const SizedBox();
      },
    );
  }

  Widget fullScreenButton() {
    switch (widget.showFullscreenModeToggleButtonRules) {
      case ZegoShowFullscreenModeToggleButtonRules.alwaysShow:
        return Positioned(
          top: 0,
          bottom: 0,
          right: 20.zR,
          child: Center(
            child: getFullScreenIconButton(),
          ),
        );
      case ZegoShowFullscreenModeToggleButtonRules.alwaysHide:
        return Container();
      case ZegoShowFullscreenModeToggleButtonRules.showWhenScreenPressed:
        return ValueListenableBuilder<bool>(
          valueListenable: isShowFullScreenButtonNotifier,
          builder: (context, isShow, _) {
            if (isShow) {
              return Positioned(
                top: 0,
                bottom: 0,
                child: Center(
                  child: getFullScreenIconButton(),
                ),
              );
            } else {
              return Container();
            }
          },
        );
    }
  }

  IconButton getFullScreenIconButton() {
    return IconButton(
      iconSize: 50.zR,
      icon: getFullScreenIcon(),
      onPressed: () {
        /// notify ZegoAudioVideoContainer to update layout
        if (widget.user?.id ==
            widget.controller?.fullscreenUserNotifier.value?.id) {
          widget.controller?.fullscreenUserNotifier.value = null;
        } else {
          widget.controller?.fullscreenUserNotifier.value = widget.user;
        }
      },
    );
  }

  Image getFullScreenIcon() {
    if (widget.controller?.fullscreenUserNotifier.value?.id ==
        widget.user?.id) {
      return UIKitImage.asset(StyleIconUrls.iconVideoViewFullScreenClose);
    } else {
      return UIKitImage.asset(StyleIconUrls.iconVideoViewFullScreenOpen);
    }
  }

  void onSendVideoFirstFrame() {
    final value = ZegoUIKit()
        .getAudioVideoSendVideoFirstFrameNotifier(
          targetRoomID: widget.roomID,
          ZegoUIKit().getLocalUser().id,
          streamType: ZegoStreamType.screenSharing,
        )
        .value;

    if (value) {
      /// start publishing
      ZegoUIKit()
          .getAudioVideoSendVideoFirstFrameNotifier(
            targetRoomID: widget.roomID,
            ZegoUIKit().getLocalUser().id,
            streamType: ZegoStreamType.screenSharing,
          )
          .removeListener(onSendVideoFirstFrame);

      /// listen for system stop screen sharing
      ZegoUIKit()
          .getAudioVideoQualityNotifier(
            targetRoomID: widget.roomID,
            ZegoUIKit().getLocalUser().id,
            streamType: ZegoStreamType.screenSharing,
          )
          .addListener(onQualityUpdated);
    }
  }

  void onQualityUpdated() {
    final value = ZegoUIKit()
        .getAudioVideoQualityNotifier(
          targetRoomID: widget.roomID,
          ZegoUIKit().getLocalUser().id,
          streamType: ZegoStreamType.screenSharing,
        )
        .value;

    if (value.videoCaptureFPS < 0.01) {
      invalidQualityCount++;
    } else {
      invalidQualityCount = 0;
    }

    final settings = widget.controller?.private.autoStopSettings ??
        ZegoScreenSharingAutoStopSettings();
    if (invalidQualityCount >= settings.invalidCount) {
      ZegoUIKit()
          .getAudioVideoQualityNotifier(
            targetRoomID: widget.roomID,
            ZegoUIKit().getLocalUser().id,
            streamType: ZegoStreamType.screenSharing,
          )
          .removeListener(onQualityUpdated);

      if (settings.canEnd?.call() ?? true) {
        /// system stopped
        ZegoUIKit.instance.stopSharingScreen(
          targetRoomID: widget.roomID,
        );
      }
    }
  }
}
