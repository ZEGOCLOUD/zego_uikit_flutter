// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'user.dart';

/// Mixer stream data holder used inside UIKit core.
///
/// Stores stream ID, view information, load state, sound levels and user list
/// for a mixed audio & video stream.
class ZegoUIKitCoreMixerStream {
  final String streamID;
  int viewID = -1;
  final view = ValueNotifier<Widget?>(null);
  final loaded = ValueNotifier<bool>(false); // first frame
  StreamController<Map<int, double>>? soundLevels;

  final usersNotifier = ValueNotifier<List<ZegoUIKitCoreUser>>([]);
  StreamController<List<ZegoUIKitCoreUser>>? userListStreamCtrl;

  void addUser(ZegoUIKitCoreUser user) {
    usersNotifier.value = List.from(usersNotifier.value)..add(user);

    userListStreamCtrl?.add(usersNotifier.value);
  }

  void removeUser(ZegoUIKitCoreUser user) {
    usersNotifier.value = List.from(usersNotifier.value)
      ..removeWhere((e) => e.id == user.id);

    userListStreamCtrl?.add(usersNotifier.value);
  }

  /// Map of user ID to sound ID (sound channel ID).
  Map<String, int> userSoundIDs = {};

  /// Create a mixer stream description for UIKit core.
  ///
  /// [streamID] The ID of the mixed stream.
  /// [userSoundIDs] Map of user ID to sound ID (sound channel ID).
  /// [users] Initial user list contained in this mixed stream.
  ZegoUIKitCoreMixerStream(
    this.streamID,
    this.userSoundIDs,
    List<ZegoUIKitCoreUser> users,
  ) {
    usersNotifier.value = List.from(users);
    userListStreamCtrl ??=
        StreamController<List<ZegoUIKitCoreUser>>.broadcast();

    soundLevels ??= StreamController<Map<int, double>>.broadcast();
  }

  void destroyTextureRenderer({bool isMainStream = true}) {
    if (viewID != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(viewID);
    }
    viewID = -1;
    view.value = null;
    soundLevels?.close();

    userListStreamCtrl?.close();
    userListStreamCtrl = null;
  }

  @override
  String toString() {
    return '{'
        'hashCode:$hashCode, '
        'id:$streamID, '
        'view id:$viewID, '
        'view:$view, '
        'loaded:$loaded, '
        'users:${usersNotifier.value.map((e) => e.toZegoUser())}, '
        '}';
  }
}
