// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/components/outside_room_audio_video/internal.dart';
import 'package:zego_uikit/src/services/internal/core/data/media.dart';
import 'package:zego_uikit/src/services/internal/core/data/message.dart';
import 'package:zego_uikit/src/services/internal/core/data/network_timestamp.dart';
import 'package:zego_uikit/src/services/internal/core/data/screen_sharing.dart';
import 'package:zego_uikit/src/services/internal/core/data/stream.dart';
import 'package:zego_uikit/src/services/internal/core/data/user.dart';
import 'package:zego_uikit/src/services/internal/core/event/event.dart';
import 'package:zego_uikit/src/services/internal/core/event_handler.dart';
import 'package:zego_uikit/src/services/services.dart';

part 'data/data.dart';

part 'defines.dart';

part 'media.dart';

part 'error.dart';

part 'device.dart';

part 'message.dart';

/// @nodoc
class ZegoUIKitCore
    with
        ZegoUIKitCoreMessage,
        ZegoUIKitCoreEventHandler,
        ZegoUIKitCoreDataError,
        ZegoUIKitCoreDataDevice {
  ZegoUIKitCore._internal() {
    eventHandler.initConnectivity();
  }

  static final ZegoUIKitCore shared = ZegoUIKitCore._internal();

  final ZegoUIKitReporter reporter = ZegoUIKitReporter();
  final ZegoUIKitCoreData coreData = ZegoUIKitCoreData();
  var event = ZegoUIKitEvent();

  bool isInit = false;
  bool isNeedDisableWakelock = false;
  bool playingStreamInPIPUnderIOS = false;
  final expressEngineCreatedNotifier = ValueNotifier<bool>(false);
  List<StreamSubscription<dynamic>?> subscriptions = [];
  String? version;

  Future<String> getZegoUIKitVersion() async {
    if (null == version) {
      final expressVersion = await ZegoExpressEngine.getVersion();
      final mobileInfo = 'platform:${Platform.operatingSystem}, '
          'version:${Platform.operatingSystemVersion}';

      const zegoUIKitVersion = 'zego_uikit: 2.28.8; ';
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
        this.playingStreamInPIPUnderIOS = playingStreamInPIPUnderIOS;
        coreData.isEnablePlatformView = enablePlatformView ?? false;

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
      'scenario:$scenario, ',
      tag: 'uikit-service-core',
      subTag: 'init',
    );

    reporter.create(
      appID: appID,
      signOrToken: appSign.isNotEmpty ? appSign : token,
      params: {},
    );

    this.playingStreamInPIPUnderIOS = playingStreamInPIPUnderIOS;
    coreData.init();
    coreData.isEnablePlatformView = enablePlatformView ?? false;

    event.init();
    error.init();
    await device.init();
    initEventHandle();

    ZegoExpressEngine.setEngineConfig(ZegoEngineConfig(advancedConfig: {
      'vcap_external_mem_class': '1',
    }));

    ZegoLoggerService.logInfo(
      'create engine with profile,'
      'withoutCreateEngine:$withoutCreateEngine, ',
      tag: 'uikit-service-core',
      subTag: 'init',
    );
    if (withoutCreateEngine) {
      /// make it has been created (android call offline invitation will have a scene created in advance)
      expressEngineCreatedNotifier.value = true;
    } else {
      try {
        await ZegoExpressEngine.createEngineWithProfile(
          ZegoEngineProfile(
            appID,
            scenario,
            appSign: appSign,
            enablePlatformView: enablePlatformView,
          ),
        ).then((value) {
          ZegoLoggerService.logInfo(
            'engine created',
            tag: 'uikit-service-core',
            subTag: 'init',
          );
        });

        expressEngineCreatedNotifier.value = true;
      } catch (e) {
        ZegoLoggerService.logInfo(
          'engine error:$e, '
          'app sign:$appSign, ',
          tag: 'uikit-service-core',
          subTag: 'init',
        );

        ZegoUIKitCore.shared.error.errorStreamCtrl?.add(
          ZegoUIKitError(
            code: -1,
            message: e.toString(),
            method: 'createEngineWithProfile',
          ),
        );
        expressEngineCreatedNotifier.value = false;
      }
    }

    ZegoExpressEngine.setEngineConfig(ZegoEngineConfig(advancedConfig: {
      'notify_remote_device_unknown_status': 'true',
      'notify_remote_device_init_status': 'true',
      'keep_audio_session_active': 'true',
    }));

    ZegoLoggerService.logInfo(
      'get network time info',
      tag: 'uikit-service-core',
      subTag: 'init',
    );
    await ZegoExpressEngine.instance.getNetworkTimeInfo().then((timeInfo) {
      coreData.initNetworkTimestamp(timeInfo.timestamp);

      ZegoLoggerService.logInfo(
        'network time info is init, timestamp:${timeInfo.timestamp}, max deviation:${timeInfo.maxDeviation}',
        tag: 'uikit-service-core',
        subTag: 'init',
      );
    });

    final initAudioRoute = await ZegoExpressEngine.instance.getAudioRouteType();
    coreData.localUser.audioRoute.value =
        ZegoUIKitAudioRouteExtension.fromSDKValue(initAudioRoute);
    coreData.localUser.lastAudioRoute =
        ZegoUIKitAudioRouteExtension.fromSDKValue(initAudioRoute);

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
    error.uninit();
    device.uninit();
    uninitEventHandle();

    clear();

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }

    expressEngineCreatedNotifier.value = false;
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

  void clear() {
    coreData.clear();
    message.clear();
  }

  void initEventHandle() {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'uikit-service-core',
      subTag: 'init event handle',
    );

    event.express.register(eventHandler);
    event.express.register(error);
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
    event.express.unregister(error);
    event.express.unregister(message);

    event.media.unregister(coreData.media);
  }

  ValueNotifier<DateTime?> getNetworkTime() {
    return coreData.networkDateTime;
  }

  void login(String id, String name) {
    coreData.login(id, name);
  }

  void logout() {
    coreData.logout();
  }

  bool hasLoginSameRoom(String roomID) {
    return coreData.room.id == roomID;
  }

  Future<ZegoRoomLoginResult> joinRoom(
    String roomID, {
    String token = '',
    bool markAsLargeRoom = false,
    bool keepWakeScreen = true,
    bool isSimulated = false,
  }) async {
    if (ZegoAudioVideoViewOutsideRoomID.isRandomRoomID(coreData.room.id)) {
      await leaveRoom();
    }

    if (hasLoginSameRoom(roomID)) {
      ZegoLoggerService.logInfo(
        'already in room($roomID)',
        tag: 'uikit-room',
        subTag: 'join room',
      );

      return ZegoRoomLoginResult(0, {});
    }

    ZegoLoggerService.logInfo(
      'room id:"$roomID", '
      'has token:${token.isNotEmpty}, '
      'markAsLargeRoom:$markAsLargeRoom, '
      'network state:${ZegoUIKit().getNetworkState()}, ',
      tag: 'uikit-room',
      subTag: 'join room',
    );

    clear();
    coreData.setRoom(roomID, markAsLargeRoom: markAsLargeRoom);

    event.init();

    Future<bool> originWakelockEnabledF = Future.value(false);
    if (keepWakeScreen) {
      originWakelockEnabledF = WakelockPlus.enabled;
    }

    ZegoLoggerService.logInfo(
      'try join room id:"$roomID" by ${coreData.localUser}, '
      'isSimulated:$isSimulated, ',
      tag: 'uikit-room',
      subTag: 'join room',
    );

    final joinRoomResult = isSimulated
        ? ZegoRoomLoginResult(0, {})
        : await ZegoExpressEngine.instance.loginRoom(
            roomID,
            coreData.localUser.toZegoUser(),
            config: ZegoRoomConfig(0, true, token),
          );
    ZegoLoggerService.logInfo(
      'result:${joinRoomResult.errorCode},'
      'extendedData:${joinRoomResult.extendedData}',
      tag: 'uikit-room',
      subTag: 'join room',
    );

    if (ZegoErrorCode.CommonSuccess == joinRoomResult.errorCode) {
      await coreData.startPublishOrNot();
      await syncDeviceStatusByStreamExtraInfo();

      if (isSimulated) {
        /// at this time, express will not throw the stream event again,
        /// and it is necessary to actively obtain
        await coreData.syncRoomStream();
      }

      if (keepWakeScreen) {
        final originWakelockEnabled = await originWakelockEnabledF;
        if (originWakelockEnabled) {
          isNeedDisableWakelock = false;
        } else {
          isNeedDisableWakelock = true;
          WakelockPlus.enable();
        }
      }

      await ZegoExpressEngine.instance.startSoundLevelMonitor();
    } else if (joinRoomResult.errorCode == ZegoErrorCode.RoomCountExceed) {
      ZegoLoggerService.logInfo(
        'room count exceed',
        tag: 'uikit-room',
        subTag: 'join room',
      );

      await leaveRoom();
      return joinRoom(roomID);
    } else {
      ZegoLoggerService.logInfo(
        'failed: ${joinRoomResult.errorCode}, ${joinRoomResult.extendedData}',
        tag: 'uikit-room',
        subTag: 'join room',
      );
    }

    return joinRoomResult;
  }

  Future<ZegoRoomLogoutResult> leaveRoom({
    String? targetRoomID,
  }) async {
    ZegoLoggerService.logInfo(
      'current room is ${coreData.room.id}, '
      'target room id:$targetRoomID'
      'network state:${ZegoUIKit().getNetworkState()}, ',
      tag: 'uikit-room',
      subTag: 'leave room',
    );

    if (targetRoomID != null && targetRoomID != coreData.room.id) {
      ZegoLoggerService.logInfo(
        'room id is different, not need to leave',
        tag: 'uikit-room',
        subTag: 'leave room',
      );

      return ZegoRoomLogoutResult(0, {});
    }

    if (isNeedDisableWakelock) {
      WakelockPlus.disable();
    }

    clear();
    coreData.canvasViewCreateQueue.clear();

    await ZegoExpressEngine.instance.stopSoundLevelMonitor();

    final leaveResult = await ZegoExpressEngine.instance.logoutRoom();
    if (ZegoErrorCode.CommonSuccess != leaveResult.errorCode) {
      ZegoLoggerService.logError(
        'failed: ${leaveResult.errorCode}, ${leaveResult.extendedData}',
        tag: 'uikit-room',
        subTag: 'leave room',
      );
    } else {
      ZegoLoggerService.logInfo(
        'success',
        tag: 'uikit-room',
        subTag: 'leave room',
      );
    }

    event.uninit();

    return leaveResult;
  }

  Future<void> renewRoomToken(String token) async {
    if (coreData.room.id.isEmpty) {
      ZegoLoggerService.logInfo(
        'not in room now',
        tag: 'uikit-room',
        subTag: 'renewToken',
      );
    }

    if (token.isEmpty) {
      ZegoLoggerService.logInfo(
        'token is empty',
        tag: 'uikit-room',
        subTag: 'renewToken',
      );
    }

    ZegoLoggerService.logInfo(
      'renew now',
      tag: 'uikit-room',
      subTag: 'renewToken',
    );

    await ZegoExpressEngine.instance.renewToken(coreData.room.id, token);
  }

  Future<int> removeUserFromRoom(List<String> userIDs) async {
    ZegoLoggerService.logInfo(
      'users:$userIDs',
      tag: 'uikit-room',
      subTag: 'remove users',
    );

    if (coreData.room.isLargeRoom || coreData.room.markAsLargeRoom) {
      ZegoLoggerService.logInfo(
        'remove all users, because is a large room',
        tag: 'uikit-room',
        subTag: 'remove users',
      );
      return sendInRoomCommand(
        const JsonEncoder().convert({removeUserInRoomCommandKey: userIDs}),
        [],
      );
    } else {
      return sendInRoomCommand(
        const JsonEncoder().convert({removeUserInRoomCommandKey: userIDs}),
        userIDs,
      );
    }
  }

  void clearLocalMessage(ZegoInRoomMessageType type) {
    ZegoLoggerService.logInfo(
      '',
      tag: 'uikit-room',
      subTag: 'remove local message',
    );

    (type == ZegoInRoomMessageType.broadcastMessage)
        ? ZegoUIKitCore.shared.coreData.broadcastMessage.clear()
        : ZegoUIKitCore.shared.coreData.barrageMessage.clear();
  }

  Future<int> clearRemoteMessage(ZegoInRoomMessageType type) async {
    ZegoLoggerService.logInfo(
      '',
      tag: 'uikit-room',
      subTag: 'remove remote message',
    );

    return sendInRoomCommand(
      const JsonEncoder().convert({
        clearMessageInRoomCommandKey: type.index.toString(),
      }),
      [],
    );
  }

  Future<bool> setRoomProperty(String key, String value) async {
    return updateRoomProperties({key: value});
  }

  Future<bool> updateRoomProperties(Map<String, String> properties) async {
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

      error.errorStreamCtrl?.add(ZegoUIKitError(
        code: ZegoUIKitErrorCode.coreNotInit,
        message: 'core not init',
        method: 'updateRoomProperties',
      ));

      return false;
    }

    if (coreData.room.id.isEmpty) {
      ZegoLoggerService.logError(
        'room is not login',
        tag: 'uikit-room-property',
        subTag: 'update room properties',
      );

      error.errorStreamCtrl?.add(ZegoUIKitError(
        code: ZegoUIKitErrorCode.roomNotLogin,
        message: 'room not login',
        method: 'updateRoomProperties',
      ));

      return false;
    }

    if (coreData.room.propertiesAPIRequesting) {
      properties.forEach((key, value) {
        coreData.room.pendingProperties[key] = value;
      });
      ZegoLoggerService.logInfo(
        'room property is updating, pending: ${coreData.room.pendingProperties}',
        tag: 'uikit-room-property',
        subTag: 'update room properties',
      );
      return false;
    }

    final localUser = ZegoUIKit().getLocalUser();

    var isAllPropertiesSame = coreData.room.properties.isNotEmpty;
    properties.forEach((key, value) {
      if (coreData.room.properties.containsKey(key) &&
          coreData.room.properties[key]!.value == value) {
        ZegoLoggerService.logInfo(
          'key exist and value is same, ${coreData.room.properties}',
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
        if (coreData.room.properties.containsKey(key)) {
          oldProperties[key] =
              RoomProperty.copyFrom(coreData.room.properties[key]!);
          oldProperties[key]!.updateUserID = localUser.id;
        }
      })

      /// local update
      ..forEach((key, value) {
        if (coreData.room.properties.containsKey(key)) {
          coreData.room.properties[key]!.oldValue =
              coreData.room.properties[key]!.value;
          coreData.room.properties[key]!.value = value;
          coreData.room.properties[key]!.updateTime =
              coreData.networkDateTime_.millisecondsSinceEpoch;
          coreData.room.properties[key]!.updateFromRemote = false;
        } else {
          coreData.room.properties[key] = RoomProperty(
            key,
            value,
            coreData.networkDateTime_.millisecondsSinceEpoch,
            localUser.id,
            false,
          );
        }
      });

    /// server update
    final extraInfoMap = <String, String>{};
    coreData.room.properties.forEach((key, value) {
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
    coreData.room.propertiesAPIRequesting = true;
    return ZegoExpressEngine.instance
        .setRoomExtraInfo(coreData.room.id, 'extra_info', extraInfo)
        .then((ZegoRoomSetRoomExtraInfoResult result) {
      ZegoLoggerService.logInfo(
        'set room extra info, result:${result.errorCode}',
        tag: 'uikit-room-property',
        subTag: 'update room properties',
      );
      if (ZegoErrorCode.CommonSuccess == result.errorCode) {
        properties.forEach((key, value) {
          if (!coreData.room.properties.containsKey(key)) {
            return;
          }

          /// exception
          final updatedProperty = coreData.room.properties[key]!
            ..updateFromRemote = true;
          coreData.room.propertyUpdateStream?.add(updatedProperty);
          coreData.room.propertiesUpdatedStream?.add({key: updatedProperty});
        });
      } else {
        properties.forEach((key, value) {
          if (coreData.room.properties.containsKey(key) &&
              oldProperties.containsKey(key)) {
            coreData.room.properties[key]!.copyFrom(oldProperties[key]!);
          }
        });
        ZegoLoggerService.logError(
          'failed, properties:$properties, error code:${result.errorCode}',
          tag: 'uikit-room-property',
          subTag: 'update room properties',
        );
      }

      coreData.room.propertiesAPIRequesting = false;
      if (coreData.room.pendingProperties.isNotEmpty) {
        final pendingProperties =
            Map<String, String>.from(coreData.room.pendingProperties);
        coreData.room.pendingProperties.clear();
        ZegoLoggerService.logInfo(
          'update pending properties:$pendingProperties',
          tag: 'uikit-room-property',
          subTag: 'update room properties',
        );
        updateRoomProperties(pendingProperties);
      }

      return ZegoErrorCode.CommonSuccess != result.errorCode;
    });
  }

  Future<int> sendInRoomCommand(
    String command,
    List<String> toUserIDs,
  ) async {
    ZegoLoggerService.logInfo(
      'send in-room command, command:$command, toUserIDs:$toUserIDs',
      tag: 'uikit-room-command',
      subTag: 'custom command',
    );

    return ZegoExpressEngine.instance
        .sendCustomCommand(
      coreData.room.id,
      command,
      toUserIDs.isEmpty
          // empty mean send to all users
          ? coreData.remoteUsersList
              .map((ZegoUIKitCoreUser user) => ZegoUser(user.id, user.name))
              .toList()
          : toUserIDs
              .map((String userID) => coreData.remoteUsersList
                  .firstWhere((element) => element.id == userID,
                      orElse: ZegoUIKitCoreUser.empty)
                  .toZegoUser())
              .toList(),
    )
        .then(
      (ZegoIMSendCustomCommandResult result) {
        ZegoLoggerService.logInfo(
          'send in-room command, result:${result.errorCode}',
          tag: 'uikit-room-command',
          subTag: 'custom command',
        );

        return result.errorCode;
      },
    );
  }

  Future<bool> useFrontFacingCamera(bool isFrontFacing) async {
    if (!coreData.localUser.camera.value) {
      ZegoLoggerService.logInfo(
        'camera not open now',
        tag: 'uikit-camera',
        subTag: 'use front facing camera',
      );

      return false;
    }

    if (isFrontFacing == coreData.localUser.isFrontFacing.value) {
      ZegoLoggerService.logInfo(
        'Already ${isFrontFacing ? 'front' : 'back'}',
        tag: 'uikit-camera',
        subTag: 'use front facing camera',
      );

      return true;
    }

    if (coreData.isUsingFrontCameraRequesting) {
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
    coreData.isUsingFrontCameraRequesting = true;

    coreData.localUser.mainChannel.isCapturedVideoFirstFrame.value = false;
    coreData.localUser.mainChannel.isCapturedVideoFirstFrame
        .addListener(onCapturedVideoFirstFrameAfterSwitchCamera);
    coreData.localUser.mainChannel.isRenderedVideoFirstFrame.value = false;

    coreData.localUser.isFrontFacing.value = isFrontFacing;
    await ZegoExpressEngine.instance.useFrontCamera(isFrontFacing);

    final videoMirrorMode = isFrontFacing
        ? (coreData.localUser.isVideoMirror.value
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
    coreData.localUser.mainChannel.isCapturedVideoFirstFrame
        .removeListener(onCapturedVideoFirstFrameAfterSwitchCamera);

    coreData.isUsingFrontCameraRequesting = false;

    ZegoLoggerService.logInfo(
      'onCapturedVideoFirstFrameAfterSwitchCamera',
      tag: 'uikit-camera',
      subTag: 'use front facing camera',
    );
  }

  void enableVideoMirroring(bool isVideoMirror) {
    coreData.localUser.isVideoMirror.value = isVideoMirror;

    ZegoExpressEngine.instance.setVideoMirrorMode(
      isVideoMirror
          ? ZegoVideoMirrorMode.BothMirror
          : ZegoVideoMirrorMode.NoMirror,
    );
  }

  void setAudioVideoResourceMode(ZegoAudioVideoResourceMode mode) {
    coreData.playResourceMode = mode;

    ZegoLoggerService.logInfo(
      'mode: $mode',
      tag: 'uikit-service-core',
      subTag: 'set audio video resource mode',
    );
  }

  Future<void> startPlayAllAudioVideo() async {
    await coreData.muteAllPlayStreamAudioVideo(false);
  }

  Future<void> stopPlayAllAudioVideo() async {
    await coreData.muteAllPlayStreamAudioVideo(true);
  }

  Future<void> startPlayAllAudio() async {
    await coreData.muteAllPlayStreamAudio(false);
  }

  Future<void> stopPlayAllAudio() async {
    await coreData.muteAllPlayStreamAudio(true);
  }

  Future<bool> muteUserAudioVideo(String userID, bool mute) async {
    return coreData.mutePlayStreamAudioVideo(
      userID,
      mute,
      forAudio: true,
      forVideo: true,
    );
  }

  Future<bool> muteUserAudio(String userID, bool mute) async {
    return coreData.mutePlayStreamAudioVideo(
      userID,
      mute,
      forAudio: true,
      forVideo: false,
    );
  }

  Future<bool> muteUserVideo(String userID, bool mute) async {
    return coreData.mutePlayStreamAudioVideo(
      userID,
      mute,
      forAudio: false,
      forVideo: true,
    );
  }

  bool setAudioOutputToSpeaker(bool useSpeaker) {
    if (!isInit) {
      ZegoLoggerService.logError(
        'core had not init',
        tag: 'uikit-service-core',
        subTag: 'set audio output to speaker',
      );

      error.errorStreamCtrl?.add(ZegoUIKitError(
        code: ZegoUIKitErrorCode.coreNotInit,
        message: 'core not init',
        method: 'setAudioOutputToSpeaker',
      ));

      return false;
    }

    if (useSpeaker) {
      if (ZegoUIKitAudioRoute.speaker == coreData.localUser.audioRoute.value) {
        ZegoLoggerService.logInfo(
          'already ${useSpeaker ? 'use' : 'not use'}',
          tag: 'uikit-service-core',
          subTag: 'set audio output to speaker',
        );

        return true;
      }

      if (ZegoUIKitAudioRoute.headphone ==
          coreData.localUser.audioRoute.value) {
        ZegoLoggerService.logWarn(
          'Currently using headphone, cannot be set as speaker.',
          tag: 'uikit-service-core',
          subTag: 'set audio output to speaker',
        );

        return false;
      }
    }

    ZegoLoggerService.logInfo(
      'use:$useSpeaker',
      tag: 'uikit-service-core',
      subTag: 'set audio output to speaker',
    );
    ZegoExpressEngine.instance.setAudioRouteToSpeaker(useSpeaker);

    // TODO: use sdk callback to update audioRoute
    if (useSpeaker) {
      coreData.localUser.lastAudioRoute = coreData.localUser.audioRoute.value;
      coreData.localUser.audioRoute.value = ZegoUIKitAudioRoute.speaker;
    } else {
      coreData.localUser.audioRoute.value = coreData.localUser.lastAudioRoute;
    }

    return true;
  }

  Future<bool> turnCameraOn(String userID, bool isOn) async {
    if (coreData.localUser.id == userID) {
      return turnOnLocalCamera(isOn);
    } else {
      final isLargeRoom =
          coreData.room.isLargeRoom || coreData.room.markAsLargeRoom;

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
              isLargeRoom ? [] : [userID],
            );
      } else {
        return ZegoUIKitErrorCode.success ==
            await sendInRoomCommand(
              const JsonEncoder()
                  .convert({turnCameraOffInRoomCommandKey: userID}),
              isLargeRoom ? [] : [userID],
            );
      }
    }
  }

  Future<bool> turnOnLocalCamera(bool isOn) async {
    if (!isInit) {
      ZegoLoggerService.logError(
        'core had not init',
        tag: 'uikit-camera',
        subTag: 'switch camera',
      );

      error.errorStreamCtrl?.add(ZegoUIKitError(
        code: ZegoUIKitErrorCode.coreNotInit,
        message: 'core not init',
        method: 'turnOnLocalCamera',
      ));

      return false;
    }

    if (isOn == coreData.localUser.camera.value) {
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

    coreData.localUser.isFrontTriggerByTurnOnCamera.value = true;
    coreData.localUser.cameraMuteMode.value = false;
    coreData.localUser.camera.value = isOn;

    if (isOn) {
      await coreData.startPreview();
    } else {
      await coreData.stopPreview();
    }

    await ZegoExpressEngine.instance.enableCamera(isOn);

    await coreData.startPublishOrNot();

    await syncDeviceStatusByStreamExtraInfo();

    return true;
  }

  void turnMicrophoneOn(String userID, bool isOn, {bool muteMode = false}) {
    if (coreData.localUser.id == userID) {
      turnOnLocalMicrophone(isOn, muteMode: muteMode);
    } else {
      final isLargeRoom =
          coreData.room.isLargeRoom || coreData.room.markAsLargeRoom;

      ZegoLoggerService.logInfo(
        "turn ${isOn ? "on" : "off"} $userID microphone, "
        "muteMode:$muteMode, "
        "is large room:$isLargeRoom, ",
        tag: 'uikit-microphone',
        subTag: 'switch microphone',
      );

      if (isOn) {
        sendInRoomCommand(
          const JsonEncoder().convert(
            {
              turnMicrophoneOnInRoomCommandKey: {
                userIDCommandKey: userID,
                muteModeCommandKey: muteMode,
              },
            },
          ),
          isLargeRoom ? [userID] : [],
        );
      } else {
        sendInRoomCommand(
          const JsonEncoder().convert(
            {
              turnMicrophoneOffInRoomCommandKey: {
                userIDCommandKey: userID,
                muteModeCommandKey: muteMode,
              },
            },
          ),
          isLargeRoom ? [userID] : [],
        );
      }
    }
  }

  Future<void> turnOnLocalMicrophone(bool isOn, {bool muteMode = false}) async {
    if (!isInit) {
      ZegoLoggerService.logError(
        'turn ${isOn ? "on" : "off"} local microphone, core had not init',
        tag: 'uikit-microphone',
        subTag: 'switch microphone',
      );

      error.errorStreamCtrl?.add(ZegoUIKitError(
        code: ZegoUIKitErrorCode.coreNotInit,
        message: 'core not init',
        method: 'turnOnLocalMicrophone',
      ));

      return;
    }

    if ((isOn == coreData.localUser.microphone.value) &&
        (muteMode == coreData.localUser.microphoneMuteMode.value)) {
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
      coreData.localUser.microphoneMuteMode.value = false;
    } else {
      if (muteMode) {
        await ZegoExpressEngine.instance.muteMicrophone(false);
        await ZegoExpressEngine.instance.mutePublishStreamAudio(true);
        coreData.localUser.microphoneMuteMode.value = true;

        /// local sound level should be mute too
        coreData.localUser.mainChannel.soundLevel?.add(0.0);
      } else {
        await ZegoExpressEngine.instance.muteMicrophone(true);
        await ZegoExpressEngine.instance.mutePublishStreamAudio(false);
        coreData.localUser.microphoneMuteMode.value = false;
      }
    }

    coreData.localUser.microphone.value = isOn;
    await coreData.startPublishOrNot();

    await syncDeviceStatusByStreamExtraInfo();
  }

  Future<void> syncDeviceStatusByStreamExtraInfo() async {
    // sync device status via stream extra info
    final streamExtraInfo = <String, dynamic>{
      streamExtraInfoCameraKey: coreData.localUser.camera.value,
      streamExtraInfoMicrophoneKey: coreData.localUser.microphone.value
    };

    final extraInfo = jsonEncode(streamExtraInfo);
    await ZegoExpressEngine.instance.setStreamExtraInfo(extraInfo);
    await syncDeviceStatusBySEI();
  }

  Future<void> syncDeviceStatusBySEI() async {
    final seiMap = <String, dynamic>{
      ZegoUIKitSEIDefines.keyCamera: coreData.localUser.camera.value,
      ZegoUIKitSEIDefines.keyMicrophone: coreData.localUser.microphone.value,
    };
    await coreData.sendSEI(
      ZegoUIKitInnerSEIType.mixerDeviceState.name,
      seiMap,
      streamType: ZegoStreamType.main,
    );
  }

  void updateTextureRendererOrientation(Orientation orientation) {
    switch (orientation) {
      case Orientation.portrait:
        ZegoExpressEngine.instance
            .setAppOrientation(DeviceOrientation.portraitUp);
        break;
      case Orientation.landscape:
        ZegoExpressEngine.instance
            .setAppOrientation(DeviceOrientation.landscapeLeft);
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
      config.toSDK,
      channel: streamType.channel,
    );
    coreData.localUser.mainChannel.viewSize.value = Size(
      config.width.toDouble(),
      config.height.toDouble(),
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

    minimizeVideoConfig ??= ZegoUIKitVideoConfig.preset360P();

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
      minimizeVideoConfig.width,
      minimizeVideoConfig.height,
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
    if (coreData.pushVideoConfig.needUpdateVideoConfig(config)) {
      final zegoVideoConfig = config.toZegoVideoConfig();
      ZegoExpressEngine.instance.setVideoConfig(
        zegoVideoConfig,
        channel: ZegoPublishChannel.Main,
      );
      coreData.localUser.mainChannel.viewSize.value = Size(
        zegoVideoConfig.captureWidth.toDouble(),
        zegoVideoConfig.captureHeight.toDouble(),
      );
    }

    if (coreData.pushVideoConfig.needUpdateOrientation(config)) {
      ZegoExpressEngine.instance.setAppOrientation(
        config.orientation,
        channel: ZegoPublishChannel.Main,
      );
    }

    coreData.pushVideoConfig = config;
  }

  void updateAppOrientation(DeviceOrientation orientation) {
    if (coreData.pushVideoConfig.orientation == orientation) {
      return;
    } else {
      ZegoLoggerService.logInfo(
        'orientation:$orientation',
        tag: 'uikit-service-core',
        subTag: 'update app orientation',
      );

      setInternalVideoConfig(
        coreData.pushVideoConfig.copyWith(orientation: orientation),
      );
    }
  }

  void setVideoConfigByPreset(ZegoPresetResolution resolution) {
    if (coreData.pushVideoConfig.resolution == resolution) {
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
        coreData.pushVideoConfig.copyWith(resolution: resolution),
      );
    }
  }

  void updateVideoViewMode(bool useVideoViewAspectFill) {
    if (coreData.pushVideoConfig.useVideoViewAspectFill ==
        useVideoViewAspectFill) {
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
      coreData.pushVideoConfig.useVideoViewAspectFill = useVideoViewAspectFill;
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
        selfKickedOut = kickUserID == coreData.localUser.id;
      } else if (commandValue is List<dynamic>) {
        final kickUserIDs = commandValue;
        selfKickedOut = kickUserIDs.contains(coreData.localUser.id);
      }

      if (selfKickedOut) {
        ZegoLoggerService.logInfo(
          'local user had been remove by ${commandData.fromUser.id}, auto leave room',
          tag: 'uikit-service-core',
          subTag: 'custom command',
        );
        leaveRoom();

        coreData.meRemovedFromRoomStreamCtrl?.add(commandData.fromUser.id);
      }
    } else if (extraInfos.keys.contains(turnCameraOnInRoomCommandKey) &&
        extraInfos[turnCameraOnInRoomCommandKey]!.toString() ==
            coreData.localUser.id) {
      ZegoLoggerService.logInfo(
        'local camera request turn on by ${commandData.fromUser}',
        tag: 'uikit-service-core',
        subTag: 'custom command',
      );
      coreData.turnOnYourCameraRequestStreamCtrl?.add(commandData.fromUser.id);
    } else if (extraInfos.keys.contains(turnCameraOffInRoomCommandKey) &&
        extraInfos[turnCameraOffInRoomCommandKey]!.toString() ==
            coreData.localUser.id) {
      ZegoLoggerService.logInfo(
        'local camera request turn off by ${commandData.fromUser}',
        tag: 'uikit-service-core',
        subTag: 'custom command',
      );
      turnCameraOn(coreData.localUser.id, false);
    } else if (extraInfos.keys.contains(turnMicrophoneOnInRoomCommandKey)) {
      final mapData =
          extraInfos[turnMicrophoneOnInRoomCommandKey] as Map<String, dynamic>;
      final userID = mapData[userIDCommandKey] ?? '';
      final muteMode = mapData[muteModeCommandKey] as bool? ?? false;

      if (userID == coreData.localUser.id) {
        ZegoLoggerService.logInfo(
          'local microphone request turn on by ${commandData.fromUser}',
          tag: 'uikit-service-core',
          subTag: 'custom command',
        );

        coreData.turnOnYourMicrophoneRequestStreamCtrl
            ?.add(ZegoUIKitReceiveTurnOnLocalMicrophoneEvent(
          commandData.fromUser.id,
          muteMode,
        ));
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

      if (userID == coreData.localUser.id) {
        ZegoLoggerService.logInfo(
          'local microphone request turn off by ${commandData.fromUser}',
          tag: 'uikit-service-core',
          subTag: 'custom command',
        );
        turnMicrophoneOn(coreData.localUser.id, false, muteMode: muteMode);
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

        clearLocalMessage(messageType);
      }
    }
  }

  void enableCustomVideoProcessing(bool enable) {
    var type = ZegoVideoBufferType.CVPixelBuffer;
    if (Platform.isAndroid) {
      type = ZegoVideoBufferType.GLTexture2D;
    }

    ZegoLoggerService.logInfo(
      '${enable ? "enable" : "disable"} custom video processing, '
      'buffer type:$type, '
      'express engineState:${coreData.engineState}, ',
      tag: 'uikit-stream',
      subTag: 'custom video processing',
    );

    if (ZegoUIKitExpressEngineState.stop == coreData.engineState) {
      /// this api does not allow setting after the express internal engine starts;
      /// if set after the internal engine starts, it will cause the external video preprocessing to not be truly turned off/turned on
      /// so turned off/turned on only effect when engine state is stop
      ZegoExpressEngine.instance.enableCustomVideoProcessing(
        enable,
        ZegoCustomVideoProcessConfig(type),
      );
    } else {
      coreData.waitingEngineStopEnableCustomVideoProcessing = enable;

      coreData.engineStateUpdatedSubscription?.cancel();
      coreData.engineStateUpdatedSubscription = coreData
          .engineStateStreamCtrl.stream
          .listen(onWaitingEngineStopEnableCustomVideoProcessing);
    }
  }

  void onWaitingEngineStopEnableCustomVideoProcessing(
    ZegoUIKitExpressEngineState engineState,
  ) {
    final targetEnabled = coreData.waitingEngineStopEnableCustomVideoProcessing;

    ZegoLoggerService.logInfo(
      'onWaitingEngineStopEnableCustomVideoProcessing, '
      'target enabled:$targetEnabled, '
      'engineState:$engineState, ',
      tag: 'uikit-stream',
      subTag: 'custom video processing',
    );

    coreData.waitingEngineStopEnableCustomVideoProcessing = false;
    coreData.engineStateUpdatedSubscription?.cancel();
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
          ZegoUIKitCore.shared.syncDeviceStatusBySEI();
        },
      );
    }

    return startMixerResult;
  }

  Future<ZegoMixerStopResult> stopMixerTask(ZegoMixerTask task) async {
    final stopMixerResult =
        await ZegoExpressEngine.instance.stopMixerTask(task);
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
    PlayerStateUpdateCallback? onPlayerStateUpdated,
  }) {
    return coreData.startPlayMixAudioVideo(
      mixerID,
      users,
      userSoundIDs,
      onPlayerStateUpdated: onPlayerStateUpdated,
    );
  }

  Future<void> stopPlayMixAudioVideo(String mixerID) {
    return coreData.stopPlayMixAudioVideo(mixerID);
  }
}

/// @nodoc
extension ZegoUIKitCoreAudioVideo on ZegoUIKitCore {
  Future<void> startPlayAnotherRoomAudioVideo(
    String roomID,
    String userID,
    String userName, {
    PlayerStateUpdateCallback? onPlayerStateUpdated,
  }) async {
    return coreData.startPlayAnotherRoomAudioVideo(
      roomID,
      userID,
      userName,
      onPlayerStateUpdated: onPlayerStateUpdated,
    );
  }

  Future<void> stopPlayAnotherRoomAudioVideo(String userID) async {
    return coreData.stopPlayAnotherRoomAudioVideo(userID);
  }
}

/// @nodoc
extension ZegoUIKitCoreScreenShare on ZegoUIKitCore {}
