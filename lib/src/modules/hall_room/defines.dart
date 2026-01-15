// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_uikit/src/services/services.dart';

/// stream information to pull
class ZegoUIKitHallRoomListStreamUser {
  ZegoUIKitUser user;
  String roomID;

  bool isPlayed = false;

  /// stream is playing or not
  bool isPlaying = false;

  ZegoStreamType streamType = ZegoStreamType.main;

  ZegoUIKitHallRoomListStreamUser({
    required this.user,
    required this.roomID,
    ZegoStreamType? streamType,
  }) : streamType = streamType ?? ZegoStreamType.main;

  void updateStreamType(ZegoStreamType streamType) {
    if (this.streamType == streamType) {
      return;
    }

    _getPlayerStateNotifier(
      roomID: roomID,
      userID: user.id,
    ).removeListener(_onPlayerStateUpdated);

    this.streamType = streamType;

    syncPlayingState();
  }

  void syncPlayingState({
    String? syncRoomID,
  }) {
    final playerState = _getPlayerStateNotifier(
      roomID: syncRoomID ?? roomID,
      userID: user.id,
    ).value;
    isPlayed = ZegoUIKitPlayerState.Playing == playerState;
    isPlaying = ZegoUIKitPlayerState.PlayRequesting == playerState ||
        ZegoUIKitPlayerState.Playing == playerState;

    _listenPlayingState(syncRoomID: syncRoomID);
  }

  ValueNotifier<ZegoUIKitPlayerState> _getPlayerStateNotifier({
    required String roomID,
    required String userID,
  }) {
    final targetUser = ZegoUIKit().getUser(
      userID,
      targetRoomID: roomID,
    );
    return streamType.channel == ZegoUIKitPublishChannel.Main
        ? targetUser.playerState
        : targetUser.auxPlayerState;
  }

  void _listenPlayingState({
    String? syncRoomID,
  }) {
    final playerStateNotifier = _getPlayerStateNotifier(
      roomID: syncRoomID ?? roomID,
      userID: user.id,
    );
    playerStateNotifier.removeListener(_onPlayerStateUpdated);
    playerStateNotifier.addListener(_onPlayerStateUpdated);
  }

  void _onPlayerStateUpdated() {
    syncPlayingState();
  }

  String get streamID {
    return generateStreamID(user.id, roomID, streamType);
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
        'isPlayed:$isPlayed, '
        'isPlaying:$isPlaying, '
        '}';
  }
}
