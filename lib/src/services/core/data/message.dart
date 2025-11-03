// Dart imports:
import 'dart:async';

// Project imports:
import 'package:zego_uikit/src/services/services.dart';

mixin ZegoUIKitCoreDataMessage {
  var broadcastMessage = ZegoUIKitCoreDataMessageInfo();
  var barrageMessage = ZegoUIKitCoreDataMessageInfo();

  void initMessage() {
    ZegoLoggerService.logInfo(
      'init message',
      tag: 'uikit-message',
      subTag: 'init',
    );

    broadcastMessage.init();
    barrageMessage.init();
  }

  void uninitMessage() {
    ZegoLoggerService.logInfo(
      'uninit message',
      tag: 'uikit-message',
      subTag: 'uninit',
    );

    broadcastMessage.uninit();
    barrageMessage.uninit();
  }
}

class ZegoUIKitCoreDataMessageInfo {
  int localMessageId = 0;
  List<ZegoInRoomMessage> messageList = []; // uid:user
  StreamController<List<ZegoInRoomMessage>>? streamControllerMessageList;
  StreamController<ZegoInRoomMessage>? streamControllerRemoteMessage;
  StreamController<ZegoInRoomMessage>? streamControllerLocalMessage;

  void init() {
    streamControllerMessageList ??=
        StreamController<List<ZegoInRoomMessage>>.broadcast();
    streamControllerRemoteMessage ??=
        StreamController<ZegoInRoomMessage>.broadcast();
    streamControllerLocalMessage ??=
        StreamController<ZegoInRoomMessage>.broadcast();
  }

  void uninit() {
    streamControllerMessageList?.close();
    streamControllerMessageList = null;

    streamControllerRemoteMessage?.close();
    streamControllerRemoteMessage = null;

    streamControllerLocalMessage?.close();
    streamControllerLocalMessage = null;
  }

  void clear() {
    messageList.clear();
    streamControllerMessageList?.add(List<ZegoInRoomMessage>.from(messageList));
  }
}
