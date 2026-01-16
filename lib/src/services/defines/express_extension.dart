// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/services/defines/express.dart';

extension ZegoUIKitVideoConfigExtension on ZegoUIKitVideoConfig {
  String toStringX() {
    return 'ZegoUIKitVideoConfig{'
        'captureWidth:$captureWidth, '
        'captureHeight:$captureHeight, '
        'encodeWidth:$encodeWidth, '
        'encodeHeight:$encodeHeight, '
        'fps:$fps, '
        'bitrate:$bitrate, '
        'codecID:$codecID, '
        'keyFrameInterval:$keyFrameInterval, '
        '}';
  }
}

extension ZegoMixerOutputVideoConfignExtension on ZegoMixerOutputVideoConfig {
  String toStringX() {
    return 'ZegoMixerTask{'
        'videoCodecID, $videoCodecID, '
        'bitrate, $bitrate, '
        'encodeProfile, $encodeProfile, '
        'encodeLatency, $encodeLatency, '
        '}';
  }
}

extension ZegoMixerOutputnExtension on ZegoMixerOutput {
  String toStringX() {
    return 'ZegoMixerOutput{'
        'target:$target, '
        'videoConfig:${videoConfig?.toStringX()}, '
        '}';
  }
}

extension ZegoPublishStreamQualityExtension on ZegoPublishStreamQuality {
  String toStringX() {
    return 'ZegoPublishStreamQualityExtension{'
        'videoCaptureFPS:$videoCaptureFPS, '
        'videoEncodeFPS:$videoEncodeFPS, '
        'videoSendFPS:$videoSendFPS, '
        'videoKBPS:$videoKBPS, '
        'audioCaptureFPS:$audioCaptureFPS, '
        'audioSendFPS:$audioSendFPS, '
        'audioKBPS:$audioKBPS, '
        'rtt:$rtt, '
        'packetLostRate:$packetLostRate, '
        'level:$level, '
        'isHardwareEncode:$isHardwareEncode, '
        'videoCodecID:$videoCodecID, '
        'totalSendBytes:$totalSendBytes, '
        'audioSendBytes:$audioSendBytes, '
        'videoSendByte:$videoSendBytes, '
        'audioTrafficControlRate:$audioTrafficControlRate, '
        'videoTrafficControlRate:$videoTrafficControlRate, '
        '}';
  }

  static ZegoPublishStreamQuality empty() {
    return ZegoPublishStreamQuality(
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0,
      0.0,
      ZegoStreamQualityLevel.Unknown,
      false,
      ZegoVideoCodecID.Default,
      0.0,
      0.0,
      0.0,
      -1,
      -1,
    );
  }
}

extension ZegoStreamExtension on ZegoStream {
  String toStringX() {
    return 'ZegoStreamExtension{'
        'user:(${user.userID},${user.userName}), '
        'streamID:$streamID, '
        'extraInfo:$extraInfo, '
        '}';
  }
}

extension ZegoMixerTaskExtension on ZegoMixerTask {
  String toStringX() {
    return 'ZegoMixerTask{'
        'taskID:$taskID, '
        'audioConfig:${audioConfig.toMap()}, '
        'videoConfig:${videoConfig.toMap()}, '
        'inputList:${inputList.map((e) => e.toMap())}, '
        'outputList:${outputList.map((e) => e.toStringX())}, '
        'watermark:${watermark.toMap()}, '
        'whiteboard:${whiteboard.toMap()}, '
        'backgroundColor:$backgroundColor, '
        'backgroundImageURL:$backgroundImageURL, '
        'enableSoundLevel:$enableSoundLevel, '
        'streamAlignmentMode:$streamAlignmentMode, '
        'userData:$userData, '
        'advancedConfig:$advancedConfig, '
        'minPlayStreamBufferLength:$minPlayStreamBufferLength, '
        '}';
  }
}

extension ZegoMixerStartResultExtesion on ZegoMixerStartResult {
  String toStringX() {
    return 'ZegoMixerStartResult{'
        'errorCode:$errorCode, '
        'extendedData:$extendedData, '
        '}';
  }
}

extension ZegoCDNConfigExtension on ZegoCDNConfig {
  String toStringX() {
    return 'ZegoCDNConfig{'
        'url:$url, '
        'authParam:$authParam, '
        'protocol:$protocol, '
        'quicVersion:$quicVersion, '
        'httpdns:$httpdns, '
        'quicConnectMode:$quicConnectMode, '
        'customParams:$customParams, '
        '}';
  }
}
