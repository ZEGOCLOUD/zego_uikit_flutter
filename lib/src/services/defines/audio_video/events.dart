class ZegoUIKitReceiveTurnOnLocalMicrophoneEvent {
  final String fromUserID;
  final bool muteMode;

  ZegoUIKitReceiveTurnOnLocalMicrophoneEvent(this.fromUserID, this.muteMode);

  @override
  String toString() {
    return 'from user id:$fromUserID, mute mode:$muteMode';
  }
}
