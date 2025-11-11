// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_uikit/src/modules/hall_room/controller.p.dart';
import 'package:zego_uikit/src/modules/hall_room/defines.dart';
import 'package:zego_uikit/src/modules/hall_room/internal.dart';
import 'package:zego_uikit/zego_uikit.dart';

class ZegoUIKitHallRoomListController {
  ZegoUIKitHallRoomListController({
    /// stream information to pull
    List<ZegoUIKitHallRoomListStreamUser> streams = const [],
  }) {
    private.streamsNotifier.value = streams
        .map((stream) => ZegoUIKitHallRoomListStream(
              user: stream.user,
              roomID: stream.roomID,
            ))
        .toList();
  }

  /// DO NOT CALL!!!
  /// Please do not call this. It is the internal logic.
  final private = ZegoUIKitHallRoomListControllerPrivate();

  ValueNotifier<bool> get sdkInitNotifier => private.sdkInitNotifier;
  ValueNotifier<bool> get roomLoginNotifier => private.roomLoginNotifier;
  String get roomID => private.roomID;
  ZegoUIKitUser get localUser => private.localUser;

  /// start play all stream
  Future<bool> startPlayAll() async {
    ZegoLoggerService.logInfo(
      '',
      tag: 'hall controller',
      subTag: 'startPlayAll',
    );

    return private.playAll(isPlay: true);
  }

  /// stop play all stream
  Future<bool> stopPlayAll() async {
    ZegoLoggerService.logInfo(
      '',
      tag: 'hall controller',
      subTag: 'stopPlayAll',
    );

    return private.playAll(isPlay: false);
  }

  /// start play target stream
  /// if not in streams, it would not play, use [addStream].
  Future<bool> startPlayOne(
    ZegoUIKitHallRoomListStreamUser stream,
  ) async {
    ZegoLoggerService.logInfo(
      'stream:$stream',
      tag: 'hall controller',
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
    ZegoUIKitHallRoomListStreamUser stream,
  ) async {
    ZegoLoggerService.logInfo(
      'stream:$stream',
      tag: 'hall controller',
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
    List<ZegoUIKitHallRoomListStreamUser> streams, {
    bool startPlay = true,
  }) {
    ZegoLoggerService.logInfo(
      'streams:$streams, startPlay:$startPlay',
      tag: 'hall controller',
      subTag: 'updateStreams',
    );

    private.streamsNotifier.value = streams
        .map((stream) => ZegoUIKitHallRoomListStream(
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
    ZegoUIKitHallRoomListStreamUser stream, {
    bool startPlay = true,
  }) {
    ZegoLoggerService.logInfo(
      'stream:$stream, startPlay:$startPlay',
      tag: 'hall controller',
      subTag: 'addStream',
    );

    private.streamsNotifier.value = [
      ...private.streamsNotifier.value,
      ZegoUIKitHallRoomListStream(
        user: stream.user,
        roomID: stream.roomID,
      ),
    ];

    if (startPlay) {
      startPlayOne(stream);
    }
  }

  /// remove a stream
  void removeStream(ZegoUIKitHallRoomListStreamUser stream) {
    ZegoLoggerService.logInfo(
      'stream:$stream',
      tag: 'hall controller',
      subTag: 'removeStream',
    );

    stopPlayOne(stream);

    private.streamsNotifier.value.removeWhere(
      (e) => e.roomID == stream.roomID && e.user.id == stream.user.id,
    );
    private.streamsNotifier.value = List.from(private.streamsNotifier.value);
  }
}
