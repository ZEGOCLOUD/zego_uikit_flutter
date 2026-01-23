// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

// Project imports:
import 'package:zego_uikit/src/plugins/signaling/impl/core/advance_invitation_data.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/core/event.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/core/invitation_data.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/core/notification_data.dart';
import 'package:zego_uikit/src/services/services.dart';

/// @nodoc
class ZegoSignalingPluginCoreData
    with
        ZegoSignalingPluginCoreInvitationData,
        ZegoSignalingPluginCoreNotificationData,
        ZegoSignalingPluginCoreEvent,
        ZegoSignalingPluginCoreAdvanceInvitationData {
  ZegoSignalingPluginCoreData() {
    initData();
  }

  bool isInit = false;
  bool isDataInit = false;
  String? currentUserID;
  String? currentUserName;
  String? currentRoomID;
  ZegoSignalingPluginRoomState currentRoomState =
      ZegoSignalingPluginRoomState.disconnected;
  String? currentRoomName;

  /// create engine
  Future<void> create({required int appID, String appSign = ''}) async {
    if (ZegoPluginAdapter().signalingPlugin == null) {
      return;
    }

    if (isInit) {
      ZegoLoggerService.logInfo(
        'has created.',
        tag: 'uikit-plugin-signaling',
        subTag: 'core data',
      );

      return;
    }

    initData();

    await ZegoPluginAdapter().signalingPlugin!.init(
          appID: appID,
          appSign: appSign,
        );
    isInit = true;

    ZegoLoggerService.logInfo(
      'create, appID:$appID',
      tag: 'uikit-plugin-signaling',
      subTag: 'core data',
    );
  }

  /// destroy engine
  Future<void> destroy({bool forceDestroy = false}) async {
    if (ZegoPluginAdapter().signalingPlugin == null) {
      ZegoLoggerService.logInfo(
        'signaling plugin is null.',
        tag: 'uikit-plugin-signaling',
        subTag: 'core data',
      );
      return;
    }

    if (!isInit) {
      ZegoLoggerService.logInfo(
        'is not created.',
        tag: 'uikit-plugin-signaling',
        subTag: 'core data',
      );
      return;
    }

    if (forceDestroy) {
      ZegoLoggerService.logInfo(
        'force destroy signaling plugin',
        tag: 'uikit-plugin-signaling',
        subTag: 'core data',
      );

      ZegoPluginAdapter().signalingPlugin!.uninit();
    }

    isInit = false;
    ZegoLoggerService.logInfo(
      'destroy.',
      tag: 'uikit-plugin-signaling',
      subTag: 'core data',
    );

    clear();
    uninitData();
  }

  void initData() {
    if (isDataInit) {
      return;
    }

    isDataInit = true;

    ZegoLoggerService.logInfo(
      'init data.',
      tag: 'uikit-plugin-signaling',
      subTag: 'core data',
    );

    initInvitationData();
    initAdvanceInvitationData();
    initNotificationData();
  }

  void uninitData() {
    if (!isDataInit) {
      return;
    }

    isDataInit = false;

    ZegoLoggerService.logInfo(
      'uninit data.',
      tag: 'uikit-plugin-signaling',
      subTag: 'core data',
    );

    uninitInvitationData();
    uninitAdvanceInvitationData();
    uninitNotificationData();
  }

  Future<void> reportCallEnded(
      ZegoSignalingPluginCXCallEndedReason endedReason, String uuid) async {
    ZegoLoggerService.logInfo(
      'reportCallEnded, endedReason:$endedReason, uuid:$uuid',
      tag: 'uikit-plugin-signaling',
      subTag: 'core data',
    );
    ZegoPluginAdapter().signalingPlugin!.reportCallEnded(endedReason, uuid);
  }

  /// login
  Future<bool> login(
    String id,
    String name, {
    String token = '',
  }) async {
    if (ZegoPluginAdapter().signalingPlugin == null) {
      return false;
    }

    if (!isInit) {
      ZegoLoggerService.logInfo(
        'is not created.',
        tag: 'uikit-plugin-signaling',
        subTag: 'core data',
      );
      return false;
    }

    if (null != currentUserID) {
      if (currentUserID != id || currentUserName != name) {
        ZegoLoggerService.logError(
          'login exist before, and not same, auto logout...',
          tag: 'uikit-plugin-signaling',
          subTag: 'core data',
        );
        await logout();
      } else {
        ZegoLoggerService.logError(
          'login exist before, and same, not need login...',
          tag: 'uikit-plugin-signaling',
          subTag: 'core data',
        );
        return true;
      }
    }

    ZegoLoggerService.logInfo(
      'login request, '
      'user id:$id, user name:$name,'
      'has token:${token.isNotEmpty}',
      tag: 'uikit-plugin-signaling',
      subTag: 'core data',
    );
    currentUserID = id;
    currentUserName = name;

    ZegoLoggerService.logInfo(
      'ready to login.',
      tag: 'uikit-plugin-signaling',
      subTag: 'core data',
    );

    final pluginResult = await ZegoPluginAdapter().signalingPlugin!.connectUser(
          id: id,
          name: name,
          token: token,
        );

    if (pluginResult.error == null) {
      ZegoLoggerService.logInfo(
        'login success',
        tag: 'uikit-plugin-signaling',
        subTag: 'core data',
      );
    } else {
      ZegoLoggerService.logInfo(
        'login error, ${pluginResult.error}',
        tag: 'uikit-plugin-signaling',
        subTag: 'core data',
      );
    }

    return pluginResult.error == null;
  }

  /// logout
  Future<void> logout() async {
    if (ZegoPluginAdapter().signalingPlugin == null) {
      return;
    }

    if (null == currentUserID) {
      ZegoLoggerService.logInfo(
        'user logout, not login before.',
        tag: 'uikit-plugin-signaling',
        subTag: 'core data',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'user logout, '
      'currentUserID:$currentUserID, '
      'currentUserName:$currentUserName, ',
      tag: 'uikit-plugin-signaling',
      subTag: 'core data',
    );

    currentUserID = null;
    currentUserName = null;

    final pluginResult =
        await ZegoPluginAdapter().signalingPlugin!.disconnectUser();

    if (pluginResult.timeout) {
      ZegoLoggerService.logInfo(
        'logout waitForDisconnect timeout',
        tag: 'uikit-plugin-signaling',
        subTag: 'core data',
      );
    } else {
      ZegoLoggerService.logInfo(
        'logout success',
        tag: 'uikit-plugin-signaling',
        subTag: 'core data',
      );
    }

    clear();
    ZegoLoggerService.logInfo(
      'logout done.',
      tag: 'uikit-plugin-signaling',
      subTag: 'core data',
    );
  }

  Future<bool> renewToken(String token) async {
    if (ZegoPluginAdapter().signalingPlugin == null) {
      return false;
    }

    ZegoLoggerService.logInfo(
      'renew token',
      tag: 'uikit-plugin-signaling',
      subTag: 'core data',
    );

    final pluginResult =
        await ZegoPluginAdapter().signalingPlugin!.renewToken(token);

    if (pluginResult.error == null) {
      ZegoLoggerService.logInfo(
        'renew token success',
        tag: 'uikit-plugin-signaling',
        subTag: 'core data',
      );
    } else {
      ZegoLoggerService.logInfo(
        'renew token error, ${pluginResult.error}',
        tag: 'uikit-plugin-signaling',
        subTag: 'core data',
      );
    }

    return pluginResult.error == null;
  }

  /// join room
  Future<ZegoSignalingPluginJoinRoomResult> joinRoom(
    String roomID,
    String roomName,
    bool force,
  ) async {
    if (!isInit) {
      ZegoLoggerService.logInfo(
        'is not created.',
        tag: 'uikit-plugin-signaling',
        subTag: 'core data',
      );
      return ZegoSignalingPluginJoinRoomResult(
        error: PlatformException(code: '-1', message: 'zim is not created.'),
      );
    }

    if (ZegoPluginAdapter().signalingPlugin == null) {
      return ZegoSignalingPluginJoinRoomResult(
        error: PlatformException(code: '-2', message: 'signaling is null'),
      );
    }

    if (currentRoomID != null) {
      if (currentRoomID == roomID) {
        ZegoLoggerService.logInfo(
          'same room has login, '
          'room id:$roomID, ',
          tag: 'uikit-plugin-signaling',
          subTag: 'core data',
        );
        return const ZegoSignalingPluginJoinRoomResult();
      }

      ZegoLoggerService.logInfo(
        'has login different room, '
        'old room id:$currentRoomID, '
        'target room id:$roomID, ',
        tag: 'uikit-plugin-signaling',
        subTag: 'core data',
      );
      if (force) {
        ZegoLoggerService.logInfo(
          'force quit old room',
          tag: 'uikit-plugin-signaling',
          subTag: 'core data',
        );

        await leaveRoom();
      } else {
        return ZegoSignalingPluginJoinRoomResult(
          error: PlatformException(code: '-3', message: 'room has login.'),
        );
      }
    }

    currentRoomID = roomID;
    currentRoomName = roomName;

    ZegoLoggerService.logInfo(
      'join room, '
      'room id:"$roomID", '
      'room name:$roomName, ',
      tag: 'uikit-plugin-signaling',
      subTag: 'core data',
    );

    final pluginResult = await ZegoPluginAdapter()
        .signalingPlugin!
        .joinRoom(roomID: roomID, roomName: roomName);

    if (pluginResult.error == null) {
      ZegoLoggerService.logInfo(
        'join room success',
        tag: 'uikit-plugin-signaling',
        subTag: 'core data',
      );
    } else {
      ZegoLoggerService.logInfo(
        'exception on join room, ${pluginResult.error}',
        tag: 'uikit-plugin-signaling',
        subTag: 'core data',
      );
      currentRoomID = null;
      currentRoomName = null;
    }
    return pluginResult;
  }

  /// leave room
  Future<void> leaveRoom() async {
    if (ZegoPluginAdapter().signalingPlugin == null) {
      return;
    }

    if (!isInit) {
      ZegoLoggerService.logInfo(
        'is not created.',
        tag: 'uikit-plugin-signaling',
        subTag: 'core data',
      );
      return;
    }

    if (currentRoomID == null) {
      ZegoLoggerService.logInfo(
        'room has not login.',
        tag: 'uikit-plugin-signaling',
        subTag: 'core data',
      );
      return;
    }

    ZegoLoggerService.logInfo(
      'ready to leave room ${currentRoomID!}',
      tag: 'uikit-plugin-signaling',
      subTag: 'core data',
    );
    final pluginResult = await ZegoPluginAdapter()
        .signalingPlugin!
        .leaveRoom(roomID: currentRoomID!);

    if (pluginResult.error == null) {
      ZegoLoggerService.logInfo(
        'leave room success',
        tag: 'uikit-plugin-signaling',
        subTag: 'core data',
      );
      currentRoomID = null;
    } else {
      ZegoLoggerService.logInfo(
        'leave room failed with ${pluginResult.error}',
        tag: 'uikit-plugin-signaling',
        subTag: 'core data',
      );
    }
  }

  Stream<ZegoSignalingError> getErrorStream() {
    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.signaling) != null) {
      return ZegoPluginAdapter().signalingPlugin!.getErrorStream();
    }

    return const Stream.empty();
  }

  /// clear
  void clear() {
    ZegoLoggerService.logInfo(
      'clear',
      tag: 'uikit-plugin-signaling',
      subTag: 'core data',
    );
    clearInvitationData();

    currentUserID = null;
    currentUserName = null;
    currentRoomID = null;
    currentRoomName = null;
  }

  ///  on error
  void onError(ZegoSignalingPluginErrorEvent event) {
    ZegoLoggerService.logInfo(
      'zim error, $event',
      tag: 'uikit-plugin-signaling',
      subTag: 'core data',
    );
  }

  /// on connection state changed
  void onConnectionStateChanged(
      ZegoSignalingPluginConnectionStateChangedEvent event) {
    ZegoLoggerService.logInfo(
      'connection state changed, $event',
      tag: 'uikit-plugin-signaling',
      subTag: 'core data',
    );

    if (event.state == ZegoSignalingPluginConnectionState.disconnected) {
      ZegoLoggerService.logInfo(
        'disconnected, auto logout',
        tag: 'uikit-plugin-signaling',
        subTag: 'core data',
      );
      // TODO 这个逻辑怎么搞 zimkit一起用的话估计是有问题的
      logout();
    }
  }

  void onNotificationArrived(
      ZegoSignalingPluginNotificationArrivedEvent event) {
    ZegoLoggerService.logInfo(
      'notification arrived, $event',
      tag: 'uikit-plugin-signaling',
      subTag: 'core data',
    );

    streamCtrlNotificationArrived?.add(event);
  }

  void onNotificationClicked(
      ZegoSignalingPluginNotificationClickedEvent event) {
    ZegoLoggerService.logInfo(
      'notification clicked, $event',
      tag: 'uikit-plugin-signaling',
      subTag: 'core data',
    );

    streamCtrlNotificationClicked?.add(event);
  }

  void onNotificationRegistered(
      ZegoSignalingPluginNotificationRegisteredEvent event) {
    ZegoLoggerService.logInfo(
      'notification registered, $event',
      tag: 'uikit-plugin-signaling',
      subTag: 'core data',
    );

    streamCtrlNotificationRegistered?.add(event);
  }

  /// on room state changed
  void onRoomStateChanged(ZegoSignalingPluginRoomStateChangedEvent event) {
    ZegoLoggerService.logInfo(
      'room state changed, $event',
      tag: 'uikit-plugin-signaling',
      subTag: 'core data',
    );

    if (event.roomID == currentRoomID) {
      currentRoomState = event.state;

      if (currentRoomState == ZegoSignalingPluginRoomState.disconnected) {
        ZegoLoggerService.logInfo(
          'room has been disconnect.',
          tag: 'uikit.plugin.signaling-coredata',
          subTag: 'core data',
        );
        currentRoomID = null;
        currentRoomName = null;
      }
    }
  }
}
