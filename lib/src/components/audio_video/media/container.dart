// Dart imports:

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/components/audio_video/audio_video.dart';
import 'package:zego_uikit/src/components/audio_video/defines.dart';
import 'package:zego_uikit/src/services/services.dart';

/// container of media,
class ZegoUIKitMediaContainer extends StatefulWidget {
  const ZegoUIKitMediaContainer({
    super.key,
    this.foregroundBuilder,
    this.backgroundBuilder,
  });

  /// foreground builder of audio video view
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;

  /// background builder of audio video view
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  @override
  State<ZegoUIKitMediaContainer> createState() =>
      _ZegoUIKitMediaContainerState();
}

class _ZegoUIKitMediaContainerState extends State<ZegoUIKitMediaContainer> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ZegoUIKitUser>>(
      stream: ZegoUIKit().getMediaListStream(),
      builder: (context, snapshot) {
        final mediaUsers = ZegoUIKit().getMediaList();
        if (mediaUsers.isEmpty) {
          return Container();
        }

        return ZegoUIKitMediaView(
          user: mediaUsers.first,
          backgroundBuilder: widget.backgroundBuilder,
          foregroundBuilder: widget.foregroundBuilder,
        );
      },
    );
  }
}
