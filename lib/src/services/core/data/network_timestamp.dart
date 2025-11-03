// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

mixin ZegoUIKitCoreDataNetworkTimestamp {
  DateTime get networkDateTime_ => _networkDateTime.value ?? DateTime.now();

  ValueNotifier<DateTime?> get networkDateTime => _networkDateTime;

  void initNetworkTimestamp(int timestamp) {
    if (timestamp <= 0) {
      _networkTimeInfoFixerTimer?.cancel();
      _networkTimeInfoFixerTimer =
          Timer.periodic(const Duration(milliseconds: 100), (timer) {
        ZegoExpressEngine.instance.getNetworkTimeInfo().then((timeInfo) {
          if (timeInfo.timestamp > 0) {
            _networkTimeInfoFixerTimer?.cancel();
            _syncNetworkTimestamp(timeInfo.timestamp);
          }
        });
      });
    } else {
      _syncNetworkTimestamp(timestamp);
    }
  }

  void uninitNetworkTimestamp() {
    _durationTimer?.cancel();
  }

  void _syncNetworkTimestamp(int timestamp) {
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
