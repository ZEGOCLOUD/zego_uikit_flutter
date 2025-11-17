// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

class ZegoScreenSharingCountdownTimer extends StatefulWidget {
  const ZegoScreenSharingCountdownTimer({
    Key? key,
    required this.seconds,
    this.textColor,
    this.progressColor,
    this.secondFontSize,
    this.tipsFontSize,
    this.tips,
    this.onCountDownFinished,
  }) : super(key: key);

  final int seconds;
  final Color? textColor;
  final Color? progressColor;
  final double? secondFontSize;
  final double? tipsFontSize;
  final String? tips;

  final VoidCallback? onCountDownFinished;

  @override
  State<ZegoScreenSharingCountdownTimer> createState() =>
      _CountdownTimerState();
}

class _CountdownTimerState extends State<ZegoScreenSharingCountdownTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int currentCount = 10; // Starting value for countdown
  Timer? _timer;

  double get secondFontSize => widget.secondFontSize ?? 30;
  double get tipsFontSize => widget.tipsFontSize ?? 15;

  @override
  void initState() {
    super.initState();

    currentCount = widget.seconds;

    _controller = AnimationController(
      duration: Duration(seconds: widget.seconds),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    _controller.reverse(from: widget.seconds.toDouble());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentCount > 0) {
        setState(() {
          currentCount--;
        });
      } else {
        widget.onCountDownFinished?.call();
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: secondFontSize * 1.5,
                height: secondFontSize * 1.5,
                child: CircularProgressIndicator(
                  value: _controller.value,
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.progressColor ?? Colors.yellow,
                  ),
                ),
              ),
              SizedBox(
                width: secondFontSize * 1.5,
                height: secondFontSize * 1.5,
                child: Center(
                  child: Text(
                    '${currentCount > 0 ? currentCount : 0}',
                    style: TextStyle(
                      fontSize: secondFontSize,
                      color: widget.textColor ?? Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          (widget.tips?.isEmpty ?? true)
              ? const SizedBox()
              : SizedBox(
                  height: tipsFontSize * 1.2,
                  child: Text(
                    widget.tips!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: tipsFontSize,
                      color: widget.textColor ?? Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
