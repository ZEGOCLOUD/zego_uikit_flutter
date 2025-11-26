// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/services/core/defines/defines.dart';
import 'package:zego_uikit/src/services/services.dart';

class ZegoUIKitStreamHelper {
  static ZegoUIKitCoreStreamInfo getUserStreamChannel(
    ZegoUIKitCoreUser user,
    ZegoStreamType streamType,
  ) {
    switch (streamType) {
      case ZegoStreamType.main:
        return user.mainChannel;
      case ZegoStreamType.media:
      case ZegoStreamType.screenSharing:
      case ZegoStreamType.mix:
        return user.auxChannel;
      // return user.thirdChannel;
    }
  }

  static ZegoStreamType getStreamTypeByZegoPublishChannel(
    ZegoUIKitCoreUser user,
    ZegoPublishChannel channel,
  ) {
    switch (channel) {
      case ZegoPublishChannel.Main:
        return ZegoStreamType.main;
      case ZegoPublishChannel.Aux:
        return getStreamTypeByID(user.auxChannel.streamID);
      default:
        break;
    }

    assert(false);
    return ZegoStreamType.main;
  }

  static ZegoStreamType getStreamTypeByID(String streamID) {
    if (streamID.endsWith(ZegoStreamType.main.text)) {
      return ZegoStreamType.main;
    } else if (streamID.endsWith(ZegoStreamType.media.text)) {
      return ZegoStreamType.media;
    } else if (streamID.endsWith(ZegoStreamType.screenSharing.text)) {
      return ZegoStreamType.screenSharing;
    } else if (streamID.endsWith(ZegoStreamType.mix.text)) {
      return ZegoStreamType.mix;
    }

    assert(false);
    return ZegoStreamType.main;
  }
}
