// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:zego_uikit/src/services/core/core.dart';
import 'package:zego_uikit/src/services/core/defines/defines.dart';
import 'package:zego_uikit/src/services/services.dart';

/// Notifier for user properties changes in a room.
///
/// This class listens to user property changes (camera, microphone, attributes)
/// and notifies listeners when updates occur.
class ZegoUIKitUserPropertiesNotifier extends ChangeNotifier
    implements ValueListenable<int> {
  /// Room ID associated with this notifier.
  final String roomID;

  int _updateTimestamp = 0;

  final String? _mixerStreamID;

  final ZegoUIKitUser _user;
  late ZegoUIKitCoreUser _coreUser;

  StreamSubscription<dynamic>? _userListChangedSubscription;

  ZegoUIKitUserPropertiesNotifier(
    ZegoUIKitUser user, {
    required this.roomID,
    String? mixerStreamID,
  })  : _user = user,
        _mixerStreamID = mixerStreamID {
    _listenUser();
  }

  ZegoUIKitUser get user => _user;

  void _listenUser() {
    if (_mixerStreamID?.isEmpty ?? true) {
      _listenNormalUser();
    } else {
      _listenMixerUser();
    }
  }

  void _listenNormalUser() {
    _coreUser = ZegoUIKitCore.shared.coreData.user.getUser(
      _user.id,
      targetRoomID: ZegoUIKitCore.shared.coreData.room.currentID,
    );

    _userListChangedSubscription?.cancel();
    if (_coreUser.isEmpty) {
      _userListChangedSubscription = ZegoUIKit()
          .getUserListStream(targetRoomID: roomID)
          .listen(onUserListUpdated);
    } else {
      _listenUserProperty();
    }
  }

  void _listenMixerUser() {
    _coreUser = ZegoUIKitCore.shared.coreData.user.getUserInMixerStream(
      _user.id,
      targetRoomID: ZegoUIKitCore.shared.coreData.room.currentID,
    );

    _userListChangedSubscription?.cancel();
    if (_coreUser.isEmpty) {
      _userListChangedSubscription = ZegoUIKit()
          .getMixerUserListStream(targetRoomID: roomID, _mixerStreamID!)
          .listen(onUserListUpdated);
    } else {
      _listenUserProperty();
    }
  }

  void _listenUserProperty() {
    _coreUser.camera.addListener(onCameraStatusChanged);
    _coreUser.cameraMuteMode.addListener(onCameraMuteModeChanged);

    _coreUser.microphone.addListener(onMicrophoneStatusChanged);
    _coreUser.microphoneMuteMode.addListener(onMicrophoneMuteModeChanged);

    _coreUser.inRoomAttributes.addListener(onInRoomAttributesUpdated);
  }

  void _removeListenUserProperty() {
    _userListChangedSubscription?.cancel();

    _coreUser.camera.removeListener(onCameraStatusChanged);
    _coreUser.cameraMuteMode.removeListener(onCameraMuteModeChanged);

    _coreUser.microphone.removeListener(onMicrophoneStatusChanged);
    _coreUser.microphoneMuteMode.removeListener(onMicrophoneMuteModeChanged);

    _coreUser.inRoomAttributes.removeListener(onInRoomAttributesUpdated);
  }

  void onUserListUpdated(List<ZegoUIKitUser> users) {
    _listenUser();
  }

  void onCameraStatusChanged() {
    _updateTimestamp = DateTime.now().microsecondsSinceEpoch;

    notifyListeners();
  }

  void onCameraMuteModeChanged() {
    _updateTimestamp = DateTime.now().microsecondsSinceEpoch;

    notifyListeners();
  }

  void onMicrophoneStatusChanged() {
    _updateTimestamp = DateTime.now().microsecondsSinceEpoch;

    notifyListeners();
  }

  void onMicrophoneMuteModeChanged() {
    _updateTimestamp = DateTime.now().microsecondsSinceEpoch;

    notifyListeners();
  }

  void onInRoomAttributesUpdated() {
    _updateTimestamp = DateTime.now().microsecondsSinceEpoch;

    notifyListeners();
  }

  @override
  int get value => _updateTimestamp;

  @override
  void dispose() {
    _removeListenUserProperty();
    super.dispose();
  }
}
