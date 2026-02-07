# APIs

- [Services](#services)
  - [ZegoUIKit](#zegouikit)
  - [Audio Video](#audio-video)
  - [Room](#room)
  - [User](#user)
  - [Channel](#channel)
  - [Message](#message)
  - [Custom Command](#custom-command)
  - [Device](#device)
  - [Effect](#effect)
  - [Plugin](#plugin)
  - [Media](#media)
  - [Mixer](#mixer)
  - [Event](#event)
  - [Logger](#logger)
- [Plugins](#plugins)
  - [Signaling](#signaling)
    - [ZegoUIKitSignalingPluginImpl](#zegouikitsignalingpluginimpl)
    - [Invitation Service](#invitation-service)
    - [Invitation Service Advance](#invitation-service-advance)
    - [Notification Service](#notification-service)
    - [Message Service](#message-service)
    - [Room Attributes Service](#room-attributes-service)
    - [User In-Room Attributes Service](#user-in-room-attributes-service)
    - [Background Message Service](#background-message-service)
    - [CallKit Service](#callkit-service)
  - [Invitation Components](#invitation-components)
  - [Defines](#defines)

---

# Services

## ZegoUIKit

The `ZegoUIKit` class is a singleton that provides the main entry point for the Zego UIKit SDK.

- **init**

  - Function Action
    Initializes the Zego UIKit SDK.
  - Function Prototype
    ```dart
    Future<void> init({
      required int appID,
      String appSign = '',
      String token = '',
      bool? enablePlatformView,
      bool playingStreamInPIPUnderIOS = false,
      ZegoUIKitScenario scenario = ZegoUIKitScenario.Default,
      bool withoutCreateEngine = false,
    })
    ```
  - Example
    ```dart
    await ZegoUIKit().init(appID: 123456, appSign: 'your_app_sign');
    ```

- **uninit**

  - Function Action
    Uninitializes the SDK and destroys the engine.
  - Function Prototype
    ```dart
    Future<void> uninit()
    ```
  - Example
    ```dart
    await ZegoUIKit().uninit();
    ```

- **version**

  - Function Action
    Returns the current version of the Zego UIKit.
  - Function Prototype
    ```dart
    Future<String> version()
    ```
  - Example
    ```dart
    var version = await ZegoUIKit().version();
    ```

- **setAdvanceConfigs**

  - Function Action
    Sets advanced engine configurations.
  - Function Prototype
    ```dart
    Future<void> setAdvanceConfigs(Map<String, String> configs)
    ```
  - Example
    ```dart
    await ZegoUIKit().setAdvanceConfigs({'key': 'value'});
    ```

- **getNetworkTime**

  - Function Action
    Returns a notifier for the network time.
  - Function Prototype
    ```dart
    ValueNotifier<DateTime?> getNetworkTime()
    ```
  - Example
    ```dart
    var networkTime = ZegoUIKit().getNetworkTime();
    ```

- **getErrorStream**

  - Function Action
    Returns a stream of errors occurred in the SDK.
  - Function Prototype
    ```dart
    Stream<ZegoUIKitError> getErrorStream()
    ```
  - Example
    ```dart
    ZegoUIKit().getErrorStream().listen((error) {
      // handle error
    });
    ```

- **getEngineStateNotifier**

  - Function Action
    Returns a notifier for the engine state.
  - Function Prototype
    ```dart
    ValueNotifier<ZegoUIKitExpressEngineState> getEngineStateNotifier()
    ```
  - Example
    ```dart
    var stateNotifier = ZegoUIKit().getEngineStateNotifier();
    ```

- **getEngineStateStream**

  - Function Action
    Returns a stream of engine state changes.
  - Function Prototype
    ```dart
    Stream<ZegoUIKitExpressEngineState> getEngineStateStream()
    ```
  - Example
    ```dart
    ZegoUIKit().getEngineStateStream().listen((state) {
      // handle state change
    });
    ```

- **reporter**

  - Function Action
    Returns the reporter instance.
  - Function Prototype
    ```dart
    ZegoUIKitReporter reporter()
    ```
  - Example
    ```dart
    var reporter = ZegoUIKit().reporter();
    ```

- **useDebugMode**

  - Function Action
    Gets or sets the debug mode status.
  - Function Prototype
    ```dart
    bool get useDebugMode
    set useDebugMode(bool value)
    ```
  - Example
    ```dart
    ZegoUIKit().useDebugMode = true;
    var isDebug = ZegoUIKit().useDebugMode;
    ```

## Audio Video

- **unmuteAllRemoteAudioVideo**

  - Function Action
    Start play all audio video.
  - Function Prototype
    ```dart
    Future<void> unmuteAllRemoteAudioVideo({required String targetRoomID})
    ```
  - Example
    ```dart
    await ZegoUIKit().unmuteAllRemoteAudioVideo(targetRoomID: 'room_id');
    ```

- **muteAllRemoteAudioVideo**

  - Function Action
    Stop play all audio video.
  - Function Prototype
    ```dart
    Future<void> muteAllRemoteAudioVideo({required String targetRoomID})
    ```
  - Example
    ```dart
    await ZegoUIKit().muteAllRemoteAudioVideo(targetRoomID: 'room_id');
    ```

- **unmuteAllRemoteAudio**

  - Function Action
    Start play all audio.
  - Function Prototype
    ```dart
    Future<void> unmuteAllRemoteAudio({required String targetRoomID})
    ```
  - Example
    ```dart
    await ZegoUIKit().unmuteAllRemoteAudio(targetRoomID: 'room_id');
    ```

- **muteAllRemoteAudio**

  - Function Action
    Stop play all audio.
  - Function Prototype
    ```dart
    Future<void> muteAllRemoteAudio({required String targetRoomID})
    ```
  - Example
    ```dart
    await ZegoUIKit().muteAllRemoteAudio(targetRoomID: 'room_id');
    ```

- **muteUserAudioVideo**

  - Function Action
    Mute or unmute a user's audio and video.
  - Function Prototype
    ```dart
    Future<bool> muteUserAudioVideo(
      String userID,
      bool mute, {
      required String targetRoomID,
    })
    ```
  - Example
    ```dart
    await ZegoUIKit().muteUserAudioVideo('user_id', true, targetRoomID: 'room_id');
    ```

- **muteUserAudio**

  - Function Action
    Mute or unmute a user's audio.
  - Function Prototype
    ```dart
    Future<bool> muteUserAudio(
      String userID,
      bool mute, {
      required String targetRoomID,
    })
    ```
  - Example
    ```dart
    await ZegoUIKit().muteUserAudio('user_id', true, targetRoomID: 'room_id');
    ```

- **muteUserVideo**

  - Function Action
    Mute or unmute a user's video.
  - Function Prototype
    ```dart
    Future<bool> muteUserVideo(
      String userID,
      bool mute, {
      required String targetRoomID,
    })
    ```
  - Example
    ```dart
    await ZegoUIKit().muteUserVideo('user_id', true, targetRoomID: 'room_id');
    ```

- **setAudioOutputToSpeaker**

  - Function Action
    Set audio output to speaker or earpiece.
  - Function Prototype
    ```dart
    void setAudioOutputToSpeaker(bool isSpeaker)
    ```
  - Example
    ```dart
    ZegoUIKit().setAudioOutputToSpeaker(true);
    ```

## Room

- **hasRoomLogin**

  - Function Action
    Check if there is currently a room logged in.
  - Function Prototype
    ```dart
    bool hasRoomLogin({bool skipHallRoom = false})
    ```
  - Example
    ```dart
    var hasLogin = ZegoUIKit().hasRoomLogin();
    ```

- **loginRoomCount**

  - Function Action
    Get the count of logged-in rooms.
  - Function Prototype
    ```dart
    int loginRoomCount({bool skipHallRoom = false})
    ```
  - Example
    ```dart
    var count = ZegoUIKit().loginRoomCount();
    ```

- **getAllRoomIDs**

  - Function Action
    Get all room IDs.
  - Function Prototype
    ```dart
    List<String> getAllRoomIDs()
    ```
  - Example
    ```dart
    var roomIDs = ZegoUIKit().getAllRoomIDs();
    ```

- **getCurrentRoom**

  - Function Action
    Get current room object (for single room mode).
  - Function Prototype
    ```dart
    ZegoUIKitRoom getCurrentRoom({bool skipHallRoom = false})
    ```
  - Example
    ```dart
    var room = ZegoUIKit().getCurrentRoom();
    ```

- **joinRoom**

  - Function Action
    Join a room.
  - Function Prototype
    ```dart
    Future<ZegoUIKitRoomLoginResult> joinRoom(
      String roomID, {
      String token = '',
      bool markAsLargeRoom = false,
      bool keepWakeScreen = true,
      bool isSimulated = false,
    })
    ```
  - Example
    ```dart
    await ZegoUIKit().joinRoom('room_id');
    ```

- **leaveRoom**

  - Function Action
    Leave a room.
  - Function Prototype
    ```dart
    Future<ZegoUIKitRoomLogoutResult> leaveRoom({required String targetRoomID})
    ```
  - Example
    ```dart
    await ZegoUIKit().leaveRoom(targetRoomID: 'room_id');
    ```

- **switchRoom**

  - Function Action
    Switch to another room.
  - Function Prototype
    ```dart
    Future<void> switchRoom({
      required String toRoomID,
      required bool stopPublishAllStream,
      required bool stopPlayAllStream,
      String token = '',
      bool clearStreamData = true,
      bool clearUserData = true,
    })
    ```
  - Example
    ```dart
    await ZegoUIKit().switchRoom(
      toRoomID: 'new_room_id',
      stopPublishAllStream: true,
      stopPlayAllStream: true,
    );
    ```

- **renewRoomToken**

  - Function Action
    Renew room token.
  - Function Prototype
    ```dart
    Future<void> renewRoomToken(String token, {required String targetRoomID})
    ```
  - Example
    ```dart
    await ZegoUIKit().renewRoomToken('new_token', targetRoomID: 'room_id');
    ```

## User

- **login**

  - Function Action
    Login user.
  - Function Prototype
    ```dart
    void login(String id, String name)
    ```
  - Example
    ```dart
    ZegoUIKit().login('user_id', 'user_name');
    ```

- **logout**

  - Function Action
    Logout user.
  - Function Prototype
    ```dart
    void logout()
    ```
  - Example
    ```dart
    ZegoUIKit().logout();
    ```

- **getLocalUser**

  - Function Action
    Get local user object.
  - Function Prototype
    ```dart
    ZegoUIKitUser getLocalUser()
    ```
  - Example
    ```dart
    var user = ZegoUIKit().getLocalUser();
    ```

- **getLocalUserNotifier**

  - Function Action
    Get local user update notifier.
  - Function Prototype
    ```dart
    ValueNotifier<ZegoUIKitUser> getLocalUserNotifier()
    ```
  - Example
    ```dart
    var notifier = ZegoUIKit().getLocalUserNotifier();
    ```

- **getAllUsers**

  - Function Action
    Get all users (local and remote).
  - Function Prototype
    ```dart
    List<ZegoUIKitUser> getAllUsers({required String targetRoomID})
    ```
  - Example
    ```dart
    var users = ZegoUIKit().getAllUsers(targetRoomID: 'room_id');
    ```

- **getRemoteUsers**

  - Function Action
    Get remote users.
  - Function Prototype
    ```dart
    List<ZegoUIKitUser> getRemoteUsers({required String targetRoomID})
    ```
  - Example
    ```dart
    var users = ZegoUIKit().getRemoteUsers(targetRoomID: 'room_id');
    ```

- **getUser**

  - Function Action
    Get user by ID.
  - Function Prototype
    ```dart
    ZegoUIKitUser getUser(String userID, {required String targetRoomID})
    ```
  - Example
    ```dart
    var user = ZegoUIKit().getUser('user_id', targetRoomID: 'room_id');
    ```

- **getInRoomUserAttributesNotifier**

  - Function Action
    Get notifier of in-room user attributes.
  - Function Prototype
    ```dart
    ValueNotifier<ZegoUIKitUserAttributes> getInRoomUserAttributesNotifier(
      String userID, {
      required String targetRoomID,
    })
    ```
  - Example
    ```dart
    var notifier = ZegoUIKit().getInRoomUserAttributesNotifier('user_id', targetRoomID: 'room_id');
    ```

- **getUserListStream**

  - Function Action
    Get user list stream.
  - Function Prototype
    ```dart
    Stream<List<ZegoUIKitUser>> getUserListStream({required String targetRoomID})
    ```
  - Example
    ```dart
    ZegoUIKit().getUserListStream(targetRoomID: 'room_id').listen((users) {});
    ```

- **getUserJoinStream**

  - Function Action
    Get user join stream.
  - Function Prototype
    ```dart
    Stream<List<ZegoUIKitUser>> getUserJoinStream({required String targetRoomID})
    ```
  - Example
    ```dart
    ZegoUIKit().getUserJoinStream(targetRoomID: 'room_id').listen((users) {});
    ```

- **getUserLeaveStream**

  - Function Action
    Get user leave stream.
  - Function Prototype
    ```dart
    Stream<List<ZegoUIKitUser>> getUserLeaveStream({required String targetRoomID})
    ```
  - Example
    ```dart
    ZegoUIKit().getUserLeaveStream(targetRoomID: 'room_id').listen((users) {});
    ```

- **removeUserFromRoom**

  - Function Action
    Remove user from room (kick out).
  - Function Prototype
    ```dart
    Future<bool> removeUserFromRoom(List<String> userIDs, {required String targetRoomID})
    ```
  - Example
    ```dart
    await ZegoUIKit().removeUserFromRoom(['user_id'], targetRoomID: 'room_id');
    ```

- **getMeRemovedFromRoomStream**

  - Function Action
    Get stream for when current user is removed from room.
  - Function Prototype
    ```dart
    Stream<String> getMeRemovedFromRoomStream({required String targetRoomID})
    ```
  - Example
    ```dart
    ZegoUIKit().getMeRemovedFromRoomStream(targetRoomID: 'room_id').listen((data) {});
    ```

## Channel

- **backToDesktop**

  - Function Action
    Back to desktop (Android).
  - Function Prototype
    ```dart
    Future<void> backToDesktop({bool nonRoot = false})
    ```
  - Example
    ```dart
    await ZegoUIKit().backToDesktop();
    ```

- **isLockScreen**

  - Function Action
    Check if screen is locked.
  - Function Prototype
    ```dart
    Future<bool> isLockScreen()
    ```
  - Example
    ```dart
    var isLocked = await ZegoUIKit().isLockScreen();
    ```

- **checkAppRunning**

  - Function Action
    Check if app is running.
  - Function Prototype
    ```dart
    Future<bool> checkAppRunning()
    ```
  - Example
    ```dart
    var isRunning = await ZegoUIKit().checkAppRunning();
    ```

- **activeAppToForeground**

  - Function Action
    Bring app to foreground.
  - Function Prototype
    ```dart
    Future<void> activeAppToForeground()
    ```
  - Example
    ```dart
    await ZegoUIKit().activeAppToForeground();
    ```

- **stopIOSPIP**

  - Function Action
    Stop iOS PIP.
  - Function Prototype
    ```dart
    Future<bool> stopIOSPIP()
    ```
  - Example
    ```dart
    await ZegoUIKit().stopIOSPIP();
    ```

- **isIOSInPIP**

  - Function Action
    Check if iOS is in PIP mode.
  - Function Prototype
    ```dart
    Future<bool> isIOSInPIP()
    ```
  - Example
    ```dart
    var inPIP = await ZegoUIKit().isIOSInPIP();
    ```

- **enableIOSPIP**

  - Function Action
    Enable iOS PIP.
  - Function Prototype
    ```dart
    Future<void> enableIOSPIP(
      String streamID, {
      int aspectWidth = 9,
      int aspectHeight = 16,
    })
    ```
  - Example
    ```dart
    await ZegoUIKit().enableIOSPIP('stream_id');
    ```

- **updateIOSPIPSource**

  - Function Action
    Update iOS PIP source.
  - Function Prototype
    ```dart
    Future<void> updateIOSPIPSource(String streamID)
    ```
  - Example
    ```dart
    await ZegoUIKit().updateIOSPIPSource('stream_id');
    ```

- **enableIOSPIPAuto**

  - Function Action
    Enable iOS PIP auto mode.
  - Function Prototype
    ```dart
    Future<void> enableIOSPIPAuto(
      bool isEnabled, {
      int aspectWidth = 9,
      int aspectHeight = 16,
    })
    ```
  - Example
    ```dart
    await ZegoUIKit().enableIOSPIPAuto(true);
    ```

- **enableHardwareDecoder**

  - Function Action
    Enable hardware decoder.
  - Function Prototype
    ```dart
    Future<void> enableHardwareDecoder(bool isEnabled)
    ```
  - Example
    ```dart
    await ZegoUIKit().enableHardwareDecoder(true);
    ```

- **enableCustomVideoRender**

  - Function Action
    Enable custom video render.
  - Function Prototype
    ```dart
    Future<void> enableCustomVideoRender(bool isEnabled)
    ```
  - Example
    ```dart
    await ZegoUIKit().enableCustomVideoRender(true);
    ```

## Message

- **sendInRoomMessage**

  - Function Action
    Send in-room message.
  - Function Prototype
    ```dart
    Future<bool> sendInRoomMessage(
      String message, {
      required String targetRoomID,
      ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
    })
    ```
  - Example
    ```dart
    await ZegoUIKit().sendInRoomMessage('hello', targetRoomID: 'room_id');
    ```

- **resendInRoomMessage**

  - Function Action
    Resend in-room message.
  - Function Prototype
    ```dart
    Future<bool> resendInRoomMessage(
      ZegoInRoomMessage message, {
      required String targetRoomID,
      ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
    })
    ```
  - Example
    ```dart
    await ZegoUIKit().resendInRoomMessage(message, targetRoomID: 'room_id');
    ```

- **getInRoomMessages**

  - Function Action
    Get history messages.
  - Function Prototype
    ```dart
    List<ZegoInRoomMessage> getInRoomMessages({
      required String targetRoomID,
      ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
    })
    ```
  - Example
    ```dart
    var messages = ZegoUIKit().getInRoomMessages(targetRoomID: 'room_id');
    ```

- **getInRoomMessageListStream**

  - Function Action
    Get messages list stream.
  - Function Prototype
    ```dart
    Stream<List<ZegoInRoomMessage>> getInRoomMessageListStream({
      required String targetRoomID,
      ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
    })
    ```
  - Example
    ```dart
    ZegoUIKit().getInRoomMessageListStream(targetRoomID: 'room_id').listen((messages) {});
    ```

- **getInRoomMessageStream**

  - Function Action
    Get latest message received stream.
  - Function Prototype
    ```dart
    Stream<ZegoInRoomMessage> getInRoomMessageStream({
      required String targetRoomID,
      ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
    })
    ```
  - Example
    ```dart
    ZegoUIKit().getInRoomMessageStream(targetRoomID: 'room_id').listen((message) {});
    ```

## Custom Command

- **sendInRoomCommand**

  - Function Action
    Send in-room command.
  - Function Prototype
    ```dart
    Future<bool> sendInRoomCommand(
      String command,
      List<String> toUserIDs, {
      required String targetRoomID,
    })
    ```
  - Example
    ```dart
    await ZegoUIKit().sendInRoomCommand('command', [], targetRoomID: 'room_id');
    ```

- **getInRoomCommandReceivedStream**

  - Function Action
    Get in-room command received stream.
  - Function Prototype
    ```dart
    Stream<ZegoInRoomCommandReceivedData> getInRoomCommandReceivedStream()
    ```
  - Example
    ```dart
    ZegoUIKit().getInRoomCommandReceivedStream().listen((data) {});
    ```

## Device

- **getTurnOnYourCameraRequestStream**

  - Function Action
    Get stream for "Turn on your camera" requests.
  - Function Prototype
    ```dart
    Stream<String> getTurnOnYourCameraRequestStream({required String targetRoomID})
    ```
  - Example
    ```dart
    ZegoUIKit().getTurnOnYourCameraRequestStream(targetRoomID: 'room_id').listen((userID) {});
    ```

- **getTurnOnYourMicrophoneRequestStream**

  - Function Action
    Get stream for "Turn on your microphone" requests.
  - Function Prototype
    ```dart
    Stream<ZegoUIKitReceiveTurnOnLocalMicrophoneEvent> getTurnOnYourMicrophoneRequestStream({
      required String targetRoomID,
    })
    ```
  - Example
    ```dart
    ZegoUIKit().getTurnOnYourMicrophoneRequestStream(targetRoomID: 'room_id').listen((event) {});
    ```

- **enableCustomVideoProcessing**

  - Function Action
    Enable custom video processing.
  - Function Prototype
    ```dart
    Future<void> enableCustomVideoProcessing(bool enable)
    ```
  - Example
    ```dart
    await ZegoUIKit().enableCustomVideoProcessing(true);
    ```

- **getMobileSystemVersion**

  - Function Action
    Get mobile system version.
  - Function Prototype
    ```dart
    ZegoMobileSystemVersion getMobileSystemVersion()
    ```
  - Example
    ```dart
    var version = ZegoUIKit().getMobileSystemVersion();
    ```

- **setAudioDeviceMode**

  - Function Action
    Set audio device mode.
  - Function Prototype
    ```dart
    Future<void> setAudioDeviceMode(ZegoUIKitAudioDeviceMode deviceMode)
    ```
  - Example
    ```dart
    await ZegoUIKit().setAudioDeviceMode(ZegoUIKitAudioDeviceMode.General);
    ```

## Effect

- **enableBeauty**

  - Function Action
    Enable beauty effect.
  - Function Prototype
    ```dart
    Future<void> enableBeauty(bool isOn)
    ```
  - Example
    ```dart
    await ZegoUIKit().enableBeauty(true);
    ```

- **startEffectsEnv**

  - Function Action
    Start effects environment.
  - Function Prototype
    ```dart
    Future<void> startEffectsEnv()
    ```
  - Example
    ```dart
    await ZegoUIKit().startEffectsEnv();
    ```

- **stopEffectsEnv**

  - Function Action
    Stop effects environment.
  - Function Prototype
    ```dart
    Future<void> stopEffectsEnv()
    ```
  - Example
    ```dart
    await ZegoUIKit().stopEffectsEnv();
    ```

- **setBeautifyValue**

  - Function Action
    Set intensity of specific face beautify feature.
  - Function Prototype
    ```dart
    void setBeautifyValue(int value, BeautyEffectType type)
    ```
  - Example
    ```dart
    ZegoUIKit().setBeautifyValue(50, BeautyEffectType.whiten);
    ```

- **getBeautyValue**

  - Function Action
    Get current beauty parameters.
  - Function Prototype
    ```dart
    ZegoEffectsBeautyParam getBeautyValue()
    ```
  - Example
    ```dart
    var params = ZegoUIKit().getBeautyValue();
    ```

- **setVoiceChangerType**

  - Function Action
    Set voice changer type.
  - Function Prototype
    ```dart
    void setVoiceChangerType(ZegoVoiceChangerPreset voicePreset)
    ```
  - Example
    ```dart
    ZegoUIKit().setVoiceChangerType(ZegoVoiceChangerPreset.Robot);
    ```

- **setReverbType**

  - Function Action
    Set reverb type.
  - Function Prototype
    ```dart
    void setReverbType(ZegoReverbPreset reverbPreset)
    ```
  - Example
    ```dart
    ZegoUIKit().setReverbType(ZegoReverbPreset.KTV);
    ```

- **resetSoundEffect**

  - Function Action
    Reset sound effects (voice changer and reverb).
  - Function Prototype
    ```dart
    Future<void> resetSoundEffect()
    ```
  - Example
    ```dart
    await ZegoUIKit().resetSoundEffect();
    ```

## Plugin

- **pluginsInstallNotifier**

  - Function Action
    Get installed plugins notifier.
  - Function Prototype
    ```dart
    ValueNotifier<List<ZegoUIKitPluginType>> pluginsInstallNotifier()
    ```
  - Example
    ```dart
    var notifier = ZegoUIKit().pluginsInstallNotifier();
    ```

- **installPlugins**

  - Function Action
    Install plugins.
  - Function Prototype
    ```dart
    void installPlugins(List<IZegoUIKitPlugin> plugins)
    ```
  - Example
    ```dart
    ZegoUIKit().installPlugins([plugin1, plugin2]);
    ```

- **uninstallPlugins**

  - Function Action
    Uninstall plugins.
  - Function Prototype
    ```dart
    void uninstallPlugins(List<IZegoUIKitPlugin> plugins)
    ```
  - Example
    ```dart
    ZegoUIKit().uninstallPlugins([plugin1]);
    ```

- **adapterService**

  - Function Action
    Get adapter service.
  - Function Prototype
    ```dart
    ZegoPluginAdapterService adapterService()
    ```
  - Example
    ```dart
    var service = ZegoUIKit().adapterService();
    ```

- **getPlugin**

  - Function Action
    Get plugin object by type.
  - Function Prototype
    ```dart
    IZegoUIKitPlugin? getPlugin(ZegoUIKitPluginType type)
    ```
  - Example
    ```dart
    var plugin = ZegoUIKit().getPlugin(ZegoUIKitPluginType.beauty);
    ```

- **getSignalingPlugin**

  - Function Action
    Get signaling plugin instance.
  - Function Prototype
    ```dart
    ZegoUIKitSignalingPluginImpl getSignalingPlugin()
    ```
  - Example
    ```dart
    var plugin = ZegoUIKit().getSignalingPlugin();
    ```

- **getBeautyPlugin**

  - Function Action
    Get beauty plugin instance.
  - Function Prototype
    ```dart
    ZegoUIKitBeautyPluginImpl getBeautyPlugin()
    ```
  - Example
    ```dart
    var plugin = ZegoUIKit().getBeautyPlugin();
    ```

## Media

- **registerMediaEvent**

  - Function Action
    Register media event.
  - Function Prototype
    ```dart
    void registerMediaEvent(ZegoUIKitMediaEventInterface event)
    ```
  - Example
    ```dart
    ZegoUIKit().registerMediaEvent(eventImpl);
    ```

- **unregisterMediaEvent**

  - Function Action
    Unregister media event.
  - Function Prototype
    ```dart
    void unregisterMediaEvent(ZegoUIKitMediaEventInterface event)
    ```
  - Example
    ```dart
    ZegoUIKit().unregisterMediaEvent(eventImpl);
    ```

- **playMedia**

  - Function Action
    Start playing media.
  - Function Prototype
    ```dart
    Future<ZegoUIKitMediaPlayResult> playMedia({
      required String filePathOrURL,
      bool enableRepeat = false,
      bool autoStart = true,
    })
    ```
  - Example
    ```dart
    await ZegoUIKit().playMedia(filePathOrURL: 'path/to/file');
    ```

- **startMedia**

  - Function Action
    Start media.
  - Function Prototype
    ```dart
    Future<void> startMedia()
    ```
  - Example
    ```dart
    await ZegoUIKit().startMedia();
    ```

- **stopMedia**

  - Function Action
    Stop media.
  - Function Prototype
    ```dart
    Future<void> stopMedia()
    ```
  - Example
    ```dart
    await ZegoUIKit().stopMedia();
    ```

- **pauseMedia**

  - Function Action
    Pause media.
  - Function Prototype
    ```dart
    Future<void> pauseMedia()
    ```
  - Example
    ```dart
    await ZegoUIKit().pauseMedia();
    ```

- **resumeMedia**

  - Function Action
    Resume media.
  - Function Prototype
    ```dart
    Future<void> resumeMedia()
    ```
  - Example
    ```dart
    await ZegoUIKit().resumeMedia();
    ```

- **destroyMedia**

  - Function Action
    Destroy media.
  - Function Prototype
    ```dart
    Future<void> destroyMedia()
    ```
  - Example
    ```dart
    await ZegoUIKit().destroyMedia();
    ```

- **seekTo**

  - Function Action
    Seek to specific time.
  - Function Prototype
    ```dart
    Future<ZegoUIKitMediaSeekToResult> seekTo(int millisecond)
    ```
  - Example
    ```dart
    await ZegoUIKit().seekTo(1000);
    ```

- **setMediaVolume**

  - Function Action
    Set media volume.
  - Function Prototype
    ```dart
    Future<void> setMediaVolume(int volume, {bool isSyncToRemote = false})
    ```
  - Example
    ```dart
    await ZegoUIKit().setMediaVolume(50);
    ```

- **getMediaVolume**

  - Function Action
    Get media volume.
  - Function Prototype
    ```dart
    int getMediaVolume()
    ```
  - Example
    ```dart
    var volume = ZegoUIKit().getMediaVolume();
    ```

## Mixer

- **startPlayAnotherRoomAudioVideo**

  - Function Action
    Start playing a user's audio & video stream from another room.
  - Function Prototype
    ```dart
    Future<void> startPlayAnotherRoomAudioVideo(
      String anotherRoomID,
      String anotherUserID, {
      ZegoStreamType streamType = ZegoStreamType.main,
      String anotherUserName = '',
      required String targetRoomID,
      required bool playOnAnotherRoom,
      PlayerStateUpdateCallback? onPlayerStateUpdated,
    })
    ```
  - Example
    ```dart
    await ZegoUIKit().startPlayAnotherRoomAudioVideo('room_b', 'user_b', targetRoomID: 'room_a', playOnAnotherRoom: true);
    ```

- **stopPlayAnotherRoomAudioVideo**

  - Function Action
    Stop playing a user's audio & video stream from another room.
  - Function Prototype
    ```dart
    Future<void> stopPlayAnotherRoomAudioVideo(
      String userID, {
      required String targetRoomID,
      ZegoStreamType streamType = ZegoStreamType.main,
    })
    ```
  - Example
    ```dart
    await ZegoUIKit().stopPlayAnotherRoomAudioVideo('user_b', targetRoomID: 'room_a');
    ```

- **startMixerTask**

  - Function Action
    Start a mixer task.
  - Function Prototype
    ```dart
    Future<ZegoMixerStartResult> startMixerTask(ZegoMixerTask task)
    ```
  - Example
    ```dart
    await ZegoUIKit().startMixerTask(task);
    ```

- **stopMixerTask**

  - Function Action
    Stop a mixer task.
  - Function Prototype
    ```dart
    Future<ZegoMixerStopResult> stopMixerTask(ZegoMixerTask task)
    ```
  - Example
    ```dart
    await ZegoUIKit().stopMixerTask(task);
    ```

- **startPlayMixAudioVideo**

  - Function Action
    Start playing a mixed audio & video stream.
  - Function Prototype
    ```dart
    Future<void> startPlayMixAudioVideo(
      String mixerStreamID, {
      required String targetRoomID,
      List<ZegoUIKitUser> users = const [],
      Map<String, int> userSoundIDs = const {},
      PlayerStateUpdateCallback? onPlayerStateUpdated,
    })
    ```
  - Example
    ```dart
    await ZegoUIKit().startPlayMixAudioVideo('mixer_stream_id', targetRoomID: 'room_id');
    ```

- **stopPlayMixAudioVideo**

  - Function Action
    Stop playing a mixed audio & video stream.
  - Function Prototype
    ```dart
    Future<void> stopPlayMixAudioVideo(String mixerStreamID, {required String targetRoomID})
    ```
  - Example
    ```dart
    await ZegoUIKit().stopPlayMixAudioVideo('mixer_stream_id', targetRoomID: 'room_id');
    ```

## Event

- **registerExpressEvent**

  - Function Action
    Register express event.
  - Function Prototype
    ```dart
    void registerExpressEvent(ZegoUIKitExpressEventInterface event)
    ```
  - Example
    ```dart
    ZegoUIKit().registerExpressEvent(eventImpl);
    ```

- **unregisterExpressEvent**

  - Function Action
    Unregister express event.
  - Function Prototype
    ```dart
    void unregisterExpressEvent(ZegoUIKitExpressEventInterface event)
    ```
  - Example
    ```dart
    ZegoUIKit().unregisterExpressEvent(eventImpl);
    ```

## Logger

- **initLog**

  - Function Action
    Initialize logger.
  - Function Prototype
    ```dart
    Future<void> initLog()
    ```
  - Example
    ```dart
    await ZegoUIKit().initLog();
    ```

- **clearLogs**

  - Function Action
    Clear logs.
  - Function Prototype
    ```dart
    Future<void> clearLogs()
    ```
  - Example
    ```dart
    await ZegoUIKit().clearLogs();
    ```

- **exportLogs**

  - Function Action
    Export logs.
  - Function Prototype
    ```dart
    Future<bool> exportLogs({
      String? title,
      String? content,
      String? fileName,
      List<ZegoLogExporterFileType> fileTypes = const [
        ZegoLogExporterFileType.txt,
        ZegoLogExporterFileType.log,
        ZegoLogExporterFileType.zip
      ],
      List<ZegoLogExporterDirectoryType> directories = const [
        ZegoLogExporterDirectoryType.zegoUIKits,
        ZegoLogExporterDirectoryType.zimAudioLog,
        ZegoLogExporterDirectoryType.zimLogs,
        ZegoLogExporterDirectoryType.zefLogs,
        ZegoLogExporterDirectoryType.zegoLogs,
      ],
      void Function(double progress)? onProgress,
    })
    ```
  - Example
    ```dart
    await ZegoUIKit().exportLogs();
    ```

- **logInfo**

  - Function Action
    Log info message.
  - Function Prototype
    ```dart
    static Future<void> logInfo(String logMessage, {String tag = '', String subTag = ''})
    ```
  - Example
    ```dart
    await ZegoLoggerService.logInfo('message');
    ```

# Plugins

## Signaling

### ZegoUIKitSignalingPluginImpl

The signaling plugin implementation. Access it via `ZegoUIKitSignalingPluginImpl.shared` or `ZegoUIKit().getSignalingPlugin()`.

- **init**

  - Function Action
    Initialize the signaling plugin.
  - Function Prototype
    ```dart
    Future<void> init(
      int appID, {
      String appSign = '',
      String token = '',
    })
    ```
  - Example
    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.init(appID: 123456);
    ```

- **uninit**

  - Function Action
    Uninitialize the signaling plugin.
  - Function Prototype
    ```dart
    Future<void> uninit({bool forceDestroy = false})
    ```
  - Example
    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.uninit();
    ```

- **login**

  - Function Action
    Login to the signaling service.
  - Function Prototype
    ```dart
    Future<bool> login({
      required String id,
      required String name,
      String token = '',
    })
    ```
  - Example
    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.login(id: 'user', name: 'User');
    ```

- **logout**

  - Function Action
    Logout from the signaling service.
  - Function Prototype
    ```dart
    Future<void> logout()
    ```
  - Example
    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.logout();
    ```

- **joinRoom**

  - Function Action
    Join a signaling room.
  - Function Prototype
    ```dart
    Future<ZegoSignalingPluginJoinRoomResult> joinRoom(
      String roomID, {
      String roomName = '',
      bool force = false,
    })
    ```
  - Example
    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.joinRoom('room_id');
    ```

- **switchRoom**

  - Function Action
    Switch to another signaling room.
  - Function Prototype
    ```dart
    Future<ZegoSignalingPluginJoinRoomResult> switchRoom(
      String roomID, {
      String roomName = '',
    })
    ```
  - Example
    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.switchRoom('new_room_id');
    ```

- **renewToken**

  - Function Action
    Renew the signaling token.
  - Function Prototype
    ```dart
    Future<bool> renewToken(String token)
    ```
  - Example
    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.renewToken('new_token');
    ```

### Invitation Service

- **sendInvitation**

  - Function Action
    Send a call invitation.
  - Function Prototype
    ```dart
    Future<ZegoSignalingPluginSendInvitationResult> sendInvitation({
      required String inviterID,
      required String inviterName,
      required List<String> invitees,
      required int timeout,
      required int type,
      required String data,
      bool isAdvancedMode = false,
      ZegoNotificationConfig? zegoNotificationConfig,
    })
    ```
  - Example
    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.sendInvitation(
      inviterID: 'id',
      inviterName: 'name',
      invitees: ['invitee_id'],
      timeout: 60,
      type: 1,
      data: 'data',
    );
    ```

### Invitation Service Advance

- **sendAdvanceInvitation**

  - Function Action
    Send an advanced call invitation.
  - Function Prototype
    ```dart
    Future<ZegoSignalingPluginSendInvitationResult> sendAdvanceInvitation({
      required String inviterID,
      required String inviterName,
      required List<String> invitees,
      required int timeout,
      required int type,
      required String data,
      ZegoNotificationConfig? zegoNotificationConfig,
    })
    ```
  - Example
    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.sendAdvanceInvitation(
      inviterID: 'id',
      inviterName: 'name',
      invitees: ['invitee_id'],
      timeout: 60,
      type: 1,
      data: 'data',
    );
    ```

### Notification Service

- **enableNotifyWhenAppRunningInBackgroundOrQuit**

  - Function Action
    Enable background notifications.
  - Function Prototype
    ```dart
    Future<ZegoSignalingPluginEnableNotifyResult> enableNotifyWhenAppRunningInBackgroundOrQuit(
      bool enabled, {
      bool? isIOSSandboxEnvironment,
      bool enableIOSVoIP = true,
      int certificateIndex = 1,
      String appName = '',
      String androidChannelID = '',
      String androidChannelName = '',
      String androidSound = '',
    })
    ```
  - Example
    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.enableNotifyWhenAppRunningInBackgroundOrQuit(true);
    ```

### Message Service

- **sendInRoomTextMessage**

  - Function Action
    Send text message in room.
  - Function Prototype
    ```dart
    Future<ZegoSignalingPluginInRoomTextMessageResult> sendInRoomTextMessage({
      required String roomID,
      required String message,
    })
    ```
  - Example
    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.sendInRoomTextMessage(
      roomID: 'room_id',
      message: 'hello',
    );
    ```

- **sendInRoomCommandMessage**

  - Function Action
    Send command message in room.
  - Function Prototype
    ```dart
    Future<ZegoSignalingPluginInRoomCommandMessageResult> sendInRoomCommandMessage({
      required String roomID,
      required Uint8List message,
    })
    ```
  - Example
    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.sendInRoomCommandMessage(
      roomID: 'room_id',
      message: Uint8List.fromList([1, 2, 3]),
    );
    ```

### Room Attributes Service

- **updateRoomProperty**

  - Function Action
    Update room properties.
  - Function Prototype
    ```dart
    Future<ZegoSignalingPluginRoomPropertiesOperationResult> updateRoomProperty({
      required String roomID,
      required String key,
      required String value,
      bool isForce = false,
      bool isDeleteAfterOwnerLeft = false,
      bool isUpdateOwner = false,
    })
    ```
  - Example
    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.updateRoomProperty(
      roomID: 'room_id',
      key: 'key',
      value: 'value',
    );
    ```

- **deleteRoomProperties**

  - Function Action
    Delete room properties.
  - Function Prototype
    ```dart
    Future<ZegoSignalingPluginRoomPropertiesOperationResult> deleteRoomProperties({
      required String roomID,
      required List<String> keys,
      bool isForce = false,
      bool showErrorLog = true,
    })
    ```
  - Example
    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.deleteRoomProperties(
      roomID: 'room_id',
      keys: ['key'],
    );
    ```

### User In-Room Attributes Service

- **setUsersInRoomAttributes**

  - Function Action
    Set user attributes in room.
  - Function Prototype
    ```dart
    Future<ZegoSignalingPluginSetUsersInRoomAttributesResult> setUsersInRoomAttributes({
      required String roomID,
      required String key,
      required String value,
      required List<String> userIDs,
    })
    ```
  - Example
    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.setUsersInRoomAttributes(
      roomID: 'room_id',
      key: 'key',
      value: 'value',
      userIDs: ['user_id'],
    );
    ```

- **queryUsersInRoomAttributes**

  - Function Action
    Query user attributes in room.
  - Function Prototype
    ```dart
    Future<ZegoSignalingPluginQueryUsersInRoomAttributesResult> queryUsersInRoomAttributes({
      required String roomID,
      String nextFlag = '',
      int count = 100,
    })
    ```
  - Example
    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.queryUsersInRoomAttributes(
      roomID: 'room_id',
    );
    ```

### Background Message Service

- **setBackgroundMessageHandler**

  - Function Action
    Set background message handler.
  - Function Prototype
    ```dart
    Future<ZegoSignalingPluginSetMessageHandlerResult> setBackgroundMessageHandler(
      ZegoSignalingPluginZPNsBackgroundMessageHandler handler, {
      String key = 'default',
    })
    ```
  - Example
    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.setBackgroundMessageHandler(handler);
    ```

### CallKit Service

- **setIncomingPushReceivedHandler**

  - Function Action
    Set incoming push received handler.
  - Function Prototype
    ```dart
    Future<void> setIncomingPushReceivedHandler(
        ZegoSignalingIncomingPushReceivedHandler handler)
    ```
  - Example
    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.setIncomingPushReceivedHandler(handler);
    ```

- **setInitConfiguration**

  - Function Action
    Set initialization configuration.
  - Function Prototype
    ```dart
    Future<void> setInitConfiguration(
      ZegoSignalingPluginProviderConfiguration configuration,
    )
    ```
  - Example
    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.setInitConfiguration(config);
    ```

## Invitation Components

**ZegoStartInvitationButton**

- **Constructor**
  - Function Action
    Create a start invitation button.
  - Function Prototype
    ```dart
    const ZegoStartInvitationButton({
      Key? key,
      required int invitationType,
      required List<String> invitees,
      required String data,
      bool isAdvancedMode = false,
      ZegoNotificationConfig? notificationConfig,
      int timeoutSeconds = 60,
      String? text,
      TextStyle? textStyle,
      ButtonIcon? icon,
      Size? iconSize,
      double? iconTextSpacing,
      bool verticalLayout = true,
      Size? buttonSize,
      double? borderRadius,
      EdgeInsetsGeometry? margin,
      EdgeInsetsGeometry? padding,
      Future<bool> Function()? onWillPressed,
      void Function(ZegoStartInvitationButtonResult result)? onPressed,
      ZegoNetworkLoadingConfig? networkLoadingConfig,
      Color? clickableTextColor,
      Color? unclickableTextColor,
      Color? clickableBackgroundColor,
      Color? unclickableBackgroundColor,
    })
    ```
  - Example
    ```dart
    ZegoStartInvitationButton(
      invitationType: 1,
      invitees: ['user_id'],
      data: 'data',
    );
    ```

**ZegoAcceptInvitationButton**

- **Constructor**
  - Function Action
    Create an accept invitation button.
  - Function Prototype
    ```dart
    const ZegoAcceptInvitationButton({
      Key? key,
      required String inviterID,
      bool isAdvancedMode = false,
      String customData = '',
      String? targetInvitationID,
      String? text,
      TextStyle? textStyle,
      ButtonIcon? icon,
      Size? iconSize,
      Size? buttonSize,
      double? iconTextSpacing,
      bool verticalLayout = true,
      void Function()? onWillPress,
      void Function(ZegoAcceptInvitationButtonResult result)? onPressed,
      ZegoNetworkLoadingConfig? networkLoadingConfig,
      Color? clickableTextColor,
      Color? unclickableTextColor,
      Color? clickableBackgroundColor,
      Color? unclickableBackgroundColor,
    })
    ```
  - Example
    ```dart
    ZegoAcceptInvitationButton(inviterID: 'inviter_id');
    ```

**ZegoRefuseInvitationButton**

- **Constructor**
  - Function Action
    Create a refuse invitation button.
  - Function Prototype
    ```dart
    const ZegoRefuseInvitationButton({
      Key? key,
      required String inviterID,
      String data = '',
      bool isAdvancedMode = false,
      String? targetInvitationID,
      String? text,
      TextStyle? textStyle,
      ButtonIcon? icon,
      Size? iconSize,
      Size? buttonSize,
      double? iconTextSpacing,
      bool verticalLayout = true,
      void Function()? onWillPress,
      void Function(ZegoRefuseInvitationButtonResult result)? onPressed,
      ZegoNetworkLoadingConfig? networkLoadingConfig,
      Color? clickableTextColor,
      Color? unclickableTextColor,
      Color? clickableBackgroundColor,
      Color? unclickableBackgroundColor,
    })
    ```
  - Example
    ```dart
    ZegoRefuseInvitationButton(inviterID: 'inviter_id');
    ```

**ZegoCancelInvitationButton**

- **Constructor**
  - Function Action
    Create a cancel invitation button.
  - Function Prototype
    ```dart
    const ZegoCancelInvitationButton({
      Key? key,
      required List<String> invitees,
      String data = '',
      bool isAdvancedMode = false,
      String? targetInvitationID,
      String? text,
      TextStyle? textStyle,
      ButtonIcon? icon,
      Size? iconSize,
      Size? buttonSize,
      double? iconTextSpacing,
      bool verticalLayout = true,
      void Function()? onWillPress,
      void Function(ZegoCancelInvitationButtonResult result)? onPressed,
      ZegoNetworkLoadingConfig? networkLoadingConfig,
      Color? clickableTextColor,
      Color? unclickableTextColor,
      Color? clickableBackgroundColor,
      Color? unclickableBackgroundColor,
    })
    ```
  - Example
    ```dart
    ZegoCancelInvitationButton(invitees: ['user_id']);
    ```

## Defines

**ZegoNotificationConfig**

- **Properties**
  - `bool notifyWhenAppIsInTheBackgroundOrQuit`: Whether to notify when the app is in the background or quit.
  - `String resourceID`: Resource ID for the notification.
  - `String title`: Title of the notification.
  - `String message`: Message of the notification.
  - `ZegoNotificationVoIPConfig? voIPConfig`: VoIP configuration.

**ZegoNotificationVoIPConfig**

- **Properties**
  - `bool iOSVoIPHasVideo`: Whether the iOS VoIP call has video.
