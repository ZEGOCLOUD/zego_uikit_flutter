// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/services/core/data/error.dart';
import 'package:zego_uikit/src/services/defines/defines.dart';
import 'package:zego_uikit/src/services/uikit_service.dart';
import '../core.dart';

class ZegoUIKitCoreDataEngine {
  ValueNotifier<ZegoUIKitExpressEngineState> stateNotifier =
      ValueNotifier<ZegoUIKitExpressEngineState>(
    ZegoUIKitExpressEngineState.Stop,
  );
  final stateStreamCtrl =
      StreamController<ZegoUIKitExpressEngineState>.broadcast();

  final createdNotifier = ValueNotifier<bool>(false);

  /// for custom video processing
  bool waitingEngineStopEnableValueOfCustomVideoProcessing = false;
  StreamSubscription? stateUpdatedSubscriptionByEnableCustomVideoProcessing;

  /// for custom video render
  bool waitingEngineStopEnableValueOfCustomVideoRender = false;
  StreamSubscription? stateUpdatedSubscriptionByEnableCustomVideoRender;

  ZegoUIKitCoreDataError get _errorCommonData =>
      ZegoUIKitCore.shared.coreData.error;

  Future<void> create({
    required int appID,
    String appSign = '',
    String token = '',
    bool withoutCreateEngine = false,
    bool? enablePlatformView,
    ZegoUIKitScenario scenario = ZegoUIKitScenario.Default,
  }) async {
    ZegoExpressEngine.setEngineConfig(
      ZegoEngineConfig(advancedConfig: {'vcap_external_mem_class': '1'}),
    );

    ZegoLoggerService.logInfo(
      'create engine with profile,'
      'withoutCreateEngine:$withoutCreateEngine, ',
      tag: 'uikit-engine',
      subTag: 'init',
    );
    if (withoutCreateEngine) {
      /// make it has been created (android call offline invitation will have a scene created in advance)
      createdNotifier.value = true;
    } else {
      try {
        await ZegoExpressEngine.createEngineWithProfile(
          ZegoEngineProfile(
            appID,
            scenario,
            appSign: appSign,
            enablePlatformView: enablePlatformView,
          ),
        ).then((value) {
          ZegoLoggerService.logInfo(
            'engine created',
            tag: 'uikit-engine',
            subTag: 'init',
          );
        });

        /// Even if the callback returns, the internal ve may not have been created yet and needs to wait
        createdNotifier.value = true;
      } catch (e) {
        ZegoLoggerService.logInfo(
          'engine error:$e, '
          'app sign:$appSign, ',
          tag: 'uikit-engine',
          subTag: 'init',
        );

        _errorCommonData.errorStreamCtrl?.add(
          ZegoUIKitError(
            code: -1,
            message: e.toString(),
            method: 'createEngineWithProfile',
          ),
        );
        createdNotifier.value = false;
      }
    }

    ZegoExpressEngine.setEngineConfig(
      ZegoEngineConfig(
        advancedConfig: {
          'notify_remote_device_unknown_status': 'true',
          'notify_remote_device_init_status': 'true',
          'keep_audio_session_active': 'true',
        },
      ),
    );
  }
}
