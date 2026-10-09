// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/services/uikit_service.dart';

class ZegoStreamCanvasViewCreateQueue {
  Completer? _completer;

  int _queueGeneration = 0;
  bool _isTaskRunning = false;
  List<TaskItem> _taskList = [];

  bool get isTaskRunning => _isTaskRunning;

  String? get currentTaskKey => _taskList.isNotEmpty ? _taskList[0].key : null;

  void clear() {
    _queueGeneration++;
    _isTaskRunning = false;
    _taskList = [];

    final taskCompleter = _completer;
    _completer = null;
    if (!(taskCompleter?.isCompleted ?? true)) {
      taskCompleter?.complete();
    }
  }

  void completeCurrentTask() {
    ZegoLoggerService.logInfo(
      'try complete current task($currentTaskKey)',
      tag: 'uikit-stream',
      subTag: 'queue',
    );

    if (_completer == null) {
      ZegoLoggerService.logInfo(
        'completer is null',
        tag: 'uikit-stream',
        subTag: 'queue',
      );

      return;
    }

    final tempCompleter = _completer;
    _completer = null;

    if (!(tempCompleter?.isCompleted ?? true)) {
      ZegoLoggerService.logInfo(
        'current task($currentTaskKey) is completed',
        tag: 'uikit-stream',
        subTag: 'queue',
      );

      tempCompleter?.complete();
    }
  }

  Future<void> addTask({
    required String uniqueKey,
    required Future Function() task,
  }) async {
    late final TaskItem taskItem;
    final taskGeneration = _queueGeneration;
    taskItem = TaskItem(
      uniqueKey,
      task,
      () => _finishTask(taskItem, taskGeneration),
    );

    _taskList.add(taskItem);
    ZegoLoggerService.logInfo(
      'task($uniqueKey) is added, task queue size:${_taskList.length}, '
      'keys:${_taskList.map((e) => '${e.key},')}',
      tag: 'uikit-stream',
      subTag: 'queue',
    );
    _doTask();
  }

  Future<void> _doTask() async {
    if (_isTaskRunning) {
      ZegoLoggerService.logInfo(
        'task($currentTaskKey) is running, ignore current do request',
        tag: 'uikit-stream',
        subTag: 'queue',
      );

      return;
    }

    if (_taskList.isEmpty) {
      ZegoLoggerService.logInfo(
        'task queue is empty',
        tag: 'uikit-stream',
        subTag: 'queue',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'try get task, task queue size:${_taskList.length}, '
      'keys:${_taskList.map((e) => '${e.key},')}',
      tag: 'uikit-stream',
      subTag: 'queue',
    );

    final taskCompleter = Completer<void>();
    _completer = taskCompleter;
    final task = _taskList[0];
    _isTaskRunning = true;

    ZegoLoggerService.logInfo(
      'run task(${task.key})',
      tag: 'uikit-stream',
      subTag: 'queue',
    );
    try {
      await task.runner.call();

      await taskCompleter.future;

      task.next();
    } catch (e) {
      ZegoLoggerService.logInfo(
        'task(${task.key}) exception, $e',
        tag: 'uikit-stream',
        subTag: 'queue',
      );

      task.next();
    }
  }

  void _finishTask(TaskItem task, int taskGeneration) {
    if (taskGeneration != _queueGeneration ||
        _taskList.isEmpty ||
        !identical(_taskList.first, task)) {
      ZegoLoggerService.logInfo(
        'ignore stale task(${task.key}) completion, '
        'task generation:$taskGeneration, current generation:$_queueGeneration, '
        'current task:$currentTaskKey',
        tag: 'uikit-stream',
        subTag: 'queue',
      );
      return;
    }

    ZegoLoggerService.logInfo(
      'task(${task.key}) run finished, task queue size:${_taskList.length}, '
      'keys:${_taskList.map((e) => '${e.key},')}, '
      'run next task',
      tag: 'uikit-stream',
      subTag: 'queue',
    );

    _taskList.removeAt(0);
    _completer = null;
    _isTaskRunning = false;
    _doTask();
  }
}

class TaskItem {
  final String key;
  final Future Function() runner;
  final VoidCallback next;

  const TaskItem(
    this.key,
    this.runner,
    this.next,
  );
}
