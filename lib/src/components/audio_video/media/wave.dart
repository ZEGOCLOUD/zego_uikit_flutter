// Dart imports:
import 'dart:async';
import 'dart:core';
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/services/defines/defines.dart';

class ZegoUIKitMediaWaveform extends StatefulWidget {
  final Stream<double> soundLevelStream;
  final ValueNotifier<ZegoUIKitMediaPlayState> playStateNotifier;

  const ZegoUIKitMediaWaveform({
    Key? key,
    required this.soundLevelStream,
    required this.playStateNotifier,
  }) : super(key: key);

  @override
  State<ZegoUIKitMediaWaveform> createState() => _ZegoUIKitMediaWaveformState();
}

class _ZegoUIKitMediaWaveformState extends State<ZegoUIKitMediaWaveform> {
  final List<double> _soundLevels = [];
  final isPlaying = ValueNotifier<bool>(false);
  StreamSubscription<dynamic>? subscription;

  int get soundLevelCount => 100;

  @override
  void initState() {
    super.initState();

    widget.playStateNotifier.addListener(onPlayStateChanged);
    onPlayStateChanged();
  }

  @override
  void dispose() {
    super.dispose();

    widget.playStateNotifier.removeListener(onPlayStateChanged);
    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WaveformPainter(
        soundLevels: _soundLevels,
        isPlaying: isPlaying,
      ),
      size: const Size(double.infinity, 100.0),
    );
  }

  void onSoundLevelUpdated(double soundLevel) {
    setState(() {
      _soundLevels.add(soundLevel);
      if (_soundLevels.length > soundLevelCount) {
        _soundLevels.removeRange(0, _soundLevels.length - soundLevelCount);
      }
    });
  }

  void onPlayStateChanged() {
    final playState = widget.playStateNotifier.value;

    subscription?.cancel();
    if (ZegoUIKitMediaPlayState.playing == playState) {
      subscription = widget.soundLevelStream.listen(onSoundLevelUpdated);
    }
    isPlaying.value = ZegoUIKitMediaPlayState.playing == playState;
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> soundLevels; // 存储声音级别的数组
  final ValueNotifier<bool> isPlaying;
  double timestampSecond = 0.0;

  WaveformPainter({
    required this.soundLevels,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (isPlaying.value) {
      timestampSecond = DateTime.now().millisecondsSinceEpoch / 1000.0;
    }
    final xStep = size.width / soundLevels.length;
    final yMid = size.height / 2.0;
    path.moveTo(0.0, yMid);
    for (var i = 0; i < soundLevels.length; i++) {
      final x = i * xStep;
      var y = yMid + soundLevels[i] * sin(timestampSecond + i * 0.5);
      if (y > size.height - 1) {
        y = size.height - 1;
      }
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
