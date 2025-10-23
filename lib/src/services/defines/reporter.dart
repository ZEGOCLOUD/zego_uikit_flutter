// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_uikit/src/channel/platform_interface.dart';
import 'package:zego_uikit/src/services/uikit_service.dart';

class ZegoUIKitReporter {
  static String eventLoginRoom = "loginRoom";
  static String eventLogoutRoom = "logoutRoom";

  static String eventKeyRoomID = "room_id";
  static String eventKeyUserID = "user_id";
  static String eventKeyToken = "token";

  static String eventKeyErrorMsg = "msg";
  static String eventKeyErrorCode = "error";

  /// Timestamp at the start of the event, in milliseconds
  static String eventKeyStartTime = "start_time";

  /// Platform type for developing Client application, such as android, ios, flutter, rn, uniApp, web
  static String eventKeyPlatform = "platform";

  /// Platform version, such as rn 0.75.4, flutter 3.24
  static String eventKeyPlatformVersion = "platform_version";

  /// The underlying uikit version number that each kit depends on, usually in three segments
  static String eventKeyUIKitVersion = "uikit_version";

  /// Name of kit, call for call, LIVE for livestreaming, voice chat for liveAudioRoom, chat for imkit
  static String eventKeyKitName = "kit_name";
  static String callKitName = "call";
  static String audioRoomKitName = "liveaudioroom";
  static String liveStreamingKitName = "livestreaming";
  static String imKitName = "imkit";

  static String eventKeyAppState = "app_state";
  static String eventKeyAppStateActive = "active";
  static String eventKeyAppStateBackground = "background";
  static String eventKeyAppStateRestarted = "restarted";

  static String currentAppState() {
    final appStateMap = <AppLifecycleState, String>{
      AppLifecycleState.resumed: eventKeyAppStateActive,
      AppLifecycleState.inactive: eventKeyAppStateBackground,
      AppLifecycleState.hidden: eventKeyAppStateBackground,
      AppLifecycleState.paused: eventKeyAppStateBackground,
      AppLifecycleState.detached: eventKeyAppStateBackground,
    };

    return appStateMap[WidgetsBinding.instance.lifecycleState] ??
        eventKeyAppStateBackground;
  }

  bool hadCreated = false;
  int appID = -1;

  Future<void> create({
    required String userID,
    required int appID,
    required String signOrToken,
    Map<String, Object> params = const {},
  }) async {
    ZegoLoggerService.logInfo(
      'appID:$appID, params:$params',
      tag: 'uikit-reporter',
      subTag: 'create',
    );

    assert(appID != -1);

    if (hadCreated) {
      ZegoLoggerService.logInfo(
        'had created before',
        tag: 'uikit-reporter',
        subTag: 'create',
      );

      if (this.appID != appID) {
        ZegoLoggerService.logInfo(
          'app id is not equal, old:${this.appID}, now:$appID, '
          're-create...',
          tag: 'uikit-reporter',
          subTag: 'create',
        );

        return destroy().then((_) {
          ZegoLoggerService.logInfo(
            're-create, destroyed, create now..',
            tag: 'uikit-reporter',
            subTag: 'create',
          );

          create(
            userID: userID,
            appID: appID,
            signOrToken: signOrToken,
            params: params,
          );
        });
      }

      if (params.isNotEmpty) {
        ZegoLoggerService.logInfo(
          'update common params',
          tag: 'uikit-reporter',
          subTag: 'create',
        );

        final uikitVersion = await ZegoUIKit().getZegoUIKitVersion();
        params.addAll({
          eventKeyPlatform: 'flutter',
          eventKeyUIKitVersion: uikitVersion,
        });
        updateCommonParams(params);
      }

      return;
    }

    ZegoLoggerService.logInfo(
      'create',
      tag: 'uikit-reporter',
      subTag: 'create',
    );
    hadCreated = true;
    this.appID = appID;

    final uikitVersion = await ZegoUIKit().getZegoUIKitVersion();
    if (params.isEmpty) {
      params = {
        eventKeyPlatform: 'flutter',
        eventKeyUIKitVersion: uikitVersion,
      };
    } else {
      params.addAll({
        eventKeyPlatform: 'flutter',
        eventKeyUIKitVersion: uikitVersion,
      });
    }
    await ZegoUIKitPluginPlatform.instance.reporterCreate(
      userID: userID,
      appID: appID,
      signOrToken: signOrToken,
      params: params,
    );
  }

  Future<void> destroy() async {
    if (!hadCreated) {
      ZegoLoggerService.logInfo(
        'not created',
        tag: 'uikit-reporter',
        subTag: 'destroy',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      '',
      tag: 'uikit-reporter',
      subTag: 'destroy',
    );
    hadCreated = false;
    appID = -1;

    await ZegoUIKitPluginPlatform.instance.reporterDestroy();
  }

  Future<void> updateCommonParams(Map<String, Object> params) async {
    if (!hadCreated) {
      ZegoLoggerService.logInfo(
        'not init',
        tag: 'uikit-reporter',
        subTag: 'updateCommonParams',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      '$params',
      tag: 'uikit-reporter',
      subTag: 'updateCommonParams',
    );

    await ZegoUIKitPluginPlatform.instance.reporterUpdateCommonParams(params);
  }

  Future<void> updateUserID(String userID) async {
    if (!hadCreated) {
      ZegoLoggerService.logInfo(
        'not init',
        tag: 'uikit-reporter',
        subTag: 'updateUserID',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'userID:$userID',
      tag: 'uikit-reporter',
      subTag: 'updateUserID',
    );

    await ZegoUIKitPluginPlatform.instance.reporterUpdateCommonParams({
      eventKeyUserID: userID,
    });
  }

  Future<void> renewToken(String token) async {
    if (!hadCreated) {
      ZegoLoggerService.logInfo(
        'not init',
        tag: 'uikit-reporter',
        subTag: 'renewToken',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'renew token, token size:${token.length}',
      tag: 'uikit-reporter',
      subTag: 'renewToken',
    );

    await ZegoUIKitPluginPlatform.instance.reporterUpdateToken(token);
  }

  Future<void> report({
    required String event,
    Map<String, Object> params = const {},
  }) async {
    if (!hadCreated) {
      ZegoLoggerService.logInfo(
        'not init',
        tag: 'uikit-reporter',
        subTag: 'report',
      );

      return;
    }

    await ZegoUIKitPluginPlatform.instance.reporterEvent(
      event: event,
      params: params,
    );
  }
}
