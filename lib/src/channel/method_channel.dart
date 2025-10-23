// Dart imports:
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:zego_uikit/src/channel/platform_interface.dart';
import 'package:zego_uikit/src/services/services.dart';

/// @nodoc
/// An implementation of [ZegoUIKitPluginPlatform] that uses method channels.
class MethodChannelZegoUIKitPlugin extends ZegoUIKitPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('zego_uikit_plugin');

  /// backToDesktop
  @override
  Future<void> backToDesktop({
    bool nonRoot = false,
  }) async {
    if (Platform.isAndroid) {
      ZegoLoggerService.logInfo(
        'nonRoot:$nonRoot',
        tag: 'uikit-channel',
        subTag: 'backToDesktop',
      );

      try {
        await methodChannel.invokeMethod<String>('backToDesktop', {
          'nonRoot': nonRoot,
        });
      } on PlatformException catch (e) {
        ZegoLoggerService.logError(
          'Failed to back to desktop: $e.',
          tag: 'uikit-channel',
          subTag: 'backToDesktop',
        );
      }
    } else {
      try {
        await methodChannel.invokeMethod<bool?>('minimizeApp') ?? false;
      } on PlatformException catch (e) {
        ZegoLoggerService.logError(
          'Failed: $e.',
          tag: 'uikit-channel',
          subTag: 'backToDesktop',
        );
      }
    }
  }

  @override
  Future<bool> isLockScreen() async {
    if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'not support in iOS',
        tag: 'uikit-channel',
        subTag: 'isLockScreen',
      );
      return false;
    }

    var isLock = false;
    try {
      isLock = await methodChannel.invokeMethod<bool?>('isLockScreen') ?? false;
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to check isLock: $e.',
        tag: 'uikit-channel',
        subTag: 'isLockScreen',
      );
    }

    return isLock;
  }

  /// check app running
  /// only support android
  @override
  Future<bool> checkAppRunning() async {
    if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'not support in iOS',
        tag: 'uikit-channel',
        subTag: 'checkAppRunning',
      );

      return false;
    }

    ZegoLoggerService.logInfo(
      'checkAppRunning',
      tag: 'uikit-channel',
      subTag: 'checkAppRunning',
    );

    var isAppRunning = false;
    try {
      isAppRunning =
          await methodChannel.invokeMethod<bool?>('checkAppRunning') ?? false;
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to check app running: $e.',
        tag: 'uikit-channel',
        subTag: 'checkAppRunning',
      );
    }

    return isAppRunning;
  }

  /// active app to foreground
  /// only support android
  @override
  Future<void> activeAppToForeground() async {
    if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'not support in iOS',
        tag: 'uikit-channel',
        subTag: 'activeAppToForeground',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'activeAppToForeground',
      tag: 'uikit-channel',
      subTag: 'activeAppToForeground',
    );

    try {
      await methodChannel.invokeMethod('activeAppToForeground', {});
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to active app to foreground: $e.',
        tag: 'uikit-channel',
        subTag: 'activeAppToForeground',
      );
    }
  }

  /// request dismiss keyguard
  /// only support android
  @override
  Future<void> requestDismissKeyguard() async {
    if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'not support in iOS',
        tag: 'uikit-channel',
        subTag: 'requestDismissKeyguard',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'requestDismissKeyguard',
      tag: 'uikit-channel',
      subTag: 'requestDismissKeyguard',
    );

    try {
      await methodChannel.invokeMethod('requestDismissKeyguard', {});
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to request dismiss keyguard: $e.',
        tag: 'uikit-channel',
        subTag: 'requestDismissKeyguard',
      );
    }
  }

  /// only support iOS
  @override
  Future<bool> stopIOSPIP() async {
    if (Platform.isAndroid) {
      ZegoLoggerService.logInfo(
        'not support in Android',
        tag: 'uikit-channel',
        subTag: 'stopIOSPIP',
      );

      return false;
    }

    final systemVersion = ZegoUIKit().getMobileSystemVersion();
    if (systemVersion.major < 15) {
      ZegoLoggerService.logInfo(
        'not support smaller than 15',
        tag: 'uikit-channel',
        subTag: 'stopIOSPIP',
      );

      return false;
    }

    ZegoLoggerService.logInfo(
      '',
      tag: 'uikit-channel',
      subTag: 'stopIOSPIP',
    );

    bool result = false;
    try {
      result = await methodChannel.invokeMethod('stopPIP', {});
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to request: $e.',
        tag: 'uikit-channel',
        subTag: 'stopPIPInIOS',
      );
    }

    return result;
  }

  /// only support iOS
  @override
  Future<bool> isIOSInPIP() async {
    if (Platform.isAndroid) {
      ZegoLoggerService.logInfo(
        'not support in Android',
        tag: 'uikit-channel',
        subTag: 'isIOSInPIP',
      );

      return false;
    }

    final systemVersion = ZegoUIKit().getMobileSystemVersion();
    if (systemVersion.major < 15) {
      ZegoLoggerService.logInfo(
        'not support smaller than 15',
        tag: 'uikit-channel',
        subTag: 'isIOSInPIP',
      );

      return false;
    }

    ZegoLoggerService.logInfo(
      '',
      tag: 'uikit-channel',
      subTag: 'isIOSInPIP',
    );

    var isInPIP = false;
    try {
      isInPIP = await methodChannel.invokeMethod('isInPIP', {});
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to request: $e.',
        tag: 'uikit-channel',
        subTag: 'isIOSInPIP',
      );
    }

    return isInPIP;
  }

  /// only support iOS
  @override
  Future<void> enableIOSPIP(
    String streamID, {
    int aspectWidth = 9,
    int aspectHeight = 16,
  }) async {
    if (Platform.isAndroid) {
      ZegoLoggerService.logInfo(
        'not support in Android',
        tag: 'uikit-channel',
        subTag: 'enableIOSPIP',
      );

      return;
    }

    final systemVersion = ZegoUIKit().getMobileSystemVersion();
    if (systemVersion.major < 15) {
      ZegoLoggerService.logInfo(
        'not support smaller than 15',
        tag: 'uikit-channel',
        subTag: 'enableIOSPIP',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'streamID:$streamID, ',
      tag: 'uikit-channel',
      subTag: 'enableIOSPIP',
    );

    try {
      await methodChannel.invokeMethod('enablePIP', {
        'stream_id': streamID,
        'aspect_width': aspectWidth,
        'aspect_height': aspectHeight,
      });
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to request: $e.',
        tag: 'uikit-channel',
        subTag: 'enableIOSPIP',
      );
    }
  }

  /// only support iOS
  @override
  Future<void> updateIOSPIPSource(String streamID) async {
    if (Platform.isAndroid) {
      ZegoLoggerService.logInfo(
        'not support in Android',
        tag: 'uikit-channel',
        subTag: 'updateIOSPIPSource',
      );

      return;
    }

    final systemVersion = ZegoUIKit().getMobileSystemVersion();
    if (systemVersion.major < 15) {
      ZegoLoggerService.logInfo(
        'not support smaller than 15',
        tag: 'uikit-channel',
        subTag: 'updateIOSPIPSource',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'streamID:$streamID, ',
      tag: 'uikit-channel',
      subTag: 'updateIOSPIPSource',
    );

    try {
      await methodChannel.invokeMethod('updatePIPSource', {
        'stream_id': streamID,
      });
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to request: $e.',
        tag: 'uikit-channel',
        subTag: 'updateIOSPIPSource',
      );
    }
  }

  /// only support iOS
  @override
  Future<void> enableIOSPIPAuto(
    bool isEnabled, {
    int aspectWidth = 9,
    int aspectHeight = 16,
  }) async {
    if (Platform.isAndroid) {
      ZegoLoggerService.logInfo(
        'not support in Android',
        tag: 'uikit-channel',
        subTag: 'enableIOSPIPAuto',
      );

      return;
    }

    final systemVersion = ZegoUIKit().getMobileSystemVersion();
    if (systemVersion.major < 15) {
      ZegoLoggerService.logInfo(
        'not support smaller than 15',
        tag: 'uikit-channel',
        subTag: 'enableIOSPIPAuto',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'enabled:$isEnabled, ',
      tag: 'uikit-channel',
      subTag: 'enableIOSPIPAuto',
    );

    try {
      await methodChannel.invokeMethod('enableAutoPIP', {
        'enabled': isEnabled,
        'aspect_width': aspectWidth,
        'aspect_height': aspectHeight,
      });
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to request: $e.',
        tag: 'uikit-channel',
        subTag: 'enableIOSPIPAuto',
      );
    }
  }

  /// only support iOS
  @override
  Future<void> enableHardwareDecoder(bool isEnabled) async {
    if (Platform.isAndroid) {
      ZegoLoggerService.logInfo(
        'not support in Android',
        tag: 'uikit-channel',
        subTag: 'enableHardwareDecoder',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'enabled:$isEnabled, ',
      tag: 'uikit-channel',
      subTag: 'enableHardwareDecoder',
    );

    try {
      await methodChannel.invokeMethod('enableHardwareDecoder', {
        'enabled': isEnabled,
      });
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to request: $e.',
        tag: 'uikit-channel',
        subTag: 'enableHardwareDecoder',
      );
    }
  }

  /// only support iOS
  @override
  Future<void> enableCustomVideoRender(bool isEnabled) async {
    if (Platform.isAndroid) {
      ZegoLoggerService.logInfo(
        'not support in Android',
        tag: 'uikit-channel',
        subTag: 'enableCustomVideoRender',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'enabled:$isEnabled, ',
      tag: 'uikit-channel',
      subTag: 'enableCustomVideoRender',
    );

    try {
      await methodChannel.invokeMethod('enableCustomVideoRender', {
        'enabled': isEnabled,
      });
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to request: $e.',
        tag: 'uikit-channel',
        subTag: 'enableCustomVideoRender',
      );
    }
  }

  /// only support iOS
  @override
  Future<void> startPlayingStreamInPIP(String streamID) async {
    if (Platform.isAndroid) {
      ZegoLoggerService.logInfo(
        'not support in Android',
        tag: 'uikit-channel',
        subTag: 'startPlayingStreamInPIP',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'streamID:$streamID, ',
      tag: 'uikit-channel',
      subTag: 'startPlayingStreamInPIP',
    );

    try {
      await methodChannel.invokeMethod('startPlayingStreamInPIP', {
        'stream_id': streamID,
      });
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to request: $e.',
        tag: 'uikit-channel',
        subTag: 'startPlayingStreamInPIP',
      );
    }
  }

  /// only support iOS
  @override
  Future<void> updatePlayingStreamViewInPIP(
    int viewID,
    String streamID,
    int viewMode,
  ) async {
    if (Platform.isAndroid) {
      ZegoLoggerService.logInfo(
        'not support in Android',
        tag: 'uikit-channel',
        subTag: 'updatePlayingStreamViewInPIP',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'viewID:$viewID, '
      'streamID:$streamID, '
      'viewMode:$viewMode, ',
      tag: 'uikit-channel',
      subTag: 'updatePlayingStreamViewInPIP',
    );

    try {
      await methodChannel.invokeMethod('updatePlayingStreamViewInPIP', {
        'view_id': viewID,
        'stream_id': streamID,
        'view_mode': viewMode,
      });
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to request: $e.',
        tag: 'uikit-channel',
        subTag: 'updatePlayingStreamViewInPIP',
      );
    }
  }

  /// only support iOS
  @override
  Future<void> stopPlayingStreamInPIP(String streamID) async {
    if (Platform.isAndroid) {
      ZegoLoggerService.logInfo(
        'not support in Android',
        tag: 'uikit-channel',
        subTag: 'stopPlayingStreamInPIP',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'streamID:$streamID',
      tag: 'uikit-channel',
      subTag: 'stopPlayingStreamInPIP',
    );

    try {
      await methodChannel.invokeMethod('stopPlayingStreamInPIP', {
        'stream_id': streamID,
      });
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to request: $e.',
        tag: 'uikit-channel',
        subTag: 'stopPlayingStreamInPIP',
      );
    }
  }

  @override
  Future<void> reporterCreate({
    required String userID,
    required int appID,
    required String signOrToken,
    Map<String, Object> params = const {},
  }) async {
    ZegoLoggerService.logInfo(
      'userID:$userID, '
      'appID:$appID, '
      'params:$params, ',
      tag: 'uikit-channel',
      subTag: 'reporterCreate',
    );

    try {
      await methodChannel.invokeMethod('reporterCreate', {
        'user_id': userID,
        'app_id': appID,
        'sign_token': signOrToken,
        'params': params,
      });
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to request: $e.',
        tag: 'uikit-channel',
        subTag: 'reporterCreate',
      );
    }
  }

  @override
  Future<void> reporterDestroy() async {
    ZegoLoggerService.logInfo(
      '',
      tag: 'uikit-channel',
      subTag: 'reporterDestroy',
    );

    try {
      await methodChannel.invokeMethod('reporterDestroy', {});
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to request: $e.',
        tag: 'uikit-channel',
        subTag: 'reporterDestroy',
      );
    }
  }

  @override
  Future<void> reporterUpdateToken(String token) async {
    ZegoLoggerService.logInfo(
      'token:$token, ',
      tag: 'uikit-channel',
      subTag: 'reporterUpdateToken',
    );

    try {
      await methodChannel.invokeMethod('reporterUpdateToken', {
        'token': token,
      });
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to request: $e.',
        tag: 'uikit-channel',
        subTag: 'reporterUpdateToken',
      );
    }
  }

  @override
  Future<void> reporterUpdateCommonParams(Map<String, Object> params) async {
    ZegoLoggerService.logInfo(
      'params:$params, ',
      tag: 'uikit-channel',
      subTag: 'reporterUpdateCommonParams',
    );

    try {
      await methodChannel.invokeMethod('reporterUpdateCommonParams', {
        'params': params,
      });
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to request: $e.',
        tag: 'uikit-channel',
        subTag: 'reporterUpdateCommonParams',
      );
    }
  }

  @override
  Future<void> reporterEvent({
    required String event,
    Map<String, Object> params = const {},
  }) async {
    ZegoLoggerService.logInfo(
      'event:$event, '
      'params:$params, ',
      tag: 'uikit-channel',
      subTag: 'reporterEvent',
    );

    try {
      await methodChannel.invokeMethod('reporterEvent', {
        'event': event,
        'params': params,
      });
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to request: $e.',
        tag: 'uikit-channel',
        subTag: 'reporterEvent',
      );
    }
  }

  @override
  Future<void> openAppSettings() async {
    if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'not support in iOS',
        tag: 'uikit-channel',
        subTag: 'openAppSettings',
      );
      return;
    }

    ZegoLoggerService.logInfo(
      'openAppSettings',
      tag: 'uikit-channel',
      subTag: 'openAppSettings',
    );

    try {
      await methodChannel.invokeMethod('openAppSettings');
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to open app settings: $e.',
        tag: 'uikit-channel',
        subTag: 'openAppSettings',
      );
    }
  }
}
