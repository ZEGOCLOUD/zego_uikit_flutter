// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

// Project imports:
import 'package:zego_uikit/src/plugins/signaling/impl/core/core.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/service/background_message_service.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/service/callkit_service.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/service/invitation_service.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/service/invitation_service_advance.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/service/message_service.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/service/notification_service.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/service/room_properties.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/service/user_attributes.dart';

/// @nodoc
class ZegoUIKitSignalingPluginImpl
    with
        ZegoPluginInvitationService,
        ZegoPluginInvitationServiceAdvance,
        ZegoPluginNotificationService,
        ZegoUIKitMessagesPluginService,
        ZegoUIKitRoomAttributesPluginService,
        ZegoUIKitUserInRoomAttributesPluginService,
        ZegoPluginBackgroundMessageService,
        ZegoPluginCallKitService {
  factory ZegoUIKitSignalingPluginImpl() => shared;

  ZegoUIKitSignalingPluginImpl._internal() {
    WidgetsFlutterBinding.ensureInitialized();
  }

  static final ZegoUIKitSignalingPluginImpl shared =
      ZegoUIKitSignalingPluginImpl._internal();

  bool isInit() {
    return ZegoSignalingPluginCore.shared.isInit();
  }

  /// init
  Future<void> init(
    int appID, {
    required String roomID,
    String appSign = '',
  }) async {
    initUserInRoomAttributes(roomID: roomID);
    return ZegoSignalingPluginCore.shared.init(appID: appID, appSign: appSign);
  }

  /// uninit
  Future<void> uninit({bool forceDestroy = false}) async {
    uninitUserInRoomAttributes();

    return ZegoSignalingPluginCore.shared.uninit(forceDestroy: forceDestroy);
  }

  Future<void> reportCallEnded(
    ZegoSignalingPluginCXCallEndedReason endedReason,
    String uuid,
  ) async {
    return ZegoSignalingPluginCore.shared.reportCallEnded(endedReason, uuid);
  }

  Future<void> setAdvancedConfig(String key, String value) async {
    await ZegoSignalingPluginCore.shared.setAdvancedConfig(key, value);
  }

  /// login
  Future<bool> login({
    required String id,
    required String name,
    String token = '',
  }) async {
    return ZegoSignalingPluginCore.shared.login(id, name, token: token);
  }

  /// logout
  Future<void> logout() async {
    return ZegoSignalingPluginCore.shared.logout();
  }

  Future<bool> renewToken(String token) async {
    return ZegoSignalingPluginCore.shared.renewToken(token);
  }

  /// join room
  Future<ZegoSignalingPluginJoinRoomResult> joinRoom(
    String roomID, {
    String roomName = '',
  }) async {
    return ZegoSignalingPluginCore.shared.joinRoom(roomID, roomName);
  }

  String getRoomID() {
    return ZegoSignalingPluginCore.shared.getRoomID();
  }

  /// leave room
  Future<void> leaveRoom() async {
    return ZegoSignalingPluginCore.shared.leaveRoom();
  }

  ZegoSignalingPluginConnectionState getConnectionState() {
    return ZegoPluginAdapter().signalingPlugin!.getConnectionState();
  }

  Stream<ZegoSignalingPluginConnectionStateChangedEvent>
      getConnectionStateStream() {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .getConnectionStateChangedEventStream();
  }

  ZegoSignalingPluginRoomState getRoomState() {
    return ZegoPluginAdapter().signalingPlugin!.getRoomState();
  }

  Stream<ZegoSignalingPluginRoomStateChangedEvent> getRoomStateStream() {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .getRoomStateChangedEventStream();
  }

  Stream<ZegoSignalingError> getErrorStream() {
    return ZegoSignalingPluginCore.shared.getErrorStream();
  }
}
