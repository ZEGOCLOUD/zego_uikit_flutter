// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/services/uikit_service.dart';

class ZegoStreamCanvasViewCreateQueue {
  Completer? _completer;

  bool _isTaskRunning = false;
  List<TaskItem> _taskList = [];

  bool get isTaskRunning => _isTaskRunning;

  String? get currentTaskKey => _taskList.isNotEmpty ? _taskList[0].key : null;

  void clear() {
    _isTaskRunning = false;
    _taskList = [];

    if (!(_completer?.isCompleted ?? true)) {
      _completer?.complete();
    }
  }

  void completeCurrentTask() {
    ZegoLoggerService.logInfo(
      'complete current task($currentTaskKey)',
      tag: 'uikit-stream',
      subTag: 'queue',
    );

    final tempCompleter = _completer;
    _completer = null;

    if (!(tempCompleter?.isCompleted ?? true)) {
      tempCompleter?.complete();
    }
  }

  Future<void> addTask({
    required String uniqueKey,
    required Future Function() task,
  }) async {
    TaskItem taskItem = TaskItem(
      uniqueKey,
      task,
      () {
        ZegoLoggerService.logInfo(
          'task($uniqueKey) run finished, task queue size:${_taskList.length}, '
          'keys:${_taskList.map((e) => '${e.key},')}, '
          'run next task',
          tag: 'uikit-stream',
          subTag: 'queue',
        );

        if (_taskList.isNotEmpty) {
          _taskList.removeAt(0);
          _isTaskRunning = false;
          _doTask();
        }
      },
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
        'task($currentTaskKey) is running',
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

    _completer = Completer<void>();
    TaskItem task = _taskList[0];
    _isTaskRunning = true;

    ZegoLoggerService.logInfo(
      'run task(${task.key})',
      tag: 'uikit-stream',
      subTag: 'queue',
    );
    try {
      await task.runner.call();

      await _completer?.future;

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
