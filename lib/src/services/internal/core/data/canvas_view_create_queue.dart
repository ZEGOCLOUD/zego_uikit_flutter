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

  String? get currentTaskId => _taskList.isNotEmpty ? _taskList[0].id : null;

  void clear() {
    _isTaskRunning = false;
    _taskList = [];

    if (!(_completer?.isCompleted ?? true)) {
      _completer?.complete();
    }
  }

  void completeCurrentTask() {
    final tempCompleter = _completer;
    _completer = null;

    if (!(tempCompleter?.isCompleted ?? true)) {
      tempCompleter?.complete();
    }
  }

  Future<void> addTask({
    required String id,
    required Future Function() task,
  }) async {
    TaskItem taskItem = TaskItem(
      DateTime.now().millisecondsSinceEpoch.toString(),
      task,
      () {
        ZegoLoggerService.logInfo(
          'task run finished, task queue size:${_taskList.length}, '
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
      'task is added, task queue size:${_taskList.length}',
      tag: 'uikit-stream',
      subTag: 'queue',
    );
    _doTask();
  }

  Future<void> _doTask() async {
    if (_isTaskRunning) {
      ZegoLoggerService.logInfo(
        'task is running',
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
      'try get task, task queue size:${_taskList.length}',
      tag: 'uikit-stream',
      subTag: 'queue',
    );

    _completer = Completer<void>();
    TaskItem task = _taskList[0];
    _isTaskRunning = true;

    ZegoLoggerService.logInfo(
      'run task',
      tag: 'uikit-stream',
      subTag: 'queue',
    );
    try {
      await task.runner.call();

      await _completer?.future;

      task.next();
    } catch (e) {
      ZegoLoggerService.logInfo(
        'task exception, $e',
        tag: 'uikit-stream',
        subTag: 'queue',
      );

      task.next();
    }
  }
}

class TaskItem {
  final String id;
  final Future Function() runner;
  final VoidCallback next;

  const TaskItem(
    this.id,
    this.runner,
    this.next,
  );
}
