/// Represents a room property with key-value pair.
class RoomProperty {
  /// The property key.
  String key = '';

  /// The property value.
  String value = '';

  /// The old property value (for updates).
  String? oldValue;

  /// Timestamp of the last update.
  int updateTime = 0;

  /// User ID who made the update.
  String updateUserID = '';

  /// Whether the property was updated from remote.
  bool updateFromRemote = false;

  RoomProperty(
    this.key,
    this.value,
    this.updateTime,
    this.updateUserID,
    this.updateFromRemote,
  );

  RoomProperty.copyFrom(RoomProperty property)
      : key = property.key,
        value = property.value,
        oldValue = property.oldValue,
        updateTime = property.updateTime,
        updateUserID = property.updateUserID,
        updateFromRemote = property.updateFromRemote;

  void copyFrom(RoomProperty property) {
    key = property.key;
    value = property.value;
    oldValue = property.oldValue;
    updateTime = property.updateTime;
    updateUserID = property.updateUserID;
    updateFromRemote = property.updateFromRemote;
  }

  @override
  String toString() {
    return '{'
        'key:$key, '
        'value:$value, '
        'old value:$oldValue, '
        'update time:$updateTime, '
        'update user id:$updateUserID, '
        'update from remote:$updateFromRemote, '
        '}';
  }
}

/// Keys for room properties.
enum RoomPropertyKey {
  /// Host user property.
  host,

  /// Live status property.
  liveStatus,

  /// Live duration property.
  liveDuration,
}

extension RoomPropertyKeyExtension on RoomPropertyKey {
  static Map<String, RoomPropertyKey> textValues = {
    'host': RoomPropertyKey.host,
    'live_status': RoomPropertyKey.liveStatus,
    'ld': RoomPropertyKey.liveDuration,
  };

  String get text {
    final mapValues = {
      RoomPropertyKey.host: 'host',
      RoomPropertyKey.liveStatus: 'live_status',
      RoomPropertyKey.liveDuration: 'ld',
    };

    return mapValues[this]!;
  }
}
