// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

class ZegoUIKitError {
  int code;
  String message;
  String method;

  ZegoUIKitError({
    required this.code,
    required this.message,
    required this.method,
  });

  @override
  String toString() {
    return '{uikit error, code:$code, message:$message, method:$method}';
  }
}

/// uikit-${library_type}-${error_type}-${error_code}
/// 3-xx-xxx-xxx
///
/// library_type: {
///   00:uikit;
///
///   01:signaling plugin;
///   02:adapter plugin;
///   03:beauty plugin;
///
///   10:call prebuilt;
///   11:live audio room prebuilt;
///   12:live streaming prebuilt;
///   13:video conference prebuilt;
///   14:zim-kit;
/// }
///
/// --------------------------------
/// 3-00-xxx-xxx
///
/// error type: {
///   internal(001): 300001-xxx
///   audio video(002): 300002-xxx
///   custom command(003): 300003-xxx
///   device(004): 300004-xxx
///   effect(005): 300005-xxx
///   media(006): 300006-xxx
///   message(007): 300007-xxx
///   room(008): 300008-xxx
///   user(009): 300009-xxx
///   screen capture(010): 300010-xxx
/// }
class ZegoUIKitErrorCode {
  /// Execution successful.
  static const int success = 0;

  ///
  static const int paramsInvalid = -1;

  ///
  static const int coreNotInit = 300001001;

  ///
  static const int roomNotLogin = 300001002;

  ///
  static const int roomLoginError = 300001003;

  ///
  static const int roomLeaveError = 300001004;

  ///
  static const int customCommandSendError = 300003001;

  /// media play error
  static const int mediaPlayError = 300006001;

  /// media seek error
  static const int mediaSeekError = 300006002;

  /// pick media file error
  static const int mediaPickFilesError = 300006003;

  ///
  static const int messageSendError = 300007001;

  ///
  static const int messageReSendError = 300007002;

  /// Unknown video capture exception type.
  static const int screenCaptureExceptionUnknown = 300010001;

  /// The video capture system version does not support it, and Android only supports 5.0 and above.
  static const int screenCaptureExceptionVideoNotSupported = 300010002;

  /// The capture target fails, such as the monitor is unplugged and the window is closed.
  static const int screenCaptureExceptionAudioNotSupported = 300010003;

  /// Audio recording object creation failed. Possible reasons: 1. The audio recording permission is not enabled; 2. The allocated memory for audio recording is insufficient; 3. The creation of AudioRecord fails.
  static const int screenCaptureExceptionAudioCreateFailed = 300010004;

  /// MediaProjection request for dynamic permissions was denied.
  static const int screenCaptureExceptionMediaProjectionPermissionDenied =
      300010005;

  /// Capture is not started. Need to start capturing with [startScreenCapture] first.
  static const int screenCaptureExceptionNotStartCapture = 300010006;

  /// Screen capture has already started, repeated calls failed. You need to stop the capture with [stopScreenCapture] first.
  static const int screenCaptureExceptionAlreadyStarted = 300010007;

  /// Failed to start the foreground service.
  static const int screenCaptureExceptionForegroundServiceFailed = 300010008;

  /// Before starting screen capture, you need to call [setVideoSource], [setAudioSource] to specify the video and audio source `ScreenCapture`.
  static const int screenCaptureExceptionSourceNotSpecified = 300010009;

  /// System error exception. For example, low memory, etc.
  static const int screenCaptureExceptionSystemError = 300010010;

  /// Exception interrupted. For example, the user clicks the stop button in the control center during the capture process.
  static const int screenCaptureExceptionInterrupted = 300010011;

  /// Audio device exception. You need to restart the capture.
  static const int screenCaptureExceptionAudioDeviceException = 300010012;

  static int fromZegoScreenCaptureExceptionType(
    ZegoScreenCaptureExceptionType exceptionType,
  ) {
    switch (exceptionType) {
      case ZegoScreenCaptureExceptionType.Unknown:
        return screenCaptureExceptionUnknown;
      case ZegoScreenCaptureExceptionType.VideoNotSupported:
        return screenCaptureExceptionVideoNotSupported;
      case ZegoScreenCaptureExceptionType.AudioNotSupported:
        return screenCaptureExceptionAudioNotSupported;
      case ZegoScreenCaptureExceptionType.AudioCreateFailed:
        return screenCaptureExceptionAudioCreateFailed;
      case ZegoScreenCaptureExceptionType.MediaProjectionPermissionDenied:
        return screenCaptureExceptionMediaProjectionPermissionDenied;
      case ZegoScreenCaptureExceptionType.NotStartCapture:
        return screenCaptureExceptionNotStartCapture;
      case ZegoScreenCaptureExceptionType.AlreadyStarted:
        return screenCaptureExceptionAlreadyStarted;
      case ZegoScreenCaptureExceptionType.ForegroundServiceFailed:
        return screenCaptureExceptionForegroundServiceFailed;
      case ZegoScreenCaptureExceptionType.SourceNotSpecified:
        return screenCaptureExceptionSourceNotSpecified;
      case ZegoScreenCaptureExceptionType.SystemError:
        return screenCaptureExceptionSystemError;
      case ZegoScreenCaptureExceptionType.ExceptionInterrupted:
        return screenCaptureExceptionInterrupted;
      case ZegoScreenCaptureExceptionType.AudioDeviceException:
        return screenCaptureExceptionAudioDeviceException;
    }
  }

  static String expressErrorCodeDocumentTips =
      'please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.';
}
