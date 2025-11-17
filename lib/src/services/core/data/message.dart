// Project imports:
import 'package:zego_uikit/src/services/services.dart';
import 'message.room.dart';
import 'room_map.dart';

/// Messages for multiple rooms
/// @nodoc
class ZegoUIKitCoreDataMessage {
  var roomBroadcastMessages =
      ZegoUIKitCoreRoomMap<ZegoUIKitCoreDataRoomMessage>(
    name: 'core data broadcast message',
    createDefault: (String roomID) {
      final roomMessage = ZegoUIKitCoreDataRoomMessage(roomID);
      roomMessage.init();
      return roomMessage;
    },
    onUpgradeEmptyRoom:
        (ZegoUIKitCoreDataRoomMessage emptyRoomMessage, roomID) {
      // When prepared room is upgraded, update its roomID
      emptyRoomMessage.roomID = roomID;
      ZegoLoggerService.logInfo(
        'empty room(${emptyRoomMessage.hashCode}) has update id to $roomID, ',
        tag: 'uikit-room',
        subTag: 'room-map',
      );
    },
  );
  var roomBarrageMessages = ZegoUIKitCoreRoomMap<ZegoUIKitCoreDataRoomMessage>(
    name: 'core data barrage message',
    createDefault: (String roomID) {
      final roomMessage = ZegoUIKitCoreDataRoomMessage(roomID);
      roomMessage.init();
      return roomMessage;
    },
    onUpgradeEmptyRoom:
        (ZegoUIKitCoreDataRoomMessage emptyRoomMessage, roomID) {
      // When prepared room is upgraded, update its roomID
      emptyRoomMessage.roomID = roomID;
      ZegoLoggerService.logInfo(
        'empty room(${emptyRoomMessage.hashCode}) has update id to $roomID, ',
        tag: 'uikit-room',
        subTag: 'room-map',
      );
    },
  );

  void init() {
    ZegoLoggerService.logInfo(
      'init message',
      tag: 'uikit-messages',
      subTag: 'init',
    );

    roomBroadcastMessages.forEachSync((_, roomMessages) {
      roomMessages.init();
    });
    roomBarrageMessages.forEachSync((_, roomMessages) {
      roomMessages.init();
    });
  }

  void clear({
    required String targetRoomID,
  }) {
    clearBroadcast(targetRoomID: targetRoomID);
    clearBarrage(targetRoomID: targetRoomID);
  }

  void clearBroadcast({
    required String targetRoomID,
  }) {
    ZegoLoggerService.logInfo(
      'clear broadcast message, '
      'room id:$targetRoomID',
      tag: 'uikit-messages',
      subTag: 'uninit',
    );

    if (roomBroadcastMessages.containsRoom(targetRoomID)) {
      roomBroadcastMessages.getRoom(targetRoomID).clear();
    }
    roomBroadcastMessages.removeRoom(targetRoomID);
  }

  void clearBarrage({
    required String targetRoomID,
  }) {
    ZegoLoggerService.logInfo(
      'clear barrage message, '
      'room id:$targetRoomID',
      tag: 'uikit-messages',
      subTag: 'uninit',
    );

    if (roomBarrageMessages.containsRoom(targetRoomID)) {
      roomBarrageMessages.getRoom(targetRoomID).clear();
    }
    roomBarrageMessages.removeRoom(targetRoomID);
  }

  void uninit() {
    ZegoLoggerService.logInfo(
      'uninit message, '
      'room ids:${roomBroadcastMessages.allRoomIDs}',
      tag: 'uikit-messages',
      subTag: 'uninit',
    );

    roomBroadcastMessages.forEachSync((_, roomMessages) {
      roomMessages.uninit();
    });
    roomBroadcastMessages.clearRooms();

    roomBarrageMessages.forEachSync((_, roomMessages) {
      roomMessages.uninit();
    });
    roomBarrageMessages.clearRooms();
  }
}
