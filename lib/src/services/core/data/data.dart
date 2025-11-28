// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';
// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';
// Project imports:
import 'package:zego_uikit/src/services/core/data/device.dart';
import 'package:zego_uikit/src/services/core/data/engine.dart';
import 'package:zego_uikit/src/services/core/data/error.dart';
import 'package:zego_uikit/src/services/core/data/media.dart';
import 'package:zego_uikit/src/services/core/data/message.dart';
import 'package:zego_uikit/src/services/core/data/room.dart';
import 'package:zego_uikit/src/services/core/data/screen_sharing.dart';
import 'package:zego_uikit/src/services/core/data/stream.dart';
import 'package:zego_uikit/src/services/core/data/timestamp.dart';
import 'package:zego_uikit/src/services/core/data/user.dart';
import 'package:zego_uikit/src/services/core/defines/defines.dart';
import 'package:zego_uikit/src/services/services.dart';

/// @nodoc
class ZegoUIKitCoreData {
  bool isInit = false;

  final message = ZegoUIKitCoreDataMessage();
  final room = ZegoUIKitCoreDataRoom();
  final stream = ZegoUIKitCoreDataStream();
  final user = ZegoUIKitCoreDataUser();

  final timestamp = ZegoUIKitCoreDataTimestamp();
  final screenSharing = ZegoUIKitCoreDataScreenSharing();
  final media = ZegoUIKitCoreDataMedia();
  final device = ZegoUIKitCoreDataDevice();
  final error = ZegoUIKitCoreDataError();
  final engine = ZegoUIKitCoreDataEngine();

  Timer? mixerSEITimer;

  StreamController<ZegoInRoomCommandReceivedData>?
      customCommandReceivedStreamCtrl;
  final networkStateNotifier =
      ValueNotifier<ZegoUIKitNetworkState>(ZegoUIKitNetworkState.online);
  StreamController<ZegoUIKitNetworkState>? networkStateStreamCtrl;

  ZegoEffectsBeautyParam beautyParam = ZegoEffectsBeautyParam.defaultParam();

  Future<void> init({
    bool? enablePlatformView,
    bool playingStreamInPIPUnderIOS = false,
  }) async {
    if (isInit) {
      return;
    }

    isInit = true;

    ZegoLoggerService.logInfo(
      'init',
      tag: 'uikit',
      subTag: 'core data',
    );

    customCommandReceivedStreamCtrl ??=
        StreamController<ZegoInRoomCommandReceivedData>.broadcast();
    networkStateStreamCtrl ??=
        StreamController<ZegoUIKitNetworkState>.broadcast();

    await device.init();
    room.init();
    user.init();
    stream.init(
      enablePlatformView: enablePlatformView,
      playingStreamInPIPUnderIOS: playingStreamInPIPUnderIOS,
    );
    media.init();
    message.init();
    screenSharing.init();
    error.init();
  }

  Future<void> uninit() async {
    if (!isInit) {
      return;
    }

    isInit = false;

    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'uikit',
      subTag: 'core data',
    );

    customCommandReceivedStreamCtrl?.close();
    customCommandReceivedStreamCtrl = null;

    networkStateStreamCtrl?.close();
    networkStateStreamCtrl = null;

    device.uninit();
    await room.uninit();
    user.uninit();
    stream.uninit();
    media.uninit();
    message.uninit();
    screenSharing.uninit();
    error.uninit();
  }

  void clear({
    required String targetRoomID,
  }) {
    ZegoLoggerService.logInfo(
      'clear',
      tag: 'uikit',
      subTag: 'core data',
    );

    if (targetRoomID.isEmpty) {
      ZegoLoggerService.logInfo(
        'target room id is empty',
        tag: 'uikit',
        subTag: 'core data',
      );

      return;
    }

    media.clear();
    stream.clear(
      targetRoomID: targetRoomID,
    );
    user.clear(targetRoomID: targetRoomID);
    room.clear(targetRoomID: targetRoomID);
    message.clear(targetRoomID: targetRoomID);
  }

  Future<bool> sendSEI(
    String typeIdentifier,
    Map<String, dynamic> seiData, {
    ZegoStreamType streamType = ZegoStreamType.main,
  }) async {
    if (ZegoUIKitStreamHelper.getUserStreamChannel(
      user.localUser,
      streamType,
    ).streamID.isEmpty) {
      ZegoLoggerService.logError(
        'local user has not publish stream, send sei will be failed',
        tag: 'uikit.sei',
        subTag: 'sendSEI',
      );
    }

    final dataJson = jsonEncode({
      ZegoUIKitSEIDefines.keyUserID: user.localUser.id,
      ZegoUIKitSEIDefines.keyTypeIdentifier: typeIdentifier,
      ZegoUIKitSEIDefines.keySEI: seiData,
    });
    final dataBytes = Uint8List.fromList(utf8.encode(dataJson));

    await ZegoExpressEngine.instance.sendSEI(
      dataBytes,
      dataBytes.length,
      channel: streamType.channel,
    );

    return true;
  }
}
