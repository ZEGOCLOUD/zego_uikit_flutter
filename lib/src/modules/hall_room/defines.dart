// Project imports:
import 'package:zego_uikit/src/services/services.dart';

/// stream information to pull
class ZegoUIKitHallRoomListStreamUser {
  ZegoUIKitUser user;
  String roomID;

  /// stream is playing or not
  bool isPlaying = false;

  ZegoUIKitHallRoomListStreamUser({
    required this.user,
    required this.roomID,
  });

  void syncPlayingState({
    String? syncRoomID,
  }) {
    final playerState = ZegoUIKit()
        .getUser(user.id, targetRoomID: syncRoomID ?? roomID)
        .playerState
        .value;
    isPlaying = ZegoUIKitPlayerState.Playing == playerState;
    _listenPlayingState(syncRoomID: syncRoomID);
  }

  void _listenPlayingState({
    String? syncRoomID,
  }) {
    ZegoUIKit()
        .getUser(user.id, targetRoomID: syncRoomID ?? roomID)
        .playerState
        .removeListener(_onPlayerStateUpdated);
    ZegoUIKit()
        .getUser(user.id, targetRoomID: syncRoomID ?? roomID)
        .playerState
        .addListener(_onPlayerStateUpdated);
  }

  void _onPlayerStateUpdated() {
    syncPlayingState();
  }

  String get streamID {
    return generateStreamID(user.id, roomID, ZegoStreamType.main);
  }

  bool get isEmpty => user.isEmpty() || roomID.isEmpty;

  bool get isNotEmpty => !isEmpty;

  static ZegoUIKitHallRoomListStreamUser empty() {
    return ZegoUIKitHallRoomListStreamUser(
      user: ZegoUIKitUser.empty(),
      roomID: '',
    );
  }

  @override
  bool operator ==(Object other) {
    /// Should not reach here, should use isEqual
    assert(false);
    return identical(this,
            other) || // First check if same reference (performance optimization)
        other
                is ZegoUIKitHallRoomListStreamUser && // Then check if type is consistent
            runtimeType ==
                other
                    .runtimeType && // Ensure runtime type is same (subclass scenario)
            roomID == other.roomID &&
            user.id == other.user.id;
  }

  bool isEqual(ZegoUIKitHallRoomListStreamUser other) =>
      roomID == other.roomID && user.id == other.user.id;

  @override
  String toString() {
    return '{'
        'room id:$roomID, '
        'user id:${user.id}, '
        'isPlaying:$isPlaying, '
        '}';
  }
}
