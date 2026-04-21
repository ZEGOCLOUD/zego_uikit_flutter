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
    return ZegoUIKitCore.shared.coreData.localUser.toZegoUikitUser();
  }

  /// get all users, include local user and remote users
  List<ZegoUIKitUser> getAllUsers() {
    return [
      ZegoUIKitCore.shared.coreData.localUser,
      ...ZegoUIKitCore.shared.coreData.remoteUsersList
    ]
        .where((user) => !user.isAnotherRoomUser)
        .map((user) => user.toZegoUikitUser())
        .toList();
  }

  /// get remote users, not include local user
  List<ZegoUIKitUser> getRemoteUsers() {
    return ZegoUIKitCore.shared.coreData.remoteUsersList
        .where((user) => !user.isAnotherRoomUser)
        .map((user) => user.toZegoUikitUser())
        .toList();
  }
  /// get leave users which are not in room any more, not include local user
  List<ZegoUIKitUser> getLeaveUsers() {
    ZegoLoggerService.logInfo(
      'get leave users, leave users:${ZegoUIKitCore.shared.coreData.leaveUsersList}',
      tag: 'uikit-user',
      subTag: 'getLeaveUsers',
    );
    return ZegoUIKitCore.shared.coreData.leaveUsersList
        .where((user) => !user.isAnotherRoomUser)
        .map((user) => user.toZegoUikitUser())
        .toList();
  }

  /// get leave users cache for the specified room
  Future<List<ZegoUIKitUser>> getLeaveUsersCache(String roomID) async {
    final userIDs = await ZegoUIKitUserCache().getLeaveUsers(roomID);
    return userIDs.map((id) => ZegoUIKitUser(id: id, name: '')).toList();
  }

  /// clear leave users cache for the specified room
  Future<void> clearLeaveUsersCache(String roomID) async {
    await ZegoUIKitUserCache().clearLeaveUsers(roomID);
  }

  /// get user by user id
  ZegoUIKitUser getUser(String userID) {
    return ZegoUIKitCore.shared.coreData.getUser(userID).toZegoUikitUser();
  }

  /// get notifier of in-room user attributes
  ValueNotifier<ZegoUIKitUserAttributes> getInRoomUserAttributesNotifier(
      String userID) {
    return ZegoUIKitCore.shared.coreData.getUser(userID).inRoomAttributes;
  }

  /// get user list notifier
  Stream<List<ZegoUIKitUser>> getUserListStream() {
    return ZegoUIKitCore.shared.coreData.userListStreamCtrl?.stream.map(
            (users) => users
                .where((user) => !user.isAnotherRoomUser)
                .map((e) => e.toZegoUikitUser())
                .toList()) ??
        const Stream.empty();
  }

  /// get user join notifier
  Stream<List<ZegoUIKitUser>> getUserJoinStream() {
    return ZegoUIKitCore.shared.coreData.userJoinStreamCtrl?.stream
            .map((users) => users.map((e) => e.toZegoUikitUser()).toList()) ??
        const Stream.empty();
  }

  /// get user leave notifier
  Stream<List<ZegoUIKitUser>> getUserLeaveStream() {
    return ZegoUIKitCore.shared.coreData.userLeaveStreamCtrl?.stream
            .map((users) => users.map((e) => e.toZegoUikitUser()).toList()) ??
        const Stream.empty();
  }

  /// remove user from room, kick out
  Future<bool> removeUserFromRoom(List<String> userIDs) async {
    final resultErrorCode =
        await ZegoUIKitCore.shared.removeUserFromRoom(userIDs);

    if (ZegoUIKitErrorCode.success != resultErrorCode) {
      ZegoUIKitCore.shared.error.errorStreamCtrl?.add(
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
  Stream<String> getMeRemovedFromRoomStream() {
    return ZegoUIKitCore.shared.coreData.meRemovedFromRoomStreamCtrl?.stream ??
        const Stream.empty();
  }
}
