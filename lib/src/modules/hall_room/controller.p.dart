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
import 'package:zego_uikit/src/modules/hall_room/defines.dart';
import 'package:zego_uikit/src/modules/hall_room/helper.dart';
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

  bool isInit = false;

  bool _uninitOnDispose = true;

  bool get uninitOnDispose => _uninitOnDispose;

  set uninitOnDispose(bool value) => _uninitOnDispose = value;

  String get roomID {
    _tempRoomID ??= ZegoUIKitHallRoomIDHelper.randomRoomID();
    return _tempRoomID!;
  }

  final updateNotifier = ValueNotifier<int>(0);
  final sdkInitNotifier = ValueNotifier<bool>(false);
  final roomLoginNotifier = ValueNotifier<bool>(false);
  final streamsNotifier =
      ValueNotifier<List<ZegoUIKitHallRoomListStreamUser>>([]);
  final event = ZegoUIKitHallRoomExpressEvent();

  String? _tempRoomID;
  ZegoUIKitUser? _localUser;

  Future<bool> init({
    required ZegoUIKitUser localUser,
  }) async {
    if (isInit) {
      ZegoLoggerService.logInfo(
        'had init',
        tag: 'uikit.hall-room-controller',
        subTag: 'init',
      );

      return true;
    }

    isInit = true;

    ZegoLoggerService.logInfo(
      'localUser:$localUser, ',
      tag: 'uikit.hall-room-controller',
      subTag: 'init',
    );

    _localUser = localUser;
    final tempUserID = ZegoUIKitHallRoomIDHelper.randomUserID();
    _localUser ??= ZegoUIKitUser(
      id: tempUserID,
      name: tempUserID,
      roomID: roomID,
      isAnotherRoomUser: false,
    );

    return initSDK().then((_) async {
      /// After setting this, switching room (switchRoom) will not stop pulling streams (both RTC and CDN streams will not stop)
      await ZegoUIKit().enableSwitchRoomNotStopPlay(true);

      return await joinRoom();
    });
  }

  Future<bool> uninit({
    bool needEnableSwitchRoomNotStopPlay = true,
    bool needStopPlayAll = true,
    bool needLeaveRoom = true,
    bool needUninitSDK = true,
  }) async {
    if (!isInit) {
      ZegoLoggerService.logInfo(
        'not init',
        tag: 'uikit.hall-room-controller',
        subTag: 'uninit',
      );

      return false;
    }

    isInit = false;

    ZegoLoggerService.logInfo(
      '',
      tag: 'uikit.hall-room-controller',
      subTag: 'uninit',
    );

    if (needEnableSwitchRoomNotStopPlay) {
      /// Exited live hall
      await ZegoUIKit().enableSwitchRoomNotStopPlay(false);
    }
    if (needStopPlayAll) {
      await stopPlayAll();
    }
    if (needLeaveRoom) {
      await leaveRoom();
    }
    if (needUninitSDK) {
      await uninitSDK();
    }

    return true;
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
    _localUser = null;
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

      ZegoUIKit().login(_localUser!.id, _localUser!.name);

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

    final anotherRoom = ZegoUIKit().getCurrentRoom(skipHallRoom: true);
    ZegoLoggerService.logInfo(
      'another room:$anotherRoom, ',
      tag: 'uikit.hall-room-controller',
      subTag: 'init',
    );
    if (anotherRoom.isLogin) {
      /// If entered from live hall, use live hall's exit live flow, which has optimizations
      /// todo: ignoreFilter only copy host's main
      await moveStreamToHall(ignoreFilter: (String streamID) {
        final streamType = ZegoUIKitStreamHelper.getStreamTypeByID(streamID);
        if (ZegoStreamType.main != streamType) {
          return false;
        }

        /// only copy host's main
        return false;
      });

      /// Switch back to live hall
      await ZegoUIKit().switchRoom(toRoomID: roomID);

      roomLoginNotifier.value = true;

      return true;
    } else {
      ZegoLoggerService.logInfo(
        'try join room($roomID) with user $_localUser',
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

      addToStreams(streamUser);

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

      removeFromStreams(streamUser);

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

      addToStreams(streamUser);
    } else {
      await ZegoUIKit().stopPlayAnotherRoomAudioVideo(
        targetRoomID: roomID,
        streamUser.user.id,
      );

      removeFromStreams(streamUser);
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

  void addToStreams(ZegoUIKitHallRoomListStreamUser streamUser) {
    if (-1 != streamsNotifier.value.indexWhere((e) => e.isEqual(streamUser))) {
      return;
    }

    streamsNotifier.value = [
      ...streamsNotifier.value,
      streamUser,
    ];
  }

  void removeFromStreams(ZegoUIKitHallRoomListStreamUser streamUser) {
    final index =
        streamsNotifier.value.indexWhere((e) => e.isEqual(streamUser));
    if (-1 == index) {
      return;
    }

    streamsNotifier.value.removeAt(index);
    streamsNotifier.value = [...streamsNotifier.value];
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

  Future<void> moveStreamToHall({
    bool Function(String)? ignoreFilter,
  }) async {
    ZegoLoggerService.logInfo(
      'streams:${streamsNotifier.value}',
      tag: 'uikit.hall-room-controller',
      subTag: 'moveStreamToHall',
    );

    /// Copy all currently existing live room hosts back to the hall room
    ZegoUIKitCore.shared.coreData.stream.roomStreams
        .forEachSync((anotherRoomID, anotherRoomStream) {
      if (anotherRoomID == roomID) {
        return;
      }

      final streamIDs = [
        ...anotherRoomStream.streamDicNotifier.value.keys,
        ...anotherRoomStream.mixerStreamDic.keys,
      ]..removeWhere((e) => ignoreFilter?.call(e) ?? false);

      ZegoUIKit().moveToAnotherRoom(
        fromRoomID: anotherRoomID,
        fromStreamIDs: streamIDs,
        toRoomID: roomID,

        /// Nominally becomes hall's own
        isFromAnotherRoom: false,
      );
    });
  }
}
