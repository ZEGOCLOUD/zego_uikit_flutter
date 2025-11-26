// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_uikit/src/modules/hall_room/controller.p.dart';
import 'package:zego_uikit/zego_uikit.dart';
import '../../services/core/core.dart';

class ZegoUIKitHallRoomListController {
  ZegoUIKitHallRoomListController();

  /// DO NOT CALL!!!
  /// Please do not call this. It is the internal logic.
  final private = ZegoUIKitHallRoomListControllerPrivate();

  ValueNotifier<bool> get sdkInitNotifier => private.sdkInitNotifier;
  ValueNotifier<bool> get roomLoginNotifier => private.roomLoginNotifier;
  String get roomID => private.roomID;
  ZegoUIKitUser get localUser => private.localUser;

  /// Switches from the hall room to a specific live room. Before switching,
  /// it copies all hosts from the hall room to their respective live rooms.
  Future<bool> moveStreamToTheirRoom() async {
    ZegoLoggerService.logInfo(
      'streams:${private.streamsNotifier.value}',
      tag: 'uikit.hall-room-controller',
      subTag: 'copyStreamToTheirRoom',
    );

    /// Copy hosts from hall room to their respective live rooms
    for (var stream in private.streamsNotifier.value) {
      ZegoUIKit().moveToAnotherRoom(
        fromRoomID: roomID,
        fromStreamIDs: [stream.streamID],
        toRoomID: stream.roomID,

        /// Copy back to own room, not belonging to another
        isFromAnotherRoom: false,
      );
    }

    return true;
  }

  /// Restore from live room to hall
  ///
  /// Returns from a live room back to the hall room, restoring the hall room state.
  Future<void> moveStreamToHall({
    bool Function(String)? ignoreFilter,
  }) async {
    ZegoLoggerService.logInfo(
      'streams:${private.streamsNotifier.value}',
      tag: 'uikit.hall-room-controller',
      subTag: 'restoreFromLive',
    );

    /// Copy all currently existing live room hosts back to the hall room
    ZegoUIKitCore.shared.coreData.stream.roomStreams
        .forEachSync((anotherRoomID, anotherRoomStream) {
      if (anotherRoomID == roomID) {
        return;
      }

      final streamIDs = [
        ...anotherRoomStream.streamDicNotifier.value.keys,
        ...anotherRoomStream.mixerStreamDic.keys,
      ]..removeWhere((e) => ignoreFilter?.call(e) ?? false);

      ZegoUIKit().moveToAnotherRoom(
        fromRoomID: anotherRoomID,
        fromStreamIDs: streamIDs,
        toRoomID: roomID,

        /// Nominally becomes hall's own
        isFromAnotherRoom: false,
      );
    });
  }
}
