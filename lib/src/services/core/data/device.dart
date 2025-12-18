// Dart imports:
import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/services/core/core.dart';
import 'package:zego_uikit/src/services/core/data/data.dart';
import 'package:zego_uikit/src/services/core/defines/sei.dart';
import 'package:zego_uikit/src/services/defines/audio_video/sei.dart';
import 'package:zego_uikit/src/services/defines/audio_video/stream_type.dart';
import 'package:zego_uikit/src/services/defines/stream.dart';
import 'package:zego_uikit/src/services/uikit_service.dart';

class ZegoUIKitCoreDataDevice {
  ZegoUIKitCoreData get _coreData => ZegoUIKitCore.shared.coreData;

  AndroidDeviceInfo? _androidDeviceInfo;
  IosDeviceInfo? _iosDeviceInfo;

  AndroidDeviceInfo? get androidDeviceInfo => _androidDeviceInfo;

  IosDeviceInfo? get iosDeviceInfo => _iosDeviceInfo;

  /// sync device status via stream extra info
  Future<void> syncDeviceStatusByStreamExtraInfo({
    required String targetRoomID,
    required ZegoStreamType streamType,
  }) async {
    if (!_coreData.stream.roomStreams.getRoom(targetRoomID).isPublishing) {
      ZegoLoggerService.logWarn(
        'not publishing, '
        'room id:$targetRoomID, ',
        tag: 'uikit-stream',
        subTag: 'syncDeviceStatusByStreamExtraInfo',
      );
      return;
    }

    final streamExtraInfo = <String, dynamic>{
      streamExtraInfoCameraKey: _coreData.user.localUser.camera.value,
      streamExtraInfoMicrophoneKey: _coreData.user.localUser.microphone.value,
    };

    final extraInfo = jsonEncode(streamExtraInfo);
    await ZegoExpressEngine.instance.setStreamExtraInfo(extraInfo);

    if (_coreData.stream.isSyncDeviceStatusBySEI) {
      await syncDeviceStatusBySEI();
    }
  }

  Future<void> syncDeviceStatusBySEI() async {
    final seiMap = <String, dynamic>{
      ZegoUIKitSEIDefines.keyCamera: _coreData.user.localUser.camera.value,
      ZegoUIKitSEIDefines.keyMicrophone:
          _coreData.user.localUser.microphone.value,
    };
    await _coreData.sendSEI(
      ZegoUIKitInnerSEIType.mixerDeviceState.name,
      seiMap,
      streamType: ZegoStreamType.main,
    );
  }

  Future<void> init() async {
    ZegoLoggerService.logInfo(
      'init device module',
      subTag: 'core data',
    );

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      await deviceInfo.androidInfo.then((androidInfo) {
        _androidDeviceInfo = androidInfo;
      });
    }

    if (Platform.isIOS) {
      await deviceInfo.iosInfo.then((iosInfo) {
        _iosDeviceInfo = iosInfo;
      });
    }
  }

  void uninit() {
    ZegoLoggerService.logInfo(
      'uninit device module',
      subTag: 'core data',
    );
  }
}
