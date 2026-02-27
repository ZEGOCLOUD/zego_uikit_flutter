# CLAUDE.md

> **Note**: This library is part of the `zego_uikits` monorepo. See the root [CLAUDE.md](https://github.com/your-org/zego_uikits/blob/main/CLAUDE.md) for cross-library dependencies and architecture overview.

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Workflow Orchestration

### 1. Plan Node Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately - don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

### 2. Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One tack per subagent for focused execution

### 3. Self-Improvement Loop
- After ANY correction from the user: update `tasks/lessons.md` with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project

### 4. Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

### 5. Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes - don't over-engineer
- Challenge your own work before presenting it

### 6. Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests - then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

## Task Management

1. **Plan First**: Write plan to `tasks/todo.md` with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review section to `tasks/todo.md`
6. **Capture Lessons**: Update `tasks/lessons.md` after corrections

## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimat Impact**: Changes should only touch what's necessary. Avoid introducing bugs.

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