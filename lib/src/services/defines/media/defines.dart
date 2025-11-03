// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

typedef ZegoUIKitPlatformFile = PlatformFile;

List<String> zegoMediaVideoExtensions = const [
  "avi",
  "flv",
  "mkv",
  "mov",
  "mp4",
  "mpeg",
  "webm",
  "wmv",
];

List<String> zegoMediaAudioExtensions = const [
  "aac",
  "midi",
  "mp3",
  "ogg",
  "wav",
];

/// media type
enum ZegoUIKitMediaType {
  pureAudio,
  video,
  unknown,
}
