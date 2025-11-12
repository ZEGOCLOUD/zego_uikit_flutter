part of 'uikit_service.dart';

mixin ZegoRoomService {
  /// 当前是否有房间登录
  bool get hasRoomLogin {
    bool value = false;

    ZegoUIKitCore.shared.coreData.room.rooms.forEachSync((roomID, room) {
      if (ZegoUIKitHallRoomIDHelper.isRandomRoomID(roomID)) {
        /// 跳过大厅房间
        return;
      }

      if (value) {
        /// 已经有房间登录了，不需要再更新值
        return;
      }

      if (room.isLogin) {
        value = true;
      }
    });

    return value;
  }

  /// 当前已登录的房间数量
  /// 跳过大厅房间
  int get loginRoomCount {
    int count = 0;

    ZegoUIKitCore.shared.coreData.room.rooms.forEachSync((roomID, room) {
      if (ZegoUIKitHallRoomIDHelper.isRandomRoomID(roomID)) {
        /// 跳过大厅房间
        return;
      }

      if (!room.isLogin) {
        return;
      }

      count++;
    });

    return count;
  }

  /// get room object
  /// 只针对单房间模式，如果是多房间模式，请通过[getRoom]
  ZegoUIKitRoom getCurrentRoom() {
    ZegoUIKitRoom currentRoom = ZegoUIKitRoom.empty();
    ZegoUIKitCore.shared.coreData.room.rooms.forEachSync((roomID, room) {
      if (ZegoUIKitHallRoomIDHelper.isRandomRoomID(roomID)) {
        /// 跳过大厅房间
        return;
      }

      if (!room.isLogin) {
        /// 跳过没登录的房间
        return;
      }

      currentRoom = room.toUIKitRoom();
    });

    return currentRoom;
  }

  /// join room
  ///
  /// *[token]
  /// The token issued by the developer's business server is used to ensure security.
  /// For the generation rules, please refer to [Using Token Authentication] (https://doc-zh.zego.im/article/10360), the default is an empty string, that is, no authentication.
  ///
  /// if appSign is not passed in or if appSign is empty, this parameter must be set for authentication when logging in to a room.
  Future<ZegoUIKitRoomLoginResult> joinRoom(
    String roomID, {
    String token = '',
    bool markAsLargeRoom = false,
    bool keepWakeScreen = true,

    /// Simulate entering the room, it will not really initiate the entry
    /// call on express (accept offline call invitation on android, will join
    /// in advance)
    bool isSimulated = false,
  }) async {
    if (ZegoUIKitCore.shared.hasLoginSameRoom(roomID)) {
      return ZegoRoomLoginResult(0, {});
    }

    final joinBeginTime = DateTime.now().millisecondsSinceEpoch;
    final joinRoomResult = await ZegoUIKitCore.shared.joinRoom(
      roomID,
      token: token,
      markAsLargeRoom: markAsLargeRoom,
      keepWakeScreen: keepWakeScreen,
      isSimulated: isSimulated,
    );

    if (ZegoErrorCode.CommonSuccess != joinRoomResult.errorCode) {
      ZegoUIKitCore.shared.coreData.error.errorStreamCtrl?.add(ZegoUIKitError(
        code: ZegoUIKitErrorCode.roomLoginError,
        message: 'login room error:${joinRoomResult.errorCode}, '
            'room id:$roomID, large room:$markAsLargeRoom, '
            '${ZegoUIKitErrorCode.expressErrorCodeDocumentTips}',
        method: 'joinRoom',
      ));
    }

    ZegoUIKit().reporter().report(
      event: ZegoUIKitReporter.eventLoginRoom,
      params: {
        ZegoUIKitReporter.eventKeyRoomID: roomID,
        ZegoUIKitReporter.eventKeyToken: token,
        ZegoUIKitReporter.eventKeyStartTime: joinBeginTime,
        ZegoUIKitReporter.eventKeyErrorCode: joinRoomResult.errorCode,
        ZegoUIKitReporter.eventKeyErrorMsg:
            joinRoomResult.extendedData.toString(),
      },
    );

    return joinRoomResult;
  }

  /// leave room
  Future<ZegoUIKitRoomLogoutResult> leaveRoom({
    required String targetRoomID,
    required bool stopPlayingAnotherRoomStream,
  }) async {
    final leaveRoomResult = await ZegoUIKitCore.shared.leaveRoom(
      targetRoomID: targetRoomID,
      stopPlayingAnotherRoomStream: stopPlayingAnotherRoomStream,
    );

    if (ZegoErrorCode.CommonSuccess != leaveRoomResult.errorCode) {
      ZegoUIKitCore.shared.coreData.error.errorStreamCtrl?.add(ZegoUIKitError(
        code: ZegoUIKitErrorCode.roomLeaveError,
        message: 'leave room error:${leaveRoomResult.errorCode}, '
            '${ZegoUIKitErrorCode.expressErrorCodeDocumentTips}',
        method: 'leaveRoom',
      ));
    }

    ZegoUIKit().reporter().report(
      event: ZegoUIKitReporter.eventLogoutRoom,
      params: {
        ZegoUIKitReporter.eventKeyRoomID: targetRoomID,
        ZegoUIKitReporter.eventKeyErrorCode: leaveRoomResult.errorCode,
        ZegoUIKitReporter.eventKeyErrorMsg:
            leaveRoomResult.extendedData.toString(),
      },
    );

    return leaveRoomResult;
  }

  Future<void> renewRoomToken(
    String token, {
    required String targetRoomID,
  }) async {
    await ZegoUIKitCore.shared.coreData.room.renewToken(
      token,
      targetRoomID: targetRoomID,
    );
  }

  /// get room object
  ZegoUIKitRoom getRoom({
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.room.rooms
        .getRoom(targetRoomID)
        .toUIKitRoom();
  }

  /// get room state notifier
  ValueNotifier<ZegoUIKitRoomsState> getRoomsStateStream() {
    return ZegoUIKitCore.shared.coreData.room.roomsStateNotifier;
  }

  /// get room state notifier
  ValueNotifier<ZegoUIKitRoomState> getRoomStateStream({
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.room.rooms.getRoom(targetRoomID).state;
  }

  /// update one room property
  Future<bool> setRoomProperty(
    String key,
    String value, {
    required String targetRoomID,
  }) async {
    return ZegoUIKitCore.shared.setRoomProperty(
      key,
      value,
      targetRoomID: targetRoomID,
    );
  }

  /// update room properties
  Future<bool> updateRoomProperties(
    Map<String, String> properties, {
    required String targetRoomID,
  }) async {
    return ZegoUIKitCore.shared.updateRoomProperties(
      Map<String, String>.from(properties),
      targetRoomID: targetRoomID,
    );
  }

  /// get room properties
  Map<String, RoomProperty> getRoomProperties({
    required String targetRoomID,
  }) {
    return Map<String, RoomProperty>.from(ZegoUIKitCore
        .shared.coreData.room.rooms
        .getRoom(targetRoomID)
        .properties);
  }

  /// only notify the property which changed
  /// you can get full properties by getRoomProperties() function
  Stream<RoomProperty> getRoomPropertyStream({
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.room.rooms
            .getRoom(targetRoomID)
            .propertyUpdateStream
            ?.stream ??
        const Stream.empty();
  }

  /// the room Token authentication is about to expire will be sent 30 seconds before the Token expires
  Stream<int> getRoomTokenExpiredStream({
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.room.rooms
            .getRoom(targetRoomID)
            .tokenExpiredStreamCtrl
            ?.stream ??
        const Stream.empty();
  }

  /// only notify the properties which changed
  /// you can get full properties by getRoomProperties() function
  Stream<Map<String, RoomProperty>> getRoomPropertiesStream({
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.room.rooms
            .getRoom(targetRoomID)
            .propertiesUpdatedStream
            ?.stream ??
        const Stream.empty();
  }

  ValueNotifier<ZegoUIKitNetworkState> getNetworkStateNotifier() {
    return ZegoUIKitCore.shared.coreData.networkStateNotifier;
  }

  ZegoUIKitNetworkState getNetworkState() {
    return ZegoUIKitCore.shared.coreData.networkStateNotifier.value;
  }

  /// get network state notifier
  Stream<ZegoUIKitNetworkState> getNetworkModeStream() {
    return ZegoUIKitCore.shared.coreData.networkStateStreamCtrl?.stream ??
        const Stream.empty();
  }
}
