part of 'uikit_service.dart';

mixin ZegoUserService {
  /// login
  void login(String id, String name) {
    ZegoUIKitCore.shared.login(id, name);
  }

  /// logout
  void logout() {
    ZegoUIKitCore.shared.logout();
  }

  /// get local user
  ZegoUIKitUser getLocalUser() {
    return ZegoUIKitCore.shared.coreData.user.localUser.toZegoUikitUser();
  }

  /// get all users, include local user and remote users
  List<ZegoUIKitUser> getAllUsers({
    String? targetRoomID,
  }) {
    return [
      ZegoUIKitCore.shared.coreData.user.localUser,
      ...ZegoUIKitCore.shared.coreData.user.roomUsers
          .getRoom(targetRoomID ?? ZegoUIKitCore.shared.coreData.room.currentID)
          .remoteUsers
    ]
        .where((user) => !user.isAnotherRoomUser)
        .map((user) => user.toZegoUikitUser())
        .toList();
  }

  /// get remote users, not include local user
  List<ZegoUIKitUser> getRemoteUsers({
    String? targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.user.roomUsers
        .getRoom(targetRoomID ?? ZegoUIKitCore.shared.coreData.room.currentID)
        .remoteUsers
        .where((user) => !user.isAnotherRoomUser)
        .map((user) => user.toZegoUikitUser())
        .toList();
  }

  /// get user by user id
  ZegoUIKitUser getUser(
    String userID, {
    String? targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.user
        .getUser(
          userID,
          targetRoomID:
              targetRoomID ?? ZegoUIKitCore.shared.coreData.room.currentID,
        )
        .toZegoUikitUser();
  }

  /// get notifier of in-room user attributes
  ValueNotifier<ZegoUIKitUserAttributes> getInRoomUserAttributesNotifier(
    String userID, {
    String? targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.user
        .getUser(
          userID,
          targetRoomID:
              targetRoomID ?? ZegoUIKitCore.shared.coreData.room.currentID,
        )
        .inRoomAttributes;
  }

  /// get user list notifier
  Stream<List<ZegoUIKitUser>> getUserListStream({
    String? targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.user.roomUsers
            .getRoom(
              targetRoomID ?? ZegoUIKitCore.shared.coreData.room.currentID,
            )
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
    String? targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.user.roomUsers
            .getRoom(
                targetRoomID ?? ZegoUIKitCore.shared.coreData.room.currentID)
            .joinStreamCtrl
            ?.stream
            .map((users) => users.map((e) => e.toZegoUikitUser()).toList()) ??
        const Stream.empty();
  }

  /// get user leave notifier
  Stream<List<ZegoUIKitUser>> getUserLeaveStream({
    String? targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.user.roomUsers
            .getRoom(
                targetRoomID ?? ZegoUIKitCore.shared.coreData.room.currentID)
            .leaveStreamCtrl
            ?.stream
            .map((users) => users.map((e) => e.toZegoUikitUser()).toList()) ??
        const Stream.empty();
  }

  /// remove user from room, kick out
  Future<bool> removeUserFromRoom(
    List<String> userIDs, {
    String? targetRoomID,
  }) async {
    final resultErrorCode = await ZegoUIKitCore.shared.removeUserFromRoom(
      userIDs,
      targetRoomID:
          targetRoomID ?? ZegoUIKitCore.shared.coreData.room.currentID,
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
    String? targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.user.roomUsers
            .getRoom(
                targetRoomID ?? ZegoUIKitCore.shared.coreData.room.currentID)
            .meRemovedFromRoomStreamCtrl
            ?.stream ??
        const Stream.empty();
  }
}
