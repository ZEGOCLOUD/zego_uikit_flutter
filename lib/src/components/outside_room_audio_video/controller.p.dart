// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/components/outside_room_audio_video/config.dart';
import 'package:zego_uikit/src/components/outside_room_audio_video/controller.event.dart';
import 'package:zego_uikit/src/components/outside_room_audio_video/internal.dart';
import 'package:zego_uikit/src/services/internal/core/core.dart';
import 'package:zego_uikit/src/services/services.dart';

/// @nodoc
class ZegoOutsideRoomAudioVideoViewControllerPrivate {
  String get roomID {
    _tempRoomID ??= ZegoAudioVideoViewOutsideRoomID.randomRoomID();
    return _tempRoomID!;
  }

  ZegoUIKitUser get localUser {
    final tempUserID = ZegoAudioVideoViewOutsideRoomID.randomUserID();
    _tempUser ??= ZegoUIKitUser(
      id: tempUserID,
      name: tempUserID,
    );

    return _tempUser!;
  }

  final updateNotifier = ValueNotifier<int>(0);
  final sdkInitNotifier = ValueNotifier<bool>(false);
  final roomLoginNotifier = ValueNotifier<bool>(false);

  List<ZegoOutsideRoomAudioVideoViewStream> previousStreams = [];
  final streamsNotifier =
      ValueNotifier<List<ZegoOutsideRoomAudioVideoViewStream>>([]);
  final event = ZegoOutsideRoomAudioVideoViewExpressEvent();

  String? _tempRoomID;
  ZegoUIKitUser? _tempUser;

  int _appID = 0;
  String _appSign = '';
  String _token = '';
  ZegoScenario _scenario = ZegoScenario.Default;
  ZegoOutsideRoomAudioVideoViewListConfig _config =
      const ZegoOutsideRoomAudioVideoViewListConfig();

  Future<bool> init() async {
    return initSDK().then((_) async {
      /// audio should not be played
      ZegoUIKit().stopPlayAllAudio();

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
        ZegoUIKit().startPlayAllAudio();

        return await uninitSDK();
      });
    });
  }

  void setData({
    required int appID,
    required String appSign,
    required String token,
    required ZegoScenario scenario,
    required ZegoOutsideRoomAudioVideoViewListConfig config,
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
        tag: 'outside room audio video controller.p',
        subTag: 'initSDK',
      );

      ZegoUIKit().login(localUser.id, localUser.name);

      sdkInitNotifier.value = true;

      return true;
    }

    ZegoLoggerService.logInfo(
      'init',
      tag: 'outside room audio video controller.p',
      subTag: 'initSDK',
    );

    return ZegoUIKit()
        .init(
      appID: _appID,
      appSign: _appSign,
      token: _token,
      scenario: _scenario,
    )
        .then((value) async {
      ZegoLoggerService.logInfo(
        'init done',
        tag: 'outside room audio video controller.p',
        subTag: 'initSDK',
      );

      await ZegoUIKit().setVideoConfig(
        _config.video ?? ZegoUIKitVideoConfig.preset180P(),
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
        tag: 'outside room audio video controller.p',
        subTag: 'joinRoom',
      );

      return false;
    }

    if (ZegoUIKit().isRoomLogin) {
      ZegoLoggerService.logInfo(
        'has already login',
        tag: 'outside room audio video controller.p',
        subTag: 'joinRoom',
      );

      roomLoginNotifier.value = true;
      return true;
    }

    ZegoLoggerService.logInfo(
      'try join room($roomID) with a temp user $localUser',
      tag: 'outside room audio video controller.p',
      subTag: 'joinRoom',
    );
    return ZegoUIKit().joinRoom(roomID, token: _token).then((result) {
      ZegoLoggerService.logInfo(
        'join room result:${result.errorCode} ${result.extendedData}',
        tag: 'outside room audio video controller.p',
        subTag: 'loginRoom',
      );

      roomLoginNotifier.value = result.errorCode == 0;

      return result.errorCode == 0;
    });
  }

  Future<bool> leaveRoom() async {
    ZegoLoggerService.logInfo(
      'try leave room $roomID',
      tag: 'outside room audio video controller.p',
      subTag: 'leaveRoom',
    );

    if (ZegoUIKitCore.shared.coreData.room.id != roomID) {
      ZegoLoggerService.logInfo(
        'is not current room, now is ${ZegoUIKitCore.shared.coreData.room.id}',
        tag: 'outside room audio video controller.p',
        subTag: 'leaveRoom',
      );

      roomLoginNotifier.value = false;
      return true;
    }

    return ZegoUIKit().leaveRoom().then((ZegoRoomLogoutResult result) {
      ZegoLoggerService.logInfo(
        'leave room result:$result',
        tag: 'outside room audio video controller.p',
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
        tag: 'outside room audio video controller.p',
        subTag: isPlay ? 'startPlayAll' : 'stopPlayAll',
      );

      return false;
    }

    if (!ZegoUIKit().isRoomLogin) {
      ZegoLoggerService.logInfo(
        'has not login room',
        tag: 'outside room audio video controller.p',
        subTag: isPlay ? 'startPlayAll' : 'stopPlayAll',
      );

      return false;
    }

    for (var streamInfo in streamsNotifier.value) {
      if (isPlay && streamInfo.isPlaying) {
        ZegoLoggerService.logInfo(
          '${streamInfo.targetStreamID} is playing',
          tag: 'outside room audio video controller.p',
          subTag: isPlay ? 'startPlayAll' : 'stopPlayAll',
        );

        continue;
      } else if (!isPlay && !streamInfo.isPlaying) {
        ZegoLoggerService.logInfo(
          '${streamInfo.targetStreamID} is not playing',
          tag: 'outside room audio video controller.p',
          subTag: isPlay ? 'startPlayAll' : 'stopPlayAll',
        );

        continue;
      }

      ZegoLoggerService.logInfo(
        'stream id:${streamInfo.targetStreamID}',
        tag: 'outside room audio video controller.p',
        subTag: isPlay ? 'startPlayAll' : 'stopPlayAll',
      );

      streamInfo.isPlaying = isPlay;
      isPlay
          ? await ZegoUIKit().startPlayAnotherRoomAudioVideo(
              streamInfo.roomID,
              streamInfo.user.id,
              userName: streamInfo.user.name,
            )
          : await ZegoUIKit().stopPlayAnotherRoomAudioVideo(
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
          tag: 'outside room audio video controller.p',
          subTag: toPlay ? 'startPlayOne' : 'stopPlayOne',
        );
      }

      return false;
    }

    if (!ZegoUIKit().isRoomLogin) {
      if (withLog) {
        ZegoLoggerService.logInfo(
          'has not login room',
          tag: 'outside room audio video controller.p',
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
          tag: 'outside room audio video controller.p',
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
          tag: 'outside room audio video controller.p',
          subTag: toPlay ? 'startPlayOne' : 'stopPlayOne',
        );
      }

      return false;
    } else if (!toPlay && !streamInfo.isPlaying) {
      if (withLog) {
        ZegoLoggerService.logInfo(
          '${streamInfo.targetStreamID} is not playing',
          tag: 'outside room audio video controller.p',
          subTag: toPlay ? 'startPlayOne' : 'stopPlayOne',
        );
      }

      return false;
    }

    ZegoLoggerService.logInfo(
      'stream id:${streamInfo.targetStreamID}',
      tag: 'outside room audio video controller.p',
      subTag: toPlay ? 'startPlayOne' : 'stopPlayOne',
    );

    streamInfo.isPlaying = toPlay;
    toPlay
        ? await ZegoUIKit().startPlayAnotherRoomAudioVideo(
            streamInfo.roomID,
            streamInfo.user.id,
            userName: streamInfo.user.name,
          )
        : await ZegoUIKit().stopPlayAnotherRoomAudioVideo(
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
        List<ZegoOutsideRoomAudioVideoViewStream>.from(streamsNotifier.value);
  }

  Future<void> onStreamVisibleStateUpdate() async {
    if (ZegoOutsideRoomAudioVideoViewListPlayMode.autoPlay ==
        _config.playMode) {
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
