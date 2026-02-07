# Components

- [Audio & Video](#audio--video)
  - [ZegoAudioVideoView](#zegoaudiovideoview)
  - [ZegoScreenSharingView](#zegoscreensharingview)
  - [ZegoAudioVideoContainer](#zegoaudiovideocontainer)
  - [ZegoUIKitMediaContainer](#zegouikitmediacontainer)
  - [ZegoUIKitMediaPlayer](#zegouikitmediaplayer)
  - [ZegoUIKitMediaView](#zegouikitmediaview)
  - [ZegoLayoutGallery](#zegolayoutgallery)
  - [ZegoLayoutPictureInPicture](#zegolayoutpictureinpicture)
  - [ZegoAvatar](#zegoavatar)
  - [ZegoCameraStateIcon](#zegocamerastateicon)
  - [ZegoMicrophoneStateIcon](#zegomicrophonestateicon)
  - [ZegoScreenSharingViewController](#zegoscreensharingviewcontroller)
  - [ZegoScreenSharingCountDownStopSettings](#zegoscreensharingcountdownstopsettings)
  - [ZegoScreenSharingAutoStopSettings](#zegoscreensharingautostopsettings)
  - [ZegoLayoutGalleryConfig](#zegolayoutgalleryconfig)
  - [ZegoLayoutPictureInPictureConfig](#zegolayoutpictureinpictureconfig)
  - [ZegoViewPosition](#zegoviewposition)
  - [isScreenSharingExtraInfoKey](#isscreensharingextrainfokey)
- [Controls](#controls)
  - [ZegoScreenSharingToggleButton](#zegoscreensharingtogglebutton)
  - [ZegoSwitchAudioOutputButton](#zegoswitchaudiooutputbutton)
  - [ZegoSwitchCameraButton](#zegoswitchcamerabutton)
  - [ZegoToggleCameraButton](#zegotogglecamerabutton)
  - [ZegoToggleMicrophoneButton](#zegotogglemicrophonebutton)
  - [ZegoLeaveButton](#zegoleavebutton)
  - [ZegoMoreButton](#zegomorebutton)
  - [ZegoTextIconButton](#zegotexticonbutton)
- [Member & Message](#member--message)
  - [ZegoMemberList](#zegomemberlist)
  - [ZegoInRoomMessageView](#zegoinroommessageview)
  - [ZegoInRoomMessageInput](#zegoinroommessageinput)
  - [ZegoInRoomChatView](#zegoinroomchatview)
  - [ZegoInRoomMessageViewItem](#zegoinroommessageviewitem)
  - [ZegoInRoomNotificationView](#zegoinroomnotificationview)
  - [ZegoInRoomNotificationViewItem](#zegoinroomnotificationviewitem)
- [Effect](#effect)
  - [ZegoBeautyEffectSlider](#zegobeautyeffectslider)
- [Widgets](#widgets)
  - [ZegoDraggableBottomSheet](#zegodraggablebottomsheet)
  - [ZegoInputBoardWrapper](#zegoinputboardwrapper)
  - [ZegoSlider](#zegoslider)
  - [ZegoNetworkLoading](#zegonetworkloading)
  - [ZegoLoadingIndicator](#zegoloadingindicator)
  - [ZegoServiceValueIcon](#zegoservicevalueicon)
  - [ValueNotifierSliderVisibility](#valuenotifierslidervisibility)
- [Functions](#functions)
  - [showAlertDialog](#showalertdialog)
  - [showTopModalSheet](#showtopmodalsheet)
  - [getTextSize](#gettextsize)

---

# Audio & Video

## ZegoAudioVideoView

Display user audio and video information.

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **user**
  - Meaning: The user whose stream needs to be rendered.
  - Type: ZegoUIKitUser?
- **foregroundBuilder**
  - Meaning: Foreground builder, you can display something you want on top of the view, foreground will always show.
  - Type: ZegoAudioVideoViewForegroundBuilder?
- **backgroundBuilder**
  - Meaning: Background builder, you can display something when user close camera.
  - Type: ZegoAudioVideoViewBackgroundBuilder?
- **borderRadius**
  - Meaning: The border radius of the view.
  - Type: double?
- **borderColor**
  - Meaning: The border color of the view.
  - Type: Color?
- **extraInfo**
  - Meaning: Additional information.
  - Type: Map<String, dynamic>?
- **avatarConfig**
  - Meaning: Configuration for the avatar.
  - Type: ZegoAvatarConfig?
  - Members:
    - **showInAudioMode**
      - Meaning: Determines whether the avatar should be shown in audio mode.
      - Type: bool?
    - **showSoundWavesInAudioMode**
      - Meaning: Determines whether sound waves should be shown in audio mode.
      - Type: bool?
    - **verticalAlignment**
      - Meaning: The vertical alignment of the avatar.
      - Type: ZegoAvatarAlignment (center, start, end)
    - **size**
      - Meaning: The size of the avatar.
      - Type: Size?
    - **soundWaveColor**
      - Meaning: The color of the sound waves.
      - Type: Color?
    - **builder**
      - Meaning: The builder function for the avatar widget.
      - Type: ZegoAvatarBuilder?
- **onTap**
  - Meaning: Callback when the view is tapped.
  - Type: void Function(ZegoUIKitUser? user)?

## ZegoScreenSharingView

Display user screensharing information.

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **user**
  - Meaning: The user who is sharing the screen.
  - Type: ZegoUIKitUser?
- **foregroundBuilder**
  - Meaning: Foreground builder, you can display something you want on top of the view, foreground will always show.
  - Type: ZegoAudioVideoViewForegroundBuilder?
- **backgroundBuilder**
  - Meaning: Background builder, you can display something when user close camera.
  - Type: ZegoAudioVideoViewBackgroundBuilder?
- **borderRadius**
  - Meaning: The border radius of the view.
  - Type: double?
- **borderColor**
  - Meaning: The color of the border.
  - Type: Color
- **extraInfo**
  - Meaning: Extra info.
  - Type: Map<String, dynamic>
- **showFullscreenModeToggleButtonRules**
  - Meaning: The rules for showing the fullscreen mode toggle button.
  - Type: ZegoShowFullscreenModeToggleButtonRules
- **controller**
  - Meaning: The controller for the screen sharing view.
  - Type: ZegoScreenSharingViewController?

## ZegoAudioVideoContainer

Container of audio video view, it will layout views by layout mode and config.

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **layout**
  - Meaning: Layout configuration.
  - Type: ZegoLayout
  - Members:
    - **ZegoLayout.pictureInPicture**
      - Meaning: Picture-in-Picture (PiP) layout.
      - Type: Factory
      - Members:
        - **smallViewMargin**
          - Meaning: The margin of PIP view.
          - Type: EdgeInsets?
        - **isSmallViewDraggable**
          - Meaning: Small video view is draggable if set true in one-on-one mode.
          - Type: bool
        - **switchLargeOrSmallViewByClick**
          - Meaning: Whether you can switch view's position by clicking on the small view.
          - Type: bool
        - **smallViewPosition**
          - Meaning: Default position of small video view.
          - Type: ZegoViewPosition
        - **smallViewSize**
          - Meaning: The size of every small view.
          - Type: Size?
        - **spacingBetweenSmallViews**
          - Meaning: The space between small views in multi-users mode.
          - Type: EdgeInsets?
        - **isSmallViewsScrollable**
          - Meaning: Small video views is scrollable if set true in multi-users mode.
          - Type: bool
        - **visibleSmallViewsCount**
          - Meaning: The visible small views count in multi-users mode.
          - Type: int
        - **showNewScreenSharingViewInFullscreenMode**
          - Meaning: Whether to show the new screen sharing view in fullscreen mode.
          - Type: bool
        - **showScreenSharingFullscreenModeToggleButtonRules**
          - Meaning: The rules for showing the fullscreen mode toggle button.
          - Type: ZegoShowFullscreenModeToggleButtonRules
        - **bigViewUserID**
          - Meaning: User ID for Specifying Large View.
          - Type: String?
    - **ZegoLayout.gallery**
      - Meaning: Gallery Layout.
      - Type: Factory
      - Members:
        - **showOnlyOnAudioVideo**
          - Meaning: Show audio video view only open camera or microphone.
          - Type: bool
        - **margin**
          - Meaning: The margin of layout.
          - Type: EdgeInsetsGeometry
        - **addBorderRadiusAndSpacingBetweenView**
          - Meaning: Whether to display rounded corners and spacing between views.
          - Type: bool
        - **showNewScreenSharingViewInFullscreenMode**
          - Meaning: Whether to show the new screen sharing view in fullscreen mode.
          - Type: bool
        - **showScreenSharingFullscreenModeToggleButtonRules**
          - Meaning: The rules for showing the fullscreen mode toggle button.
          - Type: ZegoShowFullscreenModeToggleButtonRules
- **foregroundBuilder**
  - Meaning: Foreground builder of audio video view.
  - Type: ZegoAudioVideoViewForegroundBuilder?
- **backgroundBuilder**
  - Meaning: Background builder of audio video view.
  - Type: ZegoAudioVideoViewBackgroundBuilder?
- **sortAudioVideo**
  - Meaning: Sorter for the audio video views.
  - Type: ZegoAudioVideoViewSorter?
- **filterAudioVideo**
  - Meaning: Filter for the audio video views.
  - Type: ZegoAudioVideoViewFilter?
- **avatarConfig**
  - Meaning: Configuration for the avatar.
  - Type: ZegoAvatarConfig?
  - Members:
    - **showInAudioMode**
      - Meaning: Determines whether the avatar should be shown in audio mode.
      - Type: bool?
    - **showSoundWavesInAudioMode**
      - Meaning: Determines whether sound waves should be shown in audio mode.
      - Type: bool?
    - **verticalAlignment**
      - Meaning: The vertical alignment of the avatar.
      - Type: ZegoAvatarAlignment
    - **size**
      - Meaning: The size of the avatar.
      - Type: Size?
    - **soundWaveColor**
      - Meaning: The color of the sound waves.
      - Type: Color?
    - **builder**
      - Meaning: The builder function for the avatar widget.
      - Type: ZegoAvatarBuilder?
- **screenSharingViewController**
  - Meaning: Controller for screen sharing view.
  - Type: ZegoScreenSharingViewController?
- **virtualUsersNotifier**
  - Meaning: Notifier for virtual users.
  - Type: ValueNotifier<List<ZegoUIKitUser>>?
- **sources**
  - Meaning: Sources to display (audio/video, screen sharing, etc.).
  - Type: List<ZegoAudioVideoContainerSource>
- **onUserListUpdated**
  - Meaning: Callback when the user list is updated.
  - Type: void Function(List<ZegoUIKitUser> userList)?

## ZegoUIKitMediaContainer

Container of media (audio/video).

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **foregroundBuilder**
  - Meaning: Foreground builder of audio video view.
  - Type: ZegoAudioVideoViewForegroundBuilder?
- **backgroundBuilder**
  - Meaning: Background builder of audio video view.
  - Type: ZegoAudioVideoViewBackgroundBuilder?

## ZegoUIKitMediaPlayer

You can use this control to play audio or video.

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **size**
  - Meaning: Size of this widget display on parent.
  - Type: Size
- **config**
  - Meaning: Configuration for the media player.
  - Type: ZegoUIKitMediaPlayerConfig
  - Members:
    - **allowedExtensions**
      - Meaning: Extensions of pick files (video: "avi","flv","mkv","mov","mp4","mpeg","webm","wmv"; audio: "aac","midi","mp3","ogg","wav").
      - Type: List<String>?
    - **canControl**
      - Meaning: Can control or not.
      - Type: bool
    - **enableRepeat**
      - Meaning: Repeat or not.
      - Type: bool
    - **autoStart**
      - Meaning: Auto start play after pick or set media url.
      - Type: bool
    - **isMovable**
      - Meaning: Can this media moveable on parent.
      - Type: bool
    - **isPlayButtonCentral**
      - Meaning: Show big play button central on player, or show a small control button.
      - Type: bool
    - **showSurface**
      - Meaning: Show surface(controls) or not.
      - Type: bool
    - **autoHideSurface**
      - Meaning: Auto hide surface after [hideSurfaceSecond].
      - Type: bool
    - **hideSurfaceSecond**
      - Meaning: Hide surface in seconds.
      - Type: int
- **style**
  - Meaning: Style configuration for the media player.
  - Type: ZegoUIKitMediaPlayerStyle
  - Members:
    - **closeIcon**
      - Meaning: The close icon.
      - Type: Widget?
    - **moreIcon**
      - Meaning: The more icon.
      - Type: Widget?
    - **playIcon**
      - Meaning: The play icon.
      - Type: Widget?
    - **pauseIcon**
      - Meaning: The pause icon.
      - Type: Widget?
    - **volumeIcon**
      - Meaning: The volume icon.
      - Type: Widget?
    - **volumeMuteIcon**
      - Meaning: The volume mute icon.
      - Type: Widget?
    - **durationTextStyle**
      - Meaning: The text style of the duration.
      - Type: TextStyle?
- **event**
  - Meaning: Event callbacks for the media player.
  - Type: ZegoUIKitMediaPlayerEvent
  - Members:
    - **onPlayStateChanged**
      - Meaning: Play state callback.
      - Type: void Function(ZegoUIKitMediaPlayState)?
- **filePathOrURL**
  - Meaning: Load the absolute path to the local resource or the URL of the network resource. If null, will pop-up and pick files from local.
  - Type: String?
- **initPosition**
  - Meaning: Top-left position display this widget on parent widget.
  - Type: Offset?

## ZegoUIKitMediaView

Display user media view.

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **user**
  - Meaning: The user whose stream needs to be rendered.
  - Type: ZegoUIKitUser?
- **foregroundBuilder**
  - Meaning: Foreground builder, you can display something you want on top of the view, foreground will always show.
  - Type: ZegoAudioVideoViewForegroundBuilder?
- **backgroundBuilder**
  - Meaning: Background builder, you can display something when user close camera.
  - Type: ZegoAudioVideoViewBackgroundBuilder?
- **borderRadius**
  - Meaning: The border radius of the view.
  - Type: double?
- **borderColor**
  - Meaning: The border color of the view.
  - Type: Color?
- **extraInfo**
  - Meaning: Additional information.
  - Type: Map<String, dynamic>?

## ZegoLayoutGallery

Gallery layout.

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **maxItemCount**
  - Meaning: The maximum number of items.
  - Type: int
- **userList**
  - Meaning: The list of users to display.
  - Type: List<ZegoUIKitUser>
- **layoutConfig**
  - Meaning: Configuration for the gallery layout.
  - Type: ZegoLayoutGalleryConfig
  - Members:
    - **showOnlyOnAudioVideo**
      - Meaning: Show audio video view only open camera or microphone.
      - Type: bool
    - **margin**
      - Meaning: The margin of layout.
      - Type: EdgeInsetsGeometry
    - **addBorderRadiusAndSpacingBetweenView**
      - Meaning: Whether to display rounded corners and spacing between views.
      - Type: bool
    - **showNewScreenSharingViewInFullscreenMode**
      - Meaning: Whether to show the new screen sharing view in fullscreen mode.
      - Type: bool
    - **showScreenSharingFullscreenModeToggleButtonRules**
      - Meaning: The rules for showing the fullscreen mode toggle button.
      - Type: ZegoShowFullscreenModeToggleButtonRules
- **backgroundColor**
  - Meaning: The background color.
  - Type: Color
- **foregroundBuilder**
  - Meaning: Foreground builder.
  - Type: ZegoAudioVideoViewForegroundBuilder?
- **backgroundBuilder**
  - Meaning: Background builder.
  - Type: ZegoAudioVideoViewBackgroundBuilder?
- **avatarConfig**
  - Meaning: Configuration for the avatar.
  - Type: ZegoAvatarConfig?
  - Members:
    - **showInAudioMode**
      - Meaning: Determines whether the avatar should be shown in audio mode.
      - Type: bool?
    - **showSoundWavesInAudioMode**
      - Meaning: Determines whether sound waves should be shown in audio mode.
      - Type: bool?
    - **verticalAlignment**
      - Meaning: The vertical alignment of the avatar.
      - Type: ZegoAvatarAlignment
    - **size**
      - Meaning: The size of the avatar.
      - Type: Size?
    - **soundWaveColor**
      - Meaning: The color of the sound waves.
      - Type: Color?
    - **builder**
      - Meaning: The builder function for the avatar widget.
      - Type: ZegoAvatarBuilder?
- **screenSharingViewController**
  - Meaning: Controller for screen sharing view.
  - Type: ZegoScreenSharingViewController?

## ZegoLayoutPictureInPicture

Picture in picture layout.

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **userList**
  - Meaning: The list of users to display.
  - Type: List<ZegoUIKitUser>
- **layoutConfig**
  - Meaning: Configuration for the PiP layout.
  - Type: ZegoLayoutPictureInPictureConfig
  - Members:
    - **isSmallViewDraggable**
      - Meaning: Small video view is draggable if set true in one-on-one mode.
      - Type: bool
    - **switchLargeOrSmallViewByClick**
      - Meaning: Whether you can switch view's position by clicking on the small view.
      - Type: bool
    - **smallViewPosition**
      - Meaning: Default position of small video view.
      - Type: ZegoViewPosition
    - **margin**
      - Meaning: The margin of PIP view.
      - Type: EdgeInsets?
    - **smallViewSize**
      - Meaning: The size of every small view.
      - Type: Size?
    - **spacingBetweenSmallViews**
      - Meaning: The space between small views in multi-users mode.
      - Type: EdgeInsets?
    - **isSmallViewsScrollable**
      - Meaning: Small video views is scrollable if set true in multi-users mode.
      - Type: bool
    - **visibleSmallViewsCount**
      - Meaning: The visible small views count in multi-users mode.
      - Type: int
    - **showNewScreenSharingViewInFullscreenMode**
      - Meaning: Whether to show the new screen sharing view in fullscreen mode.
      - Type: bool
    - **showScreenSharingFullscreenModeToggleButtonRules**
      - Meaning: The rules for showing the fullscreen mode toggle button.
      - Type: ZegoShowFullscreenModeToggleButtonRules
    - **bigViewUserID**
      - Meaning: User ID for Specifying Large View.
      - Type: String?
- **foregroundBuilder**
  - Meaning: Foreground builder.
  - Type: ZegoAudioVideoViewForegroundBuilder?
- **backgroundBuilder**
  - Meaning: Background builder.
  - Type: ZegoAudioVideoViewBackgroundBuilder?
- **avatarConfig**
  - Meaning: Configuration for the avatar.
  - Type: ZegoAvatarConfig?
  - Members:
    - **showInAudioMode**
      - Meaning: Determines whether the avatar should be shown in audio mode.
      - Type: bool?
    - **showSoundWavesInAudioMode**
      - Meaning: Determines whether sound waves should be shown in audio mode.
      - Type: bool?
    - **verticalAlignment**
      - Meaning: The vertical alignment of the avatar.
      - Type: ZegoAvatarAlignment
    - **size**
      - Meaning: The size of the avatar.
      - Type: Size?
    - **soundWaveColor**
      - Meaning: The color of the sound waves.
      - Type: Color?
    - **builder**
      - Meaning: The builder function for the avatar widget.
      - Type: ZegoAvatarBuilder?

## ZegoAvatar

Display user avatar.

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **avatarSize**
  - Meaning: The size of the avatar.
  - Type: Size
- **user**
  - Meaning: The user to display.
  - Type: ZegoUIKitUser?
- **showAvatar**
  - Meaning: Whether to show the avatar.
  - Type: bool
- **showSoundLevel**
  - Meaning: Whether to show sound level ripple.
  - Type: bool
- **soundLevelSize**
  - Meaning: The size of the sound level ripple.
  - Type: Size?
- **soundLevelColor**
  - Meaning: The color of the sound level ripple.
  - Type: Color?
- **avatarBuilder**
  - Meaning: Custom builder for the avatar.
  - Type: ZegoAvatarBuilder?
- **mixerStreamID**
  - Meaning: Stream ID for mixer.
  - Type: String?

## ZegoCameraStateIcon

Monitor the camera status changes, when the status changes, the corresponding icon is automatically switched.

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **targetUser**
  - Meaning: The user to monitor.
  - Type: ZegoUIKitUser?
- **iconCameraOn**
  - Meaning: Icon when camera is on.
  - Type: Image?
- **iconCameraOff**
  - Meaning: Icon when camera is off.
  - Type: Image?

## ZegoMicrophoneStateIcon

Monitor the microphone status changes, when the status changes, the corresponding icon is automatically switched.

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **targetUser**
  - Meaning: The user to monitor.
  - Type: ZegoUIKitUser?
- **iconMicrophoneOn**
  - Meaning: Icon when microphone is on.
  - Type: Image?
- **iconMicrophoneOff**
  - Meaning: Icon when microphone is off.
  - Type: Image?
- **iconMicrophoneSpeaking**
  - Meaning: Icon when microphone is speaking.
  - Type: Image?

## ZegoScreenSharingViewController

Controller for screen sharing view.

- **fullscreenUserNotifier**
  - Meaning: Notifier for the user who is in full-screen mode.
  - Type: ValueNotifier<ZegoUIKitUser?>
- **showScreenSharingViewInFullscreenMode**
  - Meaning: Specify whether a certain user enters or exits full-screen mode during screen sharing.
  - Type: void Function(String userID, bool isFullscreen, {required String targetRoomID})

## ZegoScreenSharingCountDownStopSettings

Configuration for screen sharing countdown stop.

- **support**
  - Meaning: Whether to support countdown stop.
  - Type: bool
- **tips**
  - Meaning: The tips to display.
  - Type: String
- **seconds**
  - Meaning: The countdown seconds.
  - Type: int
- **textColor**
  - Meaning: The color of the text.
  - Type: Color?
- **progressColor**
  - Meaning: The color of the progress.
  - Type: Color?
- **secondFontSize**
  - Meaning: The font size of the second.
  - Type: double?
- **tipsFontSize**
  - Meaning: The font size of the tips.
  - Type: double?
- **onCountDownFinished**
  - Meaning: Callback when countdown finished.
  - Type: VoidCallback?

## ZegoScreenSharingAutoStopSettings

Configuration for screen sharing auto stop.

- **invalidCount**
  - Meaning: Count of the check fails before automatically end the screen sharing.
  - Type: int
- **canEnd**
  - Meaning: Determines whether to end.
  - Type: bool Function()?

## ZegoLayoutGalleryConfig

Configuration for gallery layout.

- **showOnlyOnAudioVideo**
  - Meaning: Show audio video view only open camera or microphone.
  - Type: bool
- **addBorderRadiusAndSpacingBetweenView**
  - Meaning: Whether to display rounded corners and spacing between views.
  - Type: bool
- **margin**
  - Meaning: The margin of layout.
  - Type: EdgeInsetsGeometry
- **showNewScreenSharingViewInFullscreenMode**
  - Meaning: Whether to show the new screen sharing view in fullscreen mode.
  - Type: bool
- **showScreenSharingFullscreenModeToggleButtonRules**
  - Meaning: The rules for showing the fullscreen mode toggle button.
  - Type: ZegoShowFullscreenModeToggleButtonRules

## ZegoLayoutPictureInPictureConfig

Configuration for Picture-in-Picture layout.

- **isSmallViewDraggable**
  - Meaning: Small video view is draggable if set true in one-on-one mode.
  - Type: bool
- **switchLargeOrSmallViewByClick**
  - Meaning: Whether you can switch view's position by clicking on the small view.
  - Type: bool
- **smallViewPosition**
  - Meaning: Default position of small video view.
  - Type: ZegoViewPosition
- **margin**
  - Meaning: The margin of PIP view.
  - Type: EdgeInsets?
- **smallViewSize**
  - Meaning: The size of every small view.
  - Type: Size?
- **spacingBetweenSmallViews**
  - Meaning: The space between small views in multi-users mode.
  - Type: EdgeInsets?
- **isSmallViewsScrollable**
  - Meaning: Small video views is scrollable if set true in multi-users mode.
  - Type: bool
- **visibleSmallViewsCount**
  - Meaning: The visible small views count in multi-users mode.
  - Type: int
- **showNewScreenSharingViewInFullscreenMode**
  - Meaning: Whether to show the new screen sharing view in fullscreen mode.
  - Type: bool
- **showScreenSharingFullscreenModeToggleButtonRules**
  - Meaning: The rules for showing the fullscreen mode toggle button.
  - Type: ZegoShowFullscreenModeToggleButtonRules
- **bigViewUserID**
  - Meaning: User ID for Specifying Large View.
  - Type: String?

## ZegoViewPosition

Position of small audio video view.

- **topLeft**
- **topRight**
- **bottomLeft**
- **bottomRight**

## isScreenSharingExtraInfoKey

Extra info key for screen sharing.

- **Value**
  - Meaning: The key value.
  - Type: String ('isScreenSharing')

# Controls

## ZegoScreenSharingToggleButton

Button to toggle screen sharing.

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **iconStartSharing**
  - Meaning: Icon to start sharing.
  - Type: ButtonIcon?
- **iconStopSharing**
  - Meaning: Icon to stop sharing.
  - Type: ButtonIcon?
- **buttonSize**
  - Meaning: The size of button.
  - Type: Size?
- **iconSize**
  - Meaning: The size of button's icon.
  - Type: Size?
- **onPressed**
  - Meaning: Callback after pressed.
  - Type: void Function(bool isStart)?
- **canStart**
  - Meaning: Callback to check if can start sharing.
  - Type: bool Function()?

## ZegoSwitchAudioOutputButton

Button used to switch audio output button route between speaker or system device.

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **speakerIcon**
  - Meaning: Icon for speaker.
  - Type: ButtonIcon?
- **headphoneIcon**
  - Meaning: Icon for headphone.
  - Type: ButtonIcon?
- **bluetoothIcon**
  - Meaning: Icon for bluetooth.
  - Type: ButtonIcon?
- **onPressed**
  - Meaning: Callback after pressed.
  - Type: void Function(bool isON)?
- **defaultUseSpeaker**
  - Meaning: Whether to open speaker by default.
  - Type: bool
- **iconSize**
  - Meaning: The size of button's icon.
  - Type: Size?
- **buttonSize**
  - Meaning: The size of button.
  - Type: Size?

## ZegoSwitchCameraButton

Switch cameras.

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **onPressed**
  - Meaning: Callback after pressed.
  - Type: void Function(bool isFrontFacing)?
- **icon**
  - Meaning: The icon of the button.
  - Type: ButtonIcon?
- **defaultUseFrontFacingCamera**
  - Meaning: Whether to use the front-facing camera by default.
  - Type: bool
- **iconSize**
  - Meaning: The size of button's icon.
  - Type: Size?
- **buttonSize**
  - Meaning: The size of button.
  - Type: Size?

## ZegoToggleCameraButton

Button used to open/close camera.

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **normalIcon**
  - Meaning: Icon when camera is on.
  - Type: ButtonIcon?
- **offIcon**
  - Meaning: Icon when camera is off.
  - Type: ButtonIcon?
- **onPressed**
  - Meaning: Callback after pressed.
  - Type: void Function(bool isON)?
- **defaultOn**
  - Meaning: Whether to open camera by default.
  - Type: bool
- **iconSize**
  - Meaning: The size of button's icon.
  - Type: Size?
- **buttonSize**
  - Meaning: The size of button.
  - Type: Size?

## ZegoToggleMicrophoneButton

Button used to open/close microphone.

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **normalIcon**
  - Meaning: Icon when microphone is on.
  - Type: ButtonIcon?
- **offIcon**
  - Meaning: Icon when microphone is off.
  - Type: ButtonIcon?
- **onPressed**
  - Meaning: Callback after pressed.
  - Type: void Function(bool isON)?
- **defaultOn**
  - Meaning: Whether to open microphone by default.
  - Type: bool
- **iconSize**
  - Meaning: The size of button's icon.
  - Type: Size?
- **buttonSize**
  - Meaning: The size of button.
  - Type: Size?
- **muteMode**
  - Meaning: Only use mute, will not stop the stream.
  - Type: bool

## ZegoLeaveButton

Quit room/channel/group.

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **icon**
  - Meaning: The icon of the button.
  - Type: ButtonIcon?
  - Members:
    - **icon**
      - Meaning: The icon widget.
      - Type: Widget?
    - **backgroundColor**
      - Meaning: The background color of the icon.
      - Type: Color?
- **onLeaveConfirmation**
  - Meaning: Confirmation callback before leaving. Return true to exit.
  - Type: Future<bool?> Function(BuildContext context)?
- **onPress**
  - Meaning: Callback after pressed.
  - Type: VoidCallback?
- **quitDelegate**
  - Meaning: Custom quit logic.
  - Type: void Function(String roomID)?
- **iconSize**
  - Meaning: The size of button's icon.
  - Type: Size?
- **buttonSize**
  - Meaning: The size of button.
  - Type: Size?
- **clickableNotifier**
  - Meaning: Notifier to control clickability.
  - Type: ValueNotifier<bool>?

## ZegoMoreButton

More button of menu bar.

- **menuButtonListFunc**
  - Meaning: Function to return the list of menu buttons.
  - Type: List<Widget> Function()
- **icon**
  - Meaning: The icon of the button.
  - Type: ButtonIcon?
  - Members:
    - **icon**
      - Meaning: The icon widget.
      - Type: Widget?
    - **backgroundColor**
      - Meaning: The background color of the icon.
      - Type: Color?
- **menuItemSize**
  - Meaning: The size of each menu item.
  - Type: Size
- **menuItemCountPerRow**
  - Meaning: The number of buttons per row.
  - Type: int
- **menuRowHeight**
  - Meaning: The height of each menu row.
  - Type: double
- **menuBackgroundColor**
  - Meaning: The background color of the menu.
  - Type: Color
- **iconSize**
  - Meaning: The size of button's icon.
  - Type: Size?
- **buttonSize**
  - Meaning: The size of button.
  - Type: Size?
- **onSheetPopUp**
  - Meaning: Callback when the sheet pops up.
  - Type: Function(int)?
- **onSheetPop**
  - Meaning: Callback when the sheet pops.
  - Type: Function(int)?

## ZegoTextIconButton

Text button, icon button, or text+icon button.

- **text**
  - Meaning: The text of the button.
  - Type: String?
- **textStyle**
  - Meaning: The style of the text.
  - Type: TextStyle?
- **softWrap**
  - Meaning: Whether the text should break at soft line breaks.
  - Type: bool?
- **icon**
  - Meaning: The icon of the button.
  - Type: ButtonIcon?
  - Members:
    - **icon**
      - Meaning: The icon widget.
      - Type: Widget?
    - **backgroundColor**
      - Meaning: The background color of the icon.
      - Type: Color?
- **iconSize**
  - Meaning: The size of the icon.
  - Type: Size?
- **iconTextSpacing**
  - Meaning: The spacing between icon and text.
  - Type: double?
- **iconBorderColor**
  - Meaning: The border color of the icon.
  - Type: Color?
- **buttonSize**
  - Meaning: The size of the button.
  - Type: Size?
- **borderRadius**
  - Meaning: The border radius of the button.
  - Type: double?
- **margin**
  - Meaning: The margin of the button.
  - Type: EdgeInsetsGeometry?
- **padding**
  - Meaning: The padding of the button.
  - Type: EdgeInsetsGeometry?
- **onPressed**
  - Meaning: Callback when the button is pressed.
  - Type: VoidCallback?
- **clickableTextColor**
  - Meaning: Text color when clickable.
  - Type: Color?
- **unclickableTextColor**
  - Meaning: Text color when unclickable.
  - Type: Color?
- **clickableBackgroundColor**
  - Meaning: Background color when clickable.
  - Type: Color?
- **unclickableBackgroundColor**
  - Meaning: Background color when unclickable.
  - Type: Color?
- **verticalLayout**
  - Meaning: Whether to layout vertically.
  - Type: bool
- **networkLoadingConfig**
  - Meaning: Configuration for network loading state.
  - Type: ZegoNetworkLoadingConfig?
  - Members:
    - **enabled**
      - Meaning: Whether network loading is enabled.
      - Type: bool
    - **icon**
      - Meaning: Icon when network had error.
      - Type: Widget?
    - **iconColor**
      - Meaning: Color of the icon.
      - Type: Color?
    - **progressColor**
      - Meaning: Color of the progress indicator.
      - Type: Color?

# Member & Message

## ZegoMemberList

List of members in the room.

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **showMicrophoneState**
  - Meaning: Whether to show microphone state.
  - Type: bool
- **showCameraState**
  - Meaning: Whether to show camera state.
  - Type: bool
- **avatarBuilder**
  - Meaning: Builder for the avatar.
  - Type: ZegoAvatarBuilder?
- **itemBuilder**
  - Meaning: Builder for the list item.
  - Type: ZegoMemberListItemBuilder?
- **sortUserList**
  - Meaning: Sorter for the user list.
  - Type: ZegoMemberListSorter?
- **hiddenUserIDs**
  - Meaning: List of user IDs to hide.
  - Type: List<String>
- **stream**
  - Meaning: Stream of user list updates.
  - Type: Stream<List<ZegoUIKitUser>>?
- **pseudoUsers**
  - Meaning: List of pseudo users to display.
  - Type: List<ZegoUIKitUser>

## ZegoInRoomMessageView

View for displaying in-room messages.

- **stream**
  - Meaning: Stream of message updates.
  - Type: Stream<List<ZegoInRoomMessage>>
- **historyMessages**
  - Meaning: List of history messages.
  - Type: List<ZegoInRoomMessage>
- **itemBuilder**
  - Meaning: Builder for message items.
  - Type: ZegoInRoomMessageItemBuilder
- **scrollable**
  - Meaning: Whether the list is scrollable.
  - Type: bool
- **scrollController**
  - Meaning: Controller for scrolling.
  - Type: ScrollController?

## ZegoInRoomMessageInput

Input field for sending in-room messages.

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **placeHolder**
  - Meaning: Placeholder text.
  - Type: String
- **payloadAttributes**
  - Meaning: Custom attributes for the message.
  - Type: Map<String, String>?
- **backgroundColor**
  - Meaning: Background color of the input area.
  - Type: Color?
- **inputBackgroundColor**
  - Meaning: Background color of the input field.
  - Type: Color?
- **textColor**
  - Meaning: Text color.
  - Type: Color?
- **textHintColor**
  - Meaning: Hint text color.
  - Type: Color?
- **cursorColor**
  - Meaning: Cursor color.
  - Type: Color?
- **buttonColor**
  - Meaning: Send button color.
  - Type: Color?
- **borderRadius**
  - Meaning: Border radius of the input field.
  - Type: double?
- **enabled**
  - Meaning: Whether the input is enabled.
  - Type: bool
- **autofocus**
  - Meaning: Whether to autofocus.
  - Type: bool
- **onSubmit**
  - Meaning: Callback when message is submitted.
  - Type: VoidCallback?
- **valueNotifier**
  - Meaning: Notifier for the input value.
  - Type: ValueNotifier<String>?
- **focusNotifier**
  - Meaning: Notifier for the focus state.
  - Type: ValueNotifier<bool>?

## ZegoInRoomChatView

Chat view for displaying and sending messages.

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **avatarBuilder**
  - Meaning: Builder for the avatar.
  - Type: ZegoAvatarBuilder?
- **itemBuilder**
  - Meaning: Builder for message items.
  - Type: ZegoInRoomMessageItemBuilder?
- **scrollController**
  - Meaning: Controller for scrolling.
  - Type: ScrollController?

## ZegoInRoomMessageViewItem

Item view for a single message in the message list.

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **message**
  - Meaning: The message to display.
  - Type: ZegoInRoomMessage
- **isHorizontal**
  - Meaning: Whether to layout horizontally.
  - Type: bool
- **showName**
  - Meaning: Whether to show the user name.
  - Type: bool
- **showAvatar**
  - Meaning: Whether to show the avatar.
  - Type: bool
- **namePrefix**
  - Meaning: Prefix for the user name.
  - Type: String?
- **avatarBuilder**
  - Meaning: Builder for the avatar.
  - Type: ZegoAvatarBuilder?
- **resendIcon**
  - Meaning: Icon for the resend button.
  - Type: Widget?
- **borderRadius**
  - Meaning: Border radius of the item.
  - Type: BorderRadiusGeometry?
- **paddings**
  - Meaning: Padding of the item.
  - Type: EdgeInsetsGeometry?
- **opacity**
  - Meaning: Opacity of the background.
  - Type: double?
- **backgroundColor**
  - Meaning: Background color of the item.
  - Type: Color?
- **maxLines**
  - Meaning: Maximum lines for the message text.
  - Type: int?
- **nameTextStyle**
  - Meaning: Style for the user name text.
  - Type: TextStyle?
- **messageTextStyle**
  - Meaning: Style for the message text.
  - Type: TextStyle?
- **onItemClick**
  - Meaning: Callback when the item is clicked.
  - Type: ZegoInRoomMessageViewItemPressEvent?
- **onItemLongPress**
  - Meaning: Callback when the item is long pressed.
  - Type: ZegoInRoomMessageViewItemPressEvent?

## ZegoInRoomNotificationView

View for displaying in-room notifications (join/leave, etc.).

- **roomID**
  - Meaning: The ID of the room.
  - Type: String
- **maxCount**
  - Meaning: Maximum number of notifications to show.
  - Type: int
- **itemMaxLine**
  - Meaning: Maximum lines per notification item.
  - Type: int
- **itemDisappearTime**
  - Meaning: Time in milliseconds before an item disappears.
  - Type: int
- **notifyUserLeave**
  - Meaning: Whether to notify when a user leaves.
  - Type: bool
- **userJoinItemBuilder**
  - Meaning: Builder for user join notifications.
  - Type: ZegoNotificationUserItemBuilder?
- **userLeaveItemBuilder**
  - Meaning: Builder for user leave notifications.
  - Type: ZegoNotificationUserItemBuilder?
- **itemBuilder**
  - Meaning: Builder for custom notifications.
  - Type: ZegoNotificationMessageItemBuilder?

## ZegoInRoomNotificationViewItem

Item view for a single notification.

- **user**
  - Meaning: The user associated with the notification.
  - Type: ZegoUIKitUser
- **message**
  - Meaning: The notification message.
  - Type: String
- **prefix**
  - Meaning: Prefix for the notification.
  - Type: String?
- **maxLines**
  - Meaning: Maximum lines for the text.
  - Type: int?
- **isHorizontal**
  - Meaning: Whether to layout horizontally.
  - Type: bool

# Effect

## ZegoBeautyEffectSlider

Slider for adjusting beauty effects.

- **effectType**
  - Meaning: The type of beauty effect.
  - Type: BeautyEffectType
- **defaultValue**
  - Meaning: The default value of the effect.
  - Type: int
- **thumpHeight**
  - Meaning: The height of the thumb.
  - Type: double?
- **trackHeight**
  - Meaning: The height of the track.
  - Type: double?
- **labelFormatFunc**
  - Meaning: Function to format the label.
  - Type: String Function(int)?
- **textStyle**
  - Meaning: The style of the text displayed on the Slider's thumb.
  - Type: TextStyle?
- **textBackgroundColor**
  - Meaning: The background color of the text displayed on the Slider's thumb.
  - Type: Color?
- **activeTrackColor**
  - Meaning: The color of the track that is active when sliding the Slider.
  - Type: Color?
- **inactiveTrackColor**
  - Meaning: The color of the track that is inactive when sliding the Slider.
  - Type: Color?
- **thumbColor**
  - Meaning: The color of the Slider's thumb.
  - Type: Color?
- **thumbRadius**
  - Meaning: The radius of the Slider's thumb.
  - Type: double?

# Widgets

## ZegoDraggableBottomSheet

Partially visible bottom sheet that can be dragged into the screen.

- **alignment**
  - Meaning: Alignment of the sheet.
  - Type: Alignment
- **backgroundWidget**
  - Meaning: This widget will hide behind the sheet when expanded.
  - Type: Widget?
- **blurBackground**
  - Meaning: Whether to blur the background while sheet expansion.
  - Type: bool
- **expandedChild**
  - Meaning: Child of expended sheet.
  - Type: Widget?
- **expansionExtent**
  - Meaning: Extent from the min-height to change from previewChild to expandedChild.
  - Type: double
- **maxExtent**
  - Meaning: Max-extent for sheet expansion.
  - Type: double
- **minExtent**
  - Meaning: Min-extent for the sheet, also the original height of the sheet.
  - Type: double
- **previewChild**
  - Meaning: Child to be displayed when sheet is not expended.
  - Type: Widget?
- **scrollDirection**
  - Meaning: Scroll direction of the sheet.
  - Type: Axis

## ZegoInputBoardWrapper

Wrapper to handle input board visibility.

- **child**
  - Meaning: The child widget.
  - Type: Widget

## ZegoSlider

A custom slider widget.

- **defaultValue**
  - Meaning: The default value.
  - Type: int
- **onChanged**
  - Meaning: Callback when value changes.
  - Type: void Function(double value)?
- **thumpHeight**
  - Meaning: The height of the thumb.
  - Type: double?
- **trackHeight**
  - Meaning: The height of the track.
  - Type: double?
- **labelFormatFunc**
  - Meaning: Function to format the label.
  - Type: String Function(int)?
- **textStyle**
  - Meaning: The style of the text displayed on the Slider's thumb.
  - Type: TextStyle?
- **textBackgroundColor**
  - Meaning: The background color of the text displayed on the Slider's thumb.
  - Type: Color?
- **activeTrackColor**
  - Meaning: The color of the track that is active when sliding the Slider.
  - Type: Color?
- **inactiveTrackColor**
  - Meaning: The color of the track that is inactive when sliding the Slider.
  - Type: Color?
- **thumbColor**
  - Meaning: The color of the Slider's thumb.
  - Type: Color?
- **thumbRadius**
  - Meaning: The radius of the Slider's thumb.
  - Type: double?

## ZegoNetworkLoading

Widget to display network loading state.

- **child**
  - Meaning: The child widget.
  - Type: Widget
- **config**
  - Meaning: Configuration for network loading.
  - Type: ZegoNetworkLoadingConfig?
  - Members:
    - **enabled**
      - Meaning: Whether enabled.
      - Type: bool
    - **icon**
      - Meaning: Icon when network had error.
      - Type: Widget?
    - **iconColor**
      - Meaning: Color of the icon.
      - Type: Color?
    - **progressColor**
      - Meaning: Color of the progress indicator.
      - Type: Color?

## ZegoLoadingIndicator

A custom loading indicator widget.

- **text**
  - Meaning: The text to display below the loading indicator.
  - Type: String

## ZegoServiceValueIcon

Icon that changes based on a value notifier.

- **notifier**
  - Meaning: Notifier for the value.
  - Type: ValueNotifier<bool>
- **normalIcon**
  - Meaning: Icon for the normal state (false).
  - Type: Image
- **checkedIcon**
  - Meaning: Icon for the checked state (true).
  - Type: Image

## ValueNotifierSliderVisibility

Widget to control visibility with animation based on a value notifier.

- **child**
  - Meaning: The child widget.
  - Type: Widget
- **visibilityNotifier**
  - Meaning: Notifier for visibility.
  - Type: ValueNotifier<bool>
- **animationDuration**
  - Meaning: Duration of the animation.
  - Type: Duration
- **beginOffset**
  - Meaning: Begin offset for slide transition.
  - Type: Offset
- **endOffset**
  - Meaning: End offset for slide transition.
  - Type: Offset


## ZegoScreenUtilInit

A helper widget that initializes ZegoScreenUtil.

- **builder**
  - Meaning: Builder for the child.
  - Type: ZegoScreenUtilInitBuilder?
- **child**
  - Meaning: The child widget.
  - Type: Widget?
- **rebuildFactor**
  - Meaning: The factor to rebuild the widget.
  - Type: ZegoRebuildFactor
- **designSize**
  - Meaning: The Size of the device in the design draft, in dp.
  - Type: Size
- **splitScreenMode**
  - Meaning: Whether to support split screen mode.
  - Type: bool
- **minTextAdapt**
  - Meaning: Whether to support minimum text adaptation.
  - Type: bool
- **useInheritedMediaQuery**
  - Meaning: Whether to use inherited media query.
  - Type: bool
- **ensureScreenSize**
  - Meaning: Whether to ensure screen size.
  - Type: bool?
- **responsiveWidgets**
  - Meaning: The widgets that need to be responsive.
  - Type: Iterable<String>?
- **fontSizeResolver**
  - Meaning: The resolver for font size.
  - Type: ZegoFontSizeResolver


# Functions

## showAlertDialog

Show an alert dialog.

- **context**
  - Meaning: The context.
  - Type: BuildContext?
- **title**
  - Meaning: The title of the dialog.
  - Type: String
- **content**
  - Meaning: The content of the dialog.
  - Type: String
- **actions**
  - Meaning: The actions of the dialog.
  - Type: List<Widget>
- **titleStyle**
  - Meaning: The style of the title.
  - Type: TextStyle?
- **contentStyle**
  - Meaning: The style of the content.
  - Type: TextStyle?
- **actionsAlignment**
  - Meaning: The alignment of the actions.
  - Type: MainAxisAlignment?
- **backgroundColor**
  - Meaning: The background color.
  - Type: Color?
- **backgroundBrightness**
  - Meaning: The brightness of the background.
  - Type: Brightness?

## showTopModalSheet

Show a modal sheet from the top.

- **context**
  - Meaning: The context.
  - Type: BuildContext?
- **widget**
  - Meaning: The widget to display.
  - Type: Widget
- **barrierDismissible**
  - Meaning: Whether the barrier is dismissible.
  - Type: bool

## getTextSize

Calculate the size of the text.

- **text**
  - Meaning: The text.
  - Type: String
- **textStyle**
  - Meaning: The style of the text.
  - Type: TextStyle
