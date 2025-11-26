// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/components/screen_util/screen_util.dart';
import 'package:zego_uikit/src/services/services.dart';

class ZegoLayoutGalleryLastItem extends StatefulWidget {
  const ZegoLayoutGalleryLastItem({
    super.key,
    required this.users,
    this.borderColor,
    this.borderRadius,
    this.backgroundColor,
  });

  final List<ZegoUIKitUser> users;
  final Color? borderColor;
  final double? borderRadius;
  final Color? backgroundColor;

  @override
  State<ZegoLayoutGalleryLastItem> createState() =>
      _ZegoLayoutGalleryLastItemState();
}

class _ZegoLayoutGalleryLastItemState extends State<ZegoLayoutGalleryLastItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        border: widget.borderColor != null
            ? Border.all(color: widget.borderColor!)
            : null,
        borderRadius: widget.borderRadius != null
            ? BorderRadius.all(Radius.circular(widget.borderRadius!))
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          avatarUsers(),
          SizedBox(height: 16.zR),
          hints(),
        ],
      ),
    );
  }

  Widget hints() {
    return Text(
      '${widget.users.length} others',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 24.zR,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget avatarUsers() {
    final firstUser = widget.users.first;
    final lastUser = widget.users.last;

    return SizedBox.fromSize(
      size: Size(212.zR, 120.zR),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: avatarUser(context, firstUser, false),
          ),
          Positioned(
            top: 0,
            left: 92.zR,
            child: avatarUser(context, lastUser, true),
          ),
        ],
      ),
    );
  }

  Widget avatarUser(
    BuildContext context,
    ZegoUIKitUser user,
    bool withBorderColor,
  ) {
    return SizedBox.fromSize(
      size: Size(120.zR, 120.zR),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffDBDDE3),
          shape: BoxShape.circle,
          border: Border.all(
              color: withBorderColor
                  ? const Color(0xff4A4B4D)
                  : Colors.transparent,
              width: 0.89.zR),
        ),
        child: Center(
          child: Text(
            user.name.isNotEmpty ? user.name.characters.first : '',
            style: TextStyle(
              fontSize: 46.zR,
              fontWeight: FontWeight.w600,
              color: const Color(0xff222222),
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
