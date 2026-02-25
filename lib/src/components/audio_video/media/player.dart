// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/services/core/core.dart';
import 'package:zego_uikit/zego_uikit.dart';

/// You can use this control to play audio or video.
///
/// You can directly specify the file to be played using [filePathOrURL].
///
/// If you want to specify the allowed formats, you can set them using [allowedExtensions].
/// Currently, for video, we support "avi", "flv", "mkv", "mov", "mp4", "mpeg", "webm", "wmv".
/// For audio, we support "aac", "midi", "mp3", "ogg", "wav".
class ZegoUIKitMediaPlayer extends StatefulWidget {
  const ZegoUIKitMediaPlayer({
    super.key,
    required this.roomID,
    required this.size,
    required this.config,
    this.filePathOrURL,
    this.initPosition,
    ZegoUIKitMediaPlayerStyle? style,
    ZegoUIKitMediaPlayerEvent? event,
  })  : style = style ?? const ZegoUIKitMediaPlayerStyle(),
        event = event ?? const ZegoUIKitMediaPlayerEvent();

  /// Room ID for the media player.
  final String roomID;

  /// load the absolute path to the local resource or the URL of the network resource
  /// is null, will pop-up and pick files from local
  final String? filePathOrURL;

  /// size of this widget display on parent
  final Size size;

  /// top-left position display this widget on parent widget
  final Offset? initPosition;

  /// Configuration for the media player.
  final ZegoUIKitMediaPlayerConfig config;

  /// Style for the media player UI.
  final ZegoUIKitMediaPlayerStyle style;

  /// Event callbacks for the media player.
  final ZegoUIKitMediaPlayerEvent event;

  @override
  State<StatefulWidget> createState() => _ZegoUIKitMediaPlayerState();
}

class _ZegoUIKitMediaPlayerState extends State<ZegoUIKitMediaPlayer> {
  final showVolumeSliderNotifier = ValueNotifier<bool>(false);
  final surfaceVisibilityNotifier = ValueNotifier<bool>(true);

  Offset? topLeft;

  Timer? hideSurfaceTimer;

  double get spacing => 5;

  double get sliderHeight => 10;

  Size get buttonSize => const Size(20, 20);

  List<String> get allowedExtensions =>
      widget.config.allowedExtensions ??
      [
        /// video
        "avi",
        "flv",
        "mkv",
        "mov",
        "mp4",
        "mpeg",
        "webm",
        "wmv",

        /// audio
        "aac",
        "midi",
        "mp3",
        "ogg",
        "wav",
      ];

  @override
  void initState() {
    super.initState();

    topLeft = widget.initPosition ?? const Offset(10, 10);

    ZegoUIKit().getMediaPlayStateNotifier().addListener(onPlayStateChanged);
  }

  @override
  void dispose() {
    super.dispose();

    hideSurfaceTimer?.cancel();

    ZegoUIKitCore.shared.coreData.engine.createdNotifier
        .removeListener(onExpressEngineCreated);

    ZegoUIKit().getMediaPlayStateNotifier().removeListener(onPlayStateChanged);
  }

  @override
  Widget build(BuildContext context) {
    checkAndShareMedia();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            movable(
              child: Container(
                width: widget.size.width,
                height: widget.size.height,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                child: Stack(
                  children: [
                    media(),
                    surface(constraints.maxWidth, constraints.maxHeight),
                  ],
                ),
              ),
              constraints: constraints,
            ),
          ],
        );
      },
    );
  }

  Widget movable({
    required Widget child,
    required BoxConstraints constraints,
  }) {
    return Positioned(
      left: topLeft?.dx ?? 10,
      top: topLeft?.dy ?? 10,
      child: widget.config.isMovable
          ? GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  var x = topLeft!.dx + details.delta.dx;
                  var y = topLeft!.dy + details.delta.dy;

                  x = x.clamp(
                    0.0,
                    constraints.maxWidth - widget.size.width,
                  );
                  y = y.clamp(
                    0.0,
                    constraints.maxHeight - widget.size.height,
                  );
                  topLeft = Offset(x, y);
                });
              },
              child: child,
            )
          : child,
    );
  }

  Widget media() {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: ZegoUIKitMediaContainer(roomID: widget.roomID),
    );
  }

  Widget surface(double maxViewWidth, double maxViewHeight) {
    if (!widget.config.showSurface) {
      return Container();
    }

    return Container(
      padding: const EdgeInsets.all(10.0),
      child: ValueListenableBuilder<bool>(
        valueListenable: surfaceVisibilityNotifier,
        builder: (context, surfaceVisibility, _) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (showVolumeSliderNotifier.value) {
                showVolumeSliderNotifier.value = false;
              } else {
                surfaceVisibilityNotifier.value = !surfaceVisibility;

                final playState = ZegoUIKit().getMediaPlayStateNotifier().value;
                if (ZegoUIKitMediaPlayState.noPlay == playState ||
                    ZegoUIKitMediaPlayState.playEnded == playState) {
                  /// reject hide if not source playing
                  surfaceVisibilityNotifier.value = true;
                }

                if (surfaceVisibilityNotifier.value) {
                  if (ZegoUIKitMediaPlayState.playing == playState) {
                    startHideSurfaceTimer();
                  }
                }
              }
            },
            child: Container(
              color: Colors.transparent,
              child: surfaceVisibility
                  ? controls(
                      maxViewWidth,
                      maxViewHeight,
                    )
                  : Container(),
            ),
          );
        },
      ),
    );
  }

  Widget controls(double maxViewWidth, double maxViewHeight) {
    return Stack(
      children: [
        ...widget.config.canControl
            ? [
                closeButton(),
                filePickButton(),
                if (widget.config.isPlayButtonCentral)
                  bigPlayButton(
                    maxViewWidth,
                    maxViewHeight,
                  )
                else
                  smallPlayButton(),
              ]
            : [],
        volumeButton(),
        volumeSlider(
          maxViewWidth,
          maxViewHeight,
        ),
        progressSlider(),
        progressDuration(),
      ],
    );
  }

  Widget progressSlider() {
    return ValueListenableBuilder<int>(
      valueListenable: ZegoUIKit().getMediaCurrentProgressNotifier(),
      builder: (context, progress, _) {
        return ValueListenableBuilder<ZegoUIKitMediaPlayState>(
          valueListenable: ZegoUIKit().getMediaPlayStateNotifier(),
          builder: (context, playState, _) {
            final duration = ZegoUIKit().getMediaTotalDuration();
            return Positioned(
              left: spacing,
              right: spacing,
              bottom: spacing,
              child: SizedBox(
                height: sliderHeight,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2.0,
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6.0,
                    ),
                    overlayShape: SliderComponentShape.noOverlay,
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.5),
                    disabledThumbColor: Colors.white,
                    disabledActiveTrackColor: Colors.white,
                    disabledInactiveTrackColor: Colors.white,
                  ),
                  child: ZegoUIKitMediaPlayState.noPlay == playState
                      ? const Slider(
                          min: 0,
                          max: 1,
                          value: 0,
                          onChanged: null,
                        )
                      : Slider(
                          min: 0,
                          max: duration.toDouble(),
                          value: progress.toDouble(),
                          onChanged: widget.config.canControl
                              ? (double value) {
                                  ZegoUIKit().seekTo(value.toInt());
                                }
                              : null,
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget progressDuration() {
    return ValueListenableBuilder<int>(
      valueListenable: ZegoUIKit().getMediaCurrentProgressNotifier(),
      builder: (context, progress, _) {
        final duration = ZegoUIKit().getMediaTotalDuration();
        final progressDuration =
            '${durationFormatString(Duration(milliseconds: progress))} / '
            '${durationFormatString(Duration(milliseconds: duration))}';
        return Positioned(
          bottom: spacing + sliderHeight + 10 / 2,
          left: spacing +
              (widget.config.canControl ? buttonSize.width + spacing : 0),
          child: Text(
            progressDuration,
            style: widget.style.durationTextStyle ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
          ),
        );
      },
    );
  }

  String durationFormatString(Duration elapsedTime) {
    final hours = elapsedTime.inHours;
    final minutes = elapsedTime.inMinutes.remainder(60);
    final seconds = elapsedTime.inSeconds.remainder(60);

    final minutesFormatString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return hours > 0
        ? '${hours.toString().padLeft(2, '0')}:$minutesFormatString'
        : minutesFormatString;
  }

  Widget volumeButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: ZegoUIKit().getMediaMuteNotifier(),
      builder: (context, isMute, _) {
        return Positioned(
          bottom: spacing + sliderHeight + spacing,
          right: 2 * spacing,
          child: GestureDetector(
            onTap: () {
              ZegoUIKit().muteMediaLocal(!isMute);
              if (isMute) {
                showVolumeSliderNotifier.value = true;
              }
            },
            onLongPress: widget.config.canControl
                ? () {
                    showVolumeSliderNotifier.value =
                        !showVolumeSliderNotifier.value;
                  }
                : null,
            child: SizedBox(
              width: buttonSize.width,
              height: buttonSize.height,
              child: (isMute
                      ? widget.style.volumeMuteIcon
                      : widget.style.volumeIcon) ??
                  Icon(
                    isMute ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: buttonSize.width,
                  ),
            ),
          ),
        );
      },
    );
  }

  Widget volumeSlider(double maxViewWidth, double maxViewHeight) {
    return ValueListenableBuilder<bool>(
      valueListenable: showVolumeSliderNotifier,
      builder: (context, isShowVolumeSlider, _) {
        return isShowVolumeSlider
            ? Positioned(
                bottom: spacing + sliderHeight + spacing + buttonSize.height,
                right: spacing + sliderHeight / 2,
                child: RotatedBox(
                  quarterTurns: -1,
                  child: SizedBox(
                    width: maxViewHeight / 2,
                    height: sliderHeight,
                    child: ValueListenableBuilder<int>(
                      valueListenable: ZegoUIKit().getMediaVolumeNotifier(),
                      builder: (context, volume, _) {
                        return SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 2.0,
                            thumbColor: Colors.white,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6.0,
                            ),
                            overlayShape: SliderComponentShape.noOverlay,
                            overlayColor: Colors.yellow.withValues(alpha: 0.4),
                            activeTrackColor: Colors.blue,
                            inactiveTrackColor:
                                Colors.blue.withValues(alpha: 0.5),
                          ),
                          child: Slider(
                            min: 0,
                            max: 100,
                            value: volume.toDouble(),
                            onChangeStart: widget.config.canControl
                                ? (double value) {
                                    hideSurfaceTimer?.cancel();
                                  }
                                : null,
                            onChangeEnd: widget.config.canControl
                                ? (double value) {
                                    startHideSurfaceTimer();
                                  }
                                : null,
                            onChanged: widget.config.canControl
                                ? (double value) {
                                    ZegoUIKit().setMediaVolume(value.toInt());
                                  }
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
            : Container();
      },
    );
  }

  Widget bigPlayButton(double maxViewWidth, double maxViewHeight) {
    final buttonSize = Size(maxViewWidth / 6.0, maxViewWidth / 6.0);
    return Center(
      child: ValueListenableBuilder<ZegoUIKitMediaPlayState>(
        valueListenable: ZegoUIKit().getMediaPlayStateNotifier(),
        builder: (context, playState, _) {
          return GestureDetector(
            onTap: () {
              onPlayButtonClick(playState);
            },
            child: SizedBox(
              width: buttonSize.width,
              height: buttonSize.height,
              child: getPlayButtonIcon(playState, buttonSize),
            ),
          );
        },
      ),
    );
  }

  Widget smallPlayButton() {
    return Positioned(
      bottom: spacing + sliderHeight + spacing,
      left: spacing,
      child: ValueListenableBuilder<ZegoUIKitMediaPlayState>(
        valueListenable: ZegoUIKit().getMediaPlayStateNotifier(),
        builder: (context, playState, _) {
          return GestureDetector(
            onTap: () {
              onPlayButtonClick(playState);
            },
            child: SizedBox(
              width: buttonSize.width,
              height: buttonSize.height,
              child: getPlayButtonIcon(playState, buttonSize),
            ),
          );
        },
      ),
    );
  }

  Widget getPlayButtonIcon(ZegoUIKitMediaPlayState playState, Size buttonSize) {
    var icon = widget.style.playIcon ??
        Icon(
          Icons.play_circle,
          color: Colors.white,
          size: buttonSize.width,
        );

    switch (playState) {
      case ZegoUIKitMediaPlayState.playing:
        icon = widget.style.pauseIcon ??
            Icon(
              Icons.pause_circle,
              color: Colors.white,
              size: buttonSize.width,
            );
        break;
      case ZegoUIKitMediaPlayState.noPlay:
      case ZegoUIKitMediaPlayState.loadReady:
      case ZegoUIKitMediaPlayState.pausing:
      case ZegoUIKitMediaPlayState.playEnded:
        icon = widget.style.playIcon ??
            Icon(
              Icons.play_circle,
              color: Colors.white,
              size: buttonSize.width,
            );
        break;
    }

    return icon;
  }

  Future<void> onPlayButtonClick(ZegoUIKitMediaPlayState playState) async {
    if (!widget.config.canControl) {
      return;
    }

    switch (playState) {
      case ZegoUIKitMediaPlayState.noPlay:
        if (widget.filePathOrURL?.isNotEmpty ?? false) {
          shareMedia(widget.filePathOrURL!);
        } else {
          pickMediaToShare();
        }
        break;
      case ZegoUIKitMediaPlayState.loadReady:
        ZegoUIKit().startMedia();
        break;
      case ZegoUIKitMediaPlayState.playing:
        ZegoUIKit().pauseMedia();
        break;
      case ZegoUIKitMediaPlayState.pausing:
        ZegoUIKit().resumeMedia();
        break;
      case ZegoUIKitMediaPlayState.playEnded:
        ZegoUIKit().startMedia();
        break;
    }
  }

  Widget closeButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: GestureDetector(
        onTap: widget.config.canControl ? destroyMedia : null,
        child: SizedBox(
          width: buttonSize.width,
          height: buttonSize.height,
          child: widget.style.closeIcon ??
              Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: buttonSize.width,
              ),
        ),
      ),
    );
  }

  Widget filePickButton() {
    return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTap: widget.config.canControl ? pickMediaToShare : null,
        child: SizedBox(
          width: buttonSize.width,
          height: buttonSize.height,
          child: widget.style.moreIcon ??
              Icon(
                Icons.more_vert,
                color: Colors.white,
                size: buttonSize.width,
              ),
        ),
      ),
    );
  }

  Future<void> destroyMedia() async {
    await ZegoUIKit().destroyMedia();
  }

  Future<void> pickMediaToShare() async {
    final files = await ZegoUIKit().pickMediaFile(
      allowedExtensions: allowedExtensions,
    );
    if (files.isEmpty) {
      ZegoLoggerService.logInfo(
        'files is empty',
        tag: 'uikit.component',
        subTag: 'media player',
      );
    } else {
      shareMedia(files.first.path ?? '');
    }
  }

  Future<void> shareMedia(String targetPathOrURL) async {
    if (!widget.config.canControl) {
      return;
    }

    if (targetPathOrURL.isEmpty) {
      return;
    }

    final shareResult = await ZegoUIKit().playMedia(
      filePathOrURL: targetPathOrURL,
      enableRepeat: widget.config.enableRepeat,
      autoStart: widget.config.autoStart,
    );
    if (0 != shareResult.errorCode) {
      ZegoLoggerService.logInfo(
        'share media failed:${shareResult.errorCode}',
        tag: 'uikit.component',
        subTag: 'media player',
      );
    }
  }

  void onPlayStateChanged() {
    final playState = ZegoUIKit().getMediaPlayStateNotifier().value;

    widget.event.onPlayStateChanged?.call(playState);

    if (ZegoUIKitMediaPlayState.playing == playState) {
      startHideSurfaceTimer();
    } else {
      hideSurfaceTimer?.cancel();
    }
  }

  void startHideSurfaceTimer() {
    hideSurfaceTimer?.cancel();

    if (!widget.config.autoHideSurface) {
      return;
    }

    hideSurfaceTimer = Timer.periodic(
      Duration(seconds: widget.config.hideSurfaceSecond),
      (timer) {
        hideSurfaceTimer?.cancel();

        surfaceVisibilityNotifier.value = false;
      },
    );
  }

  void checkAndShareMedia() {
    if (widget.filePathOrURL?.isNotEmpty ?? false) {
      if (ZegoUIKitCore.shared.coreData.engine.createdNotifier.value) {
        autoShareMedia();
      } else {
        ZegoUIKitCore.shared.coreData.engine.createdNotifier
            .addListener(onExpressEngineCreated);

        ZegoLoggerService.logInfo(
          'express engine is not created, wait..',
          tag: 'uikit.component',
          subTag: 'media player',
        );
      }
    }
  }

  void onExpressEngineCreated() {
    final isCreated =
        ZegoUIKitCore.shared.coreData.engine.createdNotifier.value;
    ZegoLoggerService.logInfo(
      'express engine created:$isCreated',
      tag: 'uikit.component',
      subTag: 'media player',
    );

    if (isCreated) {
      ZegoUIKitCore.shared.coreData.engine.createdNotifier
          .removeListener(onExpressEngineCreated);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        autoShareMedia();
      });
    }
  }

  void autoShareMedia() {
    ZegoLoggerService.logInfo(
      'auto share media:${widget.filePathOrURL}',
      tag: 'uikit.component',
      subTag: 'media player',
    );

    final currentPlayState = ZegoUIKit().getMediaPlayStateNotifier().value;
    if (ZegoUIKitMediaPlayState.noPlay != currentPlayState) {
      ZegoLoggerService.logInfo(
        'play state is not no play, $currentPlayState',
        tag: 'uikit.component',
        subTag: 'media player',
      );

      return;
    }

    ZegoUIKit()
        .playMedia(
      filePathOrURL: widget.filePathOrURL!,
      enableRepeat: widget.config.enableRepeat,
      autoStart: widget.config.autoStart,
    )
        .then((shareResult) {
      ZegoLoggerService.logInfo(
        'auto share media result:${widget.filePathOrURL}',
        tag: 'uikit.component',
        subTag: 'media player',
      );
    });
  }
}
