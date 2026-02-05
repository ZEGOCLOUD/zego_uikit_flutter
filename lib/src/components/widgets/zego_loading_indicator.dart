// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:loading_indicator/loading_indicator.dart';

// Project imports:
import 'package:zego_uikit/src/components/screen_util/screen_util.dart';

/// A custom loading indicator widget that wraps the loading_indicator package.
///
/// This widget displays a loading animation with an optional text label below it.
class ZegoLoadingIndicator extends StatelessWidget {
  /// The text to display below the loading indicator.
  ///
  /// Defaults to an empty string.
  final String text;

  const ZegoLoadingIndicator({
    super.key,
    this.text = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80.zR,
          height: 80.zR,
          child: LoadingIndicator(
            indicatorType: Indicator.ballSpinFadeLoader,
            colors: [
              Colors.red,
              Colors.orange,
              Colors.yellow,
              Colors.green,
              Colors.blue,
              Colors.indigo,
              Colors.purple,
            ],
            strokeWidth: 2.zR,
            backgroundColor: Colors.transparent,
            pathBackgroundColor: Colors.transparent,
          ),
        ),
        if (text.isNotEmpty) ...[
          SizedBox(height: 8.zH),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.zR,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ],
    );
  }
}
