// Dart imports:
import 'dart:async';

// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

// Project imports:
import 'package:zego_uikit/src/plugins/signaling/impl/core/data.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/core/event.dart';

/// @nodoc
class ZegoSignalingPluginCore with ZegoSignalingPluginCoreEvent {
  ZegoSignalingPluginCore._internal();

  static ZegoSignalingPluginCore shared = ZegoSignalingPluginCore._internal();
  ZegoSignalingPluginCoreData coreData = ZegoSignalingPluginCoreData();

  /// get version
  Future<String> getVersion() async {
    return ZegoPluginAdapter().signalingPlugin?.getVersion() ??
        Future.value('signalingPlugin:null');
  }

  Future<void> setAdvancedConfig(String key, String value) async {
    await ZegoPluginAdapter().signalingPlugin?.setAdvancedConfig(key, value);
  }

  bool isInit() {
    return coreData.isInit;
  }

  /// init
  Future<void> init({required int appID, String appSign = ''}) async {
    initEvent();
    await coreData.create(appID: appID, appSign: appSign);
  }

  /// uninit
  Future<void> uninit({bool forceDestroy = false}) async {
    uninitEvent();
    return coreData.destroy(forceDestroy: forceDestroy);
  }

  Future<void> reportCallEnded(
    ZegoSignalingPluginCXCallEndedReason endedReason,
    String uuid,
  ) async {
    return coreData.reportCallEnded(endedReason, uuid);
  }

  /// login
  Future<bool> login(
    String id,
    String name, {
    String token = '',
  }) async {
    return coreData.login(
      id,
      name,
      token: token,
    );
  }

  /// logout
  Future<void> logout() async {
    await coreData.logout();
  }

  Future<bool> renewToken(String token) async {
    return coreData.renewToken(token);
  }

  /// join room
  Future<ZegoSignalingPluginJoinRoomResult> joinRoom(
    String roomID,
    String roomName,
  ) async {
    return coreData.joinRoom(roomID, roomName);
  }

  /// switch room
  Future<ZegoSignalingPluginJoinRoomResult> switchRoom(
    String roomID,
    String roomName,
  ) async {
    return coreData.switchRoom(roomID, roomName);
  }

  String getRoomID() {
    return coreData.currentRoomID ?? '';
  }

  ZegoSignalingPluginRoomState getRoomState() {
    return coreData.currentRoomState;
  }

  /// leave room
  Future<void> leaveRoom() async {
    await coreData.leaveRoom();
  }

  Stream<ZegoSignalingError> getErrorStream() {
    return coreData.getErrorStream();
  }
}
