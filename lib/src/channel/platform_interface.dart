// Package imports:
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Project imports:
import 'method_channel.dart';

/// @nodoc
abstract class ZegoUIKitPluginPlatform extends PlatformInterface {
  /// Constructs a ZegoUIKitPluginPlatform.
  ZegoUIKitPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static ZegoUIKitPluginPlatform _instance = MethodChannelZegoUIKitPlugin();

  /// The default instance of [ZegoUIKitPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelUntitled].
  static ZegoUIKitPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ZegoUIKitPluginPlatform] when
  /// they register themselves.
  static set instance(ZegoUIKitPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// backToDesktop
  Future<void> backToDesktop({
    bool nonRoot = false,
  }) {
    throw UnimplementedError('backToDesktop has not been implemented.');
  }

  /// isLock
  Future<bool> isLockScreen() {
    throw UnimplementedError('backToDesktop has not been implemented.');
  }

  /// checkAppRunning
  Future<bool> checkAppRunning() {
    throw UnimplementedError('checkAppRunning has not been implemented.');
  }

  /// activeAppToForeground
  Future<void> activeAppToForeground() {
    throw UnimplementedError('activeAppToForeground has not been implemented.');
  }

  Future<void> requestDismissKeyguard() {
    throw UnimplementedError(
        'requestDismissKeyguard has not been implemented.');
  }

  Future<void> enableHardwareDecoder(bool isEnabled) {
    throw UnimplementedError('enableHardwareDecoder has not been implemented.');
  }

  Future<bool> stopIOSPIP() {
    throw UnimplementedError('stopIOSPIP has not been implemented.');
  }

  Future<bool> isIOSInPIP() {
    throw UnimplementedError('isIOSInPIP has not been implemented.');
  }

  Future<void> enableIOSPIPAuto(
    bool isEnabled, {
    int aspectWidth = 9,
    int aspectHeight = 16,
  }) {
    throw UnimplementedError('enableIOSPIPAuto has not been implemented.');
  }

  Future<void> enableIOSPIP(
    String streamID, {
    int aspectWidth = 9,
    int aspectHeight = 16,
  }) {
    throw UnimplementedError('enableIOSPIP has not been implemented.');
  }

  Future<void> updateIOSPIPSource(String streamID) {
    throw UnimplementedError('updateIOSPIPSource has not been implemented.');
  }

  Future<void> enableCustomVideoRender(bool isEnabled) {
    throw UnimplementedError(
        'enableCustomVideoRender has not been implemented.');
  }

  Future<void> startPlayingStreamInPIP(String streamID) {
    throw UnimplementedError(
        'startPlayingStreamInPIP has not been implemented.');
  }

  Future<void> updatePlayingStreamViewInPIP(
    int viewID,
    String streamID,
    int viewMode,
  ) {
    throw UnimplementedError(
        'updatePlayingStreamViewInPIP has not been implemented.');
  }

  Future<void> stopPlayingStreamInPIP(String streamID) {
    throw UnimplementedError(
        'stopPlayingStreamInPIP has not been implemented.');
  }

  Future<void> reporterCreate({
    required String userID,
    required int appID,
    required String signOrToken,
    Map<String, Object> params = const {},
  }) {
    throw UnimplementedError('reporterCreate has not been implemented.');
  }

  Future<void> reporterDestroy() {
    throw UnimplementedError('reporterDestroy has not been implemented.');
  }

  Future<void> reporterUpdateToken(String token) {
    throw UnimplementedError('reporterUpdateToken has not been implemented.');
  }

  Future<void> reporterUpdateCommonParams(Map<String, Object> params) {
    throw UnimplementedError(
        'reporterUpdateCommonParams has not been implemented.');
  }

  Future<void> reporterEvent({
    required String event,
    Map<String, Object> params = const {},
  }) {
    throw UnimplementedError('reporterEvent has not been implemented.');
  }

  /// 打开应用设置页面
  Future<void> openAppSettings() {
    throw UnimplementedError('openAppSettings has not been implemented.');
  }
}
