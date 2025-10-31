// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/modules/outside_room_audio_video/internal.dart';
import 'package:zego_uikit/zego_uikit.dart';

class ZegoOutsideRoomAudioVideoViewExpressEvent
    extends ZegoUIKitExpressEventInterface {
  ValueNotifier<List<ZegoOutsideRoomAudioVideoViewStream>>? _streamsNotifier;
  void init({
    required ValueNotifier<List<ZegoOutsideRoomAudioVideoViewStream>>
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
        .indexWhere((streamInfo) => streamInfo.targetStreamID == streamID);
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
          return e.roomID == roomID && e.user.id == stream.user.userID;
        });
      }
    }
  }
}
