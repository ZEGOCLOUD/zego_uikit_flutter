// ignore_for_file: no_leading_underscores_for_local_identifiers
part of 'core.dart';

/// @nodoc
mixin ZegoUIKitCoreMessage {
  final _messageImpl = ZegoUIKitCoreMessageImpl();

  ZegoUIKitCoreMessageImpl get message => _messageImpl;
}

/// @nodoc
class ZegoUIKitCoreMessageImpl extends ZegoUIKitExpressEventInterface {
  ZegoUIKitCoreData get coreData => ZegoUIKitCore.shared.coreData;

  void clear() {
    coreData.broadcastMessage.clear();
    coreData.barrageMessage.clear();
  }

  Future<int> sendBarrageMessage(String message) async {
    return _sendMessage(
      message,
      coreData.barrageMessage,
      ZegoInRoomMessageType.barrageMessage,
    );
  }

  /// @return Error code, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  Future<int> sendBroadcastMessage(String message) async {
    return _sendMessage(
      message,
      coreData.broadcastMessage,
      ZegoInRoomMessageType.broadcastMessage,
    );
  }

  Future<int> _sendMessage(
    String message,
    ZegoUIKitCoreDataMessageInfo messageInfo,
    ZegoInRoomMessageType type,
  ) async {
    messageInfo.localMessageId = messageInfo.localMessageId - 1;

    final messageItem = ZegoInRoomMessage(
      messageID: messageInfo.localMessageId.toString(),
      user: coreData.localUser.toZegoUikitUser(),
      message: message,
      timestamp: coreData.networkDateTime_.millisecondsSinceEpoch,
    );
    messageItem.state.value = ZegoInRoomMessageState.idle;

    if (ZegoInRoomMessageType.barrageMessage != type) {
      /// not cache barrage message
      messageInfo.messageList.add(messageItem);
    }
    messageInfo.streamControllerMessageList?.add(
      List<ZegoInRoomMessage>.from(messageInfo.messageList),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (ZegoInRoomMessageState.idle == messageItem.state.value) {
        /// if the status is still Idle after 300 ms,  it mean the message is not sent yet.
        messageItem.state.value = ZegoInRoomMessageState.sending;
        messageInfo.streamControllerMessageList?.add(
          List<ZegoInRoomMessage>.from(messageInfo.messageList),
        );
      }
    });

    return type == ZegoInRoomMessageType.broadcastMessage
        ? ZegoExpressEngine.instance
            .sendBroadcastMessage(coreData.room.id, message)
            .then((ZegoIMSendBroadcastMessageResult result) {
            messageItem.state.value = (result.errorCode == 0)
                ? ZegoInRoomMessageState.success
                : ZegoInRoomMessageState.failed;

            if (ZegoErrorCode.CommonSuccess == result.errorCode) {
              messageItem.messageID = result.messageID.toString();
            }
            messageInfo.streamControllerLocalMessage?.add(messageItem);

            messageInfo.streamControllerMessageList?.add(
              List<ZegoInRoomMessage>.from(messageInfo.messageList),
            );

            return result.errorCode;
          })
        : ZegoExpressEngine.instance
            .sendBarrageMessage(coreData.room.id, message)
            .then((ZegoIMSendBarrageMessageResult result) {
            messageItem.state.value = (result.errorCode == 0)
                ? ZegoInRoomMessageState.success
                : ZegoInRoomMessageState.failed;

            if (ZegoErrorCode.CommonSuccess == result.errorCode) {
              messageItem.messageID = result.messageID;
            }
            messageInfo.streamControllerLocalMessage?.add(messageItem);

            messageInfo.streamControllerMessageList?.add(
              List<ZegoInRoomMessage>.from(messageInfo.messageList),
            );

            return result.errorCode;
          });
  }

  /// @return Error code, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  Future<int> resendMessage(
    ZegoInRoomMessage message,
    ZegoInRoomMessageType type,
  ) async {
    switch (type) {
      case ZegoInRoomMessageType.broadcastMessage:
        coreData.broadcastMessage.messageList.removeWhere(
          (element) => element.messageID == message.messageID,
        );

        return sendBroadcastMessage(message.message);
      case ZegoInRoomMessageType.barrageMessage:
        coreData.barrageMessage.messageList.removeWhere(
          (element) => element.messageID == message.messageID,
        );

        return sendBarrageMessage(message.message);
    }
  }

  @override
  void onIMRecvBroadcastMessage(
    String roomID,
    List<ZegoBroadcastMessageInfo> messageList,
  ) {
    List<ZegoInRoomMessage> _messageList = [];
    for (final _message in messageList) {
      final message = ZegoInRoomMessage.fromBroadcastMessage(_message);
      _messageList.add(message);
    }

    _onIMRecvMessage(true, _messageList, coreData.broadcastMessage);
  }

  @override
  void onIMRecvBarrageMessage(
    String roomID,
    List<ZegoBarrageMessageInfo> messageList,
  ) {
    List<ZegoInRoomMessage> _messageList = [];
    for (final _message in messageList) {
      final message = ZegoInRoomMessage.fromBarrageMessage(_message);
      _messageList.add(message);
    }

    _onIMRecvMessage(false, _messageList, coreData.barrageMessage);
  }

  void _onIMRecvMessage(
    bool localCache,
    List<ZegoInRoomMessage> messageList,
    ZegoUIKitCoreDataMessageInfo messageInfo,
  ) {
    for (final message in messageList) {
      messageInfo.streamControllerRemoteMessage?.add(message);

      if (localCache) {
        messageInfo.messageList.add(message);
      }
    }

    if (messageInfo.messageList.length > 500) {
      messageInfo.messageList.removeRange(
        0,
        messageInfo.messageList.length - 500,
      );
    }

    messageInfo.streamControllerMessageList?.add(List<ZegoInRoomMessage>.from(
      localCache ? messageInfo.messageList : messageList,
    ));
  }
}
