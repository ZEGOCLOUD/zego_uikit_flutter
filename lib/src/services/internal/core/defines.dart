part of 'core.dart';

/// @nodoc
const streamExtraInfoCameraKey = 'isCameraOn';

/// @nodoc
const streamExtraInfoMicrophoneKey = 'isMicrophoneOn';

/// @nodoc
class ZegoUIKitSEIDefines {
  /// @nodoc
  static const keySEI = 'sei';

  /// @nodoc
  static const keyTypeIdentifier = 'type';

  /// @nodoc
  static const keyUserID = 'uid';

  /// @nodoc
  static const keyCamera = 'cam';

  /// @nodoc
  static const keyMicrophone = 'mic';

  /// @nodoc
  static const keyMediaStatus = 'md_stat';

  /// @nodoc
  static const keyMediaProgress = 'md_pro';

  /// @nodoc
  static const keyMediaDuration = 'md_dur';

  /// @nodoc
  static const keyMediaType = 'md_type';

  /// @nodoc
  static const keyMediaSoundLevel = 'md_s_l';
}

/// @nodoc
class ZegoUIKitCoreMixerStream {
  final String streamID;
  int viewID = -1;
  final view = ValueNotifier<Widget?>(null);
  final loaded = ValueNotifier<bool>(false); // first frame
  StreamController<Map<int, double>>? soundLevels;

  final usersNotifier = ValueNotifier<List<ZegoUIKitCoreUser>>([]);
  StreamController<List<ZegoUIKitCoreUser>>? userListStreamCtrl;

  void addUser(ZegoUIKitCoreUser user) {
    usersNotifier.value = List.from(usersNotifier.value)..add(user);

    userListStreamCtrl?.add(usersNotifier.value);
  }

  void removeUser(ZegoUIKitCoreUser user) {
    usersNotifier.value = List.from(usersNotifier.value)
      ..removeWhere((e) => e.id == user.id);

    userListStreamCtrl?.add(usersNotifier.value);
  }

  /// userid, sound id
  Map<String, int> userSoundIDs = {};

  ZegoUIKitCoreMixerStream(
    this.streamID,
    this.userSoundIDs,
    List<ZegoUIKitCoreUser> users,
  ) {
    usersNotifier.value = List.from(users);
    userListStreamCtrl ??=
        StreamController<List<ZegoUIKitCoreUser>>.broadcast();

    soundLevels ??= StreamController<Map<int, double>>.broadcast();
  }

  void destroyTextureRenderer({bool isMainStream = true}) {
    if (viewID != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(viewID);
    }
    viewID = -1;
    view.value = null;
    soundLevels?.close();

    userListStreamCtrl?.close();
    userListStreamCtrl = null;
  }
}

/// @nodoc
typedef ZegoUIKitUserAttributes = Map<String, String>;

/// @nodoc
extension ZegoUIKitUserAttributesExtension on ZegoUIKitUserAttributes {
  String get avatarURL {
    return this[attributeKeyAvatar] ?? '';
  }
}

class ZegoUIKitCoreStreamInfo {
  String streamID = '';
  int streamTimestamp = 0;

  int viewID = -1;
  ValueNotifier<Widget?> view = ValueNotifier<Widget?>(null);
  ValueNotifier<Size> viewSize = ValueNotifier<Size>(const Size(360, 640));
  StreamController<double>? soundLevel;

  ValueNotifier<ZegoUIKitPublishStreamQuality> quality =
      ValueNotifier<ZegoUIKitPublishStreamQuality>(
          ZegoPublishStreamQualityExtension.empty().toUIKit());
  ValueNotifier<bool> isCapturedAudioFirstFrame = ValueNotifier<bool>(false);
  ValueNotifier<bool> isCapturedVideoFirstFrame = ValueNotifier<bool>(false);
  ValueNotifier<bool> isRenderedVideoFirstFrame = ValueNotifier<bool>(false);
  ValueNotifier<bool> isSendAudioFirstFrame = ValueNotifier<bool>(false);
  ValueNotifier<bool> isSendVideoFirstFrame = ValueNotifier<bool>(false);
  ValueNotifier<GlobalKey> globalKey = ValueNotifier<GlobalKey>(GlobalKey());

  ZegoUIKitCoreStreamInfo.empty() {
    soundLevel ??= StreamController<double>.broadcast();
  }

  void closeSoundLevel() {
    soundLevel?.close();
  }

  void clearViewInfo() {
    viewID = -1;
    view.value = null;
    viewSize.value = const Size(360, 640);

    quality.value = ZegoPublishStreamQualityExtension.empty().toUIKit();
    isCapturedAudioFirstFrame.value = false;
    isCapturedVideoFirstFrame.value = false;
    isRenderedVideoFirstFrame.value = false;
    isSendAudioFirstFrame.value = false;
    isSendVideoFirstFrame.value = false;
  }
}

/// @nodoc
// user
class ZegoUIKitCoreUser {
  ZegoUIKitCoreUser(this.id, this.name);

  ZegoUIKitCoreUser.fromZego(ZegoUser user) : this(user.userID, user.userName);

  ZegoUIKitCoreUser.empty();

  ZegoUIKitCoreUser.localDefault() {
    camera.value = false;
    microphone.value = false;
  }

  String id = '';
  String name = '';

  ValueNotifier<bool> camera = ValueNotifier<bool>(false);
  ValueNotifier<bool> cameraMuteMode = ValueNotifier<bool>(false);
  ValueNotifier<ZegoUIKitDeviceExceptionType?> cameraException =
      ValueNotifier<ZegoUIKitDeviceExceptionType?>(null);

  ValueNotifier<bool> microphone = ValueNotifier<bool>(false);
  ValueNotifier<bool> microphoneMuteMode = ValueNotifier<bool>(false);
  ValueNotifier<ZegoUIKitDeviceExceptionType?> microphoneException =
      ValueNotifier<ZegoUIKitDeviceExceptionType?>(null);

  ValueNotifier<ZegoUIKitUserAttributes> inRoomAttributes =
      ValueNotifier<ZegoUIKitUserAttributes>({});

  ZegoUIKitCoreStreamInfo mainChannel = ZegoUIKitCoreStreamInfo.empty();
  ZegoUIKitCoreStreamInfo auxChannel = ZegoUIKitCoreStreamInfo.empty();
  ZegoUIKitCoreStreamInfo thirdChannel = ZegoUIKitCoreStreamInfo.empty();

  bool isAnotherRoomUser = false;

  ValueNotifier<ZegoStreamQualityLevel> network =
      ValueNotifier<ZegoStreamQualityLevel>(ZegoStreamQualityLevel.Excellent);

  // only for local
  ValueNotifier<bool> isFrontFacing = ValueNotifier<bool>(true);
  ValueNotifier<bool> isFrontTriggerByTurnOnCamera = ValueNotifier<bool>(false);
  ValueNotifier<bool> isVideoMirror = ValueNotifier<bool>(false);
  ValueNotifier<ZegoUIKitAudioRoute> audioRoute =
      ValueNotifier<ZegoUIKitAudioRoute>(ZegoUIKitAudioRoute.receiver);
  ZegoUIKitAudioRoute lastAudioRoute = ZegoUIKitAudioRoute.receiver;

  void clear() {
    id = '';
    name = '';

    network.value = ZegoStreamQualityLevel.Excellent;

    isFrontFacing.value = true;
    isFrontTriggerByTurnOnCamera.value = false;
    isVideoMirror.value = false;
    audioRoute.value = ZegoUIKitAudioRoute.receiver;
    lastAudioRoute = ZegoUIKitAudioRoute.receiver;

    clearRoomAttribute();
  }

  void clearRoomAttribute() {
    camera.value = false;
    cameraMuteMode.value = false;
    cameraException.value = null;

    microphone.value = false;
    microphoneMuteMode.value = false;
    microphoneException.value = null;

    inRoomAttributes.value = {};

    mainChannel = ZegoUIKitCoreStreamInfo.empty();
    auxChannel = ZegoUIKitCoreStreamInfo.empty();
    thirdChannel = ZegoUIKitCoreStreamInfo.empty();

    isAnotherRoomUser = false;
  }

  bool get isEmpty => id.isEmpty;

  Future<void> destroyTextureRenderer(
      {required ZegoStreamType streamType}) async {
    switch (streamType) {
      case ZegoStreamType.main:
        if (mainChannel.viewID != -1) {
          await ZegoExpressEngine.instance.destroyCanvasView(
            mainChannel.viewID,
          );
        }

        mainChannel.clearViewInfo();
        break;
      case ZegoStreamType.media:
      case ZegoStreamType.screenSharing:
      case ZegoStreamType.mix:
        if (auxChannel.viewID != -1) {
          await ZegoExpressEngine.instance.destroyCanvasView(auxChannel.viewID);
        }

        auxChannel.clearViewInfo();
        break;
    }
  }

  ZegoUIKitUser toZegoUikitUser() => ZegoUIKitUser(id: id, name: name);

  ZegoUser toZegoUser() => ZegoUser(id, name);

  @override
  String toString() {
    return 'id:$id, name:$name';
  }
}

/// @nodoc
String generateStreamID(String userID, String roomID, ZegoStreamType type) {
  return '${roomID}_${userID}_${type.text}';
}

/// @nodoc
// room
class ZegoUIKitCoreRoom {
  ZegoUIKitCoreRoom(this.id) {
    ZegoLoggerService.logInfo(
      'create $id',
      tag: 'uikit-service-core',
      subTag: 'core room',
    );
  }

  String id = '';

  bool isLargeRoom = false;
  bool markAsLargeRoom = false;

  ValueNotifier<ZegoUIKitRoomState> state = ValueNotifier<ZegoUIKitRoomState>(
    ZegoUIKitRoomState(ZegoRoomStateChangedReason.Logout, 0, {}),
  );

  bool roomExtraInfoHadArrived = false;
  Map<String, RoomProperty> properties = {};
  bool propertiesAPIRequesting = false;
  Map<String, String> pendingProperties = {};

  StreamController<RoomProperty>? propertyUpdateStream;
  StreamController<Map<String, RoomProperty>>? propertiesUpdatedStream;
  StreamController<int>? tokenExpiredStreamCtrl;

  void init() {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'uikit-service-core',
      subTag: 'core room',
    );

    propertyUpdateStream ??= StreamController<RoomProperty>.broadcast();
    propertiesUpdatedStream ??=
        StreamController<Map<String, RoomProperty>>.broadcast();
    tokenExpiredStreamCtrl ??= StreamController<int>.broadcast();
  }

  void uninit() {
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'uikit-service-core',
      subTag: 'core room',
    );

    propertyUpdateStream?.close();
    propertyUpdateStream = null;

    propertiesUpdatedStream?.close();
    propertiesUpdatedStream = null;

    tokenExpiredStreamCtrl?.close();
    tokenExpiredStreamCtrl = null;
  }

  void clear() {
    ZegoLoggerService.logInfo(
      'clear',
      tag: 'uikit-service-core',
      subTag: 'core room',
    );

    id = '';

    properties.clear();
    propertiesAPIRequesting = false;
    pendingProperties.clear();
  }

  ZegoUIKitRoom toUIKitRoom() {
    return ZegoUIKitRoom(id: id);
  }
}

/// @nodoc
// video config
class ZegoUIKitVideoInternalConfig {
  ZegoUIKitVideoInternalConfig({
    this.resolution = ZegoPresetResolution.Preset360P,
    this.orientation = DeviceOrientation.portraitUp,
    this.useVideoViewAspectFill = false,
  });

  ZegoPresetResolution resolution;
  DeviceOrientation orientation;
  bool useVideoViewAspectFill;

  bool needUpdateOrientation(ZegoUIKitVideoInternalConfig newConfig) {
    return orientation != newConfig.orientation;
  }

  bool needUpdateVideoConfig(ZegoUIKitVideoInternalConfig newConfig) {
    return (resolution != newConfig.resolution) ||
        (orientation != newConfig.orientation);
  }

  ZegoVideoConfig toZegoVideoConfig() {
    final config = ZegoVideoConfig.preset(resolution);
    if (orientation == DeviceOrientation.landscapeLeft ||
        orientation == DeviceOrientation.landscapeRight) {
      var tmp = config.captureHeight;
      config
        ..captureHeight = config.captureWidth
        ..captureWidth = tmp;

      tmp = config.encodeHeight;
      config
        ..encodeHeight = config.encodeWidth
        ..encodeWidth = tmp;
    }
    return config;
  }

  ZegoUIKitVideoInternalConfig copyWith({
    ZegoPresetResolution? resolution,
    DeviceOrientation? orientation,
    bool? useVideoViewAspectFill,
  }) =>
      ZegoUIKitVideoInternalConfig(
        resolution: resolution ?? this.resolution,
        orientation: orientation ?? this.orientation,
        useVideoViewAspectFill:
            useVideoViewAspectFill ?? this.useVideoViewAspectFill,
      );
}

/// @nodoc
class ZegoUIKitAdvancedConfigKey {
  static const String videoViewMode = 'videoViewMode';
}

extension ZegoAudioVideoResourceModeExtension on ZegoAudioVideoResourceMode {
  ZegoStreamResourceMode get toSdkValue {
    switch (this) {
      case ZegoAudioVideoResourceMode.defaultMode:
        return ZegoStreamResourceMode.Default;
      case ZegoAudioVideoResourceMode.onlyCDN:
        return ZegoStreamResourceMode.OnlyCDN;
      case ZegoAudioVideoResourceMode.onlyL3:
        return ZegoStreamResourceMode.OnlyL3;
      case ZegoAudioVideoResourceMode.onlyRTC:
        return ZegoStreamResourceMode.OnlyRTC;
      case ZegoAudioVideoResourceMode.cdnPlus:
        return ZegoStreamResourceMode.CDNPlus;
    }
  }
}

extension ZegoUIKitAudioRouteExtension on ZegoUIKitAudioRoute {
  static ZegoUIKitAudioRoute fromSDKValue(ZegoAudioRoute value) {
    switch (value) {
      case ZegoAudioRoute.Speaker:
        return ZegoUIKitAudioRoute.speaker;
      case ZegoAudioRoute.Headphone:
        return ZegoUIKitAudioRoute.headphone;
      case ZegoAudioRoute.Bluetooth:
        return ZegoUIKitAudioRoute.bluetooth;
      case ZegoAudioRoute.Receiver:
        return ZegoUIKitAudioRoute.receiver;
      case ZegoAudioRoute.ExternalUSB:
        return ZegoUIKitAudioRoute.externalUSB;
      case ZegoAudioRoute.AirPlay:
        return ZegoUIKitAudioRoute.airPlay;
    }
  }

  ZegoAudioRoute get toSDKValue {
    switch (this) {
      case ZegoUIKitAudioRoute.speaker:
        return ZegoAudioRoute.Speaker;
      case ZegoUIKitAudioRoute.headphone:
        return ZegoAudioRoute.Headphone;
      case ZegoUIKitAudioRoute.bluetooth:
        return ZegoAudioRoute.Bluetooth;
      case ZegoUIKitAudioRoute.receiver:
        return ZegoAudioRoute.Receiver;
      case ZegoUIKitAudioRoute.externalUSB:
        return ZegoAudioRoute.ExternalUSB;
      case ZegoUIKitAudioRoute.airPlay:
        return ZegoAudioRoute.AirPlay;
    }
  }
}

extension ZegoUIKitNetworkStateExtension on ZegoUIKitNetworkState {
  static ZegoUIKitNetworkState fromZego(ZegoNetworkMode networkMode) {
    ZegoUIKitNetworkState uiKitNetworkState = ZegoUIKitNetworkState.unknown;
    switch (networkMode) {
      case ZegoNetworkMode.Offline:
      case ZegoNetworkMode.Unknown:
        uiKitNetworkState = ZegoUIKitNetworkState.offline;
        break;
      case ZegoNetworkMode.Ethernet:
      case ZegoNetworkMode.WiFi:
      case ZegoNetworkMode.Mode2G:
      case ZegoNetworkMode.Mode3G:
      case ZegoNetworkMode.Mode4G:
      case ZegoNetworkMode.Mode5G:
        uiKitNetworkState = ZegoUIKitNetworkState.online;
        break;
    }

    return uiKitNetworkState;
  }
}
