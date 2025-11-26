// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/components/audio_video/avatar/ripple_animation.dart';
import 'package:zego_uikit/src/services/services.dart';

/// display sound level value through circular ripples
class ZegoRippleAvatar extends StatefulWidget {
  const ZegoRippleAvatar({
    super.key,
    required this.roomID,
    required this.user,
    required this.child,
    this.color,
    this.minRadius = 60,
    this.radiusIncrement = 0.2,
    this.mixerStreamID,
  });
  final String roomID;
  final Widget child;

  final ZegoUIKitUser? user;

  /// min radius of ripple
  final double minRadius;

  final Color? color;

  final double radiusIncrement;

  final String? mixerStreamID;

  @override
  State<ZegoRippleAvatar> createState() => _ZegoRippleAvatarState();
}

class _ZegoRippleAvatarState extends State<ZegoRippleAvatar> {
  /// subscription of sound level value's stream
  StreamSubscription<double>? soundLevelStreamSubscription;
  StreamSubscription<dynamic>? userListUpdateSubscription;

  /// ripple count notifier
  final ValueNotifier<int> countNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();

    listenSoundLevel();
  }

  @override
  void dispose() {
    /// cancel subscription
    soundLevelStreamSubscription?.cancel();
    userListUpdateSubscription?.cancel();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ZegoRippleAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    listenSoundLevel();
  }

  @override
  Widget build(BuildContext context) {
    return widget.user == null
        ? animation()
        : ValueListenableBuilder<bool>(
            valueListenable: widget.user!.microphone,
            builder: (context, isOpen, _) {
              if (!isOpen) {
                countNotifier.value = 0;
              }

              return animation();
            },
          );
  }

  Widget animation() {
    return RippleAnimation(
      color: widget.color ?? const Color(0xffDBDDE3).withValues(alpha: 0.1),
      minRadius: widget.minRadius,
      radiusIncrement: widget.radiusIncrement,
      countReceiver: countNotifier,
      child: Center(child: widget.child),
    );
  }

  /// update ripple count when the sound level value is updated.
  void onSoundLevelChanged(double value) {
    final newCount = soundLevelConvertToRippleCount(value);
    if (newCount != countNotifier.value) {
      countNotifier.value = newCount;
    }
  }

  /// convert sound level value to ripple count,
  /// the larger sound level, the more ripples.
  int soundLevelConvertToRippleCount(double soundLevel) {
    /// in order to show the wave effect even if the sound wave is small

    /** make (0~100) sound level value to (0,10) ripple count
     * 1~3 => 1
     * 4~6 => 2
     * 7~9 => 3
     * 10~20 => 4
     * 21~30 => 5
     * 31~40 => 6
     * 41~50 => 7
     * 51~65 => 8
     * 66~80 => 9
     * 81~100 => 10
     */
    var currentValue = 0;
    if (soundLevel < 1) {
      currentValue = 0;
    } else if (soundLevel < 3) {
      currentValue = 1;
    } else if (soundLevel < 6) {
      currentValue = 2;
    } else if (soundLevel < 9) {
      currentValue = 3;
    } else if (soundLevel < 20) {
      currentValue = 4;
    } else if (soundLevel < 30) {
      currentValue = 5;
    } else if (soundLevel < 40) {
      currentValue = 6;
    } else if (soundLevel < 50) {
      currentValue = 7;
    } else if (soundLevel < 65) {
      currentValue = 8;
    } else if (soundLevel < 80) {
      currentValue = 9;
    } else if (soundLevel < 100) {
      currentValue = 10;
    }

    return currentValue;
  }

  void listenSoundLevel() {
    userListUpdateSubscription?.cancel();
    soundLevelStreamSubscription?.cancel();

    if (widget.mixerStreamID?.isNotEmpty ?? false) {
      if (-1 ==
          ZegoUIKit()
              .getMixerStreamUsers(
                targetRoomID: widget.roomID,
                widget.mixerStreamID ?? '',
              )
              .indexWhere((e) => e.id == widget.user?.id)) {
        userListUpdateSubscription = ZegoUIKit()
            .getMixerUserListStream(
              targetRoomID: widget.roomID,
              widget.mixerStreamID ?? '',
            )
            .listen(onUserListUpdated);
      } else {
        soundLevelStreamSubscription = ZegoUIKit()
            .getMixedSoundLevelStream(
              targetRoomID: widget.roomID,
              widget.user?.id ?? '',
            )
            .listen(onSoundLevelChanged);
      }
    } else {
      if (ZegoUIKit()
          .getUser(targetRoomID: widget.roomID, widget.user?.id ?? '')
          .isEmpty()) {
        userListUpdateSubscription = ZegoUIKit()
            .getUserListStream(targetRoomID: widget.roomID)
            .listen(onUserListUpdated);
      } else {
        soundLevelStreamSubscription = ZegoUIKit()
            .getSoundLevelStream(
              targetRoomID: widget.roomID,
              widget.user?.id ?? '',
            )
            .listen(onSoundLevelChanged);
      }
    }
  }

  void onUserListUpdated(List<ZegoUIKitUser> users) {
    userListUpdateSubscription?.cancel();

    listenSoundLevel();
  }
}
