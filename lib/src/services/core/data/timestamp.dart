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
  DateTime get now {
    if (_beginDateTime != null && _syncStartTime != null) {
      // 实时计算时间，确保即使定时器还没触发也能获取到正确的时间
      final elapsed = DateTime.now().difference(_syncStartTime!);
      return _beginDateTime!.add(elapsed);
    }
    return _networkDateTime.value ?? DateTime.now();
  }

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
        _networkTimeInfoFixerTimer = Timer.periodic(
          const Duration(milliseconds: 100),
          (timer) {
            ZegoExpressEngine.instance.getNetworkTimeInfo().then(
              (timeInfo) {
                if (timeInfo.timestamp > 0) {
                  _networkTimeInfoFixerTimer?.cancel();
                  _sync(timeInfo.timestamp);
                }
              },
            );
          },
        );
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
    _durationTimer = null;
    _networkTimeInfoFixerTimer?.cancel();
    _networkTimeInfoFixerTimer = null;
    _beginDateTime = null;
    _syncStartTime = null;
  }

  void _sync(int timestamp) {
    _beginDateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    _syncStartTime = DateTime.now();

    // 立即设置初始值，不等待定时器第一次触发
    _networkDateTime.value = _beginDateTime;

    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_beginDateTime != null && _syncStartTime != null) {
        // 使用实际经过的时间来计算，而不是依赖 timer.tick
        // 这样可以避免定时器暂停导致的时间不更新问题
        final elapsed = DateTime.now().difference(_syncStartTime!);
        _networkDateTime.value = _beginDateTime!.add(elapsed);
      }
    });
  }

  Timer? _durationTimer;
  DateTime? _beginDateTime;
  DateTime? _syncStartTime;
  final _networkDateTime = ValueNotifier<DateTime?>(null);

  Timer? _networkTimeInfoFixerTimer;
}
