# Components

- [Audio &amp; Video](#audio--video)
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
  - [ZegoScreenSharingCountdownTimer](#zegoscreensharingcountdowntimer)
  - [ZegoUIKitMediaWaveform](#zegouikitmediawaveform)
  - [ZegoRippleAvatar](#zegorippleavatar)
  - [ZegoLayoutPIPSmallItemList](#zegolayoutpipsmallitemlist)
  - [ZegoLayoutPIPSmallItem](#zegolayoutpipsmallitem)
  - [ZegoLayoutGalleryLastItem](#zegolayoutgallerylastitem)
- [Hall Room](#hall-room)
  - [ZegoUIKitHallRoomList](#zegouikithallroomlist)
  - [ZegoUIKitHallRoomListConfig](#zegouikithallroomlistconfig)
  - [ZegoUIKitHallRoomListStyle](#zegouikithallroomliststyle)
  - [ZegoUIKitHallRoomListItemStyle](#zegouikithallroomlistitemstyle)
  - [ZegoUIKitHallRoomListController](#zegouikithallroomlistcontroller)
- [Controls](#controls)
  - [ZegoScreenSharingToggleButton](#zegoscreensharingtogglebutton)
  - [ZegoSwitchAudioOutputButton](#zegoswitchaudiooutputbutton)
  - [ZegoSwitchCameraButton](#zegoswitchcamerabutton)
  - [ZegoToggleCameraButton](#zegotogglecamerabutton)
  - [ZegoToggleMicrophoneButton](#zegotogglemicrophonebutton)
  - [ZegoLeaveButton](#zegoleavebutton)
  - [ZegoMoreButton](#zegomorebutton)
  - [ZegoTextIconButton](#zegotexticonbutton)
- [Member &amp; Message](#member--message)
  - [ZegoMemberList](#zegomemberlist)
  - [ZegoInRoomMessageView](#zegoinroommessageview)
  - [ZegoInRoomMessageInput](#zegoinroommessageinput)
  - [ZegoInRoomChatView](#zegoinroomchatview)
  - [ZegoInRoomMessageViewItem](#zegoinroommessageviewitem)
  - [ZegoInRoomNotificationView](#zegoinroomnotificationview)
  - [ZegoInRoomNotificationViewItem](#zegoinroomnotificationviewitem)
  - [ZegoInRoomChatViewItem](#zegoinroomchatviewitem)
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
  - [ZegoUIKitFlipTransition](#zegouikitfliptransition)
  - [ZegoScreenUtilInit](#zegoscreenutilinit)
- [Functions](#functions)
  - [showAlertDialog](#showalertdialog)
  - [showTopModalSheet](#showtopmodalsheet)
  - [getTextSize](#gettextsize)

---

# Audio & Video

## ZegoAudioVideoView

Display user audio and video information.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | user | The user whose stream needs to be rendered. | `ZegoUIKitUser?` | Required |
  | foregroundBuilder | Foreground builder, you can display something you want on top of the view, foreground will always show. | `ZegoAudioVideoViewForegroundBuilder?` | `null` |
  | backgroundBuilder | Background builder, you can display something when user close camera. | `ZegoAudioVideoViewBackgroundBuilder?` | `null` |
  | borderRadius | The border radius of the view. | `double?` | `null` |
  | borderColor | The border color of the view. | `Color?` | `null` |
  | extraInfo | Additional information. | `Map<String, dynamic>?` | `null` |
  | avatarConfig | Configuration for the avatar. | `ZegoAvatarConfig?` | `null` |
  | onTap | Callback when the view is tapped. | `void Function(ZegoUIKitUser? user)?` | `null` |

## ZegoScreenSharingView

Display user screensharing information.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | user | The user who is sharing the screen. | `ZegoUIKitUser?` | Required |
  | foregroundBuilder | Foreground builder, you can display something you want on top of the view, foreground will always show. | `ZegoAudioVideoViewForegroundBuilder?` | `null` |
  | backgroundBuilder | Background builder, you can display something when user close camera. | `ZegoAudioVideoViewBackgroundBuilder?` | `null` |
  | borderRadius | The border radius of the view. | `double?` | `null` |
  | borderColor | The color of the border. | `Color` | `Color(0xffA4A4A4)` |
  | extraInfo | Extra info. | `Map<String, dynamic>` | `{}` |
  | showFullscreenModeToggleButtonRules | The rules for showing the fullscreen mode toggle button. | `ZegoShowFullscreenModeToggleButtonRules` | `ZegoShowFullscreenModeToggleButtonRules.showWhenScreenPressed` |
  | controller | The controller for the screen sharing view. | `ZegoScreenSharingViewController?` | `null` |

## ZegoAudioVideoContainer

Container of audio video view, it will layout views by layout mode and config.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | layout | Layout configuration. | `ZegoLayout` | Required |
  | foregroundBuilder | Foreground builder of audio video view. | `ZegoAudioVideoViewForegroundBuilder?` | `null` |
  | backgroundBuilder | Background builder of audio video view. | `ZegoAudioVideoViewBackgroundBuilder?` | `null` |
  | sortAudioVideo | Sorter for audio video views. | `ZegoAudioVideoViewSorter?` | `null` |
  | filterAudioVideo | Filter for audio video views. | `ZegoAudioVideoViewFilter?` | `null` |
  | avatarConfig | Configuration for the avatar. | `ZegoAvatarConfig?` | `null` |
  | screenSharingViewController | Controller for screen sharing view. | `ZegoScreenSharingViewController?` | `null` |
  | virtualUsersNotifier | Notifier for virtual users. | `ValueNotifier<List<ZegoUIKitUser>>?` | `null` |
  | sources | Sources to display. | `List<ZegoAudioVideoContainerSource>` | `[audioVideo, screenSharing]` |
  | onUserListUpdated | Callback when the user list is updated. | `void Function(List<ZegoUIKitUser> userList)?` | `null` |

## ZegoUIKitMediaContainer

Container of media (audio/video).

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | foregroundBuilder | Foreground builder of audio video view. | `ZegoAudioVideoViewForegroundBuilder?` | `null` |
  | backgroundBuilder | Background builder of audio video view. | `ZegoAudioVideoViewBackgroundBuilder?` | `null` |

## ZegoUIKitMediaPlayer

You can use this control to play audio or video.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | size | Size of this widget display on parent. | `Size` | Required |
  | config | Configuration for the media player. | `ZegoUIKitMediaPlayerConfig` | Required |
  | filePathOrURL | Load the absolute path to the local resource or the URL of the network resource. If null, will pop-up and pick files from local. | `String?` | `null` |
  | initPosition | Top-left position display this widget on parent widget. | `Offset?` | `null` |
  | style | Style configuration for the media player. | `ZegoUIKitMediaPlayerStyle?` | `null` |
  | event | Event callbacks for the media player. | `ZegoUIKitMediaPlayerEvent?` | `null` |

## ZegoUIKitMediaView

Display user media view.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | user | The user whose stream needs to be rendered. | `ZegoUIKitUser?` | Required |
  | backgroundBuilder | Background builder, you can display something when user close camera. | `ZegoAudioVideoViewBackgroundBuilder?` | `null` |
  | foregroundBuilder | Foreground builder, you can display something you want on top of the view, foreground will always show. | `ZegoAudioVideoViewForegroundBuilder?` | `null` |
  | borderRadius | The border radius of the view. | `double?` | `null` |
  | borderColor | The border color of the view. | `Color?` | `null` |
  | extraInfo | Additional information. | `Map<String, dynamic>?` | `null` |

## ZegoLayoutGallery

Gallery layout.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | maxItemCount | The maximum number of items. | `int` | Required |
  | userList | The list of users to display. | `List<ZegoUIKitUser>` | Required |
  | layoutConfig | Configuration for the gallery layout. | `ZegoLayoutGalleryConfig` | Required |
  | backgroundColor | The background color. | `Color` | `Color(0xff171821)` |
  | foregroundBuilder | Foreground builder. | `ZegoAudioVideoViewForegroundBuilder?` | `null` |
  | backgroundBuilder | Background builder. | `ZegoAudioVideoViewBackgroundBuilder?` | `null` |
  | avatarConfig | Configuration for the avatar. | `ZegoAvatarConfig?` | `null` |
  | screenSharingViewController | Controller for screen sharing view. | `ZegoScreenSharingViewController?` | `null` |

## ZegoLayoutPictureInPicture

Picture in picture layout.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | userList | The list of users to display. | `List<ZegoUIKitUser>` | Required |
  | layoutConfig | Configuration for the PiP layout. | `ZegoLayoutPictureInPictureConfig` | Required |
  | foregroundBuilder | Foreground builder. | `ZegoAudioVideoViewForegroundBuilder?` | `null` |
  | backgroundBuilder | Background builder. | `ZegoAudioVideoViewBackgroundBuilder?` | `null` |
  | avatarConfig | Configuration for the avatar. | `ZegoAvatarConfig?` | `null` |

## ZegoAvatar

Display user avatar.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | avatarSize | The size of the avatar. | `Size` | Required |
  | user | The user to display. | `ZegoUIKitUser?` | `null` |
  | showAvatar | Whether to show the avatar. | `bool` | `true` |
  | showSoundLevel | Whether to show sound level ripple. | `bool` | `false` |
  | soundLevelSize | The size of the sound level ripple. | `Size?` | `null` |
  | soundLevelColor | The color of the sound level ripple. | `Color?` | `null` |
  | avatarBuilder | Custom builder for the avatar. | `ZegoAvatarBuilder?` | `null` |
  | mixerStreamID | Stream ID for mixer. | `String?` | `null` |

## ZegoCameraStateIcon

Monitor the camera status changes, when the status changes, the corresponding icon is automatically switched.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | targetUser | The user to monitor. | `ZegoUIKitUser?` | Required |
  | iconCameraOn | Icon when camera is on. | `Image?` | `null` |
  | iconCameraOff | Icon when camera is off. | `Image?` | `null` |

## ZegoMicrophoneStateIcon

Monitor the microphone status changes, when the status changes, the corresponding icon is automatically switched.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | targetUser | The user to monitor. | `ZegoUIKitUser?` | Required |
  | iconMicrophoneOn | Icon when microphone is on. | `Image?` | `null` |
  | iconMicrophoneOff | Icon when microphone is off. | `Image?` | `null` |
  | iconMicrophoneSpeaking | Icon when microphone is speaking. | `Image?` | `null` |

## ZegoScreenSharingViewController

Controller for screen sharing view.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | fullscreenUserNotifier | Notifier for the user who is in full-screen mode. | `ValueNotifier<ZegoUIKitUser?>` | Required |
  | showScreenSharingViewInFullscreenMode | Specify whether a certain user enters or exits full-screen mode during screen sharing. | `void Function(String userID, bool isFullscreen, {required String targetRoomID})` | Required |

## ZegoScreenSharingCountdownTimer

Countdown timer for screen sharing.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | seconds | The countdown duration in seconds. | `int` | Required |
  | textColor | The text color. | `Color?` | `null` |
  | progressColor | The progress indicator color. | `Color?` | `null` |
  | secondFontSize | The font size for the seconds. | `double?` | `null` |
  | tipsFontSize | The font size for the tips. | `double?` | `null` |
  | tips | The tips text. | `String?` | `null` |
  | onCountDownFinished | Callback when countdown finishes. | `VoidCallback?` | `null` |

## ZegoUIKitMediaWaveform

Visualizes sound level as a waveform.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | soundLevelStream | The stream of sound levels. | `Stream<double>` | Required |
  | playStateNotifier | Notifier for media play state. | `ValueNotifier<ZegoUIKitMediaPlayState>` | Required |

## ZegoRippleAvatar

Avatar with ripple animation based on sound level.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | user | The user to display. | `ZegoUIKitUser?` | Required |
  | child | The child widget (avatar). | `Widget` | Required |
  | color | The ripple color. | `Color?` | `null` |
  | minRadius | The minimum radius. | `double` | `60` |
  | radiusIncrement | The radius increment. | `double` | `0.2` |
  | mixerStreamID | The mixer stream ID. | `String?` | `null` |

## ZegoScreenSharingCountDownStopSettings

Configuration for screen sharing countdown stop.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | support | Whether to support countdown stop. | `bool` | Required |
  | tips | The tips to display. | `String` | Required |
  | seconds | The countdown seconds. | `int` | Required |
  | textColor | The color of the text. | `Color?` | `null` |
  | progressColor | The color of the progress. | `Color?` | `null` |
  | secondFontSize | The font size of the second. | `double?` | `null` |
  | tipsFontSize | The font size of the tips. | `double?` | `null` |
  | onCountDownFinished | Callback when countdown finished. | `VoidCallback?` | `null` |

## ZegoScreenSharingAutoStopSettings

Configuration for screen sharing auto stop.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | invalidCount | Count of the check fails before automatically end the screen sharing. | `int` | Required |
  | canEnd | Determines whether to end. | `bool Function()?` | `null` |

## ZegoLayoutGalleryConfig

Configuration for gallery layout.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | showOnlyOnAudioVideo | Show audio video view only open camera or microphone. | `bool` | `false` |
  | addBorderRadiusAndSpacingBetweenView | Whether to display rounded corners and spacing between views. | `bool` | `true` |
  | margin | The margin of layout. | `EdgeInsetsGeometry` | `EdgeInsets.all(2.0)` |
  | showNewScreenSharingViewInFullscreenMode | Whether to show the new screen sharing view in fullscreen mode. | `bool` | `true` |
  | showScreenSharingFullscreenModeToggleButtonRules | The rules for showing the fullscreen mode toggle button. | `ZegoShowFullscreenModeToggleButtonRules` | `ZegoShowFullscreenModeToggleButtonRules.showWhenScreenPressed` |

## ZegoLayoutPictureInPictureConfig

Configuration for Picture-in-Picture layout.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | isSmallViewDraggable | Small video view is draggable if set true in one-on-one mode. | `bool` | `true` |
  | switchLargeOrSmallViewByClick | Whether you can switch view's position by clicking on the small view. | `bool` | `true` |
  | smallViewPosition | Default position of small video view. | `ZegoViewPosition` | `ZegoViewPosition.topRight` |
  | margin | The margin of PIP view. | `EdgeInsets?` | `null` |
  | smallViewSize | The size of every small view. | `Size?` | `null` |
  | spacingBetweenSmallViews | The space between small views in multi-users mode. | `EdgeInsets?` | `null` |
  | isSmallViewsScrollable | Small video views is scrollable if set true in multi-users mode. | `bool` | `true` |
  | visibleSmallViewsCount | The visible small views count in multi-users mode. | `int` | `3` |
  | showNewScreenSharingViewInFullscreenMode | Whether to show the new screen sharing view in fullscreen mode. | `bool` | `true` |
  | showScreenSharingFullscreenModeToggleButtonRules | The rules for showing the fullscreen mode toggle button. | `ZegoShowFullscreenModeToggleButtonRules` | `ZegoShowFullscreenModeToggleButtonRules.showWhenScreenPressed` |
  | bigViewUserID | User ID for Specifying Large View. | `String?` | `null` |

## ZegoViewPosition

Position of small audio video view.

| Name | Description | Value |
| :--- | :--- | :--- |
| topLeft | Top left position. | - |
| topRight | Top right position. | - |
| bottomLeft | Bottom left position. | - |
| bottomRight | Bottom right position. | - |

## isScreenSharingExtraInfoKey

Extra info key for screen sharing.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | value | The key value. | `String` | `'isScreenSharing'` |

## ZegoLayoutPIPSmallItemList

A list of small views in Picture-in-Picture (PIP) layout.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | targetUsers | The list of users to display. | `List<ZegoUIKitUser>` | Required |
  | defaultPosition | The default position of the small views. | `ZegoViewPosition` | Required |
  | showOnlyVideo | Whether to show only video. | `bool` | `false` |
  | onTap | Callback when a user is tapped. | `void Function(ZegoUIKitUser user)` | `null` |
  | visibleItemCount | The number of visible items. | `int` | `3` |
  | scrollable | Whether the list is scrollable. | `bool` | `true` |
  | foregroundBuilder | Builder for the foreground. | `ZegoAudioVideoViewForegroundBuilder?` | `null` |
  | backgroundBuilder | Builder for the background. | `ZegoAudioVideoViewBackgroundBuilder?` | `null` |
  | borderRadius | The border radius. | `double?` | `null` |
  | spacingBetweenSmallViews | The spacing between small views. | `EdgeInsets?` | `null` |
  | size | The size of the widget. | `Size?` | `null` |
  | margin | The margin of the widget. | `EdgeInsets?` | `null` |
  | avatarConfig | Configuration for the avatar. | `ZegoAvatarConfig?` | `null` |

## ZegoLayoutPIPSmallItem

A single small view in Picture-in-Picture (PIP) layout.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | targetUser | The user to display. | `ZegoUIKitUser?` | Required |
  | localUser | The local user. | `ZegoUIKitUser` | Required |
  | defaultPosition | The default position of the view. | `ZegoViewPosition` | Required |
  | draggable | Whether the view is draggable. | `bool` | Required |
  | showOnlyVideo | Whether to show only video. | `bool` | `false` |
  | onTap | Callback when the view is tapped. | `void Function(ZegoUIKitUser? user)` | `null` |
  | foregroundBuilder | Builder for the foreground. | `ZegoAudioVideoViewForegroundBuilder?` | `null` |
  | backgroundBuilder | Builder for the background. | `ZegoAudioVideoViewBackgroundBuilder?` | `null` |
  | borderRadius | The border radius. | `double?` | `null` |
  | size | The size of the widget. | `Size?` | `null` |
  | margin | The margin of the widget. | `EdgeInsets?` | `null` |
  | avatarConfig | Configuration for the avatar. | `ZegoAvatarConfig?` | `null` |

## ZegoLayoutGalleryLastItem

The last item in the Gallery layout, usually displaying "X others".

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | users | The list of remaining users. | `List<ZegoUIKitUser>` | Required |
  | borderColor | The border color. | `Color?` | `null` |
  | borderRadius | The border radius. | `double?` | `null` |
  | backgroundColor | The background color. | `Color?` | `null` |

# Hall Room

## ZegoUIKitHallRoomList

Display user audio and video information without join room(live/conference), usually used for live room preview list (like TikTok).

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | appID | App ID. | `int` | Required |
  | appSign | App Sign. | `String` | Required |
  | token | Token. | `String` | Required |
  | userID | User ID. | `String` | Required |
  | userName | User Name. | `String` | Required |
  | controller | Controller for the hall room list. | `ZegoUIKitHallRoomListController` | Required |
  | model | Data model for the list (host ID and live ID). | `ZegoUIKitHallRoomListModel?` | `null` |
  | modelDelegate | Delegate for data management if model is not used. | `ZegoUIKitHallRoomListModelDelegate?` | `null` |
  | scenario | Scenario. | `ZegoUIKitScenario` | Required |
  | style | Style configuration. | `ZegoUIKitHallRoomListStyle?` | `null` |
  | config | Configuration parameters. | `ZegoUIKitHallRoomListConfig?` | `null` |

## ZegoUIKitHallRoomListConfig

Configuration parameters for Hall Room List.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | video | Video configuration (resolution, frame rate, etc.). | `ZegoUIKitVideoConfig?` | `null` |
  | streamMode | Stream mode. | `ZegoUIKitHallRoomStreamMode` | Required |
  | audioVideoResourceMode | Audio video resource mode. | `ZegoUIKitStreamResourceMode?` | `null` |

## ZegoUIKitHallRoomListStyle

Style configuration for Hall Room List.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | loadingBuilder | Builder for loading view. | `Widget? Function(BuildContext context)?` | `null` |
  | item | Item style. | `ZegoUIKitHallRoomListItemStyle` | Required |

## ZegoUIKitHallRoomListItemStyle

Style for Hall Room List Item.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | foregroundBuilder | Builder for foreground view. | `Widget Function(BuildContext, Size, ZegoUIKitUser?, String)?` | `null` |
  | backgroundBuilder | Builder for background view. | `Widget Function(BuildContext, Size, ZegoUIKitUser?, String)?` | `null` |
  | loadingBuilder | Builder for loading view per item. | `Widget? Function(BuildContext, ZegoUIKitUser?, String)?` | `null` |
  | avatar | Avatar configuration. | `ZegoAvatarConfig?` | `null` |

## ZegoUIKitHallRoomListController

Controller for the hall room list.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | moveStreamToTheirRoom | Switches from the hall room to a specific live room. | `Future<bool> Function()` | Required |
  | moveStreamToHall | Restore from live room to hall. | `Future<void> Function({bool Function(String)? ignoreFilter})` | Required |
  | roomID | The current room ID. | `String` | Required |
  | sdkInitNotifier | Notifier for SDK initialization status. | `ValueNotifier<bool>` | Required |
  | roomLoginNotifier | Notifier for room login status. | `ValueNotifier<bool>` | Required |

# Controls

## ZegoScreenSharingToggleButton

Button to toggle screen sharing.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | iconStartSharing | Icon to start sharing. | `ButtonIcon?` | `null` |
  | iconStopSharing | Icon to stop sharing. | `ButtonIcon?` | `null` |
  | buttonSize | The size of button. | `Size?` | `null` |
  | iconSize | The size of button's icon. | `Size?` | `null` |
  | onPressed | Callback after pressed. | `void Function(bool isStart)?` | `null` |
  | canStart | Callback to check if can start sharing. | `bool Function()?` | `null` |

## ZegoSwitchAudioOutputButton

Button used to switch audio output button route between speaker or system device.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | speakerIcon | Icon for speaker. | `ButtonIcon?` | `null` |
  | headphoneIcon | Icon for headphone. | `ButtonIcon?` | `null` |
  | bluetoothIcon | Icon for bluetooth. | `ButtonIcon?` | `null` |
  | onPressed | Callback after pressed. | `void Function(bool isON)?` | `null` |
  | defaultUseSpeaker | Whether to open speaker by default. | `bool` | `true` |
  | iconSize | The size of button's icon. | `Size?` | `null` |
  | buttonSize | The size of button. | `Size?` | `null` |

## ZegoSwitchCameraButton

Switch cameras.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | onPressed | Callback after pressed. | `void Function(bool isFrontFacing)?` | `null` |
  | icon | The icon of the button. | `ButtonIcon?` | `null` |
  | defaultUseFrontFacingCamera | Whether to use the front-facing camera by default. | `bool` | `true` |
  | iconSize | The size of button's icon. | `Size?` | `null` |
  | buttonSize | The size of button. | `Size?` | `null` |

## ZegoToggleCameraButton

Button used to open/close camera.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | normalIcon | Icon when camera is on. | `ButtonIcon?` | `null` |
  | offIcon | Icon when camera is off. | `ButtonIcon?` | `null` |
  | onPressed | Callback after pressed. | `void Function(bool isON)?` | `null` |
  | defaultOn | Whether to open camera by default. | `bool` | `true` |
  | iconSize | The size of button's icon. | `Size?` | `null` |
  | buttonSize | The size of button. | `Size?` | `null` |

## ZegoToggleMicrophoneButton

Button used to open/close microphone.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | normalIcon | Icon when microphone is on. | `ButtonIcon?` | `null` |
  | offIcon | Icon when microphone is off. | `ButtonIcon?` | `null` |
  | onPressed | Callback after pressed. | `void Function(bool isON)?` | `null` |
  | defaultOn | Whether to open microphone by default. | `bool` | `true` |
  | iconSize | The size of button's icon. | `Size?` | `null` |
  | buttonSize | The size of button. | `Size?` | `null` |
  | muteMode | Only use mute, will not stop the stream. | `bool` | `false` |

## ZegoLeaveButton

Quit room/channel/group.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | icon | The icon of the button. | `ButtonIcon?` | `null` |
  | onLeaveConfirmation | Confirmation callback before leaving. Return true to exit. | `Future<bool?> Function(BuildContext context)?` | `null` |
  | onPress | Callback after pressed. | `VoidCallback?` | `null` |
  | quitDelegate | Custom quit logic. | `void Function(String roomID)?` | `null` |
  | iconSize | The size of button's icon. | `Size?` | `null` |
  | buttonSize | The size of button. | `Size?` | `null` |
  | clickableNotifier | Notifier to control clickability. | `ValueNotifier<bool>?` | `null` |

## ZegoMoreButton

More button of menu bar.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | menuButtonListFunc | Function to return the list of menu buttons. | `List<Widget> Function()` | Required |
  | icon | The icon of the button. | `ButtonIcon?` | `null` |
  | menuItemSize | The size of each menu item. | `Size` | Required |
  | menuItemCountPerRow | The number of buttons per row. | `int` | Required |
  | menuRowHeight | The height of each menu row. | `double` | Required |
  | menuBackgroundColor | The background color of the menu. | `Color` | Required |
  | iconSize | The size of button's icon. | `Size?` | `null` |
  | buttonSize | The size of button. | `Size?` | `null` |
  | onSheetPopUp | Callback when the sheet pops up. | `Function(int)?` | `null` |
  | onSheetPop | Callback when the sheet pops. | `Function(int)?` | `null` |

## ZegoTextIconButton

Text button, icon button, or text+icon button.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | text | The text of the button. | `String?` | `null` |
  | textStyle | The style of the text. | `TextStyle?` | `null` |
  | softWrap | Whether the text should break at soft line breaks. | `bool?` | `null` |
  | icon | The icon of the button. | `ButtonIcon?` | `null` |
  | iconSize | The size of the icon. | `Size?` | `null` |
  | iconTextSpacing | The spacing between icon and text. | `double?` | `null` |
  | iconBorderColor | The border color of the icon. | `Color?` | `null` |
  | buttonSize | The size of the button. | `Size?` | `null` |
  | borderRadius | The border radius of the button. | `double?` | `null` |
  | margin | The margin of the button. | `EdgeInsetsGeometry?` | `null` |
  | padding | The padding of the button. | `EdgeInsetsGeometry?` | `null` |
  | onPressed | Callback when the button is pressed. | `VoidCallback?` | `null` |
  | clickableTextColor | Text color when clickable. | `Color?` | `null` |
  | unclickableTextColor | Text color when unclickable. | `Color?` | `null` |
  | clickableBackgroundColor | Background color when clickable. | `Color?` | `null` |
  | unclickableBackgroundColor | Background color when unclickable. | `Color?` | `null` |
  | verticalLayout | Whether to layout vertically. | `bool` | `false` |
  | networkLoadingConfig | Configuration for network loading state. | `ZegoNetworkLoadingConfig?` | `null` |

# Member & Message

## ZegoMemberList

List of members in the room.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | showMicrophoneState | Whether to show microphone state. | `bool` | `true` |
  | showCameraState | Whether to show camera state. | `bool` | `true` |
  | avatarBuilder | Builder for the avatar. | `ZegoAvatarBuilder?` | `null` |
  | itemBuilder | Builder for the list item. | `ZegoMemberListItemBuilder?` | `null` |
  | sortUserList | Sorter for the user list. | `ZegoMemberListSorter?` | `null` |
  | hiddenUserIDs | List of user IDs to hide. | `List<String>` | `[]` |
  | stream | Stream of user list updates. | `Stream<List<ZegoUIKitUser>>?` | `null` |
  | pseudoUsers | List of pseudo users to display. | `List<ZegoUIKitUser>` | `[]` |

## ZegoInRoomMessageView

View for displaying in-room messages.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | stream | Stream of message updates. | `Stream<List<ZegoInRoomMessage>>` | Required |
  | historyMessages | List of history messages. | `List<ZegoInRoomMessage>` | `[]` |
  | itemBuilder | Builder for message items. | `ZegoInRoomMessageItemBuilder` | Required |
  | scrollable | Whether the list is scrollable. | `bool` | `true` |
  | scrollController | Controller for scrolling. | `ScrollController?` | `null` |

## ZegoInRoomMessageInput

Input field for sending in-room messages.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | placeHolder | Placeholder text. | `String` | Required |
  | payloadAttributes | Custom attributes for the message. | `Map<String, String>?` | `null` |
  | backgroundColor | Background color of the input area. | `Color?` | `null` |
  | inputBackgroundColor | Background color of the input field. | `Color?` | `null` |
  | textColor | Text color. | `Color?` | `null` |
  | textHintColor | Hint text color. | `Color?` | `null` |
  | cursorColor | Cursor color. | `Color?` | `null` |
  | buttonColor | Send button color. | `Color?` | `null` |
  | borderRadius | Border radius of the input field. | `double?` | `null` |
  | enabled | Whether the input is enabled. | `bool` | `true` |
  | autofocus | Whether to autofocus. | `bool` | `false` |
  | onSubmit | Callback when message is submitted. | `VoidCallback?` | `null` |
  | valueNotifier | Notifier for the input value. | `ValueNotifier<String>?` | `null` |
  | focusNotifier | Notifier for the focus state. | `ValueNotifier<bool>?` | `null` |

## ZegoInRoomChatView

Chat view for displaying and sending messages.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | avatarBuilder | Builder for the avatar. | `ZegoAvatarBuilder?` | `null` |
  | itemBuilder | Builder for message items. | `ZegoInRoomMessageItemBuilder?` | `null` |
  | scrollController | Controller for scrolling. | `ScrollController?` | `null` |

## ZegoInRoomMessageViewItem

Item view for a single message in the message list.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | message | The message to display. | `ZegoInRoomMessage` | Required |
  | isHorizontal | Whether to layout horizontally. | `bool` | `false` |
  | showName | Whether to show the user name. | `bool` | `true` |
  | showAvatar | Whether to show the avatar. | `bool` | `true` |
  | namePrefix | Prefix for the user name. | `String?` | `null` |
  | avatarBuilder | Builder for the avatar. | `ZegoAvatarBuilder?` | `null` |
  | resendIcon | Icon for the resend button. | `Widget?` | `null` |
  | borderRadius | Border radius of the item. | `BorderRadiusGeometry?` | `null` |
  | paddings | Padding of the item. | `EdgeInsetsGeometry?` | `null` |
  | opacity | Opacity of the background. | `double?` | `null` |
  | backgroundColor | Background color of the item. | `Color?` | `null` |
  | maxLines | Maximum lines for the message text. | `int?` | `null` |
  | nameTextStyle | Style for the user name text. | `TextStyle?` | `null` |
  | messageTextStyle | Style for the message text. | `TextStyle?` | `null` |
  | onItemClick | Callback when the item is clicked. | `ZegoInRoomMessageViewItemPressEvent?` | `null` |
  | onItemLongPress | Callback when the item is long pressed. | `ZegoInRoomMessageViewItemPressEvent?` | `null` |

## ZegoInRoomNotificationView

View for displaying in-room notifications (join/leave, etc.).

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | maxCount | Maximum number of notifications to show. | `int` | `3` |
  | itemMaxLine | Maximum lines per notification item. | `int` | `1` |
  | itemDisappearTime | Time in milliseconds before an item disappears. | `int` | `3000` |
  | notifyUserLeave | Whether to notify when a user leaves. | `bool` | `true` |
  | userJoinItemBuilder | Builder for user join notifications. | `ZegoNotificationUserItemBuilder?` | `null` |
  | userLeaveItemBuilder | Builder for user leave notifications. | `ZegoNotificationUserItemBuilder?` | `null` |
  | itemBuilder | Builder for custom notifications. | `ZegoNotificationMessageItemBuilder?` | `null` |

## ZegoInRoomNotificationViewItem

Item view for a single notification.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | user | The user associated with the notification. | `ZegoUIKitUser` | Required |
  | message | The notification message. | `String` | Required |
  | prefix | Prefix for the notification. | `String?` | `null` |
  | maxLines | Maximum lines for the text. | `int?` | `null` |
  | isHorizontal | Whether to layout horizontally. | `bool` | `false` |

## ZegoInRoomChatViewItem

A single chat message item in the room chat view.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | roomID | The ID of the room. | `String` | Required |
  | message | The chat message. | `ZegoInRoomMessage` | Required |
  | avatarBuilder | Builder for the avatar. | `ZegoAvatarBuilder?` | `null` |

# Effect

## ZegoBeautyEffectSlider

Slider for adjusting beauty effects.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | effectType | The type of beauty effect. | `BeautyEffectType` | Required |
  | defaultValue | The default value of the effect. | `int` | `50` |
  | thumpHeight | The height of the thumb. | `double?` | `null` |
  | trackHeight | The height of the track. | `double?` | `null` |
  | labelFormatFunc | Function to format the label. | `String Function(int)?` | `null` |
  | textStyle | The style of the text displayed on the Slider's thumb. | `TextStyle?` | `null` |
  | textBackgroundColor | The background color of the text displayed on the Slider's thumb. | `Color?` | `null` |
  | activeTrackColor | The color of the track that is active when sliding the Slider. | `Color?` | `null` |
  | inactiveTrackColor | The color of the track that is inactive when sliding the Slider. | `Color?` | `null` |
  | thumbColor | The color of the Slider's thumb. | `Color?` | `null` |
  | thumbRadius | The radius of the Slider's thumb. | `double?` | `null` |

# Widgets

## ZegoDraggableBottomSheet

Partially visible bottom sheet that can be dragged into the screen.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | alignment | Alignment of the sheet. | `Alignment` | Required |
  | backgroundWidget | This widget will hide behind the sheet when expanded. | `Widget?` | `null` |
  | blurBackground | Whether to blur the background while sheet expansion. | `bool` | `false` |
  | expandedChild | Child of expended sheet. | `Widget?` | `null` |
  | expansionExtent | Extent from the min-height to change from previewChild to expandedChild. | `double` | Required |
  | maxExtent | Max-extent for sheet expansion. | `double` | Required |
  | minExtent | Min-extent for the sheet, also the original height of the sheet. | `double` | Required |
  | previewChild | Child to be displayed when sheet is not expended. | `Widget?` | `null` |
  | scrollDirection | Scroll direction of the sheet. | `Axis` | `Axis.vertical` |

## ZegoInputBoardWrapper

Wrapper to handle input board visibility.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | child | The child widget. | `Widget` | Required |

## ZegoSlider

A custom slider widget.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | defaultValue | The default value. | `int` | Required |
  | onChanged | Callback when value changes. | `void Function(double value)?` | `null` |
  | thumpHeight | The height of the thumb. | `double?` | `null` |
  | trackHeight | The height of the track. | `double?` | `null` |
  | labelFormatFunc | Function to format the label. | `String Function(int)?` | `null` |
  | textStyle | The style of the text displayed on the Slider's thumb. | `TextStyle?` | `null` |
  | textBackgroundColor | The background color of the text displayed on the Slider's thumb. | `Color?` | `null` |
  | activeTrackColor | The color of the track that is active when sliding the Slider. | `Color?` | `null` |
  | inactiveTrackColor | The color of the track that is inactive when sliding the Slider. | `Color?` | `null` |
  | thumbColor | The color of the Slider's thumb. | `Color?` | `null` |
  | thumbRadius | The radius of the Slider's thumb. | `double?` | `null` |

## ZegoNetworkLoading

Widget to display network loading state.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | child | The child widget. | `Widget` | Required |
  | config | Configuration for network loading. | `ZegoNetworkLoadingConfig?` | `null` |

## ZegoLoadingIndicator

A custom loading indicator widget.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | text | The text to display below the loading indicator. | `String` | Required |

## ZegoServiceValueIcon

Icon that changes based on a value notifier.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | notifier | Notifier for the value. | `ValueNotifier<bool>` | Required |
  | normalIcon | Icon for the normal state (false). | `Image` | Required |
  | checkedIcon | Icon for the checked state (true). | `Image` | Required |

## ValueNotifierSliderVisibility

Widget to control visibility with animation based on a value notifier.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | child | The child widget. | `Widget` | Required |
  | visibilityNotifier | Notifier for visibility. | `ValueNotifier<bool>` | Required |
  | animationDuration | Duration of the animation. | `Duration` | Required |
  | beginOffset | Begin offset for slide transition. | `Offset` | Required |
  | endOffset | End offset for slide transition. | `Offset` | Required |

## ZegoUIKitFlipTransition

A widget that applies a flip transition animation.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | child | The child widget to animate. | `Widget` | Required |
  | isFlippedNotifier | Notifier for the flip state. | `ValueNotifier<bool>` | Required |
  | isFrontTriggerByTurnOnCamera | Notifier indicating if the front side is triggered by turning on the camera. | `ValueNotifier<bool>` | Required |
  | duration | The duration of the animation. | `Duration` | `Duration(milliseconds: 300)` |

## ZegoScreenUtilInit

A helper widget that initializes ZegoScreenUtil.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | builder | Builder for the child. | `ZegoScreenUtilInitBuilder?` | `null` |
  | child | The child widget. | `Widget?` | `null` |
  | rebuildFactor | The factor to rebuild the widget. | `ZegoRebuildFactor` | Required |
  | designSize | The Size of the device in the design draft, in dp. | `Size` | Required |
  | splitScreenMode | Whether to support split screen mode. | `bool` | `false` |
  | minTextAdapt | Whether to support minimum text adaptation. | `bool` | `false` |
  | useInheritedMediaQuery | Whether to use inherited media query. | `bool` | `false` |
  | ensureScreenSize | Whether to ensure screen size. | `bool?` | `null` |
  | responsiveWidgets | The widgets that need to be responsive. | `Iterable<String>?` | `null` |
  | fontSizeResolver | The resolver for font size. | `ZegoFontSizeResolver` | Required |

# Functions

## showAlertDialog

Show an alert dialog.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | context | The context. | `BuildContext?` | `null` |
  | title | The title of the dialog. | `String` | Required |
  | content | The content of the dialog. | `String` | Required |
  | actions | The actions of the dialog. | `List<Widget>` | Required |
  | titleStyle | The style of the title. | `TextStyle?` | `null` |
  | contentStyle | The style of the content. | `TextStyle?` | `null` |
  | actionsAlignment | The alignment of the actions. | `MainAxisAlignment?` | `null` |
  | backgroundColor | The background color. | `Color?` | `null` |
  | backgroundBrightness | The brightness of the background. | `Brightness?` | `null` |

## showTopModalSheet

Show a modal sheet from the top.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | context | The context. | `BuildContext?` | `null` |
  | widget | The widget to display. | `Widget` | Required |
  | barrierDismissible | Whether the barrier is dismissible. | `bool` | `true` |

## getTextSize

Calculate the size of the text.

- **Parameters**

  | Name | Description | Type | Default Value |
  | :--- | :--- | :--- | :--- |
  | text | The text. | `String` | Required |
  | textStyle | The style of the text. | `TextStyle` | Required |
