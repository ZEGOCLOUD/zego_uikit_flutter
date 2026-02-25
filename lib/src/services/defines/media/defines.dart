// Package imports:
import 'package:file_picker/file_picker.dart';

/// Alias for PlatformFile from file_picker package.
typedef ZegoUIKitPlatformFile = PlatformFile;

/// Supported video file extensions for media playback.
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

/// Supported audio file extensions for media playback.
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
