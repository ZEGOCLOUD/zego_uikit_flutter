// Flutter imports:
import 'package:flutter/material.dart';

/// Mixin to provide rate limiting functionality for buttons
/// Prevents rapid clicking that could cause UI or state issues
mixin ButtonRateLimitMixin<T extends StatefulWidget> on State<T> {
  /// Rate limiting for button clicks to prevent rapid toggling
  DateTime? _lastClickTime;

  /// Cooldown duration between button clicks
  /// Default is 500ms, can be overridden by subclasses
  Duration get clickCooldown => const Duration(milliseconds: 500);

  /// Check if enough time has passed since last click
  /// Returns true if click should be allowed, false if rate limited
  bool shouldAllowClick() {
    final now = DateTime.now();

    if (_lastClickTime != null &&
        now.difference(_lastClickTime!) < clickCooldown) {
      return false; // Rate limited
    }

    _lastClickTime = now;
    return true; // Click allowed
  }

  /// Execute a function with rate limiting
  /// Returns true if executed, false if rate limited
  bool executeWithRateLimit(VoidCallback action) {
    if (!shouldAllowClick()) {
      return false; // Rate limited, action not executed
    }

    action();
    return true; // Action executed
  }
}
