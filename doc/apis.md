# APIs

- [Services](#services)
  - [ZegoUIKit](#zegouikit)
    - [init](#init)
    - [uninit](#uninit)
    - [version](#version)
    - [isInit](#isinit)
    - [setAdvanceConfigs](#setadvanceconfigs)
    - [getNetworkTime](#getnetworktime)
    - [getErrorStream](#geterrorstream)
    - [getEngineStateNotifier](#getenginestatenotifier)
    - [getEngineStateStream](#getenginestatestream)
    - [reporter](#reporter)
    - [useDebugMode](#usedebugmode)
    - [engineCreatedNotifier](#enginecreatednotifier)
  - [Audio Video](#audio-video)
    - [unmuteAllRemoteAudioVideo](#unmuteallremoteaudiovideo)
    - [muteAllRemoteAudioVideo](#muteallremoteaudiovideo)
    - [unmuteAllRemoteAudio](#unmuteallremoteaudio)
    - [muteAllRemoteAudio](#muteallremoteaudio)
    - [muteAllPlayStreamAudio](#muteallplaystreamaudio)
    - [muteUserAudioVideo](#muteuseraudiovideo)
    - [muteUserAudio](#muteuseraudio)
    - [muteUserVideo](#muteuservideo)
    - [setAudioOutputToSpeaker](#setaudiooutputtospeaker)
    - [setVideoConfig](#setvideoconfig)
    - [enableTrafficControl](#enabletrafficcontrol)
    - [startPlayingStream](#startplayingstream)
    - [stopPlayingStream](#stopplayingstream)
    - [turnCameraOn](#turncameraon)
    - [turnLocalCameraOnForPreview](#turnlocalcameraonforpreview)
    - [turnMicrophoneOn](#turnmicrophoneon)
    - [turnLocalMicrophoneOnForPreview](#turnlocalmicrophoneonforpreview)
    - [useFrontFacingCamera](#usefrontfacingcamera)
    - [enableVideoMirroring](#enablevideomirroring)
    - [stopPublishingAllStream](#stoppublishingallstream)
    - [stopPlayingAllStream](#stopplayingallstream)
    - [setPlayerResourceMode](#setplayerresourcemode)
    - [setPlayerCDNConfig](#setplayercdnconfig)
    - [enableSyncDeviceStatusBySEI](#enablesyncdevicestatusbysei)
    - [sendCustomSEI](#sendcustomsei)
    - [enableSwitchRoomNotStopPlay](#enableswitchroomnotstopplay)
    - [getAudioVideoViewNotifier](#getaudiovideoviewnotifier)
    - [getAudioVideoViewIDNotifier](#getaudiovideoviewidnotifier)
    - [getAudioVideoQualityNotifier](#getaudiovideoqualitynotifier)
    - [getAudioVideoCapturedAudioFirstFrameNotifier](#getaudiovideocapturedaudiofirstframenotifier)
    - [getAudioVideoCapturedVideoFirstFrameNotifier](#getaudiovideocapturedvideofirstframenotifier)
    - [getAudioVideoSendAudioFirstFrameNotifier](#getaudiovideosendaudiofirstframenotifier)
    - [getAudioVideoSendVideoFirstFrameNotifier](#getaudiovideosendvideofirstframenotifier)
    - [getCameraStateNotifier](#getcamerastatenotifier)
    - [getUseFrontFacingCameraStateNotifier](#getusefrontfacingcamerastatenotifier)
    - [getMicrophoneStateNotifier](#getmicrophonestatenotifier)
    - [getAudioOutputDeviceNotifier](#getaudiooutputdevicenotifier)
    - [getScreenSharingStateNotifier](#getscreensharingstatenotifier)
    - [getSoundLevelStream](#getsoundlevelstream)
    - [moveToAnotherRoom](#movetoanotherroom)
    - [copyToAnotherRoom](#copytoanotherroom)
    - [getAudioVideoListStream](#getaudiovideoliststream)
    - [getAudioVideoList](#getaudiovideolist)
    - [getScreenSharingListStream](#getscreensharingliststream)
    - [getScreenSharingList](#getscreensharinglist)
    - [getMediaListStream](#getmedialiststream)
    - [getMediaList](#getmedialist)
    - [startSharingScreen](#startsharingscreen)
    - [stopSharingScreen](#stopsharingscreen)
    - [getVideoSizeNotifier](#getvideosizenotifier)
    - [getStreamPlayerStateNotifier](#getstreamplayerstatenotifier)
    - [updateTextureRendererOrientation](#updatetexturerendererorientation)
    - [updateAppOrientation](#updateapporientation)
    - [updateVideoViewMode](#updatevideoviewmode)
    - [getReceiveSEIStream](#getreceiveseistream)
    - [getReceiveCustomSEIStream](#getreceivecustomseistream)
    - [getGeneratedStreamID](#getgeneratedstreamid)
  - [Room](#room)
    - [hasRoomLogin](#hasroomlogin)
    - [loginRoomCount](#loginroomcount)
    - [getAllRoomIDs](#getallroomids)
    - [getCurrentRoom](#getcurrentroom)
    - [joinRoom](#joinroom)
    - [leaveRoom](#leaveroom)
    - [switchRoom](#switchroom)
    - [renewRoomToken](#renewroomtoken)
    - [getRoom](#getroom)
    - [getRoomsStateStream](#getroomsstatestream)
    - [clearRoomData](#clearroomdata)
    - [getRoomStateStream](#getroomstatestream)
    - [setRoomProperty](#setroomproperty)
    - [updateRoomProperties](#updateroomproperties)
    - [getRoomProperties](#getroomproperties)
    - [getRoomPropertyStream](#getroompropertystream)
    - [getRoomPropertiesStream](#getroompropertiesstream)
    - [getRoomTokenExpiredStream](#getroomtokenexpiredstream)
    - [getNetworkStateNotifier](#getnetworkstatenotifier)
    - [getNetworkState](#getnetworkstate)
    - [getNetworkModeStream](#getnetworkmodestream)
  - [User](#user)
    - [login](#login)
    - [logout](#logout)
    - [getLocalUser](#getlocaluser)
    - [getLocalUserNotifier](#getlocalusernotifier)
    - [getAllUsers](#getallusers)
    - [getRemoteUsers](#getremoteusers)
    - [getUser](#getuser)
    - [getInRoomUserAttributesNotifier](#getinroomuserattributesnotifier)
    - [getUserListStream](#getuserliststream)
    - [getUserJoinStream](#getuserjoinstream)
    - [getUserLeaveStream](#getuserleavestream)
    - [removeUserFromRoom](#removeuserfromroom)
    - [getMeRemovedFromRoomStream](#getmeremovedfromroomstream)
  - [Channel](#channel)
    - [backToDesktop](#backtodesktop)
    - [isLockScreen](#islockscreen)
    - [checkAppRunning](#checkapprunning)
    - [activeAppToForeground](#activeapptoforeground)
    - [stopIOSPIP](#stopiospip)
    - [isIOSInPIP](#isiosinpip)
    - [enableIOSPIP](#enableiospip)
    - [updateIOSPIPSource](#updateiospipsource)
    - [enableIOSPIPAuto](#enableiospipauto)
    - [enableHardwareDecoder](#enablehardwaredecoder)
    - [enableCustomVideoRender](#enablecustomvideorender)
    - [requestDismissKeyguard](#requestdismisskeyguard)
    - [startPlayingStreamInPIP](#startplayingstreaminpip)
    - [stopPlayingStreamInPIP](#stopplayingstreaminpip)
    - [openAppSettings](#openappsettings)
    - [onWillPop](#onwillpop)
  - [Message](#message)
    - [sendInRoomMessage](#sendinroommessage)
    - [resendInRoomMessage](#resendinroommessage)
    - [getInRoomMessages](#getinroommessages)
    - [getInRoomMessageListStream](#getinroommessageliststream)
    - [getInRoomMessageStream](#getinroommessagestream)
    - [getInRoomLocalMessageStream](#getinroomlocalmessagestream)
    - [clearMessage](#clearmessage)
  - [Custom Command](#custom-command)
    - [sendInRoomCommand](#sendinroomcommand)
    - [getInRoomCommandReceivedStream](#getinroomcommandreceivedstream)
  - [Device](#device)
    - [getTurnOnYourCameraRequestStream](#getturnonyourcamerarequeststream)
    - [getTurnOnYourMicrophoneRequestStream](#getturnonyourmicrophonerequeststream)
    - [enableCustomVideoProcessing](#enablecustomvideoprocessing)
    - [getMobileSystemVersion](#getmobilesystemversion)
    - [setAudioDeviceMode](#setaudiodevicemode)
    - [getMobileSystemVersionX](#getmobilesystemversionx)
  - [Effect](#effect)
    - [enableBeauty](#enablebeauty)
    - [startEffectsEnv](#starteffectsenv)
    - [stopEffectsEnv](#stopeffectsenv)
    - [setBeautifyValue](#setbeautifyvalue)
    - [getBeautyValue](#getbeautyvalue)
    - [setVoiceChangerType](#setvoicechangertype)
    - [setReverbType](#setreverbtype)
    - [resetSoundEffect](#resetsoundeffect)
    - [resetBeautyEffect](#resetbeautyeffect)
  - [Plugin](#plugin)
    - [pluginsInstallNotifier](#pluginsinstallnotifier)
    - [installPlugins](#installplugins)
    - [uninstallPlugins](#uninstallplugins)
    - [adapterService](#adapterservice)
    - [getPlugin](#getplugin)
    - [getSignalingPlugin](#getsignalingplugin)
    - [getBeautyPlugin](#getbeautyplugin)
  - [Media](#media)
    - [registerMediaEvent](#registermediaevent)
    - [unregisterMediaEvent](#unregistermediaevent)
    - [playMedia](#playmedia)
    - [startMedia](#startmedia)
    - [stopMedia](#stopmedia)
    - [pauseMedia](#pausemedia)
    - [resumeMedia](#resumemedia)
    - [destroyMedia](#destroymedia)
    - [seekTo](#seekto)
    - [setMediaVolume](#setmediavolume)
    - [getMediaVolume](#getmediavolume)
    - [muteMediaLocal](#mutemedialocal)
    - [getMediaMuteNotifier](#getmediamutenotifier)
    - [getMediaVolumeNotifier](#getmediavolumenotifier)
    - [getMediaTotalDuration](#getmediatotalduration)
    - [getMediaCurrentProgress](#getmediacurrentprogress)
    - [getMediaCurrentProgressNotifier](#getmediacurrentprogressnotifier)
    - [getMediaType](#getmediatype)
    - [getMediaTypeNotifier](#getmediatypenotifier)
    - [getMediaPlayStateNotifier](#getmediaplaystatenotifier)
    - [pickPureAudioMediaFile](#pickpureaudiomediafile)
    - [pickVideoMediaFile](#pickvideomediafile)
    - [pickMediaFile](#pickmediafile)
    - [getMediaInfo](#getmediainfo)
  - [Mixer](#mixer)
    - [startPlayAnotherRoomAudioVideo](#startplayanotherroomaudiovideo)
    - [stopPlayAnotherRoomAudioVideo](#stopplayanotherroomaudiovideo)
    - [startMixerTask](#startmixertask)
    - [stopMixerTask](#stopmixertask)
    - [startPlayMixAudioVideo](#startplaymixaudiovideo)
    - [stopPlayMixAudioVideo](#stopplaymixaudiovideo)
    - [muteMixStreamAudioVideo](#mutemixstreamaudiovideo)
    - [muteMixStreamAudio](#mutemixstreamaudio)
    - [muteMixStreamVideo](#mutemixstreamvideo)
    - [getMixAudioVideoViewNotifier](#getmixaudiovideoviewnotifier)
    - [getMixAudioVideoSizeNotifier](#getmixaudiovideosizenotifier)
    - [getMixAudioVideoCameraStateNotifier](#getmixaudiovideocamerastatenotifier)
    - [getMixAudioVideoMicrophoneStateNotifier](#getmixaudiovideomicrophonestatenotifier)
    - [getMixAudioVideoLoadedNotifier](#getmixaudiovideoloadednotifier)
    - [getMixedSoundLevelsStream](#getmixedsoundlevelsstream)
    - [getMixedSoundLevelStream](#getmixedsoundlevelstream)
    - [getUserInMixerStream](#getuserinmixerstream)
    - [getMixerStreamUsers](#getmixerstreamusers)
    - [getMixerUserListStream](#getmixeruserliststream)
  - [Event](#event)
    - [registerExpressEvent](#registerexpressevent)
    - [unregisterExpressEvent](#unregisterexpressevent)
  - [Logger](#logger)
    - [initLog](#initlog)
    - [clearLogs](#clearlogs)
    - [exportLogs](#exportlogs)
    - [logInfo](#loginfo)
    - [logWarn](#logwarn)
    - [logError](#logerror)
    - [logErrorTrace](#logerrortrace)
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

### init

  - description

    Initializes the Zego UIKit SDK.


  - prototype

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
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | appID | Parameter appID | `int` | `Required` |
    | appSign | Parameter appSign | `String` | `` |
    | token | Parameter token | `String` | `` |
    | enablePlatformView | Parameter enablePlatformView | `bool?` | `Optional` |
    | playingStreamInPIPUnderIOS | Parameter playingStreamInPIPUnderIOS | `bool` | `false` |
    | scenario | Parameter scenario | `ZegoUIKitScenario` | `ZegoUIKitScenario.Default` |
    | withoutCreateEngine | Parameter withoutCreateEngine | `bool` | `false` |
  - example

    ```dart
    await ZegoUIKit().init(appID: 123456, appSign: 'your_app_sign');
    ```

### uninit

  - description

    Uninitializes the SDK and destroys the engine.

  - prototype

    ```dart
    Future<void> uninit()
    ```
  - example

    ```dart
    await ZegoUIKit().uninit();
    ```

### version

  - description

    Returns the current version of the Zego UIKit.

  - prototype

    ```dart
    Future<String> version()
    ```
  - example

    ```dart
    var version = await ZegoUIKit().version();
    ```

### isInit

  - description

    Check if the ZegoUIKit is initialized.

  - prototype

    ```dart
    bool get isInit
    ```
  - example

    ```dart
    var isInitialized = ZegoUIKit().isInit;
    ```

### setAdvanceConfigs

  - description

    Sets advanced engine configurations.

  - prototype

    ```dart
    Future<void> setAdvanceConfigs(Map<String, String> configs)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | configs | Parameter configs | `String>` | `Optional` |
  - example

    ```dart
    await ZegoUIKit().setAdvanceConfigs({'key': 'value'});
    ```


### getNetworkTime

  - description

    Gets the network time.

  - prototype

    ```dart
    ValueNotifier<DateTime?> getNetworkTime()
    ```
  - example

    ```dart
    ValueNotifier<DateTime?> networkTime = ZegoUIKit().getNetworkTime();
    ```

### getErrorStream

  - description

    Gets the stream of SDK errors.

  - prototype

    ```dart
    Stream<ZegoUIKitError> getErrorStream()
    ```
  - example

    ```dart
    ZegoUIKit().getErrorStream().listen((error) {
      // handle error
    });
    ```

### getEngineStateNotifier

  - description

    Gets the notifier for the engine state.

  - prototype

    ```dart
    ValueNotifier<ZegoUIKitExpressEngineState> getEngineStateNotifier()
    ```
  - example

    ```dart
    ValueNotifier<ZegoUIKitExpressEngineState> stateNotifier = ZegoUIKit().getEngineStateNotifier();
    ```

### getEngineStateStream

  - description

    Gets the stream of the engine state.

  - prototype

    ```dart
    Stream<ZegoUIKitExpressEngineState> getEngineStateStream()
    ```
  - example

    ```dart
    ZegoUIKit().getEngineStateStream().listen((state) {
      // handle state change
    });
    ```

### reporter

  - description

    Gets the reporter instance for reporting issues or feedback.

  - prototype

    ```dart
    ZegoUIKitReporter reporter()
    ```
  - example

    ```dart
    ZegoUIKit().reporter().report(event: 'custom_event');
    ```

### useDebugMode

  - description

    Gets or sets whether to use debug mode.

  - prototype

    ```dart
    bool get useDebugMode
    set useDebugMode(bool value)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | value | Parameter value | `bool` | `Optional` |
  - example

    ```dart
    ZegoUIKit().useDebugMode = true;
    ```

### engineCreatedNotifier

  - description

    Gets the notifier for when the engine is created.

  - prototype

    ```dart
    ValueNotifier<bool> get engineCreatedNotifier
    ```
  - example

    ```dart
    ValueNotifier<bool> createdNotifier = ZegoUIKit().engineCreatedNotifier;
    ```



## Audio Video

### unmuteAllRemoteAudioVideo

  - description

    Start play all audio video.

  - prototype

    ```dart
    Future<void> unmuteAllRemoteAudioVideo({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().unmuteAllRemoteAudioVideo(targetRoomID: 'room_id');
    ```

### muteAllRemoteAudioVideo

  - description

    Stop play all audio video.

  - prototype

    ```dart
    Future<void> muteAllRemoteAudioVideo({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().muteAllRemoteAudioVideo(targetRoomID: 'room_id');
    ```

### unmuteAllRemoteAudio

  - description

    Start play all audio.

  - prototype

    ```dart
    Future<void> unmuteAllRemoteAudio({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().unmuteAllRemoteAudio(targetRoomID: 'room_id');
    ```

### muteAllRemoteAudio

  - description

    Stop play all audio.

  - prototype

    ```dart
    Future<void> muteAllRemoteAudio({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().muteAllRemoteAudio(targetRoomID: 'room_id');
    ```

### muteAllPlayStreamAudio

  - description

    Mute or unmute all playing streams audio.

  - prototype

    ```dart
    Future<void> muteAllPlayStreamAudio(bool isMuted)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | isMuted | Parameter isMuted | `bool` | `Optional` |
  - example

    ```dart
    await ZegoUIKit().muteAllPlayStreamAudio(true);
    ```

### muteUserAudioVideo

  - description

    Mute or unmute a user's audio and video.

  - prototype

    ```dart
    Future<bool> muteUserAudioVideo(
      String userID,
      bool mute, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String` | `Optional` |
    | mute | Parameter mute | `bool` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().muteUserAudioVideo('user_id', true, targetRoomID: 'room_id');
    ```

### muteUserAudio

  - description

    Mute or unmute a user's audio.

  - prototype

    ```dart
    Future<bool> muteUserAudio(
      String userID,
      bool mute, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String` | `Optional` |
    | mute | Parameter mute | `bool` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().muteUserAudio('user_id', true, targetRoomID: 'room_id');
    ```

### muteUserVideo

  - description

    Mute or unmute a user's video.

  - prototype

    ```dart
    Future<bool> muteUserVideo(
      String userID,
      bool mute, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String` | `Optional` |
    | mute | Parameter mute | `bool` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().muteUserVideo('user_id', true, targetRoomID: 'room_id');
    ```

### setAudioOutputToSpeaker

  - description

    Set audio output to speaker or earpiece.

  - prototype

    ```dart
    void setAudioOutputToSpeaker(bool isSpeaker)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | isSpeaker | Parameter isSpeaker | `bool` | `Optional` |
  - example

    ```dart
    ZegoUIKit().setAudioOutputToSpeaker(true);
    ```

### setVideoConfig

  - description

    Update video configuration.

  - prototype

    ```dart
    Future<void> setVideoConfig(
      ZegoUIKitVideoConfig config, {
      ZegoStreamType streamType = ZegoStreamType.main,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | config | Parameter config | `ZegoUIKitVideoConfig` | `Optional` |
    | streamType | Parameter streamType | `ZegoStreamType` | `ZegoStreamType.main` |
  - example

    ```dart
    await ZegoUIKit().setVideoConfig(ZegoUIKitVideoConfig.preset1080p);
    ```

### enableTrafficControl

  - description

    Enable traffic control to automatically adjust video quality based on network conditions.

  - prototype

    ```dart
    Future<void> enableTrafficControl(
      bool enabled,
      List<ZegoUIKitTrafficControlProperty> properties, {
      required String targetRoomID,
      ZegoUIKitVideoConfig? minimizeVideoConfig,
      bool isFocusOnRemote = true,
      ZegoStreamType streamType = ZegoStreamType.main,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | enabled | Parameter enabled | `bool` | `Optional` |
    | properties | Parameter properties | `List<ZegoUIKitTrafficControlProperty>` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | minimizeVideoConfig | Parameter minimizeVideoConfig | `ZegoUIKitVideoConfig?` | `Optional` |
    | isFocusOnRemote | Parameter isFocusOnRemote | `bool` | `true` |
    | streamType | Parameter streamType | `ZegoStreamType` | `ZegoStreamType.main` |
  - example

    ```dart
    await ZegoUIKit().enableTrafficControl(true, [], targetRoomID: 'room_id');
    ```

### startPlayingStream

  - description

    Manually start playing a stream.

  - prototype

    ```dart
    Future<void> startPlayingStream(
      String streamID,
      String streamUserID, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | streamID | Parameter streamID | `String` | `Optional` |
    | streamUserID | Parameter streamUserID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().startPlayingStream('stream_id', 'user_id', targetRoomID: 'room_id');
    ```

### stopPlayingStream

  - description

    Manually stop playing a stream.

  - prototype

    ```dart
    Future<void> stopPlayingStream(
      String streamID, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | streamID | Parameter streamID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().stopPlayingStream('stream_id', targetRoomID: 'room_id');
    ```

### turnCameraOn

  - description

    Turn on/off camera for local or remote user.

  - prototype

    ```dart
    Future<bool> turnCameraOn(
      bool isOn, {
      String? userID,
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | isOn | Parameter isOn | `bool` | `Optional` |
    | userID | Parameter userID | `String?` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().turnCameraOn(true, targetRoomID: 'room_id');
    ```

### turnLocalCameraOnForPreview

  - description

    Turn on/off camera only for preview (not published to remote).

  - prototype

    ```dart
    void turnLocalCameraOnForPreview(bool isOn)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | isOn | Parameter isOn | `bool` | `Optional` |
  - example

    ```dart
    ZegoUIKit().turnLocalCameraOnForPreview(true);
    ```

### turnMicrophoneOn

  - description

    Turn on/off microphone for local or remote user.

  - prototype

    ```dart
    Future<bool> turnMicrophoneOn(
      bool isOn, {
      required String targetRoomID,
      String? userID,
      bool muteMode = false,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | isOn | Parameter isOn | `bool` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | userID | Parameter userID | `String?` | `Optional` |
    | muteMode | Parameter muteMode | `bool` | `false` |
  - example

    ```dart
    await ZegoUIKit().turnMicrophoneOn(true, targetRoomID: 'room_id');
    ```

### turnLocalMicrophoneOnForPreview

  - description

    Turn on/off microphone only for preview (not published to remote).

  - prototype

    ```dart
    void turnLocalMicrophoneOnForPreview({
      bool isOn,
      bool muteMode = false,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | isOn | Parameter isOn | `bool` | `Optional` |
    | muteMode | Parameter muteMode | `bool` | `false` |
  - example

    ```dart
    ZegoUIKit().turnLocalMicrophoneOnForPreview(isOn: true);
    ```

### useFrontFacingCamera

  - description

    Switch between front and back camera.

  - prototype

    ```dart
    Future<bool> useFrontFacingCamera(
      bool isFrontFacing, {
      bool ignoreCameraStatus = false,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | isFrontFacing | Parameter isFrontFacing | `bool` | `Optional` |
    | ignoreCameraStatus | Parameter ignoreCameraStatus | `bool` | `false` |
  - example

    ```dart
    await ZegoUIKit().useFrontFacingCamera(true);
    ```

### enableVideoMirroring

  - description

    Enable or disable video mirror mode.

  - prototype

    ```dart
    void enableVideoMirroring(bool isVideoMirror)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | isVideoMirror | Parameter isVideoMirror | `bool` | `Optional` |
  - example

    ```dart
    ZegoUIKit().enableVideoMirroring(true);
    ```

### stopPublishingAllStream

  - description

    Stop publishing all streams in the room.

  - prototype

    ```dart
    Future<void> stopPublishingAllStream({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().stopPublishingAllStream(targetRoomID: 'room_id');
    ```

### stopPlayingAllStream

  - description

    Stop playing all streams in the room.

  - prototype

    ```dart
    Future<void> stopPlayingAllStream({
      required String targetRoomID,
      List<String> ignoreStreamIDs = const [],
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | ignoreStreamIDs | Parameter ignoreStreamIDs | `List<String>` | `const []` |
  - example

    ```dart
    await ZegoUIKit().stopPlayingAllStream(targetRoomID: 'room_id');
    ```

### setPlayerResourceMode

  - description

    Set player resource mode (RTC or CDN).

  - prototype

    ```dart
    void setPlayerResourceMode(
      ZegoUIKitStreamResourceMode mode, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | mode | Parameter mode | `ZegoUIKitStreamResourceMode` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    ZegoUIKit().setPlayerResourceMode(ZegoUIKitStreamResourceMode.RTC, targetRoomID: 'room_id');
    ```

### setPlayerCDNConfig

  - description

    Set player CDN configuration.

  - prototype

    ```dart
    void setPlayerCDNConfig(
      ZegoUIKitCDNConfig? cdnConfig, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | cdnConfig | Parameter cdnConfig | `ZegoUIKitCDNConfig?` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    ZegoUIKit().setPlayerCDNConfig(config, targetRoomID: 'room_id');
    ```

### enableSyncDeviceStatusBySEI

  - description

    Enable synchronization of device status through SEI.

  - prototype

    ```dart
    void enableSyncDeviceStatusBySEI(bool value)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | value | Parameter value | `bool` | `Optional` |
  - example

    ```dart
    ZegoUIKit().enableSyncDeviceStatusBySEI(true);
    ```

### sendCustomSEI

  - description

    Send custom SEI data synchronized with video stream.

  - prototype

    ```dart
    Future<bool> sendCustomSEI(
      Map<String, dynamic> seiData, {
      ZegoStreamType streamType = ZegoStreamType.main,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | seiData | Parameter seiData | `dynamic>` | `Optional` |
    | streamType | Parameter streamType | `ZegoStreamType` | `ZegoStreamType.main` |
  - example

    ```dart
    await ZegoUIKit().sendCustomSEI({'key': 'value'});
    ```

### enableSwitchRoomNotStopPlay

  - description

    When enabled, switching room will not stop pulling streams.

  - prototype

    ```dart
    Future<void> enableSwitchRoomNotStopPlay(bool enabled)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | enabled | Parameter enabled | `bool` | `Optional` |
  - example

    ```dart
    await ZegoUIKit().enableSwitchRoomNotStopPlay(true);
    ```

### getAudioVideoViewNotifier

  - description

    Get audio video view notifier for a user.

  - prototype

    ```dart
    ValueNotifier<Widget?> getAudioVideoViewNotifier(
      String? userID, {
      required String targetRoomID,
      ZegoStreamType streamType = ZegoStreamType.main,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String?` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | streamType | Parameter streamType | `ZegoStreamType` | `ZegoStreamType.main` |
  - example

    ```dart
    var notifier = ZegoUIKit().getAudioVideoViewNotifier('user_id', targetRoomID: 'room_id');
    ```

### getAudioVideoViewIDNotifier

  - description

    Get audio video view ID notifier for a user.

  - prototype

    ```dart
    ValueNotifier<int?> getAudioVideoViewIDNotifier(
      String? userID, {
      required String targetRoomID,
      ZegoStreamType streamType = ZegoStreamType.main,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String?` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | streamType | Parameter streamType | `ZegoStreamType` | `ZegoStreamType.main` |
  - example

    ```dart
    var notifier = ZegoUIKit().getAudioVideoViewIDNotifier('user_id', targetRoomID: 'room_id');
    ```

### getAudioVideoQualityNotifier

  - description

    Get audio/video quality notifier for a user.

  - prototype

    ```dart
    ValueNotifier<ZegoUIKitPublishStreamQuality> getAudioVideoQualityNotifier(
      String? userID, {
      required String targetRoomID,
      ZegoStreamType streamType = ZegoStreamType.main,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String?` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | streamType | Parameter streamType | `ZegoStreamType` | `ZegoStreamType.main` |
  - example

    ```dart
    var notifier = ZegoUIKit().getAudioVideoQualityNotifier('user_id', targetRoomID: 'room_id');
    ```

### getAudioVideoCapturedAudioFirstFrameNotifier

  - description

    Get notifier for first captured audio frame.

  - prototype

    ```dart
    ValueNotifier<bool> getAudioVideoCapturedAudioFirstFrameNotifier(
      String? userID, {
      required String targetRoomID,
      ZegoStreamType streamType = ZegoStreamType.main,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String?` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | streamType | Parameter streamType | `ZegoStreamType` | `ZegoStreamType.main` |
  - example

    ```dart
    var notifier = ZegoUIKit().getAudioVideoCapturedAudioFirstFrameNotifier('user_id', targetRoomID: 'room_id');
    ```

### getAudioVideoCapturedVideoFirstFrameNotifier

  - description

    Get notifier for first captured video frame.

  - prototype

    ```dart
    ValueNotifier<bool> getAudioVideoCapturedVideoFirstFrameNotifier(
      String? userID, {
      required String targetRoomID,
      ZegoStreamType streamType = ZegoStreamType.main,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String?` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | streamType | Parameter streamType | `ZegoStreamType` | `ZegoStreamType.main` |
  - example

    ```dart
    var notifier = ZegoUIKit().getAudioVideoCapturedVideoFirstFrameNotifier('user_id', targetRoomID: 'room_id');
    ```

### getAudioVideoSendAudioFirstFrameNotifier

  - description

    Get notifier for first sent audio frame.

  - prototype

    ```dart
    ValueNotifier<bool> getAudioVideoSendAudioFirstFrameNotifier(
      String? userID, {
      required String targetRoomID,
      ZegoStreamType streamType = ZegoStreamType.main,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String?` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | streamType | Parameter streamType | `ZegoStreamType` | `ZegoStreamType.main` |
  - example

    ```dart
    var notifier = ZegoUIKit().getAudioVideoSendAudioFirstFrameNotifier('user_id', targetRoomID: 'room_id');
    ```

### getAudioVideoSendVideoFirstFrameNotifier

  - description

    Get notifier for first sent video frame.

  - prototype

    ```dart
    ValueNotifier<bool> getAudioVideoSendVideoFirstFrameNotifier(
      String? userID, {
      required String targetRoomID,
      ZegoStreamType streamType = ZegoStreamType.main,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String?` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | streamType | Parameter streamType | `ZegoStreamType` | `ZegoStreamType.main` |
  - example

    ```dart
    var notifier = ZegoUIKit().getAudioVideoSendVideoFirstFrameNotifier('user_id', targetRoomID: 'room_id');
    ```

### getCameraStateNotifier

  - description

    Get camera state notifier for a user.

  - prototype

    ```dart
    ValueNotifier<bool> getCameraStateNotifier(
      String userID, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    var notifier = ZegoUIKit().getCameraStateNotifier('user_id', targetRoomID: 'room_id');
    ```

### getUseFrontFacingCameraStateNotifier

  - description

    Get front-facing camera switch state notifier.

  - prototype

    ```dart
    ValueNotifier<bool> getUseFrontFacingCameraStateNotifier(
      String userID, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    var notifier = ZegoUIKit().getUseFrontFacingCameraStateNotifier('user_id', targetRoomID: 'room_id');
    ```

### getMicrophoneStateNotifier

  - description

    Get microphone state notifier for a user.

  - prototype

    ```dart
    ValueNotifier<bool> getMicrophoneStateNotifier(
      String userID, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    var notifier = ZegoUIKit().getMicrophoneStateNotifier('user_id', targetRoomID: 'room_id');
    ```

### getAudioOutputDeviceNotifier

  - description

    Get audio output device notifier for a user.

  - prototype

    ```dart
    ValueNotifier<ZegoUIKitAudioRoute> getAudioOutputDeviceNotifier(
      String userID, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    var notifier = ZegoUIKit().getAudioOutputDeviceNotifier('user_id', targetRoomID: 'room_id');
    ```

### getScreenSharingStateNotifier

  - description

    Get screen sharing state notifier.

  - prototype

    ```dart
    ValueNotifier<bool> getScreenSharingStateNotifier()
    ```
  - example

    ```dart
    var notifier = ZegoUIKit().getScreenSharingStateNotifier();
    ```

### getSoundLevelStream

  - description

    Get sound level stream for a user.

  - prototype

    ```dart
    Stream<double> getSoundLevelStream(
      String userID, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    ZegoUIKit().getSoundLevelStream('user_id', targetRoomID: 'room_id').listen((level) {});
    ```

### moveToAnotherRoom

  - description

    Move streams from one room to another.

  - prototype

    ```dart
    void moveToAnotherRoom({
      required String fromRoomID,
      required List<String> fromStreamIDs,
      required String toRoomID,
      required bool isFromAnotherRoom,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | fromRoomID | Parameter fromRoomID | `String` | `Required` |
    | fromStreamIDs | Parameter fromStreamIDs | `List<String>` | `Required` |
    | toRoomID | Parameter toRoomID | `String` | `Required` |
    | isFromAnotherRoom | Parameter isFromAnotherRoom | `bool` | `Required` |
  - example

    ```dart
    ZegoUIKit().moveToAnotherRoom(fromRoomID: 'room_a', fromStreamIDs: ['stream'], toRoomID: 'room_b', isFromAnotherRoom: false);
    ```

### copyToAnotherRoom

  - description

    Copy streams to another room (play on both rooms).

  - prototype

    ```dart
    void copyToAnotherRoom({
      required String fromRoomID,
      required List<String> fromStreamIDs,
      required String toRoomID,
      required bool isFromAnotherRoom,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | fromRoomID | Parameter fromRoomID | `String` | `Required` |
    | fromStreamIDs | Parameter fromStreamIDs | `List<String>` | `Required` |
    | toRoomID | Parameter toRoomID | `String` | `Required` |
    | isFromAnotherRoom | Parameter isFromAnotherRoom | `bool` | `Required` |
  - example

    ```dart
    ZegoUIKit().copyToAnotherRoom(fromRoomID: 'room_a', fromStreamIDs: ['stream'], toRoomID: 'room_b', isFromAnotherRoom: false);
    ```

### getAudioVideoListStream

  - description

    Get stream for audio/video user list updates.

  - prototype

    ```dart
    Stream<List<ZegoUIKitUser>> getAudioVideoListStream({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    ZegoUIKit().getAudioVideoListStream(targetRoomID: 'room_id').listen((users) {});
    ```

### getAudioVideoList

  - description

    Get current audio/video user list.

  - prototype

    ```dart
    List<ZegoUIKitUser> getAudioVideoList({
      required String targetRoomID,
      bool onlyTargetRoom = true,
      ZegoStreamType streamType = ZegoStreamType.main,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | onlyTargetRoom | Parameter onlyTargetRoom | `bool` | `true` |
    | streamType | Parameter streamType | `ZegoStreamType` | `ZegoStreamType.main` |
  - example

    ```dart
    var users = ZegoUIKit().getAudioVideoList(targetRoomID: 'room_id');
    ```

### getScreenSharingListStream

  - description

    Get stream for screen sharing user list updates.

  - prototype

    ```dart
    Stream<List<ZegoUIKitUser>> getScreenSharingListStream({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    ZegoUIKit().getScreenSharingListStream(targetRoomID: 'room_id').listen((users) {});
    ```

### getScreenSharingList

  - description

    Get current screen sharing user list.

  - prototype

    ```dart
    List<ZegoUIKitUser> getScreenSharingList({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    var users = ZegoUIKit().getScreenSharingList(targetRoomID: 'room_id');
    ```

### getMediaListStream

  - description

    Get stream for media player user list updates.

  - prototype

    ```dart
    Stream<List<ZegoUIKitUser>> getMediaListStream({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    ZegoUIKit().getMediaListStream(targetRoomID: 'room_id').listen((users) {});
    ```

### getMediaList

  - description

    Get current media player user list.

  - prototype

    ```dart
    List<ZegoUIKitUser> getMediaList({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    var users = ZegoUIKit().getMediaList(targetRoomID: 'room_id');
    ```

### startSharingScreen

  - description

    Start screen sharing.

  - prototype

    ```dart
    Future<void> startSharingScreen({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().startSharingScreen(targetRoomID: 'room_id');
    ```

### stopSharingScreen

  - description

    Stop screen sharing.

  - prototype

    ```dart
    Future<void> stopSharingScreen({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().stopSharingScreen(targetRoomID: 'room_id');
    ```

### getVideoSizeNotifier

  - description

    Get video size notifier for a user.

  - prototype

    ```dart
    ValueNotifier<Size> getVideoSizeNotifier(
      String userID, {
      required String targetRoomID,
      ZegoStreamType streamType = ZegoStreamType.main,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | streamType | Parameter streamType | `ZegoStreamType` | `ZegoStreamType.main` |
  - example

    ```dart
    var notifier = ZegoUIKit().getVideoSizeNotifier('user_id', targetRoomID: 'room_id');
    ```

### getStreamPlayerStateNotifier

  - description

    Get stream player state notifier for a user.

  - prototype

    ```dart
    ValueNotifier<ZegoUIKitPlayerState> getStreamPlayerStateNotifier(
      String userID, {
      required String targetRoomID,
      ZegoStreamType streamType = ZegoStreamType.main,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | streamType | Parameter streamType | `ZegoStreamType` | `ZegoStreamType.main` |
  - example

    ```dart
    var notifier = ZegoUIKit().getStreamPlayerStateNotifier('user_id', targetRoomID: 'room_id');
    ```

### updateTextureRendererOrientation

  - description

    Update texture render orientation.

  - prototype

    ```dart
    void updateTextureRendererOrientation(Orientation orientation)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | orientation | Parameter orientation | `Orientation` | `Optional` |
  - example

    ```dart
    ZegoUIKit().updateTextureRendererOrientation(Orientation.portrait);
    ```

### updateAppOrientation

  - description

    Update app orientation.

  - prototype

    ```dart
    void updateAppOrientation(DeviceOrientation orientation)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | orientation | Parameter orientation | `DeviceOrientation` | `Optional` |
  - example

    ```dart
    ZegoUIKit().updateAppOrientation(DeviceOrientation.portraitUp);
    ```

### updateVideoViewMode

  - description

    Update video view mode (aspect fill or fit).

  - prototype

    ```dart
    void updateVideoViewMode(bool useVideoViewAspectFill)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | useVideoViewAspectFill | Parameter useVideoViewAspectFill | `bool` | `Optional` |
  - example

    ```dart
    ZegoUIKit().updateVideoViewMode(true);
    ```

### getReceiveSEIStream

  - description

    Get stream for received SEI data.

  - prototype

    ```dart
    Stream<ZegoUIKitReceiveSEIEvent> getReceiveSEIStream({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    ZegoUIKit().getReceiveSEIStream(targetRoomID: 'room_id').listen((event) {});
    ```

### getReceiveCustomSEIStream

  - description

    Get stream for received custom SEI data.

  - prototype

    ```dart
    Stream<ZegoUIKitReceiveSEIEvent> getReceiveCustomSEIStream({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    ZegoUIKit().getReceiveCustomSEIStream(targetRoomID: 'room_id').listen((event) {});
    ```

### getGeneratedStreamID

  - description

    Generate stream ID for a user.

  - prototype

    ```dart
    String getGeneratedStreamID(String userID, String roomID, ZegoStreamType type)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String` | `Optional` |
    | roomID | Parameter roomID | `String` | `Optional` |
    | type | Parameter type | `ZegoStreamType` | `Optional` |
  - example

    ```dart
    var streamID = ZegoUIKit().getGeneratedStreamID('user_id', 'room_id', ZegoStreamType.main);
    ```

## Room

### hasRoomLogin

  - description

    Check if there is currently a room logged in.

  - prototype

    ```dart
    bool hasRoomLogin({bool skipHallRoom = false})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | skipHallRoom | Parameter skipHallRoom | `bool` | `false` |
  - example

    ```dart
    var hasLogin = ZegoUIKit().hasRoomLogin();
    ```

### loginRoomCount

  - description

    Get the count of logged-in rooms.

  - prototype

    ```dart
    int loginRoomCount({bool skipHallRoom = false})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | skipHallRoom | Parameter skipHallRoom | `bool` | `false` |
  - example

    ```dart
    var count = ZegoUIKit().loginRoomCount();
    ```

### getAllRoomIDs

  - description

    Get all room IDs.

  - prototype

    ```dart
    List<String> getAllRoomIDs()
    ```
  - example

    ```dart
    var roomIDs = ZegoUIKit().getAllRoomIDs();
    ```

### getCurrentRoom

  - description

    Get current room object (for single room mode).

  - prototype

    ```dart
    ZegoUIKitRoom getCurrentRoom({bool skipHallRoom = false})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | skipHallRoom | Parameter skipHallRoom | `bool` | `false` |
  - example

    ```dart
    var room = ZegoUIKit().getCurrentRoom();
    ```

### joinRoom

  - description

    Join a room.

  - prototype

    ```dart
    Future<ZegoUIKitRoomLoginResult> joinRoom(
      String roomID, {
      String token = '',
      bool markAsLargeRoom = false,
      bool keepWakeScreen = true,
      bool isSimulated = false,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | roomID | Parameter roomID | `String` | `Optional` |
    | token | Parameter token | `String` | `` |
    | markAsLargeRoom | Parameter markAsLargeRoom | `bool` | `false` |
    | keepWakeScreen | Parameter keepWakeScreen | `bool` | `true` |
    | isSimulated | Parameter isSimulated | `bool` | `false` |
  - example

    ```dart
    await ZegoUIKit().joinRoom('room_id');
    ```

### leaveRoom

  - description

    Leave a room.

  - prototype

    ```dart
    Future<ZegoUIKitRoomLogoutResult> leaveRoom({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().leaveRoom(targetRoomID: 'room_id');
    ```

### switchRoom

  - description

    Switch to another room.

  - prototype

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
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | toRoomID | Parameter toRoomID | `String` | `Required` |
    | stopPublishAllStream | Parameter stopPublishAllStream | `bool` | `Required` |
    | stopPlayAllStream | Parameter stopPlayAllStream | `bool` | `Required` |
    | token | Parameter token | `String` | `` |
    | clearStreamData | Parameter clearStreamData | `bool` | `true` |
    | clearUserData | Parameter clearUserData | `bool` | `true` |
  - example

    ```dart
    await ZegoUIKit().switchRoom(
      toRoomID: 'new_room_id',
      stopPublishAllStream: true,
      stopPlayAllStream: true,
    );
    ```

### renewRoomToken

  - description

    Renew room token.

  - prototype

    ```dart
    Future<void> renewRoomToken(String token, {required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | token | Parameter token | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().renewRoomToken('new_token', targetRoomID: 'room_id');
    ```

### getRoom

  - description

    Get room object by room ID.

  - prototype

    ```dart
    ZegoUIKitRoom getRoom({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    var room = ZegoUIKit().getRoom(targetRoomID: 'room_id');
    ```

### getRoomsStateStream

  - description

    Get room states notifier for all rooms.

  - prototype

    ```dart
    ValueNotifier<Map<String, ZegoUIKitRoomState>> getRoomsStateStream()
    ```
  - example

    ```dart
    var stateNotifier = ZegoUIKit().getRoomsStateStream();
    ```

### clearRoomData

  - description

    Clear room data and stop all streams.

  - prototype

    ```dart
    void clearRoomData({
      required String targetRoomID,
      bool stopPublishAllStream = true,
      bool stopPlayAllStream = true,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | stopPublishAllStream | Parameter stopPublishAllStream | `bool` | `true` |
    | stopPlayAllStream | Parameter stopPlayAllStream | `bool` | `true` |
  - example

    ```dart
    ZegoUIKit().clearRoomData(targetRoomID: 'room_id');
    ```

### getRoomStateStream

  - description

    Get room state notifier for a specific room.

  - prototype

    ```dart
    ValueNotifier<ZegoUIKitRoomState> getRoomStateStream({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    var stateNotifier = ZegoUIKit().getRoomStateStream(targetRoomID: 'room_id');
    ```

### setRoomProperty

  - description

    Update a single room property.

  - prototype

    ```dart
    Future<bool> setRoomProperty(
      String key,
      String value, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | key | Parameter key | `String` | `Optional` |
    | value | Parameter value | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().setRoomProperty('key', 'value', targetRoomID: 'room_id');
    ```

### updateRoomProperties

  - description

    Update multiple room properties at once.

  - prototype

    ```dart
    Future<bool> updateRoomProperties(
      Map<String, String> properties, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | properties | Parameter properties | `String>` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().updateRoomProperties({'key1': 'value1', 'key2': 'value2'}, targetRoomID: 'room_id');
    ```

### getRoomProperties

  - description

    Get all room properties.

  - prototype

    ```dart
    Map<String, RoomProperty> getRoomProperties({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    var properties = ZegoUIKit().getRoomProperties(targetRoomID: 'room_id');
    ```

### getRoomPropertyStream

  - description

    Get stream for room property changes.

  - prototype

    ```dart
    Stream<RoomProperty> getRoomPropertyStream({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    ZegoUIKit().getRoomPropertyStream(targetRoomID: 'room_id').listen((property) {});
    ```

### getRoomPropertiesStream

  - description

    Get stream for all room properties updates.

  - prototype

    ```dart
    Stream<Map<String, RoomProperty>> getRoomPropertiesStream({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    ZegoUIKit().getRoomPropertiesStream(targetRoomID: 'room_id').listen((properties) {});
    ```

### getRoomTokenExpiredStream

  - description

    Get stream for room token expiration warning (30 seconds before expiry).

  - prototype

    ```dart
    Stream<int> getRoomTokenExpiredStream({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    ZegoUIKit().getRoomTokenExpiredStream(targetRoomID: 'room_id').listen((time) {});
    ```

### getNetworkStateNotifier

  - description

    Get network state notifier.

  - prototype

    ```dart
    ValueNotifier<ZegoUIKitNetworkState> getNetworkStateNotifier()
    ```
  - example

    ```dart
    var notifier = ZegoUIKit().getNetworkStateNotifier();
    ```

### getNetworkState

  - description

    Get current network state.

  - prototype

    ```dart
    ZegoUIKitNetworkState getNetworkState()
    ```
  - example

    ```dart
    var state = ZegoUIKit().getNetworkState();
    ```

### getNetworkModeStream

  - description

    Get stream for network mode changes.

  - prototype

    ```dart
    Stream<ZegoUIKitNetworkState> getNetworkModeStream()
    ```
  - example

    ```dart
    ZegoUIKit().getNetworkModeStream().listen((state) {});
    ```

## User

### login

  - description

    Login user.

  - prototype

    ```dart
    void login(String id, String name)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | id | Parameter id | `String` | `Optional` |
    | name | Parameter name | `String` | `Optional` |
  - example

    ```dart
    ZegoUIKit().login('user_id', 'user_name');
    ```

### logout

  - description

    Logout user.

  - prototype

    ```dart
    void logout()
    ```
  - example

    ```dart
    ZegoUIKit().logout();
    ```

### getLocalUser

  - description

    Get local user object.

  - prototype

    ```dart
    ZegoUIKitUser getLocalUser()
    ```
  - example

    ```dart
    var user = ZegoUIKit().getLocalUser();
    ```

### getLocalUserNotifier

  - description

    Get local user update notifier.

  - prototype

    ```dart
    ValueNotifier<ZegoUIKitUser> getLocalUserNotifier()
    ```
  - example

    ```dart
    var notifier = ZegoUIKit().getLocalUserNotifier();
    ```

### getAllUsers

  - description

    Get all users (local and remote).

  - prototype

    ```dart
    List<ZegoUIKitUser> getAllUsers({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    var users = ZegoUIKit().getAllUsers(targetRoomID: 'room_id');
    ```

### getRemoteUsers

  - description

    Get remote users.

  - prototype

    ```dart
    List<ZegoUIKitUser> getRemoteUsers({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    var users = ZegoUIKit().getRemoteUsers(targetRoomID: 'room_id');
    ```

### getUser

  - description

    Get user by ID.

  - prototype

    ```dart
    ZegoUIKitUser getUser(String userID, {required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    var user = ZegoUIKit().getUser('user_id', targetRoomID: 'room_id');
    ```

### getInRoomUserAttributesNotifier

  - description

    Get notifier of in-room user attributes.

  - prototype

    ```dart
    ValueNotifier<ZegoUIKitUserAttributes> getInRoomUserAttributesNotifier(
      String userID, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    var notifier = ZegoUIKit().getInRoomUserAttributesNotifier('user_id', targetRoomID: 'room_id');
    ```

### getUserListStream

  - description

    Get user list stream.

  - prototype

    ```dart
    Stream<List<ZegoUIKitUser>> getUserListStream({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    ZegoUIKit().getUserListStream(targetRoomID: 'room_id').listen((users) {});
    ```

### getUserJoinStream

  - description

    Get user join stream.

  - prototype

    ```dart
    Stream<List<ZegoUIKitUser>> getUserJoinStream({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    ZegoUIKit().getUserJoinStream(targetRoomID: 'room_id').listen((users) {});
    ```

### getUserLeaveStream

  - description

    Get user leave stream.

  - prototype

    ```dart
    Stream<List<ZegoUIKitUser>> getUserLeaveStream({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    ZegoUIKit().getUserLeaveStream(targetRoomID: 'room_id').listen((users) {});
    ```

### removeUserFromRoom

  - description

    Remove user from room (kick out).

  - prototype

    ```dart
    Future<bool> removeUserFromRoom(List<String> userIDs, {required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userIDs | Parameter userIDs | `List<String>` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().removeUserFromRoom(['user_id'], targetRoomID: 'room_id');
    ```

### getMeRemovedFromRoomStream

  - description

    Get stream for when current user is removed from room.

  - prototype

    ```dart
    Stream<String> getMeRemovedFromRoomStream({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    ZegoUIKit().getMeRemovedFromRoomStream(targetRoomID: 'room_id').listen((data) {});
    ```

## Channel

### backToDesktop

  - description

    Back to desktop (Android).

  - prototype

    ```dart
    Future<void> backToDesktop({bool nonRoot = false})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | nonRoot | Parameter nonRoot | `bool` | `false` |
  - example

    ```dart
    await ZegoUIKit().backToDesktop();
    ```

### isLockScreen

  - description

    Check if screen is locked.

  - prototype

    ```dart
    Future<bool> isLockScreen()
    ```
  - example

    ```dart
    var isLocked = await ZegoUIKit().isLockScreen();
    ```

### checkAppRunning

  - description

    Check if app is running.

  - prototype

    ```dart
    Future<bool> checkAppRunning()
    ```
  - example

    ```dart
    var isRunning = await ZegoUIKit().checkAppRunning();
    ```

### activeAppToForeground

  - description

    Bring app to foreground.

  - prototype

    ```dart
    Future<void> activeAppToForeground()
    ```
  - example

    ```dart
    await ZegoUIKit().activeAppToForeground();
    ```

### stopIOSPIP

  - description

    Stop iOS PIP.

  - prototype

    ```dart
    Future<bool> stopIOSPIP()
    ```
  - example

    ```dart
    await ZegoUIKit().stopIOSPIP();
    ```

### isIOSInPIP

  - description

    Check if iOS is in PIP mode.

  - prototype

    ```dart
    Future<bool> isIOSInPIP()
    ```
  - example

    ```dart
    var inPIP = await ZegoUIKit().isIOSInPIP();
    ```

### enableIOSPIP

  - description

    Enable iOS PIP.

  - prototype

    ```dart
    Future<void> enableIOSPIP(
      String streamID, {
      int aspectWidth = 9,
      int aspectHeight = 16,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | streamID | Parameter streamID | `String` | `Optional` |
    | aspectWidth | Parameter aspectWidth | `int` | `9` |
    | aspectHeight | Parameter aspectHeight | `int` | `16` |
  - example

    ```dart
    await ZegoUIKit().enableIOSPIP('stream_id');
    ```

### updateIOSPIPSource

  - description

    Update iOS PIP source.

  - prototype

    ```dart
    Future<void> updateIOSPIPSource(String streamID)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | streamID | Parameter streamID | `String` | `Optional` |
  - example

    ```dart
    await ZegoUIKit().updateIOSPIPSource('stream_id');
    ```

### enableIOSPIPAuto

  - description

    Enable iOS PIP auto mode.

  - prototype

    ```dart
    Future<void> enableIOSPIPAuto(
      bool isEnabled, {
      int aspectWidth = 9,
      int aspectHeight = 16,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | isEnabled | Parameter isEnabled | `bool` | `Optional` |
    | aspectWidth | Parameter aspectWidth | `int` | `9` |
    | aspectHeight | Parameter aspectHeight | `int` | `16` |
  - example

    ```dart
    await ZegoUIKit().enableIOSPIPAuto(true);
    ```

### enableHardwareDecoder

  - description

    Enable hardware decoder.

  - prototype

    ```dart
    Future<void> enableHardwareDecoder(bool isEnabled)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | isEnabled | Parameter isEnabled | `bool` | `Optional` |
  - example

    ```dart
    await ZegoUIKit().enableHardwareDecoder(true);
    ```

### enableCustomVideoRender

  - description

    Enable custom video render.

  - prototype

    ```dart
    Future<void> enableCustomVideoRender(bool isEnabled)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | isEnabled | Parameter isEnabled | `bool` | `Optional` |
  - example

    ```dart
    await ZegoUIKit().enableCustomVideoRender(true);
    ```

### requestDismissKeyguard

  - description

    Request to dismiss keyguard (unlock screen).

  - prototype

    ```dart
    Future<void> requestDismissKeyguard()
    ```
  - example

    ```dart
    await ZegoUIKit().requestDismissKeyguard();
    ```

### startPlayingStreamInPIP

  - description

    Start playing stream in Picture-in-Picture mode.

  - prototype

    ```dart
    Future<void> startPlayingStreamInPIP(String streamID)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | streamID | Parameter streamID | `String` | `Optional` |
  - example

    ```dart
    await ZegoUIKit().startPlayingStreamInPIP('stream_id');
    ```

### stopPlayingStreamInPIP

  - description

    Stop playing stream in Picture-in-Picture mode.

  - prototype

    ```dart
    Future<void> stopPlayingStreamInPIP(String streamID)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | streamID | Parameter streamID | `String` | `Optional` |
  - example

    ```dart
    await ZegoUIKit().stopPlayingStreamInPIP('stream_id');
    ```

### openAppSettings

  - description

    Open app settings page.

  - prototype

    ```dart
    Future<void> openAppSettings()
    ```
  - example

    ```dart
    await ZegoUIKit().openAppSettings();
    ```

### onWillPop

  - description

    Handle back navigation (Android specific).

  - prototype

    ```dart
    Future<bool> onWillPop(BuildContext context)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | context | Parameter context | `BuildContext` | `Optional` |
  - example

    ```dart
    await ZegoUIKit().onWillPop(context);
    ```

## Message

### sendInRoomMessage

  - description

    Send in-room message.

  - prototype

    ```dart
    Future<bool> sendInRoomMessage(
      String message, {
      required String targetRoomID,
      ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | message | Parameter message | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | type | Parameter type | `ZegoInRoomMessageType` | `ZegoInRoomMessageType.broadcastMessage` |
  - example

    ```dart
    await ZegoUIKit().sendInRoomMessage('hello', targetRoomID: 'room_id');
    ```

### resendInRoomMessage

  - description

    Resend in-room message.

  - prototype

    ```dart
    Future<bool> resendInRoomMessage(
      ZegoInRoomMessage message, {
      required String targetRoomID,
      ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | message | Parameter message | `ZegoInRoomMessage` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | type | Parameter type | `ZegoInRoomMessageType` | `ZegoInRoomMessageType.broadcastMessage` |
  - example

    ```dart
    await ZegoUIKit().resendInRoomMessage(message, targetRoomID: 'room_id');
    ```

### getInRoomMessages

  - description

    Get history messages.

  - prototype

    ```dart
    List<ZegoInRoomMessage> getInRoomMessages({
      required String targetRoomID,
      ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | type | Parameter type | `ZegoInRoomMessageType` | `ZegoInRoomMessageType.broadcastMessage` |
  - example

    ```dart
    var messages = ZegoUIKit().getInRoomMessages(targetRoomID: 'room_id');
    ```

### getInRoomMessageListStream

  - description

    Get messages list stream.

  - prototype

    ```dart
    Stream<List<ZegoInRoomMessage>> getInRoomMessageListStream({
      required String targetRoomID,
      ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | type | Parameter type | `ZegoInRoomMessageType` | `ZegoInRoomMessageType.broadcastMessage` |
  - example

    ```dart
    ZegoUIKit().getInRoomMessageListStream(targetRoomID: 'room_id').listen((messages) {});
    ```

### getInRoomMessageStream

  - description

    Get latest message received stream.

  - prototype

    ```dart
    Stream<ZegoInRoomMessage> getInRoomMessageStream({
      required String targetRoomID,
      ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | type | Parameter type | `ZegoInRoomMessageType` | `ZegoInRoomMessageType.broadcastMessage` |
  - example

    ```dart
    ZegoUIKit().getInRoomMessageStream(targetRoomID: 'room_id').listen((message) {});
    ```

### getInRoomLocalMessageStream

  - description

    Get stream for locally sent messages.

  - prototype

    ```dart
    Stream<ZegoInRoomMessage> getInRoomLocalMessageStream({
      required String targetRoomID,
      ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | type | Parameter type | `ZegoInRoomMessageType` | `ZegoInRoomMessageType.broadcastMessage` |
  - example

    ```dart
    ZegoUIKit().getInRoomLocalMessageStream(targetRoomID: 'room_id').listen((message) {});
    ```

### clearMessage

  - description

    Clear messages in the room.

  - prototype

    ```dart
    Future<bool> clearMessage({
      required String targetRoomID,
      ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
      bool clearRemote = true,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | type | Parameter type | `ZegoInRoomMessageType` | `ZegoInRoomMessageType.broadcastMessage` |
    | clearRemote | Parameter clearRemote | `bool` | `true` |
  - example

    ```dart
    await ZegoUIKit().clearMessage(targetRoomID: 'room_id');
    ```

## Custom Command

### sendInRoomCommand

  - description

    Send in-room command.

  - prototype

    ```dart
    Future<bool> sendInRoomCommand(
      String command,
      List<String> toUserIDs, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | command | Parameter command | `String` | `Optional` |
    | toUserIDs | Parameter toUserIDs | `List<String>` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().sendInRoomCommand('command', [], targetRoomID: 'room_id');
    ```

### getInRoomCommandReceivedStream

  - description

    Get in-room command received stream.

  - prototype

    ```dart
    Stream<ZegoInRoomCommandReceivedData> getInRoomCommandReceivedStream()
    ```
  - example

    ```dart
    ZegoUIKit().getInRoomCommandReceivedStream().listen((data) {});
    ```

## Device

### getTurnOnYourCameraRequestStream

  - description

    Get stream for "Turn on your camera" requests.

  - prototype

    ```dart
    Stream<String> getTurnOnYourCameraRequestStream({required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    ZegoUIKit().getTurnOnYourCameraRequestStream(targetRoomID: 'room_id').listen((userID) {});
    ```

### getTurnOnYourMicrophoneRequestStream

  - description

    Get stream for "Turn on your microphone" requests.

  - prototype

    ```dart
    Stream<ZegoUIKitReceiveTurnOnLocalMicrophoneEvent> getTurnOnYourMicrophoneRequestStream({
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    ZegoUIKit().getTurnOnYourMicrophoneRequestStream(targetRoomID: 'room_id').listen((event) {});
    ```

### enableCustomVideoProcessing

  - description

    Enable custom video processing.

  - prototype

    ```dart
    Future<void> enableCustomVideoProcessing(bool enable)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | enable | Parameter enable | `bool` | `Optional` |
  - example

    ```dart
    await ZegoUIKit().enableCustomVideoProcessing(true);
    ```

### getMobileSystemVersion

  - description

    Get mobile system version.

  - prototype

    ```dart
    ZegoMobileSystemVersion getMobileSystemVersion()
    ```
  - example

    ```dart
    var version = ZegoUIKit().getMobileSystemVersion();
    ```

### setAudioDeviceMode

  - description

    Set audio device mode.

  - prototype

    ```dart
    Future<void> setAudioDeviceMode(ZegoUIKitAudioDeviceMode deviceMode)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | deviceMode | Parameter deviceMode | `ZegoUIKitAudioDeviceMode` | `Optional` |
  - example

    ```dart
    await ZegoUIKit().setAudioDeviceMode(ZegoUIKitAudioDeviceMode.General);
    ```

### getMobileSystemVersionX

  - description

    Get mobile system version (extended version parsing).

  - prototype

    ```dart
    ZegoMobileSystemVersion getMobileSystemVersionX()
    ```
  - example

    ```dart
    var version = ZegoUIKit().getMobileSystemVersionX();
    ```

## Effect

### enableBeauty

  - description

    Enable beauty effect.

  - prototype

    ```dart
    Future<void> enableBeauty(bool isOn)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | isOn | Parameter isOn | `bool` | `Optional` |
  - example

    ```dart
    await ZegoUIKit().enableBeauty(true);
    ```

### startEffectsEnv

  - description

    Start effects environment.

  - prototype

    ```dart
    Future<void> startEffectsEnv()
    ```
  - example

    ```dart
    await ZegoUIKit().startEffectsEnv();
    ```

### stopEffectsEnv

  - description

    Stop effects environment.

  - prototype

    ```dart
    Future<void> stopEffectsEnv()
    ```
  - example

    ```dart
    await ZegoUIKit().stopEffectsEnv();
    ```

### setBeautifyValue

  - description

    Set intensity of specific face beautify feature.

  - prototype

    ```dart
    void setBeautifyValue(int value, BeautyEffectType type)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | value | Parameter value | `int` | `Optional` |
    | type | Parameter type | `BeautyEffectType` | `Optional` |
  - example

    ```dart
    ZegoUIKit().setBeautifyValue(50, BeautyEffectType.whiten);
    ```

### getBeautyValue

  - description

    Get current beauty parameters.

  - prototype

    ```dart
    ZegoEffectsBeautyParam getBeautyValue()
    ```
  - example

    ```dart
    var params = ZegoUIKit().getBeautyValue();
    ```

### setVoiceChangerType

  - description

    Set voice changer type.

  - prototype

    ```dart
    void setVoiceChangerType(ZegoVoiceChangerPreset voicePreset)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | voicePreset | Parameter voicePreset | `ZegoVoiceChangerPreset` | `Optional` |
  - example

    ```dart
    ZegoUIKit().setVoiceChangerType(ZegoVoiceChangerPreset.Robot);
    ```

### setReverbType

  - description

    Set reverb type.

  - prototype

    ```dart
    void setReverbType(ZegoReverbPreset reverbPreset)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | reverbPreset | Parameter reverbPreset | `ZegoReverbPreset` | `Optional` |
  - example

    ```dart
    ZegoUIKit().setReverbType(ZegoReverbPreset.KTV);
    ```

### resetSoundEffect

  - description

    Reset sound effects (voice changer and reverb).

  - prototype

    ```dart
    Future<void> resetSoundEffect()
    ```
  - example

    ```dart
    await ZegoUIKit().resetSoundEffect();
    ```

### resetBeautyEffect

  - description

    Reset beauty effect to default values.

  - prototype

    ```dart
    Future<void> resetBeautyEffect()
    ```
  - example

    ```dart
    await ZegoUIKit().resetBeautyEffect();
    ```

## Plugin

### pluginsInstallNotifier

  - description

    Get installed plugins notifier.

  - prototype

    ```dart
    ValueNotifier<List<ZegoUIKitPluginType>> pluginsInstallNotifier()
    ```
  - example

    ```dart
    var notifier = ZegoUIKit().pluginsInstallNotifier();
    ```

### installPlugins

  - description

    Install plugins.

  - prototype

    ```dart
    void installPlugins(List<IZegoUIKitPlugin> plugins)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | plugins | Parameter plugins | `List<IZegoUIKitPlugin>` | `Optional` |
  - example

    ```dart
    ZegoUIKit().installPlugins([plugin1, plugin2]);
    ```

### uninstallPlugins

  - description

    Uninstall plugins.

  - prototype

    ```dart
    void uninstallPlugins(List<IZegoUIKitPlugin> plugins)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | plugins | Parameter plugins | `List<IZegoUIKitPlugin>` | `Optional` |
  - example

    ```dart
    ZegoUIKit().uninstallPlugins([plugin1]);
    ```

### adapterService

  - description

    Get adapter service.

  - prototype

    ```dart
    ZegoPluginAdapterService adapterService()
    ```
  - example

    ```dart
    var service = ZegoUIKit().adapterService();
    ```

### getPlugin

  - description

    Get plugin object by type.

  - prototype

    ```dart
    IZegoUIKitPlugin? getPlugin(ZegoUIKitPluginType type)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | type | Parameter type | `ZegoUIKitPluginType` | `Optional` |
  - example

    ```dart
    var plugin = ZegoUIKit().getPlugin(ZegoUIKitPluginType.beauty);
    ```

### getSignalingPlugin

  - description

    Get signaling plugin instance.

  - prototype

    ```dart
    ZegoUIKitSignalingPluginImpl getSignalingPlugin()
    ```
  - example

    ```dart
    var plugin = ZegoUIKit().getSignalingPlugin();
    ```

### getBeautyPlugin

  - description

    Get beauty plugin instance.

  - prototype

    ```dart
    ZegoUIKitBeautyPluginImpl getBeautyPlugin()
    ```
  - example

    ```dart
    var plugin = ZegoUIKit().getBeautyPlugin();
    ```

## Media

### registerMediaEvent

  - description

    Register media event.

  - prototype

    ```dart
    void registerMediaEvent(ZegoUIKitMediaEventInterface event)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | event | Parameter event | `ZegoUIKitMediaEventInterface` | `Optional` |
  - example

    ```dart
    ZegoUIKit().registerMediaEvent(eventImpl);
    ```

### unregisterMediaEvent

  - description

    Unregister media event.

  - prototype

    ```dart
    void unregisterMediaEvent(ZegoUIKitMediaEventInterface event)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | event | Parameter event | `ZegoUIKitMediaEventInterface` | `Optional` |
  - example

    ```dart
    ZegoUIKit().unregisterMediaEvent(eventImpl);
    ```

### playMedia

  - description

    Start playing media.

  - prototype

    ```dart
    Future<ZegoUIKitMediaPlayResult> playMedia({
      required String filePathOrURL,
      bool enableRepeat = false,
      bool autoStart = true,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | filePathOrURL | Parameter filePathOrURL | `String` | `Required` |
    | enableRepeat | Parameter enableRepeat | `bool` | `false` |
    | autoStart | Parameter autoStart | `bool` | `true` |
  - example

    ```dart
    await ZegoUIKit().playMedia(filePathOrURL: 'path/to/file');
    ```

### startMedia

  - description

    Start media.

  - prototype

    ```dart
    Future<void> startMedia()
    ```
  - example

    ```dart
    await ZegoUIKit().startMedia();
    ```

### stopMedia

  - description

    Stop media.

  - prototype

    ```dart
    Future<void> stopMedia()
    ```
  - example

    ```dart
    await ZegoUIKit().stopMedia();
    ```

### pauseMedia

  - description

    Pause media.

  - prototype

    ```dart
    Future<void> pauseMedia()
    ```
  - example

    ```dart
    await ZegoUIKit().pauseMedia();
    ```

### resumeMedia

  - description

    Resume media.

  - prototype

    ```dart
    Future<void> resumeMedia()
    ```
  - example

    ```dart
    await ZegoUIKit().resumeMedia();
    ```

### destroyMedia

  - description

    Destroy media.

  - prototype

    ```dart
    Future<void> destroyMedia()
    ```
  - example

    ```dart
    await ZegoUIKit().destroyMedia();
    ```

### seekTo

  - description

    Seek to specific time.

  - prototype

    ```dart
    Future<ZegoUIKitMediaSeekToResult> seekTo(int millisecond)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | millisecond | Parameter millisecond | `int` | `Optional` |
  - example

    ```dart
    await ZegoUIKit().seekTo(1000);
    ```

### setMediaVolume

  - description

    Set media volume.

  - prototype

    ```dart
    Future<void> setMediaVolume(int volume, {bool isSyncToRemote = false})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | volume | Parameter volume | `int` | `Optional` |
    | isSyncToRemote | Parameter isSyncToRemote | `bool` | `false` |
  - example

    ```dart
    await ZegoUIKit().setMediaVolume(50);
    ```

### getMediaVolume

  - description

    Get media volume.

  - prototype

    ```dart
    int getMediaVolume()
    ```
  - example

    ```dart
    var volume = ZegoUIKit().getMediaVolume();
    ```

### muteMediaLocal

  - description

    Mute or unmute media locally.

  - prototype

    ```dart
    Future<void> muteMediaLocal(bool mute)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | mute | Parameter mute | `bool` | `Optional` |
  - example

    ```dart
    await ZegoUIKit().muteMediaLocal(true);
    ```

### getMediaMuteNotifier

  - description

    Get media mute state notifier.

  - prototype

    ```dart
    ValueNotifier<bool> getMediaMuteNotifier()
    ```
  - example

    ```dart
    var notifier = ZegoUIKit().getMediaMuteNotifier();
    ```

### getMediaVolumeNotifier

  - description

    Get media volume notifier.

  - prototype

    ```dart
    ValueNotifier<int> getMediaVolumeNotifier()
    ```
  - example

    ```dart
    var notifier = ZegoUIKit().getMediaVolumeNotifier();
    ```

### getMediaTotalDuration

  - description

    Get total duration of media in milliseconds.

  - prototype

    ```dart
    int getMediaTotalDuration()
    ```
  - example

    ```dart
    var duration = ZegoUIKit().getMediaTotalDuration();
    ```

### getMediaCurrentProgress

  - description

    Get current playing progress in milliseconds.

  - prototype

    ```dart
    int getMediaCurrentProgress()
    ```
  - example

    ```dart
    var progress = ZegoUIKit().getMediaCurrentProgress();
    ```

### getMediaCurrentProgressNotifier

  - description

    Get current playing progress notifier.

  - prototype

    ```dart
    ValueNotifier<int> getMediaCurrentProgressNotifier()
    ```
  - example

    ```dart
    var notifier = ZegoUIKit().getMediaCurrentProgressNotifier();
    ```

### getMediaType

  - description

    Get media type.

  - prototype

    ```dart
    ZegoUIKitMediaType getMediaType()
    ```
  - example

    ```dart
    var type = ZegoUIKit().getMediaType();
    ```

### getMediaTypeNotifier

  - description

    Get media type notifier.

  - prototype

    ```dart
    ValueNotifier<ZegoUIKitMediaType> getMediaTypeNotifier()
    ```
  - example

    ```dart
    var notifier = ZegoUIKit().getMediaTypeNotifier();
    ```

### getMediaPlayStateNotifier

  - description

    Get media play state notifier.

  - prototype

    ```dart
    ValueNotifier<ZegoUIKitMediaPlayState> getMediaPlayStateNotifier()
    ```
  - example

    ```dart
    var notifier = ZegoUIKit().getMediaPlayStateNotifier();
    ```

### pickPureAudioMediaFile

  - description

    Pick pure audio media file from device.

  - prototype

    ```dart
    Future<List<ZegoUIKitPlatformFile>> pickPureAudioMediaFile()
    ```
  - example

    ```dart
    var files = await ZegoUIKit().pickPureAudioMediaFile();
    ```

### pickVideoMediaFile

  - description

    Pick video media file from device.

  - prototype

    ```dart
    Future<List<ZegoUIKitPlatformFile>> pickVideoMediaFile()
    ```
  - example

    ```dart
    var files = await ZegoUIKit().pickVideoMediaFile();
    ```

### pickMediaFile

  - description

    Pick media file (audio or video) from device.

  - prototype

    ```dart
    Future<List<ZegoUIKitPlatformFile>> pickMediaFile({
      List<String>? allowedExtensions,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | allowedExtensions | Parameter allowedExtensions | `List<String>?` | `Optional` |
  - example

    ```dart
    var files = await ZegoUIKit().pickMediaFile();
    ```

### getMediaInfo

  - description

    Get media player information.

  - prototype

    ```dart
    ZegoUIKitMediaPlayerMediaInfo getMediaInfo()
    ```
  - example

    ```dart
    var info = ZegoUIKit().getMediaInfo();
    ```

## Mixer

### startPlayAnotherRoomAudioVideo

  - description

    Start playing a user's audio & video stream from another room.

  - prototype

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
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | anotherRoomID | Parameter anotherRoomID | `String` | `Optional` |
    | anotherUserID | Parameter anotherUserID | `String` | `Optional` |
    | streamType | Parameter streamType | `ZegoStreamType` | `ZegoStreamType.main` |
    | anotherUserName | Parameter anotherUserName | `String` | `` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | playOnAnotherRoom | Parameter playOnAnotherRoom | `bool` | `Required` |
    | onPlayerStateUpdated | Parameter onPlayerStateUpdated | `PlayerStateUpdateCallback?` | `Optional` |
  - example

    ```dart
    await ZegoUIKit().startPlayAnotherRoomAudioVideo('room_b', 'user_b', targetRoomID: 'room_a', playOnAnotherRoom: true);
    ```

### stopPlayAnotherRoomAudioVideo

  - description

    Stop playing a user's audio & video stream from another room.

  - prototype

    ```dart
    Future<void> stopPlayAnotherRoomAudioVideo(
      String userID, {
      required String targetRoomID,
      ZegoStreamType streamType = ZegoStreamType.main,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | streamType | Parameter streamType | `ZegoStreamType` | `ZegoStreamType.main` |
  - example

    ```dart
    await ZegoUIKit().stopPlayAnotherRoomAudioVideo('user_b', targetRoomID: 'room_a');
    ```

### startMixerTask

  - description

    Start a mixer task.

  - prototype

    ```dart
    Future<ZegoMixerStartResult> startMixerTask(ZegoMixerTask task)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | task | Parameter task | `ZegoMixerTask` | `Optional` |
  - example

    ```dart
    await ZegoUIKit().startMixerTask(task);
    ```

### stopMixerTask

  - description

    Stop a mixer task.

  - prototype

    ```dart
    Future<ZegoMixerStopResult> stopMixerTask(ZegoMixerTask task)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | task | Parameter task | `ZegoMixerTask` | `Optional` |
  - example

    ```dart
    await ZegoUIKit().stopMixerTask(task);
    ```

### startPlayMixAudioVideo

  - description

    Start playing a mixed audio & video stream.

  - prototype

    ```dart
    Future<void> startPlayMixAudioVideo(
      String mixerStreamID, {
      required String targetRoomID,
      List<ZegoUIKitUser> users = const [],
      Map<String, int> userSoundIDs = const {},
      PlayerStateUpdateCallback? onPlayerStateUpdated,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | mixerStreamID | Parameter mixerStreamID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
    | users | Parameter users | `List<ZegoUIKitUser>` | `const []` |
    | userSoundIDs | Parameter userSoundIDs | `int>` | `const {}` |
    | onPlayerStateUpdated | Parameter onPlayerStateUpdated | `PlayerStateUpdateCallback?` | `Optional` |
  - example

    ```dart
    await ZegoUIKit().startPlayMixAudioVideo('mixer_stream_id', targetRoomID: 'room_id');
    ```

### stopPlayMixAudioVideo

  - description

    Stop playing a mixed audio & video stream.

  - prototype

    ```dart
    Future<void> stopPlayMixAudioVideo(String mixerStreamID, {required String targetRoomID})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | mixerStreamID | Parameter mixerStreamID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().stopPlayMixAudioVideo('mixer_stream_id', targetRoomID: 'room_id');
    ```

### muteMixStreamAudioVideo

  - description

    Mute or unmute both audio and video for a mixed stream.

  - prototype

    ```dart
    Future<void> muteMixStreamAudioVideo(
      String mixerStreamID,
      bool mute, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | mixerStreamID | Parameter mixerStreamID | `String` | `Optional` |
    | mute | Parameter mute | `bool` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().muteMixStreamAudioVideo('mixer_stream_id', true, targetRoomID: 'room_id');
    ```

### muteMixStreamAudio

  - description

    Mute or unmute audio for a mixed stream.

  - prototype

    ```dart
    Future<void> muteMixStreamAudio(
      String mixerStreamID,
      bool mute, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | mixerStreamID | Parameter mixerStreamID | `String` | `Optional` |
    | mute | Parameter mute | `bool` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().muteMixStreamAudio('mixer_stream_id', true, targetRoomID: 'room_id');
    ```

### muteMixStreamVideo

  - description

    Mute or unmute video for a mixed stream.

  - prototype

    ```dart
    Future<void> muteMixStreamVideo(
      String mixerStreamID,
      bool mute, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | mixerStreamID | Parameter mixerStreamID | `String` | `Optional` |
    | mute | Parameter mute | `bool` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKit().muteMixStreamVideo('mixer_stream_id', true, targetRoomID: 'room_id');
    ```

### getMixAudioVideoViewNotifier

  - description

    Get the view notifier for a mixed audio & video stream.

  - prototype

    ```dart
    ValueNotifier<Widget?> getMixAudioVideoViewNotifier(
      String mixerID, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | mixerID | Parameter mixerID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    var notifier = ZegoUIKit().getMixAudioVideoViewNotifier('mixer_id', targetRoomID: 'room_id');
    ```

### getMixAudioVideoSizeNotifier

  - description

    Get the video size notifier for a mixed audio & video stream.

  - prototype

    ```dart
    ValueNotifier<Size> getMixAudioVideoSizeNotifier(
      String mixerID, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | mixerID | Parameter mixerID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    var notifier = ZegoUIKit().getMixAudioVideoSizeNotifier('mixer_id', targetRoomID: 'room_id');
    ```

### getMixAudioVideoCameraStateNotifier

  - description

    Get the camera state notifier of a specific user in a mixed stream.

  - prototype

    ```dart
    ValueNotifier<bool> getMixAudioVideoCameraStateNotifier(
      String mixerID,
      String userID, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | mixerID | Parameter mixerID | `String` | `Optional` |
    | userID | Parameter userID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    var notifier = ZegoUIKit().getMixAudioVideoCameraStateNotifier('mixer_id', 'user_id', targetRoomID: 'room_id');
    ```

### getMixAudioVideoMicrophoneStateNotifier

  - description

    Get the microphone state notifier of a specific user in a mixed stream.

  - prototype

    ```dart
    ValueNotifier<bool> getMixAudioVideoMicrophoneStateNotifier(
      String mixerID,
      String userID, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | mixerID | Parameter mixerID | `String` | `Optional` |
    | userID | Parameter userID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    var notifier = ZegoUIKit().getMixAudioVideoMicrophoneStateNotifier('mixer_id', 'user_id', targetRoomID: 'room_id');
    ```

### getMixAudioVideoLoadedNotifier

  - description

    Get the loading-complete state notifier for a mixed stream.

  - prototype

    ```dart
    ValueNotifier<bool> getMixAudioVideoLoadedNotifier(
      String mixerID, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | mixerID | Parameter mixerID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    var notifier = ZegoUIKit().getMixAudioVideoLoadedNotifier('mixer_id', targetRoomID: 'room_id');
    ```

### getMixedSoundLevelsStream

  - description

    Get the mixed sound levels stream for the room.

  - prototype

    ```dart
    Stream<Map<int, double>> getMixedSoundLevelsStream({
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    ZegoUIKit().getMixedSoundLevelsStream(targetRoomID: 'room_id').listen((levels) {});
    ```

### getMixedSoundLevelStream

  - description

    Get the sound level stream of a specific user in a mixed stream.

  - prototype

    ```dart
    Stream<double> getMixedSoundLevelStream(
      String userID, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    ZegoUIKit().getMixedSoundLevelStream('user_id', targetRoomID: 'room_id').listen((level) {});
    ```

### getUserInMixerStream

  - description

    Get user info of a specific user in a mixed stream.

  - prototype

    ```dart
    ZegoUIKitUser getUserInMixerStream(
      String userID, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | userID | Parameter userID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    var user = ZegoUIKit().getUserInMixerStream('user_id', targetRoomID: 'room_id');
    ```

### getMixerStreamUsers

  - description

    Get the user list of a specific mixed stream.

  - prototype

    ```dart
    List<ZegoUIKitUser> getMixerStreamUsers(
      String mixerStreamID, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | mixerStreamID | Parameter mixerStreamID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    var users = ZegoUIKit().getMixerStreamUsers('mixer_stream_id', targetRoomID: 'room_id');
    ```

### getMixerUserListStream

  - description

    Get the user list stream of a specific mixed stream.

  - prototype

    ```dart
    Stream<List<ZegoUIKitUser>> getMixerUserListStream(
      String mixerStreamID, {
      required String targetRoomID,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | mixerStreamID | Parameter mixerStreamID | `String` | `Optional` |
    | targetRoomID | Parameter targetRoomID | `String` | `Required` |
  - example

    ```dart
    ZegoUIKit().getMixerUserListStream('mixer_stream_id', targetRoomID: 'room_id').listen((users) {});
    ```

## Event

### registerExpressEvent

  - description

    Register express event.

  - prototype

    ```dart
    void registerExpressEvent(ZegoUIKitExpressEventInterface event)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | event | Parameter event | `ZegoUIKitExpressEventInterface` | `Optional` |
  - example

    ```dart
    ZegoUIKit().registerExpressEvent(eventImpl);
    ```

### unregisterExpressEvent

  - description

    Unregister express event.

  - prototype

    ```dart
    void unregisterExpressEvent(ZegoUIKitExpressEventInterface event)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | event | Parameter event | `ZegoUIKitExpressEventInterface` | `Optional` |
  - example

    ```dart
    ZegoUIKit().unregisterExpressEvent(eventImpl);
    ```

## Logger

### initLog

  - description

    Initialize logger.

  - prototype

    ```dart
    Future<void> initLog()
    ```
  - example

    ```dart
    await ZegoUIKit().initLog();
    ```

### clearLogs

  - description

    Clear logs.

  - prototype

    ```dart
    Future<void> clearLogs()
    ```
  - example

    ```dart
    await ZegoUIKit().clearLogs();
    ```

### exportLogs

  - description

    Export logs.

  - prototype

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
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | title | Parameter title | `String?` | `Optional` |
    | content | Parameter content | `String?` | `Optional` |
    | fileName | Parameter fileName | `String?` | `Optional` |
    | fileTypes | Parameter fileTypes | `List<ZegoLogExporterFileType>` | `const [` |
    | directories | Parameter directories | `List<ZegoLogExporterDirectoryType>` | `const [` |
    | Function | Parameter Function | `void` | `Optional` |
  - example

    ```dart
    await ZegoUIKit().exportLogs();
    ```

### logInfo

  - description

    Log info message.

  - prototype

    ```dart
    static Future<void> logInfo(String logMessage, {String tag = '', String subTag = ''})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | logMessage | Parameter logMessage | `String` | `Optional` |
    | tag | Parameter tag | `String` | `` |
    | subTag | Parameter subTag | `String` | `` |
  - example

    ```dart
    await ZegoLoggerService.logInfo('message');
    ```

### logWarn

  - description

    Log warning message.

  - prototype

    ```dart
    static Future<void> logWarn(String logMessage, {String tag = '', String subTag = ''})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | logMessage | Parameter logMessage | `String` | `Optional` |
    | tag | Parameter tag | `String` | `` |
    | subTag | Parameter subTag | `String` | `` |
  - example

    ```dart
    await ZegoLoggerService.logWarn('warning message');
    ```

### logError

  - description

    Log error message.

  - prototype

    ```dart
    static Future<void> logError(String logMessage, {String tag = '', String subTag = ''})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | logMessage | Parameter logMessage | `String` | `Optional` |
    | tag | Parameter tag | `String` | `` |
    | subTag | Parameter subTag | `String` | `` |
  - example

    ```dart
    await ZegoLoggerService.logError('error message');
    ```

### logErrorTrace

  - description

    Log error message with stack trace.

  - prototype

    ```dart
    static Future<void> logErrorTrace(String logMessage, Error e, {String tag = '', String subTag = ''})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | logMessage | Parameter logMessage | `String` | `Optional` |
    | e | Parameter e | `Error` | `Optional` |
    | tag | Parameter tag | `String` | `` |
    | subTag | Parameter subTag | `String` | `` |
  - example

    ```dart
    await ZegoLoggerService.logErrorTrace('error with trace', e);
    ```

# Plugins

## Signaling

### ZegoUIKitSignalingPluginImpl

The signaling plugin implementation. Access it via `ZegoUIKitSignalingPluginImpl.shared` or `ZegoUIKit().getSignalingPlugin()`.

### init

  - description

    Initialize the signaling plugin.

  - prototype

    ```dart
    Future<void> init(
      int appID, {
      String appSign = '',
      String token = '',
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | appID | Parameter appID | `int` | `Optional` |
    | appSign | Parameter appSign | `String` | `` |
    | token | Parameter token | `String` | `` |
  - example

    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.init(appID: 123456);
    ```

### uninit

  - description

    Uninitialize the signaling plugin.

  - prototype

    ```dart
    Future<void> uninit({bool forceDestroy = false})
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | forceDestroy | Parameter forceDestroy | `bool` | `false` |
  - example

    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.uninit();
    ```

### login

  - description

    Login to the signaling service.

  - prototype

    ```dart
    Future<bool> login({
      required String id,
      required String name,
      String token = '',
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | id | Parameter id | `String` | `Required` |
    | name | Parameter name | `String` | `Required` |
    | token | Parameter token | `String` | `` |
  - example

    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.login(id: 'user', name: 'User');
    ```

### logout

  - description

    Logout from the signaling service.

  - prototype

    ```dart
    Future<void> logout()
    ```
  - example

    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.logout();
    ```

### joinRoom

  - description

    Join a signaling room.

  - prototype

    ```dart
    Future<ZegoSignalingPluginJoinRoomResult> joinRoom(
      String roomID, {
      String roomName = '',
      bool force = false,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | roomID | Parameter roomID | `String` | `Optional` |
    | roomName | Parameter roomName | `String` | `` |
    | force | Parameter force | `bool` | `false` |
  - example

    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.joinRoom('room_id');
    ```

### switchRoom

  - description

    Switch to another signaling room.

  - prototype

    ```dart
    Future<ZegoSignalingPluginJoinRoomResult> switchRoom(
      String roomID, {
      String roomName = '',
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | roomID | Parameter roomID | `String` | `Optional` |
    | roomName | Parameter roomName | `String` | `` |
  - example

    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.switchRoom('new_room_id');
    ```

### renewToken

  - description

    Renew the signaling token.

  - prototype

    ```dart
    Future<bool> renewToken(String token)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | token | Parameter token | `String` | `Optional` |
  - example

    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.renewToken('new_token');
    ```

### Invitation Service

### sendInvitation

  - description

    Send a call invitation.

  - prototype

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
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | inviterID | Parameter inviterID | `String` | `Required` |
    | inviterName | Parameter inviterName | `String` | `Required` |
    | invitees | Parameter invitees | `List<String>` | `Required` |
    | timeout | Parameter timeout | `int` | `Required` |
    | type | Parameter type | `int` | `Required` |
    | data | Parameter data | `String` | `Required` |
    | isAdvancedMode | Parameter isAdvancedMode | `bool` | `false` |
    | zegoNotificationConfig | Parameter zegoNotificationConfig | `ZegoNotificationConfig?` | `Optional` |
  - example

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

### sendAdvanceInvitation

  - description

    Send an advanced call invitation.

  - prototype

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
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | inviterID | Parameter inviterID | `String` | `Required` |
    | inviterName | Parameter inviterName | `String` | `Required` |
    | invitees | Parameter invitees | `List<String>` | `Required` |
    | timeout | Parameter timeout | `int` | `Required` |
    | type | Parameter type | `int` | `Required` |
    | data | Parameter data | `String` | `Required` |
    | zegoNotificationConfig | Parameter zegoNotificationConfig | `ZegoNotificationConfig?` | `Optional` |
  - example

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

### enableNotifyWhenAppRunningInBackgroundOrQuit

  - description

    Enable background notifications.

  - prototype

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
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | enabled | Parameter enabled | `bool` | `Optional` |
    | isIOSSandboxEnvironment | Parameter isIOSSandboxEnvironment | `bool?` | `Optional` |
    | enableIOSVoIP | Parameter enableIOSVoIP | `bool` | `true` |
    | certificateIndex | Parameter certificateIndex | `int` | `1` |
    | appName | Parameter appName | `String` | `` |
    | androidChannelID | Parameter androidChannelID | `String` | `` |
    | androidChannelName | Parameter androidChannelName | `String` | `` |
    | androidSound | Parameter androidSound | `String` | `` |
  - example

    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.enableNotifyWhenAppRunningInBackgroundOrQuit(true);
    ```

### Message Service

### sendInRoomTextMessage

  - description

    Send text message in room.

  - prototype

    ```dart
    Future<ZegoSignalingPluginInRoomTextMessageResult> sendInRoomTextMessage({
      required String roomID,
      required String message,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | roomID | Parameter roomID | `String` | `Required` |
    | message | Parameter message | `String` | `Required` |
  - example

    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.sendInRoomTextMessage(
      roomID: 'room_id',
      message: 'hello',
    );
    ```

### sendInRoomCommandMessage

  - description

    Send command message in room.

  - prototype

    ```dart
    Future<ZegoSignalingPluginInRoomCommandMessageResult> sendInRoomCommandMessage({
      required String roomID,
      required Uint8List message,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | roomID | Parameter roomID | `String` | `Required` |
    | message | Parameter message | `Uint8List` | `Required` |
  - example

    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.sendInRoomCommandMessage(
      roomID: 'room_id',
      message: Uint8List.fromList([1, 2, 3]),
    );
    ```

### Room Attributes Service

### updateRoomProperty

  - description

    Update room properties.

  - prototype

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
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | roomID | Parameter roomID | `String` | `Required` |
    | key | Parameter key | `String` | `Required` |
    | value | Parameter value | `String` | `Required` |
    | isForce | Parameter isForce | `bool` | `false` |
    | isDeleteAfterOwnerLeft | Parameter isDeleteAfterOwnerLeft | `bool` | `false` |
    | isUpdateOwner | Parameter isUpdateOwner | `bool` | `false` |
  - example

    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.updateRoomProperty(
      roomID: 'room_id',
      key: 'key',
      value: 'value',
    );
    ```

### deleteRoomProperties

  - description

    Delete room properties.

  - prototype

    ```dart
    Future<ZegoSignalingPluginRoomPropertiesOperationResult> deleteRoomProperties({
      required String roomID,
      required List<String> keys,
      bool isForce = false,
      bool showErrorLog = true,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | roomID | Parameter roomID | `String` | `Required` |
    | keys | Parameter keys | `List<String>` | `Required` |
    | isForce | Parameter isForce | `bool` | `false` |
    | showErrorLog | Parameter showErrorLog | `bool` | `true` |
  - example

    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.deleteRoomProperties(
      roomID: 'room_id',
      keys: ['key'],
    );
    ```

### User In-Room Attributes Service

### setUsersInRoomAttributes

  - description

    Set user attributes in room.

  - prototype

    ```dart
    Future<ZegoSignalingPluginSetUsersInRoomAttributesResult> setUsersInRoomAttributes({
      required String roomID,
      required String key,
      required String value,
      required List<String> userIDs,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | roomID | Parameter roomID | `String` | `Required` |
    | key | Parameter key | `String` | `Required` |
    | value | Parameter value | `String` | `Required` |
    | userIDs | Parameter userIDs | `List<String>` | `Required` |
  - example

    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.setUsersInRoomAttributes(
      roomID: 'room_id',
      key: 'key',
      value: 'value',
      userIDs: ['user_id'],
    );
    ```

### queryUsersInRoomAttributes

  - description

    Query user attributes in room.

  - prototype

    ```dart
    Future<ZegoSignalingPluginQueryUsersInRoomAttributesResult> queryUsersInRoomAttributes({
      required String roomID,
      String nextFlag = '',
      int count = 100,
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | roomID | Parameter roomID | `String` | `Required` |
    | nextFlag | Parameter nextFlag | `String` | `` |
    | count | Parameter count | `int` | `100` |
  - example

    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.queryUsersInRoomAttributes(
      roomID: 'room_id',
    );
    ```

### Background Message Service

### setBackgroundMessageHandler

  - description

    Set background message handler.

  - prototype

    ```dart
    Future<ZegoSignalingPluginSetMessageHandlerResult> setBackgroundMessageHandler(
      ZegoSignalingPluginZPNsBackgroundMessageHandler handler, {
      String key = 'default',
    })
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | handler | Parameter handler | `ZegoSignalingPluginZPNsBackgroundMessageHandler` | `Optional` |
    | key | Parameter key | `String` | `default` |
  - example

    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.setBackgroundMessageHandler(handler);
    ```

### CallKit Service

### setIncomingPushReceivedHandler

  - description

    Set incoming push received handler.

  - prototype

    ```dart
    Future<void> setIncomingPushReceivedHandler(
        ZegoSignalingIncomingPushReceivedHandler handler)
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | handler | Parameter handler | `ZegoSignalingIncomingPushReceivedHandler` | `Optional` |
  - example

    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.setIncomingPushReceivedHandler(handler);
    ```

### setInitConfiguration

  - description

    Set initialization configuration.

  - prototype

    ```dart
    Future<void> setInitConfiguration(
      ZegoSignalingPluginProviderConfiguration configuration,
    )
    ```
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | configuration | Parameter configuration | `ZegoSignalingPluginProviderConfiguration` | `Optional` |
  - example

    ```dart
    await ZegoUIKitSignalingPluginImpl.shared.setInitConfiguration(config);
    ```

## Invitation Components

**ZegoStartInvitationButton**

### Constructor
  - description

    Create a start invitation button.

  - prototype

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
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | key | Parameter key | `Key?` | `Optional` |
    | invitationType | Parameter invitationType | `int` | `Required` |
    | invitees | Parameter invitees | `List<String>` | `Required` |
    | data | Parameter data | `String` | `Required` |
    | isAdvancedMode | Parameter isAdvancedMode | `bool` | `false` |
    | notificationConfig | Parameter notificationConfig | `ZegoNotificationConfig?` | `Optional` |
    | timeoutSeconds | Parameter timeoutSeconds | `int` | `60` |
    | text | Parameter text | `String?` | `Optional` |
    | textStyle | Parameter textStyle | `TextStyle?` | `Optional` |
    | icon | Parameter icon | `ButtonIcon?` | `Optional` |
    | iconSize | Parameter iconSize | `Size?` | `Optional` |
    | iconTextSpacing | Parameter iconTextSpacing | `double?` | `Optional` |
    | verticalLayout | Parameter verticalLayout | `bool` | `true` |
    | buttonSize | Parameter buttonSize | `Size?` | `Optional` |
    | borderRadius | Parameter borderRadius | `double?` | `Optional` |
    | margin | Parameter margin | `EdgeInsetsGeometry?` | `Optional` |
    | padding | Parameter padding | `EdgeInsetsGeometry?` | `Optional` |
    | Function | Parameter Function | `Future<bool>` | `Optional` |
    | Function | Parameter Function | `void` | `Optional` |
    | networkLoadingConfig | Parameter networkLoadingConfig | `ZegoNetworkLoadingConfig?` | `Optional` |
    | clickableTextColor | Parameter clickableTextColor | `Color?` | `Optional` |
    | unclickableTextColor | Parameter unclickableTextColor | `Color?` | `Optional` |
    | clickableBackgroundColor | Parameter clickableBackgroundColor | `Color?` | `Optional` |
    | unclickableBackgroundColor | Parameter unclickableBackgroundColor | `Color?` | `Optional` |
  - example

    ```dart
    ZegoStartInvitationButton(
      invitationType: 1,
      invitees: ['user_id'],
      data: 'data',
    );
    ```

**ZegoAcceptInvitationButton**

### Constructor
  - description

    Create an accept invitation button.

  - prototype

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
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | key | Parameter key | `Key?` | `Optional` |
    | inviterID | Parameter inviterID | `String` | `Required` |
    | isAdvancedMode | Parameter isAdvancedMode | `bool` | `false` |
    | customData | Parameter customData | `String` | `` |
    | targetInvitationID | Parameter targetInvitationID | `String?` | `Optional` |
    | text | Parameter text | `String?` | `Optional` |
    | textStyle | Parameter textStyle | `TextStyle?` | `Optional` |
    | icon | Parameter icon | `ButtonIcon?` | `Optional` |
    | iconSize | Parameter iconSize | `Size?` | `Optional` |
    | buttonSize | Parameter buttonSize | `Size?` | `Optional` |
    | iconTextSpacing | Parameter iconTextSpacing | `double?` | `Optional` |
    | verticalLayout | Parameter verticalLayout | `bool` | `true` |
    | Function | Parameter Function | `void` | `Optional` |
    | Function | Parameter Function | `void` | `Optional` |
    | networkLoadingConfig | Parameter networkLoadingConfig | `ZegoNetworkLoadingConfig?` | `Optional` |
    | clickableTextColor | Parameter clickableTextColor | `Color?` | `Optional` |
    | unclickableTextColor | Parameter unclickableTextColor | `Color?` | `Optional` |
    | clickableBackgroundColor | Parameter clickableBackgroundColor | `Color?` | `Optional` |
    | unclickableBackgroundColor | Parameter unclickableBackgroundColor | `Color?` | `Optional` |
  - example

    ```dart
    ZegoAcceptInvitationButton(inviterID: 'inviter_id');
    ```

**ZegoRefuseInvitationButton**

### Constructor
  - description

    Create a refuse invitation button.

  - prototype

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
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | key | Parameter key | `Key?` | `Optional` |
    | inviterID | Parameter inviterID | `String` | `Required` |
    | data | Parameter data | `String` | `` |
    | isAdvancedMode | Parameter isAdvancedMode | `bool` | `false` |
    | targetInvitationID | Parameter targetInvitationID | `String?` | `Optional` |
    | text | Parameter text | `String?` | `Optional` |
    | textStyle | Parameter textStyle | `TextStyle?` | `Optional` |
    | icon | Parameter icon | `ButtonIcon?` | `Optional` |
    | iconSize | Parameter iconSize | `Size?` | `Optional` |
    | buttonSize | Parameter buttonSize | `Size?` | `Optional` |
    | iconTextSpacing | Parameter iconTextSpacing | `double?` | `Optional` |
    | verticalLayout | Parameter verticalLayout | `bool` | `true` |
    | Function | Parameter Function | `void` | `Optional` |
    | Function | Parameter Function | `void` | `Optional` |
    | networkLoadingConfig | Parameter networkLoadingConfig | `ZegoNetworkLoadingConfig?` | `Optional` |
    | clickableTextColor | Parameter clickableTextColor | `Color?` | `Optional` |
    | unclickableTextColor | Parameter unclickableTextColor | `Color?` | `Optional` |
    | clickableBackgroundColor | Parameter clickableBackgroundColor | `Color?` | `Optional` |
    | unclickableBackgroundColor | Parameter unclickableBackgroundColor | `Color?` | `Optional` |
  - example

    ```dart
    ZegoRefuseInvitationButton(inviterID: 'inviter_id');
    ```

**ZegoCancelInvitationButton**

### Constructor
  - description

    Create a cancel invitation button.

  - prototype

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
  - parameters
    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | key | Parameter key | `Key?` | `Optional` |
    | invitees | Parameter invitees | `List<String>` | `Required` |
    | data | Parameter data | `String` | `` |
    | isAdvancedMode | Parameter isAdvancedMode | `bool` | `false` |
    | targetInvitationID | Parameter targetInvitationID | `String?` | `Optional` |
    | text | Parameter text | `String?` | `Optional` |
    | textStyle | Parameter textStyle | `TextStyle?` | `Optional` |
    | icon | Parameter icon | `ButtonIcon?` | `Optional` |
    | iconSize | Parameter iconSize | `Size?` | `Optional` |
    | buttonSize | Parameter buttonSize | `Size?` | `Optional` |
    | iconTextSpacing | Parameter iconTextSpacing | `double?` | `Optional` |
    | verticalLayout | Parameter verticalLayout | `bool` | `true` |
    | Function | Parameter Function | `void` | `Optional` |
    | Function | Parameter Function | `void` | `Optional` |
    | networkLoadingConfig | Parameter networkLoadingConfig | `ZegoNetworkLoadingConfig?` | `Optional` |
    | clickableTextColor | Parameter clickableTextColor | `Color?` | `Optional` |
    | unclickableTextColor | Parameter unclickableTextColor | `Color?` | `Optional` |
    | clickableBackgroundColor | Parameter clickableBackgroundColor | `Color?` | `Optional` |
    | unclickableBackgroundColor | Parameter unclickableBackgroundColor | `Color?` | `Optional` |
  - example

    ```dart
    ZegoCancelInvitationButton(invitees: ['user_id']);
    ```

## Defines

**ZegoNotificationConfig**

### Properties
  - `bool notifyWhenAppIsInTheBackgroundOrQuit`: Whether to notify when the app is in the background or quit.
  - `String resourceID`: Resource ID for the notification.
  - `String title`: Title of the notification.
  - `String message`: Message of the notification.
  - `ZegoNotificationVoIPConfig? voIPConfig`: VoIP configuration.

**ZegoNotificationVoIPConfig**

### Properties
  - `bool iOSVoIPHasVideo`: Whether the iOS VoIP call has video.

**ZegoUIKitHallRoomStreamMode**

- **Enum Values**
  - `preloaded`: Pre-pull streams and mute/unmute for smooth switching. More smooth experience but costs extra for two additional streams (previous/next).
  - `economy`: Stop/start streams when switching. No extra stream costs, but may have brief video/audio rendering delays, black screen, or stuttering during switching.

**ZegoUIKitHallRoomListStreamUser**

### Properties
  - `ZegoUIKitUser user`: The user.
  - `String roomID`: The room ID.
  - `ZegoStreamType streamType`: The stream type.

**ZegoUIKitHallRoomListSlideContext**

### Properties
  - `ZegoUIKitHallRoomListStreamUser previous`: Information of the previous room.
  - `ZegoUIKitHallRoomListStreamUser next`: Information of the next room.

**ZegoUIKitHallRoomListModel**

### Properties
  - `ZegoUIKitHallRoomListStreamUser? activeRoom`: The currently active/selected room in the hall.
  - `ZegoUIKitHallRoomListSlideContext? activeContext`: Adjacent room data context relative to activeRoom.
