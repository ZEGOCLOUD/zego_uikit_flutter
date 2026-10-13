part of 'uikit_service.dart';

mixin ZegoMessageService {
  /// send in-room message
  Future<bool> sendInRoomMessage(
    String message, {
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
  }) async {
    final resultErrorCode = type == ZegoInRoomMessageType.broadcastMessage
        ? await ZegoUIKitCore.shared.message.sendBroadcastMessage(message)
        : await ZegoUIKitCore.shared.message.sendBarrageMessage(message);

    if (ZegoUIKitErrorCode.success != resultErrorCode) {
      ZegoUIKitCore.shared.error.errorStreamCtrl?.add(
        ZegoUIKitError(
          code: ZegoUIKitErrorCode.messageSendError,
          message:
              'send in-room message error:$resultErrorCode, '
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
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
  }) async {
    final resultErrorCode = await ZegoUIKitCore.shared.message.resendMessage(
      message,
      type,
    );

    if (ZegoUIKitErrorCode.success != resultErrorCode) {
      ZegoUIKitCore.shared.error.errorStreamCtrl?.add(
        ZegoUIKitError(
          code: ZegoUIKitErrorCode.messageReSendError,
          message:
              'resend in-room message error:$resultErrorCode, '
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
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
  }) {
    return type == ZegoInRoomMessageType.broadcastMessage
        ? ZegoUIKitCore.shared.coreData.broadcastMessage.messageList
        : ZegoUIKitCore.shared.coreData.barrageMessage.messageList;
  }

  /// messages notifier
  Stream<List<ZegoInRoomMessage>> getInRoomMessageListStream({
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
  }) {
    return (type == ZegoInRoomMessageType.broadcastMessage
            ? ZegoUIKitCore
                  .shared
                  .coreData
                  .broadcastMessage
                  .streamControllerMessageList
                  ?.stream
            : ZegoUIKitCore
                  .shared
                  .coreData
                  .barrageMessage
                  .streamControllerMessageList
                  ?.stream) ??
        const Stream.empty();
  }

  /// latest message received notifier
  Stream<ZegoInRoomMessage> getInRoomMessageStream({
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
  }) {
    return (type == ZegoInRoomMessageType.broadcastMessage
            ? ZegoUIKitCore
                  .shared
                  .coreData
                  .broadcastMessage
                  .streamControllerRemoteMessage
                  ?.stream
            : ZegoUIKitCore
                  .shared
                  .coreData
                  .barrageMessage
                  .streamControllerRemoteMessage
                  ?.stream) ??
        const Stream.empty();
  }

  /// local message sent notifier
  Stream<ZegoInRoomMessage> getInRoomLocalMessageStream({
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
  }) {
    return (type == ZegoInRoomMessageType.broadcastMessage
            ? ZegoUIKitCore
                  .shared
                  .coreData
                  .broadcastMessage
                  .streamControllerLocalMessage
                  ?.stream
            : ZegoUIKitCore
                  .shared
                  .coreData
                  .barrageMessage
                  .streamControllerLocalMessage
                  ?.stream) ??
        const Stream.empty();
  }

  Future<bool> clearMessage({
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
    bool clearRemote = true,
  }) async {
    ZegoUIKitCore.shared.clearLocalMessage(type);

    if (clearRemote) {
      final resultErrorCode = await ZegoUIKitCore.shared.clearRemoteMessage(
        type,
      );

      if (ZegoUIKitErrorCode.success != resultErrorCode) {
        ZegoUIKitCore.shared.error.errorStreamCtrl?.add(
          ZegoUIKitError(
            code: ZegoUIKitErrorCode.customCommandSendError,
            message:
                'remove remote message error:$resultErrorCode, '
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
