// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

// Project imports:
import 'package:zego_uikit/zego_uikit.dart';

/// @nodoc
class ZegoUIKitUserInRoomAttributesPluginServicePrivate {
  ZegoUIKitUserInRoomAttributesPluginServicePrivate({
    required this.roomID,
  });

  final String roomID;

  final bool isInit = false;
  final List<StreamSubscription<dynamic>?> subscriptions = [];
  final Map<String, Map<String, String>> pendingUserRoomAttributes = {};

  void init() {
    if (isInit) {
      debugPrint('[core] user in-room private had init');
      return;
    }

    debugPrint('[core] user in-room private init');
    subscriptions
      ..add(ZegoUIKit()
          .getUserListStream(targetRoomID: roomID)
          .listen(_onUserListUpdated))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getUsersInRoomAttributesStream()
          .listen(onUsersAttributesUpdated));
  }

  void uninit() {
    if (!isInit) {
      debugPrint('[core] user in-room private is not init');
      return;
    }

    debugPrint('[core] user in-room private uninit');
    for (final subscription in subscriptions) {
      subscription?.cancel();
    }
  }

  void onUsersAttributesUpdated(
      ZegoSignalingPluginUsersInRoomAttributesUpdatedEvent event) {
    updateUserInRoomAttributes(event.attributes);
  }

  void _onUserListUpdated(List<ZegoUIKitUser> users) {
    final doneUserIDs = <String>[];
    pendingUserRoomAttributes
      ..forEach((userID, userAttributes) {
        debugPrint('[core] exist pending user attribute, user id: $userID, '
            'attributes: $userAttributes');

        final user = ZegoUIKit().getUser(targetRoomID: roomID, userID);
        if (!user.isEmpty()) {
          updateUserInRoomAttributes({userID: userAttributes});

          doneUserIDs.add(userID);
        }
      })
      ..removeWhere((userID, userAttributes) => doneUserIDs.contains(userID));
  }

  void updateUserInRoomAttributes(Map<String, Map<String, String>> infos) {
    infos.forEach((updateUserID, updateUserAttributes) {
      final updateUser = ZegoUIKit().getUser(
        targetRoomID: roomID,
        updateUserID,
      );
      if (updateUser.isEmpty()) {
        pendingUserRoomAttributes[updateUserID] = updateUserAttributes;
        return;
      }

      updateUser.inRoomAttributes.value = updateUserAttributes;
      debugPrint(
          '[core] user in-room attributes update, user id:$updateUserID, '
          'attributes:$updateUserAttributes');
    });
  }
}
