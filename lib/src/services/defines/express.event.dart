// Dart imports:
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_express_engine_for_uikit/zego_express_engine.dart';

///
/// Example:
/// ``` dart
///
/// ...
/// final expressEvent = ExpressEvent();
/// ZegoUIKit().registerExpressEvent(expressEvent);
/// ...
/// class ExpressEvent extends ZegoUIKitExpressEventInterface
/// {
/// ...
///   @override
///   void onDebugError(
///       int errorCode,
///       String funcName,
///       String info,
///       ) {
///     /// your code
///   }
/// ...
/// }
///
/// class ExpressEvent implements ZegoUIKitExpressEventInterface
/// {
/// ...
/// }
/// ```
abstract class ZegoUIKitExpressEventInterface {
  /// The callback for obtaining debugging error information.
  ///
  /// Available since: 1.1.0
  /// Description: When the SDK functions are not used correctly, the callback prompts for detailed error information.
  /// Trigger: Notify the developer when an exception occurs in the SDK.
  /// Restrictions: None.
  /// Caution: None.
  ///
  /// - [errorCode] Error code, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  /// - [funcName] Function name.
  /// - [info] Detailed error information.
  void onDebugError(int errorCode, String funcName, String info) {}

  /// Method execution result callback
  ///
  /// Available since: 2.3.0
  /// Description: When the monitoring is turned on through [setApiCalledCallback], the results of the execution of all methods will be called back through this callback.
  /// Trigger: When the developer calls the SDK method, the execution result of the method is called back.
  /// Restrictions: None.
  /// Caution: It is recommended to monitor and process this callback in the development and testing phases, and turn off the monitoring of this callback after going online.
  ///
  /// - [errorCode] Error code, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  /// - [funcName] Function name.
  /// - [info] Detailed error information.
  void onApiCalledResult(int errorCode, String funcName, String info) {}

  /// The callback triggered when the audio/video engine state changes.
  ///
  /// Available since: 1.1.0
  /// Description: Callback notification of audio/video engine status update. When audio/video functions are enabled, such as preview, push streaming, local media player, audio data observing, etc., the audio/video engine will enter the start state. When you exit the room or disable all audio/video functions , The audio/video engine will enter the stop state.
  /// Trigger: The developer called the relevant function to change the state of the audio and video engine. For example: 1. Called ZegoExpressEngine's [startPreview], [stopPreview], [startPublishingStream], [stopPublishingStream], [startPlayingStream], [stopPlayingStream], [startAudioDataObserver], [stopAudioDataObserver] and other functions. 2. The related functions of MediaPlayer are called. 3. The [LogoutRoom] function was called. 4. The related functions of RealTimeSequentialDataManager are called.
  /// Restrictions: None.
  /// Caution:
  ///   1. When the developer calls [destroyEngine], this notification will not be triggered because the resources of the SDK are completely released.
  ///   2. If there is no special need, the developer does not need to pay attention to this callback.
  ///
  /// - [state] The audio/video engine state.
  void onEngineStateUpdate(ZegoEngineState state) {}

  /// Experimental API callback
  ///
  /// Available since: 2.7.0
  /// Description: Receive experimental API callbacks in JSON string format.
  /// Caution: Please use this feature with the help of ZEGO Technical Support.
  ///
  /// - [content] Callback content in JSON string format.
  void onRecvExperimentalAPI(String content) {}

  /// The callback that triggered a fatal error, causing the SDK to malfunction and unable to function properly.
  ///
  /// Available since: 3.6.0
  /// Description: The callback that triggered a fatal error.
  /// Trigger: The APP has enabled the restriction of access from foreign IP addresses, and the current client is outside of the domain.
  /// Restrictions: None.
  /// Caution:
  ///   None.
  ///
  /// - [errorCode] Error code.
  void onFatalError(int errorCode) {}

  /// Notification of the room connection state changes.
  ///
  /// Available since: 1.1.0
  /// Description: This callback is triggered when the connection status of the room changes, and the reason for the change is notified.For versions 2.18.0 and above, it is recommended to use the onRoomStateChanged callback instead of the onRoomStateUpdate callback to monitor room state changes.
  /// Use cases: Developers can use this callback to determine the status of the current user in the room.
  /// When to trigger:
  ///  1. The developer will receive this notification when calling the [loginRoom], [logoutRoom], [switchRoom] functions.
  ///  2. This notification may also be received when the network condition of the user's device changes (SDK will automatically log in to the room when disconnected, please refer to [Does ZEGO SDK support a fast reconnection for temporary disconnection] for details](https://docs.zegocloud.com/faq/reconnect?product=ExpressVideo&platform=all).
  /// Restrictions: None.
  /// Caution: If the connection is being requested for a long time, the general probability is that the user's network is unstable.
  /// Related APIs: [loginRoom]、[logoutRoom]、[switchRoom]
  ///
  /// - [roomID] Room ID, a string of up to 128 bytes in length.
  /// - [state] Changed room state.
  /// - [errorCode] Error code, For details, please refer to [Common Error Codes](https://docs.zegocloud.com/article/5548).
  /// - [extendedData] Extended Information with state updates. When the room login is successful, the key "room_session_id" can be used to obtain the unique RoomSessionID of each audio and video communication, which identifies the continuous communication from the first user in the room to the end of the audio and video communication. It can be used in scenarios such as call quality scoring and call problem diagnosis.
  void onRoomStateUpdate(
    String roomID,
    ZegoRoomState state,
    int errorCode,
    Map<String, dynamic> extendedData,
  ) {}

  /// Notification of the room connection state changes, including specific reasons for state change.
  ///
  /// Available since: 2.18.0
  /// Description: This callback is triggered when the connection status of the room changes, and the reason for the change is notified.For versions 2.18.0 and above, it is recommended to use the onRoomStateChanged callback instead of the onRoomStateUpdate callback to monitor room state changes.
  /// Use cases: Developers can use this callback to determine the status of the current user in the room.
  /// When to trigger: Users will receive this notification when they call room functions (refer to [Related APIs]). 2. This notification may also be received when the user device's network conditions change (SDK will automatically log in to the room again when the connection is disconnected, refer to https://doc-zh.zego.im/faq/reconnect ).
  /// Restrictions: None.
  /// Caution: If the connection is being requested for a long time, the general probability is that the user's network is unstable.
  /// Related APIs: [loginRoom], [logoutRoom], [switchRoom]
  ///
  /// - [roomID] Room ID, a string of up to 128 bytes in length.
  /// - [reason] Room state change reason.
  /// - [errorCode] Error code, please refer to the error codes document https://doc-en.zego.im/en/5548.html for details.
  /// - [extendedData] Extended Information with state updates. When the room login is successful, the key "room_session_id" can be used to obtain the unique RoomSessionID of each audio and video communication, which identifies the continuous communication from the first user in the room to the end of the audio and video communication. It can be used in scenarios such as call quality scoring and call problem diagnosis.
  void onRoomStateChanged(
    String roomID,
    ZegoRoomStateChangedReason reason,
    int errorCode,
    Map<String, dynamic> extendedData,
  ) {}

  /// The callback triggered when the number of other users in the room increases or decreases.
  ///
  /// Available since: 1.1.0
  /// Description: When other users in the room are online or offline, which causes the user list in the room to change, the developer will be notified through this callback.
  /// Use cases: Developers can use this callback to update the user list display in the room in real time.
  /// When to trigger:
  ///   1. When the user logs in to the room for the first time, if there are other users in the room, the SDK will trigger a callback notification with `updateType` being [ZegoUpdateTypeAdd], and `userList` is the other users in the room at this time.
  ///   2. The user is already in the room. If another user logs in to the room through the [loginRoom] or [switchRoom] functions, the SDK will trigger a callback notification with `updateType` being [ZegoUpdateTypeAdd].
  ///   3. If other users log out of this room through the [logoutRoom] or [switchRoom] functions, the SDK will trigger a callback notification with `updateType` being [ZegoUpdateTypeDelete].
  ///   4. The user is already in the room. If another user is kicked out of the room from the server, the SDK will trigger a callback notification with `updateType` being [ZegoUpdateTypeDelete].
  /// Restrictions: If developers need to use ZEGO room users notifications, please ensure that the [ZegoRoomConfig] sent by each user when logging in to the room has the [isUserStatusNotify] property set to true, otherwise the callback notification will not be received.
  /// Related APIs: [loginRoom]、[logoutRoom]、[switchRoom]
  ///
  /// - [roomID] Room ID where the user is logged in, a string of up to 128 bytes in length.
  /// - [updateType] Update type (add/delete).
  /// - [userList] List of users changed in the current room.
  void onRoomUserUpdate(
    String roomID,
    ZegoUpdateType updateType,
    List<ZegoUser> userList,
  ) {}

  /// The callback triggered every 30 seconds to report the current number of online users.
  ///
  /// Available since: 1.7.0
  /// Description: This method will notify the user of the current number of online users in the room.
  /// Use cases: Developers can use this callback to show the number of user online in the current room.
  /// When to call /Trigger: After successfully logging in to the room.
  /// Restrictions: None.
  /// Caution: 1. This function is called back every 30 seconds. 2. Because of this design, when the number of users in the room exceeds 500, there will be some errors in the statistics of the number of online people in the room.
  ///
  /// - [roomID] Room ID where the user is logged in, a string of up to 128 bytes in length.
  /// - [count] Count of online users.
  void onRoomOnlineUserCountUpdate(String roomID, int count) {}

  /// The callback triggered when the number of streams published by the other users in the same room increases or decreases.
  ///
  /// Available since: 1.1.0
  /// Description: When other users in the room start streaming or stop streaming, the streaming list in the room changes, and the developer will be notified through this callback.
  /// Use cases: This callback is used to monitor stream addition or stream deletion notifications of other users in the room. Developers can use this callback to determine whether other users in the same room start or stop publishing stream, so as to achieve active playing stream [startPlayingStream] or take the initiative to stop the playing stream [stopPlayingStream], and use it to change the UI controls at the same time.
  /// When to trigger:
  ///   1. When the user logs in to the room for the first time, if there are other users publishing streams in the room, the SDK will trigger a callback notification with `updateType` being [ZegoUpdateTypeAdd], and `streamList` is an existing stream list.
  ///   2. The user is already in the room. if another user adds a new push, the SDK will trigger a callback notification with `updateType` being [ZegoUpdateTypeAdd].
  ///   3. The user is already in the room. If other users stop streaming, the SDK will trigger a callback notification with `updateType` being [ZegoUpdateTypeDelete].
  ///   4. The user is already in the room. If other users leave the room, the SDK will trigger a callback notification with `updateType` being [ZegoUpdateTypeDelete].
  /// Restrictions: None.
  ///
  /// - [roomID] Room ID where the user is logged in, a string of up to 128 bytes in length.
  /// - [updateType] Update type (add/delete).
  /// - [streamList] Updated stream list.
  /// - [extendedData] Extended information with stream updates.When receiving a stream deletion notification, the developer can convert the string into a json object to get the stream_delete_reason field, which is an array of stream deletion reasons, and the stream_delete_reason[].code field may have the following values: 1 (the user actively stops publishing stream) ; 2 (user heartbeat timeout); 3 (user repeated login); 4 (user kicked out); 5 (user disconnected); 6 (removed by the server).
  void onRoomStreamUpdate(
    String roomID,
    ZegoUpdateType updateType,
    List<ZegoStream> streamList,
    Map<String, dynamic> extendedData,
  ) {}

  /// The callback triggered when there is an update on the extra information of the streams published by other users in the same room.
  ///
  /// Available since: 1.1.0
  /// Description: All users in the room will be notified by this callback when the extra information of the stream in the room is updated.
  /// Use cases: Users can realize some business functions through the characteristics of stream extra information consistent with stream life cycle.
  /// When to call /Trigger: When a user publishing the stream update the extra information of the stream in the same room, other users in the same room will receive the callback.
  /// Restrictions: None.
  /// Caution: Unlike the stream ID, which cannot be modified during the publishing process, the stream extra information can be updated during the life cycle of the corresponding stream ID.
  /// Related APIs: Users who publish stream can set extra stream information through [setStreamExtraInfo].
  ///
  /// - [roomID] Room ID where the user is logged in, a string of up to 128 bytes in length.
  /// - [streamList] List of streams that the extra info was updated.
  void onRoomStreamExtraInfoUpdate(
    String roomID,
    List<ZegoStream> streamList,
  ) {}

  /// The callback triggered when there is an update on the extra information of the room.
  ///
  /// Available since: 1.1.0
  /// Description: After the room extra information is updated, all users in the room will be notified except update the room extra information user.
  /// Use cases: Extra information for the room.
  /// When to call /Trigger: When a user update the room extra information, other users in the same room will receive the callback.
  /// Restrictions: None.
  /// Related APIs: Users can update room extra information through [setRoomExtraInfo] function.
  ///
  /// - [roomID] Room ID where the user is logged in, a string of up to 128 bytes in length.
  /// - [roomExtraInfoList] List of the extra info updated.
  void onRoomExtraInfoUpdate(
    String roomID,
    List<ZegoRoomExtraInfo> roomExtraInfoList,
  ) {}

  /// Callback notification that room Token authentication is about to expire.
  ///
  /// Available since: 2.8.0
  /// Description: The callback notification that the room Token authentication is about to expire, please use [renewToken] to update the room Token authentication.
  /// Use cases: In order to prevent illegal entry into the room, it is necessary to perform authentication control on login room, push streaming, etc., to improve security.
  /// When to call /Trigger: 30 seconds before the Token expires, the SDK will call [onRoomTokenWillExpire] to notify developer.
  /// Restrictions: None.
  /// Caution: The token contains important information such as the user's room permissions, publish stream permissions, and effective time, please refer to https://docs.zegocloud.com/article/11649.
  /// Related APIs: When the developer receives this callback, he can use [renewToken] to update the token authentication information.
  ///
  /// - [roomID] Room ID where the user is logged in, a string of up to 128 bytes in length.
  /// - [remainTimeInSecond] The remaining time before the token expires.
  void onRoomTokenWillExpire(String roomID, int remainTimeInSecond) {}

  /// The callback triggered when the state of stream publishing changes.
  ///
  /// Available since: 1.1.0
  /// Description: After calling the [startPublishingStream] successfully, the notification of the publish stream state change can be obtained through the callback function. You can roughly judge the user's uplink network status based on whether the state parameter is in [PUBLISH_REQUESTING].
  /// Caution: The parameter [extendedData] is extended information with state updates. If you use ZEGO's CDN content distribution network, after the stream is successfully published, the keys of the content of this parameter are [flv_url_list], [rtmp_url_list], [hls_url_list], these correspond to the publishing stream URLs of the flv, rtmp, and hls protocols.
  /// Related callbacks: After calling the [startPlayingStream] successfully, the notification of the play stream state change can be obtained through the callback function [onPlayerStateUpdate]. You can roughly judge the user's down-link network status based on whether the state parameter is in [PLAY_REQUESTING].
  ///
  /// - [streamID] Stream ID.
  /// - [state] State of publishing stream.
  /// - [errorCode] The error code corresponding to the status change of the publish stream, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  /// - [extendedData] Extended information with state updates, include playing stream CDN address.
  void onPublisherStateUpdate(
    String streamID,
    ZegoPublisherState state,
    int errorCode,
    Map<String, dynamic> extendedData,
  ) {}

  /// Callback for current stream publishing quality.
  ///
  /// Available since: 1.1.0
  /// Description: After calling the [startPublishingStream] successfully, the callback will be received every 3 seconds default(If you need to change the time, please contact the instant technical support to configure). Through the callback, the collection frame rate, bit rate, RTT, packet loss rate and other quality data of the published audio and video stream can be obtained, and the health of the publish stream can be monitored in real time.You can monitor the health of the published audio and video streams in real time according to the quality parameters of the callback function, in order to show the uplink network status in real time on the device UI.
  /// Caution: If you does not know how to use the parameters of this callback function, you can only pay attention to the [level] field of the [quality] parameter, which is a comprehensive value describing the uplink network calculated by SDK based on the quality parameters.
  /// Related callbacks: After calling the [startPlayingStream] successfully, the callback [onPlayerQualityUpdate] will be received every 3 seconds. You can monitor the health of play streams in real time based on quality data such as frame rate, code rate, RTT, packet loss rate, etc.
  ///
  /// - [streamID] Stream ID.
  /// - [quality] Publishing stream quality, including audio and video framerate, bitrate, RTT, etc.
  void onPublisherQualityUpdate(
    String streamID,
    ZegoPublishStreamQuality quality,
  ) {}

  /// The callback triggered when the first audio frame is captured.
  ///
  /// Available since: 1.1.0
  /// Description: This callback will be received when the SDK starts the microphone to capture the first frame of audio data. If this callback is not received, the audio capture device is occupied or abnormal.
  /// Trigger: When the engine of the audio/video module inside the SDK starts, the SDK will go and collect the audio data from the local device and will receive the callback at that time.
  /// Related callbacks: Determine if the SDK actually collected video data by the callback function [onPublisherCapturedVideoFirstFrame], determine if the SDK has rendered the first frame of video data collected by calling back [onPublisherRenderVideoFirstFrame].
  void onPublisherCapturedAudioFirstFrame() {}

  /// The callback triggered when the first video frame is captured.
  ///
  /// Available since: 1.1.0
  /// Description: The SDK will receive this callback when the first frame of video data is captured. If this callback is not received, the video capture device is occupied or abnormal.
  /// Trigger: When the SDK's internal audio/video module's engine starts, the SDK will collect video data from the local device and will receive this callback.
  /// Related callbacks: Determine if the SDK actually collected audio data by the callback function [onPublisherCapturedAudioFirstFrame], determine if the SDK has rendered the first frame of video data collected by calling back [onPublisherRenderVideoFirstFrame].
  /// Note: This function is only available in ZegoExpressVideo SDK!
  ///
  /// - [channel] Publishing stream channel.If you only publish one audio and video stream, you can ignore this parameter.
  void onPublisherCapturedVideoFirstFrame(ZegoPublishChannel channel) {}

  /// The callback triggered when the first video frame is captured.
  ///
  /// Available since: 1.1.0
  /// Description: The SDK will receive this callback when the first frame of video data is captured. If this callback is not received, the video capture device is occupied or abnormal.
  /// Trigger: When the SDK's internal audio/video module's engine starts, the SDK will collect video data from the local device and will receive this callback.
  /// Related callbacks: Determine if the SDK actually collected audio data by the callback function [onPublisherCapturedAudioFirstFrame], determine if the SDK has rendered the first frame of video data collected by calling back [onPublisherRenderVideoFirstFrame].
  /// Note: This function is only available in ZegoExpressVideo SDK!
  ///
  /// - [channel] Publishing stream channel.If you only publish one audio and video stream, you can ignore this parameter.void onPublisherCapturedVideoFirstFrame(ZegoPublishChannel channel,) {}

  /// The callback triggered when the first audio frame is sent.
  ///
  /// Available since: 3.5.0
  /// Description: After the [startPublishingStream] function is called successfully, this callback will be called when SDK received the first frame of audio data. Developers can use this callback to determine whether SDK has actually collected audio data. If the callback is not received, the audio capture device is occupied or abnormal.
  /// Trigger: In the case of no startPublishingStream audio stream, the first startPublishingStream audio stream, it will receive this callback.
  /// Related callbacks: After the [startPublishingStream] function is called successfully, determine if the SDK actually collected video data by the callback function [onPublisherCapturedVideoFirstFrame], determine if the SDK has rendered the first frame of video data collected by calling back [onPublisherRenderVideoFirstFrame].
  ///
  /// - [channel] Publishing stream channel.If you only publish one audio stream, you can ignore this parameter.
  void onPublisherSendAudioFirstFrame(ZegoPublishChannel channel) {}

  /// The callback triggered when the first video frame is sent.
  ///
  /// Available since: 3.5.0
  /// Description: After the [startPublishingStream] function is called successfully, this callback will be called when SDK received the first frame of video data. Developers can use this callback to determine whether SDK has actually collected video data. If the callback is not received, the video capture device is occupied or abnormal.
  /// Trigger: In the case of no startPublishingStream video stream, the first startPublishingStream video stream, it will receive this callback.
  /// Related callbacks: After the [startPublishingStream] function is called successfully, determine if the SDK actually collected audio data by the callback function [onPublisherCapturedAudioFirstFrame], determine if the SDK has rendered the first frame of video data collected by calling back [onPublisherRenderVideoFirstFrame].
  /// Note: This function is only available in ZegoExpressVideo SDK!
  ///
  /// - [channel] Publishing stream channel.If you only publish one video stream, you can ignore this parameter.
  void onPublisherSendVideoFirstFrame(ZegoPublishChannel channel) {}

  /// The callback triggered when the first video frame is rendered.
  ///
  /// Available since: 2.4.0
  /// Description: this callback will be called after SDK rendered the first frame of video data captured. This interface is for preview rendering. The first frame callback is only available for external collection and internal preview. If it is not for SDK rendering, there is no such callback.
  /// Related callbacks: After the [startPublishingStream] function is called successfully, determine if the SDK actually collected audio data by the callback function [onPublisherCapturedAudioFirstFrame], determine if the SDK actually collected video data by the callback function [onPublisherCapturedVideoFirstFrame].
  /// Note: This function is only available in ZegoExpressVideo SDK!
  ///
  /// - [channel] Publishing stream channel.If you only publish one audio and video stream, you can ignore this parameter.
  void onPublisherRenderVideoFirstFrame(ZegoPublishChannel channel) {}

  /// The callback triggered when the video capture resolution changes.
  ///
  /// Available since: 1.1.0
  /// Description: When the audio and video stream is not published [startPublishingStream] or previewed [startPreview] for the first time, the publishing stream or preview first time, that is, the engine of the audio and video module inside the SDK is started, the video data of the local device will be collected, and the collection resolution will change at this time.
  /// Trigger: After the successful publish [startPublishingStream], the callback will be received if there is a change in the video capture resolution in the process of publishing the stream.
  /// Use cases: You can use this callback to remove the cover of the local preview UI and similar operations.You can also dynamically adjust the scale of the preview view based on the resolution of the callback.
  /// Caution: What is notified during external collection is the change in encoding resolution, which will be affected by flow control.
  /// Note: This function is only available in ZegoExpressVideo SDK!
  ///
  /// - [width] Video capture resolution width.
  /// - [height] Video capture resolution height.
  /// - [channel] Publishing stream channel.If you only publish one audio and video stream, you can ignore this parameter.
  void onPublisherVideoSizeChanged(
    int width,
    int height,
    ZegoPublishChannel channel,
  ) {}

  /// The callback triggered when the state of relayed streaming to CDN changes.
  ///
  /// Available since: 1.1.0
  /// Description: Developers can use this callback to determine whether the audio and video streams of the relay CDN are normal. If they are abnormal, further locate the cause of the abnormal audio and video streams of the relay CDN and make corresponding disaster recovery strategies.
  /// Trigger: After the ZEGO RTC server relays the audio and video streams to the CDN, this callback will be received if the CDN relay status changes, such as a stop or a retry.
  /// Caution: If you do not understand the cause of the abnormality, you can contact ZEGO technicians to analyze the specific cause of the abnormality.
  ///
  /// - [streamID] Stream ID.
  /// - [infoList] List of information that the current CDN is relaying.
  void onPublisherRelayCDNStateUpdate(
    String streamID,
    List<ZegoStreamRelayCDNInfo> infoList,
  ) {}

  /// The callback triggered when the video encoder changes in publishing stream.
  ///
  /// Available since: 2.12.0
  /// Description: After the H.265 automatic downgrade policy is enabled, if H.265 encoding is not supported or the encoding fails during the streaming process with H.265 encoding, the SDK will actively downgrade to the specified encoding (H.264), and this callback will be triggered at this time.
  /// When to trigger: In the process of streaming with H.265 encoding, if H.265 encoding is not supported or encoding fails, the SDK will actively downgrade to the specified encoding (H.264), and this callback will be triggered at this time.
  /// Caution: When this callback is triggered, if local video recording or cloud recording is in progress, multiple recording files will be generated. Developers need to collect all the recording files for processing after the recording ends. When this callback is triggered, because the streaming code has changed, the developer can evaluate whether to notify the streaming end, so that the streaming end can deal with it accordingly.
  ///
  /// - [fromCodecID] Video codec ID before the change.
  /// - [toCodecID] Video codec ID after the change.
  /// - [channel] Publishing stream channel.If you only publish one audio and video stream, you can ignore this parameter.
  void onPublisherVideoEncoderChanged(
    ZegoVideoCodecID fromCodecID,
    ZegoVideoCodecID toCodecID,
    ZegoPublishChannel channel,
  ) {}

  /// The callback triggered when publishing stream.
  ///
  /// Available since: 2.18.0
  /// Description: After start publishing stream, this callback will return the current stream address, resource type and protocol-related information.
  /// When to trigger: Publish and retry publish events.
  /// Caution: None.
  ///
  /// - [eventID] Publish stream event ID
  /// - [streamID] Stream ID.
  /// - [extraInfo] extra info. it is in JSON format. Included information includes "url" for address, "streamProtocol" for stream protocol, including rtmp, flv, avertp, hls, webrtc, etc. "netProtocol" for network protocol, including tcp, udp, quic, "resourceType" for resource type , including cdn, rtc, l3.
  void onPublisherStreamEvent(
    ZegoStreamEvent eventID,
    String streamID,
    String extraInfo,
  ) {}

  /// The video object segmentation state changed.
  ///
  /// Available since: 3.4.0
  /// Description: The object segmentation state of the stream publishing end changes.
  /// When to trigger: When [enableVideoObjectSegmentation] enables or disables object segmentation, notify the developer whether to enable object segmentation according to the actual state.
  /// Caution: This callback depends on enabling preview or stream publishing.
  ///
  /// - [state] Object segmentation state.
  /// - [channel] Publishing stream channel.If you only publish one audio and video stream, you can ignore this parameter.
  /// - [errorCode] The error code corresponding to the status change of the object segmentation, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  void onVideoObjectSegmentationStateChanged(
    ZegoObjectSegmentationState state,
    ZegoPublishChannel channel,
    int errorCode,
  ) {}

  /// Video encoding low frame rate warning.
  ///
  /// Available since: 3.8.0
  /// Description: Video encoding low frame rate warning.
  /// When to trigger: This callback triggered by low frame rate in video encoding.
  /// Caution: This callback is disabled by default, if necessary, please contact ZEGO technical support.
  ///
  /// - [codecID] Video codec ID.
  /// - [channel] Publishing stream channel.If you only publish one audio and video stream, you can ignore this parameter.
  void onPublisherLowFpsWarning(
    ZegoVideoCodecID codecID,
    ZegoPublishChannel channel,
  ) {}

  /// The notification for setting the path of the static image displayed when the camera is turned off is incorrect.
  ///
  /// Available since: 3.9.0
  /// Description: The notification for setting the path of the static image displayed when the camera is turned off is incorrect.
  /// When to trigger: If the path for the image is set using [setDummyCaptureImagePath], but the image cannot be obtained during streaming, this callback will be triggered.
  /// Caution: Please make sure that the image path is correct and has read permission before setting it.
  ///
  /// - [errorCode] error code.
  /// - [path] Image path.
  /// - [channel] Publishing stream channel.If you only publish one audio and video stream, you can ignore this parameter.
  void onPublisherDummyCaptureImagePathError(
    int errorCode,
    String path,
    ZegoPublishChannel channel,
  ) {}

  /// The callback triggered when the state of stream playing changes.
  ///
  /// Available since: 1.1.0
  /// Description: After calling the [startPlayingStream] successfully, the notification of the playing stream state change can be obtained through the callback function. You can roughly judge the user's down-link network status based on whether the state parameter is in [PLAY_REQUESTING].
  /// When to trigger:  After calling the [startPublishingStream], this callback is triggered when a playing stream's state changed.
  /// Related callbacks: After calling the [startPublishingStream] successfully, the notification of the publish stream state change can be obtained through the callback function [onPublisherStateUpdate]. You can roughly judge the user's uplink network status based on whether the state parameter is in [PUBLISH_REQUESTING].
  ///
  /// - [streamID] stream ID.
  /// - [state] State of playing stream.
  /// - [errorCode] The error code corresponding to the status change of the playing stream, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  /// - [extendedData] Extended Information with state updates. As the standby, only an empty json table is currently returned.
  void onPlayerStateUpdate(
    String streamID,
    ZegoPlayerState state,
    int errorCode,
    Map<String, dynamic> extendedData,
  ) {}

  /// Callback for current stream playing quality.
  ///
  /// Available since: 1.1.0
  /// Description: After calling the [startPlayingStream] successfully, the callback will be received every 3 seconds default(If you need to change the time, please contact the instant technical support to configure). Through the callback, the collection frame rate, bit rate, RTT, packet loss rate and other quality data can be obtained, and the health of the played audio and video streams can be monitored in real time.
  /// Use cases: You can monitor the health of the played audio and video streams in real time according to the quality parameters of the callback function, in order to show the down-link network status on the device UI in real time.
  /// Caution: If you does not know how to use the various parameters of the callback function, you can only focus on the level field of the quality parameter, which is a comprehensive value describing the down-link network calculated by SDK based on the quality parameters.
  /// Related callbacks: After calling the [startPublishingStream] successfully, a callback [onPublisherQualityUpdate] will be received every 3 seconds. You can monitor the health of publish streams in real time based on quality data such as frame rate, code rate, RTT, packet loss rate, etc.
  ///
  /// - [streamID] Stream ID.
  /// - [quality] Playing stream quality, including audio and video framerate, bitrate, RTT, etc.
  void onPlayerQualityUpdate(String streamID, ZegoPlayStreamQuality quality) {}

  /// The callback triggered when a media event occurs during streaming playing.
  ///
  /// Available since: 1.1.0
  /// Description: This callback is used to receive pull streaming events.
  /// Use cases: You can use this callback to make statistics on stutters or to make friendly displays in the UI of the app.
  /// When to trigger:  After calling the [startPublishingStream], this callback is triggered when an event such as audio and video jamming and recovery occurs in the playing stream.
  ///
  /// - [streamID] Stream ID.
  /// - [event] Specific events received when playing the stream.
  void onPlayerMediaEvent(String streamID, ZegoPlayerMediaEvent event) {}

  /// The callback triggered when the first audio frame is received.
  ///
  /// Available since: 1.1.0
  /// Description: After the [startPlayingStream] function is called successfully, this callback will be called when SDK received the first frame of audio data.
  /// Use cases: Developer can use this callback to count time consuming that take the first frame time or update the UI for playing stream.
  /// Trigger: This callback is triggered when SDK receives the first frame of audio data from the network.
  /// Related callbacks: After a successful call to [startPlayingStream], the callback function [onPlayerRecvVideoFirstFrame] determines whether the SDK has received the video data, and the callback [onPlayerRenderVideoFirstFrame] determines whether the SDK has rendered the first frame of the received video data.
  ///
  /// - [streamID] Stream ID.
  void onPlayerRecvAudioFirstFrame(String streamID) {}

  /// The callback triggered when the first video frame is received. Except for Linux systems, this callback is thrown from the ui thread by default.
  ///
  /// Available since: 1.1.0
  /// Description: After the [startPlayingStream] function is called successfully, this callback will be called when SDK received the first frame of video data.
  /// Use cases: Developer can use this callback to count time consuming that take the first frame time or update the UI for playing stream.
  /// Trigger: This callback is triggered when SDK receives the first frame of video data from the network.
  /// Related callbacks: After a successful call to [startPlayingStream], the callback function [onPlayerRecvAudioFirstFrame] determines whether the SDK has received the audio data, and the callback [onPlayerRenderVideoFirstFrame] determines whether the SDK has rendered the first frame of the received video data.
  /// Note: This function is only available in ZegoExpressVideo SDK!
  ///
  /// - [streamID] Stream ID.
  void onPlayerRecvVideoFirstFrame(String streamID) {}

  /// The callback triggered when the first video frame is rendered.
  ///
  /// Available since: 1.1.0
  /// Description: After the [startPlayingStream] function is called successfully, this callback will be called when SDK rendered the first frame of video data.
  /// Use cases: Developer can use this callback to count time consuming that take the first frame time or update the UI for playing stream.
  /// Trigger: This callback is triggered when SDK rendered the first frame of video data from the network.
  /// Related callbacks: After a successful call to [startPlayingStream], the callback function [onPlayerRecvAudioFirstFrame] determines whether the SDK has received the audio data, and the callback [onPlayerRecvVideoFirstFrame] determines whether the SDK has received the video data.
  /// Note: This function is only available in ZegoExpressVideo SDK!
  ///
  /// - [streamID] Stream ID.
  void onPlayerRenderVideoFirstFrame(String streamID) {}

  /// Calls back when the stream playing end renders the first frame of the video from the remote camera.
  ///
  /// Available since: 3.0.0
  /// Description: After calling the [startPlayingStream] function to pull the stream successfully, the SDK will receive this callback after pulling the stream and rendering the first frame of remote camera video data.
  /// Use cases: Developer can use this callback to count time consuming that take the first frame time or update the UI for playing stream.
  /// Trigger: After the remote [enableCamera] enables the camera, or after [mutePublishStreamVideo] is true and starts to send video data, the SDK will receive this callback after playing the stream and rendering the first frame of the remote camera video data.
  /// Caution: It is only applicable when the remote end uses the camera to push the stream. Only applicable to RTC publishing and playing streaming scenarios.
  /// Related callbacks: After a successful call to [startPlayingStream], the callback [onPlayerRecvVideoFirstFrame] determines whether the SDK has received the video data.
  /// Note: This function is only available in ZegoExpressVideo SDK!
  ///
  /// - [streamID] Stream ID.
  void onPlayerRenderCameraVideoFirstFrame(String streamID) {}

  /// The callback triggered when the stream playback resolution changes.
  ///
  /// Available since: 1.1.0
  /// Description: After the [startPlayingStream] function is called successfully, the play resolution will change when the first frame of video data is received, or when the publisher changes the encoding resolution by calling [setVideoConfig], or when the network traffic control strategies work.
  /// Use cases: Developers can update or switch the UI components that actually play the stream based on the final resolution of the stream.
  /// Trigger: After the [startPlayingStream] function is called successfully, this callback is triggered when the video resolution changes while playing the stream.
  /// Caution: If the stream is only audio data, the callback will not be triggered.
  /// Note: This function is only available in ZegoExpressVideo SDK!
  ///
  /// - [streamID] Stream ID.
  /// - [width] Video decoding resolution width.
  /// - [height] Video decoding resolution height.
  void onPlayerVideoSizeChanged(String streamID, int width, int height) {}

  /// The callback triggered when Supplemental Enhancement Information is received.
  ///
  /// Available since: 1.1.0
  /// Description: After the [startPlayingStream] function is called successfully, when the remote stream sends SEI (such as directly calling [sendSEI], audio mixing with SEI data, and sending custom video capture encoded data with SEI, etc.), the local end will receive this callback.
  /// Trigger: After the [startPlayingStream] function is called successfully, when the remote stream sends SEI, the local end will receive this callback.
  /// Caution:
  ///  1. This function will switch the UI thread callback data, and the customer can directly operate the UI control in this callback function.
  ///  2. Since the video encoder itself generates an SEI with a payload type of 5, or when a video file is used for publishing, such SEI may also exist in the video file. Therefore, if the developer needs to filter out this type of SEI, it can be before [createEngine] Call [ZegoEngineConfig.advancedConfig("unregister_sei_filter", "XXXXX")]. Among them, unregister_sei_filter is the key, and XXXXX is the uuid filter string to be set.
  ///  3. When [mutePlayStreamVideo] or [muteAllPlayStreamVideo] is called to set only the audio stream to be pulled, the SEI will not be received.
  ///
  /// - [streamID] Stream ID.
  /// - [data] SEI content.
  void onPlayerRecvSEI(String streamID, Uint8List data) {}

  /// The callback triggered when Supplemental Enhancement Information is received synchronously.
  ///
  /// Available since: 3.9.0
  /// Description: After the [startPlayingStream] function is called successfully, when the remote stream sends SEI (such as directly calling [sendSEI], audio mixing with SEI data, and sending custom video capture encoded data with SEI, etc.), the local end will receive this callback.
  /// Trigger: After the [startPlayingStream] function is called successfully, when the remote stream sends SEI, the local end will receive this callback.
  /// Caution: 1. Since the video encoder itself generates an SEI with a payload type of 5, or when a video file is used for publishing, such SEI may also exist in the video file. Therefore, if the developer needs to filter out this type of SEI, it can be before [createEngine] Call [ZegoEngineConfig.advancedConfig("unregister_sei_filter", "XXXXX")]. Among them, unregister_sei_filter is the key, and XXXXX is the uuid filter string to be set. 2. When [mutePlayStreamVideo] or [muteAllPlayStreamVideo] is called to set only the audio stream to be pulled, the SEI will not be received.
  ///
  /// - [info] SEI Callback info.
  void onPlayerRecvMediaSideInfo(ZegoMediaSideInfo info) {}

  /// Receive the audio side information content of the remote stream.
  ///
  /// Available since: 2.19.0
  /// Description: After the [startPlayingStream] function is called successfully, when the remote stream sends audio side information, the local end will receive this callback.
  /// Trigger: After the [startPlayingStream] function is called successfully, when the remote stream sends audio side information, the local end will receive this callback.
  /// Caution: 1. When [mutePlayStreamAudio] or [muteAllPlayStreamAudio] is called to set only the video stream to be pulled, the audio side information not be received. 2. Due to factors such as the network, the received data may be missing, but the order is guaranteed.
  /// Related APIs: Send audio side information by the [sendAudioSideInfo] function.
  ///
  /// - [streamID] Stream ID.
  /// - [data] Audio side information content.
  void onPlayerRecvAudioSideInfo(String streamID, Uint8List data) {}

  /// Playing stream low frame rate warning.
  ///
  /// Available since: 2.14.0
  /// Description: This callback triggered by low frame rate when playing stream.
  /// When to trigger: This callback triggered by low frame rate when playing stream.
  /// Caution: If the callback is triggered when the user playing the h.265 stream, you can stop playing the h.265 stream and switch to play the H.264 stream.
  ///
  /// - [codecID] Video codec ID.
  /// - [streamID] Stream ID.
  void onPlayerLowFpsWarning(ZegoVideoCodecID codecID, String streamID) {}

  /// The callback triggered when playing stream.
  ///
  /// Available since: 2.18.0
  /// Description: After start playing stream, this callback will return the current stream address, resource type and protocol-related information.
  /// When to trigger: Play and retry play events.
  /// Caution: None.
  ///
  /// - [eventID] Play stream event ID
  /// - [streamID] Stream ID.
  /// - [extraInfo] extra info. it is in JSON format. Included information includes "url" for address, "streamProtocol" for stream protocol, including rtmp, flv, avertp, hls, webrtc, etc. "netProtocol" for network protocol, including tcp, udp, quic, "resourceType" for resource type , including cdn, rtc, l3.
  void onPlayerStreamEvent(
    ZegoStreamEvent eventID,
    String streamID,
    String extraInfo,
  ) {}

  /// Playing stream video super resolution enabled state changes.
  ///
  /// Available since: 3.0.0
  /// Description: Playing stream video super resolution enabled state changes.
  /// When to trigger: When [enableVideoSuperResolution] enables or disables video super resolution, the developer will be notified whether to enable video super resolution according to the actual situation when playing stream video rendering.
  /// Caution: None.
  ///
  /// - [streamID] Stream ID.
  /// - [state] Video super resolution state.
  /// - [errorCode] Error code, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  void onPlayerVideoSuperResolutionUpdate(
    String streamID,
    ZegoSuperResolutionState state,
    int errorCode,
  ) {}

  /// The callback triggered when the state of relayed streaming of the mixed stream to CDN changes.
  ///
  /// Available since: 1.2.1
  /// Description: The general situation of the mixing task on the ZEGO RTC server will push the output stream to the CDN using the RTMP protocol, and the state change during the push process will be notified from the callback function.
  /// Use cases: It is often used when multiple video images are required to synthesize a video using mixed streaming, such as education, live teacher and student images.
  /// When to trigger: After the developer calls the [startMixerTask] function to start mixing, when the ZEGO RTC server pushes the output stream to the CDN, there is a state change.
  /// Restrictions: None.
  /// Related callbacks: Develop can get the sound update notification of each single stream in the mixed stream through [OnMixerSoundLevelUpdate].
  /// Related APIs: Develop can start a mixed flow task through [startMixerTask].
  ///
  /// - [taskID] The mixing task ID. Value range: the length does not exceed 256. Caution: This parameter is in string format and cannot contain URL keywords, such as 'http' and '?' etc., otherwise the push and pull flow will fail. Only supports numbers, English characters and'~','!','@','$','%','^','&','*','(',')','_' ,'+','=','-','`',';',''',',','.','<','>','/','\'.
  /// - [infoList] List of information that the current CDN is being mixed.
  void onMixerRelayCDNStateUpdate(
    String taskID,
    List<ZegoStreamRelayCDNInfo> infoList,
  ) {}

  /// The callback triggered when the sound level of any input stream changes in the stream mixing process.
  ///
  /// Available since: 1.2.1
  /// Description: Developers can use this callback to display the effect of which stream’s anchor is talking on the UI interface of the mixed stream of the audience.
  /// Use cases: It is often used when multiple video images are required to synthesize a video using mixed streaming, such as education, live teacher and student images.
  /// When to trigger: After the developer calls the [startPlayingStream] function to start playing the mixed stream. Callback notification period is 100 ms.
  /// Restrictions: The callback is triggered every 100 ms, and the trigger frequency cannot be set.Due to the high frequency of this callback, please do not perform time-consuming tasks or UI operations in this callback to avoid stalling.
  /// Related callbacks: [OnMixerRelayCDNStateUpdate] can be used to get update notification of mixing stream repost CDN status.
  /// Related APIs: Develop can start a mixed flow task through [startMixerTask].
  ///
  /// - [soundLevels] The sound key-value pair of each single stream in the mixed stream, the key is the soundLevelID of each single stream, and the value is the sound value of the corresponding single stream. Value range: The value range of value is 0.0 ~ 100.0.
  void onMixerSoundLevelUpdate(Map<int, double> soundLevels) {}

  /// The callback triggered when the sound level of any input stream changes in the auto stream mixing process.
  ///
  /// Available since: 2.10.0
  /// Description: According to this callback, user can obtain the sound level information of each stream pulled during auto stream mixing.
  /// Use cases: Often used in voice chat room scenarios.Users can use this callback to show which streamer is speaking when an audience pulls a mixed stream.
  /// Trigger: Call [startPlayingStream] function to pull the stream.
  /// Related APIs: Users can call [startAutoMixerTask] function to start an auto stream mixing task.Users can call [stopAutoMixerTask] function to stop an auto stream mixing task.
  ///
  /// - [soundLevels] Sound level hash map, key is the streamID of every single stream in this mixer stream, value is the sound level value of that single stream, value ranging from 0.0 to 100.0.
  void onAutoMixerSoundLevelUpdate(Map<String, double> soundLevels) {}

  /// The callback triggered when there is a change to audio devices (i.e. new device added or existing device deleted).
  ///
  /// Only supports desktop.
  /// This callback is triggered when an audio device is added or removed from the system. By listening to this callback, users can update the sound collection or output using a specific device when necessary.
  ///
  /// - [updateType] Update type (add/delete)
  /// - [deviceType] Audio device type
  /// - [deviceInfo] Audio device information
  void onAudioDeviceStateChanged(
    ZegoUpdateType updateType,
    ZegoAudioDeviceType deviceType,
    ZegoDeviceInfo deviceInfo,
  ) {}

  /// The callback triggered when there is a change of the volume for the audio devices.
  ///
  /// Available since: 1.1.0
  /// Description: Audio device volume change event callback.
  /// When to trigger: After calling the [startAudioDeviceVolumeMonitor] function to start the device volume monitor, and the volume of the monitored audio device changes.
  /// Platform differences: Only supports Windows and macOS.
  ///
  /// - [deviceType] Audio device type
  /// - [deviceID] Audio device ID
  /// - [volume] audio device volume
  void onAudioDeviceVolumeChanged(
    ZegoAudioDeviceType deviceType,
    String deviceID,
    int volume,
  ) {}

  /// The callback triggered when there is a change to video devices (i.e. new device added or existing device deleted).
  ///
  /// Available since: 1.1.0
  /// Description: By listening to this callback, users can update the video capture using a specific device when necessary.
  /// When to trigger: This callback is triggered when a video device is added or removed from the system.
  /// Restrictions: None
  /// Platform differences: Only supports Windows and macOS.
  /// Note: This function is only available in ZegoExpressVideo SDK!
  ///
  /// - [updateType] Update type (add/delete)
  /// - [deviceInfo] Audio device information
  void onVideoDeviceStateChanged(
    ZegoUpdateType updateType,
    ZegoDeviceInfo deviceInfo,
  ) {}

  /// The local captured audio sound level callback.
  ///
  /// Available since: 1.1.0
  /// Description: The local captured audio sound level callback.
  /// Trigger: After you start the sound level monitor by calling [startSoundLevelMonitor].
  /// Caution:
  ///   1. The callback notification period is the parameter value set when the [startSoundLevelMonitor] is called. The callback value is the default value of 0 When you have not called the interface [startPublishingStream] and [startPreview].
  ///   2. This callback is a high-frequency callback, and it is recommended not to do complex logic processing inside the callback.
  /// Related APIs: Start sound level monitoring via [startSoundLevelMonitor]. Monitoring remote played audio sound level by callback [onRemoteSoundLevelUpdate]
  ///
  /// - [soundLevel] Locally captured sound level value, ranging from 0.0 to 100.0.
  void onCapturedSoundLevelUpdate(double soundLevel) {}

  /// The local captured audio sound level callback, supported vad.
  ///
  /// Available since: 2.10.0
  /// Description: The local captured audio sound level callback.
  /// Trigger: After you start the sound level monitor by calling [startSoundLevelMonitor].
  /// Caution:
  ///   1. The callback notification period is the parameter value set when the [startSoundLevelMonitor] is called.
  ///   2. This callback is a high-frequency callback, and it is recommended not to do complex logic processing inside the callback.
  /// Related APIs: Start sound level monitoring via [startSoundLevelMonitor]. Monitoring remote played audio sound level by callback [onRemoteSoundLevelUpdate] or [onRemoteSoundLevelInfoUpdate].
  ///
  /// - [soundLevelInfo] Locally captured sound level value, ranging from 0.0 to 100.0.
  void onCapturedSoundLevelInfoUpdate(ZegoSoundLevelInfo soundLevelInfo) {}

  /// The remote playing streams audio sound level callback.
  ///
  /// Available since: 1.1.0
  /// Description: The remote playing streams audio sound level callback.
  /// Trigger: After you start the sound level monitor by calling [startSoundLevelMonitor], you are in the state of playing the stream [startPlayingStream].
  /// Caution: The callback notification period is the parameter value set when the [startSoundLevelMonitor] is called.
  /// Related APIs: Start sound level monitoring via [startSoundLevelMonitor]. Monitoring local captured audio sound by callback [onCapturedSoundLevelUpdate] or [onCapturedSoundLevelInfoUpdate].
  ///
  /// - [soundLevels] Remote sound level hash map, key is the streamID, value is the sound level value of the corresponding streamID, value ranging from 0.0 to 100.0.
  void onRemoteSoundLevelUpdate(Map<String, double> soundLevels) {}

  /// The remote playing streams audio sound level callback, supported vad.
  ///
  /// Available since: 2.10.0
  /// Description: The remote playing streams audio sound level callback.
  /// Trigger: After you start the sound level monitor by calling [startSoundLevelMonitor], you are in the state of playing the stream [startPlayingStream].
  /// Caution: The callback notification period is the parameter value set when the [startSoundLevelMonitor] is called.
  /// Related APIs: Start sound level monitoring via [startSoundLevelMonitor]. Monitoring local captured audio sound by callback [onCapturedSoundLevelUpdate] or [onCapturedSoundLevelInfoUpdate].
  ///
  /// - [soundLevelInfos] Remote sound level hash map, key is the streamID, value is the sound level value of the corresponding streamID, value ranging from 0.0 to 100.0.
  void onRemoteSoundLevelInfoUpdate(
    Map<String, ZegoSoundLevelInfo> soundLevelInfos,
  ) {}

  /// The local captured audio spectrum callback.
  ///
  /// Available since: 1.1.0
  /// Description: The local captured audio spectrum callback.
  /// Trigger: After you start the audio spectrum monitor by calling [startAudioSpectrumMonitor].
  /// Caution: The callback notification period is the parameter value set when the [startAudioSpectrumMonitor] is called. The callback value is the default value of 0 When you have not called the interface [startPublishingStream] and [startPreview].
  /// Related APIs: Start audio spectrum monitoring via [startAudioSpectrumMonitor]. Monitoring remote played audio spectrum by callback [onRemoteAudioSpectrumUpdate]
  ///
  /// - [audioSpectrum] Locally captured audio spectrum value list. Spectrum value range is [0-2^30].
  void onCapturedAudioSpectrumUpdate(List<double> audioSpectrum) {}

  /// The remote playing streams audio spectrum callback.
  ///
  /// Available since: 1.1.0
  /// Description: The remote playing streams audio spectrum callback.
  /// Trigger: After you start the audio spectrum monitor by calling [startAudioSpectrumMonitor], you are in the state of playing the stream [startPlayingStream].
  /// Caution: The callback notification period is the parameter value set when the [startAudioSpectrumMonitor] is called.
  /// Related APIs: Start audio spectrum monitoring via [startAudioSpectrumMonitor]. Monitoring local played audio spectrum by callback [onCapturedAudioSpectrumUpdate].
  ///
  /// - [audioSpectrums] Remote audio spectrum hash map, key is the streamID, value is the audio spectrum list of the corresponding streamID. Spectrum value range is [0-2^30]
  void onRemoteAudioSpectrumUpdate(Map<String, List<double>> audioSpectrums) {}

  /// The callback triggered when a local device exception occurred.
  ///
  /// Available since: 2.15.0
  /// Description: The callback triggered when a local device exception occurs.
  /// Trigger: This callback is triggered when the function of the local audio or video device is abnormal.
  ///
  /// - [exceptionType] The type of the device exception.
  /// - [deviceType] The type of device where the exception occurred.
  /// - [deviceID] Device ID. Currently, only desktop devices are supported to distinguish different devices; for mobile devices, this parameter will return an empty string.
  void onLocalDeviceExceptionOccurred(
    ZegoDeviceExceptionType exceptionType,
    ZegoDeviceType deviceType,
    String deviceID,
  ) {}

  /// The callback triggered when the state of the remote camera changes.
  ///
  /// Available since: 1.1.0
  /// Description: The callback triggered when the state of the remote camera changes.
  /// Use cases: Developers of 1v1 education scenarios or education small class scenarios and similar scenarios can use this callback notification to determine whether the camera device of the remote publishing stream device is working normally, and preliminary understand the cause of the device problem according to the corresponding state.
  /// Trigger: When the state of the remote camera device changes, such as switching the camera, by monitoring this callback, it is possible to obtain an event related to the far-end camera, which can be used to prompt the user that the video may be abnormal.
  /// Caution: This callback will not be called back when the remote stream is play from the CDN, or when custom video acquisition is used at the peer.
  /// Note: This function is only available in ZegoExpressVideo SDK!
  ///
  /// - [streamID] Stream ID.
  /// - [state] Remote camera status.
  void onRemoteCameraStateUpdate(
    String streamID,
    ZegoRemoteDeviceState state,
  ) {}

  /// The callback triggered when the state of the remote microphone changes.
  ///
  /// Available since: 1.1.0
  /// Description: The callback triggered when the state of the remote microphone changes.
  /// Use cases: Developers of 1v1 education scenarios or education small class scenarios and similar scenarios can use this callback notification to determine whether the microphone device of the remote publishing stream device is working normally, and preliminary understand the cause of the device problem according to the corresponding state.
  /// Trigger: When the state of the remote microphone device is changed, such as switching a microphone, etc., by listening to the callback, it is possible to obtain an event related to the remote microphone, which can be used to prompt the user that the audio may be abnormal.
  /// Caution: This callback will not be called back when the remote stream is play from the CDN, or when custom audio acquisition is used at the peer (But the stream is not published to the ZEGO RTC server.).
  ///
  /// - [streamID] Stream ID.
  /// - [state] Remote microphone status.
  void onRemoteMicStateUpdate(String streamID, ZegoRemoteDeviceState state) {}

  /// The callback triggered when the state of the remote speaker changes.
  ///
  /// Available since: 1.1.0
  /// Description: The callback triggered when the state of the remote microphone changes.
  /// Use cases: Developers of 1v1 education scenarios or education small class scenarios and similar scenarios can use this callback notification to determine whether the speaker device of the remote publishing stream device is working normally, and preliminary understand the cause of the device problem according to the corresponding state.
  /// Trigger: When the state of the remote speaker device changes, such as switching the speaker, by monitoring this callback, you can get events related to the remote speaker.
  /// Caution: This callback will not be called back when the remote stream is play from the CDN.
  ///
  /// - [streamID] Stream ID.
  /// - [state] Remote speaker status.
  void onRemoteSpeakerStateUpdate(
    String streamID,
    ZegoRemoteDeviceState state,
  ) {}

  /// Callback for device's audio route changed.
  ///
  /// Available since: 1.20.0
  /// Description: Callback for device's audio route changed.
  /// Trigger: This callback will be called when there are changes in audio routing such as earphone plugging, speaker and receiver switching, etc.
  /// Platform differences: Only supports iOS and Android.
  ///
  /// - [audioRoute] Current audio route.
  void onAudioRouteChange(ZegoAudioRoute audioRoute) {}

  /// Callback for audio VAD  stable state update.
  ///
  /// Available since: 2.14.0
  /// Description: Callback for audio VAD  stable state update.
  /// When to trigger: the [startAudioVADStableStateMonitor] function must be called to start the audio VAD monitor and you must be in a state where it is publishing the audio and video stream or be in [startPreview] state.
  /// Restrictions: The callback notification period is 3 seconds.
  /// Related APIs: [startAudioVADStableStateMonitor], [stopAudioVADStableStateMonitor].
  ///
  /// - [type] audio VAD monitor type
  /// - [state] VAD result
  void onAudioVADStateUpdate(
    ZegoAudioVADStableStateMonitorType type,
    ZegoAudioVADType state,
  ) {}

  /// Callback for receiving real-time sequential data.
  ///
  /// Available since: 2.14.0
  /// Description: Through this callback, you can receive real-time sequential data from the current subscribing stream.
  /// Use cases: You need to listen to this callback when you need to receive real-time sequential data.
  /// When to trigger: After calling [startSubscribing] to successfully start the subscription, and when data is sent on the stream, this callback will be triggered.
  /// Restrictions: None.
  /// Caution: None.
  ///
  /// - [manager] The real-time sequential data manager instance that triggers this callback.
  /// - [data] The received real-time sequential data.
  /// - [streamID] Subscribed stream ID
  void onReceiveRealTimeSequentialData(
    ZegoRealTimeSequentialDataManager manager,
    Uint8List data,
    String streamID,
  ) {}

  /// The callback triggered when Barrage Messages are received.
  ///
  /// Available since: 1.5.0
  /// Description: This callback is used to receive room passthrough messages sent by other users in the same room.
  /// When to trigger: After calling [loginRoom] to login to the room, this callback is triggered if there is a user in the room who sends a message received by the specified client through the [sendTransparentMessage] function.
  /// Restrictions: None
  /// Caution: Barrage messages sent by users themselves will not be notified through this callback. When there are a large number of barrage messages in the room, the notification may be delayed, and some barrage messages may be lost.
  /// Related callbacks: A bullet-screen message sent by the user himself is not notified by this callback. [sendTransparentMessage] specifies that only a server callback is used. This callback is not triggered.
  ///
  /// - [roomID] Room ID. Value range: The maximum length is 128 bytes.
  /// - [message] recv message.
  void onRecvRoomTransparentMessage(
    String roomID,
    ZegoRoomRecvTransparentMessage message,
  ) {}

  /// The callback triggered when Broadcast Messages are received.
  ///
  /// Available since: 1.2.1
  /// Description: This callback is used to receive broadcast messages sent by other users in the same room.
  /// Use cases: Generally used when the number of people in the live room does not exceed 500
  /// When to trigger: After calling [loginRoom] to log in to the room, if a user in the room sends a broadcast message via [sendBroadcastMessage] function, this callback will be triggered.
  /// Restrictions: None
  /// Caution: The broadcast message sent by the user will not be notified through this callback.
  /// Related callbacks: You can receive room barrage messages through [onIMRecvBarrageMessage], and you can receive room custom signaling through [onIMRecvCustomCommand].
  ///
  /// - [roomID] Room ID. Value range: The maximum length is 128 bytes.
  /// - [messageList] List of received messages. Value range: Up to 50 messages can be received each time.
  void onIMRecvBroadcastMessage(
    String roomID,
    List<ZegoBroadcastMessageInfo> messageList,
  ) {}

  /// The callback triggered when Barrage Messages are received.
  ///
  /// Available since: 1.5.0
  /// Description: This callback is used to receive barrage messages sent by other users in the same room.
  /// Use cases: Generally used in scenarios where there is a large number of messages sent and received in the room and the reliability of the messages is not required, such as live barrage.
  /// When to trigger: After calling [loginRoom] to log in to the room, if a user in the room sends a barrage message through the [sendBarrageMessage] function, this callback will be triggered.
  /// Restrictions: None
  /// Caution: Barrage messages sent by users themselves will not be notified through this callback. When there are a large number of barrage messages in the room, the notification may be delayed, and some barrage messages may be lost.
  /// Related callbacks: Develop can receive room broadcast messages through [onIMRecvBroadcastMessage], and can receive room custom signaling through [onIMRecvCustomCommand].
  ///
  /// - [roomID] Room ID. Value range: The maximum length is 128 bytes.
  /// - [messageList] List of received messages. Value range: Up to 50 messages can be received each time.
  void onIMRecvBarrageMessage(
    String roomID,
    List<ZegoBarrageMessageInfo> messageList,
  ) {}

  /// The callback triggered when a Custom Command is received.
  ///
  /// Available since: 1.2.1
  /// Description: This callback is used to receive custom command sent by other users in the same room.
  /// Use cases: Generally used when the number of people in the live room does not exceed 500
  /// When to trigger: After calling [loginRoom] to log in to the room, if other users in the room send custom signaling to the developer through the [sendCustomCommand] function, this callback will be triggered.
  /// Restrictions: None
  /// Caution: The custom command sent by the user himself will not be notified through this callback.
  /// Related callbacks: You can receive room broadcast messages through [onIMRecvBroadcastMessage], and you can receive room barrage message through [onIMRecvBarrageMessage].
  ///
  /// - [roomID] Room ID. Value range: The maximum length is 128 bytes.
  /// - [fromUser] Sender of the command.
  /// - [command] Command content received.Value range: The maximum length is 1024 bytes.
  void onIMRecvCustomCommand(
    String roomID,
    ZegoUser fromUser,
    String command,
  ) {}

  /// Audio effect playback state callback.
  ///
  /// Available since: 1.16.0
  /// Description: This callback is triggered when the playback state of a audio effect of the audio effect player changes.
  /// Trigger: This callback is triggered when the playback status of the audio effect changes.
  /// Restrictions: None.
  ///
  /// - [audioEffectPlayer] Audio effect player instance that triggers this callback.
  /// - [audioEffectID] The ID of the audio effect resource that triggered this callback.
  /// - [state] The playback state of the audio effect.
  /// - [errorCode] Error code, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  void onAudioEffectPlayStateUpdate(
    ZegoAudioEffectPlayer audioEffectPlayer,
    int audioEffectID,
    ZegoAudioEffectPlayState state,
    int errorCode,
  ) {}

  /// The callback triggered when the state of data recording (to a file) changes.
  ///
  /// Available since: 1.10.0
  /// Description: The callback triggered when the state of data recording (to a file) changes.
  /// Use cases: The developer should use this callback to determine the status of the file recording or for UI prompting.
  /// When to trigger: After [startRecordingCapturedData] is called, if the state of the recording process changes, this callback will be triggered.
  /// Restrictions: None.
  ///
  /// - [state] File recording status.
  /// - [errorCode] Error code, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  /// - [config] Record config.
  /// - [channel] Publishing stream channel.
  void onCapturedDataRecordStateUpdate(
    ZegoDataRecordState state,
    int errorCode,
    ZegoDataRecordConfig config,
    ZegoPublishChannel channel,
  ) {}

  /// The callback to report the current recording progress.
  ///
  /// Available since: 1.10.0
  /// Description: Recording progress update callback, triggered at regular intervals during recording.
  /// Use cases: Developers can do UI hints for the user interface.
  /// When to trigger: After [startRecordingCapturedData] is called, If configured to require a callback, timed trigger during recording.
  /// Restrictions: None.
  ///
  /// - [progress] File recording progress, which allows developers to hint at the UI, etc.
  /// - [config] Record config.
  /// - [channel] Publishing stream channel.
  void onCapturedDataRecordProgressUpdate(
    ZegoDataRecordProgress progress,
    ZegoDataRecordConfig config,
    ZegoPublishChannel channel,
  ) {}

  /// System performance monitoring callback.
  ///
  /// Available since: 1.19.0
  /// Description: System performance monitoring callback. The callback notification period is the value of millisecond parameter set by call [startPerformanceMonitor].
  /// Use cases: Monitor system performance can help user quickly locate and solve performance problems and improve user experience.
  /// When to trigger: It will triggered after [createEngine], and call [startPerformanceMonitor] to start system performance monitoring.
  /// Restrictions: None.
  ///
  /// - [status] System performance monitoring status.
  void onPerformanceStatusUpdate(ZegoPerformanceStatus status) {}

  /// Network mode changed callback.
  ///
  /// Available since: 1.20.0
  /// Description: Network mode changed callback.
  /// When to trigger: This callback will be triggered when the device's network mode changed, such as switched from WiFi to 5G, or when network is disconnected.
  /// Restrictions: None.
  ///
  /// - [mode] Current network mode.
  void onNetworkModeChanged(ZegoNetworkMode mode) {}

  /// Network speed test error callback.
  ///
  /// Available since: 1.20.0
  /// Description: Network speed test error callback.
  /// Use cases: This function can be used to detect whether the network environment is suitable for pushing/pulling streams with specified bitrate.
  /// When to Trigger: If an error occurs during the speed test, such as: can not connect to speed test server, this callback will be triggered.
  /// Restrictions: None.
  ///
  /// - [errorCode] Network speed test error code. Please refer to error codes document https://docs.zegocloud.com/en/5548.html for details.
  /// - [type] Uplink or down-link.
  void onNetworkSpeedTestError(int errorCode, ZegoNetworkSpeedTestType type) {}

  /// Network speed test quality callback.
  ///
  /// Available since: 1.20.0
  /// Description: Network speed test quality callback when the network can be connected.
  /// Use cases: This function can be used to detect whether the network environment is suitable for pushing/pulling streams with specified bitrate.
  /// When to Trigger: After call [startNetworkSpeedTest] start network speed test, this callback will be triggered. The trigger period is determined by the parameter value specified by call [startNetworkSpeedTest], default value is 3 seconds
  /// Restrictions: None.
  /// Caution: When error occurred during network speed test or [stopNetworkSpeedTest] called, this callback will not be triggered.
  ///
  /// - [quality] Network speed test quality.
  /// - [type] Uplink or down-link.
  void onNetworkSpeedTestQualityUpdate(
    ZegoNetworkSpeedTestQuality quality,
    ZegoNetworkSpeedTestType type,
  ) {}

  /// The network quality callback of users who are publishing in the room.
  ///
  /// Available since: 2.10.0
  /// Description: The uplink and down-link network callbacks of the local and remote users, that would be called by default every two seconds for the local and each playing remote user's network quality.
  ///   Versions 2.10.0 to 2.13.1:
  ///   1. Developer must both publish and play streams before you receive your own network quality callback.
  ///   2. When playing a stream, the publish end has a play stream and the publish end is in the room where it is located, then the user's network quality will be received.
  ///   Versions 2.14.0 to 2.21.1:
  ///   1. As long as you publish or play a stream, you will receive your own network quality callback.
  ///   2. When you play a stream, the publish end is in the room where you are, and you will receive the user's network quality.
  ///   Version 2.22.0 and above:
  ///   1. Estimate the network conditions of the remote stream publishing user. If the remote stream publishing user loses one heartbeat, the network quality will be called back as unknown; if the remote stream publishing user's heartbeat loss reaches 3 Second, call back its network quality to die.
  /// Use case: When the developer wants to analyze the network condition on the link, or wants to know the network condition of local and remote users.
  /// When to Trigger: After publishing a stream by called [startPublishingStream] or playing a stream by called [startPlayingStream].
  ///
  /// - [userID] User ID, empty means local user
  /// - [upstreamQuality] Upstream network quality
  /// - [downstreamQuality] Downstream network quality
  void onNetworkQuality(
    String userID,
    ZegoStreamQualityLevel upstreamQuality,
    ZegoStreamQualityLevel downstreamQuality,
  ) {}

  /// Successful callback of network time synchronization.
  ///
  /// Available since: 2.12.0
  /// This callback is triggered when internal network time synchronization completes after a developer calls [createEngine].
  void onNetworkTimeSynchronized() {}

  /// Request to dump data.
  ///
  /// Available since: 3.10.0
  /// When to Trigger: When the customer reports back the problem, ZEGO expects the user to dump the data to analyze the audio / video processing problem, which will trigger this callback.
  void onRequestDumpData() {}

  /// Request to dump data.
  ///
  /// Available since: 3.11.0
  /// When to Trigger: When the customer reports back the problem, ZEGO expects the user to dump the data to analyze the audio / video processing problem, which will trigger this callback.
  ///
  /// - [dumpDir] Dump data dir.
  /// - [takePhoto] Need to take photo when uploading dump data
  void onRequestUploadDumpData(String dumpDir, bool takePhoto) {}

  /// Callback when starting to dump data.
  ///
  /// Available since: 3.10.0
  /// When to Trigger: This callback is triggered when [startDumpData] is called.
  ///
  /// - [errorCode] Error code.
  void onStartDumpData(int errorCode) {}

  /// Callback when stopping to dump data.
  ///
  /// Available since: 3.10.0
  /// When to Trigger: This callback is triggered when [stopDumpData] is called.
  ///
  /// - [errorCode] Error code.
  /// - [dumpDir] Dump data dir.
  void onStopDumpData(int errorCode, String dumpDir) {}

  /// Callback after uploading the dump data.
  ///
  /// Available since: 3.10.0
  /// When to Trigger: When [uploadDumpData] is called, this callback will be triggered after SDK executes the upload task.
  ///
  /// - [errorCode] Error code.
  void onUploadDumpData(int errorCode) {}

  /// Custom audio processing local captured PCM audio frame callback.
  ///
  /// Available: Since 2.13.0
  /// Description: In this callback, you can receive the PCM audio frames captured locally after used headphone monitor. Developers can modify the audio frame data, as well as the audio channels and sample rate. The timestamp can be used for data synchronization, such as lyrics, etc. If you need the data after used headphone monitor, please use the [onProcessCapturedAudioDataAfterUsedHeadphoneMonitor] callback.
  /// When to trigger: You need to call [enableCustomAudioCaptureProcessing] to enable the function first, and call [startPreview] or [startPublishingStream] to trigger this callback function.
  /// Restrictions: None.
  /// Caution: This callback is a high-frequency callback, please do not perform time-consuming operations in this callback.
  ///
  /// - [data] Audio data in PCM format.
  /// - [dataLength] Length of the data.
  /// - [param] Parameters of the audio frame.
  /// - [timestamp] The audio frame timestamp, starting from 0 when capture is started, the unit is milliseconds.
  void onProcessCapturedAudioData(
    Uint8List data,
    int dataLength,
    ZegoAudioFrameParam param,
    double timestamp,
  ) {}

  /// Custom audio processing local captured PCM audio frame callback after used headphone monitor.
  ///
  /// Available: Since 2.13.0
  /// Description: In this callback, you can receive the PCM audio frames captured locally after used headphone monitor. Developers can modify the audio frame data, as well as the audio channels and sample rate. The timestamp can be used for data synchronization, such as lyrics, etc.
  /// When to trigger: You need to call [enableCustomAudioCaptureProcessingAfterHeadphoneMonitor] to enable the function first, and call [startPreview] or [startPublishingStream] to trigger this callback function.
  /// Caution: This callback is a high-frequency callback, please do not perform time-consuming operations in this callback.
  ///
  /// - [data] Audio data in PCM format
  /// - [dataLength] Length of the data
  /// - [param] Parameters of the audio frame
  /// - [timestamp] The audio frame timestamp, starting from 0 when capture is started, the unit is milliseconds.
  void onProcessCapturedAudioDataAfterUsedHeadphoneMonitor(
    Uint8List data,
    int dataLength,
    ZegoAudioFrameParam param,
    double timestamp,
  ) {}

  /// Aligned audio aux frames callback.
  ///
  /// Available: Since 2.22.0
  /// Description: In this callback, you can receive the audio aux frames which aligned with accompany. Developers can record locally.
  /// When to trigger: This callback function will not be triggered until [enableAlignedAudioAuxData] is called to turn on the function and [startPublishingStream] or [startRecordingCapturedData] is called.
  /// Restrictions: To obtain audio aux data of the media player from this callback, developers need to call [enableAux] and [start] of MediaPlayer.
  /// Caution: This callback is a high-frequency callback, please do not perform time-consuming operations in this callback, and the data in this callback cannot be modified.
  ///
  /// - [data] Audio data in PCM format.
  /// - [param] Parameters of the audio frame.
  void onAlignedAudioAuxData(Uint8List data, ZegoAudioFrameParam param) {}

  /// Custom audio processing remote playing stream PCM audio frame callback.
  ///
  /// Available: Since 2.13.0
  /// Description: In this callback, you can receive the PCM audio frames of remote playing stream. Developers can modify the audio frame data, as well as the audio channels and sample rate. The timestamp can be used for data synchronization, such as lyrics, etc.
  /// When to trigger: You need to call [enableCustomAudioRemoteProcessing] to enable the function first, and call [startPlayingStream] to trigger this callback function.
  /// Restrictions: None.
  /// Caution: This callback is a high-frequency callback, please do not perform time-consuming operations in this callback.
  ///
  /// - [data] Audio data in PCM format.
  /// - [dataLength] Length of the data.
  /// - [param] Parameters of the audio frame.
  /// - [streamID] Corresponding stream ID.
  /// - [timestamp] The audio frame timestamp, starting from 0 when capture is started, the unit is milliseconds.
  void onProcessRemoteAudioData(
    Uint8List data,
    int dataLength,
    ZegoAudioFrameParam param,
    String streamID,
    double timestamp,
  ) {}

  /// Custom audio processing SDK playback PCM audio frame callback.
  ///
  /// Available: Since 2.13.0
  /// Description: In this callback, you can receive the SDK playback PCM audio frame. Developers can modify the audio frame data, as well as the audio channels and sample rate. The timestamp can be used for data synchronization, such as lyrics, etc.
  /// When to trigger: You need to call [enableCustomAudioPlaybackProcessing] to enable the function first, and call [startPublishingStream], [startPlayingStream], [startPreview], [createMediaPlayer] or [createAudioEffectPlayer] to trigger this callback function.
  /// Restrictions: None.
  /// Caution: This callback is a high-frequency callback, please do not perform time-consuming operations in this callback.
  ///
  /// - [data] Audio data in PCM format.
  /// - [dataLength] Length of the data.
  /// - [param] Parameters of the audio frame.
  /// - [timestamp] The audio frame timestamp, starting from 0 when capture is started, the unit is milliseconds (It is effective when there is one and only one stream).
  void onProcessPlaybackAudioData(
    Uint8List data,
    int dataLength,
    ZegoAudioFrameParam param,
    double timestamp,
  ) {}

  /// The callback for obtaining the audio data captured by the local microphone.
  ///
  /// Available: Since 1.1.0
  /// Description: In non-custom audio capture mode, the SDK capture the microphone's sound, but the developer may also need to get a copy of the audio data captured by the SDK is available through this callback.
  /// When to trigger: On the premise of calling [setAudioDataHandler] to set the listener callback, after calling [startAudioDataObserver] to set the mask 0b01 that means 1 << 0, this callback will be triggered only when it is in the publishing stream state.
  /// Restrictions: None.
  /// Caution: This callback is a high-frequency callback, please do not perform time-consuming operations in this callback.
  ///
  /// - [data] Audio data in PCM format.
  /// - [dataLength] Length of the data.
  /// - [param] Parameters of the audio frame.
  void onCapturedAudioData(
    Uint8List data,
    int dataLength,
    ZegoAudioFrameParam param,
  ) {}

  /// The callback for obtaining the audio data of all the streams playback by SDK.
  ///
  /// Available: Since 1.1.0
  /// Description: This function will callback all the mixed audio data to be playback. This callback can be used for that you needs to fetch all the mixed audio data to be playback to process.
  /// When to trigger: On the premise of calling [setAudioDataHandler] to set the listener callback, after calling [startAudioDataObserver] to set the mask 0b10 that means 1 << 1, this callback will be triggered only when it is in the SDK inner audio and video engine started(called the [startPreview] or [startPlayingStream] or [startPublishingStream]).
  /// Restrictions: When playing copyrighted music, this callback will be disabled by default. If necessary, please contact ZEGO technical support.
  /// Caution: This callback is a high-frequency callback. Please do not perform time-consuming operations in this callback. When the engine is not in the stream publishing state and the media player is not used to play media files, the audio data in the callback is muted audio data.
  ///
  /// - [data] Audio data in PCM format.
  /// - [dataLength] Length of the data.
  /// - [param] Parameters of the audio frame.
  void onPlaybackAudioData(
    Uint8List data,
    int dataLength,
    ZegoAudioFrameParam param,
  ) {}

  /// Callback to get the audio data played by the SDK and the audio data captured by the local microphone. The audio data is the data mixed by the SDK.
  ///
  /// Available: Since 1.1.0
  /// Description: The audio data played by the SDK is mixed with the data captured by the local microphone before being sent to the speaker, and is called back through this function.
  /// When to trigger: On the premise of calling [setAudioDataHandler] to set the listener callback, after calling [startAudioDataObserver] to set the mask 0x04, this callback will be triggered only when it is in the publishing stream state or playing stream state.
  /// Restrictions: When playing copyrighted music, this callback will be disabled by default. If necessary, please contact ZEGO technical support.
  /// Caution: This callback is a high-frequency callback, please do not perform time-consuming operations in this callback.
  ///
  /// - [data] Audio data in PCM format.
  /// - [dataLength] Length of the data.
  /// - [param] Parameters of the audio frame.
  void onMixedAudioData(
    Uint8List data,
    int dataLength,
    ZegoAudioFrameParam param,
  ) {}

  /// The callback for obtaining the audio data of each stream.
  ///
  /// Available: Since 1.1.0
  /// Description: This function will call back the data corresponding to each playing stream. Different from [onPlaybackAudioData], the latter is the mixed data of all playing streams. If developers need to process a piece of data separately, they can use this callback.
  /// When to trigger: On the premise of calling [setAudioDataHandler] to set up listening for this callback, calling [startAudioDataObserver] to set the mask 0x08 that is 1 << 3, and this callback will be triggered when the SDK audio and video engine starts to play the stream.
  /// Restrictions: None.
  /// Caution: This callback is a high-frequency callback, please do not perform time-consuming operations in this callback.
  ///
  /// - [data] Audio data in PCM format.
  /// - [dataLength] Length of the data.
  /// - [param] Parameters of the audio frame.
  /// - [streamID] Corresponding stream ID.
  void onPlayerAudioData(
    Uint8List data,
    int dataLength,
    ZegoAudioFrameParam param,
    String streamID,
  ) {}

  /// Range audio microphone state callback.
  ///
  /// Available since: 2.11.0
  /// Description: The status change notification of the microphone, starting to send audio is an asynchronous process, and the state switching in the middle is called back through this function.
  /// When to Trigger: After the [enableMicrophone] function.
  /// Caution: It must be monitored before the [enableMicrophone] function is called.
  ///
  /// - [rangeAudio] Range audio instance that triggers this callback.
  /// - [state] The use state of the range audio.
  /// - [errorCode] Error code, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  void onRangeAudioMicrophoneStateUpdate(
    ZegoRangeAudio rangeAudio,
    ZegoRangeAudioMicrophoneState state,
    int errorCode,
  ) {}

  /// Callback for download song or accompaniment progress rate.
  ///
  /// - [copyrightedMusic] Copyrighted music instance that triggers this callback.
  /// - [resourceID] The resource ID of the song or accompaniment that triggered this callback.
  /// - [progressRate] download progress rate.
  void onDownloadProgressUpdate(
    ZegoCopyrightedMusic copyrightedMusic,
    String resourceID,
    double progressRate,
  ) {}

  /// Real-time pitch line callback.
  ///
  /// - [copyrightedMusic] Copyrighted music instance that triggers this callback.
  /// - [resourceID] The resource ID of the song or accompaniment that triggered this callback.
  /// - [currentDuration] Current playback progress.
  /// - [pitchValue] Real-time pitch accuracy or value.
  void onCurrentPitchValueUpdate(
    ZegoCopyrightedMusic copyrightedMusic,
    String resourceID,
    int currentDuration,
    int pitchValue,
  ) {}

  /// The callback triggered when a screen capture source exception occurred
  ///
  /// Available since: 3.1.0
  /// Description: The callback triggered when a screen capture source exception occurred.
  /// Trigger: This callback is triggered when an exception occurs after the screen start capture.
  /// Caution: The callback does not actually take effect until call [setEventHandler] to set.
  /// Restrictions: Only available on Windows/macOS.
  ///
  /// - [source] Callback screen capture source object.
  /// - [exceptionType] Capture source exception type.
  void onScreenCaptureExceptionOccurred(
    ZegoScreenCaptureSource source,
    ZegoScreenCaptureSourceExceptionType exceptionType,
  ) {}

  /// The callback will be triggered when the state of the capture target window change.
  ///
  /// Available since: 3.4.0
  /// Caution: The callback does not actually take effect until call [setEventHandler] to set.
  /// Restrictions: Only available on Windows/macOS.
  ///
  /// - [source] Callback screen capture source object.
  /// - [windowState] Capture window state.
  /// - [windowRect] Capture window rect.
  void onScreenCaptureWindowStateChanged(
    ZegoScreenCaptureSource source,
    ZegoScreenCaptureWindowState windowState,
    Rect windowRect,
  ) {}

  /// The callback will be triggered when the state of the capture target window change.
  ///
  /// Available since: 3.7.0
  /// Caution: The callback does not actually take effect until call [setEventHandler] to set.
  /// Restrictions: Only available on Windows/macOS.
  ///
  /// - [source] Callback screen capture source object.
  /// - [captureRect] Capture source rect.
  void onScreenCaptureSourceRectChanged(
    ZegoScreenCaptureSource source,
    Rect captureRect,
  ) {}

  /// The callback triggered when a screen capture source exception occurred
  ///
  /// Available since: 3.6.0
  /// Description: The callback triggered when the mobile screen capture source exception occurred.
  /// Trigger: This callback is triggered when an exception occurs after the mobile screen capture started.
  /// Caution: The callback does not actually take effect until call [setEventHandler] to set.
  /// Restrictions: Only available on Android.
  ///
  /// - [exceptionType] Screen capture exception type.
  void onMobileScreenCaptureExceptionOccurred(
    ZegoScreenCaptureExceptionType exceptionType,
  ) {}

  /// Initialize AI voice changer engine status callback.
  ///
  /// Available since: 3.10.0.
  /// Description: Initialize AI voice changer engine status callback.
  /// Trigger: The callback triggered when call [init] function.
  /// Restrictions: None.
  ///
  /// - [aiVoiceChanger] Callback AI voice changer instance.
  /// - [errorCode] Error code, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  void onAIVoiceChangerInit(ZegoAIVoiceChanger aiVoiceChanger, int errorCode) {}

  /// Update AI voice changer engine models status callback.
  ///
  /// Available since: 3.10.0.
  /// Description: Update AI voice changer engine models status callback.
  /// Trigger: The callback triggered when call [update] function.
  /// Restrictions: None.
  ///
  /// - [aiVoiceChanger] Callback AI voice changer instance.
  /// - [errorCode] Error code, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  void onAIVoiceChangerUpdate(
    ZegoAIVoiceChanger aiVoiceChanger,
    int errorCode,
  ) {}

  /// Get AI voice changer engine available speaker list callback.
  ///
  /// Available since: 3.10.0.
  /// Description: Get AI voice changer engine available speaker list callback.
  /// Trigger: The callback triggered when call [getSpeakerList] function.
  /// Restrictions: None.
  ///
  /// - [aiVoiceChanger] Callback AI voice changer instance.
  /// - [errorCode] Error code, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  /// - [speakerList] Available speaker list.
  void onAIVoiceChangerGetSpeakerList(
    ZegoAIVoiceChanger aiVoiceChanger,
    int errorCode,
    List<ZegoAIVoiceChangerSpeakerInfo> speakerList,
  ) {}
}
