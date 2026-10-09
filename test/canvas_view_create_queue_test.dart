import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:zego_uikit/src/services/internal/core/core.dart';
import 'package:zego_uikit/src/services/internal/core/data/stream.dart';

void main() {
  test('异步画布回调完成前不释放创建队列', () async {
    final callbackGate = Completer<void>();
    var queueReleased = false;

    final callback = completeCanvasViewCreationCallback(
      () => callbackGate.future,
      onCompleted: () => queueReleased = true,
    );

    await Future<void>.delayed(Duration.zero);
    expect(queueReleased, isFalse);

    callbackGate.complete();
    await callback;
    expect(queueReleased, isTrue);
  });

  test('重复初始化未指定PlatformView时保留原设置', () {
    expect(
      ZegoUIKitCore.resolvePlatformViewEnabledForReinit(
        requestedValue: null,
        currentValue: true,
      ),
      isTrue,
    );
  });

  test('重复初始化明确关闭PlatformView时更新设置', () {
    expect(
      ZegoUIKitCore.resolvePlatformViewEnabledForReinit(
        requestedValue: false,
        currentValue: true,
      ),
      isFalse,
    );
  });
}
