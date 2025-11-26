// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/zego_uikit.dart';

class ZegoCancelInvitationButtonResult {
  final String invitationID;
  final String code;
  final String message;
  final List<String> errorInvitees;

  ZegoCancelInvitationButtonResult({
    required this.invitationID,
    required this.code,
    required this.message,
    required this.errorInvitees,
  });

  @override
  toString() {
    return 'code:$code, '
        'message:$message, '
        'invitation id:$invitationID, '
        'error invitees:$errorInvitees';
  }
}

/// @nodoc
class ZegoCancelInvitationButton extends StatefulWidget {
  const ZegoCancelInvitationButton({
    super.key,
    required this.invitees,
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
    this.onPressed,
    this.networkLoadingConfig,
    this.clickableTextColor = Colors.black,
    this.unclickableTextColor = Colors.black,
    this.clickableBackgroundColor = Colors.transparent,
    this.unclickableBackgroundColor = Colors.transparent,
  });
  final bool isAdvancedMode;

  final List<String> invitees;
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

  ///  You can do what you want after pressed.
  final void Function(ZegoCancelInvitationButtonResult result)? onPressed;

  final ZegoNetworkLoadingConfig? networkLoadingConfig;

  @override
  State<ZegoCancelInvitationButton> createState() =>
      _ZegoCancelInvitationButtonState();
}

/// @nodoc
class _ZegoCancelInvitationButtonState
    extends State<ZegoCancelInvitationButton> {
  @override
  Widget build(BuildContext context) {
    return ZegoTextIconButton(
      onPressed: onPressed,
      text: widget.text,
      textStyle: widget.textStyle,
      icon: widget.icon,
      iconTextSpacing: widget.iconTextSpacing,
      iconSize: widget.iconSize,
      borderRadius: widget.buttonSize?.width ?? 0 / 2,
      buttonSize: widget.buttonSize,
      verticalLayout: widget.verticalLayout,
      clickableTextColor: widget.clickableTextColor,
      unclickableTextColor: widget.unclickableTextColor,
      clickableBackgroundColor: widget.clickableBackgroundColor,
      unclickableBackgroundColor: widget.unclickableBackgroundColor,
      networkLoadingConfig: widget.networkLoadingConfig,
    );
  }

  Future<void> onPressed() async {
    final result = widget.isAdvancedMode
        ? await ZegoUIKit().getSignalingPlugin().cancelAdvanceInvitation(
              invitees: widget.invitees,
              data: widget.data ?? '',
              invitationID: widget.targetInvitationID,
            )
        : await ZegoUIKit().getSignalingPlugin().cancelInvitation(
              invitees: widget.invitees,
              data: widget.data ?? '',
            );

    widget.onPressed?.call(
      ZegoCancelInvitationButtonResult(
        invitationID: result.invitationID,
        code: result.error?.code ?? '',
        message: result.error?.message ?? '',
        errorInvitees: result.errorInvitees,
      ),
    );
  }
}
