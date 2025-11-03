part of 'event.dart';

mixin ZegoUIKitMediaEvent {
  final _mediaImpl = ZegoUIKitMediaEventImpl();

  ZegoUIKitMediaEventImpl get media => _mediaImpl;
}

class ZegoUIKitMediaEventImpl {
  List<ZegoUIKitMediaEventInterface> events = [];

  void register(ZegoUIKitMediaEventInterface event) {
    if (events.contains(event)) {
      ZegoLoggerService.logInfo(
        '${event.hashCode} has registered',
        tag: 'uikit-media',
        subTag: 'event',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'register, ${event.hashCode}',
      tag: 'uikit-media',
      subTag: 'event',
    );

    events.add(event);
  }

  void unregister(ZegoUIKitMediaEventInterface event) {
    ZegoLoggerService.logInfo(
      'unregister, ${event.hashCode}',
      tag: 'uikit-media',
      subTag: 'event',
    );

    events.remove(event);
  }

  void init() {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'uikit-media',
      subTag: 'event',
    );

    ZegoExpressEngine.onMediaPlayerStateUpdate = onMediaPlayerStateUpdate;
    ZegoExpressEngine.onMediaPlayerNetworkEvent = onMediaPlayerNetworkEvent;
    ZegoExpressEngine.onMediaPlayerPlayingProgress =
        onMediaPlayerPlayingProgress;
    ZegoExpressEngine.onMediaPlayerRenderingProgress =
        onMediaPlayerRenderingProgress;
    ZegoExpressEngine.onMediaPlayerVideoSizeChanged =
        onMediaPlayerVideoSizeChanged;
    ZegoExpressEngine.onMediaPlayerRecvSEI = onMediaPlayerRecvSEI;
    ZegoExpressEngine.onMediaPlayerSoundLevelUpdate =
        onMediaPlayerSoundLevelUpdate;
    ZegoExpressEngine.onMediaPlayerFrequencySpectrumUpdate =
        onMediaPlayerFrequencySpectrumUpdate;
    ZegoExpressEngine.onMediaPlayerFirstFrameEvent =
        onMediaPlayerFirstFrameEvent;
    ZegoExpressEngine.onMediaDataPublisherFileOpen =
        onMediaDataPublisherFileOpen;
    ZegoExpressEngine.onMediaDataPublisherFileClose =
        onMediaDataPublisherFileClose;
    ZegoExpressEngine.onMediaDataPublisherFileDataBegin =
        onMediaDataPublisherFileDataBegin;
  }

  void uninit() {
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'uikit-media',
      subTag: 'event',
    );

    ZegoExpressEngine.onMediaPlayerStateUpdate = null;
    ZegoExpressEngine.onMediaPlayerNetworkEvent = null;
    ZegoExpressEngine.onMediaPlayerPlayingProgress = null;
    ZegoExpressEngine.onMediaPlayerRenderingProgress = null;
    ZegoExpressEngine.onMediaPlayerVideoSizeChanged = null;
    ZegoExpressEngine.onMediaPlayerRecvSEI = null;
    ZegoExpressEngine.onMediaPlayerSoundLevelUpdate = null;
    ZegoExpressEngine.onMediaPlayerFrequencySpectrumUpdate = null;
    ZegoExpressEngine.onMediaPlayerFirstFrameEvent = null;
    ZegoExpressEngine.onMediaDataPublisherFileOpen = null;
    ZegoExpressEngine.onMediaDataPublisherFileClose = null;
    ZegoExpressEngine.onMediaDataPublisherFileDataBegin = null;
  }

  void onMediaPlayerStateUpdate(
    ZegoMediaPlayer mediaPlayer,
    ZegoMediaPlayerState state,
    int errorCode,
  ) {
    for (var event in events) {
      event.onMediaPlayerStateUpdate(mediaPlayer, state, errorCode);
    }
  }

  void onMediaPlayerNetworkEvent(
    ZegoMediaPlayer mediaPlayer,
    ZegoMediaPlayerNetworkEvent networkEvent,
  ) {
    for (var event in events) {
      event.onMediaPlayerNetworkEvent(mediaPlayer, networkEvent);
    }
  }

  void onMediaPlayerPlayingProgress(
    ZegoMediaPlayer mediaPlayer,
    int millisecond,
  ) {
    for (var event in events) {
      event.onMediaPlayerPlayingProgress(mediaPlayer, millisecond);
    }
  }

  void onMediaPlayerRenderingProgress(
    ZegoMediaPlayer mediaPlayer,
    int millisecond,
  ) {}

  void onMediaPlayerVideoSizeChanged(
    ZegoMediaPlayer mediaPlayer,
    int width,
    int height,
  ) {}

  void onMediaPlayerRecvSEI(
    ZegoMediaPlayer mediaPlayer,
    Uint8List data,
  ) {
    for (var event in events) {
      event.onMediaPlayerRecvSEI(mediaPlayer, data);
    }
  }

  void onMediaPlayerSoundLevelUpdate(
    ZegoMediaPlayer mediaPlayer,
    double soundLevel,
  ) {
    for (var event in events) {
      event.onMediaPlayerSoundLevelUpdate(mediaPlayer, soundLevel);
    }
  }

  void onMediaPlayerFrequencySpectrumUpdate(
    ZegoMediaPlayer mediaPlayer,
    List<double> spectrumList,
  ) {
    for (var event in events) {
      event.onMediaPlayerFrequencySpectrumUpdate(mediaPlayer, spectrumList);
    }
  }

  void onMediaPlayerFirstFrameEvent(
    ZegoMediaPlayer mediaPlayer,
    ZegoMediaPlayerFirstFrameEvent firstFrameEvent,
  ) {
    for (var event in events) {
      event.onMediaPlayerFirstFrameEvent(mediaPlayer, firstFrameEvent);
    }
  }

  void onMediaDataPublisherFileOpen(
    ZegoMediaDataPublisher mediaDataPublisher,
    String path,
  ) {
    for (var event in events) {
      event.onMediaDataPublisherFileOpen(mediaDataPublisher, path);
    }
  }

  void onMediaDataPublisherFileClose(
    ZegoMediaDataPublisher mediaDataPublisher,
    int errorCode,
    String path,
  ) {
    for (var event in events) {
      event.onMediaDataPublisherFileClose(mediaDataPublisher, errorCode, path);
    }
  }

  void onMediaDataPublisherFileDataBegin(
    ZegoMediaDataPublisher mediaDataPublisher,
    String path,
  ) {
    for (var event in events) {
      event.onMediaDataPublisherFileDataBegin(mediaDataPublisher, path);
    }
  }
}
