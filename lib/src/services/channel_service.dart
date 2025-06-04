part of 'uikit_service.dart';

mixin ZegoChannelService {
  /// Android go to the desktop
  Future<void> backToDesktop({
    bool nonRoot = false,
  }) async {
    return ZegoUIKitPluginPlatform.instance.backToDesktop();
  }

  /// Android/IOS is lock screen
  Future<bool> isLockScreen() async {
    return ZegoUIKitPluginPlatform.instance.isLockScreen();
  }

  Future<bool> checkAppRunning() async {
    return ZegoUIKitPluginPlatform.instance.checkAppRunning();
  }

  @pragma('vm:entry-point')
  Future<void> activeAppToForeground() async {
    await ZegoUIKitPluginPlatform.instance.activeAppToForeground();
  }

  Future<bool> stopIOSPIP() async {
    return await ZegoUIKitPluginPlatform.instance.stopIOSPIP();
  }

  Future<bool> isIOSInPIP() async {
    return await ZegoUIKitPluginPlatform.instance.isIOSInPIP();
  }

  Future<void> enableIOSPIP(
    String streamID, {
    int aspectWidth = 9,
    int aspectHeight = 16,
  }) async {
    return await ZegoUIKitPluginPlatform.instance.enableIOSPIP(
      streamID,
      aspectWidth: aspectWidth,
      aspectHeight: aspectHeight,
    );
  }

  Future<void> updateIOSPIPSource(String streamID) async {
    return await ZegoUIKitPluginPlatform.instance.updateIOSPIPSource(streamID);
  }

  Future<void> enableIOSPIPAuto(
    bool isEnabled, {
    int aspectWidth = 9,
    int aspectHeight = 16,
  }) async {
    return await ZegoUIKitPluginPlatform.instance.enableIOSPIPAuto(
      isEnabled,
      aspectWidth: aspectWidth,
      aspectHeight: aspectHeight,
    );
  }

  Future<void> enableHardwareDecoder(bool isEnabled) async {
    await ZegoUIKitPluginPlatform.instance.enableHardwareDecoder(isEnabled);
  }

  Future<void> enableCustomVideoRender(bool isEnabled) async {
    ZegoLoggerService.logInfo(
      'isEnabled:$isEnabled, '
      'roomState:${ZegoUIKitCore.shared.coreData.room.state.value}, '
      'isPreviewing:${ZegoUIKitCore.shared.coreData.isPreviewing}, '
      'isPublishingStream:${ZegoUIKitCore.shared.coreData.isPublishingStream}, '
      'isPlayingStream:${ZegoUIKitCore.shared.coreData.isPlayingStream}, ',
      tag: 'uikit-channel',
      subTag: 'enableCustomVideoRender',
    );

    if (isEnabled == ZegoUIKitCore.shared.coreData.isEnableCustomVideoRender) {
      ZegoLoggerService.logInfo(
        'state is same, ignore',
        tag: 'uikit-channel',
        subTag: 'enableCustomVideoRender',
      );

      return;
    }

    ZegoUIKitCore.shared.coreData.isEnableCustomVideoRender = isEnabled;

    await ZegoUIKitPluginPlatform.instance.enableCustomVideoRender(isEnabled);
  }

  @pragma('vm:entry-point')
  Future<void> requestDismissKeyguard() async {
    await ZegoUIKitPluginPlatform.instance.requestDismissKeyguard();
  }

  Future<void> startPlayingStreamInPIP(int viewID, String streamID) async {
    await ZegoUIKitPluginPlatform.instance.startPlayingStreamInPIP(
      viewID,
      streamID,
    );
  }

  Future<void> stopPlayingStreamInPIP(String streamID) async {
    await ZegoUIKitPluginPlatform.instance.stopPlayingStreamInPIP(streamID);
  }

  /// 'onWillPop' in Android returns true will cause the Flutter engine to be destroyed,
  /// resulting in the inability to interact between native code and Flutter code.
  ///
  /// Here, if Android wants to go to the desktop,
  /// it should be implemented by calling native code instead of returning true
  Future<bool> onWillPop(BuildContext context) async {
    if (Platform.isAndroid) {
      if (Navigator.of(context).canPop()) {
        return true;
      } else {
        await ZegoUIKit().backToDesktop();
        return false;
      }
    }

    return true;
  }
}
