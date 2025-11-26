part of 'uikit_service.dart';

mixin ZegoMessageService {
  /// send in-room message
  Future<bool> sendInRoomMessage(
    String message, {
    required String targetRoomID,
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
  }) async {
    final resultErrorCode = type == ZegoInRoomMessageType.broadcastMessage
        ? await ZegoUIKitCore.shared.message.sendBroadcastMessage(
            targetRoomID: targetRoomID,
            message,
          )
        : await ZegoUIKitCore.shared.message.sendBarrageMessage(
            message,
            targetRoomID: targetRoomID,
          );

    if (ZegoUIKitErrorCode.success != resultErrorCode) {
      ZegoUIKitCore.shared.coreData.error.errorStreamCtrl?.add(
        ZegoUIKitError(
          code: ZegoUIKitErrorCode.messageSendError,
          message: 'send in-room message error, '
              'room id:$targetRoomID, '
              'code:$resultErrorCode, '
              'message:$message, '
              '${ZegoUIKitErrorCode.expressErrorCodeDocumentTips}',
          method: 'sendInRoomCommand',
        ),
      );
    }

    return ZegoErrorCode.CommonSuccess == resultErrorCode;
  }

  /// re-send in-room message
  Future<bool> resendInRoomMessage(
    ZegoInRoomMessage message, {
    required String targetRoomID,
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
  }) async {
    final resultErrorCode = await ZegoUIKitCore.shared.message.resendMessage(
      targetRoomID: targetRoomID,
      message,
      type,
    );

    if (ZegoUIKitErrorCode.success != resultErrorCode) {
      ZegoUIKitCore.shared.coreData.error.errorStreamCtrl?.add(
        ZegoUIKitError(
          code: ZegoUIKitErrorCode.messageReSendError,
          message: 'resend in-room message error,'
              'room id:$targetRoomID, '
              'code:$resultErrorCode, '
              'message:$message, '
              '${ZegoUIKitErrorCode.expressErrorCodeDocumentTips}',
          method: 'sendInRoomCommand',
        ),
      );
    }

    return ZegoErrorCode.CommonSuccess == resultErrorCode;
  }

  /// get history messages
  List<ZegoInRoomMessage> getInRoomMessages({
    required String targetRoomID,
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
  }) {
    return type == ZegoInRoomMessageType.broadcastMessage
        ? ZegoUIKitCore.shared.coreData.message.roomBroadcastMessages
            .getRoom(targetRoomID)
            .messageList
        : ZegoUIKitCore.shared.coreData.message.roomBarrageMessages
            .getRoom(targetRoomID)
            .messageList;
  }

  /// messages notifier
  Stream<List<ZegoInRoomMessage>> getInRoomMessageListStream({
    required String targetRoomID,
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
  }) {
    return (type == ZegoInRoomMessageType.broadcastMessage
            ? ZegoUIKitCore.shared.coreData.message.roomBroadcastMessages
                .getRoom(targetRoomID)
                .streamControllerMessageList
                ?.stream
            : ZegoUIKitCore.shared.coreData.message.roomBarrageMessages
                .getRoom(targetRoomID)
                .streamControllerMessageList
                ?.stream) ??
        const Stream.empty();
  }

  /// latest message received notifier
  Stream<ZegoInRoomMessage> getInRoomMessageStream({
    required String targetRoomID,
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
  }) {
    return (type == ZegoInRoomMessageType.broadcastMessage
            ? ZegoUIKitCore.shared.coreData.message.roomBroadcastMessages
                .getRoom(targetRoomID)
                .streamControllerRemoteMessage
                ?.stream
            : ZegoUIKitCore.shared.coreData.message.roomBarrageMessages
                .getRoom(targetRoomID)
                .streamControllerRemoteMessage
                ?.stream) ??
        const Stream.empty();
  }

  /// local message sent notifier
  Stream<ZegoInRoomMessage> getInRoomLocalMessageStream({
    required String targetRoomID,
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
  }) {
    return (type == ZegoInRoomMessageType.broadcastMessage
            ? ZegoUIKitCore.shared.coreData.message.roomBroadcastMessages
                .getRoom(targetRoomID)
                .streamControllerLocalMessage
                ?.stream
            : ZegoUIKitCore.shared.coreData.message.roomBarrageMessages
                .getRoom(targetRoomID)
                .streamControllerLocalMessage
                ?.stream) ??
        const Stream.empty();
  }

  Future<bool> clearMessage({
    required String targetRoomID,
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
    bool clearRemote = true,
  }) async {
    ZegoUIKitCore.shared.clearLocalMessage(
      type,
      targetRoomID: targetRoomID,
    );

    if (clearRemote) {
      final resultErrorCode = await ZegoUIKitCore.shared.clearRemoteMessage(
        type,
        targetRoomID: targetRoomID,
      );

      if (ZegoUIKitErrorCode.success != resultErrorCode) {
        ZegoUIKitCore.shared.coreData.error.errorStreamCtrl?.add(
          ZegoUIKitError(
            code: ZegoUIKitErrorCode.customCommandSendError,
            message: 'remove remote message error:$resultErrorCode, '
                '${ZegoUIKitErrorCode.expressErrorCodeDocumentTips}',
            method: 'clearMessage',
          ),
        );
      }

      return ZegoErrorCode.CommonSuccess == resultErrorCode;
    }

    return true;
  }
}
