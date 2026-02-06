# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ZegoUIKit is a Flutter plugin for building audio/video communication apps. Version 3.0+ supports multi-room scenarios. The package provides pre-built UI components and services for video calls.

**SDK Requirements**: Dart >=3.0.0, Flutter >=3.0.0

## Common Commands

```bash
# Analyze and lint
flutter analyze

# Run tests
flutter test

# Build for release
flutter build apk --release  # Android
flutter build ios --release  # iOS

# Sort imports (project convention)
flutter pub run import_sorter:main

# Generate documentation
dart doc
```

## Architecture

### Core Pattern: Singleton with Mixins

`ZegoUIKit()` is a factory singleton that combines multiple service mixins:

```dart
class ZegoUIKit with ZegoAudioVideoService, ZegoRoomService, ZegoUserService, ...
```

Each service is defined as a `part` file (see `lib/src/services/`):
- `audio_video_service.dart` - Audio/video stream management
- `room_service.dart` - Room login/logout, multi-room support
- `user_service.dart` - User management
- `device_service.dart` - Camera, mic, speaker control
- `media_service.dart` - Media player/recorder
- `message_service.dart` - In-room messaging
- `logger_service.dart` - Logging with tag/subTag pattern

### Package Structure

```
lib/src/
├── components/     # UI widgets (AudioVideoView, buttons, dialogs)
├── plugins/        # Optional plugins (beauty, signaling)
├── services/       # Core services via mixins
├── modules/        # Feature modules (hall_room for multi-room)
├── channel/        # Platform channel (method_channel.dart)
└── deprecated/     # Deprecated APIs
```

## Code Conventions

- **Documentation required**: `public_member_api_docs: true` lint rule enforces documentation on all public APIs
- **Import sorting**: Use `import_sorter` for consistent import ordering
- **Categories**: APIs are grouped using `@category` annotations (see `dartdoc_options.yaml`)
- **Logging**: Use `ZegoLoggerService.logInfo/Warn/Error` with tag/subTag pattern