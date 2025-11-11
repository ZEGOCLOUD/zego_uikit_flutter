// Dart imports:
import 'dart:async';

// Project imports:
import 'package:zego_uikit/src/services/services.dart';

import 'room_map.dart';

/// 单个房间的消息
class ZegoUIKitCoreDataRoomMessage {
  String roomID;
  ZegoUIKitCoreDataRoomMessage(this.roomID);

  int localMessageId = 0;
  List<ZegoInRoomMessage> messageList = []; // uid:user
  StreamController<List<ZegoInRoomMessage>>? streamControllerMessageList;
  StreamController<ZegoInRoomMessage>? streamControllerRemoteMessage;
  StreamController<ZegoInRoomMessage>? streamControllerLocalMessage;

  void init() {
    ZegoLoggerService.logInfo(
      'hash:$hashCode, '
      'room id:$roomID',
      tag: 'uikit-messages-room',
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
      'hash:$hashCode, '
      'room id:$roomID',
      tag: 'uikit-messages-room',
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
      'hash:$hashCode, '
      'room id:$roomID',
      tag: 'uikit-messages-room',
      subTag: 'clear',
    );

    messageList.clear();
    streamControllerMessageList?.add(List<ZegoInRoomMessage>.from(messageList));
  }
}
