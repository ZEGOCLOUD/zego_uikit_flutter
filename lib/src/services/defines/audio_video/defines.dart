import 'package:zego_uikit/src/services/defines/express.dart';

String get attributeKeyAvatar => 'avatar';

typedef PlayerStateUpdateCallback = void Function(
  ZegoUIKitPlayerState state,
  int errorCode,
  Map<String, dynamic> extendedData,
);

typedef PublisherStateUpdateCallback = void Function(
  ZegoUIKitPublisherState state,
  int errorCode,
  Map<String, dynamic> extendedData,
);
