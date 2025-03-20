# ZEGO UIKit Flutter Services API

- [ZEGO UIKit Flutter Services API](#zego-uikit-flutter-services-api)
  - [Services Overview](#services-overview)
  - [AudioVideoService](#audiovideoservice)
    - [turnCameraOn](#turncameraon)
    - [turnMicrophoneOn](#turnmicrophoneon)
    - [useFrontFacingCamera](#usefrontfacingcamera)
    - [startPlayingStream](#startplayingstream)
    - [stopPlayingStream](#stopplayingstream)
  - [CustomCommandService](#customcommandservice)
    - [sendCustomCommand](#sendcustomcommand)
  - [DeviceService](#deviceservice)
    - [getDeviceInfo](#getdeviceinfo)
    - [getSystemInfo](#getsysteminfo)
    - [getCameraList](#getcameralist)
    - [getMicrophoneList](#getmicrophonelist)
  - [EffectService](#effectservice)
    - [setBeautyEffect](#setbeautyeffect)
    - [setVirtualBackground](#setvirtualbackground)
  - [EventService](#eventservice)
    - [listen](#listen)
    - [unlisten](#unlisten)
  - [LoggerService](#loggerservice)
    - [logInfo](#loginfo)
    - [logWarning](#logwarning)
    - [logError](#logerror)
  - [MediaService](#mediaservice)
    - [startMediaPlayer](#startmediaplayer)
    - [pauseMediaPlayer](#pausemediaplayer)
    - [resumeMediaPlayer](#resumemediaplayer)
    - [stopMediaPlayer](#stopmediaplayer)
  - [MessageService](#messageservice)
    - [sendBroadcastMessage](#sendbroadcastmessage)
    - [sendBarrageMessage](#sendbarragemessage)
    - [sendCustomMessage](#sendcustommessage)
  - [MixerService](#mixerservice)
    - [startMixerTask](#startmixertask)
    - [stopMixerTask](#stopmixertask)
    - [updateMixerLayout](#updatemixerlayout)
  - [PluginService](#pluginservice)
    - [registerPlugin](#registerplugin)
    - [unregisterPlugin](#unregisterplugin)
  - [RoomService](#roomservice)
    - [joinRoom](#joinroom)
    - [leaveRoom](#leaveroom)
    - [updateRoomProperties](#updateroomproperties)
  - [UIKitService](#uikitservice)
    - [init](#init)
    - [uninit](#uninit)
    - [getVersion](#getversion)
  - [UserService](#userservice)
    - [getLocalUser](#getlocaluser)
    - [getAllUsers](#getallusers)
    - [getUserByID](#getuserbyid)

---

## Services Overview

ZEGO UIKit Flutter SDK provides a series of service modules for managing and controlling various aspects of real-time audio and video communication, including audio/video control, room management, user management, message sending, device control, and other functions.

## AudioVideoService

Handles audio and video-related functions, such as camera and microphone control, and audio/video stream playback.

### turnCameraOn

> Turn on or off the camera.
>
> - function prototype:
>
> ```dart
> Future<void> turnCameraOn(bool isOn, {String? userID}) async
> ```
>
> - parameters:
>   - `isOn`: Whether to turn on the camera.
>   - `userID`: The ID of the user whose camera to control. If empty, controls the local user's camera.

### turnMicrophoneOn

> Turn on or off the microphone.
>
> - function prototype:
>
> ```dart
> Future<void> turnMicrophoneOn(bool isOn, {String? userID}) async
> ```
>
> - parameters:
>   - `isOn`: Whether to turn on the microphone.
>   - `userID`: The ID of the user whose microphone to control. If empty, controls the local user's microphone.

### useFrontFacingCamera

> Switch between front and back cameras.
>
> - function prototype:
>
> ```dart
> Future<void> useFrontFacingCamera(bool isFrontFacing) async
> ```
>
> - parameters:
>   - `isFrontFacing`: Whether to use the front camera.

### startPlayingStream

> Start playing a user's audio/video stream.
>
> - function prototype:
>
> ```dart
> Future<void> startPlayingStream(String userID) async
> ```
>
> - parameters:
>   - `userID`: The ID of the user whose stream to play.

### stopPlayingStream

> Stop playing a user's audio/video stream.
>
> - function prototype:
>
> ```dart
> Future<void> stopPlayingStream(String userID) async
> ```
>
> - parameters:
>   - `userID`: The ID of the user whose stream to stop playing.

## CustomCommandService

Provides functionality for sending custom commands.

### sendCustomCommand

> Send a custom command to specific users.
>
> - function prototype:
>
> ```dart
> Future<bool> sendCustomCommand(String command, List<String> toUserIDs) async
> ```
>
> - parameters:
>   - `command`: The custom command to send.
>   - `toUserIDs`: The list of user IDs to send the command to.
>
> - returns:
>   - `bool`: Whether the command was sent successfully.

## DeviceService

Provides device-related functions, such as getting device information and managing camera and microphone device lists.

### getDeviceInfo

> Get information about the current device.
>
> - function prototype:
>
> ```dart
> Map<String, dynamic> getDeviceInfo()
> ```
>
> - returns:
>   - `Map<String, dynamic>`: The device information.

### getSystemInfo

> Get information about the system.
>
> - function prototype:
>
> ```dart
> Map<String, dynamic> getSystemInfo()
> ```
>
> - returns:
>   - `Map<String, dynamic>`: The system information.

### getCameraList

> Get the list of available cameras.
>
> - function prototype:
>
> ```dart
> List<ZegoDeviceInfo> getCameraList()
> ```
>
> - returns:
>   - `List<ZegoDeviceInfo>`: The list of available cameras.

### getMicrophoneList

> Get the list of available microphones.
>
> - function prototype:
>
> ```dart
> List<ZegoDeviceInfo> getMicrophoneList()
> ```
>
> - returns:
>   - `List<ZegoDeviceInfo>`: The list of available microphones.

## EffectService

Provides video effects such as beauty filters and virtual backgrounds.

### setBeautyEffect

> Set beauty effects for the video.
>
> - function prototype:
>
> ```dart
> Future<void> setBeautyEffect(BeautyEffectConfig config) async
> ```
>
> - parameters:
>   - `config`: The beauty effect configuration.

### setVirtualBackground

> Set the virtual background for the video.
>
> - function prototype:
>
> ```dart
> Future<void> setVirtualBackground(VirtualBackgroundConfig config) async
> ```
>
> - parameters:
>   - `config`: The virtual background configuration.

## EventService

Provides functionality for event listening and unlistening.

### listen

> Listen to a specific event.
>
> - function prototype:
>
> ```dart
> void listen<T>(String eventName, void Function(T) callback)
> ```
>
> - parameters:
>   - `eventName`: The name of the event to listen to.
>   - `callback`: The function to call when the event occurs.

### unlisten

> Stop listening to a specific event.
>
> - function prototype:
>
> ```dart
> void unlisten<T>(String eventName, [void Function(T)? callback])
> ```
>
> - parameters:
>   - `eventName`: The name of the event to stop listening to.
>   - `callback`: The callback function to remove. If null, removes all callbacks for this event.

## LoggerService

Provides logging functionality.

### logInfo

> Log information level message.
>
> - function prototype:
>
> ```dart
> void logInfo(String tag, String message)
> ```
>
> - parameters:
>   - `tag`: The tag for the log message.
>   - `message`: The message to log.

### logWarning

> Log warning level message.
>
> - function prototype:
>
> ```dart
> void logWarning(String tag, String message)
> ```
>
> - parameters:
>   - `tag`: The tag for the log message.
>   - `message`: The message to log.

### logError

> Log error level message.
>
> - function prototype:
>
> ```dart
> void logError(String tag, String message, [dynamic error, StackTrace? stackTrace])
> ```
>
> - parameters:
>   - `tag`: The tag for the log message.
>   - `message`: The message to log.
>   - `error`: The error object, if any.
>   - `stackTrace`: The stack trace, if any.

## MediaService

Provides media playback related functions.

### startMediaPlayer

> Start playing media from a source.
>
> - function prototype:
>
> ```dart
> Future<int> startMediaPlayer(String source) async
> ```
>
> - parameters:
>   - `source`: The source of the media to play.
>
> - returns:
>   - `int`: Error code, 0 indicates success.

### pauseMediaPlayer

> Pause the media player.
>
> - function prototype:
>
> ```dart
> Future<int> pauseMediaPlayer() async
> ```
>
> - returns:
>   - `int`: Error code, 0 indicates success.

### resumeMediaPlayer

> Resume the media player.
>
> - function prototype:
>
> ```dart
> Future<int> resumeMediaPlayer() async
> ```
>
> - returns:
>   - `int`: Error code, 0 indicates success.

### stopMediaPlayer

> Stop the media player.
>
> - function prototype:
>
> ```dart
> Future<int> stopMediaPlayer() async
> ```
>
> - returns:
>   - `int`: Error code, 0 indicates success.

## MessageService

Provides message sending functionality, including broadcast messages, barrage messages, and custom messages.

### sendBroadcastMessage

> Send a broadcast message to everyone in the room.
>
> - function prototype:
>
> ```dart
> Future<ZegoIMSendResult> sendBroadcastMessage(String message) async
> ```
>
> - parameters:
>   - `message`: The message to send.
>
> - returns:
>   - `ZegoIMSendResult`: The result of sending the message.

### sendBarrageMessage

> Send a barrage message to everyone in the room.
>
> - function prototype:
>
> ```dart
> Future<ZegoIMSendResult> sendBarrageMessage(String message) async
> ```
>
> - parameters:
>   - `message`: The message to send.
>
> - returns:
>   - `ZegoIMSendResult`: The result of sending the message.

### sendCustomMessage

> Send a custom message to specific users.
>
> - function prototype:
>
> ```dart
> Future<ZegoIMSendResult> sendCustomMessage(String message, List<String> toUserIDs) async
> ```
>
> - parameters:
>   - `message`: The message to send.
>   - `toUserIDs`: The list of user IDs to send the message to.
>
> - returns:
>   - `ZegoIMSendResult`: The result of sending the message.

## MixerService

Provides stream mixing functionality for combining multiple video streams into one.

### startMixerTask

> Start a mixer task.
>
> - function prototype:
>
> ```dart
> Future<int> startMixerTask(ZegoMixerTask task) async
> ```
>
> - parameters:
>   - `task`: The mixer task configuration.
>
> - returns:
>   - `int`: Error code, 0 indicates success.

### stopMixerTask

> Stop a mixer task.
>
> - function prototype:
>
> ```dart
> Future<int> stopMixerTask(String taskID) async
> ```
>
> - parameters:
>   - `taskID`: The ID of the mixer task to stop.
>
> - returns:
>   - `int`: Error code, 0 indicates success.

### updateMixerLayout

> Update the layout of a mixer task.
>
> - function prototype:
>
> ```dart
> Future<int> updateMixerLayout(String taskID, List<ZegoMixerInput> mixerInputs) async
> ```
>
> - parameters:
>   - `taskID`: The ID of the mixer task to update.
>   - `mixerInputs`: The new mixer inputs for the layout.
>
> - returns:
>   - `int`: Error code, 0 indicates success.

## PluginService

Provides plugin registration and unregistration functionality.

### registerPlugin

> Register a plugin.
>
> - function prototype:
>
> ```dart
> void registerPlugin(IZegoUIKitPlugin plugin)
> ```
>
> - parameters:
>   - `plugin`: The plugin to register.

### unregisterPlugin

> Unregister a plugin.
>
> - function prototype:
>
> ```dart
> void unregisterPlugin(IZegoUIKitPlugin plugin)
> ```
>
> - parameters:
>   - `plugin`: The plugin to unregister.

## RoomService

Provides room-related functions, such as joining a room, leaving a room, and updating room properties.

### joinRoom

> Join a room.
>
> - function prototype:
>
> ```dart
> Future<int> joinRoom(String roomID, ZegoRoomConfig config) async
> ```
>
> - parameters:
>   - `roomID`: The ID of the room to join.
>   - `config`: The room configuration.
>
> - returns:
>   - `int`: Error code, 0 indicates success.

### leaveRoom

> Leave the current room.
>
> - function prototype:
>
> ```dart
> Future<int> leaveRoom() async
> ```
>
> - returns:
>   - `int`: Error code, 0 indicates success.

### updateRoomProperties

> Update the properties of the current room.
>
> - function prototype:
>
> ```dart
> Future<int> updateRoomProperties(Map<String, String> properties) async
> ```
>
> - parameters:
>   - `properties`: The properties to update.
>
> - returns:
>   - `int`: Error code, 0 indicates success.

## UIKitService

Provides UIKit initialization and uninitialization functionality.

### init

> Initialize the UIKit with the given configuration.
>
> - function prototype:
>
> ```dart
> Future<void> init(ZegoUIKitConfig config) async
> ```
>
> - parameters:
>   - `config`: The UIKit configuration.

### uninit

> Uninitialize the UIKit.
>
> - function prototype:
>
> ```dart
> Future<void> uninit() async
> ```

### getVersion

> Get the version of the UIKit.
>
> - function prototype:
>
> ```dart
> String getVersion()
> ```
>
> - returns:
>   - `String`: The version string.

## UserService

Provides user management functionality, such as getting user information.

### getLocalUser

> Get the local user information.
>
> - function prototype:
>
> ```dart
> ZegoUIKitUser getLocalUser()
> ```
>
> - returns:
>   - `ZegoUIKitUser`: The local user information.

### getAllUsers

> Get the list of all users in the room.
>
> - function prototype:
>
> ```dart
> List<ZegoUIKitUser> getAllUsers()
> ```
>
> - returns:
>   - `List<ZegoUIKitUser>`: The list of all users in the room.

### getUserByID

> Get user information by user ID.
>
> - function prototype:
>
> ```dart
> ZegoUIKitUser? getUserByID(String userID)
> ```
>
> - parameters:
>   - `userID`: The ID of the user to get information for.
>
> - returns:
>   - `ZegoUIKitUser?`: The user information, or null if the user is not found.