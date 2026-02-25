/// media play result
class ZegoUIKitMediaPlayResult {
  /// Error code of the media play operation.
  int errorCode;

  /// Error message if any.
  String message;

  ZegoUIKitMediaPlayResult({
    required this.errorCode,
    this.message = '',
  });
}

/// seek result of media
class ZegoUIKitMediaSeekToResult {
  /// Error code of the seek operation.
  int errorCode;

  /// Error message if any.
  String message;

  ZegoUIKitMediaSeekToResult({
    required this.errorCode,
    this.message = '',
  });
}
