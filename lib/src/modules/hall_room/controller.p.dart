// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/modules/hall_room/config.dart';
import 'package:zego_uikit/src/modules/hall_room/controller.event.dart';
import 'package:zego_uikit/src/modules/hall_room/helper.dart';
import 'package:zego_uikit/src/modules/hall_room/defines.dart';
import 'package:zego_uikit/src/services/core/core.dart';
import 'package:zego_uikit/src/services/services.dart';

/// @nodoc
class ZegoUIKitHallRoomListControllerPrivate {
  ZegoUIKitHallRoomListControllerPrivate();

  int appID = 0;
  String appSign = '';
  String token = '';
  ZegoUIKitScenario scenario = ZegoUIKitScenario.Default;
  ZegoUIKitHallRoomListConfig config = const ZegoUIKitHallRoomListConfig();

  String get roomID {
    _tempRoomID ??= ZegoUIKitHallRoomIDHelper.randomRoomID();
    return _tempRoomID!;
  }

  ZegoUIKitUser get localUser {
    final tempUserID = ZegoUIKitHallRoomIDHelper.randomUserID();
    _tempUser ??= ZegoUIKitUser(
      id: tempUserID,
      name: tempUserID,
      roomID: roomID,
      isAnotherRoomUser: false,
    );

    return _tempUser!;
  }

  final updateNotifier = ValueNotifier<int>(0);
  final sdkInitNotifier = ValueNotifier<bool>(false);
  final roomLoginNotifier = ValueNotifier<bool>(false);
  final streamsNotifier =
      ValueNotifier<List<ZegoUIKitHallRoomListStreamUser>>([]);
  final event = ZegoUIKitHallRoomExpressEvent();

  String? _tempRoomID;
  ZegoUIKitUser? _tempUser;

  Future<bool> init() async {
    ZegoLoggerService.logInfo(
      '',
      tag: 'uikit.hall-room-controller',
      subTag: 'init',
    );

    return initSDK().then((_) async {
      /// After setting this, switching room (switchRoom) will not stop pulling streams (both RTC and CDN streams will not stop)
      await ZegoUIKit().enableSwitchRoomNotStopPlay(true);

      return await joinRoom();
    });
  }

  Future<bool> uninit() async {
    ZegoLoggerService.logInfo(
      '',
      tag: 'uikit.hall-room-controller',
      subTag: 'uninit',
    );

    /// Exited live hall
    await ZegoUIKit().enableSwitchRoomNotStopPlay(false);

    return stopPlayAll().then((_) async {
      return leaveRoom().then((_) async {
        return await uninitSDK();
      });
    });
  }

  void setData({
    required int appID,
    required String appSign,
    required String token,
    required ZegoUIKitScenario scenario,
    required ZegoUIKitHallRoomListConfig config,
  }) {
    this.appID = appID;
    this.appSign = appSign;
    this.token = token;
    this.scenario = scenario;
    this.config = config;

    /// Update stream status through stream events
    event.init(streamsNotifier: streamsNotifier);
    ZegoUIKit().registerExpressEvent(event);
  }

  void clearData() {
    ZegoLoggerService.logInfo(
      '',
      tag: 'uikit.hall-room-controller',
      subTag: 'clearData',
    );

    event.uninit();

    streamsNotifier.value = [];

    _tempRoomID = null;
    _tempUser = null;
    appID = 0;
    appSign = '';
    token = '';
    scenario = ZegoUIKitScenario.Default;

    sdkInitNotifier.value = false;
    roomLoginNotifier.value = false;
  }

  Future<bool> initSDK() async {
    if (ZegoUIKitCore.shared.isInit) {
      ZegoLoggerService.logInfo(
        'has already init',
        tag: 'uikit.hall-room-controller',
        subTag: 'initSDK',
      );

      ZegoUIKit().login(localUser.id, localUser.name);

      sdkInitNotifier.value = true;

      return true;
    }

    ZegoLoggerService.logInfo(
      'init',
      tag: 'uikit.hall-room-controller',
      subTag: 'initSDK',
    );

    return ZegoUIKit()
        .init(
      appID: appID,
      appSign: appSign,
      token: token,
      scenario: scenario,
    )
        .then((value) async {
      ZegoLoggerService.logInfo(
        'init done',
        tag: 'uikit.hall-room-controller',
        subTag: 'initSDK',
      );

      await ZegoUIKit().setVideoConfig(
        config.video ?? ZegoVideoConfigExtension.preset180P(),
      );

      sdkInitNotifier.value = true;

      return true;
    });
  }

  Future<bool> uninitSDK() async {
    ZegoUIKit().logout();

    return true;
  }

  /// Join the live streaming hall room
  ///
  /// Joins the hall room with a temporary user to enable viewing and managing
  /// the list of live rooms in the hall.
  Future<bool> joinRoom() async {
    if (!ZegoUIKitCore.shared.isInit) {
      ZegoLoggerService.logInfo(
        'has already init sdk',
        tag: 'uikit.hall-room-controller',
        subTag: 'join room',
      );

      return false;
    }

    if (ZegoUIKit().getRoom(targetRoomID: roomID).isLogin) {
      ZegoLoggerService.logInfo(
        'has already login',
        tag: 'uikit.hall-room-controller',
        subTag: 'join room',
      );

      return false;
    }

    ZegoLoggerService.logInfo(
      'try join room($roomID) with a temp user $localUser',
      tag: 'uikit.hall-room-controller',
      subTag: 'join room',
    );
    return ZegoUIKit().joinRoom(roomID, token: token).then((result) {
      ZegoLoggerService.logInfo(
        'join room result:${result.errorCode} ${result.extendedData}',
        tag: 'uikit.hall-room-controller',
        subTag: 'join room',
      );

      roomLoginNotifier.value = result.errorCode == 0;

      return result.errorCode == 0;
    });
  }

  Future<bool> leaveRoom() async {
    ZegoLoggerService.logInfo(
      'try leave room $roomID',
      tag: 'uikit.hall-room-controller',
      subTag: 'leave room',
    );

    if (!ZegoUIKit().getRoom(targetRoomID: roomID).isLogin) {
      ZegoLoggerService.logInfo(
        'room is not login room',
        tag: 'uikit.hall-room-controller',
        subTag: 'leave room',
      );

      roomLoginNotifier.value = false;
      return true;
    }

    return ZegoUIKit()
        .leaveRoom(targetRoomID: roomID)
        .then((ZegoRoomLogoutResult result) {
      ZegoLoggerService.logInfo(
        'leave room result:$result',
        tag: 'uikit.hall-room-controller',
        subTag: 'leave room',
      );

      roomLoginNotifier.value = result.errorCode == 0;
      return result.errorCode == 0;
    });
  }

  void forceUpdate() {
    updateNotifier.value = DateTime.now().millisecondsSinceEpoch;
  }

  Future<bool> playOnly({
    required List<ZegoUIKitHallRoomListStreamUser> streamUsers,
    required List<ZegoUIKitHallRoomListStreamUser> muteStreamUsers,
  }) async {
    if (!ZegoUIKitCore.shared.isInit) {
      ZegoLoggerService.logInfo(
        'has not init sdk',
        tag: 'uikit.hall-room-controller',
        subTag: 'playOnly',
      );

      return false;
    }

    if (!ZegoUIKit().getRoom(targetRoomID: roomID).isLogin) {
      ZegoLoggerService.logInfo(
        'has not login room',
        tag: 'uikit.hall-room-controller',
        subTag: 'playOnly',
      );

      return false;
    }

    /// Categorize
    final streamUserIDs = streamUsers.map((e) => e.user.id).toList();
    List<ZegoUIKitHallRoomListStreamUser> stopPlayingStreamUsers = [];
    List<ZegoUIKitHallRoomListStreamUser> startPlayingStreamUsers = streamUsers;
    for (var streamUser in streamsNotifier.value) {
      if (!streamUserIDs.contains(streamUser.user.id) && streamUser.isPlaying) {
        stopPlayingStreamUsers.add(streamUser);
      }

      if (streamUserIDs.contains(streamUser.user.id) && streamUser.isPlaying) {
        startPlayingStreamUsers.removeWhere((e) =>
            e.user.id == streamUser.user.id && e.roomID == streamUser.roomID);
      }
    }

    /// Stop pulling streams
    for (var streamUser in stopPlayingStreamUsers) {
      await playOne(streamUser: streamUser, toPlay: false, isMuted: false);
    }

    /// Pull streams
    final muteStreamUserIDs = muteStreamUsers.map((e) => e.user.id).toList();
    for (var streamUser in startPlayingStreamUsers) {
      await playOne(
        streamUser: streamUser,
        toPlay: true,
        isMuted: muteStreamUserIDs.contains(streamUser.user.id),
      );
    }

    return true;
  }

  Future<bool> playOne({
    required ZegoUIKitHallRoomListStreamUser streamUser,
    required bool toPlay,
    required bool isMuted,
  }) async {
    if (toPlay && streamUser.isPlaying) {
      ZegoLoggerService.logInfo(
        '${streamUser.streamID} is playing',
        tag: 'uikit.hall-room-controller',
        subTag: toPlay ? 'startPlayOne' : 'stopPlayOne',
      );

      await ZegoUIKit().muteUserAudio(
        streamUser.user.id,
        isMuted,
        targetRoomID: roomID,
      );

      return true;
    } else if (!toPlay && !streamUser.isPlaying) {
      ZegoLoggerService.logInfo(
        '${streamUser.streamID} is not playing',
        tag: 'uikit.hall-room-controller',
        subTag: toPlay ? 'startPlayOne' : 'stopPlayOne',
      );

      return true;
    }

    ZegoLoggerService.logInfo(
      'stream:$streamUser',
      tag: 'uikit.hall-room-controller',
      subTag: toPlay ? 'startPlayOne' : 'stopPlayOne',
    );

    /// Assign value first, then update based on status callback;
    /// prevents state anomalies caused by rapid API calls
    /// Will be updated later in ZegoUIKitHallRoomExpressEvent
    streamUser.isPlaying = toPlay;
    if (toPlay) {
      await ZegoUIKit().startPlayAnotherRoomAudioVideo(
        targetRoomID: roomID,
        streamUser.roomID,
        streamUser.user.id,
        userName: streamUser.user.name,

        /// Will copy to respective rooms later after entering
        playOnAnotherRoom: false,
      );
      streamsNotifier.value = [
        ...streamsNotifier.value,
        streamUser,
      ];
    } else {
      await ZegoUIKit().stopPlayAnotherRoomAudioVideo(
        targetRoomID: roomID,
        streamUser.user.id,
      );
      streamsNotifier.value.removeWhere((e) => e.isEqual(streamUser));
      streamsNotifier.value = [...streamsNotifier.value];
    }

    if (toPlay) {
      await ZegoUIKit().muteUserAudio(
        streamUser.user.id,
        isMuted,
        targetRoomID: roomID,
      );
    }

    return true;
  }

  Future<bool> stopPlayAll() async {
    if (!ZegoUIKitCore.shared.isInit) {
      ZegoLoggerService.logInfo(
        'has not init sdk',
        tag: 'uikit.hall-room-controller',
        subTag: 'playOnly',
      );

      return false;
    }

    if (!ZegoUIKit().getRoom(targetRoomID: roomID).isLogin) {
      ZegoLoggerService.logInfo(
        'has not login room',
        tag: 'uikit.hall-room-controller',
        subTag: 'playOnly',
      );

      return false;
    }

    for (var streamUser in List.from(streamsNotifier.value)) {
      await playOne(streamUser: streamUser, toPlay: false, isMuted: false);
    }
    streamsNotifier.value = [];

    return true;
  }
}
