/// media play result
class ZegoUIKitMediaPlayResult {
  int errorCode;
  String message;

  ZegoUIKitMediaPlayResult({
    required this.errorCode,
    this.message = '',
  });
}

/// seek result of media
class ZegoUIKitMediaSeekToResult {
  int errorCode;
  String message;

  ZegoUIKitMediaSeekToResult({
    required this.errorCode,
    this.message = '',
  });
}
