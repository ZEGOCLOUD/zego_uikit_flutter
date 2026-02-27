// Project imports:
import 'stream_type.dart';

/// Internal SEI (Supplemental Enhancement Information) types.
enum ZegoUIKitInnerSEIType {
  /// Mixer device state.
  mixerDeviceState,

  /// Media sync information.
  mediaSyncInfo,

  /// Custom SEI data.
  custom,
}

/// receive SEI from remote
class ZegoUIKitReceiveSEIEvent {
  /// The type identifier of the SEI data.
  final String typeIdentifier;

  /// The user ID who sent the SEI.
  final String senderID;

  /// The SEI data content.
  final Map<String, dynamic> sei;

  /// The stream ID.
  final String streamID;

  /// The stream type.
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
    return '{'
        'streamID:$streamID, '
        'streamType:$streamType, '
        'senderID:$senderID, '
        'typeIdentifier:$typeIdentifier, '
        'sei:$sei, '
        '}';
  }
}
