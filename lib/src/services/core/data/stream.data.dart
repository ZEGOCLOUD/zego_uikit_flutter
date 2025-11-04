// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/services/core/core.dart';
import 'package:zego_uikit/src/services/core/defines/defines.dart';
import 'package:zego_uikit/src/services/services.dart';

class ZegoUIKitCoreDataStreamData {
  String roomID;
  String userID;
  ZegoPlayerState playerState;
  ZegoPublisherState publisherState;

  ZegoUIKitCoreDataStreamData({
    required this.roomID,
    required this.userID,
    this.playerState = ZegoPlayerState.NoPlay,
    this.publisherState = ZegoPublisherState.NoPublish,
  });

  @override
  String toString() {
    return 'room id:$roomID, '
        'user id:$userID, '
        'player state:$playerState, '
        'publisher state:$publisherState';
  }
}
