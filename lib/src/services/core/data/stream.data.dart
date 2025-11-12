// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/services/core/core.dart';
import 'package:zego_uikit/src/services/core/defines/defines.dart';
import 'package:zego_uikit/src/services/services.dart';

class ZegoUIKitCoreDataStreamData {
  String roomID;
  String userID;
  String userName;
  ZegoPlayerState playerState;
  ZegoPublisherState publisherState;
  bool isAnotherRoomUser;

  ZegoUIKitCoreDataStreamData({
    required this.roomID,
    required this.userID,
    required this.userName,
    this.isAnotherRoomUser = false,
    this.playerState = ZegoPlayerState.NoPlay,
    this.publisherState = ZegoPublisherState.NoPublish,
  });

  @override
  String toString() {
    return 'room id:$roomID, '
        'user id:$userID, '
        'user name:$userName, '
        'isAnotherRoomUser:$isAnotherRoomUser, '
        'player state:$playerState, '
        'publisher state:$publisherState';
  }
}
