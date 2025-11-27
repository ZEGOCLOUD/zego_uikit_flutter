// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_uikit/src/modules/hall_room/controller.p.dart';
import 'package:zego_uikit/zego_uikit.dart';

class ZegoUIKitHallRoomListController {
  ZegoUIKitHallRoomListController() {}

  /// DO NOT CALL!!!
  /// Please do not call this. It is the internal logic.
  final private = ZegoUIKitHallRoomListControllerPrivate();

  ValueNotifier<bool> get sdkInitNotifier => private.sdkInitNotifier;

  ValueNotifier<bool> get roomLoginNotifier => private.roomLoginNotifier;

  String get roomID => private.roomID;

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
    private.streamsNotifier.value.clear();

    return true;
  }

  /// Restore from live room to hall
  ///
  /// Returns from a live room back to the hall room, restoring the hall room state.
  Future<void> moveStreamToHall({
    bool Function(String)? ignoreFilter,
  }) async {
    return private.moveStreamToHall(ignoreFilter: ignoreFilter);
  }
}
