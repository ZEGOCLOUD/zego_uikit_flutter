// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_uikit/src/modules/outside_room_audio_video/controller.p.dart';
import 'package:zego_uikit/src/modules/outside_room_audio_video/defines.dart';
import 'package:zego_uikit/src/modules/outside_room_audio_video/internal.dart';
import 'package:zego_uikit/zego_uikit.dart';

class ZegoOutsideRoomAudioVideoViewListController {
  ZegoOutsideRoomAudioVideoViewListController({
    /// stream information to pull
    List<ZegoOutsideRoomAudioVideoViewStreamUser> streams = const [],
  }) {
    private.streamsNotifier.value = streams
        .map((stream) => ZegoOutsideRoomAudioVideoViewStream(
              user: stream.user,
              roomID: stream.roomID,
            ))
        .toList();
  }

  /// DO NOT CALL!!!
  /// Please do not call this. It is the internal logic.
  final private = ZegoOutsideRoomAudioVideoViewControllerPrivate();

  ValueNotifier<bool> get sdkInitNotifier => private.sdkInitNotifier;
  ValueNotifier<bool> get roomLoginNotifier => private.roomLoginNotifier;
  String get roomID => private.roomID;
  ZegoUIKitUser get localUser => private.localUser;

  /// start play all stream
  Future<bool> startPlayAll() async {
    ZegoLoggerService.logInfo(
      '',
      tag: 'outside room audio video controller',
      subTag: 'startPlayAll',
    );

    return private.playAll(isPlay: true);
  }

  /// stop play all stream
  Future<bool> stopPlayAll() async {
    ZegoLoggerService.logInfo(
      '',
      tag: 'outside room audio video controller',
      subTag: 'stopPlayAll',
    );

    return private.playAll(isPlay: false);
  }

  /// start play target stream
  /// if not in streams, it would not play, use [addStream].
  Future<bool> startPlayOne(
    ZegoOutsideRoomAudioVideoViewStreamUser stream,
  ) async {
    ZegoLoggerService.logInfo(
      'stream:$stream',
      tag: 'outside room audio video controller',
      subTag: 'startPlayOne',
    );

    return private.playOne(
      user: stream.user,
      roomID: stream.roomID,
      toPlay: true,
    );
  }

  /// stop play target stream
  Future<bool> stopPlayOne(
    ZegoOutsideRoomAudioVideoViewStreamUser stream,
  ) async {
    ZegoLoggerService.logInfo(
      'stream:$stream',
      tag: 'outside room audio video controller',
      subTag: 'stopPlayOne',
    );

    return private.playOne(
      user: stream.user,
      roomID: stream.roomID,
      toPlay: false,
    );
  }

  /// update streams
  void updateStreams(
    List<ZegoOutsideRoomAudioVideoViewStreamUser> streams, {
    bool startPlay = true,
  }) {
    ZegoLoggerService.logInfo(
      'streams:$streams, startPlay:$startPlay',
      tag: 'outside room audio video controller',
      subTag: 'updateStreams',
    );

    private.streamsNotifier.value = streams
        .map((stream) => ZegoOutsideRoomAudioVideoViewStream(
              user: stream.user,
              roomID: stream.roomID,
            ))
        .toList();

    if (startPlay) {
      startPlayAll();
    }
  }

  /// add a stream
  void addStream(
    ZegoOutsideRoomAudioVideoViewStreamUser stream, {
    bool startPlay = true,
  }) {
    ZegoLoggerService.logInfo(
      'stream:$stream, startPlay:$startPlay',
      tag: 'outside room audio video controller',
      subTag: 'addStream',
    );

    private.streamsNotifier.value = [
      ...private.streamsNotifier.value,
      ZegoOutsideRoomAudioVideoViewStream(
        user: stream.user,
        roomID: stream.roomID,
      ),
    ];

    if (startPlay) {
      startPlayOne(stream);
    }
  }

  /// remove a stream
  void removeStream(ZegoOutsideRoomAudioVideoViewStreamUser stream) {
    ZegoLoggerService.logInfo(
      'stream:$stream',
      tag: 'outside room audio video controller',
      subTag: 'removeStream',
    );

    stopPlayOne(stream);

    private.streamsNotifier.value.removeWhere(
      (e) => e.roomID == stream.roomID && e.user.id == stream.user.id,
    );
    private.streamsNotifier.value = List.from(private.streamsNotifier.value);
  }
}
