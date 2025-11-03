part of 'uikit_service.dart';

mixin ZegoRoomService {
  bool get isRoomLogin => ZegoUIKitCore.shared.coreData.room.id.isNotEmpty;

  /// join room
  ///
  /// *[token]
  /// The token issued by the developer's business server is used to ensure security.
  /// For the generation rules, please refer to [Using Token Authentication] (https://doc-zh.zego.im/article/10360), the default is an empty string, that is, no authentication.
  ///
  /// if appSign is not passed in or if appSign is empty, this parameter must be set for authentication when logging in to a room.
  Future<ZegoRoomLoginResult> joinRoom(
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
      ZegoUIKitCore.shared.error.errorStreamCtrl?.add(ZegoUIKitError(
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
  Future<ZegoRoomLogoutResult> leaveRoom({
    String? targetRoomID,
  }) async {
    final currentRoomID = ZegoUIKitCore.shared.coreData.room.id;

    final leaveRoomResult = await ZegoUIKitCore.shared.leaveRoom(
      targetRoomID: targetRoomID,
    );

    if (ZegoErrorCode.CommonSuccess != leaveRoomResult.errorCode) {
      ZegoUIKitCore.shared.error.errorStreamCtrl?.add(ZegoUIKitError(
        code: ZegoUIKitErrorCode.roomLeaveError,
        message: 'leave room error:${leaveRoomResult.errorCode}, '
            '${ZegoUIKitErrorCode.expressErrorCodeDocumentTips}',
        method: 'leaveRoom',
      ));
    }

    ZegoUIKit().reporter().report(
      event: ZegoUIKitReporter.eventLogoutRoom,
      params: {
        ZegoUIKitReporter.eventKeyRoomID: currentRoomID,
        ZegoUIKitReporter.eventKeyErrorCode: leaveRoomResult.errorCode,
        ZegoUIKitReporter.eventKeyErrorMsg:
            leaveRoomResult.extendedData.toString(),
      },
    );

    return leaveRoomResult;
  }

  Future<void> renewRoomToken(
    String token, {
    String? targetRoomID,
  }) async {
    await ZegoUIKitCore.shared.renewRoomToken(
      token,
      targetRoomID: targetRoomID ?? ZegoUIKitCore.shared.coreData.room.id,
    );
  }

  /// get room object
  ZegoUIKitRoom getRoom() {
    return ZegoUIKitCore.shared.coreData.room.toUIKitRoom();
  }

  /// get room state notifier
  ValueNotifier<ZegoUIKitRoomState> getRoomStateStream() {
    return ZegoUIKitCore.shared.coreData.room.state;
  }

  /// update one room property
  Future<bool> setRoomProperty(
    String key,
    String value, {
    String? targetRoomID,
  }) async {
    return ZegoUIKitCore.shared.setRoomProperty(
      key,
      value,
      targetRoomID: targetRoomID ?? ZegoUIKitCore.shared.coreData.room.id,
    );
  }

  /// update room properties
  Future<bool> updateRoomProperties(
    Map<String, String> properties, {
    String? targetRoomID,
  }) async {
    return ZegoUIKitCore.shared.updateRoomProperties(
      Map<String, String>.from(properties),
      targetRoomID: targetRoomID ?? ZegoUIKitCore.shared.coreData.room.id,
    );
  }

  /// get room properties
  Map<String, RoomProperty> getRoomProperties() {
    return Map<String, RoomProperty>.from(
        ZegoUIKitCore.shared.coreData.room.properties);
  }

  /// only notify the property which changed
  /// you can get full properties by getRoomProperties() function
  Stream<RoomProperty> getRoomPropertyStream() {
    return ZegoUIKitCore.shared.coreData.room.propertyUpdateStream?.stream ??
        const Stream.empty();
  }

  /// the room Token authentication is about to expire will be sent 30 seconds before the Token expires
  Stream<int> getRoomTokenExpiredStream() {
    return ZegoUIKitCore.shared.coreData.room.tokenExpiredStreamCtrl?.stream ??
        const Stream.empty();
  }

  /// only notify the properties which changed
  /// you can get full properties by getRoomProperties() function
  Stream<Map<String, RoomProperty>> getRoomPropertiesStream() {
    return ZegoUIKitCore.shared.coreData.room.propertiesUpdatedStream?.stream ??
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
