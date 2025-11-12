// Dart imports:
import 'dart:async';

// Project imports:
import 'package:flutter/cupertino.dart';
import 'package:zego_uikit/src/services/core/core.dart';
import 'package:zego_uikit/src/services/services.dart';
import '../defines/defines.dart';

import 'user.room.dart';
import 'room_map.dart';

class ZegoUIKitCoreDataUser {
  ZegoUIKitCoreUser localUser = ZegoUIKitCoreUser.localDefault();
  final localZegoUserNotifier =
      ValueNotifier<ZegoUIKitUser>(ZegoUIKitUser.empty());

  var roomUsers = ZegoUIKitCoreRoomMap<ZegoUIKitCoreDataRoomUser>(
    name: 'core data user',
    createDefault: (String roomID) {
      final roomUser = ZegoUIKitCoreDataRoomUser(roomID);
      roomUser.init();
      return roomUser;
    },
    onUpgradeEmptyRoom: (ZegoUIKitCoreDataRoomUser emptyRoomUser, roomID) {
      // 当预备房间被升级时，更新其 roomID
      emptyRoomUser.roomID = roomID;
      ZegoLoggerService.logInfo(
        'empty room(${emptyRoomUser.hashCode}) has update id to $roomID, ',
        tag: 'uikit-users',
        subTag: 'room-map',
      );
    },
  );

  void init() {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'uikit-users',
      subTag: 'init',
    );

    roomUsers.forEachSync((_, roomUserInfo) {
      roomUserInfo.init();
    });
  }

  void uninit() {
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'uikit-users',
      subTag: 'uninit',
    );

    roomUsers.forEachSync((_, roomUserInfo) {
      roomUserInfo.uninit();
    });
  }

  void clear({
    required String targetRoomID,
  }) {
    ZegoLoggerService.logInfo(
      'clear, '
      'room id:$targetRoomID, ',
      tag: 'uikit-users',
      subTag: 'uninit',
    );

    if (roomUsers.containsRoom(targetRoomID)) {
      roomUsers.getRoom(targetRoomID).remoteUsers.clear();
    }
  }

  ZegoUIKitCoreUser getUser(
    String userID, {
    required String targetRoomID,
  }) {
    if (userID.isEmpty || userID == localUser.id) {
      return localUser;
    } else {
      return roomUsers.getRoom(targetRoomID).remoteUsers.firstWhere(
            (user) => user.id == userID,
            orElse: ZegoUIKitCoreUser.empty,
          );
    }
  }

  ZegoUIKitCoreUser login(String id, String name) {
    ZegoLoggerService.logInfo(
      'id:"$id", name:$name',
      tag: 'uikit-users',
      subTag: 'login',
    );

    if (id.isEmpty || name.isEmpty) {
      ZegoLoggerService.logError(
        'params is not valid',
        tag: 'uikit-users',
        subTag: 'login',
      );
    }

    if (localUser.id == id && localUser.name == name) {
      ZegoLoggerService.logWarn(
        'user is same',
        tag: 'uikit-users',
        subTag: 'login',
      );

      return localUser;
    }

    if ((localUser.id.isNotEmpty && localUser.id != id) ||
        (localUser.name.isNotEmpty && localUser.name != name)) {
      ZegoLoggerService.logError(
        'already login, and not same user, auto logout...',
        tag: 'uikit-users',
        subTag: 'login',
      );
      logout();
    }

    ZegoLoggerService.logInfo(
      'login done',
      tag: 'uikit-users',
      subTag: 'login',
    );

    localUser
      ..id = id
      ..name = name;
    localZegoUserNotifier.value = localUser.toZegoUikitUser();

    roomUsers.forEachSync((roomID, roomUserInfo) {
      roomUserInfo.joinStreamCtrl?.add([localUser]);
      notifyUserListStreamControl(targetRoomID: roomID);
    });

    return localUser;
  }

  void logout() {
    ZegoLoggerService.logInfo(
      'logout',
      tag: 'uikit-users',
      subTag: 'logout',
    );

    localUser.clear();
    localZegoUserNotifier.value = localUser.toZegoUikitUser();

    roomUsers.forEachSync((roomID, roomUserInfo) {
      roomUserInfo.leaveStreamCtrl?.add([localUser]);
      roomUserInfo.listStreamCtrl?.add(roomUserInfo.remoteUsers);
    });
  }

  ZegoUIKitCoreUser removeUser(
    String userID, {
    required String targetRoomID,
  }) {
    final targetIndex = roomUsers
        .getRoom(targetRoomID)
        .remoteUsers
        .indexWhere((user) => userID == user.id);
    if (-1 == targetIndex) {
      return ZegoUIKitCoreUser.empty();
    }

    final roomStream = ZegoUIKitCore.shared.coreData.stream.roomStreams.getRoom(
      targetRoomID,
    );
    final targetUser =
        roomUsers.getRoom(targetRoomID).remoteUsers.removeAt(targetIndex);
    if (targetUser.mainChannel.streamID.isNotEmpty) {
      roomStream.stopPlayingStream(
        targetUser.mainChannel.streamID,
      );
    }
    if (targetUser.auxChannel.streamID.isNotEmpty) {
      roomStream.stopPlayingStream(
        targetUser.auxChannel.streamID,
      );
    }
    if (targetUser.thirdChannel.streamID.isNotEmpty) {
      roomStream.stopPlayingStream(
        targetUser.thirdChannel.streamID,
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
    final roomInfo = roomUsers.getRoom(targetRoomID);

    final allUserList = [localUser, ...roomInfo.remoteUsers];
    roomInfo.listStreamCtrl?.add(allUserList);
  }

  ZegoUIKitCoreUser getUserInMixerStream(
    String userID, {
    required String targetRoomID,
  }) {
    final user = getMixerStreamUsers(
      targetRoomID: targetRoomID,
    ).firstWhere(
      (user) => user.id == userID,
      orElse: ZegoUIKitCoreUser.empty,
    );
    return user;
  }

  List<ZegoUIKitCoreUser> getMixerStreamUsers({
    required String targetRoomID,
  }) {
    final roomStream =
        ZegoUIKitCore.shared.coreData.stream.roomStreams.getRoom(targetRoomID);

    final users = <ZegoUIKitCoreUser>[];
    roomStream.mixerStreamDic.forEach((key, mixerStreamInfo) {
      users.addAll(mixerStreamInfo.usersNotifier.value);
    });

    return users;
  }
}
