class RoomProperty {
  String key = '';
  String value = '';
  String? oldValue;
  int updateTime = 0;
  String updateUserID = '';
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
    return 'key:$key, value:$value, old value:$oldValue, update time:$updateTime, update user id:$updateUserID, update from remote:$updateFromRemote';
  }
}

enum RoomPropertyKey {
  host,
  liveStatus,
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
