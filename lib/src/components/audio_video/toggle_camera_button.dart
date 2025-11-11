// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:zego_uikit/src/components/audio_video/button_rate_limit_mixin.dart';
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/components/internal/internal.dart';
import 'package:zego_uikit/src/components/screen_util/screen_util.dart';
import 'package:zego_uikit/src/services/services.dart';

/// button used to open/close camera
class ZegoToggleCameraButton extends StatefulWidget {
  const ZegoToggleCameraButton({
    Key? key,
    required this.roomID,
    this.normalIcon,
    this.offIcon,
    this.onPressed,
    this.defaultOn = true,
    this.iconSize,
    this.buttonSize,
  }) : super(key: key);

  final String roomID;
  final ButtonIcon? normalIcon;
  final ButtonIcon? offIcon;

  ///  You can do what you want after pressed.
  final void Function(bool isON)? onPressed;

  /// whether to open camera by default
  final bool defaultOn;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;

  @override
  State<ZegoToggleCameraButton> createState() => _ZegoToggleCameraButtonState();
}

class _ZegoToggleCameraButtonState extends State<ZegoToggleCameraButton>
    with ButtonRateLimitMixin {
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      /// synchronizing the default status
      ZegoUIKit().turnCameraOn(targetRoomID: widget.roomID, widget.defaultOn);
    });
  }

  @override
  Widget build(BuildContext context) {
    final containerSize = widget.buttonSize ?? Size(96.zR, 96.zR);
    final sizeBoxSize = widget.iconSize ?? Size(56.zR, 56.zR);

    /// listen local camera state changes
    return ValueListenableBuilder<bool>(
      valueListenable: ZegoUIKit().getCameraStateNotifier(
        targetRoomID: widget.roomID,
        ZegoUIKit().getLocalUser().id,
      ),
      builder: (context, isCameraOn, _) {
        /// update if camera state changed
        return GestureDetector(
          onTap: onPressed,
          child: Container(
            width: containerSize.width,
            height: containerSize.height,
            decoration: BoxDecoration(
              color: isCameraOn
                  ? widget.normalIcon?.backgroundColor ??
                      controlBarButtonCheckedBackgroundColor
                  : widget.offIcon?.backgroundColor ??
                      controlBarButtonBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: SizedBox.fromSize(
              size: sizeBoxSize,
              child: isCameraOn
                  ? widget.normalIcon?.icon ??
                      UIKitImage.asset(
                          StyleIconUrls.iconS1ControlBarCameraNormal)
                  : widget.offIcon?.icon ??
                      UIKitImage.asset(StyleIconUrls.iconS1ControlBarCameraOff),
            ),
          ),
        );
      },
    );
  }

  void onPressed() {
    if (!executeWithRateLimit(() {
      /// get current camera state
      final valueNotifier = ZegoUIKit().getCameraStateNotifier(
        targetRoomID: widget.roomID,
        ZegoUIKit().getLocalUser().id,
      );

      final targetState = !valueNotifier.value;

      if (targetState) {
        requestPermission(Permission.camera).then((value) {
          /// reverse current state
          ZegoUIKit().turnCameraOn(targetRoomID: widget.roomID, true);
        });
      } else {
        /// reverse current state
        ZegoUIKit().turnCameraOn(targetRoomID: widget.roomID, false);
      }

      if (widget.onPressed != null) {
        widget.onPressed!(targetState);
      }
    })) {
      ZegoLoggerService.logInfo(
        "Click rate is limited, ignoring the current click",
        tag: 'uikit-camera',
        subTag: 'toggle camera',
      );
    }
  }
}
