part of 'uikit_service.dart';

/// @nodoc
mixin ZegoEventService {
  void registerExpressEvent(ZegoUIKitExpressEventInterface event) {
    ZegoUIKitCore.shared.event.express.register(event);
  }

  void unregisterExpressEvent(ZegoUIKitExpressEventInterface event) {
    ZegoUIKitCore.shared.event.express.unregister(event);
  }
}
