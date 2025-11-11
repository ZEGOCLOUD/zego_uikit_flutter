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

/// button used to open/close microphone
class ZegoToggleMicrophoneButton extends StatefulWidget {
  const ZegoToggleMicrophoneButton({
    Key? key,
    required this.roomID,
    this.normalIcon,
    this.offIcon,
    this.onPressed,
    this.defaultOn = true,
    this.iconSize,
    this.buttonSize,
    this.muteMode = false,
  }) : super(key: key);

  final String roomID;
  final ButtonIcon? normalIcon;
  final ButtonIcon? offIcon;

  ///  You can do what you want after pressed.
  final void Function(bool isON)? onPressed;

  /// whether to open microphone by default
  final bool defaultOn;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;

  /// only use mute, will not stop the stream
  final bool muteMode;

  @override
  State<ZegoToggleMicrophoneButton> createState() =>
      _ZegoToggleMicrophoneButtonState();
}

class _ZegoToggleMicrophoneButtonState extends State<ZegoToggleMicrophoneButton>
    with ButtonRateLimitMixin {
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      /// synchronizing the default status
      ZegoUIKit().turnMicrophoneOn(
        targetRoomID: widget.roomID,
        widget.defaultOn,
        muteMode: widget.muteMode,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final containerSize = widget.buttonSize ?? Size(96.zR, 96.zR);
    final sizeBoxSize = widget.iconSize ?? Size(56.zR, 56.zR);

    /// listen local microphone state changes
    return ValueListenableBuilder<bool>(
      valueListenable: ZegoUIKit().getMicrophoneStateNotifier(
        targetRoomID: widget.roomID,
        ZegoUIKit().getLocalUser().id,
      ),
      builder: (context, isMicrophoneOn, _) {
        /// update if microphone state changed
        return GestureDetector(
          onTap: onPressed,
          child: Container(
            width: containerSize.width,
            height: containerSize.height,
            decoration: BoxDecoration(
              color: isMicrophoneOn
                  ? widget.normalIcon?.backgroundColor ??
                      controlBarButtonCheckedBackgroundColor
                  : widget.offIcon?.backgroundColor ??
                      controlBarButtonBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: SizedBox.fromSize(
              size: sizeBoxSize,
              child: isMicrophoneOn
                  ? widget.normalIcon?.icon ??
                      UIKitImage.asset(
                          StyleIconUrls.iconS1ControlBarMicrophoneNormal)
                  : widget.offIcon?.icon ??
                      UIKitImage.asset(
                          StyleIconUrls.iconS1ControlBarMicrophoneOff),
            ),
          ),
        );
      },
    );
  }

  void onPressed() {
    if (!executeWithRateLimit(() {
      /// get current microphone state
      final valueNotifier = ZegoUIKit().getMicrophoneStateNotifier(
        targetRoomID: widget.roomID,
        ZegoUIKit().getLocalUser().id,
      );

      final targetState = !valueNotifier.value;

      if (targetState) {
        requestPermission(Permission.microphone);
      }

      /// reverse current state
      ZegoUIKit().turnMicrophoneOn(
        targetRoomID: widget.roomID,
        targetState,
        muteMode: widget.muteMode,
      );

      if (widget.onPressed != null) {
        widget.onPressed!(targetState);
      }
    })) {
      ZegoLoggerService.logInfo(
        "here",
        tag: 'uikit-microphone',
        subTag: 'switch microphone',
      );
    }
  }
}
