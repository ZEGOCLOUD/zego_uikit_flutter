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
import 'package:zego_uikit/src/modules/hall_room/internal.dart';
import 'package:zego_uikit/src/services/core/core.dart';
import 'package:zego_uikit/src/services/services.dart';

/// @nodoc
class ZegoUIKitHallRoomListControllerPrivate {
  String get roomID {
    _tempRoomID ??= ZegoUIKitHallRoomIDHelper.randomRoomID();
    return _tempRoomID!;
  }

  ZegoUIKitUser get localUser {
    final tempUserID = ZegoUIKitHallRoomIDHelper.randomUserID();
    _tempUser ??= ZegoUIKitUser(
      id: tempUserID,
      name: tempUserID,
    );

    return _tempUser!;
  }

  final updateNotifier = ValueNotifier<int>(0);
  final sdkInitNotifier = ValueNotifier<bool>(false);
  final roomLoginNotifier = ValueNotifier<bool>(false);

  List<ZegoUIKitHallRoomListStream> previousStreams = [];
  final streamsNotifier = ValueNotifier<List<ZegoUIKitHallRoomListStream>>([]);
  final event = ZegoUIKitHallRoomExpressEvent();

  String? _tempRoomID;
  ZegoUIKitUser? _tempUser;

  int _appID = 0;
  String _appSign = '';
  String _token = '';
  ZegoScenario _scenario = ZegoScenario.Default;
  ZegoUIKitHallRoomListConfig _config = const ZegoUIKitHallRoomListConfig();

  Future<bool> init() async {
    return initSDK().then((_) async {
      /// audio should not be played
      ZegoUIKit().muteAllRemoteAudio(targetRoomID: roomID);

      return await joinRoom().then((result) {
        onStreamsUpdated();
        streamsNotifier.addListener(onStreamsUpdated);

        /// todo remove timer
        // renderTimer ??= startRenderTimer();

        return result;
      });
    });
  }

  Future<bool> uninit() async {
    for (var stream in previousStreams) {
      stream.isVisibleNotifier.removeListener(onStreamVisibleStateUpdate);
    }
    previousStreams.clear();
    streamsNotifier.removeListener(onStreamsUpdated);

    return playAll(isPlay: false).then((_) async {
      return leaveRoom().then((_) async {
        /// restore audio state to not muted
        ZegoUIKit().unmuteAllRemoteAudio(targetRoomID: roomID);

        return await uninitSDK();
      });
    });
  }

  void setData({
    required int appID,
    required String appSign,
    required String token,
    required ZegoScenario scenario,
    required ZegoUIKitHallRoomListConfig config,
  }) {
    _appID = appID;
    _appSign = appSign;
    _token = token;
    _scenario = scenario;
    _config = config;

    event.init(streamsNotifier: streamsNotifier);
    ZegoUIKit().registerExpressEvent(event);
  }

  void clearData() {
    event.uninit();

    streamsNotifier.value = [];

    _tempRoomID = null;
    _tempUser = null;
    _appID = 0;
    _appSign = '';
    _token = '';
    _scenario = ZegoScenario.Default;

    sdkInitNotifier.value = false;
    roomLoginNotifier.value = false;
  }

  Future<bool> initSDK() async {
    if (ZegoUIKitCore.shared.isInit) {
      ZegoLoggerService.logInfo(
        'has already init',
        tag: 'hall controller',
        subTag: 'initSDK',
      );

      ZegoUIKit().login(localUser.id, localUser.name);

      sdkInitNotifier.value = true;

      return true;
    }

    ZegoLoggerService.logInfo(
      'init',
      tag: 'hall controller',
      subTag: 'initSDK',
    );

    return ZegoUIKit()
        .init(
      appID: _appID,
      appSign: _appSign,
      token: _token,
      scenario: _scenario,

      /// todo: multi mode
      // roomMode: ZegoRoomMode.MultiRoom,
    )
        .then((value) async {
      ZegoLoggerService.logInfo(
        'init done',
        tag: 'hall controller',
        subTag: 'initSDK',
      );

      await ZegoUIKit().setVideoConfig(
        _config.video ?? ZegoVideoConfigExtension.preset180P(),
      );

      sdkInitNotifier.value = true;

      return true;
    });
  }

  Future<bool> uninitSDK() async {
    ZegoUIKit().logout();

    return true;
  }

  Future<bool> joinRoom() async {
    if (!ZegoUIKitCore.shared.isInit) {
      ZegoLoggerService.logInfo(
        'has already init sdk',
        tag: 'hall controller',
        subTag: 'joinRoom',
      );

      return false;
    }

    if (ZegoUIKit().getRoom(targetRoomID: roomID).isLogin) {
      ZegoLoggerService.logInfo(
        'has already login',
        tag: 'hall controller',
        subTag: 'joinRoom',
      );

      return false;
    }

    ZegoLoggerService.logInfo(
      'try join room($roomID) with a temp user $localUser',
      tag: 'hall controller',
      subTag: 'joinRoom',
    );
    return ZegoUIKit().joinRoom(roomID, token: _token).then((result) {
      ZegoLoggerService.logInfo(
        'join room result:${result.errorCode} ${result.extendedData}',
        tag: 'hall controller',
        subTag: 'loginRoom',
      );

      roomLoginNotifier.value = result.errorCode == 0;

      return result.errorCode == 0;
    });
  }

  Future<bool> leaveRoom() async {
    ZegoLoggerService.logInfo(
      'try leave room $roomID',
      tag: 'hall controller',
      subTag: 'leaveRoom',
    );

    if (!ZegoUIKit().getRoom(targetRoomID: roomID).isLogin) {
      ZegoLoggerService.logInfo(
        'room is not login room',
        tag: 'hall controller',
        subTag: 'leaveRoom',
      );

      roomLoginNotifier.value = false;
      return true;
    }

    return ZegoUIKit()
        .leaveRoom(targetRoomID: roomID)
        .then((ZegoRoomLogoutResult result) {
      ZegoLoggerService.logInfo(
        'leave room result:$result',
        tag: 'hall controller',
        subTag: 'leaveRoom',
      );

      roomLoginNotifier.value = result.errorCode == 0;
      return result.errorCode == 0;
    });
  }

  Future<bool> playAll({required bool isPlay}) async {
    if (!ZegoUIKitCore.shared.isInit) {
      ZegoLoggerService.logInfo(
        'has not init sdk',
        tag: 'hall controller',
        subTag: isPlay ? 'startPlayAll' : 'stopPlayAll',
      );

      return false;
    }

    if (!ZegoUIKit().getRoom(targetRoomID: roomID).isLogin) {
      ZegoLoggerService.logInfo(
        'has not login room',
        tag: 'hall controller',
        subTag: isPlay ? 'startPlayAll' : 'stopPlayAll',
      );

      return false;
    }

    for (var streamInfo in streamsNotifier.value) {
      if (isPlay && streamInfo.isPlaying) {
        ZegoLoggerService.logInfo(
          '${streamInfo.targetStreamID} is playing',
          tag: 'hall controller',
          subTag: isPlay ? 'startPlayAll' : 'stopPlayAll',
        );

        continue;
      } else if (!isPlay && !streamInfo.isPlaying) {
        ZegoLoggerService.logInfo(
          '${streamInfo.targetStreamID} is not playing',
          tag: 'hall controller',
          subTag: isPlay ? 'startPlayAll' : 'stopPlayAll',
        );

        continue;
      }

      ZegoLoggerService.logInfo(
        'stream id:${streamInfo.targetStreamID}',
        tag: 'hall controller',
        subTag: isPlay ? 'startPlayAll' : 'stopPlayAll',
      );

      streamInfo.isPlaying = isPlay;
      isPlay
          ? await ZegoUIKit().startPlayAnotherRoomAudioVideo(
              targetRoomID: roomID,
              streamInfo.roomID,
              streamInfo.user.id,
              userName: streamInfo.user.name,
            )
          : await ZegoUIKit().stopPlayAnotherRoomAudioVideo(
              targetRoomID: roomID,
              streamInfo.user.id,
            );
    }

    return true;
  }

  Future<bool> playOne({
    required ZegoUIKitUser user,
    required String roomID,
    required bool toPlay,
    bool withLog = true,
  }) async {
    if (!ZegoUIKitCore.shared.isInit) {
      if (withLog) {
        ZegoLoggerService.logInfo(
          'has not init sdk',
          tag: 'hall controller',
          subTag: toPlay ? 'startPlayOne' : 'stopPlayOne',
        );
      }

      return false;
    }

    if (!ZegoUIKit().getRoom(targetRoomID: roomID).isLogin) {
      if (withLog) {
        ZegoLoggerService.logInfo(
          'has not login room',
          tag: 'hall controller',
          subTag: toPlay ? 'startPlayOne' : 'stopPlayOne',
        );
      }

      return false;
    }

    final queryIndex = streamsNotifier.value.indexWhere((streamInfo) =>
        streamInfo.user.id == user.id && streamInfo.roomID == roomID);
    if (-1 == queryIndex) {
      if (withLog) {
        ZegoLoggerService.logInfo(
          'user not exist',
          tag: 'hall controller',
          subTag: toPlay ? 'startPlayOne' : 'stopPlayOne',
        );
      }

      return false;
    }

    final streamInfo = streamsNotifier.value[queryIndex];

    if (toPlay && streamInfo.isPlaying) {
      if (withLog) {
        ZegoLoggerService.logInfo(
          '${streamInfo.targetStreamID} is playing',
          tag: 'hall controller',
          subTag: toPlay ? 'startPlayOne' : 'stopPlayOne',
        );
      }

      return false;
    } else if (!toPlay && !streamInfo.isPlaying) {
      if (withLog) {
        ZegoLoggerService.logInfo(
          '${streamInfo.targetStreamID} is not playing',
          tag: 'hall controller',
          subTag: toPlay ? 'startPlayOne' : 'stopPlayOne',
        );
      }

      return false;
    }

    ZegoLoggerService.logInfo(
      'stream id:${streamInfo.targetStreamID}',
      tag: 'hall controller',
      subTag: toPlay ? 'startPlayOne' : 'stopPlayOne',
    );

    streamInfo.isPlaying = toPlay;
    toPlay
        ? await ZegoUIKit().startPlayAnotherRoomAudioVideo(
            targetRoomID: roomID,
            streamInfo.roomID,
            streamInfo.user.id,
            userName: streamInfo.user.name,
          )
        : await ZegoUIKit().stopPlayAnotherRoomAudioVideo(
            targetRoomID: roomID,
            streamInfo.user.id,
          );

    return true;
  }

  void forceUpdate() {
    updateNotifier.value = DateTime.now().millisecondsSinceEpoch;
  }

  void onStreamsUpdated() {
    for (var stream in previousStreams) {
      stream.isVisibleNotifier.removeListener(onStreamVisibleStateUpdate);
    }
    previousStreams.clear();

    for (var stream in streamsNotifier.value) {
      stream.isVisibleNotifier.addListener(onStreamVisibleStateUpdate);
    }
    onStreamVisibleStateUpdate();
    previousStreams =
        List<ZegoUIKitHallRoomListStream>.from(streamsNotifier.value);
  }

  Future<void> onStreamVisibleStateUpdate() async {
    if (ZegoUIKitHallRoomListPlayMode.autoPlay == _config.playMode) {
      for (final stream in streamsNotifier.value) {
        await playOne(
          user: stream.user,
          roomID: stream.roomID,
          toPlay: stream.isVisibleNotifier.value,
          withLog: false,
        );
      }
    }
  }
}
