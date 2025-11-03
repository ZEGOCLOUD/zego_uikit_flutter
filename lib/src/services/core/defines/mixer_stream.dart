import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import 'user.dart';

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

  /// userid, sound id
  Map<String, int> userSoundIDs = {};

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
}
