part of 'uikit_service.dart';

mixin ZegoUserService {
  /// login
  void login(String id, String name) {
    ZegoUIKitCore.shared.coreData.user.login(id, name);
  }

  /// logout
  void logout() {
    ZegoUIKitCore.shared.coreData.user.logout();
  }

  /// get local user
  ZegoUIKitUser getLocalUser() {
    return ZegoUIKitCore.shared.coreData.user.localUser.toZegoUikitUser();
  }

  /// get local user update notifier
  ValueNotifier<ZegoUIKitUser> getLocalUserNotifier() {
    return ZegoUIKitCore.shared.coreData.user.localZegoUserNotifier;
  }

  /// get all users, include local user and remote users
  List<ZegoUIKitUser> getAllUsers({
    required String targetRoomID,
  }) {
    assert(targetRoomID.isNotEmpty);
    return [
      ZegoUIKitCore.shared.coreData.user.localUser,
      ...ZegoUIKitCore.shared.coreData.user.roomUsers
          .getRoom(targetRoomID)
          .remoteUsers
    ]
        .where((user) => !user.isAnotherRoomUser)
        .map((user) => user.toZegoUikitUser())
        .toList();
  }

  /// get remote users, not include local user
  List<ZegoUIKitUser> getRemoteUsers({
    required String targetRoomID,
  }) {
    assert(targetRoomID.isNotEmpty);

    return ZegoUIKitCore.shared.coreData.user.roomUsers
        .getRoom(targetRoomID)
        .remoteUsers
        .where((user) => !user.isAnotherRoomUser)
        .map((user) => user.toZegoUikitUser())
        .toList();
  }

  /// get user by user id
  ZegoUIKitUser getUser(
    String userID, {
    required String targetRoomID,
  }) {
    assert(targetRoomID.isNotEmpty);
    return ZegoUIKitCore.shared.coreData.user
        .getUser(
          userID,
          targetRoomID: targetRoomID,
        )
        .toZegoUikitUser();
  }

  /// get notifier of in-room user attributes
  ValueNotifier<ZegoUIKitUserAttributes> getInRoomUserAttributesNotifier(
    String userID, {
    required String targetRoomID,
  }) {
    assert(targetRoomID.isNotEmpty);
    return ZegoUIKitCore.shared.coreData.user
        .getUser(
          userID,
          targetRoomID: targetRoomID,
        )
        .inRoomAttributes;
  }

  /// get user list notifier
  Stream<List<ZegoUIKitUser>> getUserListStream({
    required String targetRoomID,
  }) {
    assert(targetRoomID.isNotEmpty);
    return ZegoUIKitCore.shared.coreData.user.roomUsers
            .getRoom(targetRoomID)
            .listStreamCtrl
            ?.stream
            .map((users) => users
                .where((user) => !user.isAnotherRoomUser)
                .map((e) => e.toZegoUikitUser())
                .toList()) ??
        const Stream.empty();
  }

  /// get user join notifier
  Stream<List<ZegoUIKitUser>> getUserJoinStream({
    required String targetRoomID,
  }) {
    assert(targetRoomID.isNotEmpty);
    return ZegoUIKitCore.shared.coreData.user.roomUsers
            .getRoom(targetRoomID)
            .joinStreamCtrl
            ?.stream
            .map((users) => users.map((e) => e.toZegoUikitUser()).toList()) ??
        const Stream.empty();
  }

  /// get user leave notifier
  Stream<List<ZegoUIKitUser>> getUserLeaveStream({
    required String targetRoomID,
  }) {
    assert(targetRoomID.isNotEmpty);
    return ZegoUIKitCore.shared.coreData.user.roomUsers
            .getRoom(targetRoomID)
            .leaveStreamCtrl
            ?.stream
            .map((users) => users.map((e) => e.toZegoUikitUser()).toList()) ??
        const Stream.empty();
  }

  /// remove user from room, kick out
  Future<bool> removeUserFromRoom(
    List<String> userIDs, {
    required String targetRoomID,
  }) async {
    assert(targetRoomID.isNotEmpty);
    final resultErrorCode = await ZegoUIKitCore.shared.removeUserFromRoom(
      userIDs,
      targetRoomID: targetRoomID,
    );

    if (ZegoUIKitErrorCode.success != resultErrorCode) {
      ZegoUIKitCore.shared.coreData.error.errorStreamCtrl?.add(
        ZegoUIKitError(
          code: ZegoUIKitErrorCode.customCommandSendError,
          message:
              'remove user($userIDs) from room error:$resultErrorCode, ${ZegoUIKitErrorCode.expressErrorCodeDocumentTips}',
          method: 'removeUserFromRoom',
        ),
      );
    }

    return ZegoErrorCode.CommonSuccess == resultErrorCode;
  }

  /// get kicked out notifier
  Stream<String> getMeRemovedFromRoomStream({
    required String targetRoomID,
  }) {
    assert(targetRoomID.isNotEmpty);
    return ZegoUIKitCore.shared.coreData.user.roomUsers
            .getRoom(targetRoomID)
            .meRemovedFromRoomStreamCtrl
            ?.stream ??
        const Stream.empty();
  }
}
