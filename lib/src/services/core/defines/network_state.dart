// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/services/defines/network.dart';

extension ZegoUIKitNetworkStateExtension on ZegoUIKitNetworkState {
  static ZegoUIKitNetworkState fromZego(ZegoNetworkMode networkMode) {
    ZegoUIKitNetworkState uiKitNetworkState = ZegoUIKitNetworkState.unknown;
    switch (networkMode) {
      case ZegoNetworkMode.Offline:
      case ZegoNetworkMode.Unknown:
        uiKitNetworkState = ZegoUIKitNetworkState.offline;
        break;
      case ZegoNetworkMode.Ethernet:
      case ZegoNetworkMode.WiFi:
      case ZegoNetworkMode.Mode2G:
      case ZegoNetworkMode.Mode3G:
      case ZegoNetworkMode.Mode4G:
      case ZegoNetworkMode.Mode5G:
        uiKitNetworkState = ZegoUIKitNetworkState.online;
        break;
    }

    return uiKitNetworkState;
  }
}
