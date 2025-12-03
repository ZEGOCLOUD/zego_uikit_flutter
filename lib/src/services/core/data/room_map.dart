// Dart imports:
import 'dart:async';

// Package imports:
import 'package:synchronized/synchronized.dart';
import 'package:zego_uikit/src/services/core/core.dart';
// Project imports:
import 'package:zego_uikit/src/services/uikit_service.dart';

class ZegoUIKitCoreRoomMap<T extends Object> {
  String name;

  /// Internally uses a Map to store data, key is String (roomID), value is T
  final Map<String, T> _innerRoomMap = {};

  /// Factory function for creating T instances
  final T Function(String roomID) createDefault;

  /// Callback function for "upgrading" prepared room (optional)
  /// Called when prepared room is assigned a real roomID
  final void Function(T room, String roomID)? _onUpgradeEmptyRoom;

  /// Lock for protecting async iteration
  final Lock _lock = Lock();

  /// Cached prepared room instance, to avoid duplicate creation
  /// Returns this instance when roomID is empty, will be "upgraded" when first using non-empty roomID
  T? _emptyRoomCache;

  /// Timer for periodically outputting _innerRoomMap
  Timer? _debugTimer;

  /// Constructor: must pass in method for creating T instance
  /// [onUpgradeEmptyRoom] Optional upgrade callback for updating prepared room's roomID and other properties
  ZegoUIKitCoreRoomMap({
    required this.name,
    required this.createDefault,
    void Function(T room, String roomID)? onUpgradeEmptyRoom,
  }) : _onUpgradeEmptyRoom = onUpgradeEmptyRoom {
    // Start timer, output _innerRoomMap every second
    if (ZegoUIKitCore.shared.coreData.useDebugMode) {
      _debugTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'name:$name, '
          '_innerRoomMap: $_innerRoomMap',
          tag: 'uikit.room-map',
          subTag: 'debug-output',
        );
      });
    }
  }

  /// Add or update room data
  void putRoom(String roomID, T value) {
    if (roomID.isEmpty) {
      assert(roomID.isNotEmpty, 'roomID cannot be empty');
      return;
    }
    _lock.synchronized(() {
      _innerRoomMap[roomID] = value;
    });
  }

  /// Get data based on roomID
  ///
  /// Prepared room mechanism:
  /// 1. When roomID is empty, return prepared room (_emptyRoomCache)
  /// 2. When first using non-empty roomID and it doesn't exist in map, will "upgrade" prepared room
  /// 3. This keeps externally set listeners from being lost
  ///
  /// Note: Although this method is synchronous, internal critical operations are protected by lock
  /// Lock operations are async, but we avoid waiting by immediately returning existing objects
  T getRoom(String roomID) {
    if (roomID.isEmpty) {
      // Prepared room creation also needs lock protection
      if (_emptyRoomCache != null) {
        return _emptyRoomCache!;
      }

      _lock.synchronized(() {
        // Double check
        _emptyRoomCache ??= createDefault(roomID);
      });

      ZegoLoggerService.logInfo(
        'hash:$hashCode, '
        'name:$name, '
        'room id:$roomID, '
        'create empty room(${_emptyRoomCache.hashCode}), ',
        tag: 'uikit.room-map',
        subTag: 'getRoom',
      );
      return _emptyRoomCache!;
    }

    // If room already exists, return directly (no need to wait for lock)
    if (_innerRoomMap.containsKey(roomID)) {
      return _innerRoomMap[roomID]!;
    }

    // Room doesn't exist, need to create (protected by lock)
    _lock.synchronized(() {
      // Double check: may have been created by other operation while waiting for lock
      if (_innerRoomMap.containsKey(roomID)) {
        return;
      }

      // If there's a prepared room, "upgrade" it (reuse existing listeners and other state)
      if (_emptyRoomCache != null) {
        // Call upgrade callback to let external update roomID and other properties

        _onUpgradeEmptyRoom?.call(_emptyRoomCache!, roomID);

        _innerRoomMap[roomID] = _emptyRoomCache!;

        ZegoLoggerService.logInfo(
          'hash:$hashCode, '
          'name:$name, '
          'room id:$roomID, '
          'use empty room(${_emptyRoomCache.hashCode}), ',
          tag: 'uikit.room-map',
          subTag: 'getRoom',
        );

        _emptyRoomCache = null; // Prepared room has been used, clear cache
      } else {
        // No prepared room, create new instance
        _innerRoomMap[roomID] = createDefault(roomID);
      }
    });

    // Return newly created room (lock may not be released yet, but object is created)
    return _innerRoomMap[roomID]!;
  }

  /// Delete specified room data
  void removeRoom(String roomID) {
    if (roomID.isEmpty) {
      return; // Ignore empty roomID
    }
    _lock.synchronized(() {
      _innerRoomMap.remove(roomID);
    });
  }

  /// Clear all room data
  void clearRooms() {
    _lock.synchronized(() {
      _innerRoomMap.clear();
    });
  }

  /// Dispose resources, cancel timers
  void dispose() {
    _debugTimer?.cancel();
    _debugTimer = null;
    _emptyRoomCache = null;
    clearRooms();
  }

  /// Async iterate all room data (key is roomID, value is corresponding data)
  /// Protected by lock to avoid concurrent modification exceptions
  /// Suitable for scenarios where async operations need to be executed in callback
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

  /// Sync iterate all room data (key is roomID, value is corresponding data)
  /// Suitable for scenarios where only sync operations are in callback
  void forEachSync(
    void Function(String roomID, T value) action,
  ) {
    // Create a snapshot to avoid concurrent modification
    final entries = _innerRoomMap.entries.toList();
    for (final entry in entries) {
      action(entry.key, entry.value);
    }
  }

  /// Check if room exists
  bool containsRoom(String roomID) {
    return _innerRoomMap.containsKey(roomID);
  }

  /// Get all room IDs
  List<String> get allRoomIDs => _innerRoomMap.keys.toList();

  /// Get room count
  int get roomCount => _innerRoomMap.length;
}
