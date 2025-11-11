// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/components/internal/internal.dart';
import 'package:zego_uikit/src/components/screen_util/screen_util.dart';
import 'package:zego_uikit/src/components/widgets/widgets.dart';
import 'package:zego_uikit/src/services/services.dart';

class ZegoInRoomMessageInput extends StatefulWidget {
  const ZegoInRoomMessageInput({
    Key? key,
    required this.roomID,
    this.placeHolder = 'Say something...',
    this.payloadAttributes,
    this.backgroundColor,
    this.inputBackgroundColor,
    this.textColor,
    this.textHintColor,
    this.cursorColor,
    this.buttonColor,
    this.borderRadius,
    this.enabled = true,
    this.autofocus = true,
    this.onSubmit,
    this.valueNotifier,
    this.focusNotifier,
  }) : super(key: key);

  final String roomID;
  final String placeHolder;
  final Map<String, String>? payloadAttributes;
  final Color? backgroundColor;
  final Color? inputBackgroundColor;
  final Color? textColor;
  final Color? textHintColor;
  final Color? cursorColor;
  final Color? buttonColor;
  final double? borderRadius;
  final bool enabled;
  final bool autofocus;
  final VoidCallback? onSubmit;
  final ValueNotifier<String>? valueNotifier;
  final ValueNotifier<bool>? focusNotifier;

  @override
  State<ZegoInRoomMessageInput> createState() => _ZegoInRoomMessageInputState();
}

class _ZegoInRoomMessageInputState extends State<ZegoInRoomMessageInput> {
  final TextEditingController textController = TextEditingController();
  ValueNotifier<bool> isEmptyNotifier = ValueNotifier(true);
  var focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    focusNode.addListener(onFocusChange);

    if (widget.valueNotifier != null) {
      textController.text = widget.valueNotifier!.value;

      isEmptyNotifier.value = textController.text.isEmpty;
    }
  }

  @override
  void dispose() {
    super.dispose();

    focusNode
      ..removeListener(onFocusChange)
      ..dispose();
  }

  void onFocusChange() {
    widget.focusNotifier?.value = focusNode.hasFocus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.zR, vertical: 15.zR),
      color: widget.backgroundColor ??
          const Color(0xff222222).withValues(alpha: 0.8),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 90.zR,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 10.zR),
            messageInput(),
            SizedBox(width: 10.zR),
            sendButton(),
            SizedBox(width: 10.zR),
          ],
        ),
      ),
    );
  }

  Widget messageInput() {
    final messageSendBgColor = widget.buttonColor ?? const Color(0xff3e3e3d);
    final messageSendCursorColor =
        widget.cursorColor ?? const Color(0xffA653ff);
    final messageSendHintStyle = TextStyle(
      color: widget.textHintColor ?? const Color(0xffa4a4a4),
      fontSize: 28.zR,
      fontWeight: FontWeight.w400,
    );
    final messageSendInputStyle = TextStyle(
      color: widget.textColor ?? Colors.white,
      fontSize: 28.zR,
      fontWeight: FontWeight.w400,
    );

    return Expanded(
      child: Container(
        height: 78.zR,
        decoration: BoxDecoration(
          color: widget.inputBackgroundColor ?? messageSendBgColor,
          borderRadius: BorderRadius.circular(16.zR),
        ),
        child: TextField(
          enabled: widget.enabled,
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: null,
          autofocus: widget.autofocus,
          focusNode: focusNode,
          inputFormatters: <TextInputFormatter>[
            LengthLimitingTextInputFormatter(400)
          ],
          controller: textController,
          onChanged: (String inputMessage) {
            widget.valueNotifier?.value = inputMessage;

            final valueIsEmpty = inputMessage.isEmpty;
            if (valueIsEmpty != isEmptyNotifier.value) {
              isEmptyNotifier.value = valueIsEmpty;
            }
          },
          textInputAction: TextInputAction.send,
          onSubmitted: (message) => send(),
          cursorColor: messageSendCursorColor,
          cursorHeight: 30.zR,
          cursorWidth: 3.zR,
          style: messageSendInputStyle,
          decoration: InputDecoration(
            hintText: widget.placeHolder,
            hintStyle: messageSendHintStyle,
            contentPadding: EdgeInsets.only(
              left: 20.zR,
              top: -5.zR,
              right: 20.zR,
              bottom: 15.zR,
            ),
            // isDense: true,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget sendButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: isEmptyNotifier,
      builder: (context, bool isEmpty, Widget? child) {
        return ZegoTextIconButton(
          onPressed: () {
            if (!isEmpty) send();
          },
          icon: ButtonIcon(
            icon: isEmpty
                ? UIKitImage.asset(StyleIconUrls.iconSendDisable)
                : UIKitImage.asset(StyleIconUrls.iconSend),
            backgroundColor: widget.buttonColor,
          ),
          iconSize: Size(68.zR, 68.zR),
          buttonSize: Size(72.zR, 72.zR),
        );
      },
    );
  }

  void send() {
    if (textController.text.isEmpty) {
      ZegoLoggerService.logInfo(
        'message is empty',
        tag: 'uikit-component',
        subTag: 'in room message input',
      );
      return;
    }

    if (widget.payloadAttributes?.isEmpty ?? true) {
      ZegoUIKit().sendInRoomMessage(
        targetRoomID: widget.roomID,
        textController.text,
      );
    } else {
      ZegoUIKit().sendInRoomMessage(
        targetRoomID: widget.roomID,
        ZegoInRoomMessage.jsonBody(
          message: textController.text,
          attributes: widget.payloadAttributes!,
        ),
      );
    }
    textController.clear();

    widget.valueNotifier?.value = '';

    widget.onSubmit?.call();
  }
}
