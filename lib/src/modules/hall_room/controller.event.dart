// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/zego_uikit.dart';

/// Live hall stream event listener
/// 1. Update stream status and delete streams through stream events
class ZegoUIKitHallRoomExpressEvent extends ZegoUIKitExpressEventInterface {
  ValueNotifier<List<ZegoUIKitHallRoomListStreamUser>>? _streamsNotifier;
  void init({
    required ValueNotifier<List<ZegoUIKitHallRoomListStreamUser>>
        streamsNotifier,
  }) {
    _streamsNotifier = streamsNotifier;
  }

  void uninit() {}

  @override
  void onPlayerStateUpdate(
    String streamID,
    ZegoPlayerState state,
    int errorCode,
    Map<String, dynamic> extendedData,
  ) {
    final queryIndex = (_streamsNotifier?.value ?? [])
        .indexWhere((streamInfo) => streamInfo.streamID == streamID);
    if (-1 == queryIndex) {
      return;
    }

    _streamsNotifier?.value[queryIndex].isPlaying =
        ZegoPlayerState.Playing == state;
  }

  @override
  Future<void> onRoomStreamUpdate(
    String roomID,
    ZegoUpdateType updateType,
    List<ZegoStream> streamList,
    Map<String, dynamic> extendedData,
  ) async {
    if (updateType == ZegoUpdateType.Delete) {
      for (var stream in streamList) {
        _streamsNotifier?.value.removeWhere((e) {
          /// Don't compare room id, stream may have been pulled from another room but transferred to current room
          return e.streamID == stream.streamID &&
              e.user.id == stream.user.userID;
        });
      }
    }
  }
}
