part of 'uikit_service.dart';

mixin ZegoDeviceService {
  /// protocol: String is 'operator'
  Stream<String> getTurnOnYourCameraRequestStream() {
    return ZegoUIKitCore
            .shared.coreData.turnOnYourCameraRequestStreamCtrl?.stream ??
        const Stream.empty();
  }

  Stream<ZegoUIKitReceiveTurnOnLocalMicrophoneEvent>
      getTurnOnYourMicrophoneRequestStream() {
    return ZegoUIKitCore
            .shared.coreData.turnOnYourMicrophoneRequestStreamCtrl?.stream ??
        const Stream.empty();
  }

  Future<void> enableCustomVideoProcessing(bool enable) async {
    return ZegoUIKitCore.shared.enableCustomVideoProcessing(enable);
  }

  ZegoMobileSystemVersion getMobileSystemVersionX() {
    final parsedByFlutter = getMobileSystemVersion();

    if(parsedByFlutter.isEmpty) {
      if (Platform.isAndroid) {
        final parsedVersion = parse(
          ZegoUIKitCore.shared.device.androidDeviceInfo?.version.incremental ??
              '',
        );
        if (parsedVersion.isEmpty) {
          return ZegoMobileSystemVersion(
            major: int.tryParse(
                ZegoUIKitCore.shared.device.androidDeviceInfo?.version.release ?? '') ?? 0,
            minor: 0,
            patch: 0,
          );
        }

        return parsedVersion;
      }

      if (Platform.isIOS) {
        return ZegoMobileSystemVersion(
          major: 0,
          minor: 0,
          patch: 0,
        );
        // return ZegoUIKitCore.shared.device.iosDeviceInfo;
      }
    }

    return parsedByFlutter;
  }

  ZegoMobileSystemVersion getMobileSystemVersion() {
    return parse(Platform.operatingSystemVersion);
  }

  ZegoMobileSystemVersion parse(String operatingSystemVersion) {
    var systemVersion = ZegoMobileSystemVersion.empty();

    if (Platform.isAndroid) {
      final RegExp versionRegExp = RegExp(r'(\d+)\.(\d+)\.(\d+)');
      final match = versionRegExp.firstMatch(operatingSystemVersion);
      if (match != null) {
        systemVersion.major = int.parse(match.group(1)!);
        systemVersion.minor = int.parse(match.group(2)!);
      }
    } else if (Platform.isIOS) {
      final RegExp versionRegExp = RegExp(r'(\d+)\.(\d+)(?:\.(\d+))?');
      final match = versionRegExp.firstMatch(operatingSystemVersion);

      if (match != null) {
        systemVersion.major = int.parse(match.group(1)!);
        systemVersion.minor = int.parse(match.group(2)!);
        if (match.group(3) != null) {
          systemVersion.patch = int.parse(match.group(3)!);
        }
      }
    }

    return systemVersion;
  }
}
