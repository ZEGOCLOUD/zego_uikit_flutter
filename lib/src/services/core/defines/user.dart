// Flutter imports:
import 'package:flutter/cupertino.dart';
// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';
// Project imports:
import 'package:zego_uikit/src/services/core/defines/user_attributes.dart';
import 'package:zego_uikit/src/services/defines/audio_video/stream_type.dart';
import 'package:zego_uikit/src/services/defines/device/exception.dart';
import 'package:zego_uikit/src/services/defines/express.dart';
import 'package:zego_uikit/src/services/defines/user/user.dart';
import 'package:zego_uikit/src/services/uikit_service.dart';

import 'stream_info.dart';

/// @nodoc
// user
class ZegoUIKitCoreUser {
  ZegoUIKitCoreUser(
    this.id,
    this.name,
    this.roomID,
    this.fromAnotherRoom,
  );

  ZegoUIKitCoreUser.fromZego(
    ZegoUser user, {
    required String roomID,
    required bool isAnotherRoomUser,
  }) : this(user.userID, user.userName, roomID, isAnotherRoomUser);

  ZegoUIKitCoreUser.empty();

  ZegoUIKitCoreUser.localDefault() {
    camera.value = false;
    microphone.value = false;
  }

  String id = '';
  String name = '';
  String roomID = '';
  bool fromAnotherRoom = false;

  ValueNotifier<bool> camera = ValueNotifier<bool>(false);
  ValueNotifier<bool> cameraMuteMode = ValueNotifier<bool>(false);
  ValueNotifier<ZegoUIKitDeviceException?> cameraException =
      ValueNotifier<ZegoUIKitDeviceException?>(null);

  ValueNotifier<bool> microphone = ValueNotifier<bool>(false);
  ValueNotifier<bool> microphoneMuteMode = ValueNotifier<bool>(false);
  ValueNotifier<ZegoUIKitDeviceException?> microphoneException =
      ValueNotifier<ZegoUIKitDeviceException?>(null);

  ValueNotifier<ZegoUIKitUserAttributes> inRoomAttributes =
      ValueNotifier<ZegoUIKitUserAttributes>({});

  ZegoUIKitCoreStreamInfo mainChannel = ZegoUIKitCoreStreamInfo.empty();
  ZegoUIKitCoreStreamInfo auxChannel = ZegoUIKitCoreStreamInfo.empty();
  ZegoUIKitCoreStreamInfo thirdChannel = ZegoUIKitCoreStreamInfo.empty();

  ValueNotifier<ZegoStreamQualityLevel> network =
      ValueNotifier<ZegoStreamQualityLevel>(ZegoStreamQualityLevel.Excellent);

  // only for local
  ValueNotifier<bool> isFrontFacing = ValueNotifier<bool>(true);
  ValueNotifier<bool> isFrontTriggerByTurnOnCamera = ValueNotifier<bool>(false);
  ValueNotifier<bool> isVideoMirror = ValueNotifier<bool>(false);
  ValueNotifier<ZegoUIKitAudioRoute> audioRoute =
      ValueNotifier<ZegoUIKitAudioRoute>(ZegoUIKitAudioRoute.Receiver);
  ZegoUIKitAudioRoute lastAudioRoute = ZegoUIKitAudioRoute.Receiver;

  void copyAttributesFromOther(ZegoUIKitCoreUser other) {
    camera.value = other.camera.value;
    cameraMuteMode.value = other.cameraMuteMode.value;
    cameraException.value = other.cameraException.value;
    microphone.value = other.microphone.value;
    microphoneMuteMode.value = other.microphoneMuteMode.value;
    microphoneException.value = other.microphoneException.value;
    inRoomAttributes.value = other.inRoomAttributes.value;
    mainChannel = other.mainChannel;
    auxChannel = other.auxChannel;
    thirdChannel = other.thirdChannel;
    network.value = other.network.value;
    isFrontFacing.value = other.isFrontFacing.value;
    isFrontTriggerByTurnOnCamera.value =
        other.isFrontTriggerByTurnOnCamera.value;
    isVideoMirror.value = other.isVideoMirror.value;
    audioRoute.value = other.audioRoute.value;
    lastAudioRoute = other.lastAudioRoute;
  }

  void clear() {
    id = '';
    name = '';
    fromAnotherRoom = false;

    network.value = ZegoStreamQualityLevel.Excellent;

    isFrontFacing.value = true;
    isFrontTriggerByTurnOnCamera.value = false;
    isVideoMirror.value = false;
    audioRoute.value = ZegoUIKitAudioRoute.Receiver;
    lastAudioRoute = ZegoUIKitAudioRoute.Receiver;

    clearRoomAttribute();
  }

  void clearRoomAttribute() {
    camera.value = false;
    cameraMuteMode.value = false;
    cameraException.value = null;

    microphone.value = false;
    microphoneMuteMode.value = false;
    microphoneException.value = null;

    inRoomAttributes.value = {};

    mainChannel = ZegoUIKitCoreStreamInfo.empty();
    auxChannel = ZegoUIKitCoreStreamInfo.empty();
    thirdChannel = ZegoUIKitCoreStreamInfo.empty();

    fromAnotherRoom = false;
  }

  bool get isEmpty => id.isEmpty;

  ZegoUIKitCoreUser copyWith({
    String? id,
    String? name,
    String? roomID,
    bool? fromAnotherRoom,
  }) {
    return ZegoUIKitCoreUser(
      id ?? this.id,
      name ?? this.name,
      roomID ?? this.roomID,
      fromAnotherRoom ?? this.fromAnotherRoom,
    );
  }

  void initAudioRoute(ZegoAudioRoute value) {
    ZegoLoggerService.logInfo(
      'init default audio route:$value',
      tag: 'uikit.service-core',
      subTag: 'local user',
    );
    audioRoute.value = value;
    lastAudioRoute = value;
  }

  Future<void> destroyTextureRenderer(
      {required ZegoStreamType streamType}) async {
    switch (streamType) {
      case ZegoStreamType.main:
        if (mainChannel.viewIDNotifier.value != -1) {
          await ZegoExpressEngine.instance.destroyCanvasView(
            mainChannel.viewIDNotifier.value ?? -1,
          );
        }

        mainChannel.clearViewInfo();
        break;
      case ZegoStreamType.media:
      case ZegoStreamType.screenSharing:
      case ZegoStreamType.mix:
        if (auxChannel.viewIDNotifier.value != -1) {
          await ZegoExpressEngine.instance
              .destroyCanvasView(auxChannel.viewIDNotifier.value ?? -1);
        }

        auxChannel.clearViewInfo();
        break;
    }
  }

  ZegoUIKitUser toZegoUikitUser() => ZegoUIKitUser(
        id: id,
        name: name,
        roomID: roomID,
        isAnotherRoomUser: fromAnotherRoom,
      );

  ZegoUser toZegoUser() => ZegoUser(id, name);

  @override
  String toString() {
    return '{'
        'id:$id, '
        'name:$name, '
        'room id:$roomID, '
        'isAnotherRoomUser:$fromAnotherRoom, '
        '}';
  }
}
