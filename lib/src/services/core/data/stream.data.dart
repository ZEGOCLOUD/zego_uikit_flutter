class ZegoUIKitCoreDataStreamData {
  String id;
  String roomID;
  String userID;
  String userName;
  bool fromAnotherRoom;

  ZegoUIKitCoreDataStreamData({
    required this.id,
    required this.roomID,
    required this.userID,
    required this.userName,
    this.fromAnotherRoom = false,
  });

  static ZegoUIKitCoreDataStreamData empty() {
    return ZegoUIKitCoreDataStreamData(
        id: '', roomID: '', userName: '', userID: '');
  }

  bool get isEmpty => id.isEmpty || userID.isEmpty;

  ZegoUIKitCoreDataStreamData copyWith({
    String? id,
    String? roomID,
    String? userID,
    String? userName,
    bool? fromAnotherRoom,
  }) {
    return ZegoUIKitCoreDataStreamData(
      id: id ?? this.id,
      roomID: roomID ?? this.roomID,
      userID: userID ?? this.userID,
      userName: userName ?? this.userName,
      fromAnotherRoom: fromAnotherRoom ?? this.fromAnotherRoom,
    );
  }

  @override
  String toString() {
    return 'ZegoUIKitCoreDataStreamData{'
        'hashCode:$hashCode, '
        'id:$id, '
        'room id:$roomID, '
        'user id:$userID, '
        'user name:$userName, '
        'fromAnotherRoom:$fromAnotherRoom, '
        '}';
  }
}
