part of 'uikit_service.dart';

mixin ZegoMessageService {
  /// send in-room message
  Future<bool> sendInRoomMessage(
    String message, {
    String? targetRoomID,
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
  }) async {
    final resultErrorCode = type == ZegoInRoomMessageType.broadcastMessage
        ? await ZegoUIKitCore.shared.message.sendBroadcastMessage(
            targetRoomID:
                targetRoomID ?? ZegoUIKitCore.shared.coreData.currentRoomId,
            message,
          )
        : await ZegoUIKitCore.shared.message.sendBarrageMessage(
            message,
            targetRoomID:
                targetRoomID ?? ZegoUIKitCore.shared.coreData.currentRoomId,
          );

    if (ZegoUIKitErrorCode.success != resultErrorCode) {
      ZegoUIKitCore.shared.error.errorStreamCtrl?.add(
        ZegoUIKitError(
          code: ZegoUIKitErrorCode.messageSendError,
          message: 'send in-room message error, '
              'room id:${targetRoomID ?? ZegoUIKitCore.shared.coreData.currentRoomId}, '
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
    String? targetRoomID,
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
  }) async {
    final resultErrorCode = await ZegoUIKitCore.shared.message.resendMessage(
      targetRoomID: targetRoomID ?? ZegoUIKitCore.shared.coreData.currentRoomId,
      message,
      type,
    );

    if (ZegoUIKitErrorCode.success != resultErrorCode) {
      ZegoUIKitCore.shared.error.errorStreamCtrl?.add(
        ZegoUIKitError(
          code: ZegoUIKitErrorCode.messageReSendError,
          message: 'resend in-room message error,'
              'room id:${targetRoomID ?? ZegoUIKitCore.shared.coreData.currentRoomId}, '
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
    String? targetRoomID,
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
  }) {
    return type == ZegoInRoomMessageType.broadcastMessage
        ? ZegoUIKitCore.shared.coreData.multiRoomBroadcastMessages
            .getRoom(
                targetRoomID ?? ZegoUIKitCore.shared.coreData.currentRoomId)
            .messageList
        : ZegoUIKitCore.shared.coreData.multiRoomBarrageMessages
            .getRoom(
                targetRoomID ?? ZegoUIKitCore.shared.coreData.currentRoomId)
            .messageList;
  }

  /// messages notifier
  Stream<List<ZegoInRoomMessage>> getInRoomMessageListStream({
    String? targetRoomID,
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
  }) {
    return (type == ZegoInRoomMessageType.broadcastMessage
            ? ZegoUIKitCore.shared.coreData.multiRoomBroadcastMessages
                .getRoom(
                    targetRoomID ?? ZegoUIKitCore.shared.coreData.currentRoomId)
                .streamControllerMessageList
                ?.stream
            : ZegoUIKitCore.shared.coreData.multiRoomBarrageMessages
                .getRoom(
                    targetRoomID ?? ZegoUIKitCore.shared.coreData.currentRoomId)
                .streamControllerMessageList
                ?.stream) ??
        const Stream.empty();
  }

  /// latest message received notifier
  Stream<ZegoInRoomMessage> getInRoomMessageStream({
    String? targetRoomID,
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
  }) {
    return (type == ZegoInRoomMessageType.broadcastMessage
            ? ZegoUIKitCore.shared.coreData.multiRoomBroadcastMessages
                .getRoom(
                    targetRoomID ?? ZegoUIKitCore.shared.coreData.currentRoomId)
                .streamControllerRemoteMessage
                ?.stream
            : ZegoUIKitCore.shared.coreData.multiRoomBarrageMessages
                .getRoom(
                    targetRoomID ?? ZegoUIKitCore.shared.coreData.currentRoomId)
                .streamControllerRemoteMessage
                ?.stream) ??
        const Stream.empty();
  }

  /// local message sent notifier
  Stream<ZegoInRoomMessage> getInRoomLocalMessageStream({
    String? targetRoomID,
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
  }) {
    return (type == ZegoInRoomMessageType.broadcastMessage
            ? ZegoUIKitCore.shared.coreData.multiRoomBroadcastMessages
                .getRoom(
                    targetRoomID ?? ZegoUIKitCore.shared.coreData.currentRoomId)
                .streamControllerLocalMessage
                ?.stream
            : ZegoUIKitCore.shared.coreData.multiRoomBarrageMessages
                .getRoom(
                    targetRoomID ?? ZegoUIKitCore.shared.coreData.currentRoomId)
                .streamControllerLocalMessage
                ?.stream) ??
        const Stream.empty();
  }

  Future<bool> clearMessage({
    String? targetRoomID,
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
    bool clearRemote = true,
  }) async {
    ZegoUIKitCore.shared.clearLocalMessage(
      type,
      targetRoomID: targetRoomID ?? ZegoUIKitCore.shared.coreData.currentRoomId,
    );

    if (clearRemote) {
      final resultErrorCode = await ZegoUIKitCore.shared.clearRemoteMessage(
        type,
        targetRoomID:
            targetRoomID ?? ZegoUIKitCore.shared.coreData.currentRoomId,
      );

      if (ZegoUIKitErrorCode.success != resultErrorCode) {
        ZegoUIKitCore.shared.error.errorStreamCtrl?.add(
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
