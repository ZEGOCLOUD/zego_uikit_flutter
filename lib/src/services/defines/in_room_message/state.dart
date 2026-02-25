/// in-room message send state
enum ZegoInRoomMessageState {
  /// Message is idle, not yet sent.
  idle,

  /// Message is currently being sent.
  sending,

  /// Message was sent successfully.
  success,

  /// Message sending failed.
  failed,
}
