class ZegoUIKitCoreRoomMap<T extends Object> {
  /// 内部用一个 Map 存储数据，key 是 String（roomID），value 是 T
  final Map<String, T> _innerRoomMap = {};

  /// 用于创建 T 实例的工厂函数
  final T Function(String roomID) _createDefault;

  /// 构造函数：必须传入创建 T 实例的方法
  ZegoUIKitCoreRoomMap(this._createDefault);

  /// 添加或更新房间数据
  void putRoom(String roomID, T value) {
    _innerRoomMap[roomID] = value;
  }

  /// 根据 roomID 获取数据
  T getRoom(String roomID) {
    if (!_innerRoomMap.containsKey(roomID)) {
      _innerRoomMap[roomID] = _createDefault(roomID);
    }
    return _innerRoomMap[roomID]!;
  }

  /// 删除指定房间数据
  void removeRoom(String roomID) {
    _innerRoomMap.remove(roomID);
  }

  /// 清空所有房间数据
  void clearRooms() {
    _innerRoomMap.clear();
  }

  /// 遍历所有房间数据（key 是 roomID，value 是对应数据）
  void forEach(void Function(String roomID, T value) action) {
    _innerRoomMap.forEach((key, value) => action(key, value));
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
