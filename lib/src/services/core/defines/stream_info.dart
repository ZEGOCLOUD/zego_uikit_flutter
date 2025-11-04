// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_uikit/src/services/defines/express.dart';
import 'package:zego_uikit/src/services/defines/express_extension.dart';
import 'package:zego_uikit/src/services/uikit_service.dart';

class ZegoUIKitCoreStreamInfo {
  String streamID = '';
  int streamTimestamp = 0;

  ValueNotifier<int?> viewIDNotifier = ValueNotifier<int?>(-1);
  ValueNotifier<Widget?> viewNotifier = ValueNotifier<Widget?>(null);
  ValueNotifier<bool> viewCreatingNotifier = ValueNotifier<bool>(false);
  ValueNotifier<Size> viewSizeNotifier =
      ValueNotifier<Size>(const Size(360, 640));
  StreamController<double>? soundLevelStream;

  ValueNotifier<ZegoUIKitPublishStreamQuality> qualityNotifier =
      ValueNotifier<ZegoUIKitPublishStreamQuality>(
    ZegoPublishStreamQualityExtension.empty(),
  );
  ValueNotifier<bool> isCapturedAudioFirstFrameNotifier =
      ValueNotifier<bool>(false);
  ValueNotifier<bool> isCapturedVideoFirstFrameNotifier =
      ValueNotifier<bool>(false);
  ValueNotifier<bool> isRenderedVideoFirstFrameNotifier =
      ValueNotifier<bool>(false);
  ValueNotifier<bool> isSendAudioFirstFrameNotifier =
      ValueNotifier<bool>(false);
  ValueNotifier<bool> isSendVideoFirstFrameNotifier =
      ValueNotifier<bool>(false);
  ValueNotifier<GlobalKey> globalMainStreamChannelKeyNotifier =
      ValueNotifier<GlobalKey>(GlobalKey());
  ValueNotifier<GlobalKey> globalAuxStreamChannelKeyNotifier =
      ValueNotifier<GlobalKey>(GlobalKey());

  ZegoUIKitCoreStreamInfo.empty() {
    soundLevelStream ??= StreamController<double>.broadcast();

    viewIDNotifier.addListener(_onViewIDUpdate);
    viewNotifier.addListener(_onViewUpdate);
  }

  void closeSoundLevel() {
    soundLevelStream?.close();
  }

  void clearViewInfo() {
    viewIDNotifier.value = -1;
    viewNotifier.value = null;
    viewSizeNotifier.value = const Size(360, 640);

    qualityNotifier.value = ZegoPublishStreamQualityExtension.empty();
    isCapturedAudioFirstFrameNotifier.value = false;
    isCapturedVideoFirstFrameNotifier.value = false;
    isRenderedVideoFirstFrameNotifier.value = false;
    isSendAudioFirstFrameNotifier.value = false;
    isSendVideoFirstFrameNotifier.value = false;
  }

  void _onViewUpdate() {
    ZegoLoggerService.logInfo(
      'view:${viewNotifier.value}, '
      'stream id:$streamID, ',
      tag: 'uikit-stream',
      subTag: 'onViewUpdate',
    );
  }

  void _onViewIDUpdate() {
    ZegoLoggerService.logInfo(
      'view id:${viewIDNotifier.value}, '
      'stream id:$streamID, ',
      tag: 'uikit-stream',
      subTag: 'onViewIDUpdate',
    );
  }
}
