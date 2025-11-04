// Dart imports:
import 'dart:typed_data';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'state.dart';

class ZegoUIKitMediaPlayerEvent {
  const ZegoUIKitMediaPlayerEvent({
    this.onPlayStateChanged,
  });

  /// play state callback
  final void Function(ZegoUIKitMediaPlayState)? onPlayStateChanged;
}

///

/// Example:
/// ``` dart
/// ...
/// final mediaEvent = MediaEvent();
/// ZegoUIKit().registerMediaEvent(mediaEvent);
/// ...
/// class MediaEvent extends ZegoUIKitMediaEventInterface
/// {
/// ...
///   @override
///   void onMediaPlayerStateUpdate(
///       ZegoMediaPlayer mediaPlayer,
///       ZegoMediaPlayerState state,
///       int errorCode,) {
///     /// your code
///   }
/// ...
/// }
///
/// class MediaEvent implements ZegoUIKitMediaEventInterface
/// {
/// ...
/// }
/// ```
class ZegoUIKitMediaEventInterface {
  /// MediaPlayer playback status callback.
  ///
  /// Description: MediaPlayer playback status callback.
  /// Trigger: The callback triggered when the state of the media player changes.
  /// Restrictions: None.
  ///
  /// - [mediaPlayer] Callback player object.
  /// - [state] Media player status.
  /// - [errorCode] Error code, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  void onMediaPlayerStateUpdate(
    ZegoMediaPlayer mediaPlayer,
    ZegoMediaPlayerState state,
    int errorCode,
  ) {}

  /// The callback triggered when the network status of the media player changes.
  ///
  /// Description: The callback triggered when the network status of the media player changes.
  /// Trigger: When the media player is playing network resources, this callback will be triggered when the status change of the cached data.
  /// Restrictions: The callback will only be triggered when the network resource is played.
  /// Related APIs: [setNetWorkBufferThreshold].
  ///
  /// - [mediaPlayer] Callback player object.
  /// - [networkEvent] Network status event.
  void onMediaPlayerNetworkEvent(
    ZegoMediaPlayer mediaPlayer,
    ZegoMediaPlayerNetworkEvent networkEvent,
  ) {}

  /// The callback to report the current playback progress of the media player.
  ///
  /// Description: The callback triggered when the network status of the media player changes.
  /// Set the callback interval by calling [setProgressInterval].
  /// When the callback interval is set to 0, the callback is stopped. The default callback interval is 1 second.
  /// Trigger: When the media player is playing network resources, this callback will be triggered when the status change of the cached data.
  /// Restrictions: None.
  /// Related APIs: [setProgressInterval].
  ///
  /// - [mediaPlayer] Callback player object.
  /// - [millisecond] Progress in milliseconds.
  void onMediaPlayerPlayingProgress(
    ZegoMediaPlayer mediaPlayer,
    int millisecond,
  ) {}

  /// The callback to report the current rendering progress of the media player.
  ///
  /// Description: The callback to report the current rendering progress of the media player. Set the callback interval by calling [setProgressInterval]. When the callback interval is set to 0, the callback is stopped. The default callback interval is 1 second.
  /// Trigger: This callback will be triggered when the media player starts playing resources.
  /// Restrictions: None.
  /// Related APIs: [setProgressInterval].
  ///
  /// - [mediaPlayer] Callback player object.
  /// - [millisecond] Progress in milliseconds.
  void onMediaPlayerRenderingProgress(
    ZegoMediaPlayer mediaPlayer,
    int millisecond,
  ) {}

  /// The callback triggered when when the resolution of the playback video changes.
  ///
  /// Description: The callback triggered when when the resolution of the playback video changes.
  /// Trigger: When the media player is playing a video resource, This callback will be triggered when playback starts and the resolution of the video changes.
  ///
  /// - [mediaPlayer] Callback player object.
  /// - [width] width.
  /// - [height] height.
  void onMediaPlayerVideoSizeChanged(
    ZegoMediaPlayer mediaPlayer,
    int width,
    int height,
  ) {}

  /// The callback triggered when the media player got media side info.
  ///
  /// Description: The callback triggered when the media player got media side info.
  /// Trigger: When the media player starts playing media files, the callback is triggered if the SEI is resolved to the media file.
  /// Caution: The callback does not actually take effect until call [setEventHandler] to set.
  ///
  /// - [mediaPlayer] Callback player object.
  /// - [data] SEI content.
  void onMediaPlayerRecvSEI(
    ZegoMediaPlayer mediaPlayer,
    Uint8List data,
  ) {}

  /// The callback of sound level update.
  ///
  /// Description: The callback of sound level update.
  /// Trigger: The callback frequency is specified by [EnableSoundLevelMonitor].
  /// Caution: The callback does not actually take effect until call [setEventHandler] to set.
  /// Related APIs: To monitor this callback, you need to enable it through [EnableSoundLevelMonitor].
  ///
  /// - [mediaPlayer] Callback player object.
  /// - [soundLevel] Sound level value, value range: [0.0, 100.0].
  void onMediaPlayerSoundLevelUpdate(
    ZegoMediaPlayer mediaPlayer,
    double soundLevel,
  ) {}

  /// The callback of frequency spectrum update.
  ///
  /// Description: The callback of frequency spectrum update.
  /// Trigger: The callback frequency is specified by [EnableFrequencySpectrumMonitor].
  /// Caution: The callback does not actually take effect until call [setEventHandler] to set.
  /// Related APIs: To monitor this callback, you need to enable it through [EnableFrequencySpectrumMonitor].
  ///
  /// - [mediaPlayer] Callback player object.
  /// - [spectrumList] Locally captured frequency spectrum value list. Spectrum value range is [0-2^30].
  void onMediaPlayerFrequencySpectrumUpdate(
    ZegoMediaPlayer mediaPlayer,
    List<double> spectrumList,
  ) {}

  /// The callback triggered when the media player plays the first frame.
  ///
  /// Description: The callback triggered when the media player plays the first frame.
  /// Trigger: This callback is generated when the media player starts playing.
  /// Caution: The callback does not actually take effect until call [setEventHandler] to set.
  /// Related APIs: You need to call the [setPlayerCanvas] interface to set the view for the media player in order to receive the video first frame event callback.
  ///
  /// - [mediaPlayer] Callback player object.
  /// - [event] The first frame callback event type.
  void onMediaPlayerFirstFrameEvent(
    ZegoMediaPlayer mediaPlayer,
    ZegoMediaPlayerFirstFrameEvent event,
  ) {}

  /// The event callback of the media data publisher opening a media file.
  ///
  /// Description: The event callback of the media data publisher opening a media file.
  /// Trigger: The callback triggered when the media data publisher start loading a media file.
  /// Restrictions: None.
  ///
  /// - [mediaDataPublisher] Callback publisher object
  /// - [path] Path of currently open file
  void onMediaDataPublisherFileOpen(
    ZegoMediaDataPublisher mediaDataPublisher,
    String path,
  ) {}

  /// The event callback of the media data publisher closing a media file.
  ///
  /// Description: The event callback of the media data publisher closing a media file.
  /// Trigger: The callback triggered when the media data publisher start unloading a media file.
  /// Restrictions: None.
  ///
  /// - [mediaDataPublisher] Callback publisher object
  /// - [errorCode] error code. 0 means closing the file normally.
  /// - [path] Path of currently open file
  void onMediaDataPublisherFileClose(
    ZegoMediaDataPublisher mediaDataPublisher,
    int errorCode,
    String path,
  ) {}

  /// The event callback that the media data publisher has read data from the media file.
  ///
  /// Description: The event callback that the media data publisher has read data from the media file.
  /// Trigger: The callback triggered when the media data publisher begin to read media data from a media file.
  /// Restrictions: None.
  ///
  /// - [mediaDataPublisher] Callback publisher object
  /// - [path] Path of currently open file
  void onMediaDataPublisherFileDataBegin(
    ZegoMediaDataPublisher mediaDataPublisher,
    String path,
  ) {}
}
