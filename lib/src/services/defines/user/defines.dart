// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/services/core/core.dart';
import 'package:zego_uikit/src/services/core/defines/user.dart';
import 'package:zego_uikit/src/services/core/defines/user_attributes.dart';
import 'package:zego_uikit/src/services/services.dart';

extension ZegoUIKitUserList on List<ZegoUIKitUser> {
  String get ids => map((e) => e.id).toString();
}

class ZegoUIKitUser {
  String id = '';
  String name = '';
  String roomID = '';
  bool isAnotherRoomUser = false;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'room_id': roomID,
        'another_room': isAnotherRoomUser
      };

  factory ZegoUIKitUser.fromJson(Map<String, dynamic> json) {
    return ZegoUIKitUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      roomID: json['room_id'] ?? '',
      isAnotherRoomUser: json['another_room'] ?? false,
    );
  }

  ValueNotifier<bool> get microphone => _tryGetUser.microphone;

  ValueNotifier<bool> get microphoneMuteMode => _tryGetUser.microphoneMuteMode;

  ValueNotifier<ZegoUIKitDeviceException?> get microphoneException =>
      _tryGetUser.microphoneException;

  ValueNotifier<bool> get camera => _tryGetUser.camera;

  ValueNotifier<bool> get cameraMuteMode => _tryGetUser.cameraMuteMode;

  ValueNotifier<ZegoUIKitDeviceException?> get cameraException =>
      _tryGetUser.cameraException;

  Stream<double> get soundLevel =>
      _tryGetUser.mainChannel.soundLevelStream?.stream ?? const Stream.empty();

  StreamController<double>? get soundLevelStreamController =>
      _tryGetUser.mainChannel.soundLevelStream;

  Stream<double> get auxSoundLevel =>
      _tryGetUser.auxChannel.soundLevelStream?.stream ?? const Stream.empty();

  ValueNotifier<ZegoUIKitPlayerState> get playerState =>
      _tryGetUser.mainChannel.playerStateNotifier;

  ValueNotifier<ZegoUIKitPlayerState> get auxPlayerState =>
      _tryGetUser.auxChannel.playerStateNotifier;

  ValueNotifier<ZegoUIKitUserAttributes> get inRoomAttributes =>
      _tryGetUser.inRoomAttributes;

  String get streamID => _tryGetUser.mainChannel.streamID;

  int get streamTimestamp => _tryGetUser.mainChannel.streamTimestamp;

  ValueNotifier<ZegoUIKitAudioRoute?> get audioRoute => _tryGetUser.audioRoute;

  ZegoUIKitUser.empty();

  bool isEmpty() {
    return id.isEmpty;
  }

  bool get isNotEmpty => !isEmpty();

  ZegoUIKitUser({
    required this.id,
    required this.name,
    this.roomID = '',
    this.isAnotherRoomUser = false,
  });

  // internal helper function
  ZegoUser toZegoUser() => ZegoUser(id, name);

  ZegoUIKitUser.fromZego(ZegoUser zegoUser, String roomID, bool fromAnotherRoom)
      : this(
          id: zegoUser.userID,
          name: zegoUser.userName,
          roomID: roomID,
          isAnotherRoomUser: fromAnotherRoom,
        );

  ZegoUIKitCoreUser get _tryGetUser {
    final user = ZegoUIKitCore.shared.coreData.user.getUser(
      id,
      targetRoomID: roomID.isEmpty
          ? ZegoUIKitCore.shared.coreData.room.currentID
          : roomID,
    );
    if (user.isEmpty) {
      final mixerUser = ZegoUIKitCore.shared.coreData.user.getUserInMixerStream(
        id,
        targetRoomID: roomID.isEmpty
            ? ZegoUIKitCore.shared.coreData.room.currentID
            : roomID,
      );
      return mixerUser.isEmpty ? user : mixerUser;
    }

    return user;
  }

  @override
  String toString() {
    return '{'
        'id:$id, '
        'name:$name, '
        'isAnotherRoom:$isAnotherRoomUser, '
        'camera:${camera.value}, '
        'microphone:${microphone.value}, '
        '}';
  }

  String toMoreString() {
    return '{'
        'id:$id, '
        'name:$name, '
        'isAnotherRoomUser:$isAnotherRoomUser, '
        'in-room attributes:${inRoomAttributes.value}, '
        'camera:${camera.value}, '
        'camera mute mode:${cameraMuteMode.value}, '
        'microphone:${microphone.value}, '
        'microphone mute mode:${microphoneMuteMode.value} '
        '}';
  }
}
