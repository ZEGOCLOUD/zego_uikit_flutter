part of 'core.dart';

/// @nodoc
mixin ZegoUIKitCoreDataDevice {
  final _deviceImpl = ZegoUIKitCoreDataDeviceImpl();

  ZegoUIKitCoreDataDeviceImpl get device => _deviceImpl;
}

/// @nodoc
class ZegoUIKitCoreDataDeviceImpl {
  AndroidDeviceInfo? _androidDeviceInfo;
  IosDeviceInfo? _iosDeviceInfo;

  AndroidDeviceInfo? get androidDeviceInfo => _androidDeviceInfo;
  IosDeviceInfo? get iosDeviceInfo => _iosDeviceInfo;

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
