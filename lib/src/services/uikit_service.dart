// Dart imports:
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_logs_yoer/flutter_logs_yoer.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

// Project imports:
import 'package:zego_uikit/src/channel/platform_interface.dart';
import 'package:zego_uikit/src/modules/hall_room/helper.dart';
import 'package:zego_uikit/src/plugins/beauty/uikit_beauty_plugin_impl.dart';
import 'package:zego_uikit/src/plugins/plugins.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/core/core.dart';
import 'package:zego_uikit/src/services/core/core.dart';
import 'package:zego_uikit/src/services/core/defines/defines.dart';
import 'package:zego_uikit/src/services/defines/defines.dart';
import 'package:zego_uikit/src/services/log_exporter/logs_share_manager.dart';

part 'audio_video_service.dart';

part 'custom_command_service.dart';

part 'channel_service.dart';

part 'device_service.dart';

part 'effect_service.dart';

part 'logger_service.dart';

part 'media_service.dart';

part 'message_service.dart';

part 'plugin_service.dart';

part 'room_service.dart';

part 'user_service.dart';

part 'event_service.dart';

part 'mixer_service.dart';

/// {@category APIs}
/// {@category Features}
class ZegoUIKit
    with
        ZegoAudioVideoService,
        ZegoRoomService,
        ZegoUserService,
        ZegoChannelService,
        ZegoMessageService,
        ZegoCustomCommandService,
        ZegoDeviceService,
        ZegoEffectService,
        ZegoPluginService,
        ZegoMediaService,
        ZegoMixerService,
        ZegoEventService,
        ZegoLoggerService {
  factory ZegoUIKit() {
    /// make sure core data stream had created
    ZegoUIKitCore.shared.coreData.init();

    return instance;
  }

  ZegoUIKit._internal() {
    WidgetsFlutterBinding.ensureInitialized();

    initLog();
  }

  static final ZegoUIKit instance = ZegoUIKit._internal();

  /// version
  Future<String> getZegoUIKitVersion() async {
    return ZegoUIKitCore.shared.getZegoUIKitVersion();
  }

  /// init
  ///
  /// Called before enter room/push or pull stream
  ///
  /// * [enablePlatformView],
  /// Not recommended for use. Current usage scenarios include:
  /// 1. displaying PIP on iOS,
  /// 2. playing MP4 on media.
  /// * [playingStreamInPIPUnderIOS],
  /// If you want to display PIP iOS, you need to set it to true, and then
  /// the platform view + custom rendering mechanism will be launched.
  /// At this time, [enablePlatformView] should be set to **true**.
  Future<void> init({
    required int appID,
    String appSign = '',
    String token = '',
    bool? enablePlatformView,
    bool playingStreamInPIPUnderIOS = false,
    ZegoUIKitScenario scenario = ZegoUIKitScenario.Default,

    /// accept offline call invitation on android, will create in advance
    bool withoutCreateEngine = false,
  }) async {
    return ZegoUIKitCore.shared.init(
      appID: appID,
      appSign: appSign,
      token: token,
      scenario: scenario,
      playingStreamInPIPUnderIOS: playingStreamInPIPUnderIOS,
      enablePlatformView: enablePlatformView,
      withoutCreateEngine: withoutCreateEngine,
    );
  }

  /// uninit
  /// Warning, the engine will be destroyed
  /// In theory, it should not be called
  Future<void> uninit() async {
    return ZegoUIKitCore.shared.uninit();
  }

  /// Set advanced engine configuration, Used to enable advanced functions.
  /// For details, please consult ZEGO technical support.
  Future<void> setAdvanceConfigs(Map<String, String> configs) async {
    await ZegoUIKitCore.shared.setAdvanceConfigs(configs);
  }

  ValueNotifier<DateTime?> getNetworkTime() {
    return ZegoUIKitCore.shared.coreData.timestamp.notifier;
  }

  Stream<ZegoUIKitError> getErrorStream() {
    return ZegoUIKitCore.shared.coreData.error.errorStreamCtrl?.stream ??
        const Stream.empty();
  }

  Stream<ZegoUIKitExpressEngineState> getEngineStateStream() {
    return ZegoUIKitCore.shared.coreData.engine.stateStreamCtrl.stream;
  }

  ZegoUIKitReporter reporter() {
    return ZegoUIKitCore.shared.reporter;
  }

  ValueNotifier<bool> get engineCreatedNotifier =>
      ZegoUIKitCore.shared.coreData.engine.createdNotifier;
}
