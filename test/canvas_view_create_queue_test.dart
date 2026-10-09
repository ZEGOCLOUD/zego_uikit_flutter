import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:zego_uikit/src/services/internal/core/core.dart';
import 'package:zego_uikit/src/services/internal/core/data/canvas_view_create_queue.dart';
import 'package:zego_uikit/src/services/internal/core/data/stream.dart';
import 'package:zego_uikit/src/services/defines/audio_video.dart';

void main() {
  test('远端播放先启动，不等待本地画布队列释放', () async {
    final queue = ZegoStreamCanvasViewCreateQueue();
    final localCanvasStarted = Completer<void>();
    final localCanvasGate = Completer<void>();
    final remoteCanvasStarted = Completer<void>();
    var remotePlaybackStarted = false;

    unawaited(
      queue.addTask(
        uniqueKey: 'local-preview',
        task: () async {
          localCanvasStarted.complete();
          await localCanvasGate.future;
        },
      ),
    );
    await localCanvasStarted.future;

    await enqueueCanvasCreationAfterStreamStarts(
      streamID: 'remote-stream',
      queue: queue,
      startPlayback: () async {
        remotePlaybackStarted = true;
      },
      createCanvas: () async {
        remoteCanvasStarted.complete();
        queue.completeCurrentTask();
      },
    );

    expect(remotePlaybackStarted, isTrue);
    expect(remoteCanvasStarted.isCompleted, isFalse);
    expect(queue.currentTaskKey, 'local-preview');

    localCanvasGate.complete();
    queue.completeCurrentTask();
    await remoteCanvasStarted.future;
  });

  test('播放请求被取消后，不再排入画布队列', () async {
    final queue = ZegoStreamCanvasViewCreateQueue();
    final localCanvasStarted = Completer<void>();
    final localCanvasGate = Completer<void>();
    final playbackStarted = Completer<void>();
    final playbackGate = Completer<void>();
    var remoteCanvasCreated = false;
    final requests = StreamStartRequestCoordinator();
    unawaited(
      queue.addTask(
        uniqueKey: 'local-preview',
        task: () async {
          localCanvasStarted.complete();
          await localCanvasGate.future;
        },
      ),
    );
    await localCanvasStarted.future;

    final enqueue = startStreamPlaybackWithCanvasQueue(
      requests: requests,
      streamID: 'remote-stream',
      queue: queue,
      onRequestReserved: () {},
      isCanvasStateCurrent: () => true,
      startPlayback: () async {
        playbackStarted.complete();
        await playbackGate.future;
      },
      createCanvas: () async => remoteCanvasCreated = true,
      onStaleTask: queue.completeCurrentTask,
      onError: (error, stackTrace) =>
          Error.throwWithStackTrace(error, stackTrace),
    );

    await playbackStarted.future;
    requests.cancel('remote-stream');
    playbackGate.complete();
    await enqueue;

    expect(remoteCanvasCreated, isFalse);
    expect(queue.currentTaskKey, 'local-preview');
    localCanvasGate.complete();
    queue.completeCurrentTask();
  });

  test('同一流的并发启动请求只调用一次播放', () async {
    final queue = ZegoStreamCanvasViewCreateQueue();
    final playbackStarted = Completer<void>();
    final playbackGate = Completer<void>();
    final requests = StreamStartRequestCoordinator();
    var duplicatePlaybackCalls = 0;

    final firstRequest = startStreamPlaybackWithCanvasQueue(
      requests: requests,
      streamID: 'remote-stream',
      queue: queue,
      onRequestReserved: () {},
      isCanvasStateCurrent: () => true,
      startPlayback: () async {
        playbackStarted.complete();
        await playbackGate.future;
      },
      createCanvas: () async {},
      onError: (error, stackTrace) =>
          Error.throwWithStackTrace(error, stackTrace),
    );
    await playbackStarted.future;

    final duplicateRequest = await startStreamPlaybackWithCanvasQueue(
      requests: requests,
      streamID: 'remote-stream',
      queue: queue,
      onRequestReserved: () {},
      isCanvasStateCurrent: () => true,
      startPlayback: () async {
        duplicatePlaybackCalls++;
      },
      createCanvas: () async {},
      onError: (error, stackTrace) =>
          Error.throwWithStackTrace(error, stackTrace),
    );

    expect(duplicateRequest, isFalse);
    expect(duplicatePlaybackCalls, 0);

    requests.cancel('remote-stream');
    playbackGate.complete();
    expect(await firstRequest, isTrue);
  });

  test('播放启动失败后释放请求令牌', () async {
    final requests = StreamStartRequestCoordinator();
    Object? reportedError;

    final accepted = await startStreamPlaybackWithCanvasQueue(
      requests: requests,
      streamID: 'remote-stream',
      queue: ZegoStreamCanvasViewCreateQueue(),
      onRequestReserved: () {},
      isCanvasStateCurrent: () => true,
      startPlayback: () async => throw StateError('start failed'),
      createCanvas: () async {},
      onError: (error, stackTrace) => reportedError = error,
    );

    expect(accepted, isTrue);
    expect(reportedError, isA<StateError>());
    expect(requests.reserve('remote-stream'), isNotNull);
  });

  test('播放成功后才执行画布创建并释放请求令牌', () async {
    final requests = StreamStartRequestCoordinator();
    final queue = ZegoStreamCanvasViewCreateQueue();
    final canvasCreated = Completer<void>();
    var streamID = '';

    final accepted = await startStreamPlaybackWithCanvasQueue(
      requests: requests,
      streamID: 'remote-stream',
      queue: queue,
      onRequestReserved: () => streamID = 'remote-stream',
      isCanvasStateCurrent: () => streamID == 'remote-stream',
      startPlayback: () async {
        expect(streamID, 'remote-stream');
      },
      createCanvas: () async {
        canvasCreated.complete();
        queue.completeCurrentTask();
      },
      onError: (error, stackTrace) =>
          Error.throwWithStackTrace(error, stackTrace),
    );
    await canvasCreated.future;

    expect(accepted, isTrue);
    expect(requests.reserve('remote-stream'), isNotNull);
  });

  test('画布状态过期时清除仍属于本请求的创建标记', () async {
    final requests = StreamStartRequestCoordinator();
    var viewCreating = false;
    var streamID = '';

    await startStreamPlaybackWithCanvasQueue(
      requests: requests,
      streamID: 'remote-stream',
      queue: ZegoStreamCanvasViewCreateQueue(),
      onRequestReserved: () {
        streamID = 'remote-stream';
        viewCreating = true;
      },
      isCanvasStateCurrent: () => streamID.isNotEmpty,
      startPlayback: () async {
        streamID = '';
      },
      createCanvas: () async {},
      onRequestStale: () => viewCreating = false,
      onError: (error, stackTrace) =>
          Error.throwWithStackTrace(error, stackTrace),
    );

    expect(viewCreating, isFalse);
    expect(requests.reserve('remote-stream'), isNotNull);
  });

  test('迟到的旧回调不会释放下一条流的队列任务', () async {
    final queue = ZegoStreamCanvasViewCreateQueue();
    final firstTaskStarted = Completer<void>();
    final firstTaskGate = Completer<void>();
    final nextTaskStarted = Completer<void>();
    final nextTaskGate = Completer<void>();
    final thirdTaskStarted = Completer<void>();

    unawaited(
      queue.addTask(
        uniqueKey: 'old-stream',
        task: () async {
          firstTaskStarted.complete();
          await firstTaskGate.future;
        },
      ),
    );
    await firstTaskStarted.future;
    unawaited(
      queue.addTask(
        uniqueKey: 'next-stream',
        task: () async {
          nextTaskStarted.complete();
          await nextTaskGate.future;
        },
      ),
    );
    unawaited(
      queue.addTask(
        uniqueKey: 'third-stream',
        task: () async {
          thirdTaskStarted.complete();
          queue.completeCurrentTask();
        },
      ),
    );

    firstTaskGate.complete();
    queue.completeCurrentTask();
    await nextTaskStarted.future;

    completeCanvasQueueTaskIfCurrent(
      queue: queue,
      isCurrent: () => false,
    );

    expect(queue.currentTaskKey, 'next-stream');
    expect(thirdTaskStarted.isCompleted, isFalse);

    nextTaskGate.complete();
    queue.completeCurrentTask();
    await thirdTaskStarted.future;
  });

  test('当前画布回调可以释放当前队列任务', () async {
    final queue = ZegoStreamCanvasViewCreateQueue();
    final taskStarted = Completer<void>();

    unawaited(
      queue.addTask(
        uniqueKey: 'remote-stream',
        task: () async => taskStarted.complete(),
      ),
    );
    await taskStarted.future;

    completeCanvasQueueTaskIfCurrent(
      queue: queue,
      isCurrent: () => true,
    );
    await Future<void>.delayed(Duration.zero);

    expect(queue.currentTaskKey, isNull);
    expect(queue.isTaskRunning, isFalse);
  });

  test('roomID 在本地画布回调前变化时仍按入队时的任务 key 释放队列', () async {
    final queue = ZegoStreamCanvasViewCreateQueue();
    final taskStarted = Completer<void>();
    var roomID = '';
    final queuedTaskKey = generateStreamID(
      'local-user',
      roomID,
      ZegoStreamType.main,
    );

    unawaited(
      queue.addTask(
        uniqueKey: queuedTaskKey,
        task: () async => taskStarted.complete(),
      ),
    );
    await taskStarted.future;

    roomID = 'active-call';
    final currentRoomTaskKey = generateStreamID(
      'local-user',
      roomID,
      ZegoStreamType.main,
    );
    expect(currentRoomTaskKey, isNot(queuedTaskKey));

    completeCanvasQueueTaskIfCurrent(
      queue: queue,
      isCurrent: () => isLocalCanvasQueueTaskCurrent(
        queue: queue,
        queuedTaskKey: queuedTaskKey,
        expectedGeneration: 1,
        currentGeneration: 1,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(queue.currentTaskKey, isNull);
    expect(queue.isTaskRunning, isFalse);
  });

  test('停止预览使用入队时的本地 key 取消旧任务并继续远端画布', () async {
    final queue = ZegoStreamCanvasViewCreateQueue();
    final localTaskStarted = Completer<void>();
    final remoteTaskStarted = Completer<void>();
    final duplicateLocalTaskStarted = Completer<void>();
    final localTasks = ZegoStreamCanvasViewCreateQueueTaskTracker();
    var roomID = '';
    final localTaskKey = generateStreamID(
      'local-user',
      roomID,
      ZegoStreamType.main,
    );
    localTasks.track(localTaskKey);

    unawaited(
      queue.addTask(
        uniqueKey: localTaskKey,
        task: () async => localTaskStarted.complete(),
      ),
    );
    await localTaskStarted.future;
    unawaited(
      queue.addTask(
        uniqueKey: localTaskKey,
        task: () async => duplicateLocalTaskStarted.complete(),
      ),
    );
    unawaited(
      queue.addTask(
        uniqueKey: 'remote-stream',
        task: () async => remoteTaskStarted.complete(),
      ),
    );

    roomID = 'active-call';
    expect(
      generateStreamID('local-user', roomID, ZegoStreamType.main),
      isNot(localTaskKey),
    );
    expect(localTasks.cancelAll(queue), isTrue);
    await remoteTaskStarted.future;

    expect(duplicateLocalTaskStarted.isCompleted, isFalse);
    expect(queue.currentTaskKey, 'remote-stream');
    queue.completeCurrentTask();
  });

  test('已有画布仅在队列流、代数和远端用户对象匹配时释放任务', () async {
    final queue = ZegoStreamCanvasViewCreateQueue();
    final taskStarted = Completer<void>();
    final oldUser = Object();
    final rejoinedUser = Object();
    unawaited(
      queue.addTask(
        uniqueKey: 'remote-stream',
        task: () async => taskStarted.complete(),
      ),
    );
    await taskStarted.future;

    bool isCurrent({
      String streamID = 'remote-stream',
      int expectedGeneration = 4,
      int currentGeneration = 4,
      String channelStreamID = 'remote-stream',
      Iterable<Object>? currentUsers,
      Object? targetUser,
      bool streamRecordCurrent = true,
    }) =>
        isCanvasQueueTaskCurrent(
          queue: queue,
          streamID: streamID,
          expectedGeneration: expectedGeneration,
          currentGeneration: currentGeneration,
          channelStreamID: channelStreamID,
          currentUsers: currentUsers ?? [oldUser],
          targetUser: targetUser ?? oldUser,
          isStreamRecordCurrent: streamRecordCurrent,
        );

    expect(isCurrent(), isTrue);
    expect(isCurrent(streamID: 'another-stream'), isFalse);
    expect(isCurrent(currentGeneration: 5), isFalse);
    expect(isCurrent(channelStreamID: 'another-stream'), isFalse);
    expect(isCurrent(currentUsers: [rejoinedUser]), isFalse);
    expect(isCurrent(targetUser: rejoinedUser), isFalse);
    expect(isCurrent(streamRecordCurrent: false), isFalse);

    queue.clear();
  });

  test('清空后旧任务完成不会推进新队列', () async {
    final queue = ZegoStreamCanvasViewCreateQueue();
    final oldTaskStarted = Completer<void>();
    final oldTaskGate = Completer<void>();
    final newHeadStarted = Completer<void>();
    final newTailStarted = Completer<void>();

    unawaited(
      queue.addTask(
        uniqueKey: 'old-task',
        task: () async {
          oldTaskStarted.complete();
          await oldTaskGate.future;
        },
      ),
    );
    await oldTaskStarted.future;

    queue.clear();
    unawaited(
      queue.addTask(
        uniqueKey: 'new-head',
        task: () async => newHeadStarted.complete(),
      ),
    );
    unawaited(
      queue.addTask(
        uniqueKey: 'new-tail',
        task: () async => newTailStarted.complete(),
      ),
    );
    await newHeadStarted.future;

    oldTaskGate.complete();
    await Future<void>.delayed(Duration.zero);
    expect(queue.currentTaskKey, 'new-head');

    queue.completeCurrentTask();
    await newTailStarted.future;
    expect(queue.currentTaskKey, 'new-tail');

    queue.completeCurrentTask();
    await Future<void>.delayed(Duration.zero);
    expect(queue.currentTaskKey, isNull);
    expect(queue.isTaskRunning, isFalse);
  });

  test('排队后播放请求失效时跳过画布并继续队列', () async {
    final queue = ZegoStreamCanvasViewCreateQueue();
    final localCanvasStarted = Completer<void>();
    final localCanvasGate = Completer<void>();
    final staleTaskSkipped = Completer<void>();
    var requestStaleCallbackCalled = false;
    var remoteCanvasCreated = false;
    final requests = StreamStartRequestCoordinator();
    final token = requests.reserve('remote-stream')!;

    unawaited(
      queue.addTask(
        uniqueKey: 'local-preview',
        task: () async {
          localCanvasStarted.complete();
          await localCanvasGate.future;
        },
      ),
    );
    await localCanvasStarted.future;

    await enqueueCanvasCreationAfterStreamStarts(
      streamID: 'remote-stream',
      queue: queue,
      startPlayback: () async {},
      createCanvas: () async => remoteCanvasCreated = true,
      isRequestCurrent: () => requests.isCurrent('remote-stream', token),
      onRequestFinished: () => requests.release('remote-stream', token),
      onRequestStale: () => requestStaleCallbackCalled = true,
      onStaleTask: () {
        staleTaskSkipped.complete();
        queue.completeCurrentTask();
      },
    );

    requests.cancel('remote-stream');
    localCanvasGate.complete();
    queue.completeCurrentTask();
    await staleTaskSkipped.future;

    expect(remoteCanvasCreated, isFalse);
    expect(requestStaleCallbackCalled, isTrue);
  });

  test('取消旧请求不会释放同一流的新请求令牌', () {
    final requests = StreamStartRequestCoordinator();
    final oldToken = requests.reserve('remote-stream')!;

    expect(requests.reserve('remote-stream'), isNull);

    requests.cancel('remote-stream');
    final newToken = requests.reserve('remote-stream')!;
    requests.release('remote-stream', oldToken);

    expect(requests.isCurrent('remote-stream', newToken), isTrue);
    requests.release('remote-stream', newToken);
    expect(requests.isCurrent('remote-stream', newToken), isFalse);

    final clearedToken = requests.reserve('remote-stream')!;
    requests.clear();
    expect(requests.isCurrent('remote-stream', clearedToken), isFalse);
  });

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
