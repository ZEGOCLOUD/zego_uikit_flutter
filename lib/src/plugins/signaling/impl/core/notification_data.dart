// Dart imports:
import 'dart:async';

// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

// Project imports:
import 'package:zego_uikit/src/services/services.dart';

/// @nodoc
mixin ZegoSignalingPluginCoreNotificationData {
  bool notifyWhenAppIsInTheBackgroundOrQuit = false;

  // ------- notification event streams ------
  StreamController<ZegoSignalingPluginNotificationArrivedEvent>?
      streamCtrlNotificationArrived;
  StreamController<ZegoSignalingPluginNotificationClickedEvent>?
      streamCtrlNotificationClicked;
  StreamController<ZegoSignalingPluginNotificationRegisteredEvent>?
      streamCtrlNotificationRegistered;

  void initNotificationData() {
    ZegoLoggerService.logInfo(
      'init notification data',
      tag: 'uikit-plugin-signaling',
      subTag: 'notification data',
    );

    streamCtrlNotificationArrived ??= StreamController<
        ZegoSignalingPluginNotificationArrivedEvent>.broadcast();
    streamCtrlNotificationClicked ??= StreamController<
        ZegoSignalingPluginNotificationClickedEvent>.broadcast();
    streamCtrlNotificationRegistered ??= StreamController<
        ZegoSignalingPluginNotificationRegisteredEvent>.broadcast();
  }

  void uninitNotificationData() {
    ZegoLoggerService.logInfo(
      'uninit notification data',
      tag: 'uikit-plugin-signaling',
      subTag: 'notification data',
    );

    streamCtrlNotificationArrived?.close();
    streamCtrlNotificationArrived = null;

    streamCtrlNotificationClicked?.close();
    streamCtrlNotificationClicked = null;

    streamCtrlNotificationRegistered?.close();
    streamCtrlNotificationRegistered = null;
  }

  /// enable notification
  Future<ZegoSignalingPluginEnableNotifyResult>
      enableNotifyWhenAppRunningInBackgroundOrQuit(
    bool enabled, {
    bool? isIOSSandboxEnvironment,
    bool enableIOSVoIP = true,
    ZegoSignalingPluginMultiCertificate certificateIndex =
        ZegoSignalingPluginMultiCertificate.firstCertificate,
    String appName = '',
    String androidChannelID = '',
    String androidChannelName = '',
    String androidSound = '',
  }) {
    ZegoLoggerService.logInfo(
      'enable notify when app is in the background or quit: $enabled',
      tag: 'uikit-plugin-signaling',
      subTag: 'notification data',
    );
    notifyWhenAppIsInTheBackgroundOrQuit = enabled;

    return ZegoPluginAdapter()
        .signalingPlugin!
        .enableNotifyWhenAppRunningInBackgroundOrQuit(
          isIOSSandboxEnvironment: isIOSSandboxEnvironment,
          enableIOSVoIP: enableIOSVoIP,
          certificateIndex: certificateIndex,
          appName: appName,
          androidChannelID: androidChannelID,
          androidChannelName: androidChannelName,
          androidSound: androidSound,
        );
  }

  /// get notification arrived stream
  Stream<ZegoSignalingPluginNotificationArrivedEvent>
      getNotificationArrivedStream() {
    return streamCtrlNotificationArrived?.stream ?? const Stream.empty();
  }

  /// get notification clicked stream
  Stream<ZegoSignalingPluginNotificationClickedEvent>
      getNotificationClickedStream() {
    return streamCtrlNotificationClicked?.stream ?? const Stream.empty();
  }

  /// get notification registered stream
  Stream<ZegoSignalingPluginNotificationRegisteredEvent>
      getNotificationRegisteredStream() {
    return streamCtrlNotificationRegistered?.stream ?? const Stream.empty();
  }
}
