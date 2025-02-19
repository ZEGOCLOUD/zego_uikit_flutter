// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

/// @nodoc
mixin ZegoPluginBackgroundMessageService {
  Future<void> removeBackgroundMessageHandler({String key = ''}) async {
    return ZegoPluginAdapter().signalingPlugin!.removeBackgroundMessageHandler(
          key: key,
        );
  }

  /// register background message handler
  /// only for Android
  ///
  ///
  /// ```dart
  /// @pragma('vm:entry-point')
  /// Future<void> handler1(ZPNsMessage message) async {
  ///     String title,
  ///     String content,
  ///     Map<String, Object?> extras,
  ///     ZegoUIKitCallPushSourceType pushSourceType,
  ///     ) {
  ///   debugPrint(
  ///       'handler 1 recv, title:$title, content:$content, extras:$extras, push type :$pushSourceType');
  /// }
  ///
  /// await ZegoUIKit().getSignalingPlugin().setBackgroundMessageHandler(
  /// handler1,
  /// key: 'handler1',
  /// );
  /// ```
  Future<ZegoSignalingPluginSetMessageHandlerResult>
      setBackgroundMessageHandler(
    ZegoSignalingPluginZPNsBackgroundMessageHandler handler, {
    String key = 'default',
  }) async {
    return ZegoPluginAdapter().signalingPlugin!.setBackgroundMessageHandler(
          handler,
          key: key,
        );
  }

  Future<ZegoSignalingPluginSetMessageHandlerResult> setThroughMessageHandler(
    ZegoSignalingPluginZPNsThroughMessageHandler? handler,
  ) async {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .setThroughMessageHandler(handler);
  }
}
