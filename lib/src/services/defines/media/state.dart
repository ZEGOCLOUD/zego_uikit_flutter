// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

/// media play state
/// normal process: noPlay->loadReady->playing->playEnded
enum ZegoUIKitMediaPlayState {
  /// Not playing
  noPlay,

  /// not start yet
  loadReady,

  /// Playing
  playing,

  /// Pausing
  pausing,

  /// End of play
  playEnded
}

extension ZegoUIKitMediaPlayStateExtension on ZegoUIKitMediaPlayState {
  static ZegoUIKitMediaPlayState fromZego(
      ZegoMediaPlayerState zegoMediaPlayerState) {
    switch (zegoMediaPlayerState) {
      case ZegoMediaPlayerState.NoPlay:
        return ZegoUIKitMediaPlayState.noPlay;
      case ZegoMediaPlayerState.Playing:
        return ZegoUIKitMediaPlayState.playing;
      case ZegoMediaPlayerState.Pausing:
        return ZegoUIKitMediaPlayState.pausing;
      case ZegoMediaPlayerState.PlayEnded:
        return ZegoUIKitMediaPlayState.playEnded;
    }
  }
}
