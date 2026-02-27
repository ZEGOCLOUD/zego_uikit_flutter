// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/components/internal/internal.dart';
import 'package:zego_uikit/src/components/screen_util/screen_util.dart';
import 'package:zego_uikit/src/services/services.dart';

/// quit room/channel/group
class ZegoLeaveButton extends StatefulWidget {
  final String roomID;
  final ButtonIcon? icon;

  ///  You can do what you want before clicked.
  ///  Return true, exit;
  ///  Return false, will not exit.
  final Future<bool?> Function(BuildContext context)? onLeaveConfirmation;

  ///  You can do what you want after pressed.
  final VoidCallback? onPress;

  ///  custom quit logic
  ///  default is leave room
  final void Function(String roomID)? quitDelegate;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;

  final ValueNotifier<bool>? clickableNotifier;

  const ZegoLeaveButton({
    super.key,
    required this.roomID,
    this.quitDelegate,
    this.onLeaveConfirmation,
    this.onPress,
    this.icon,
    this.iconSize,
    this.buttonSize,
    this.clickableNotifier,
  });

  @override
  State<ZegoLeaveButton> createState() => _ZegoLeaveButtonState();
}

class _ZegoLeaveButtonState extends State<ZegoLeaveButton> {
  final roomLoginNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    ZegoLoggerService.logInfo(
      'initState, '
      'room id:${widget.roomID},',
      tag: 'uikit.component',
      subTag: 'leave button',
    );

    onRoomsStateUpdated();
    ZegoUIKit().getRoomsStateStream().addListener(onRoomsStateUpdated);
  }

  @override
  Widget build(BuildContext context) {
    final containerSize = widget.buttonSize ?? Size(96.zR, 96.zR);
    final sizeBoxSize = widget.iconSize ?? Size(56.zR, 56.zR);

    return ValueListenableBuilder<bool>(
      valueListenable: widget.clickableNotifier ?? ValueNotifier<bool>(true),
      builder: (context, clickable, _) {
        return ValueListenableBuilder(
            valueListenable: roomLoginNotifier,
            builder: (context, isRoomLogin, _) {
              return GestureDetector(
                onTap: () async {
                  if (!clickable || !isRoomLogin) {
                    ZegoLoggerService.logInfo(
                      'clickable:$clickable, '
                      'room id:${widget.roomID}, '
                      'isRoomLogin:$isRoomLogin, '
                      'ignore',
                      tag: 'uikit.component',
                      subTag: 'leave button',
                    );

                    return;
                  }

                  ///  if there is a user-defined event before the click,
                  ///  wait the synchronize execution result
                  final isConfirm =
                      await widget.onLeaveConfirmation?.call(context) ?? true;
                  if (isConfirm) {
                    quit();
                  }
                },
                child: Container(
                  width: containerSize.width,
                  height: containerSize.height,
                  decoration: BoxDecoration(
                    color: widget.icon?.backgroundColor ??
                        Colors.black.withAlpha(70),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.fromSize(
                    size: sizeBoxSize,
                    child: widget.icon?.icon ??
                        UIKitImage.asset(StyleIconUrls.iconS1ControlBarEnd),
                  ),
                ),
              );
            });
      },
    );
  }

  void quit() {
    if (null != widget.quitDelegate) {
      ZegoLoggerService.logInfo(
        'room id:${widget.roomID}, '
        'has quit delegate, call',
        tag: 'uikit.component',
        subTag: 'leave button',
      );

      widget.quitDelegate?.call(widget.roomID);
    } else {
      ZegoUIKit().leaveRoom(targetRoomID: widget.roomID).then((result) {
        ZegoLoggerService.logInfo(
          'room id:${widget.roomID}, '
          'leave room result, ${result.errorCode} ${result.extendedData}',
          tag: 'uikit.component',
          subTag: 'leave button',
        );
      });
    }

    if (widget.onPress != null) {
      widget.onPress!();
    }
  }

  void onRoomsStateUpdated() {
    final roomsState = ZegoUIKit().getRoomsStateStream().value;
    ZegoLoggerService.logInfo(
      'rooms state update, '
      'room id:${widget.roomID}, '
      'roomsState:$roomsState, ',
      tag: 'uikit.component',
      subTag: 'leave button',
    );

    if (!roomsState.containsKey(widget.roomID)) {
      return;
    }

    roomLoginNotifier.value = roomsState[widget.roomID]!.isLogin2;
  }
}
