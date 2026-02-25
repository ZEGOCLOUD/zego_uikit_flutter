// Project imports:
import 'package:zego_uikit/src/services/defines/express.dart';

/// Represents a device exception for local or remote devices.
///
/// This class encapsulates information about device exceptions
/// that occur during audio/video communication.
class ZegoUIKitDeviceException {
  /// The type of local device exception (if applicable).
  ZegoUIKitDeviceExceptionType? localDeviceExceptionType;

  /// The state of remote device (if applicable).
  ZegoUIKitRemoteDeviceState? remoteDeviceState;
}
