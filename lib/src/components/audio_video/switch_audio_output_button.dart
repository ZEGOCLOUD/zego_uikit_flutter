// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/components/audio_video/button_rate_limit_mixin.dart';
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/components/internal/internal.dart';
import 'package:zego_uikit/src/components/screen_util/screen_util.dart';
import 'package:zego_uikit/src/services/services.dart';

/// button used to switch audio output route between speaker or system device
class ZegoSwitchAudioOutputButton extends StatefulWidget {
  const ZegoSwitchAudioOutputButton({
    Key? key,
    this.speakerIcon,
    this.headphoneIcon,
    this.bluetoothIcon,
    this.onPressed,
    this.defaultUseSpeaker = false,
    this.iconSize,
    this.buttonSize,
  }) : super(key: key);

  final ButtonIcon? speakerIcon;
  final ButtonIcon? headphoneIcon;
  final ButtonIcon? bluetoothIcon;

  ///  You can do what you want after pressed.
  final void Function(bool isON)? onPressed;

  /// whether to open speaker by default
  final bool defaultUseSpeaker;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;

  @override
  State<ZegoSwitchAudioOutputButton> createState() =>
      _ZegoSwitchAudioOutputButtonState();
}

class _ZegoSwitchAudioOutputButtonState
    extends State<ZegoSwitchAudioOutputButton> with ButtonRateLimitMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ZegoUIKitAudioRoute>(
      /// listen local audio output route changes
      valueListenable: ZegoUIKit()
          .getAudioOutputDeviceNotifier(ZegoUIKit().getLocalUser().id),
      builder: (context, audioRoute, _) {
        /// update icon/background if route changed
        return getAudioRouteButtonByRoute(audioRoute);
      },
    );
  }

  Widget getAudioRouteButtonByRoute(ZegoUIKitAudioRoute audioRoute) {
    Widget icon = UIKitImage.asset(StyleIconUrls.iconS1ControlBarSpeakerOff);
    var backgroundColor = controlBarButtonBackgroundColor;

    /// get the new icon and background color
    if (ZegoUIKitAudioRoute.bluetooth == audioRoute) {
      /// always open
      icon = widget.bluetoothIcon?.icon ??
          UIKitImage.asset(StyleIconUrls.iconS1ControlBarSpeakerBluetooth);
      backgroundColor = widget.bluetoothIcon?.backgroundColor ??
          controlBarButtonBackgroundColor;
    } else if (ZegoUIKitAudioRoute.headphone == audioRoute) {
      /// always display speaker closed
      icon = widget.headphoneIcon?.icon ??
          UIKitImage.asset(StyleIconUrls.iconS1ControlBarSpeakerOff);
      backgroundColor = widget.headphoneIcon?.backgroundColor ??
          controlBarButtonBackgroundColor;
    } else if (ZegoUIKitAudioRoute.speaker == audioRoute) {
      icon = widget.speakerIcon?.icon ??
          UIKitImage.asset(StyleIconUrls.iconS1ControlBarSpeakerNormal);
      backgroundColor = widget.speakerIcon?.backgroundColor ??
          controlBarButtonCheckedBackgroundColor;
    } else {
      icon = widget.headphoneIcon?.icon ??
          UIKitImage.asset(StyleIconUrls.iconS1ControlBarSpeakerOff);
      backgroundColor = widget.headphoneIcon?.backgroundColor ??
          controlBarButtonBackgroundColor;
    }

    final containerSize = widget.buttonSize ?? Size(96.zR, 96.zR);
    final sizeBoxSize = widget.iconSize ?? Size(56.zR, 56.zR);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: containerSize.width,
        height: containerSize.height,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: SizedBox.fromSize(
          size: sizeBoxSize,
          child: icon,
        ),
      ),
    );
  }

  void onPressed() {
    if (!executeWithRateLimit(() {
      final audioRoute = ZegoUIKit()
          .getAudioOutputDeviceNotifier(ZegoUIKit().getLocalUser().id)
          .value;
      if (ZegoUIKitAudioRoute.headphone == audioRoute ||
          ZegoUIKitAudioRoute.bluetooth == audioRoute) {
        ///  not support close
        return;
      }

      final targetState = audioRoute != ZegoUIKitAudioRoute.speaker;

      ZegoUIKit().setAudioOutputToSpeaker(targetState);

      if (widget.onPressed != null) {
        widget.onPressed!(targetState);
      }
    })) {
      ZegoLoggerService.logInfo(
        "Click rate is limited, ignoring the current click",
        tag: 'uikit-audio-output',
        subTag: 'switch audio output',
      );
    }
  }
}
