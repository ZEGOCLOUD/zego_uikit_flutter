// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/services/uikit_service.dart';

class ZegoUIKitCoreDataTimestamp {
  DateTime get now => _networkDateTime.value ?? DateTime.now();

  ValueNotifier<DateTime?> get notifier => _networkDateTime;

  Future<void> init() async {
    ZegoLoggerService.logInfo(
      'get network time info',
      tag: 'uikit.timestamp',
      subTag: 'init',
    );

    await ZegoExpressEngine.instance.getNetworkTimeInfo().then((timeInfo) {
      if (timeInfo.timestamp <= 0) {
        _networkTimeInfoFixerTimer?.cancel();
        _networkTimeInfoFixerTimer =
            Timer.periodic(const Duration(milliseconds: 100), (timer) {
          ZegoExpressEngine.instance.getNetworkTimeInfo().then((timeInfo) {
            if (timeInfo.timestamp > 0) {
              _networkTimeInfoFixerTimer?.cancel();
              _sync(timeInfo.timestamp);
            }
          });
        });
      } else {
        _sync(timeInfo.timestamp);
      }

      ZegoLoggerService.logInfo(
        'network time info is init, timestamp:${timeInfo.timestamp}, max deviation:${timeInfo.maxDeviation}',
        tag: 'uikit.timestamp',
        subTag: 'init',
      );
    });
  }

  void uninit() {
    _durationTimer?.cancel();
  }

  void _sync(int timestamp) {
    _beginDateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _networkDateTime.value =
          _beginDateTime?.add(Duration(seconds: timer.tick));
    });
  }

  Timer? _durationTimer;
  DateTime? _beginDateTime;
  final _networkDateTime = ValueNotifier<DateTime?>(null);

  Timer? _networkTimeInfoFixerTimer;
}
