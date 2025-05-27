part of '../core.dart';

/// @nodoc
class ZegoUIKitCoreData
    with
        ZegoUIKitCoreDataStream,
        ZegoUIKitCoreDataUser,
        ZegoUIKitCoreDataNetworkTimestamp,
        ZegoUIKitCoreDataMedia,
        ZegoUIKitCoreDataScreenSharing,
        ZegoUIKitCoreDataMessage {
  bool isInit = false;

  Timer? mixerSEITimer;

  ZegoUIKitCoreRoom room = ZegoUIKitCoreRoom('');

  StreamController<ZegoInRoomCommandReceivedData>?
      customCommandReceivedStreamCtrl;
  final networkStateNotifier =
      ValueNotifier<ZegoUIKitNetworkState>(ZegoUIKitNetworkState.online);

  ZegoUIKitExpressEngineState engineState = ZegoUIKitExpressEngineState.stop;
  final engineStateStreamCtrl =
      StreamController<ZegoUIKitExpressEngineState>.broadcast();
  bool waitingEngineStopEnableCustomVideoProcessing = false;
  StreamSubscription? engineStateUpdatedSubscription;

  StreamController<ZegoUIKitNetworkState>? networkStateStreamCtrl;

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

    room.init();
    initUser();
    initStream();
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

    room.uninit();
    uninitUser();
    uninitStream();
    media.uninit();
    uninitMessage();
    uninitScreenSharing();
  }

  void clear() {
    ZegoLoggerService.logInfo(
      'clear',
      tag: 'uikit',
      subTag: 'core data',
    );

    clearStream();
    media.clear();

    isAllPlayStreamAudioVideoMuted = false;
    isAllPlayStreamAudioMuted = false;

    remoteUsersList.clear();
    streamDic.clear();
    streamExtraInfo.clear();

    room.clear();
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
    if (getLocalStreamID(streamType).isEmpty) {
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
