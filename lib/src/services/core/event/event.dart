// Dart imports:
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/services/defines/express.event.dart';
import 'package:zego_uikit/src/services/defines/media/media.dart';
import 'package:zego_uikit/src/services/uikit_service.dart';

part 'express.dart';

part 'media.dart';

class ZegoUIKitEvent with ZegoUIKitExpressEvent, ZegoUIKitMediaEvent {
  bool _isInit = false;

  void init() {
    if (_isInit) {
      ZegoLoggerService.logInfo(
        'had init before',
        tag: 'uikit-event',
        subTag: 'init',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'init',
      tag: 'uikit-event',
      subTag: 'init',
    );

    _isInit = true;

    express.init();
    media.init();
  }

  void uninit() {
    if (!_isInit) {
      ZegoLoggerService.logInfo(
        'is not init',
        tag: 'uikit-event',
        subTag: 'uninit',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'uikit-event',
      subTag: 'uninit',
    );

    express.uninit();
    media.uninit();

    _isInit = false;
  }
}
