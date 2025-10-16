// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/services/internal/core/core.dart';
import 'package:zego_uikit/src/services/services.dart';

extension ZegoUIKitUserList on List<ZegoUIKitUser> {
  String get ids => map((e) => e.id).toString();
}

class ZegoUIKitUser {
  String id = '';
  String name = '';

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory ZegoUIKitUser.fromJson(Map<String, dynamic> json) {
    return ZegoUIKitUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  ValueNotifier<bool> get microphone => _tryGetUser.microphone;

  ValueNotifier<bool> get microphoneMuteMode => _tryGetUser.microphoneMuteMode;

  ValueNotifier<ZegoUIKitDeviceExceptionType?> get microphoneException =>
      _tryGetUser.microphoneException;

  ValueNotifier<bool> get camera => _tryGetUser.camera;

  ValueNotifier<bool> get cameraMuteMode => _tryGetUser.cameraMuteMode;

  ValueNotifier<ZegoUIKitDeviceExceptionType?> get cameraException =>
      _tryGetUser.cameraException;

  Stream<double> get soundLevel =>
      _tryGetUser.mainChannel.soundLevelStream?.stream ?? const Stream.empty();

  StreamController<double>? get soundLevelStreamController =>
      _tryGetUser.mainChannel.soundLevelStream;

  Stream<double> get auxSoundLevel =>
      _tryGetUser.auxChannel.soundLevelStream?.stream ?? const Stream.empty();

  ValueNotifier<ZegoUIKitUserAttributes> get inRoomAttributes =>
      _tryGetUser.inRoomAttributes;

  String get streamID => _tryGetUser.mainChannel.streamID;

  int get streamTimestamp => _tryGetUser.mainChannel.streamTimestamp;

  ValueNotifier<ZegoUIKitAudioRoute?> get audioRoute => _tryGetUser.audioRoute;

  ZegoUIKitUser.empty();

  bool isEmpty() {
    return id.isEmpty;
  }

  ZegoUIKitUser({
    required this.id,
    required this.name,
  });

  // internal helper function
  ZegoUser toZegoUser() => ZegoUser(id, name);

  ZegoUIKitUser.fromZego(ZegoUser zegoUser)
      : this(id: zegoUser.userID, name: zegoUser.userName);

  ZegoUIKitCoreUser get _tryGetUser {
    final user = ZegoUIKitCore.shared.coreData.getUser(id);
    if (user.isEmpty) {
      final mixerUser = ZegoUIKitCore.shared.coreData.getUserInMixerStream(id);
      return mixerUser.isEmpty ? user : mixerUser;
    }

    return user;
  }

  @override
  String toString() {
    return '{'
        'id:$id, '
        'name:$name, '
        'in-room attributes:${inRoomAttributes.value}, '
        'camera:${camera.value}, '
        'microphone:${microphone.value}, '
        '}';
  }

  String toMoreString() {
    return '{'
        'id:$id, '
        'name:$name, '
        'in-room attributes:${inRoomAttributes.value}, '
        'camera:${camera.value}, '
        'camera mute mode:${cameraMuteMode.value}, '
        'microphone:${microphone.value}, '
        'microphone mute mode:${microphoneMuteMode.value} '
        '}';
  }
}

class ZegoUIKitUserPropertiesNotifier extends ChangeNotifier
    implements ValueListenable<int> {
  int _updateTimestamp = 0;

  final String? _mixerStreamID;

  final ZegoUIKitUser _user;
  late ZegoUIKitCoreUser _coreUser;

  StreamSubscription<dynamic>? _userListChangedSubscription;

  ZegoUIKitUserPropertiesNotifier(
    ZegoUIKitUser user, {
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
    _coreUser = ZegoUIKitCore.shared.coreData.getUser(_user.id);

    _userListChangedSubscription?.cancel();
    if (_coreUser.isEmpty) {
      _userListChangedSubscription =
          ZegoUIKit().getUserListStream().listen(onUserListUpdated);
    } else {
      _listenUserProperty();
    }
  }

  void _listenMixerUser() {
    _coreUser = ZegoUIKitCore.shared.coreData.getUserInMixerStream(_user.id);

    _userListChangedSubscription?.cancel();
    if (_coreUser.isEmpty) {
      _userListChangedSubscription = ZegoUIKit()
          .getMixerUserListStream(_mixerStreamID!)
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
