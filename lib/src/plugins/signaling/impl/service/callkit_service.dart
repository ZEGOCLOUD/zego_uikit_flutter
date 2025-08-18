// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

/// @nodoc
mixin ZegoPluginCallKitService {
  Future<void> setIncomingPushReceivedHandler(
      ZegoSignalingIncomingPushReceivedHandler handler) async {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .setIncomingPushReceivedHandler(handler);
  }

  Future<void> setInitConfiguration(
    ZegoSignalingPluginProviderConfiguration configuration,
  ) async {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .setInitConfiguration(configuration);
  }

  /// Called when the provider has been reset. Delegates must respond to this callback by cleaning up all internal call state (disconnecting communication channels, releasing network resources, etc.). This callback can be treated as a request to end all calls without the need to respond to any actions
  Stream<ZegoSignalingPluginCallKitVoidEvent>
      getCallkitProviderDidResetEventStream() {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .getCallkitProviderDidResetEventStream();
  }

  /// Called when the provider has been fully created and is ready to send actions and receive updates
  Stream<ZegoSignalingPluginCallKitVoidEvent>
      getCallkitProviderDidBeginEventStream() {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .getCallkitProviderDidBeginEventStream();
  }

  /// Called when the provider's audio session activation state changes.
  Stream<ZegoSignalingPluginCallKitVoidEvent>
      getCallkitActivateAudioEventStream() {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .getCallkitActivateAudioEventStream();
  }

  Stream<ZegoSignalingPluginCallKitVoidEvent>
      getCallkitDeactivateAudioEventStream() {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .getCallkitDeactivateAudioEventStream();
  }

  /// Called when an action was not performed in time and has been inherently failed. Depending on the action, this timeout may also force the call to end. An action that has already timed out should not be fulfilled or failed by the provider delegate
  Stream<ZegoSignalingPluginCallKitActionEvent>
      getCallkitTimedOutPerformingActionEventStream() {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .getCallkitTimedOutPerformingActionEventStream();
  }

  /// each perform*CallAction method is called sequentially for each action in the transaction
  Stream<ZegoSignalingPluginCallKitActionEvent>
      getCallkitPerformStartCallActionEventStream() {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .getCallkitPerformStartCallActionEventStream();
  }

  Stream<ZegoSignalingPluginCallKitActionEvent>
      getCallkitPerformAnswerCallActionEventStream() {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .getCallkitPerformAnswerCallActionEventStream();
  }

  Stream<ZegoSignalingPluginCallKitActionEvent>
      getCallkitPerformEndCallActionEventStream() {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .getCallkitPerformEndCallActionEventStream();
  }

  Stream<ZegoSignalingPluginCallKitActionEvent>
      getCallkitPerformSetHeldCallActionEventStream() {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .getCallkitPerformSetHeldCallActionEventStream();
  }

  Stream<ZegoSignalingPluginCallKitActionEvent>
      getCallkitPerformSetMutedCallActionEventStream() {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .getCallkitPerformSetMutedCallActionEventStream();
  }

  Stream<ZegoSignalingPluginCallKitActionEvent>
      getCallkitPerformSetGroupCallActionEventStream() {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .getCallkitPerformSetGroupCallActionEventStream();
  }

  Stream<ZegoSignalingPluginCallKitActionEvent>
      getCallkitPerformPlayDTMFCallActionEventStream() {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .getCallkitPerformPlayDTMFCallActionEventStream();
  }
}
