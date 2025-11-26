// Flutter imports:
import 'package:flutter/material.dart';

class ZegoUIKitFlipTransition extends StatefulWidget {
  final Widget child;
  final ValueNotifier<bool> isFlippedNotifier;
  final ValueNotifier<bool> isFrontTriggerByTurnOnCamera;
  final Duration duration;

  const ZegoUIKitFlipTransition({
    super.key,
    required this.child,
    required this.isFlippedNotifier,
    required this.isFrontTriggerByTurnOnCamera,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<ZegoUIKitFlipTransition> createState() =>
      _ZegoUIKitFlipTransitionState();
}

class _ZegoUIKitFlipTransitionState extends State<ZegoUIKitFlipTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reset();
        }
      });

    _animation = Tween<double>(begin: 0.0, end: 3.14159).animate(_controller);

    widget.isFlippedNotifier.addListener(_onFlipChanged);
  }

  void _onFlipChanged() {
    if (widget.isFrontTriggerByTurnOnCamera.value) {
      widget.isFrontTriggerByTurnOnCamera.value = false;
      return;
    }

    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    widget.isFlippedNotifier.removeListener(_onFlipChanged);
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(_animation.value),
          child: widget.child,
        );
      },
    );
  }
}
