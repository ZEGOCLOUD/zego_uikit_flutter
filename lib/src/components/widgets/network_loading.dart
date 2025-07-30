// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/services/defines/network.dart';
import 'package:zego_uikit/src/services/uikit_service.dart';

class ZegoNetworkLoadingConfig {
  bool enabled;
  Widget? icon;
  Color? iconColor;
  Color? progressColor;

  ZegoNetworkLoadingConfig({
    this.enabled = true,
    this.icon,
    this.iconColor,
    this.progressColor,
  });
}

class ZegoNetworkLoading extends StatefulWidget {
  const ZegoNetworkLoading({
    Key? key,
    required this.child,
    this.config,
  }) : super(key: key);

  final Widget child;
  final ZegoNetworkLoadingConfig? config;

  /// icon when network had error

  @override
  State<ZegoNetworkLoading> createState() => _ZegoNetworkLoadingState();
}

class _ZegoNetworkLoadingState extends State<ZegoNetworkLoading> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ZegoUIKitNetworkState>(
      valueListenable: ZegoUIKit().getNetworkStateNotifier(),
      builder: (context, networkState, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            widget.child,
            if (widget.config?.enabled ?? true)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: loading(networkState),
              ),
          ],
        );
      },
    );
  }

  Widget loading(ZegoUIKitNetworkState networkState) {
    return ZegoUIKitNetworkState.online == networkState
        ? const SizedBox()
        : GestureDetector(
            onTap: () {},
            child: Container(
              color: Colors.transparent,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      (widget.config?.progressColor ?? Colors.black)
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  widget.config?.icon ??
                      Icon(
                        Icons.wifi_off,
                        color: (widget.config?.iconColor ?? Colors.black)
                            .withValues(alpha: 0.5),
                      ),
                ],
              ),
            ),
          );
  }
}
