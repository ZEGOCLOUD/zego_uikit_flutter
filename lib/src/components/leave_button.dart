// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/components/internal/internal.dart';
import 'package:zego_uikit/src/components/screen_util/screen_util.dart';
import 'package:zego_uikit/src/services/services.dart';

/// quit room/channel/group
class ZegoLeaveButton extends StatelessWidget {
  final ButtonIcon? icon;

  ///  You can do what you want before clicked.
  ///  Return true, exit;
  ///  Return false, will not exit.
  final Future<bool?> Function(BuildContext context)? onLeaveConfirmation;

  ///  You can do what you want after pressed.
  final VoidCallback? onPress;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;

  final ValueNotifier<bool>? clickableNotifier;

  const ZegoLeaveButton({
    Key? key,
    this.onLeaveConfirmation,
    this.onPress,
    this.icon,
    this.iconSize,
    this.buttonSize,
    this.clickableNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final containerSize = buttonSize ?? Size(96.zR, 96.zR);
    final sizeBoxSize = iconSize ?? Size(56.zR, 56.zR);

    return ValueListenableBuilder<bool>(
      valueListenable: clickableNotifier ?? ValueNotifier<bool>(true),
      builder: (context, clickable, _) {
        return GestureDetector(
          onTap: clickable
              ? () async {
                  ///  if there is a user-defined event before the click,
                  ///  wait the synchronize execution result
                  final isConfirm =
                      await onLeaveConfirmation?.call(context) ?? true;
                  if (isConfirm) {
                    quit();
                  }
                }
              : null,
          child: Container(
            width: containerSize.width,
            height: containerSize.height,
            decoration: BoxDecoration(
              color: icon?.backgroundColor ?? Colors.red,
              shape: BoxShape.circle,
            ),
            child: SizedBox.fromSize(
              size: sizeBoxSize,
              child: icon?.icon ??
                  UIKitImage.asset(StyleIconUrls.iconS1ControlBarEnd),
            ),
          ),
        );
      },
    );
  }

  void quit() {
    ZegoUIKit().leaveRoom().then((result) {
      ZegoLoggerService.logInfo(
        'leave room result, ${result.errorCode} ${result.extendedData}',
        tag: 'uikit-component',
        subTag: 'leave button',
      );
    });

    if (onPress != null) {
      onPress!();
    }
  }
}
