// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:synchronized/synchronized.dart';

// Project imports:
import 'package:zego_uikit/src/services/uikit_service.dart';

class ZegoUIKitCoreRoomMap<T extends Object> {
  String name;

  /// 内部用一个 Map 存储数据，key 是 String（roomID），value 是 T
  final Map<String, T> _innerRoomMap = {};

  /// 用于创建 T 实例的工厂函数
  final T Function(String roomID) createDefault;

  /// 用于"升级"预备房间的回调函数（可选）
  /// 当预备房间被分配真实 roomID 时调用
  final void Function(T room, String roomID)? _onUpgradeEmptyRoom;

  /// 用于保护异步遍历的锁
  final Lock _lock = Lock();

  /// 缓存的预备房间实例，避免重复创建
  /// 当 roomID 为空时返回此实例，当第一次使用非空 roomID 时会被"升级"
  T? _emptyRoomCache;

  /// 构造函数：必须传入创建 T 实例的方法
  /// [onUpgradeEmptyRoom] 可选的升级回调，用于更新预备房间的 roomID 等属性
  ZegoUIKitCoreRoomMap({
    required this.name,
    required this.createDefault,
    void Function(T room, String roomID)? onUpgradeEmptyRoom,
  }) : _onUpgradeEmptyRoom = onUpgradeEmptyRoom;

  /// 添加或更新房间数据
  void putRoom(String roomID, T value) {
    if (roomID.isEmpty) {
      assert(roomID.isNotEmpty, 'roomID cannot be empty');
      return;
    }
    _lock.synchronized(() {
      _innerRoomMap[roomID] = value;
    });
  }

  /// 根据 roomID 获取数据
  ///
  /// 预备房间机制：
  /// 1. 当 roomID 为空时，返回预备房间（_emptyRoomCache）
  /// 2. 当第一次使用非空 roomID 且 map 中不存在时，会"升级"预备房间
  /// 3. 这样可以保持外部已设置的监听器不丢失
  ///
  /// 注意：虽然此方法是同步的，但内部使用锁保护关键操作
  /// 锁操作是异步的，但我们通过立即返回已存在的对象来避免等待
  T getRoom(String roomID) {
    if (roomID.isEmpty) {
      // 预备房间的创建也需要锁保护
      if (_emptyRoomCache != null) {
        return _emptyRoomCache!;
      }

      _lock.synchronized(() {
        // 双重检查
        _emptyRoomCache ??= createDefault(roomID);
      });

      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'name:$name, '
        'room id:$roomID, '
        'create empty room(${_emptyRoomCache.hashCode}), ',
        tag: 'uikit-room',
        subTag: 'room-map',
      );
      return _emptyRoomCache!;
    }

    // 如果房间已存在，直接返回（无需等待锁）
    if (_innerRoomMap.containsKey(roomID)) {
      return _innerRoomMap[roomID]!;
    }

    // 房间不存在，需要创建（使用锁保护）
    _lock.synchronized(() {
      // 双重检查：可能在等待锁期间已被其他操作创建
      if (_innerRoomMap.containsKey(roomID)) {
        return;
      }

      // 如果有预备房间，则"升级"它（复用已有的监听器等状态）
      if (_emptyRoomCache != null) {
        // 调用升级回调，让外部更新 roomID 等属性

        _onUpgradeEmptyRoom?.call(_emptyRoomCache!, roomID);

        _innerRoomMap[roomID] = _emptyRoomCache!;

        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'name:$name, '
          'room id:$roomID, '
          'use empty room(${_emptyRoomCache.hashCode}), ',
          tag: 'uikit-room',
          subTag: 'room-map',
        );

        _emptyRoomCache = null; // 预备房间已被使用，清空缓存
      } else {
        // 没有预备房间，创建新实例
        _innerRoomMap[roomID] = createDefault(roomID);
      }
    });

    // 返回刚创建的房间（此时可能锁还未释放，但对象已创建）
    return _innerRoomMap[roomID]!;
  }

  /// 删除指定房间数据
  void removeRoom(String roomID) {
    if (roomID.isEmpty) {
      return; // 忽略空 roomID
    }
    _lock.synchronized(() {
      _innerRoomMap.remove(roomID);
    });
  }

  /// 清空所有房间数据
  void clearRooms() {
    _lock.synchronized(() {
      _innerRoomMap.clear();
    });
  }

  /// 异步遍历所有房间数据（key 是 roomID，value 是对应数据）
  /// 使用锁保护，避免并发修改异常
  /// 适用于需要在回调中执行异步操作的场景
  Future<void> forEachAsync(
    Future<void> Function(String roomID, T value) action,
  ) async {
    // Create a snapshot of entries inside lock to ensure consistency
    final entries = await _lock.synchronized(() {
      return _innerRoomMap.entries.toList();
    });

    // Execute actions outside the lock to avoid deadlock
    // Note: The room might be removed during action execution,
    // but we process the snapshot to avoid concurrent modification errors
    for (final entry in entries) {
      await action(entry.key, entry.value);
    }
  }

  /// 同步遍历所有房间数据（key 是 roomID，value 是对应数据）
  /// 适用于回调中只有同步操作的场景
  void forEachSync(
    void Function(String roomID, T value) action,
  ) {
    // Create a snapshot to avoid concurrent modification
    final entries = _innerRoomMap.entries.toList();
    for (final entry in entries) {
      action(entry.key, entry.value);
    }
  }

  /// 判断房间是否存在
  bool containsRoom(String roomID) {
    return _innerRoomMap.containsKey(roomID);
  }

  /// 获取所有房间 ID
  List<String> get allRoomIDs => _innerRoomMap.keys.toList();

  /// 获取房间数量
  int get roomCount => _innerRoomMap.length;
}
