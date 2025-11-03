import 'package:zego_express_engine/zego_express_engine.dart';

enum ZegoStreamType {
  main,
  media,
  screenSharing,
  mix,
}

const zegoStreamTypeMediaText = 'player';
const zegoStreamTypeScreenSharingText = 'screensharing';

extension ZegoStreamTypeExtension on ZegoStreamType {
  String get text {
    switch (this) {
      case ZegoStreamType.main:
      case ZegoStreamType.mix:
        return name;
      case ZegoStreamType.media:
        return zegoStreamTypeMediaText;
      case ZegoStreamType.screenSharing:
        return zegoStreamTypeScreenSharingText;
    }
  }

  ZegoPublishChannel get channel {
    switch (this) {
      case ZegoStreamType.main:
        return ZegoPublishChannel.Main;
      case ZegoStreamType.media:
      case ZegoStreamType.screenSharing:
      case ZegoStreamType.mix:
        return ZegoPublishChannel.Aux;
    }
  }
}
