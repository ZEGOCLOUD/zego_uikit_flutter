/// Event data for receiving local microphone turn-on command from another user.
///
/// This event is triggered when the local user receives a command to turn on their microphone
/// from another user in the room.
class ZegoUIKitReceiveTurnOnLocalMicrophoneEvent {
  /// The user ID who sent the command.
  final String fromUserID;

  /// Whether the command was sent in mute mode.
  final bool muteMode;

  ZegoUIKitReceiveTurnOnLocalMicrophoneEvent(this.fromUserID, this.muteMode);

  @override
  String toString() {
    return '{'
        'from user id:$fromUserID, '
        'mute mode:$muteMode, '
        '}';
  }
}
