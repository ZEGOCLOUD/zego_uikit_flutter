part of 'uikit_service.dart';

mixin ZegoCustomCommandService {
  /// [toUserIDs] send to everyone if empty
  Future<bool> sendInRoomCommand(
    String command,
    List<String> toUserIDs, {
    required String targetRoomID,
  }) async {
    final resultErrorCode = await ZegoUIKitCore.shared.sendInRoomCommand(
      command,
      toUserIDs,
      targetRoomID: targetRoomID,
    );

    if (ZegoUIKitErrorCode.success != resultErrorCode) {
      ZegoUIKitCore.shared.coreData.error.errorStreamCtrl?.add(
        ZegoUIKitError(
          code: ZegoUIKitErrorCode.customCommandSendError,
          message: 'send in-room command error:$resultErrorCode, '
              'command:$command, to user ids:$toUserIDs, '
              '${ZegoUIKitErrorCode.expressErrorCodeDocumentTips}',
          method: 'sendInRoomCommand',
        ),
      );
    }

    return ZegoErrorCode.CommonSuccess == resultErrorCode;
  }

  /// get in-room command received notifier
  Stream<ZegoInRoomCommandReceivedData> getInRoomCommandReceivedStream() {
    return ZegoUIKitCore
            .shared.coreData.customCommandReceivedStreamCtrl?.stream ??
        const Stream.empty();
  }
}
