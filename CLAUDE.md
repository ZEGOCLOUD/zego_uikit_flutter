# CLAUDE.md

This file guides Claude Code / AI agents working in this package. It is part of the `zego_uikits`
Flutter monorepo. For deeper design details see [ARCHITECTURE.md](./ARCHITECTURE.md).

## Project Overview

`zego_uikit` (package: `zego_uikit`, version **2.29.1**) is the **core** low-code library. It wraps
`zego_express_engine` (RTC) and exposes ready-to-use services + UI-ready components (`AudioVideoView`,
camera/mic buttons, dialogs, etc.). Every prebuilt kit in this monorepo (call, live streaming, live
audio room, video conference) is built on top of it.

- SDK: Dart `>=3.0.0 <4.0.0`, Flutter `>=3.0.0`
- Key deps: `zego_express_engine: ^3.23.0` (RTC engine), `zego_plugin_adapter: ^2.14.2` (plugin
  contracts), plus `permission_handler`, `connectivity_plus`, `device_info_plus`, `cached_network_image`,
  `file_picker`, `wakelock_plus`, etc.
- Native plugin class: `ZegoUikitPlugin` (Android pkg `com.zegocloud.uikit.zego_uikit_plugin`, iOS).

## Position in the monorepo

`zego_uikit` depends on `zego_plugin_adapter` and discovers optional plugins (signaling / beauty /
callkit) through it at runtime — it never imports those plugin packages directly. The prebuilt kits
depend on `zego_uikit` (constraint `^2.28.x`). Local development uses path overrides in
`pubspec_overrides.yaml`.

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

> For comprehensive architecture details, see [ARCHITECTURE.md](./ARCHITECTURE.md).

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