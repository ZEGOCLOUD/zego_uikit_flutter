// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/zego_uikit.dart';

class ZegoRefuseInvitationButtonResult {
  final String invitationID;
  final String code;
  final String message;

  ZegoRefuseInvitationButtonResult({
    required this.invitationID,
    required this.code,
    required this.message,
  });

  @override
  toString() {
    return 'code:$code, '
        'message:$message, '
        'invitation id:$invitationID, ';
  }
}

/// @nodoc
class ZegoRefuseInvitationButton extends StatefulWidget {
  const ZegoRefuseInvitationButton({
    super.key,
    required this.inviterID,
    this.isAdvancedMode = false,
    this.targetInvitationID,
    this.data,
    this.text,
    this.textStyle,
    this.icon,
    this.iconSize,
    this.buttonSize,
    this.iconTextSpacing,
    this.verticalLayout = true,
    this.onWillPress,
    this.onPressed,
    this.networkLoadingConfig,
    this.clickableTextColor = Colors.black,
    this.unclickableTextColor = Colors.black,
    this.clickableBackgroundColor = Colors.transparent,
    this.unclickableBackgroundColor = Colors.transparent,
  });
  final bool isAdvancedMode;

  final String inviterID;
  final String? targetInvitationID;
  final String? data;

  final String? text;
  final TextStyle? textStyle;
  final ButtonIcon? icon;

  final Size? iconSize;
  final Size? buttonSize;
  final double? iconTextSpacing;
  final bool verticalLayout;

  final Color? clickableTextColor;
  final Color? unclickableTextColor;
  final Color? clickableBackgroundColor;
  final Color? unclickableBackgroundColor;

  final void Function()? onWillPress;

  ///  You can do what you want after pressed.
  final void Function(ZegoRefuseInvitationButtonResult result)? onPressed;

  final ZegoNetworkLoadingConfig? networkLoadingConfig;

  @override
  State<ZegoRefuseInvitationButton> createState() =>
      _ZegoRefuseInvitationButtonState();
}

/// @nodoc
class _ZegoRefuseInvitationButtonState
    extends State<ZegoRefuseInvitationButton> {
  @override
  Widget build(BuildContext context) {
    return ZegoTextIconButton(
      onPressed: onPressed,
      text: widget.text,
      textStyle: widget.textStyle,
      icon: widget.icon,
      iconTextSpacing: widget.iconTextSpacing,
      iconSize: widget.iconSize,
      buttonSize: widget.buttonSize,
      verticalLayout: widget.verticalLayout,
      clickableTextColor: widget.clickableTextColor ?? Colors.white,
      unclickableTextColor: widget.unclickableTextColor,
      clickableBackgroundColor: widget.clickableBackgroundColor,
      unclickableBackgroundColor: widget.unclickableBackgroundColor,
      networkLoadingConfig: widget.networkLoadingConfig,
    );
  }

  Future<void> onPressed() async {
    widget.onWillPress?.call();

    final result = widget.isAdvancedMode
        ? await ZegoUIKit().getSignalingPlugin().refuseAdvanceInvitation(
              inviterID: widget.inviterID,
              data: widget.data ?? '',
              invitationID: widget.targetInvitationID,
            )
        : await ZegoUIKit().getSignalingPlugin().refuseInvitation(
              inviterID: widget.inviterID,
              data: widget.data ?? '',
              targetInvitationID: widget.targetInvitationID,
            );

    widget.onPressed?.call(
      ZegoRefuseInvitationButtonResult(
        invitationID: result.invitationID,
        code: result.error?.code ?? '',
        message: result.error?.message ?? '',
      ),
    );
  }
}
