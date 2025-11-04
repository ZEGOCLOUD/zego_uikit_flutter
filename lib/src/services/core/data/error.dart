// Dart imports:
import 'dart:async';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/services/services.dart';

class ZegoUIKitCoreDataError extends ZegoUIKitExpressEventInterface {
  StreamController<ZegoUIKitError>? get errorStreamCtrl {
    _errorStreamCtrl ??= StreamController<ZegoUIKitError>.broadcast();

    return _errorStreamCtrl;
  }

  StreamController<ZegoUIKitError>? _errorStreamCtrl;

  void init() {
    ZegoLoggerService.logInfo(
      'init error module',
      subTag: 'core data',
    );

    _errorStreamCtrl ??= StreamController<ZegoUIKitError>.broadcast();
  }

  void uninit() {
    ZegoLoggerService.logInfo(
      'uninit error module',
      subTag: 'core data',
    );

    _errorStreamCtrl?.close();
    _errorStreamCtrl = null;
  }

  @override
  void onDebugError(int errorCode, String funcName, String info) {
    _errorStreamCtrl?.add(
      ZegoUIKitError(
        code: errorCode,
        message: info,
        method: 'express-debug:$funcName',
      ),
    );
  }

  @override
  void onFatalError(int errorCode) {
    _errorStreamCtrl?.add(
      ZegoUIKitError(
        code: errorCode,
        message: '',
        method: 'express-fatal',
      ),
    );
  }

  @override
  void onApiCalledResult(int errorCode, String funcName, String info) {
    if (ZegoErrorCode.CommonSuccess != errorCode) {
      _errorStreamCtrl?.add(
        ZegoUIKitError(
          code: errorCode,
          message: info,
          method: 'express-api:$funcName',
        ),
      );
    }
  }

  @override
  void onMobileScreenCaptureExceptionOccurred(
    ZegoScreenCaptureExceptionType exceptionType,
  ) {
    _errorStreamCtrl?.add(
      ZegoUIKitError(
        code: ZegoUIKitErrorCode.fromZegoScreenCaptureExceptionType(
          exceptionType,
        ),
        message: exceptionType.name,
        method: 'express-onMobileScreenCaptureExceptionOccurred',
      ),
    );
  }
}
