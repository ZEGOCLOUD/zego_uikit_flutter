// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/modules/hall_room/internal.dart';
import 'package:zego_uikit/src/services/core/data/data.dart';
import 'package:zego_uikit/src/services/core/data/message.room.dart';
import 'package:zego_uikit/src/services/core/defines/defines.dart';
import 'package:zego_uikit/src/services/core/event/event.dart';
import 'package:zego_uikit/src/services/core/event_handler.dart';
import 'package:zego_uikit/src/services/defines/defines.dart';
import 'package:zego_uikit/src/services/uikit_service.dart';

part 'media.dart';

part 'message.dart';

/// @nodoc
class ZegoUIKitCore with ZegoUIKitCoreMessage, ZegoUIKitCoreEventHandler {
  ZegoUIKitCore._internal() {
    eventHandler.initConnectivity();
  }

  static final ZegoUIKitCore shared = ZegoUIKitCore._internal();

  final ZegoUIKitReporter reporter = ZegoUIKitReporter();
  final ZegoUIKitCoreData coreData = ZegoUIKitCoreData();
  var event = ZegoUIKitEvent();

  bool isInit = false;
  List<StreamSubscription<dynamic>?> subscriptions = [];
  String? version;

  Future<String> getZegoUIKitVersion() async {
    if (null == version) {
      final expressVersion = await ZegoExpressEngine.getVersion();
      final mobileInfo = 'platform:${Platform.operatingSystem}, '
          'version:${Platform.operatingSystemVersion}';

      const zegoUIKitVersion = 'zego_uikit: 3.0.0; ';
      version ??=
          '${zegoUIKitVersion}zego_express:$expressVersion,mobile:$mobileInfo';
    }

    return version!;
  }

  Future<void> init({
    required int appID,
    String appSign = '',
    String token = '',
    bool? enablePlatformView,
    bool playingStreamInPIPUnderIOS = false,
    ZegoUIKitRoomMode roomMode = ZegoUIKitRoomMode.SingleRoom,
    ZegoScenario scenario = ZegoScenario.Default,
    bool withoutCreateEngine = false,
  }) async {
    if (isInit) {
      ZegoLoggerService.logWarn(
        'had init',
        tag: 'uikit-service-core',
        subTag: 'init',
      );

      if (Platform.isIOS) {
        coreData.stream.playingStreamInPIPUnderIOS = playingStreamInPIPUnderIOS;
        coreData.stream.isEnablePlatformView = enablePlatformView ?? false;

        ZegoLoggerService.logInfo(
          'had init now, just update next params: '
          'playingStreamInPIPUnderIOS:$playingStreamInPIPUnderIOS, '
          'enablePlatformView:$enablePlatformView, ',
          tag: 'uikit-service-core',
          subTag: 'init',
        );
      }

      return;
    }

    isInit = true;

    ZegoLoggerService.logInfo(
      'appID:$appID, '
      'has appSign:${appSign.isNotEmpty}, '
      'playingStreamInPIPUnderIOS:$playingStreamInPIPUnderIOS, '
      'enablePlatformView:$enablePlatformView, '
      'room mode:$roomMode, '
      'scenario:$scenario, ',
      tag: 'uikit-service-core',
      subTag: 'init',
    );

    reporter.create(
      userID: coreData.user.localUser.id,
      appID: appID,
      signOrToken: appSign.isNotEmpty ? appSign : token,
      params: {},
    );

    await coreData.init(
      enablePlatformView: enablePlatformView,
      playingStreamInPIPUnderIOS: playingStreamInPIPUnderIOS,
      roomMode: roomMode,
    );
    event.init();
    initEventHandle();

    await coreData.engine.create(
      appID: appID,
      appSign: appSign,
      token: token,
      withoutCreateEngine: withoutCreateEngine,
      enablePlatformView: enablePlatformView,
      roomMode: roomMode,
      scenario: scenario,
    );

    await coreData.timestamp.init();

    final initAudioRoute = await ZegoExpressEngine.instance.getAudioRouteType();
    coreData.user.localUser.initAudioRoute(initAudioRoute);

    subscriptions.add(
      coreData.customCommandReceivedStreamCtrl?.stream.listen(
        onInternalCustomCommandReceived,
      ),
    );
  }

  Future<void> uninit() async {
    if (!isInit) {
      ZegoLoggerService.logWarn(
        'is not init',
        tag: 'uikit-service-core',
        subTag: 'uninit',
      );
      return;
    }

    isInit = false;

    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'uikit-service-core',
      subTag: 'uninit',
    );

    reporter.destroy();

    coreData.uninit();
    event.uninit();
    uninitEventHandle();

    /// clear old room data
    coreData.clear(targetRoomID: coreData.room.currentID);

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }

    coreData.engine.createdNotifier.value = false;
    await ZegoExpressEngine.destroyEngine();
  }

  Future<void> setAdvanceConfigs(Map<String, String> configs) async {
    ZegoLoggerService.logInfo(
      'configs:$configs',
      tag: 'uikit-service-core',
      subTag: 'set advance configs',
    );

    await ZegoExpressEngine.setEngineConfig(
      ZegoEngineConfig(advancedConfig: configs),
    );
  }

  void initEventHandle() {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'uikit-service-core',
      subTag: 'init event handle',
    );

    event.express.register(eventHandler);
    event.express.register(coreData.error);
    event.express.register(message);

    event.media.register(coreData.media);
  }

  void uninitEventHandle() {
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'uikit-service-core',
      subTag: 'uninit event handle',
    );

    event.express.unregister(eventHandler);
    event.express.unregister(coreData.error);
    event.express.unregister(message);

    event.media.unregister(coreData.media);
  }

  ValueNotifier<DateTime?> getNetworkTime() {
    return coreData.timestamp.notifier;
  }

  void login(String id, String name) {
    coreData.user.login(id, name);
  }

  void logout() {
    coreData.user.logout();
  }

  bool hasLoginSameRoom(String roomID) {
    return coreData.room.currentID == roomID;
  }

  Future<ZegoRoomLoginResult> joinRoom(
    String roomID, {
    String token = '',
    bool markAsLargeRoom = false,
    bool keepWakeScreen = true,
    bool isSimulated = false,
  }) async {
    event.init();

    final joinRoomResult = await coreData.room.join(
      targetRoomID: roomID,
      token: token,
      markAsLargeRoom: markAsLargeRoom,
      keepWakeScreen: keepWakeScreen,
      isSimulated: isSimulated,
      tryReLoginIfCountExceed: true,
    );

    return joinRoomResult;
  }

  Future<ZegoRoomLogoutResult> leaveRoom({
    required String targetRoomID,
  }) async {
    ZegoLoggerService.logInfo(
      'current room is ${coreData.room.currentID}, '
      'all room ids:${coreData.room.rooms.allRoomIDs}, '
      'target room id:$targetRoomID, '
      'network state:${ZegoUIKit().getNetworkState()}, ',
      tag: 'uikit-room',
      subTag: 'leave',
    );

    final leaveResult = await coreData.room.leave(
      targetRoomID: targetRoomID,
    );

    if (!coreData.room.hasLogin) {
      event.uninit();
    }

    return leaveResult;
  }

  Future<int> removeUserFromRoom(
    List<String> userIDs, {
    required String targetRoomID,
  }) async {
    ZegoLoggerService.logInfo(
      'users:$userIDs',
      tag: 'uikit-room',
      subTag: 'remove users',
    );

    final targetRoomInfo = coreData.room.rooms.getRoom(targetRoomID);
    if (targetRoomInfo.isLargeRoom || targetRoomInfo.markAsLargeRoom) {
      ZegoLoggerService.logInfo(
        'remove all users, because is a large room',
        tag: 'uikit-room',
        subTag: 'remove users',
      );
      return sendInRoomCommand(
        targetRoomID: targetRoomID,
        const JsonEncoder().convert({removeUserInRoomCommandKey: userIDs}),
        [],
      );
    } else {
      return sendInRoomCommand(
        targetRoomID: targetRoomID,
        const JsonEncoder().convert({removeUserInRoomCommandKey: userIDs}),
        userIDs,
      );
    }
  }

  void clearLocalMessage(
    ZegoInRoomMessageType type, {
    required String targetRoomID,
  }) {
    ZegoLoggerService.logInfo(
      '',
      tag: 'uikit-room',
      subTag: 'remove local message',
    );

    (type == ZegoInRoomMessageType.broadcastMessage)
        ? ZegoUIKitCore.shared.coreData.message.clearBroadcast(
            targetRoomID: targetRoomID,
          )
        : ZegoUIKitCore.shared.coreData.message.clearBarrage(
            targetRoomID: targetRoomID,
          );
  }

  Future<int> clearRemoteMessage(
    ZegoInRoomMessageType type, {
    required String targetRoomID,
  }) async {
    ZegoLoggerService.logInfo(
      '',
      tag: 'uikit-room',
      subTag: 'remove remote message',
    );

    return sendInRoomCommand(
      targetRoomID: targetRoomID,
      const JsonEncoder().convert({
        clearMessageInRoomCommandKey: type.index.toString(),
      }),
      [],
    );
  }

  Future<bool> setRoomProperty(
    String key,
    String value, {
    required String targetRoomID,
  }) async {
    return updateRoomProperties(
      {key: value},
      targetRoomID: targetRoomID,
    );
  }

  Future<bool> updateRoomProperties(
    Map<String, String> properties, {
    required String targetRoomID,
  }) async {
    ZegoLoggerService.logInfo(
      'properties: $properties',
      tag: 'uikit-room-property',
      subTag: 'update room properties',
    );

    if (!isInit) {
      ZegoLoggerService.logError(
        'core had not init',
        tag: 'uikit-room-property',
        subTag: 'update room properties',
      );

      coreData.error.errorStreamCtrl?.add(
        ZegoUIKitError(
          code: ZegoUIKitErrorCode.coreNotInit,
          message: 'core not init',
          method: 'updateRoomProperties',
        ),
      );

      return false;
    }

    if (coreData.room.currentID.isEmpty) {
      ZegoLoggerService.logError(
        'room is not login',
        tag: 'uikit-room-property',
        subTag: 'update room properties',
      );

      coreData.error.errorStreamCtrl?.add(
        ZegoUIKitError(
          code: ZegoUIKitErrorCode.roomNotLogin,
          message: 'room not login',
          method: 'updateRoomProperties',
        ),
      );

      return false;
    }

    final targetRoomInfo = coreData.room.rooms.getRoom(targetRoomID);
    if (targetRoomInfo.propertiesAPIRequesting) {
      properties.forEach((key, value) {
        targetRoomInfo.pendingProperties[key] = value;
      });
      ZegoLoggerService.logInfo(
        'room property is updating, pending: ${targetRoomInfo.pendingProperties}',
        tag: 'uikit-room-property',
        subTag: 'update room properties',
      );
      return false;
    }

    final localUser = ZegoUIKit().getLocalUser();

    var isAllPropertiesSame = targetRoomInfo.properties.isNotEmpty;
    properties.forEach((key, value) {
      if (targetRoomInfo.properties.containsKey(key) &&
          targetRoomInfo.properties[key]!.value == value) {
        ZegoLoggerService.logInfo(
          'key exist and value is same, ${targetRoomInfo.properties}',
          tag: 'uikit-room-property',
          subTag: 'update room properties',
        );
        isAllPropertiesSame = false;
      }
    });
    if (isAllPropertiesSame) {
      ZegoLoggerService.logInfo(
        'all key exist and value is same',
        tag: 'uikit-room-property',
        subTag: 'update room properties',
      );
      // return true;
    }

    final oldProperties = <String, RoomProperty?>{};
    properties
      ..forEach((key, value) {
        if (targetRoomInfo.properties.containsKey(key)) {
          oldProperties[key] =
              RoomProperty.copyFrom(targetRoomInfo.properties[key]!);
          oldProperties[key]!.updateUserID = localUser.id;
        }
      })

      /// local update
      ..forEach((key, value) {
        if (targetRoomInfo.properties.containsKey(key)) {
          targetRoomInfo.properties[key]!.oldValue =
              targetRoomInfo.properties[key]!.value;
          targetRoomInfo.properties[key]!.value = value;
          targetRoomInfo.properties[key]!.updateTime =
              coreData.timestamp.now.millisecondsSinceEpoch;
          targetRoomInfo.properties[key]!.updateFromRemote = false;
        } else {
          targetRoomInfo.properties[key] = RoomProperty(
            key,
            value,
            coreData.timestamp.now.millisecondsSinceEpoch,
            localUser.id,
            false,
          );
        }
      });

    /// server update
    final extraInfoMap = <String, String>{};
    targetRoomInfo.properties.forEach((key, value) {
      extraInfoMap[key] = value.value;
    });
    final extraInfo = const JsonEncoder().convert(extraInfoMap);
    // if (extraInfo.length > 128) {
    //   ZegoLoggerService.logInfo("value length out of limit");
    //   return false;
    // }
    ZegoLoggerService.logInfo(
      'set room extra info, $extraInfo',
      tag: 'uikit-room-property',
      subTag: 'update room properties',
    );
    targetRoomInfo.propertiesAPIRequesting = true;
    return ZegoExpressEngine.instance
        .setRoomExtraInfo(targetRoomInfo.id, 'extra_info', extraInfo)
        .then((ZegoRoomSetRoomExtraInfoResult result) {
      ZegoLoggerService.logInfo(
        'set room extra info, result:${result.errorCode}',
        tag: 'uikit-room-property',
        subTag: 'update room properties',
      );
      if (ZegoErrorCode.CommonSuccess == result.errorCode) {
        properties.forEach((key, value) {
          if (!targetRoomInfo.properties.containsKey(key)) {
            return;
          }

          /// exception
          final updatedProperty = targetRoomInfo.properties[key]!
            ..updateFromRemote = true;
          targetRoomInfo.propertyUpdateStream?.add(updatedProperty);
          targetRoomInfo.propertiesUpdatedStream?.add({key: updatedProperty});
        });
      } else {
        properties.forEach((key, value) {
          if (targetRoomInfo.properties.containsKey(key) &&
              oldProperties.containsKey(key)) {
            targetRoomInfo.properties[key]!.copyFrom(oldProperties[key]!);
          }
        });
        ZegoLoggerService.logError(
          'failed, properties:$properties, error code:${result.errorCode}',
          tag: 'uikit-room-property',
          subTag: 'update room properties',
        );
      }

      targetRoomInfo.propertiesAPIRequesting = false;
      if (targetRoomInfo.pendingProperties.isNotEmpty) {
        final pendingProperties =
            Map<String, String>.from(targetRoomInfo.pendingProperties);
        targetRoomInfo.pendingProperties.clear();
        ZegoLoggerService.logInfo(
          'update pending properties:$pendingProperties',
          tag: 'uikit-room-property',
          subTag: 'update room properties',
        );
        updateRoomProperties(
          pendingProperties,
          targetRoomID: targetRoomID,
        );
      }

      return ZegoErrorCode.CommonSuccess != result.errorCode;
    });
  }

  Future<int> sendInRoomCommand(
    String command,
    List<String> toUserIDs, {
    required String targetRoomID,
  }) async {
    ZegoLoggerService.logInfo(
      'send in-room command, '
      'room id:$targetRoomID, '
      'command:$command, '
      'user ids:$toUserIDs',
      tag: 'uikit-room-command',
      subTag: 'custom command',
    );

    return ZegoExpressEngine.instance
        .sendCustomCommand(
      targetRoomID,
      command,
      toUserIDs.isEmpty

          /// empty mean send to all users
          ? coreData.user.roomUsers
              .getRoom(targetRoomID)
              .remoteUsers
              .map((ZegoUIKitCoreUser user) => ZegoUser(user.id, user.name))
              .toList()
          : toUserIDs
              .map((String userID) => coreData.user.roomUsers
                  .getRoom(targetRoomID)
                  .remoteUsers
                  .firstWhere((element) => element.id == userID,
                      orElse: ZegoUIKitCoreUser.empty)
                  .toZegoUser())
              .toList(),
    )
        .then((ZegoIMSendCustomCommandResult result) {
      ZegoLoggerService.logInfo(
        'send in-room command, result:${result.errorCode}',
        tag: 'uikit-room-command',
        subTag: 'custom command',
      );

      return result.errorCode;
    });
  }

  Future<bool> useFrontFacingCamera(
    bool isFrontFacing, {
    bool ignoreCameraStatus = false,
  }) async {
    if (!ignoreCameraStatus && !coreData.user.localUser.camera.value) {
      ZegoLoggerService.logInfo(
        'camera not open now',
        tag: 'uikit-camera',
        subTag: 'use front facing camera',
      );

      return false;
    }

    if (isFrontFacing == coreData.user.localUser.isFrontFacing.value) {
      ZegoLoggerService.logInfo(
        'Already ${isFrontFacing ? 'front' : 'back'}',
        tag: 'uikit-camera',
        subTag: 'use front facing camera',
      );

      return true;
    }

    if (coreData.stream.isUsingFrontCameraRequesting) {
      ZegoLoggerService.logInfo(
        'still requesting, ignore',
        tag: 'uikit-camera',
        subTag: 'use front facing camera',
      );

      return false;
    }

    ZegoLoggerService.logInfo(
      'use ${isFrontFacing ? 'front' : 'back'} camera',
      tag: 'uikit-camera',
      subTag: 'use front facing camera',
    );

    /// Access request frequency limit
    /// Frequent switching will cause a black screen
    coreData.stream.isUsingFrontCameraRequesting = true;

    coreData.user.localUser.mainChannel.isCapturedVideoFirstFrameNotifier
        .value = false;
    coreData.user.localUser.mainChannel.isCapturedVideoFirstFrameNotifier
        .addListener(onCapturedVideoFirstFrameAfterSwitchCamera);
    coreData.user.localUser.mainChannel.isRenderedVideoFirstFrameNotifier
        .value = false;

    coreData.user.localUser.isFrontFacing.value = isFrontFacing;
    await ZegoExpressEngine.instance.useFrontCamera(isFrontFacing);

    final videoMirrorMode = isFrontFacing
        ? (coreData.user.localUser.isVideoMirror.value
            ? ZegoVideoMirrorMode.BothMirror
            : ZegoVideoMirrorMode.NoMirror)
        : ZegoVideoMirrorMode.NoMirror;
    ZegoLoggerService.logInfo(
      'update video mirror mode:$videoMirrorMode',
      tag: 'uikit-camera',
      subTag: 'use front facing camera',
    );
    await ZegoExpressEngine.instance.setVideoMirrorMode(videoMirrorMode);

    return true;
  }

  void onCapturedVideoFirstFrameAfterSwitchCamera() {
    coreData.user.localUser.mainChannel.isCapturedVideoFirstFrameNotifier
        .removeListener(onCapturedVideoFirstFrameAfterSwitchCamera);

    coreData.stream.isUsingFrontCameraRequesting = false;

    ZegoLoggerService.logInfo(
      'onCapturedVideoFirstFrameAfterSwitchCamera',
      tag: 'uikit-camera',
      subTag: 'use front facing camera',
    );
  }

  void enableVideoMirroring(bool isVideoMirror) {
    coreData.user.localUser.isVideoMirror.value = isVideoMirror;

    ZegoExpressEngine.instance.setVideoMirrorMode(
      isVideoMirror
          ? ZegoVideoMirrorMode.BothMirror
          : ZegoVideoMirrorMode.NoMirror,
    );
  }

  void setPlayerResourceMode(
    ZegoUIKitStreamResourceMode mode, {
    required String targetRoomID,
  }) {
    coreData.stream.playerResourceMode = mode;

    ZegoLoggerService.logInfo(
      'mode: $mode',
      tag: 'uikit-service-core',
      subTag: 'set audio video resource mode',
    );
  }

  void setPlayerCDNConfig(
    ZegoUIKitCDNConfig? cdnConfig, {
    required String targetRoomID,
  }) {
    coreData.stream.playerCDNConfig = cdnConfig;

    ZegoLoggerService.logInfo(
      'config: ${cdnConfig?.toStringX()}',
      tag: 'uikit-service-core',
      subTag: 'set audio video resource mode',
    );
  }

  Future<void> startPlayAllAudioVideo({
    required String targetRoomID,
  }) async {
    await coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .muteAllPlayStreamAudioVideo(false);
  }

  Future<void> stopPlayAllAudioVideo({
    required String targetRoomID,
  }) async {
    await coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .muteAllPlayStreamAudioVideo(
          true,
        );
  }

  Future<void> startPlayAllAudio({
    required String targetRoomID,
  }) async {
    await coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .muteAllPlayStreamAudio(false);
  }

  Future<void> stopPlayAllAudio({
    required String targetRoomID,
  }) async {
    await coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .muteAllPlayStreamAudio(true);
  }

  Future<bool> muteUserAudioVideo(
    String userID,
    bool mute, {
    required String targetRoomID,
  }) async {
    return coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .mutePlayStreamAudioVideo(
          userID,
          mute,
          forAudio: true,
          forVideo: true,
        );
  }

  Future<bool> muteUserAudio(
    String userID,
    bool mute, {
    required String targetRoomID,
  }) async {
    return coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .mutePlayStreamAudioVideo(
          userID,
          mute,
          forAudio: true,
          forVideo: false,
        );
  }

  Future<bool> muteUserVideo(
    String userID,
    bool mute, {
    required String targetRoomID,
  }) async {
    return coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .mutePlayStreamAudioVideo(
          userID,
          mute,
          forAudio: false,
          forVideo: true,
        );
  }

  bool setAudioRouteToSpeaker(bool useSpeaker) {
    if (!isInit) {
      ZegoLoggerService.logError(
        'core had not init',
        tag: 'uikit-service-core',
        subTag: 'set audio route to speaker:$useSpeaker',
      );

      coreData.error.errorStreamCtrl?.add(
        ZegoUIKitError(
          code: ZegoUIKitErrorCode.coreNotInit,
          message: 'core not init',
          method: 'setAudioOutputToSpeaker',
        ),
      );

      return false;
    }

    if (useSpeaker) {
      if (ZegoUIKitAudioRoute.Speaker ==
          coreData.user.localUser.audioRoute.value) {
        ZegoLoggerService.logInfo(
          'already ${useSpeaker ? 'use' : 'not use'}',
          tag: 'uikit-service-core',
          subTag: 'set audio route to speaker:$useSpeaker',
        );

        return true;
      }

      if (ZegoUIKitAudioRoute.Headphone ==
          coreData.user.localUser.audioRoute.value) {
        ZegoLoggerService.logWarn(
          'Currently using headphone, cannot be set as speaker.',
          tag: 'uikit-service-core',
          subTag: 'set audio route to speaker:$useSpeaker',
        );

        return false;
      }
    }

    ZegoLoggerService.logInfo(
      'target is speaker:$useSpeaker, '
      'current audio route is:${coreData.user.localUser.audioRoute.value}, ',
      tag: 'uikit-service-core',
      subTag: 'set audio route to speaker:$useSpeaker',
    );
    ZegoExpressEngine.instance.setAudioRouteToSpeaker(useSpeaker);

    if (useSpeaker) {
      coreData.user.localUser.lastAudioRoute =
          coreData.user.localUser.audioRoute.value;
      coreData.user.localUser.audioRoute.value = ZegoUIKitAudioRoute.Speaker;
    } else {
      if (coreData.user.localUser.lastAudioRoute ==
          ZegoUIKitAudioRoute.Speaker) {
        coreData.user.localUser.lastAudioRoute = ZegoUIKitAudioRoute.Receiver;
      }
      coreData.user.localUser.audioRoute.value =
          coreData.user.localUser.lastAudioRoute;
    }
    ZegoLoggerService.logInfo(
      'now audio route is:${coreData.user.localUser.audioRoute.value}',
      tag: 'uikit-service-core',
      subTag: 'set audio route to speaker:$useSpeaker',
    );

    return true;
  }

  Future<bool> turnCameraOn(
    String userID,
    bool isOn, {
    required String targetRoomID,
  }) async {
    if (coreData.user.localUser.id == userID) {
      return turnOnLocalCamera(
        isOn,
        targetRoomID: targetRoomID,
      );
    } else {
      final targetRoomInfo = coreData.room.rooms.getRoom(targetRoomID);

      final isLargeRoom =
          targetRoomInfo.isLargeRoom || targetRoomInfo.markAsLargeRoom;

      ZegoLoggerService.logInfo(
        "turn ${isOn ? "on" : "off"} $userID camera, "
        "is large room:$isLargeRoom",
        tag: 'uikit-camera',
        subTag: 'switch camera',
      );

      if (isOn) {
        return ZegoUIKitErrorCode.success ==
            await sendInRoomCommand(
              const JsonEncoder()
                  .convert({turnCameraOnInRoomCommandKey: userID}),
              targetRoomID: targetRoomID,
              isLargeRoom ? [] : [userID],
            );
      } else {
        return ZegoUIKitErrorCode.success ==
            await sendInRoomCommand(
              const JsonEncoder()
                  .convert({turnCameraOffInRoomCommandKey: userID}),
              targetRoomID: targetRoomID,
              isLargeRoom ? [] : [userID],
            );
      }
    }
  }

  Future<bool> turnOnLocalCamera(
    bool isOn, {
    required String targetRoomID,
  }) async {
    if (!isInit) {
      ZegoLoggerService.logError(
        'core had not init',
        tag: 'uikit-camera',
        subTag: 'switch camera',
      );

      coreData.error.errorStreamCtrl?.add(
        ZegoUIKitError(
          code: ZegoUIKitErrorCode.coreNotInit,
          message: 'core not init',
          method: 'turnOnLocalCamera',
        ),
      );

      return false;
    }

    if (isOn == coreData.user.localUser.camera.value) {
      ZegoLoggerService.logInfo(
        'turn ${isOn ? "on" : "off"} local camera, already ${isOn ? "on" : "off"}',
        tag: 'uikit-camera',
        subTag: 'switch camera',
      );

      return true;
    }

    ZegoLoggerService.logInfo(
      "turn ${isOn ? "on" : "off"} local camera",
      tag: 'uikit-camera',
      subTag: 'switch camera',
    );

    coreData.user.localUser.isFrontTriggerByTurnOnCamera.value = true;
    coreData.user.localUser.cameraMuteMode.value = false;
    coreData.user.localUser.camera.value = isOn;

    if (isOn) {
      await coreData.stream.startPreview(targetRoomID: targetRoomID);
    } else {
      await coreData.stream.stopPreview();
    }

    await ZegoExpressEngine.instance.enableCamera(isOn);

    await coreData.stream.roomStreams.getRoom(targetRoomID).startPublishOrNot();

    await coreData.device.syncDeviceStatusByStreamExtraInfo();

    return true;
  }

  void turnMicrophoneOn(
    String userID,
    bool isOn, {
    bool muteMode = false,
    required String targetRoomID,
  }) {
    if (coreData.user.localUser.id == userID) {
      turnOnLocalMicrophone(
        isOn,
        targetRoomID: targetRoomID,
        muteMode: muteMode,
      );
    } else {
      final targetRoomInfo = coreData.room.rooms.getRoom(targetRoomID);
      final isLargeRoom =
          targetRoomInfo.isLargeRoom || targetRoomInfo.markAsLargeRoom;

      ZegoLoggerService.logInfo(
        "turn ${isOn ? "on" : "off"} $userID microphone, "
        "muteMode:$muteMode, "
        "is large room:$isLargeRoom, ",
        tag: 'uikit-microphone',
        subTag: 'switch microphone',
      );

      if (isOn) {
        sendInRoomCommand(
          const JsonEncoder().convert({
            turnMicrophoneOnInRoomCommandKey: {
              userIDCommandKey: userID,
              muteModeCommandKey: muteMode,
            },
          }),
          targetRoomID: targetRoomID,
          isLargeRoom ? [userID] : [],
        );
      } else {
        sendInRoomCommand(
          const JsonEncoder().convert({
            turnMicrophoneOffInRoomCommandKey: {
              userIDCommandKey: userID,
              muteModeCommandKey: muteMode,
            },
          }),
          targetRoomID: targetRoomID,
          isLargeRoom ? [userID] : [],
        );
      }
    }
  }

  Future<void> turnOnLocalMicrophone(
    bool isOn, {
    required String targetRoomID,
    bool muteMode = false,
  }) async {
    if (!isInit) {
      ZegoLoggerService.logError(
        'turn ${isOn ? "on" : "off"} local microphone, core had not init',
        tag: 'uikit-microphone',
        subTag: 'switch microphone',
      );

      coreData.error.errorStreamCtrl?.add(
        ZegoUIKitError(
          code: ZegoUIKitErrorCode.coreNotInit,
          message: 'core not init',
          method: 'turnOnLocalMicrophone',
        ),
      );

      return;
    }

    if ((isOn == coreData.user.localUser.microphone.value) &&
        (muteMode == coreData.user.localUser.microphoneMuteMode.value)) {
      ZegoLoggerService.logInfo(
        'turn ${isOn ? "on" : "off"} local microphone, muteMode:$muteMode, '
        'already ${isOn ? "on" : "off"}.',
        tag: 'uikit-microphone',
        subTag: 'switch microphone',
      );
      return;
    }

    ZegoLoggerService.logInfo(
      "turn ${isOn ? "on" : "off"} local microphone, muteMode:$muteMode",
      tag: 'uikit-microphone',
      subTag: 'switch microphone',
    );

    if (isOn) {
      await ZegoExpressEngine.instance.muteMicrophone(false);
      await ZegoExpressEngine.instance.mutePublishStreamAudio(false);
      coreData.user.localUser.microphoneMuteMode.value = false;
    } else {
      if (muteMode) {
        await ZegoExpressEngine.instance.muteMicrophone(false);
        await ZegoExpressEngine.instance.mutePublishStreamAudio(true);
        coreData.user.localUser.microphoneMuteMode.value = true;

        /// local sound level should be mute too
        coreData.user.localUser.mainChannel.soundLevelStream?.add(0.0);
      } else {
        await ZegoExpressEngine.instance.muteMicrophone(true);
        await ZegoExpressEngine.instance.mutePublishStreamAudio(false);
        coreData.user.localUser.microphoneMuteMode.value = false;
      }
    }

    coreData.user.localUser.microphone.value = isOn;
    await coreData.stream.roomStreams.getRoom(targetRoomID).startPublishOrNot();

    await coreData.device.syncDeviceStatusByStreamExtraInfo();
  }

  void updateTextureRendererOrientation(Orientation orientation) {
    switch (orientation) {
      case Orientation.portrait:
        ZegoExpressEngine.instance.setAppOrientation(
          DeviceOrientation.portraitUp,
        );
        break;
      case Orientation.landscape:
        ZegoExpressEngine.instance.setAppOrientation(
          DeviceOrientation.landscapeLeft,
        );
        break;
    }
  }

  Future<void> setVideoConfig(
    ZegoUIKitVideoConfig config,
    ZegoStreamType streamType,
  ) async {
    ZegoLoggerService.logInfo(
      'config:$config',
      tag: 'uikit-stream',
      subTag: 'set video config',
    );

    await ZegoExpressEngine.instance.setVideoConfig(
      config,
      channel: streamType.channel,
    );
    coreData.user.localUser.mainChannel.viewSizeNotifier.value = Size(
      config.encodeWidth.toDouble(),
      config.encodeHeight.toDouble(),
    );
  }

  Future<void> enableTrafficControl(
    bool enabled,
    List<ZegoUIKitTrafficControlProperty> properties, {
    ZegoUIKitVideoConfig? minimizeVideoConfig,
    bool isFocusOnRemote = true,
    ZegoStreamType streamType = ZegoStreamType.main,
  }) async {
    int propertyBitMask = 0;
    for (var property in properties) {
      propertyBitMask |= property.value;
    }

    minimizeVideoConfig ??= ZegoVideoConfigExtension.preset360P();

    ZegoLoggerService.logInfo(
      'enable:$enabled, '
      'properties:$properties, '
      'minimizeVideoConfig:$minimizeVideoConfig, '
      'isFocusOnRemote:$isFocusOnRemote, '
      'bitmask:$propertyBitMask',
      tag: 'uikit-stream',
      subTag: 'traffic control',
    );

    await ZegoExpressEngine.instance.setMinVideoBitrateForTrafficControl(
      minimizeVideoConfig.bitrate,
      ZegoTrafficControlMinVideoBitrateMode.UltraLowFPS,
    );
    await ZegoExpressEngine.instance.setMinVideoResolutionForTrafficControl(
      minimizeVideoConfig.encodeWidth,
      minimizeVideoConfig.encodeHeight,
    );
    await ZegoExpressEngine.instance.setMinVideoFpsForTrafficControl(
      minimizeVideoConfig.fps,
    );
    await ZegoExpressEngine.instance.setTrafficControlFocusOn(
      isFocusOnRemote
          ? ZegoTrafficControlFocusOnMode.ZegoTrafficControlFounsOnRemote
          : ZegoTrafficControlFocusOnMode.ZegoTrafficControlFounsOnLocalOnly,
    );

    await ZegoExpressEngine.instance.enableTrafficControl(
      enabled,
      propertyBitMask,
      channel: streamType.channel,
    );
  }

  void setInternalVideoConfig(ZegoUIKitVideoInternalConfig config) {
    if (coreData.stream.pushVideoConfig.needUpdateVideoConfig(config)) {
      final zegoVideoConfig = config.toZegoVideoConfig();
      ZegoExpressEngine.instance.setVideoConfig(
        zegoVideoConfig,
        channel: ZegoPublishChannel.Main,
      );
      coreData.user.localUser.mainChannel.viewSizeNotifier.value = Size(
        zegoVideoConfig.captureWidth.toDouble(),
        zegoVideoConfig.captureHeight.toDouble(),
      );
    }

    if (coreData.stream.pushVideoConfig.needUpdateOrientation(config)) {
      ZegoExpressEngine.instance.setAppOrientation(
        config.orientation,
        channel: ZegoPublishChannel.Main,
      );
    }

    coreData.stream.pushVideoConfig = config;
  }

  void updateAppOrientation(DeviceOrientation orientation) {
    if (coreData.stream.pushVideoConfig.orientation == orientation) {
      return;
    } else {
      ZegoLoggerService.logInfo(
        'orientation:$orientation',
        tag: 'uikit-service-core',
        subTag: 'update app orientation',
      );

      setInternalVideoConfig(
        coreData.stream.pushVideoConfig.copyWith(orientation: orientation),
      );
    }
  }

  void setVideoConfigByPreset(ZegoPresetResolution resolution) {
    if (coreData.stream.pushVideoConfig.resolution == resolution) {
      ZegoLoggerService.logInfo(
        'preset($resolution) is equal',
        tag: 'uikit-stream',
        subTag: 'set video config',
      );
      return;
    } else {
      ZegoLoggerService.logInfo(
        'preset:$resolution',
        tag: 'uikit-stream',
        subTag: 'set video config by preset',
      );

      setInternalVideoConfig(
        coreData.stream.pushVideoConfig.copyWith(resolution: resolution),
      );
    }
  }

  void updateVideoViewMode(bool useVideoViewAspectFill) {
    if (coreData.stream.useVideoViewAspectFill == useVideoViewAspectFill) {
      ZegoLoggerService.logInfo(
        'mode is equal',
        tag: 'uikit-stream',
        subTag: 'update video view mode',
      );
      return;
    } else {
      ZegoLoggerService.logInfo(
        'mode:$useVideoViewAspectFill',
        tag: 'uikit-stream',
        subTag: 'update video view mode',
      );
      coreData.stream.useVideoViewAspectFill = useVideoViewAspectFill;
      // TODO: need re preview, and re playStream
    }
  }

  void onInternalCustomCommandReceived(
    ZegoInRoomCommandReceivedData commandData,
  ) {
    ZegoLoggerService.logInfo(
      'on map custom command received, from user:${commandData.fromUser}, command:${commandData.command}',
      tag: 'uikit-service-core',
      subTag: 'custom command',
    );

    dynamic commandJson;
    try {
      commandJson = jsonDecode(commandData.command);
    } catch (e) {
      ZegoLoggerService.logInfo(
        'custom command is not a json, $e',
        tag: 'uikit-service-core',
        subTag: 'custom command',
      );
    }

    if (commandJson is! Map<String, dynamic>) {
      ZegoLoggerService.logInfo(
        'custom command is not a map',
        tag: 'uikit-service-core',
        subTag: 'custom command',
      );
      return;
    }

    final extraInfos = Map.from(commandJson);
    if (extraInfos.keys.contains(removeUserInRoomCommandKey)) {
      var selfKickedOut = false;
      final commandValue = extraInfos[removeUserInRoomCommandKey];
      if (commandValue is String) {
        /// compatible with web protocols
        final kickUserID = commandValue;
        selfKickedOut = kickUserID == coreData.user.localUser.id;
      } else if (commandValue is List<dynamic>) {
        final kickUserIDs = commandValue;
        selfKickedOut = kickUserIDs.contains(coreData.user.localUser.id);
      }

      if (selfKickedOut) {
        ZegoLoggerService.logInfo(
          'local user had been remove by ${commandData.fromUser.id}, auto leave room',
          tag: 'uikit-service-core',
          subTag: 'custom command',
        );
        leaveRoom(targetRoomID: commandData.roomID);

        coreData.user.roomUsers
            .getRoom(commandData.roomID)
            .meRemovedFromRoomStreamCtrl
            ?.add(commandData.fromUser.id);
      }
    } else if (extraInfos.keys.contains(turnCameraOnInRoomCommandKey) &&
        extraInfos[turnCameraOnInRoomCommandKey]!.toString() ==
            coreData.user.localUser.id) {
      ZegoLoggerService.logInfo(
        'local camera request turn on by ${commandData.fromUser}',
        tag: 'uikit-service-core',
        subTag: 'custom command',
      );
      coreData.stream.roomStreams
          .getRoom(commandData.roomID)
          .turnOnYourCameraRequestStreamCtrl
          ?.add(commandData.fromUser.id);
    } else if (extraInfos.keys.contains(turnCameraOffInRoomCommandKey) &&
        extraInfos[turnCameraOffInRoomCommandKey]!.toString() ==
            coreData.user.localUser.id) {
      ZegoLoggerService.logInfo(
        'local camera request turn off by ${commandData.fromUser}',
        tag: 'uikit-service-core',
        subTag: 'custom command',
      );
      turnCameraOn(
        coreData.user.localUser.id,
        false,
        targetRoomID: commandData.roomID,
      );
    } else if (extraInfos.keys.contains(turnMicrophoneOnInRoomCommandKey)) {
      final mapData =
          extraInfos[turnMicrophoneOnInRoomCommandKey] as Map<String, dynamic>;
      final userID = mapData[userIDCommandKey] ?? '';
      final muteMode = mapData[muteModeCommandKey] as bool? ?? false;

      if (userID == coreData.user.localUser.id) {
        ZegoLoggerService.logInfo(
          'local microphone request turn on by ${commandData.fromUser}',
          tag: 'uikit-service-core',
          subTag: 'custom command',
        );

        coreData.stream.roomStreams
            .getRoom(commandData.roomID)
            .turnOnYourMicrophoneRequestStreamCtrl
            ?.add(
              ZegoUIKitReceiveTurnOnLocalMicrophoneEvent(
                commandData.fromUser.id,
                muteMode,
              ),
            );
      }
    } else if (extraInfos.keys.contains(turnMicrophoneOffInRoomCommandKey)) {
      var userID = '';
      var muteMode = false;
      final commandValue = extraInfos[turnMicrophoneOffInRoomCommandKey];
      if (commandValue is String) {
        /// compatible with web protocols
        userID = commandValue;
      } else if (commandValue is Map<String, dynamic>) {
        /// support mute mode parameter
        final mapData = commandValue;
        userID = mapData[userIDCommandKey] ?? '';
        muteMode = mapData[muteModeCommandKey] as bool? ?? false;
      }

      if (userID == coreData.user.localUser.id) {
        ZegoLoggerService.logInfo(
          'local microphone request turn off by ${commandData.fromUser}',
          tag: 'uikit-service-core',
          subTag: 'custom command',
        );
        turnMicrophoneOn(
          coreData.user.localUser.id,
          false,
          muteMode: muteMode,
          targetRoomID: commandData.roomID,
        );
      }
    } else if (extraInfos.keys.contains(clearMessageInRoomCommandKey)) {
      final commandValue = extraInfos[clearMessageInRoomCommandKey];
      if (commandValue is String) {
        final messageType =
            ZegoInRoomMessageType.values[int.tryParse(commandValue) ?? 0];

        ZegoLoggerService.logInfo(
          'clear local message(type:$messageType) by ${commandData.fromUser}',
          tag: 'uikit-service-core',
          subTag: 'custom command',
        );

        clearLocalMessage(
          messageType,
          targetRoomID: commandData.roomID,
        );
      }
    }
  }

  ///
  Future<void> enableCustomVideoProcessing(bool enable) async {
    var type = ZegoVideoBufferType.CVPixelBuffer;
    if (Platform.isAndroid) {
      type = ZegoVideoBufferType.GLTexture2D;
    }

    ZegoLoggerService.logInfo(
      '${enable ? "enable" : "disable"} custom video processing, '
      'buffer type:$type, '
      'express engineState:${coreData.engine.stateNotifier.value}, ',
      tag: 'uikit-stream',
      subTag: 'custom video processing',
    );

    if (ZegoUIKitExpressEngineState.Stop ==
        coreData.engine.stateNotifier.value) {
      /// this api does not allow setting after the express internal engine starts;
      /// if set after the internal engine starts, it will cause the external video preprocessing to not be truly turned off/turned on
      /// so turned off/turned on only effect when engine state is stop
      await ZegoExpressEngine.instance.enableCustomVideoProcessing(
        enable,
        ZegoCustomVideoProcessConfig(type),
      );
    } else {
      coreData.engine.waitingEngineStopEnableValueOfCustomVideoProcessing =
          enable;

      coreData.engine.stateUpdatedSubscriptionByEnableCustomVideoProcessing
          ?.cancel();
      coreData.engine.stateUpdatedSubscriptionByEnableCustomVideoProcessing =
          coreData.engine.stateStreamCtrl.stream.listen(
        onWaitingEngineStopEnableCustomVideoProcessing,
      );
    }
  }

  void onWaitingEngineStopEnableCustomVideoProcessing(
    ZegoUIKitExpressEngineState engineState,
  ) {
    final targetEnabled =
        coreData.engine.waitingEngineStopEnableValueOfCustomVideoProcessing;

    ZegoLoggerService.logInfo(
      'onWaitingEngineStopEnableCustomVideoProcessing, '
      'target enabled:$targetEnabled, '
      'engineState:$engineState, ',
      tag: 'uikit-stream',
      subTag: 'custom video processing',
    );

    coreData.engine.waitingEngineStopEnableValueOfCustomVideoProcessing = false;
    coreData.engine.stateUpdatedSubscriptionByEnableCustomVideoProcessing
        ?.cancel();
    enableCustomVideoProcessing(targetEnabled);
  }
}

/// @nodoc
extension ZegoUIKitCoreBaseBeauty on ZegoUIKitCore {
  Future<void> enableBeauty(bool isOn) async {
    ZegoLoggerService.logInfo(
      '${isOn ? "enable" : "disable"} beauty',
      tag: 'uikit-beauty',
      subTag: 'effects',
    );

    ZegoExpressEngine.instance.enableEffectsBeauty(isOn);
  }

  Future<void> startEffectsEnv() async {
    ZegoLoggerService.logInfo(
      'start effects env',
      tag: 'uikit-beauty',
      subTag: 'effects',
    );

    await ZegoExpressEngine.instance.startEffectsEnv();
  }

  Future<void> stopEffectsEnv() async {
    ZegoLoggerService.logInfo(
      'stop effects env',
      tag: 'uikit-beauty',
      subTag: 'effects',
    );

    await ZegoExpressEngine.instance.stopEffectsEnv();
  }
}

/// @nodoc
extension ZegoUIKitCoreMixer on ZegoUIKitCore {
  Future<ZegoMixerStartResult> startMixerTask(ZegoMixerTask task) async {
    final startMixerResult = await ZegoExpressEngine.instance.startMixerTask(
      task,
    );
    ZegoLoggerService.logInfo(
      'code:${startMixerResult.errorCode}, '
      'extendedData:${startMixerResult.extendedData}',
      tag: 'uikit-mixstream',
      subTag: 'start mixer task',
    );

    if (ZegoErrorCode.CommonSuccess == startMixerResult.errorCode) {
      if (coreData.mixerSEITimer?.isActive ?? false) {
        coreData.mixerSEITimer?.cancel();
      }
      coreData.mixerSEITimer = Timer.periodic(
        const Duration(milliseconds: 300),
        (timer) {
          coreData.device.syncDeviceStatusBySEI();
        },
      );
    }

    return startMixerResult;
  }

  Future<ZegoMixerStopResult> stopMixerTask(ZegoMixerTask task) async {
    final stopMixerResult = await ZegoExpressEngine.instance.stopMixerTask(
      task,
    );
    ZegoLoggerService.logInfo(
      'code:${stopMixerResult.errorCode}',
      tag: 'uikit-mixstream',
      subTag: 'stop mixer task',
    );

    if (coreData.mixerSEITimer?.isActive ?? false) {
      coreData.mixerSEITimer?.cancel();
    }

    return stopMixerResult;
  }

  Future<void> startPlayMixAudioVideo(
    String mixerID,
    List<ZegoUIKitCoreUser> users,
    Map<String, int> userSoundIDs, {
    required String targetRoomID,
    PlayerStateUpdateCallback? onPlayerStateUpdated,
  }) {
    return coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .startPlayMixAudioVideo(
          mixerID,
          users,
          userSoundIDs,
          onPlayerStateUpdated: onPlayerStateUpdated,
        );
  }

  Future<void> stopPlayMixAudioVideo(
    String mixerID, {
    required String targetRoomID,
  }) {
    return coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .stopPlayMixAudioVideo(mixerID);
  }
}

/// @nodoc
extension ZegoUIKitCoreAudioVideo on ZegoUIKitCore {
  Future<void> startPlayAnotherRoomAudioVideo(
    String roomID,
    String userID,
    String userName, {
    required String targetRoomID,
    PlayerStateUpdateCallback? onPlayerStateUpdated,
  }) async {
    return coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .startPlayAnotherRoomAudioVideo(
          roomID,
          userID,
          userName,
          onPlayerStateUpdated: onPlayerStateUpdated,
        );
  }

  Future<void> stopPlayAnotherRoomAudioVideo(
    String userID, {
    required String targetRoomID,
  }) async {
    return coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .stopPlayAnotherRoomAudioVideo(
          userID,
        );
  }
}

/// @nodoc
extension ZegoUIKitCoreScreenShare on ZegoUIKitCore {}

extension ZegoUIKitCoreDevice on ZegoUIKitCore {
  Future<void> setAudioDeviceMode(ZegoUIKitAudioDeviceMode deviceMode) async {
    ZegoLoggerService.logWarn(
      'set audio device mode:$deviceMode',
      tag: 'uikit-core',
      subTag: 'device',
    );

    return ZegoExpressEngine.instance.setAudioDeviceMode(
      ZegoAudioDeviceMode.values[deviceMode.index],
    );
  }
}
