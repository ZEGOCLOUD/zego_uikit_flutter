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

  void clear({
    required String targetRoomID,
  }) {
    coreData.clearMessage(targetRoomID: targetRoomID);
  }

  Future<int> sendBarrageMessage(
    String message, {
    required String targetRoomID,
  }) async {
    return _sendMessage(
      message,
      coreData.multiRoomBarrageMessages.getRoom(targetRoomID),
      ZegoInRoomMessageType.barrageMessage,
      targetRoomID: targetRoomID,
    );
  }

  /// @return Error code, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  Future<int> sendBroadcastMessage(
    String message, {
    required String targetRoomID,
  }) async {
    return _sendMessage(
      message,
      coreData.multiRoomBroadcastMessages.getRoom(targetRoomID),
      ZegoInRoomMessageType.broadcastMessage,
      targetRoomID: targetRoomID,
    );
  }

  Future<int> _sendMessage(
    String message,
    ZegoUIKitCoreDataRoomMessageInfo roomMessageInfo,
    ZegoInRoomMessageType type, {
    required String targetRoomID,
  }) async {
    debugPrint('send message, '
        'room id:$targetRoomID, '
        'message:$message, '
        'type:$type');

    roomMessageInfo.localMessageId = roomMessageInfo.localMessageId - 1;

    final messageItem = ZegoInRoomMessage(
      messageID: roomMessageInfo.localMessageId.toString(),
      user: coreData.localUser.toZegoUikitUser(),
      message: message,
      timestamp: coreData.networkDateTime_.millisecondsSinceEpoch,
    );
    messageItem.state.value = ZegoInRoomMessageState.idle;

    if (ZegoInRoomMessageType.barrageMessage != type) {
      /// not cache barrage message
      roomMessageInfo.messageList.add(messageItem);
    }
    roomMessageInfo.streamControllerMessageList?.add(
      List<ZegoInRoomMessage>.from(roomMessageInfo.messageList),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (ZegoInRoomMessageState.idle == messageItem.state.value) {
        /// if the status is still Idle after 300 ms,  it mean the message is not sent yet.
        messageItem.state.value = ZegoInRoomMessageState.sending;
        roomMessageInfo.streamControllerMessageList?.add(
          List<ZegoInRoomMessage>.from(roomMessageInfo.messageList),
        );
      }
    });

    return type == ZegoInRoomMessageType.broadcastMessage
        ? ZegoExpressEngine.instance
            .sendBroadcastMessage(targetRoomID, message)
            .then((ZegoIMSendBroadcastMessageResult result) {
            messageItem.state.value = (result.errorCode == 0)
                ? ZegoInRoomMessageState.success
                : ZegoInRoomMessageState.failed;

            if (ZegoErrorCode.CommonSuccess == result.errorCode) {
              messageItem.messageID = result.messageID.toString();
            }
            roomMessageInfo.streamControllerLocalMessage?.add(messageItem);

            roomMessageInfo.streamControllerMessageList?.add(
              List<ZegoInRoomMessage>.from(roomMessageInfo.messageList),
            );

            return result.errorCode;
          })
        : ZegoExpressEngine.instance
            .sendBarrageMessage(targetRoomID, message)
            .then((ZegoIMSendBarrageMessageResult result) {
            messageItem.state.value = (result.errorCode == 0)
                ? ZegoInRoomMessageState.success
                : ZegoInRoomMessageState.failed;

            if (ZegoErrorCode.CommonSuccess == result.errorCode) {
              messageItem.messageID = result.messageID;
            }
            roomMessageInfo.streamControllerLocalMessage?.add(messageItem);

            roomMessageInfo.streamControllerMessageList?.add(
              List<ZegoInRoomMessage>.from(roomMessageInfo.messageList),
            );

            return result.errorCode;
          });
  }

  /// @return Error code, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  Future<int> resendMessage(
    ZegoInRoomMessage message,
    ZegoInRoomMessageType type, {
    required String targetRoomID,
  }) async {
    switch (type) {
      case ZegoInRoomMessageType.broadcastMessage:
        coreData.multiRoomBroadcastMessages
            .getRoom(targetRoomID)
            .messageList
            .removeWhere(
              (element) => element.messageID == message.messageID,
            );

        return sendBroadcastMessage(
          message.message,
          targetRoomID: targetRoomID,
        );
      case ZegoInRoomMessageType.barrageMessage:
        coreData.multiRoomBarrageMessages
            .getRoom(targetRoomID)
            .messageList
            .removeWhere(
              (element) => element.messageID == message.messageID,
            );

        return sendBarrageMessage(
          message.message,
          targetRoomID: targetRoomID,
        );
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

    _onIMRecvMessage(
      true,
      roomID,
      _messageList,
      coreData.multiRoomBroadcastMessages.getRoom(roomID),
    );
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

    _onIMRecvMessage(
      false,
      roomID,
      _messageList,
      coreData.multiRoomBarrageMessages.getRoom(roomID),
    );
  }

  void _onIMRecvMessage(
    bool localCache,
    String roomID,
    List<ZegoInRoomMessage> messageList,
    ZegoUIKitCoreDataRoomMessageInfo messageInfo,
  ) {
    debugPrint('on im recv message, '
        'room id:$roomID, '
        'use local cache:$localCache, '
        'message list:${messageList.map((e) => e.toString())}, ');

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
