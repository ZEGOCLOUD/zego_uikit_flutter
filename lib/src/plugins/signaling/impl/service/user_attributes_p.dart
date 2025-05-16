// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_uikit/zego_uikit.dart';

/// @nodoc
class ZegoUIKitUserInRoomAttributesPluginServicePrivate {
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
      ..add(ZegoUIKit().getUserListStream().listen(_onUserListUpdated))
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

        final user = ZegoUIKit().getUser(userID);
        if (!user.isEmpty()) {
          updateUserInRoomAttributes({userID: userAttributes});

          doneUserIDs.add(userID);
        }
      })
      ..removeWhere((userID, userAttributes) => doneUserIDs.contains(userID));
  }

  void updateUserInRoomAttributes(Map<String, Map<String, String>> infos) {
    infos.forEach((updateUserID, updateUserAttributes) {
      final updateUser = ZegoUIKit().getUser(updateUserID);
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
