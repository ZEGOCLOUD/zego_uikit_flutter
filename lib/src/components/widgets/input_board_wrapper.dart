// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ZegoInputBoardWrapper extends StatefulWidget {
  const ZegoInputBoardWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  State<ZegoInputBoardWrapper> createState() => _ZegoInputBoardWrapperState();
}

class _ZegoInputBoardWrapperState extends State<ZegoInputBoardWrapper> {
  EdgeInsets padding = EdgeInsets.zero;

  @override
  void initState() {
    super.initState();

    // Use View.of(context) instead of deprecated window
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          final view = View.of(context);
          padding = MediaQueryData.fromView(view).padding;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSafeArea = EdgeInsets.zero == MediaQuery.of(context).padding;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: hasSafeArea
                ? (MediaQuery.of(context).size.height -
                    padding.top -
                    padding.bottom)
                : MediaQuery.of(context).size.height,
            child: widget.child,
          )
        ],
      ),
    );
  }
}
