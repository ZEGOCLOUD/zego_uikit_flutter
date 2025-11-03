// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_uikit/src/services/defines/user/user.dart';

/// in-room message send state
enum ZegoInRoomMessageState {
  idle,
  sending,
  success,
  failed,
}
