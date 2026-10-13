// Dart imports:
import 'dart:async';

// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

// Project imports:
import 'package:zego_uikit/src/plugins/signaling/impl/core/core.dart';

/// @nodoc
mixin ZegoSignalingPluginCoreEvent {
  bool isEventInit = false;

  List<StreamSubscription<dynamic>> streamSubscriptions = [];

  void initEvent() {
    if (isEventInit) {
      return;
    }

    isEventInit = true;

    final plugin = ZegoPluginAdapter().signalingPlugin!;
    streamSubscriptions.addAll([
      plugin.getConnectionStateChangedEventStream().listen(
        ZegoSignalingPluginCore.shared.coreData.onConnectionStateChanged,
      ),
      plugin.getRoomStateChangedEventStream().listen(
        ZegoSignalingPluginCore.shared.coreData.onRoomStateChanged,
      ),
      plugin.getErrorEventStream().listen(
        ZegoSignalingPluginCore.shared.coreData.onError,
      ),
    ]);

    _initNotificationEvents();
    _initInvitationEvents();
  }

  void _initNotificationEvents() {
    final plugin = ZegoPluginAdapter().signalingPlugin!;
    streamSubscriptions.addAll([
      plugin.getNotificationArrivedEventStream().listen(
        ZegoSignalingPluginCore.shared.coreData.onNotificationArrived,
      ),
      plugin.getNotificationClickedEventStream().listen(
        ZegoSignalingPluginCore.shared.coreData.onNotificationClicked,
      ),
      plugin.getNotificationRegisteredEventStream().listen(
        ZegoSignalingPluginCore.shared.coreData.onNotificationRegistered,
      ),
    ]);
  }

  void _initInvitationEvents() {
    final plugin = ZegoPluginAdapter().signalingPlugin!;
    streamSubscriptions.addAll([
      /// user state events
      plugin.getInvitationUserStateChangedEventStream().listen(
        ZegoSignalingPluginCore.shared.coreData.onInvitationUserStateChanged,
      ),
      plugin.getInvitationUserStateChangedEventStream().listen(
        ZegoSignalingPluginCore
            .shared
            .coreData
            .onAdvanceInvitationUserStateChanged,
      ),

      /// received events
      plugin
          .getIncomingInvitationReceivedEventStream()
          .where((event) => _isNormalEvent(event.mode))
          .listen(
            ZegoSignalingPluginCore
                .shared
                .coreData
                .onIncomingInvitationReceived,
          ),
      plugin
          .getIncomingInvitationReceivedEventStream()
          .where((event) => _isAdvanceEvent(event.mode))
          .listen(
            ZegoSignalingPluginCore
                .shared
                .coreData
                .onIncomingAdvanceInvitationReceived,
          ),

      /// cancel events
      plugin
          .getIncomingInvitationCancelledEventStream()
          .where((event) => _isNormalEvent(event.mode))
          .listen(
            ZegoSignalingPluginCore
                .shared
                .coreData
                .onIncomingInvitationCancelled,
          ),
      plugin
          .getIncomingInvitationCancelledEventStream()
          .where((event) => _isAdvanceEvent(event.mode))
          .listen(
            ZegoSignalingPluginCore
                .shared
                .coreData
                .onIncomingAdvanceInvitationCancelled,
          ),

      /// only normal event
      plugin.getOutgoingInvitationAcceptedEventStream().listen(
        ZegoSignalingPluginCore.shared.coreData.onOutgoingInvitationAccepted,
      ),
      plugin.getOutgoingInvitationRejectedEventStream().listen(
        ZegoSignalingPluginCore.shared.coreData.onOutgoingInvitationRejected,
      ),

      /// end events
      plugin
          .getOutgoingInvitationEndedEventStream()
          .where((event) => _isNormalEvent(event.mode))
          .listen(
            ZegoSignalingPluginCore.shared.coreData.onOutgoingInvitationEnded,
          ),
      plugin
          .getOutgoingInvitationEndedEventStream()
          .where((event) => _isAdvanceEvent(event.mode))
          .listen(
            ZegoSignalingPluginCore
                .shared
                .coreData
                .onOutgoingAdvanceInvitationEnded,
          ),

      /// timeout events
      plugin
          .getIncomingInvitationTimeoutEventStream()
          .where((event) => _isNormalEvent(event.mode))
          .listen(
            ZegoSignalingPluginCore.shared.coreData.onIncomingInvitationTimeout,
          ),
      plugin
          .getIncomingInvitationTimeoutEventStream()
          .where((event) => _isAdvanceEvent(event.mode))
          .listen(
            ZegoSignalingPluginCore
                .shared
                .coreData
                .onIncomingAdvanceInvitationTimeout,
          ),
      plugin.getOutgoingInvitationTimeoutEventStream().listen(
        ZegoSignalingPluginCore.shared.coreData.onOutgoingInvitationTimeout,
      ),
    ]);
  }

  void uninitEvent() {
    isEventInit = false;

    for (final subscription in streamSubscriptions) {
      subscription.cancel();
    }
  }

  bool _isAdvanceEvent(ZegoSignalingPluginInvitationMode mode) {
    return ZegoSignalingPluginInvitationMode.advanced == mode;
  }

  bool _isNormalEvent(ZegoSignalingPluginInvitationMode mode) {
    return ZegoSignalingPluginInvitationMode.advanced != mode;
  }
}
