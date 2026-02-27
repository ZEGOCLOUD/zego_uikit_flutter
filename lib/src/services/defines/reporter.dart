// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_uikit/src/channel/platform_interface.dart';
import 'package:zego_uikit/src/services/uikit_service.dart';

/// Reporter class for logging events to ZEGOCLOUD analytics.
///
/// This class provides methods to report user actions and events
/// to the ZEGOCLOUD analytics service.
class ZegoUIKitReporter {
  /// Event name for room login.
  static String eventLoginRoom = "loginRoom";

  /// Event name for room logout.
  static String eventLogoutRoom = "logoutRoom";

  /// Key for room ID in event parameters.
  static String eventKeyRoomID = "room_id";

  /// Key for user ID in event parameters.
  static String eventKeyUserID = "user_id";

  /// Key for token in event parameters.
  static String eventKeyToken = "token";

  /// Key for error message in event parameters.
  static String eventKeyErrorMsg = "msg";

  /// Key for error code in event parameters.
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

  /// Kit name for call.
  static String callKitName = "call";

  /// Kit name for live audio room.
  static String audioRoomKitName = "liveaudioroom";

  /// Kit name for live streaming.
  static String liveStreamingKitName = "livestreaming";

  /// Kit name for IM kit.
  static String imKitName = "imkit";

  /// Key for app state in event parameters.
  static String eventKeyAppState = "app_state";

  /// Value for active app state.
  static String eventKeyAppStateActive = "active";

  /// Value for background app state.
  static String eventKeyAppStateBackground = "background";

  /// Value for restarted app state.
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
      tag: 'uikit.reporter',
      subTag: 'create',
    );

    assert(appID != -1);

    if (hadCreated) {
      ZegoLoggerService.logInfo(
        'had created before',
        tag: 'uikit.reporter',
        subTag: 'create',
      );

      if (this.appID != appID) {
        ZegoLoggerService.logInfo(
          'app id is not equal, old:${this.appID}, now:$appID, '
          're-create...',
          tag: 'uikit.reporter',
          subTag: 'create',
        );

        return destroy().then((_) {
          ZegoLoggerService.logInfo(
            're-create, destroyed, create now..',
            tag: 'uikit.reporter',
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
          tag: 'uikit.reporter',
          subTag: 'create',
        );

        final uikitVersion = await ZegoUIKit().version();
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
      tag: 'uikit.reporter',
      subTag: 'create',
    );
    hadCreated = true;
    this.appID = appID;

    final uikitVersion = await ZegoUIKit().version();
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
        tag: 'uikit.reporter',
        subTag: 'destroy',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      '',
      tag: 'uikit.reporter',
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
        tag: 'uikit.reporter',
        subTag: 'updateCommonParams',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      '$params',
      tag: 'uikit.reporter',
      subTag: 'updateCommonParams',
    );

    await ZegoUIKitPluginPlatform.instance.reporterUpdateCommonParams(params);
  }

  Future<void> updateUserID(String userID) async {
    if (!hadCreated) {
      ZegoLoggerService.logInfo(
        'not init',
        tag: 'uikit.reporter',
        subTag: 'updateUserID',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'userID:$userID',
      tag: 'uikit.reporter',
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
        tag: 'uikit.reporter',
        subTag: 'renewToken',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'renew token, token size:${token.length}',
      tag: 'uikit.reporter',
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
        tag: 'uikit.reporter',
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
