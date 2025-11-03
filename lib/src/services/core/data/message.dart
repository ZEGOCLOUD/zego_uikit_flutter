// Dart imports:
import 'dart:async';

// Project imports:
import 'package:zego_uikit/src/services/services.dart';

import 'package:zego_uikit/src/services/core/data/room_map.dart';

mixin ZegoUIKitCoreDataMessage {
  var multiRoomBroadcastMessages =
      ZegoUIKitCoreRoomMap<ZegoUIKitCoreDataRoomMessageInfo>((String roomID) {
    return ZegoUIKitCoreDataRoomMessageInfo(roomID);
  });
  var multiRoomBarrageMessages =
      ZegoUIKitCoreRoomMap<ZegoUIKitCoreDataRoomMessageInfo>((String roomID) {
    return ZegoUIKitCoreDataRoomMessageInfo(roomID);
  });

  void initMessage() {
    ZegoLoggerService.logInfo(
      'init message',
      tag: 'uikit-message',
      subTag: 'init',
    );

    multiRoomBroadcastMessages.forEach((_, roomMessages) {
      roomMessages.init();
    });
    multiRoomBarrageMessages.forEach((_, roomMessages) {
      roomMessages.init();
    });
  }

  void clearMessage({
    String? targetRoomID,
  }) {
    clearBroadcastMessage(targetRoomID: targetRoomID);
    clearBarrageMessage(targetRoomID: targetRoomID);
  }

  void clearBroadcastMessage({
    String? targetRoomID,
  }) {
    ZegoLoggerService.logInfo(
      'clear broadcast message, '
      'room id:$targetRoomID',
      tag: 'uikit-message',
      subTag: 'uninit',
    );

    multiRoomBroadcastMessages.forEach((roomID, roomMessages) {
      if (targetRoomID == null || targetRoomID == roomID) {
        roomMessages.clear();
      }
    });
    multiRoomBroadcastMessages.removeRoom(targetRoomID ?? '');
  }

  void clearBarrageMessage({
    String? targetRoomID,
  }) {
    ZegoLoggerService.logInfo(
      'clear barrage message, '
      'room id:$targetRoomID',
      tag: 'uikit-message',
      subTag: 'uninit',
    );

    multiRoomBarrageMessages.forEach((roomID, roomMessages) {
      if (targetRoomID == null || targetRoomID == roomID) {
        roomMessages.clear();
      }
    });
    multiRoomBarrageMessages.removeRoom(targetRoomID ?? '');
  }

  void uninitMessage() {
    ZegoLoggerService.logInfo(
      'uninit message, '
      'room ids:${multiRoomBroadcastMessages.allRoomIDs}',
      tag: 'uikit-message',
      subTag: 'uninit',
    );

    multiRoomBroadcastMessages.forEach((_, roomMessages) {
      roomMessages.uninit();
    });
    multiRoomBroadcastMessages.clearRooms();

    multiRoomBarrageMessages.forEach((_, roomMessages) {
      roomMessages.uninit();
    });
    multiRoomBarrageMessages.clearRooms();
  }
}

class ZegoUIKitCoreDataRoomMessageInfo {
  String roomID;
  ZegoUIKitCoreDataRoomMessageInfo(this.roomID);

  int localMessageId = 0;
  List<ZegoInRoomMessage> messageList = []; // uid:user
  StreamController<List<ZegoInRoomMessage>>? streamControllerMessageList;
  StreamController<ZegoInRoomMessage>? streamControllerRemoteMessage;
  StreamController<ZegoInRoomMessage>? streamControllerLocalMessage;

  void init() {
    ZegoLoggerService.logInfo(
      'room id:$roomID',
      tag: 'uikit-room-message-info',
      subTag: 'init',
    );

    streamControllerMessageList ??=
        StreamController<List<ZegoInRoomMessage>>.broadcast();
    streamControllerRemoteMessage ??=
        StreamController<ZegoInRoomMessage>.broadcast();
    streamControllerLocalMessage ??=
        StreamController<ZegoInRoomMessage>.broadcast();
  }

  void uninit() {
    ZegoLoggerService.logInfo(
      'room id:$roomID',
      tag: 'uikit-room-message-info',
      subTag: 'uninit',
    );

    streamControllerMessageList?.close();
    streamControllerMessageList = null;

    streamControllerRemoteMessage?.close();
    streamControllerRemoteMessage = null;

    streamControllerLocalMessage?.close();
    streamControllerLocalMessage = null;
  }

  void clear() {
    ZegoLoggerService.logInfo(
      'room id:$roomID',
      tag: 'uikit-room-message-info',
      subTag: 'clear',
    );

    messageList.clear();
    streamControllerMessageList?.add(List<ZegoInRoomMessage>.from(messageList));
  }
}
