// Dart imports:
import 'dart:typed_data';

// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

/// @nodoc
mixin ZegoUIKitMessagesPluginService {
  Future<ZegoSignalingPluginInRoomTextMessageResult> sendInRoomTextMessage({
    required String roomID,
    required String message,
  }) async {
    final result = await ZegoPluginAdapter().signalingPlugin!
        .sendInRoomTextMessage(roomID: roomID, message: message);
    return result;
  }

  Future<ZegoSignalingPluginInRoomCommandMessageResult>
  sendInRoomCommandMessage({
    required String roomID,
    required Uint8List message,
  }) async {
    final result = await ZegoPluginAdapter().signalingPlugin!
        .sendInRoomCommandMessage(roomID: roomID, message: message);
    return result;
  }

  Stream<ZegoSignalingPluginInRoomTextMessageReceivedEvent>
  getInRoomTextMessageReceivedEventStream() {
    return ZegoPluginAdapter().signalingPlugin!
        .getInRoomTextMessageReceivedEventStream();
  }

  Stream<ZegoSignalingPluginInRoomCommandMessageReceivedEvent>
  getInRoomCommandMessageReceivedEventStream() {
    return ZegoPluginAdapter().signalingPlugin!
        .getInRoomCommandMessageReceivedEventStream();
  }
}
