// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

/// @nodoc
mixin ZegoUIKitRoomAttributesPluginService {
  /// update room property
  Future<ZegoSignalingPluginRoomPropertiesOperationResult> updateRoomProperty({
    required String roomID,
    required String key,
    required String value,
    bool isForce = false,
    bool isDeleteAfterOwnerLeft = false,
    bool isUpdateOwner = false,
  }) async {
    return ZegoPluginAdapter().signalingPlugin!.updateRoomProperties(
      roomID: roomID,
      isForce: isForce,
      isDeleteAfterOwnerLeft: isDeleteAfterOwnerLeft,
      isUpdateOwner: isUpdateOwner,
      roomProperties: {key: value},
    );
  }

  Future<ZegoSignalingPluginRoomPropertiesOperationResult>
  updateRoomProperties({
    required String roomID,
    required Map<String, String> roomProperties,
    bool isForce = false,
    bool isDeleteAfterOwnerLeft = false,
    bool isUpdateOwner = false,
  }) async {
    return ZegoPluginAdapter().signalingPlugin!.updateRoomProperties(
      roomID: roomID,
      isForce: isForce,
      isDeleteAfterOwnerLeft: isDeleteAfterOwnerLeft,
      isUpdateOwner: isUpdateOwner,
      roomProperties: roomProperties,
    );
  }

  /// delete room properties
  Future<ZegoSignalingPluginRoomPropertiesOperationResult>
  deleteRoomProperties({
    required String roomID,
    required List<String> keys,
    bool isForce = false,
    bool showErrorLog = true,
  }) async {
    return ZegoPluginAdapter().signalingPlugin!.deleteRoomProperties(
      roomID: roomID,
      keys: keys,
      isForce: isForce,
      showErrorLog: showErrorLog,
    );
  }

  /// begin room properties in batch operation
  void beginRoomPropertiesBatchOperation({
    required String roomID,
    bool isDeleteAfterOwnerLeft = false,
    bool isForce = false,
    bool isUpdateOwner = false,
  }) {
    ZegoPluginAdapter().signalingPlugin!.beginRoomPropertiesBatchOperation(
      roomID: roomID,
      isForce: isForce,
      isDeleteAfterOwnerLeft: isDeleteAfterOwnerLeft,
      isUpdateOwner: isUpdateOwner,
    );
  }

  /// end room properties in batch operation
  Future<ZegoSignalingPluginEndRoomBatchOperationResult>
  endRoomPropertiesBatchOperation({required String roomID}) async {
    return ZegoPluginAdapter().signalingPlugin!.endRoomPropertiesBatchOperation(
      roomID: roomID,
    );
  }

  /// query room properties
  Future<ZegoSignalingPluginQueryRoomPropertiesResult> queryRoomProperties({
    required String roomID,
  }) async {
    return ZegoPluginAdapter().signalingPlugin!.queryRoomProperties(
      roomID: roomID,
    );
  }

  // Future<ZegoSignalingPluginInRoomTextMessageResult> sendInRoomTextMessage({
  //   required String roomID,
  //   required String message,
  // }) async {
  //   return ZegoPluginAdapter()
  //       .signalingPlugin!
  //       .sendInRoomTextMessage(roomID: roomID, message: message);
  // }

  /// get room properties notifier
  Stream<ZegoSignalingPluginRoomPropertiesUpdatedEvent>
  getRoomPropertiesStream() {
    return ZegoPluginAdapter().signalingPlugin!
        .getRoomPropertiesUpdatedEventStream();
  }

  /// get room batch properties notifier
  Stream<ZegoSignalingPluginRoomPropertiesBatchUpdatedEvent>
  getRoomBatchPropertiesStream() {
    return ZegoPluginAdapter().signalingPlugin!
        .getRoomPropertiesBatchUpdatedEventStream();
  }
}
