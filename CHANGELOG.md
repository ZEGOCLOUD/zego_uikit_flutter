## 2.28.7

- add system version of device

## 2.28.6
- 
- Features
  - Support for additional listening offline message handler

## 2.28.5

- Bugs
  - Fix the occasional fail of enableCustomVideoProcessing

## 2.28.4

- Support init without creating express engine; support join room without initiating entry.

## 2.28.3

- Fix bugs

## 2.28.2

- Features
  - Add animation effect on camera flip

## 2.28.1

- Fix screen-sharing outside the app, remote pull-based streaming has no sound

## 2.28.0

- Features
  - Add data analyze
  - Add iOS PIP related basic functions
- Bugs
  - Fix some issues with render iOS platform view
  - Fix the issue of media player moving out of range
  - ZegoUIKitMediaPlayer's API had changed
  - Fix the issue not publish/play stream where the camera is not turned on on iOS when enable platform view(which used by PIP now)
  - Fix the issue of audio video view UI exception in audio mode
  - Fix crash on android virtual machine
- Update dependency

## 2.27.20

- Fix Bugs

## 2.27.19

- Update dependency

## 2.27.18

- Add iOS data analyze

## 2.27.17

- Add data analyze
  
## 2.27.16

- Add some logs

## 2.27.15

- Update dependency

## 2.27.14

- Update dependency

## 2.27.13

- Update dependency

## 2.27.12

- Add PIP enum defines

## 2.27.11

- Update dependency

## 2.27.10

- Update dependency

## 2.27.9

- Bugs
  - Fix the issue that the screen video window on this side occasionally appears not closed after remote screen-sharing is closed

## 2.27.8

- Bugs
  - Fix the issue of missing type of user state event in normal call scenario

## 2.27.7

- Bugs
  - Fix the issue where the stop button cannot be clicked in the screen sharing window

## 2.27.6

- Bugs
  - Fix offline call from web failure issue

## 2.27.5

- Update dependency

## 2.27.4

- Bugs
  - Fix offline call from web failure issue

## 2.27.2

- Optimize audio-video view play outside the room
  - Add resolution configuration, default is 180p
  - Optimize the automatic play stream strategy, only play stream is available in the visible area.

## 2.27.1

- Fix the issue startPlayAllAudioVideo failed after stopPlayAllAudioVideo

## 2.27.0

- Add audio-video view play outside the room

## 2.26.1

- Update some internal variables

## 2.26.0

- Support clear messages

## 2.25.3

- Add engine create notifier.

## 2.25.2

- Update dependency

## 2.25.1

- Update dependency

## 2.25.0

- Features
  - Support login by token

## 2.24.4

- Update dependency.

## 2.24.3

- Update log

## 2.24.2

- Modify the barrage messages callback to only return the latest messages.

## 2.24.1

- add `customData` in `ZegoAcceptInvitationButton`

## 2.24.0

- Support sending and receiving barrage messages with

## 2.23.0

- Update dependency.
- Support for displaying virtual users

## 2.22.9

- Update dependency.

## 2.22.8

- Update dependency.

## 2.22.7

- Update dependency.

## 2.22.6

- Bugs
  - Fix namespace error after grade v8.0

## 2.22.5

- Update dependency.

## 2.22.4

- Update dependency.

## 2.22.3

- Update dependency.

## 2.22.2

- Update doc.

## 2.22.1

- Update doc.

## 2.22.0

- Add device exception events

## 2.21.5

- update express deps.

## 2.21.4

- Fix ZegoUIKitMediaPlayer not display on some controls

## 2.21.3

- Fix ZegoUIKitMediaPlayer not display on some controls

## 2.21.2

- Fixed the issue where media viewer did not receive status changes when stopping/destroy on the player side

## 2.21.1

- Fix rendering issues with video AspectFit mode under iOS

## 2.21.0

- support custom stream in member list

## 2.20.0

- update call button.

## 2.19.0

- update express deps.

## 2.18.9

- fix screensharing issue

## 2.18.8

- Update dependency

## 2.18.7

- Fixed some bugs.

## 2.18.6

- Add `destroyMedia` to the media service.

## 2.18.5

- Add a api to prevent remove SDK events listening

## 2.18.4

- Update documents

## 2.18.3

- add  `streamID` and `streamType` in `ZegoUIKitReceiveSEIEvent`

## 2.18.1

- Fix the issue of video shaking caused by chat input in iOS.

## 2.18.0

- Add `sendCustomSEI` and `getReceiveCustomSEIStream`

## 2.17.3

- Fix the conflict issue when using Express Engine Event together, re-register the events upon joining the room and unregister them upon leaving.

## 2.17.2

- Fix the issue of multiple callbacks caused by duplicate event listeners.

## 2.17.1

- Update documents

## 2.17.0

- Support add listener of express event by **ZegoUIKit().registerExpressEvent**
- Support add listener of media event by **ZegoUIKit().registerMediaEvent**

## 2.16.2

- Update dependency

## 2.16.1

- Optimization warnings from analysis

## 2.16.0

- support traffic control

## 2.15.10

- Update dependency

## 2.15.9

- Update dependency

## 2.15.8

- Update dependency

## 2.15.7

- message，add more leading/tailing builder for customizing the widget

## 2.15.6

- support specify the allowed formats in media service

## 2.15.5

- Fix some bugs.

## 2.15.4

- Fix the issue of extra whitespace at the bottom when prebuilt widget are not wrapped within SafeArea.

## 2.15.3

- Fix the issue of video shaking caused by chat input.

## 2.15.2

- ZegoAudioVideoContainer supports window source filtering.

## 2.15.1

- Update dependency

## 2.15.0

- support call invitation in advance mode

## 2.14.9

- Fixing iOS pod install failure

## 2.14.8

- Support return to home screen in Android by native code, instead of using returning true in onWillPop.

## 2.14.7

- Update dependency

## 2.14.6

- Optimization warnings from analysis

## 2.14.5

- Optimization warnings from analysis

## 2.14.4

- Update dependency
- Optimization warnings from analysis

## 2.14.3

- Update dependency
- Fixed some bugs

## 2.14.2

- Optimization warnings from analysis

## 2.14.1

- Optimization warnings from analysis

## 2.14.0

- Support listening for errors.
- Support listening for errors in the beauty and signaling plugins.

## 2.13.4

- About offline call on iOS, whether in sandbox or production environment, will be automatically selected internal and no longer require manual assignment

## 2.13.3

- Fix the issue where the audio/video stream is not refreshed when the state of the camera/microphone changes in mute mode.

## 2.13.2

- Update dart dependency

## 2.13.1

- Fix some bugs.

## 2.13.0

- PIP Layout now supports scrolling by default. You can disable scrolling by setting the **isSmallViewsScrollable** parameter in **ZegoLayout.pictureInPicture()**.
- PIP Layout now allows configuring the number of visible items. You can specify the number of visible items by setting the **visibleSmallViewsCount** parameter in **ZegoLayout.pictureInPicture()**.
  The default value is 3.
- Gallery Layout now supports setting margins. You can set by the **margin** parameter in **ZegoLayout.gallery()**, after setting the margins, the content
  will be centered, allowing you to display your own widgets in the surrounding empty space.

## 2.12.2

- Fix the issue of call cancellation on the calling end, where the call fails to be accepted by the receiving end after calling again.

## 2.12.1

- Fix the issue when inviting multiple invitees: when one of the invitees accepts, rejects, or times out, the inviter's internal data prematurely removes the invitation ID.

## 2.12.0

- Add the **inviterID** parameter to the **sendInvitation**
- Add **setThroughMessageHandler**

## 2.11.1

- Update dependency.

## 2.11.0

- Support for canceling offline calls.

## 2.10.1

- Update zego_express_engine version

## 2.10.0

- Add **setAdvanceConfigs** to set advanced engine configuration.

## 2.9.3

- Update dependency.

## 2.9.2

- Update dependency.

## 2.9.1

- Update dependency.

## 2.9.0

- Add signaling send command message method.

## 2.8.3

- Fix speaker button state.

## 2.8.2

- Added plugin installation notification.

## 2.8.1

- Optimizing code for chat widget

## 2.8.0

- Added the **muteUserAudio** API, which is used to stop play the audio of a specific user.
- Added the **muteUserVideo** API, which is used to stop play the video of a specific user.

## 2.7.9

- Supports signaling package create the singleton that has not been destroyed and logging in when the user has not logged out.

## 2.7.8

- Fix the incompatibility with the web live streaming protocol.

## 2.7.7

- Entering the same room is considered a successful entry and should be treated as such.

## 2.7.6

- Fix the issue of incorrect microphone status in the bottom-right corner of the screen for users in PIP view.

## 2.7.5

- Fix the black screen issue when sharing media on iOS.

## 2.7.4

- Update dependency.

## 2.7.3

- Added margin, padding, and border radius style properties to the **ZegoTextIconButton**.

## 2.7.2

- Display the playback progress bar even when the media is not playing.

## 2.7.1

- Supports mute local media volume

## 2.7.0

- Supports offline push between two apps

## 2.6.0

- Supports media sharing

## 2.5.24

- Remove the **ZegoCustomVideoProcessConfig** parameter from **enableCustomVideoProcessing**

## 2.5.23

- Added mute mode handling when toggling remote microphone.

## 2.5.22

- Optimizing network time retrieval method and providing update timing.

## 2.5.21

- Fix the issue of the beauty effect not working

## 2.5.20

- Add a local message sending callback.

## 2.5.19

- On Android, fixed the issue where the camera would not show frames on the first opening when the camera was not turned on by default, by waiting for the camera permission request to complete
  before opening the camera.

## 2.5.18

- Fix the issue of custom sound not working for offline push notifications.

## 2.5.16

- Fix the issue of player lose audio after exiting the prebuilt when using a media player and the prebuilt in App.

## 2.5.15

- Update dependency.

## 2.5.14

- Fix issues about mute microphone.

## 2.5.13

- Update dependency.

## 2.5.12

- Update dependency.

## 2.5.11

- Supports for receiving command messages.

## 2.5.10

- Fix the issue of conflict with extension key of the `flutter_screenutil` package.

## 2.5.9

- Add two APIs, `getConnectionState` and `getRoomState`

## 2.5.8

- Support for setting the video resolution.

## 2.5.7

- Update API Reference.

## 2.5.5

- Supports get network timing.

## 2.5.4

- deprecate flutter_screenutil_zego package.

## 2.5.3

- Supports hide users in member list.

## 2.5.2

- Fix beauty bugs.

## 2.5.1

- Update dependencies.
- ## 2.5.0
- Supports advance beauty.

## 2.4.4

- Update dependencies.

## 2.4.3

- Update dependencies.

## 2.4.2

- Fix some issues about iOS supports VoIP mode.

## 2.4.1

- Update dependencies.

## 2.4.0

- To differentiate the 'appDesignSize' between the App and Zego UIKit Prebuilt, we introduced the 'flutter_screenutil_zego' library and removed the 'appDesignSize' parameter from the
  Zego UIKit Prebuilt that was previously present.

## 2.3.0

- For the offline calling feature, Android supports a silent push mode, while iOS supports VoIP mode.

## 2.2.8

- automatically switch to non-mirror mode when using the rear camera.

## 2.2.7

- Add a new user attribute, soundLevel, which enables monitoring of the user's sound level.

## 2.2.6

- Fix some bugs.

## 2.2.5

- Add notifications event callback log.

## 2.2.4

- Fix some bugs.

## 2.2.3

- the video display mode of screen sharing was modified to AspectFit.

## 2.2.2

- change return value of login function in singaling plugin .

## 2.2.1

- Supports display avatar in audio video view by avatar-url attribute .

## 2.2.0

- Supports screen share.

## 2.1.6

- optimizing code.

## 2.1.5

- Fix full screen for screen sharing bugs.

## 2.1.4

- Supports full screen for screen sharing.

## 2.1.3

- Fix the issue of avatar custom configuration is not working in PIP layout mode.

## 2.1.2

- Fix the issue of mixed stream view of pkBattles is sometimes not displayed due to express doesn't trigger the first frame callback.

## 2.1.1

- Supports rtc pk-battles.

## 2.1.0

- Supports mix stream and SEI.

## 2.0.1

- Fix avatarBuilder.

## 2.0.0

- Architecture upgrade based on adapter.

## 1.9.2

* downgrade flutter_screenutil to ">=5.5.3+2 <5.6.1"

## 1.9.1

* fix some bugs.

## 1.9.0

* fix some bugs.

## 1.7.7

* fix some bugs.

## 1.7.6

* fix some bugs.

## 1.7.5

* fix some bugs.

## 1.7.4

* support custom command and room message.

## 1.7.3

* fix some bugs.

## 1.7.2

* fix some bugs.

## 1.7.1

* fix some bugs.

## 1.7.0

* support live audio room.

## 1.3.11

* fix some bugs.

## 1.3.10

* update live protocol.

## 1.3.9

* fix some bugs.

## 1.3.8

* update a dependency to the latest release..

## 1.3.7

* fix some bugs.

## 1.3.6

* fix some bugs.

## 1.3.5

* fix some bugs.

## 1.3.4

* add call invitation components.

## 1.3.3

* fix some bugs.

## 1.3.2

* fix some bugs
* support beauty-related components.

## 1.3.1

* fix some bugs.

## 1.3.0

* support balloon notifications (NotificationView) and live text chat (ChatView).

## 1.2.0

* support gallery layout for group calls and video conferences.

## 1.1.2

* fix some bugs.

## 1.1.1

* fix some bugs.

## 1.1.0

* fix some bugs.
* add Message module.
* add Member module.

## 1.0.1

* fix some bugs.

## 1.0.0

* Congratulations!

## 0.0.5

* fix some bugs.

## 0.0.4

* fix some bugs.

## 0.0.2

* fix some bugs.
* update a dependency to the latest release..

## 0.0.1

* upload initial release.
