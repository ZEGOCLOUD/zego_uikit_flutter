// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/components/audio_video/audio_video_view.dart';
import 'package:zego_uikit/src/components/audio_video/defines.dart';
import 'package:zego_uikit/src/components/audio_video_container/picture_in_picture/defines.dart';
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/components/screen_util/screen_util.dart';
import 'package:zego_uikit/src/services/services.dart';

class ZegoLayoutPIPSmallItem extends StatefulWidget {
  const ZegoLayoutPIPSmallItem({
    Key? key,
    required this.targetUser,
    required this.localUser,
    required this.defaultPosition,
    required this.draggable,
    required this.showOnlyVideo,
    required this.onTap,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.borderRadius,
    this.size,
    this.margin,
    this.avatarConfig,
  }) : super(key: key);

  final bool draggable;
  final bool showOnlyVideo;
  final ZegoUIKitUser? targetUser;
  final ZegoUIKitUser localUser;
  final ZegoViewPosition defaultPosition;
  final void Function(ZegoUIKitUser? user) onTap;
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  final double? borderRadius;
  final EdgeInsets? margin;
  final Size? size;

  /// avatar etc.
  final ZegoAvatarConfig? avatarConfig;

  @override
  State<ZegoLayoutPIPSmallItem> createState() => _ZegoLayoutPIPSmallItemState();
}

class _ZegoLayoutPIPSmallItemState extends State<ZegoLayoutPIPSmallItem> {
  late ZegoViewPosition currentPosition;

  Size get designedSize => widget.size ?? Size(190.0.zW, 338.0.zH);

  double get designedRatio => 9.0 / 16.0;

  @override
  void initState() {
    super.initState();
    currentPosition = widget.defaultPosition;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showOnlyVideo) {
      return ValueListenableBuilder<bool>(
        valueListenable:
            ZegoUIKit().getCameraStateNotifier(widget.targetUser?.id ?? ''),
        builder: (context, cameraEnabled, _) {
          if (cameraEnabled) {
            return view();
          } else {
            return const SizedBox();
          }
        },
      );
    } else {
      return view();
    }
  }

  Widget view() {
    return calculatePosition(
      child: makeDraggable(
        child: GestureDetector(
          onTap: () {
            widget.onTap(widget.targetUser);
          },
          child: AbsorbPointer(
            absorbing: false,
            child: calculateSize(
              user: widget.targetUser,
              child: ZegoAudioVideoView(
                user: widget.targetUser,
                borderRadius: widget.borderRadius ?? 18.0.zR,
                backgroundBuilder: widget.backgroundBuilder,
                foregroundBuilder: widget.foregroundBuilder,
                avatarConfig: widget.avatarConfig,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// calculates smallView's size based on current screen
  Widget calculateSize({required ZegoUIKitUser? user, required Widget child}) {
    final portraitBaseSize =
        Size(designedSize.height, designedSize.width); // vertical
    final landscapeBaseSize = designedSize; //  horizontal

    if (user == null) {
      final defaultSize = Size(
          landscapeBaseSize.height * designedRatio, landscapeBaseSize.height);

      return SizedBox.fromSize(size: defaultSize, child: child);
    } else {
      return ValueListenableBuilder<Size>(
        valueListenable: ZegoUIKit().getVideoSizeNotifier(user.id),
        builder: (context, Size size, _) {
          late double width, height;
          if (size.width > size.height) {
            width = portraitBaseSize.width;
            height = portraitBaseSize.width * designedRatio;
          } else {
            width = landscapeBaseSize.height * designedRatio;
            height = landscapeBaseSize.height;
          }

          return SizedBox(width: width, height: height, child: child);
        },
      );
    }
  }

  /// position container, calculates the coordinates based on current position
  Widget calculatePosition({required Widget child}) {
    final paddingSpace = widget.margin ??
        EdgeInsets.only(left: 20.zR, top: 50.zR, right: 20.zR, bottom: 30.zR);

    double? left, top, right, bottom;
    switch (currentPosition) {
      case ZegoViewPosition.topLeft:
        left = paddingSpace.left;
        top = paddingSpace.top;
        break;
      case ZegoViewPosition.topRight:
        right = paddingSpace.right;
        top = paddingSpace.top;
        break;
      case ZegoViewPosition.bottomLeft:
        left = paddingSpace.left;
        bottom = paddingSpace.bottom;
        break;
      case ZegoViewPosition.bottomRight:
        right = paddingSpace.right;
        bottom = paddingSpace.bottom;
        break;
    }

    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: child,
    );
  }

  Widget makeDraggable({required Widget child}) {
    if (!widget.draggable) {
      /// not support
      return child;
    }

    return _ZegoSinglePointerDraggable(
      feedback: child,
      childWhenDragging: const SizedBox.shrink(),
      onDragEnd: (Offset globalPosition) {
        /// drag finished, update current position based on final pointer pos
        final size = MediaQuery.of(context).size;
        late ZegoViewPosition targetPosition;
        final centerPos = Offset(size.width / 2, size.height / 2);
        if (globalPosition.dx < centerPos.dx &&
            globalPosition.dy < centerPos.dy) {
          targetPosition = ZegoViewPosition.topLeft;
        } else if (globalPosition.dx >= centerPos.dx &&
            globalPosition.dy < centerPos.dy) {
          targetPosition = ZegoViewPosition.topRight;
        } else if (globalPosition.dx < centerPos.dx &&
            globalPosition.dy >= centerPos.dy) {
          targetPosition = ZegoViewPosition.bottomLeft;
        } else {
          targetPosition = ZegoViewPosition.bottomRight;
        }

        if (targetPosition != currentPosition) {
          setState(() {
            currentPosition = targetPosition;
          });
        }
      },
      child: child,
    );
  }
}

/// A `Draggable`-like widget that only tracks the FIRST pointer down and
/// ignores any additional pointers. This avoids the multi-touch bug where
/// dragging with two fingers on a small view produces two feedback widgets
/// (one per pointer).
///
/// `feedback` is rendered in an [Overlay] anchored so the originally-grabbed
/// point stays under the pointer as the user drags, matching the standard
/// `Draggable` UX.
class _ZegoSinglePointerDraggable extends StatefulWidget {
  const _ZegoSinglePointerDraggable({
    required this.child,
    required this.feedback,
    required this.childWhenDragging,
    required this.onDragEnd,
  });

  final Widget child;
  final Widget feedback;
  final Widget childWhenDragging;

  /// Called when the active pointer is released. `globalPosition` is the
  /// final position of the pointer in screen coordinates.
  final void Function(Offset globalPosition) onDragEnd;

  @override
  State<_ZegoSinglePointerDraggable> createState() =>
      _ZegoSinglePointerDraggableState();
}

class _ZegoSinglePointerDraggableState
    extends State<_ZegoSinglePointerDraggable> {
  int? _activePointer;

  /// Offset of the grab point within [widget.feedback], in local coordinates.
  Offset _grabLocalOffset = Offset.zero;

  /// Latest global pointer position while dragging.
  Offset _currentGlobalPos = Offset.zero;

  OverlayEntry? _overlayEntry;

  void _handlePointerDown(PointerDownEvent event) {
    // Ignore additional pointers: only the first pointer starts a drag.
    if (_activePointer != null) {
      return;
    }

    _activePointer = event.pointer;
    _grabLocalOffset = event.localPosition;
    _currentGlobalPos = event.position;

    _overlayEntry = OverlayEntry(builder: (_) {
      return Positioned(
        left: _currentGlobalPos.dx - _grabLocalOffset.dx,
        top: _currentGlobalPos.dy - _grabLocalOffset.dy,
        child: IgnorePointer(
          ignoring: true,
          child: widget.feedback,
        ),
      );
    });
    Overlay.of(context).insert(_overlayEntry!);
    if (mounted) {
      setState(() {});
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer != _activePointer) {
      return;
    }
    _currentGlobalPos = event.position;
    _overlayEntry?.markNeedsBuild();
  }

  void _handlePointerEnd(PointerEvent event) {
    if (event.pointer != _activePointer) {
      return;
    }
    final endPosition = event.position;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _activePointer = null;
    if (mounted) {
      setState(() {});
      widget.onDragEnd(endPosition);
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerEnd,
      onPointerCancel: _handlePointerEnd,
      child: _activePointer == null ? widget.child : widget.childWhenDragging,
    );
  }
}
