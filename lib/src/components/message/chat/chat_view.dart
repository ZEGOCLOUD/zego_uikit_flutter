// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/components/message/chat/chat_view_item.dart';
import 'package:zego_uikit/src/components/message/defines.dart';
import 'package:zego_uikit/src/components/message/message_view.dart';
import 'package:zego_uikit/src/components/screen_util/screen_util.dart';
import 'package:zego_uikit/src/services/services.dart';

class ZegoInRoomChatView extends StatefulWidget {
  final String roomID;
  final ZegoAvatarBuilder? avatarBuilder;
  final ZegoInRoomMessageItemBuilder? itemBuilder;
  final ScrollController? scrollController;

  const ZegoInRoomChatView({
    Key? key,
    required this.roomID,
    this.avatarBuilder,
    this.itemBuilder,
    this.scrollController,
  }) : super(key: key);

  @override
  State<ZegoInRoomChatView> createState() => _ZegoInRoomChatViewState();
}

class _ZegoInRoomChatViewState extends State<ZegoInRoomChatView> {
  @override
  Widget build(BuildContext context) {
    return ZegoInRoomMessageView(
      historyMessages:
          ZegoUIKit().getInRoomMessages(targetRoomID: widget.roomID),
      stream: ZegoUIKit().getInRoomMessageListStream(
        targetRoomID: widget.roomID,
      ),
      scrollController: widget.scrollController,
      itemBuilder: widget.itemBuilder ??
          (BuildContext context, ZegoInRoomMessage message, _) {
            return Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 0.0.zR, vertical: 20.0.zR),
              child: ZegoInRoomChatViewItem(
                roomID: widget.roomID,
                avatarBuilder: widget.avatarBuilder,
                message: message,
              ),
            );
          },
    );
  }
}
