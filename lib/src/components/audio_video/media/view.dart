// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/components/audio_video/defines.dart';
import 'package:zego_uikit/src/components/audio_video/media/wave.dart';
import 'package:zego_uikit/src/services/services.dart';

/// display user media view,
/// and z order of widget(from bottom to top) is:
/// 1. background view
/// 2. media view
/// 3. foreground view
class ZegoUIKitMediaView extends StatefulWidget {
  const ZegoUIKitMediaView({
    Key? key,
    required this.user,
    this.backgroundBuilder,
    this.foregroundBuilder,
    this.borderRadius,
    this.borderColor,
    this.extraInfo,
  }) : super(key: key);

  final ZegoUIKitUser? user;

  /// foreground builder, you can display something you want on top of the view,
  /// foreground will always show
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;

  /// background builder, you can display something when user close camera
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  final double? borderRadius;
  final Color? borderColor;
  final Map<String, dynamic>? extraInfo;

  @override
  State<ZegoUIKitMediaView> createState() => _ZegoUIKitMediaViewState();
}

class _ZegoUIKitMediaViewState extends State<ZegoUIKitMediaView> {
  bool get logEnabled => false;

  @override
  Widget build(BuildContext context) {
    return circleBorder(
      child: Stack(
        children: [
          background(),
          mediaView(),
          foreground(),
        ],
      ),
    );
  }

  Widget mediaView() {
    if (widget.user == null) {
      ZegoLoggerService.logInfo(
        'use id:(${widget.user?.id}) is null',
        tag: 'uikit-component',
        subTag: 'media view',
      );

      return Container(color: Colors.transparent);
    }

    return SizedBox.expand(
      child: ValueListenableBuilder<ZegoUIKitMediaType>(
        valueListenable: ZegoUIKit().getMediaTypeNotifier(),
        builder: (context, mediaType, _) {
          return mediaType == ZegoUIKitMediaType.video
              ? ValueListenableBuilder<Widget?>(
                  valueListenable: ZegoUIKit().getAudioVideoViewNotifier(
                    widget.user!.id,
                    streamType: ZegoStreamType.media,
                  ),
                  builder: (context, userView, _) {
                    if (userView == null) {
                      ZegoLoggerService.logError(
                        '${widget.user?.id}\'s view is null',
                        tag: 'uikit-component',
                        subTag: 'media view',
                      );

                      /// hide video view when use not found
                      return Container(color: Colors.transparent);
                    }

                    return userView;
                  },
                )
              : ZegoUIKitMediaWaveform(
                  soundLevelStream: widget.user!.auxSoundLevel,
                  playStateNotifier: ZegoUIKit().getMediaPlayStateNotifier(),
                );
        },
      ),
    );
  }

  Widget background() {
    if (widget.backgroundBuilder != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              ValueListenableBuilder(
                valueListenable: ZegoUIKitUserPropertiesNotifier(
                  widget.user ?? ZegoUIKitUser.empty(),
                ),
                builder: (context, _, __) {
                  return widget.backgroundBuilder?.call(
                        context,
                        Size(constraints.maxWidth, constraints.maxHeight),
                        widget.user,
                        widget.extraInfo ?? {},
                      ) ??
                      Container(color: Colors.transparent);
                },
              ),
            ],
          );
        },
      );
    }

    return Container(color: Colors.transparent);
  }

  Widget foreground() {
    if (widget.foregroundBuilder != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Stack(children: [
            ValueListenableBuilder(
              valueListenable: ZegoUIKitUserPropertiesNotifier(
                widget.user ?? ZegoUIKitUser.empty(),
              ),
              builder: (context, _, __) {
                return widget.foregroundBuilder!.call(
                  context,
                  Size(constraints.maxWidth, constraints.maxHeight),
                  widget.user,
                  widget.extraInfo ?? {},
                );
              },
            ),
          ]);
        },
      );
    }

    return Container(color: Colors.transparent);
  }

  Widget circleBorder({required Widget child}) {
    if (widget.borderRadius == null) {
      return child;
    }

    final decoration = BoxDecoration(
      border: Border.all(
          color: widget.borderColor ?? const Color(0xffA4A4A4), width: 1),
      borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius!)),
    );

    return Container(
      decoration: decoration,
      child: PhysicalModel(
        color: widget.borderColor ?? const Color(0xffA4A4A4),
        borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius!)),
        clipBehavior: Clip.antiAlias,
        elevation: 6.0,
        shadowColor:
            (widget.borderColor ?? const Color(0xffA4A4A4)).withOpacity(0.3),
        child: child,
      ),
    );
  }
}
