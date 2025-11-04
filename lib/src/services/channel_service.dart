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
      'express engineState:${ZegoUIKitCore.shared.coreData.engine.stateNotifier}, ',
      tag: 'uikit-channel',
      subTag: 'enableCustomVideoRender',
    );

    if (isEnabled ==
        ZegoUIKitCore.shared.coreData.stream.isEnableCustomVideoRender) {
      ZegoLoggerService.logInfo(
        'state is same, ignore',
        tag: 'uikit-channel',
        subTag: 'enableCustomVideoRender',
      );

      return;
    }

    ZegoUIKitCore.shared.coreData.stream.isEnableCustomVideoRender = isEnabled;
    await ZegoUIKitPluginPlatform.instance.enableCustomVideoRender(isEnabled);

    // 看起来不需要这个步骤，并且只有进房后才会抛出ve start，这时候enable又会报错
    // if (ZegoUIKitExpressEngineState.Start ==
    //     ZegoUIKitCore.shared.coreData.engine.stateNotifier.value) {
    //   /// this api does not allow setting after the express internal engine starts;
    //   /// if set after the internal engine starts, it will cause the custom
    //   /// video render to not be truly turned off/turned on
    //   /// so turned off/turned on only effect when engine state is stop
    //   ZegoUIKitCore.shared.coreData.stream.isEnableCustomVideoRender =
    //       isEnabled;
    //   await ZegoUIKitPluginPlatform.instance.enableCustomVideoRender(isEnabled);
    // } else {
    //
    //   ZegoUIKitCore.shared.coreData.engine
    //       .waitingEngineStartEnableValueOfCustomVideoRender = isEnabled;
    //
    //   ZegoUIKitCore.shared.coreData.engine
    //       .stateUpdatedSubscriptionByEnableCustomVideoRender
    //       ?.cancel();
    //   ZegoUIKitCore.shared.coreData.engine
    //           .stateUpdatedSubscriptionByEnableCustomVideoRender =
    //       ZegoUIKitCore.shared.coreData.engine.stateStreamCtrl.stream
    //           .listen(onWaitingEngineStopEnableCustomVideoRender);
    // }
  }

  Future<void> onWaitingEngineStopEnableCustomVideoRender(
    ZegoUIKitExpressEngineState engineState,
  ) async {
    final targetEnabled = ZegoUIKitCore.shared.coreData.engine
        .waitingEngineStartEnableValueOfCustomVideoRender;

    ZegoLoggerService.logInfo(
      'onWaitingEngineStopEnableCustomVideoRender, '
      'target enabled:$targetEnabled, '
      'engineState:$engineState, ',
      tag: 'uikit-stream',
      subTag: 'enableCustomVideoRender',
    );

    ZegoUIKitCore.shared.coreData.engine
        .waitingEngineStartEnableValueOfCustomVideoRender = false;
    ZegoUIKitCore.shared.coreData.engine
        .stateUpdatedSubscriptionByEnableCustomVideoRender
        ?.cancel();

    await enableCustomVideoRender(targetEnabled);
  }

  Future<void> requestDismissKeyguard() async {
    await ZegoUIKitPluginPlatform.instance.requestDismissKeyguard();
  }

  Future<void> startPlayingStreamInPIP(String streamID) async {
    await ZegoUIKitPluginPlatform.instance.startPlayingStreamInPIP(streamID);
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

  /// 打开应用设置页面
  /// 仅支持 Android 平台
  Future<void> openAppSettings() async {
    await ZegoUIKitPluginPlatform.instance.openAppSettings();
  }
}
