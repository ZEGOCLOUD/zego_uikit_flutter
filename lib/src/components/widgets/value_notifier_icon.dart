// Flutter imports:
import 'package:flutter/material.dart';

class ZegoServiceValueIcon extends StatefulWidget {
  const ZegoServiceValueIcon({
    super.key,
    required this.notifier,
    required this.normalIcon,
    required this.checkedIcon,
  });

  final Image normalIcon;
  final Image checkedIcon;
  final ValueNotifier<bool> notifier;

  @override
  State<ZegoServiceValueIcon> createState() => _ZegoServiceValueIconState();
}

class _ZegoServiceValueIconState extends State<ZegoServiceValueIcon> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.notifier,
      builder: (context, icChecked, _) {
        return icChecked ? widget.checkedIcon : widget.normalIcon;
      },
    );
  }
}
