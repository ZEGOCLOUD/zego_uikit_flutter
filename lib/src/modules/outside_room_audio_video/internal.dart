// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_uikit/src/modules/outside_room_audio_video/defines.dart';
import 'package:zego_uikit/src/services/core/core.dart';
import 'package:zego_uikit/src/services/services.dart';

import '../../services/core/defines/defines.dart';

class ZegoOutsideRoomAudioVideoViewStream
    extends ZegoOutsideRoomAudioVideoViewStreamUser {
  /// stream is playing or not
  bool isPlaying = false;

  /// view can visible or not
  final isVisibleNotifier = ValueNotifier<bool>(false);

  ZegoOutsideRoomAudioVideoViewStream({
    required ZegoUIKitUser user,
    required String roomID,
  }) : super(user: user, roomID: roomID);

  String get targetStreamID {
    return generateStreamID(user.id, roomID, ZegoStreamType.main);
  }

  @override
  String toString() {
    return 'room id:$roomID, '
        'user id:${user.id}, '
        'isPlaying:$isPlaying, '
        'isVisible:${isVisibleNotifier.value}, ';
  }
}

class ZegoAudioVideoViewOutsideRoomID {
  static bool isRandomUserID(String userID) {
    RegExp regex = RegExp(r'^zg_t_u_[a-zA-Z0-9]{5}$');
    return regex.hasMatch(userID);
  }

  static bool isRandomRoomID(String roomID) {
    RegExp regex = RegExp(r'^zg_t_r_[a-zA-Z0-9]{5}$');
    return regex.hasMatch(roomID);
  }

  static String randomUserID() {
    return 'zg_t_u_${generateRandomID()}';
  }

  static String randomRoomID() {
    return 'zg_t_r_${generateRandomID()}';
  }

  static String generateRandomID() {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final Random rnd = Random();

    return String.fromCharCodes(
      Iterable.generate(
        5,
        (_) => chars.codeUnitAt(
          rnd.nextInt(chars.length),
        ),
      ),
    );
  }
}
