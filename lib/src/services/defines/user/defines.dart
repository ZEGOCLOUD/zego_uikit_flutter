// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/services/core/core.dart';
import 'package:zego_uikit/src/services/services.dart';
import 'package:zego_uikit/src/services/defines/device/device.dart';

import 'package:zego_uikit/src/services/core/defines/user_attributes.dart';
import 'package:zego_uikit/src/services/core/defines/user.dart';

extension ZegoUIKitUserList on List<ZegoUIKitUser> {
  String get ids => map((e) => e.id).toString();
}

class ZegoUIKitUser {
  String id = '';
  String name = '';

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory ZegoUIKitUser.fromJson(Map<String, dynamic> json) {
    return ZegoUIKitUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
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

  ValueNotifier<ZegoUIKitUserAttributes> get inRoomAttributes =>
      _tryGetUser.inRoomAttributes;

  String get streamID => _tryGetUser.mainChannel.streamID;

  int get streamTimestamp => _tryGetUser.mainChannel.streamTimestamp;

  ValueNotifier<ZegoUIKitAudioRoute?> get audioRoute => _tryGetUser.audioRoute;

  ZegoUIKitUser.empty();

  bool isEmpty() {
    return id.isEmpty;
  }

  ZegoUIKitUser({
    required this.id,
    required this.name,
  });

  // internal helper function
  ZegoUser toZegoUser() => ZegoUser(id, name);

  ZegoUIKitUser.fromZego(ZegoUser zegoUser)
      : this(
          id: zegoUser.userID,
          name: zegoUser.userName,
        );

  ZegoUIKitCoreUser get _tryGetUser {
    final user = ZegoUIKitCore.shared.coreData.getUser(id);
    if (user.isEmpty) {
      final mixerUser = ZegoUIKitCore.shared.coreData.getUserInMixerStream(id);
      return mixerUser.isEmpty ? user : mixerUser;
    }

    return user;
  }

  @override
  String toString() {
    return '{'
        'id:$id, '
        'name:$name, '
        'in-room attributes:${inRoomAttributes.value}, '
        'camera:${camera.value}, '
        'microphone:${microphone.value}, '
        '}';
  }

  String toMoreString() {
    return '{'
        'id:$id, '
        'name:$name, '
        'in-room attributes:${inRoomAttributes.value}, '
        'camera:${camera.value}, '
        'camera mute mode:${cameraMuteMode.value}, '
        'microphone:${microphone.value}, '
        'microphone mute mode:${microphoneMuteMode.value} '
        '}';
  }
}
