// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import 'package:zego_uikit/src/components/audio_video/avatar/ripple_avatar.dart';
import 'package:zego_uikit/src/services/core/defines/defines.dart';
import 'package:zego_uikit/zego_uikit.dart';

class ZegoAvatar extends StatelessWidget {
  final String roomID;
  final Size avatarSize;
  final ZegoUIKitUser? user;
  final bool showAvatar;
  final bool showSoundLevel;
  final Size? soundLevelSize;
  final Color? soundLevelColor;
  final ZegoAvatarBuilder? avatarBuilder;

  final String? mixerStreamID;

  const ZegoAvatar({
    super.key,
    required this.roomID,
    required this.avatarSize,
    this.user,
    this.showAvatar = true,
    this.showSoundLevel = false,
    this.soundLevelSize,
    this.soundLevelColor,
    this.avatarBuilder,
    this.mixerStreamID,
  });

  @override
  Widget build(BuildContext context) {
    if (!showAvatar || user == null) {
      return Container(color: Colors.transparent);
    }

    final centralAvatar = SizedBox(
      width: avatarSize.width,
      height: avatarSize.width,
      child: avatarBuilderWithURL(context, avatarSize, user, {}),
    );
    return Center(
      child: SizedBox.fromSize(
        size: showSoundLevel ? soundLevelSize : avatarSize,
        child: showSoundLevel
            ? ZegoRippleAvatar(
                roomID: roomID,
                user: user,
                color: soundLevelColor ?? const Color(0xff6a6b6f),
                minRadius: min(avatarSize.width, avatarSize.height) / 2,
                radiusIncrement: 0.06,
                mixerStreamID: mixerStreamID,
                child: centralAvatar,
              )
            : centralAvatar,
      ),
    );
  }

  Widget avatarBuilderWithURL(
    BuildContext context,
    Size size,
    ZegoUIKitUser? user,
    Map<String, dynamic> extraInfo,
  ) {
    return ValueListenableBuilder(
      valueListenable: ZegoUIKitUserPropertiesNotifier(
        roomID: roomID,
        user ?? ZegoUIKitUser.empty(),
      ),
      builder: (context, _, __) {
        final avatarURL = user?.inRoomAttributes.value.avatarURL ?? '';
        return avatarBuilder?.call(
              context,
              size,
              user,
              extraInfo,
            ) ??
            (avatarURL.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: avatarURL,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                    errorWidget: (context, url, error) {
                      ZegoLoggerService.logError(
                        '$user avatar url($url) error:$error',
                        tag: 'uikit.component',
                        subTag: 'avatar',
                      );
                      return circleName(context, avatarSize, user);
                    },
                  )
                : circleName(context, avatarSize, user));
      },
    );
  }

  Widget circleName(BuildContext context, Size size, ZegoUIKitUser? user) {
    final userName = user?.name ?? '';
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xffDBDDE3),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName.characters.first : '',
          style: TextStyle(
            fontSize: showSoundLevel ? size.width / 4 : size.width / 5 * 4,
            color: const Color(0xff222222),
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
