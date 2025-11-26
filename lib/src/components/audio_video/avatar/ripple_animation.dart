// Flutter imports:
import 'package:flutter/material.dart';

class RippleAnimation extends StatefulWidget {
  final Widget child;
  final double minRadius;
  final double radiusIncrement;
  final Color color;
  final ValueNotifier<int> countReceiver;

  const RippleAnimation(
      {super.key,
      required this.child,
      required this.countReceiver,
      this.color = Colors.black,
      this.minRadius = 60,
      this.radiusIncrement = 0.15});

  @override
  State<RippleAnimation> createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<RippleAnimation>
    with TickerProviderStateMixin {
  int ripplesCount = 0;

  @override
  void initState() {
    super.initState();

    widget.countReceiver.addListener(onCountUpdated);
  }

  @override
  void dispose() {
    widget.countReceiver.removeListener(onCountUpdated);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RipplePainter(
        color: widget.color,
        minRadius: widget.minRadius,
        radiusIncrement: widget.radiusIncrement,
        wavesCount: ripplesCount,
      ),
      child: widget.child,
    );
  }

  void onCountUpdated() {
    setState(() {
      ripplesCount = widget.countReceiver.value;
    });
  }
}

// Creating a Circular painter for clipping the rects and creating circle shapes
class RipplePainter extends CustomPainter {
  RipplePainter({
    required this.minRadius,
    required this.radiusIncrement,
    required this.wavesCount,
    required this.color,
  }) : super();
  final Color color;
  final double minRadius;
  final double radiusIncrement;
  final int wavesCount;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
    for (var wave = 0; wave <= wavesCount; wave++) {
      circle(canvas, rect, minRadius, wave, wavesCount);
    }
  }

  // animating the opacity according to min radius and waves count.
  void circle(
      Canvas canvas, Rect rect, double minRadius, int wave, int length) {
    Color paintColor;
    double radius;
    if (wave != 0) {
      final opacity = (1 - ((wave - 1) / length)).clamp(0.0, 1.0);
      paintColor = color.withValues(alpha: opacity);

      radius = minRadius * (1 + radiusIncrement * wave);
      final paint = Paint()
        ..color = paintColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(rect.center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) => true;
}
