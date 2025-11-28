// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

export 'package:zego_plugin_adapter/zego_plugin_adapter.dart'
    show ZegoSignalingPluginPushConfig;

/// @nodoc
extension ZegoSignalingPluginNotificationConfigToMap
    on ZegoSignalingPluginPushConfig {
  Map<String, dynamic> toMap() {
    return {
      'resourceID': resourceID,
      'title': title,
      'message': message,
    };
  }
}

/// @nodoc
class ZegoNotificationConfig {
  ZegoNotificationConfig({
    this.notifyWhenAppIsInTheBackgroundOrQuit = true,
    this.resourceID = '',
    this.title = '',
    this.message = '',
    this.voIPConfig,
  });

  bool notifyWhenAppIsInTheBackgroundOrQuit;
  String resourceID;
  String title;
  String message;
  ZegoNotificationVoIPConfig? voIPConfig;

  @override
  String toString() {
    return '{'
        'title:$title, '
        'message:$message, '
        'resource id:$resourceID, '
        'voIPConfig:$voIPConfig, '
        'notify:$notifyWhenAppIsInTheBackgroundOrQuit, '
        '}';
  }
}

/// @nodoc
class ZegoNotificationVoIPConfig {
  ZegoNotificationVoIPConfig({
    this.iOSVoIPHasVideo = false,
  });

  bool iOSVoIPHasVideo;

  @override
  String toString() => '{'
      'iOSVoIPHasVideo: $iOSVoIPHasVideo, '
      '}';
}
