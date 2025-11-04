// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'stream_type.dart';

enum ZegoUIKitInnerSEIType {
  mixerDeviceState,
  mediaSyncInfo,
  custom,
}

/// receive SEI from remote
class ZegoUIKitReceiveSEIEvent {
  final String typeIdentifier;

  final String senderID;
  final Map<String, dynamic> sei;

  final String streamID;
  final ZegoStreamType streamType;

  ZegoUIKitReceiveSEIEvent({
    required this.streamID,
    required this.typeIdentifier,
    required this.senderID,
    required this.sei,
    required this.streamType,
  });

  @override
  String toString() {
    return 'ZegoUIKitReceiveSEIEvent{'
        'streamID:$streamID, '
        'streamType:$streamType, '
        'senderID:$senderID, '
        'typeIdentifier:$typeIdentifier, '
        'sei:$sei, '
        '}';
  }
}
