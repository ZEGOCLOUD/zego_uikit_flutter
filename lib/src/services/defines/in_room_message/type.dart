enum ZegoInRoomMessageType {
  /// Messages are guaranteed to be reliable
  /// 10 times/second for room
  /// The room is not supported when the number of online people exceeds 500
  broadcastMessage,

  /// Messages are not guaranteed to be reliable
  /// 20 times/second for room
  barrageMessage
}
