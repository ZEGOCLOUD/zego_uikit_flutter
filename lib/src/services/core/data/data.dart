part of '../core.dart';

/// @nodoc
class ZegoUIKitCoreData
    with
        ZegoUIKitCoreDataRoom,
        ZegoUIKitCoreDataStream,
        ZegoUIKitCoreDataUser,
        ZegoUIKitCoreDataNetworkTimestamp,
        ZegoUIKitCoreDataMedia,
        ZegoUIKitCoreDataScreenSharing,
        ZegoUIKitCoreDataMessage {
  bool isInit = false;

  Timer? mixerSEITimer;

  StreamController<ZegoInRoomCommandReceivedData>?
      customCommandReceivedStreamCtrl;
  final networkStateNotifier =
      ValueNotifier<ZegoUIKitNetworkState>(ZegoUIKitNetworkState.online);
  StreamController<ZegoUIKitNetworkState>? networkStateStreamCtrl;

  ValueNotifier<ZegoUIKitExpressEngineState> engineStateNotifier =
      ValueNotifier<ZegoUIKitExpressEngineState>(
    ZegoUIKitExpressEngineState.Stop,
  );
  final engineStateStreamCtrl =
      StreamController<ZegoUIKitExpressEngineState>.broadcast();

  bool waitingEngineStopEnableValueOfCustomVideoProcessing = false;
  StreamSubscription?
      engineStateUpdatedSubscriptionByEnableCustomVideoProcessing;
  bool waitingEngineStopEnableValueOfCustomVideoRender = false;
  StreamSubscription? engineStateUpdatedSubscriptionByEnableCustomVideoRender;

  ZegoEffectsBeautyParam beautyParam = ZegoEffectsBeautyParam.defaultParam();

  void init() {
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

    multiRooms.forEach((roomID, roomInfo) {
      roomInfo.init();
    });
    initUser();
    multiRoomStreams.forEach((roomID, streamInfo) {
      streamInfo.initStream();
    });
    media.init();
    initMessage();
    initScreenSharing();
  }

  void uninit() {
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

    multiRooms.forEach((roomID, roomInfo) {
      roomInfo.uninit();
    });
    uninitUser();
    multiRoomStreams.forEach((roomID, streamInfo) {
      streamInfo.uninitStream();
    });
    media.uninit();
    uninitMessage();
    uninitScreenSharing();
  }

  void clear({
    required String targetRoomID,
  }) {
    ZegoLoggerService.logInfo(
      'clear',
      tag: 'uikit',
      subTag: 'core data',
    );

    media.clear();

    multiRoomStreams.forEach((roomID, streamInfo) {
      if (targetRoomID != roomID) {
        return;
      }

      streamInfo.clearStream();

      streamInfo.isAllPlayStreamAudioVideoMuted = false;
      streamInfo.isAllPlayStreamAudioMuted = false;
      streamInfo.streamDic.clear();
      streamInfo.streamExtraInfo.clear();
    });

    multiRoomUserInfo.forEach((roomID, userInfo) {
      if (targetRoomID != roomID) {
        return;
      }
      userInfo.remoteUsersList.clear();
    });

    multiRooms.forEach((roomID, roomInfo) {
      if (targetRoomID != roomID) {
        return;
      }
      roomInfo.clear();
    });
  }

  void setRoom(
    String roomID, {
    bool markAsLargeRoom = false,
  }) {
    ZegoLoggerService.logInfo(
      'set room:"$roomID", markAsLargeRoom:$markAsLargeRoom}',
      tag: 'uikit-room',
      subTag: 'setRoom',
    );

    if (roomID.isEmpty) {
      ZegoLoggerService.logError(
        'room id is empty',
        tag: 'uikit-room',
        subTag: 'setRoom',
      );
    }

    room
      ..id = roomID
      ..markAsLargeRoom = markAsLargeRoom;
  }

  Future<bool> sendSEI(
    String typeIdentifier,
    Map<String, dynamic> seiData, {
    ZegoStreamType streamType = ZegoStreamType.main,
  }) async {
    if (ZegoUIKitCoreDataStreamHelper.getLocalStreamID(streamType).isEmpty) {
      ZegoLoggerService.logError(
        'local user has not publish stream, send sei will be failed',
        tag: 'uikit-sei',
        subTag: 'sendSEI',
      );
    }

    final dataJson = jsonEncode({
      ZegoUIKitSEIDefines.keyUserID: localUser.id,
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
