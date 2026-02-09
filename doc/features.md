# Features

Zego UIKit is a comprehensive low-code solution that provides a wide range of features through its modular architecture and plugins, allowing developers to build audio and video applications quickly.

## Core Services

### Audio & Video
- **Real-time Communication**: High-quality, low-latency audio and video streaming.
- **Device Management**:
  - Switch between front and rear cameras.
  - Toggle microphone and camera on/off.
  - Switch audio output (Speaker/Earpiece/Bluetooth).
  - Mirroring support for local video.
- **Video Configuration**:
  - Support for various video resolution presets (180p, 360p, 720p, 1080p, etc.).
  - Custom bitrate and frame rate configuration.
- **Advanced Stream Features**:
  - **SEI (Supplemental Enhancement Information)**: Send custom data synchronized with the video stream.
  - **Traffic Control**: Automatically adjust video quality based on network conditions to ensure smoothness.

### Room Management
- **Room Lifecycle**: Create, join, and leave rooms.
- **Room Attributes**: Set and update global room properties shared among all participants (e.g., room title, status).
- **Room State Monitoring**: Real-time callbacks for connection state changes (connecting, connected, disconnected).

### User Management
- **User Presence**: Real-time tracking of user join/leave events.
- **User Attributes**: Custom user properties (e.g., role, level, avatar URL) that sync across the room.
- **In-Room Member List**: Automatically managed list of current participants.

### Messaging
- **Broadcast Messages**: Reliable low-frequency messages, suitable for IM chat.
- **Barrage Messages**: Unreliable high-frequency messages, suitable for Danmaku (bullet screen comments).
- **Custom Signaling**: Send custom command signaling for control logic.

## UI Components & Layouts

Zego UIKit provides a rich set of pre-built UI components:

### Audio/Video Views
- **ZegoAudioVideoView**: The fundamental component for rendering video streams.
- **ZegoAudioVideoContainer**: A container that automatically manages the layout of multiple audio/video views.
- **ZegoScreenSharingView**: Dedicated view for rendering screen sharing streams.

### Layout Management
- **Gallery Layout**: Standard grid layout for video calls.
- **Picture-in-Picture (PiP)**: Support for minimizing the video view to a floating window (Android/iOS).
- **Layout Configuration**: Customizable rows, columns, and spacing.

### Common Widgets
- **ZegoAvatar**: User avatar component with support for sound wave ripples.
- **ZegoMemberList**: Ready-to-use member list page.
- **ZegoInRoomChatView**: Ready-to-use chat component with message history.
- **ZegoUIKitHallRoomList**: A vertical scrolling list component for browsing live rooms (like TikTok), supporting video preview without fully joining the room.
- **Controls**: Pre-built buttons for camera, microphone, switch camera, end call, etc.

## Advanced Features & Plugins

### Beauty & Effects (Zego Effects Plugin)
- **Beauty Effects**: Skin tone (whitening), smoothing, rosy, and sharpening.
- **Voice Changer**: Real-time voice transformation (e.g., Robot, Child, Deep, Optimus Prime).
- **Reverb**: Audio environment simulation (e.g., KTV, Hall, Concert, Recording Studio).

### Signaling & Invitations (Zego Signaling Plugin)
- **Call Invitations**: Send, accept, refuse, and cancel call invitations.
- **Advanced Invitations**: Support for group invitations and invitation state management.
- **CallKit Support**: Integration with system calling UI (CallKit on iOS, ConnectionService on Android) for native calling experience.
- **Offline Push**: Support for background notifications when the app is killed.

### Media Player
- **Media Playback**: Play audio and video files during calls.
- **Stream Mixing**: Mix media audio into the microphone stream (BGM).

### Mixer
- **Stream Mixing**: Server-side or client-side stream mixing for complex use cases (e.g., live streaming with multiple hosts).

### Utilities
- **Network Monitoring**: Monitor network speed and quality.
- **Log Export**: Built-in mechanism to export SDK logs for issue troubleshooting.
- **Permission Handling**: Helper classes for managing camera and microphone permissions.
