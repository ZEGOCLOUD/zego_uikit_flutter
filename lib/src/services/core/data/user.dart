// Dart imports:
import 'dart:async';

// Project imports:
import 'package:zego_uikit/src/services/core/core.dart';
import 'package:zego_uikit/src/services/services.dart';
import 'package:zego_uikit/src/services/core/data/room_map.dart';

import '../defines/defines.dart';

mixin ZegoUIKitCoreDataUser {
  ZegoUIKitCoreUser localUser = ZegoUIKitCoreUser.localDefault();

  var multiRoomUserInfo =
      ZegoUIKitCoreRoomMap<ZegoUIKitCoreDataRoomUserInfo>((String roomID) {
    return ZegoUIKitCoreDataRoomUserInfo(roomID);
  });

  void initUser() {
    ZegoLoggerService.logInfo(
      'init user',
      tag: 'uikit-user',
      subTag: 'init',
    );

    multiRoomUserInfo.forEach((_, roomUserInfo) {
      roomUserInfo.init();
    });
  }

  void uninitUser() {
    ZegoLoggerService.logInfo(
      'uninit user',
      tag: 'uikit-user',
      subTag: 'uninit',
    );

    multiRoomUserInfo.forEach((_, roomUserInfo) {
      roomUserInfo.uninit();
    });
  }

  ZegoUIKitCoreUser getUser(
    String userID, {
    required String targetRoomID,
  }) {
    if (userID == localUser.id) {
      return localUser;
    } else {
      return multiRoomUserInfo.getRoom(targetRoomID).remoteUsersList.firstWhere(
            (user) => user.id == userID,
            orElse: ZegoUIKitCoreUser.empty,
          );
    }
  }

  ZegoUIKitCoreUser login(String id, String name) {
    ZegoLoggerService.logInfo(
      'id:"$id", name:$name',
      tag: 'uikit-user',
      subTag: 'login',
    );

    if (id.isEmpty || name.isEmpty) {
      ZegoLoggerService.logError(
        'params is not valid',
        tag: 'uikit-user',
        subTag: 'login',
      );
    }

    if (localUser.id == id && localUser.name == name) {
      ZegoLoggerService.logWarn(
        'user is same',
        tag: 'uikit-user',
        subTag: 'login',
      );

      return localUser;
    }

    if ((localUser.id.isNotEmpty && localUser.id != id) ||
        (localUser.name.isNotEmpty && localUser.name != name)) {
      ZegoLoggerService.logError(
        'already login, and not same user, auto logout...',
        tag: 'uikit-user',
        subTag: 'login',
      );
      logout();
    }

    ZegoLoggerService.logInfo(
      'login done',
      tag: 'uikit-user',
      subTag: 'login',
    );

    localUser
      ..id = id
      ..name = name;

    multiRoomUserInfo.forEach((roomID, roomUserInfo) {
      roomUserInfo.userJoinStreamCtrl?.add([localUser]);
      notifyUserListStreamControl(targetRoomID: roomID);
    });

    return localUser;
  }

  void logout() {
    ZegoLoggerService.logInfo(
      'logout',
      tag: 'uikit-user',
      subTag: 'logout',
    );

    localUser.clear();

    multiRoomUserInfo.forEach((roomID, roomUserInfo) {
      roomUserInfo.userLeaveStreamCtrl?.add([localUser]);
      roomUserInfo.userListStreamCtrl?.add(roomUserInfo.remoteUsersList);
    });
  }

  ZegoUIKitCoreUser removeUser(
    String userID, {
    required String targetRoomID,
  }) {
    final targetIndex = multiRoomUserInfo
        .getRoom(targetRoomID)
        .remoteUsersList
        .indexWhere((user) => userID == user.id);
    if (-1 == targetIndex) {
      return ZegoUIKitCoreUser.empty();
    }

    final targetUser = multiRoomUserInfo
        .getRoom(targetRoomID)
        .remoteUsersList
        .removeAt(targetIndex);
    if (targetUser.mainChannel.streamID.isNotEmpty) {
      ZegoUIKitCore.shared.coreData.stopPlayingStream(
        targetUser.mainChannel.streamID,
        targetRoomID: targetRoomID,
      );
    }
    if (targetUser.auxChannel.streamID.isNotEmpty) {
      ZegoUIKitCore.shared.coreData.stopPlayingStream(
        targetUser.auxChannel.streamID,
        targetRoomID: targetRoomID,
      );
    }
    if (targetUser.thirdChannel.streamID.isNotEmpty) {
      ZegoUIKitCore.shared.coreData.stopPlayingStream(
        targetUser.thirdChannel.streamID,
        targetRoomID: targetRoomID,
      );
    }

    if (ZegoUIKitCore.shared.coreData.media.ownerID == userID) {
      ZegoUIKitCore.shared.coreData.media.clear();
    }

    return targetUser;
  }

  void notifyUserListStreamControl({
    required String targetRoomID,
  }) {
    final roomInfo = multiRoomUserInfo.getRoom(targetRoomID);

    final allUserList = [localUser, ...roomInfo.remoteUsersList];
    roomInfo.userListStreamCtrl?.add(allUserList);
  }

  /// todo multi room
  ZegoUIKitCoreUser getUserInMixerStream(String userID) {
    final user = getMixerStreamUsers().firstWhere(
      (user) => user.id == userID,
      orElse: ZegoUIKitCoreUser.empty,
    );
    return user;
  }

  List<ZegoUIKitCoreUser> getMixerStreamUsers() {
    final users = <ZegoUIKitCoreUser>[];
    ZegoUIKitCore.shared.coreData.mixerStreamDic
        .forEach((key, mixerStreamInfo) {
      users.addAll(mixerStreamInfo.usersNotifier.value);
    });

    return users;
  }
}

class ZegoUIKitCoreDataRoomUserInfo {
  String roomID;
  ZegoUIKitCoreDataRoomUserInfo(this.roomID);

  final List<ZegoUIKitCoreUser> remoteUsersList = [];

  StreamController<List<ZegoUIKitCoreUser>>? get userJoinStreamCtrl {
    _userJoinStreamCtrl ??=
        StreamController<List<ZegoUIKitCoreUser>>.broadcast();
    return _userJoinStreamCtrl;
  }

  StreamController<List<ZegoUIKitCoreUser>>? get userLeaveStreamCtrl {
    _userLeaveStreamCtrl ??=
        StreamController<List<ZegoUIKitCoreUser>>.broadcast();
    return _userLeaveStreamCtrl;
  }

  StreamController<List<ZegoUIKitCoreUser>>? get userListStreamCtrl {
    _userListStreamCtrl ??=
        StreamController<List<ZegoUIKitCoreUser>>.broadcast();
    return _userListStreamCtrl;
  }

  /// local user been kick-out by some reason
  StreamController<String>? get meRemovedFromRoomStreamCtrl {
    _meRemovedFromRoomStreamCtrl ??= StreamController<String>.broadcast();
    return _meRemovedFromRoomStreamCtrl;
  }

  void init() {
    ZegoLoggerService.logInfo(
      'room id:$roomID',
      tag: 'uikit-room-user-info',
      subTag: 'init',
    );

    _userJoinStreamCtrl ??=
        StreamController<List<ZegoUIKitCoreUser>>.broadcast();
    _userLeaveStreamCtrl ??=
        StreamController<List<ZegoUIKitCoreUser>>.broadcast();
    _userListStreamCtrl ??=
        StreamController<List<ZegoUIKitCoreUser>>.broadcast();
    _meRemovedFromRoomStreamCtrl ??= StreamController<String>.broadcast();
  }

  void uninit() {
    ZegoLoggerService.logInfo(
      'room id:$roomID',
      tag: 'uikit-room-user-info',
      subTag: 'uninit',
    );

    _userJoinStreamCtrl?.close();
    _userJoinStreamCtrl = null;

    _userLeaveStreamCtrl?.close();
    _userLeaveStreamCtrl = null;

    _userListStreamCtrl?.close();
    _userListStreamCtrl = null;

    _meRemovedFromRoomStreamCtrl?.close();
    _meRemovedFromRoomStreamCtrl = null;
  }

  void clear() {
    ZegoLoggerService.logInfo(
      'room id:$roomID',
      tag: 'uikit-room-user-info',
      subTag: 'clear',
    );
  }

  StreamController<List<ZegoUIKitCoreUser>>? _userJoinStreamCtrl;
  StreamController<List<ZegoUIKitCoreUser>>? _userLeaveStreamCtrl;
  StreamController<List<ZegoUIKitCoreUser>>? _userListStreamCtrl;
  StreamController<String>? _meRemovedFromRoomStreamCtrl;
}
