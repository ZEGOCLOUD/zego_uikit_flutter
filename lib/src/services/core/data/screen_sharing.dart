// Dart imports:
import 'dart:async';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/services/core/core.dart';
import 'package:zego_uikit/src/services/services.dart';
import '../defines/defines.dart';

class ZegoUIKitCoreDataScreenSharing {
  StreamController<List<ZegoUIKitCoreUser>>? screenSharingListStreamCtrl;

  ZegoScreenCaptureSource? screenCaptureSource;
  ValueNotifier<bool> isScreenSharing = ValueNotifier(false);
  ValueNotifier<bool> isScreenSharingQualityNormal = ValueNotifier(false);
  bool isFirstScreenSharing = true;

  void init() {
    ZegoLoggerService.logInfo(
      'init screen sharing',
      tag: 'uikit-screen-sharing',
      subTag: 'init',
    );

    screenSharingListStreamCtrl ??=
        StreamController<List<ZegoUIKitCoreUser>>.broadcast();
  }

  void uninit() {
    ZegoLoggerService.logInfo(
      'uninit screen sharing',
      tag: 'uikit-screen-sharing',
      subTag: 'uninit',
    );

    screenSharingListStreamCtrl?.close();
    screenSharingListStreamCtrl = null;
  }

  //start screen share
  Future<void> startSharingScreen({
    required String targetRoomID,
  }) async {
    ZegoLoggerService.logInfo(
      'try start',
      tag: 'uikit-screen-sharing',
      subTag: 'startSharingScreen',
    );

    screenCaptureSource =
        await ZegoExpressEngine.instance.createScreenCaptureSource();

    isScreenSharingQualityNormal.value = false;
    isScreenSharing.value = true;
    await ZegoUIKitCore.shared.coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .startPublishingStream(streamType: ZegoStreamType.screenSharing);
    final config = ZegoScreenCaptureConfig(
      true,
      true,
      microphoneVolume: 100,
      applicationVolume: 100,
    );
    await screenCaptureSource?.startCapture(
      config: config,
      inApp: false,
    );

    if (isFirstScreenSharing && Platform.isAndroid) {
      isFirstScreenSharing = false;
      await stopSharingScreen(
        targetRoomID: targetRoomID,
      );
      await startSharingScreen(
        targetRoomID: targetRoomID,
      );
    }

    ZegoLoggerService.logInfo(
      'start done',
      tag: 'uikit-screen-sharing',
      subTag: 'startSharingScreen',
    );
  }

  //stop screen share
  Future<void> stopSharingScreen({
    required String targetRoomID,
  }) async {
    ZegoLoggerService.logInfo(
      'try stop',
      tag: 'uikit-screen-sharing',
      subTag: 'stopSharingScreen',
    );

    isScreenSharingQualityNormal.value = false;
    isScreenSharing.value = false;

    await ZegoUIKitCore.shared.coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .stopPublishingStream(streamType: ZegoStreamType.screenSharing);

    screenCaptureSource?.stopCapture();

    await ZegoExpressEngine.instance
        .destroyScreenCaptureSource(screenCaptureSource!);

    ZegoLoggerService.logInfo(
      'stop done',
      tag: 'uikit-screen-sharing',
      subTag: 'stopSharingScreen',
    );
  }
}
