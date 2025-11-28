// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

// Project imports:
import 'package:zego_uikit/src/services/services.dart';

/// @nodoc
class ZegoBeautyPluginCoreData {
  bool isInit = false;

  /// create engine
  Future<void> create({
    required int appID,
    required String appSign,
  }) async {
    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.beauty) == null) {
      return;
    }

    if (isInit) {
      ZegoLoggerService.logInfo(
        'has created.',
        tag: 'uikit.plugin.beauty',
        subTag: 'beauty core data',
      );

      return;
    }

    ZegoPluginAdapter().beautyPlugin!.init(
          appID: appID,
          appSign: appSign,
        );
    isInit = true;

    ZegoLoggerService.logInfo(
      'create, appID:$appID, ',
      tag: 'uikit.plugin.beauty',
      subTag: 'beauty core data',
    );
  }

  /// destroy engine
  Future<void> destroy() async {
    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.beauty) == null) {
      return;
    }

    ZegoPluginAdapter().beautyPlugin!.uninit();
    isInit = false;
    ZegoLoggerService.logInfo(
      'destroy.',
      tag: 'uikit.plugin.beauty',
      subTag: 'beauty core data',
    );
    clear();
  }

  void clear() {
    ZegoLoggerService.logInfo(
      'clear',
      tag: 'uikit.plugin.beauty',
      subTag: 'beauty core data',
    );
  }

  /// setConfig
  void setConfig(ZegoBeautyPluginConfig config) {
    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.beauty) != null) {
      ZegoPluginAdapter().beautyPlugin!.setConfig(config);
    }
  }

  /// showBeautyUI
  void showBeautyUI(BuildContext context) {
    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.beauty) != null) {
      ZegoPluginAdapter().beautyPlugin!.showBeautyUI(context);
    }
  }

  Stream<ZegoBeautyPluginFaceDetectionData> getFaceDetectionEventStream() {
    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.beauty) != null) {
      return ZegoPluginAdapter().beautyPlugin!.getFaceDetectionEventStream();
    }

    return const Stream.empty();
  }

  Stream<ZegoBeautyError> getErrorStream() {
    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.beauty) != null) {
      return ZegoPluginAdapter().beautyPlugin!.getErrorStream();
    }

    return const Stream.empty();
  }
}
