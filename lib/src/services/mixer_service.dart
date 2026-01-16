part of 'uikit_service.dart';

mixin ZegoMixerService {
  /// Start playing a user's audio & video stream from another room.
  ///
  /// [anotherRoomID] The ID of the remote room where the stream is published.
  /// [anotherUserID] The user ID in the remote room whose stream will be played.
  /// [streamType] The type of stream to play, main stream by default.
  /// [anotherUserName] The user name in the remote room, used for identification only.
  /// [targetRoomID] The local room ID in which the stream will be played.
  /// [playOnAnotherRoom] Whether to play as a stream from another room.
  /// [onPlayerStateUpdated] Callback for player state updates.
  Future<void> startPlayAnotherRoomAudioVideo(
    String anotherRoomID,
    String anotherUserID, {
    ZegoStreamType streamType = ZegoStreamType.main,
    String anotherUserName = '',
    required String targetRoomID,
    required bool playOnAnotherRoom,
    PlayerStateUpdateCallback? onPlayerStateUpdated,
  }) async {
    return ZegoUIKitCore.shared.startPlayingAnotherRoomStream(
      anotherRoomID,
      anotherUserID,
      anotherUserName,
      streamType: streamType,
      targetRoomID: targetRoomID,
      playOnAnotherRoom: playOnAnotherRoom,
    );
  }

  /// Stop playing a user's audio & video stream from another room.
  ///
  /// [userID] The user ID whose stream will be stopped.
  /// [targetRoomID] The local room ID where the stream is being played.
  /// [streamType] The type of stream to stop, main stream by default.
  Future<void> stopPlayAnotherRoomAudioVideo(
    String userID, {
    required String targetRoomID,
    ZegoStreamType streamType = ZegoStreamType.main,
  }) async {
    return ZegoUIKitCore.shared.stopPlayingAnotherRoomStream(
      userID,
      targetRoomID: targetRoomID,
      streamType: streamType,
    );
  }

  /// Start a mixer task.
  ///
  /// [task] Mixer task configuration, including inputs, outputs and layout.
  Future<ZegoMixerStartResult> startMixerTask(ZegoMixerTask task) async {
    return ZegoUIKitCore.shared.startMixerTask(task);
  }

  /// Stop a mixer task.
  ///
  /// [task] Mixer task configuration to be stopped.
  Future<ZegoMixerStopResult> stopMixerTask(ZegoMixerTask task) async {
    return ZegoUIKitCore.shared.stopMixerTask(task);
  }

  /// Start playing a mixed audio & video stream.
  ///
  /// [mixerStreamID] The ID of the mixed stream to be played.
  /// [users] The user list that participates in this mixed stream.
  /// [userSoundIDs] Map of user ID to sound ID (sound channel ID).
  /// [targetRoomID] The room ID in which the mixed stream will be played.
  /// [onPlayerStateUpdated] Callback for player state updates.
  Future<void> startPlayMixAudioVideo(
    String mixerStreamID,
    List<ZegoUIKitUser> users,
    Map<String, int> userSoundIDs, {
    required String targetRoomID,
    PlayerStateUpdateCallback? onPlayerStateUpdated,
  }) async {
    return ZegoUIKitCore.shared.startPlayMixAudioVideo(
      mixerStreamID,
      users
          .map((e) => ZegoUIKitCoreUser(e.id, e.name, targetRoomID, false))
          .toList(),
      userSoundIDs,
      targetRoomID: targetRoomID,
    );
  }

  /// Stop playing a mixed audio & video stream.
  ///
  /// [mixerStreamID] The ID of the mixed stream to stop.
  /// [targetRoomID] The room ID where the mixed stream is being played.
  Future<void> stopPlayMixAudioVideo(
    String mixerStreamID, {
    required String targetRoomID,
  }) async {
    return ZegoUIKitCore.shared.stopPlayMixAudioVideo(
      mixerStreamID,
      targetRoomID: targetRoomID,
    );
  }

  /// Get the view notifier for a mixed audio & video stream.
  ///
  /// [mixerID] The mixed stream ID.
  /// [targetRoomID] The room ID where the mixed stream exists.
  ValueNotifier<Widget?> getMixAudioVideoViewNotifier(
    String mixerID, {
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.stream.roomStreams
            .getRoom(targetRoomID)
            .mixerStreamDic[mixerID]
            ?.view ??
        ValueNotifier(null);
  }

  /// Get the camera state notifier of a specific user in a mixed stream.
  ///
  /// [mixerID] The mixed stream ID.
  /// [userID] The user ID whose camera state will be observed.
  /// [targetRoomID] The room ID where the mixed stream exists.
  ValueNotifier<bool> getMixAudioVideoCameraStateNotifier(
    String mixerID,
    String userID, {
    required String targetRoomID,
  }) {
    final targetUser = ZegoUIKitCore.shared.coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .mixerStreamDic[mixerID]
        ?.usersNotifier
        .value
        .firstWhere((user) => user.id == userID,
            orElse: ZegoUIKitCoreUser.empty);
    return targetUser?.camera ?? ValueNotifier(false);
  }

  /// Get the microphone state notifier of a specific user in a mixed stream.
  ///
  /// [mixerID] The mixed stream ID.
  /// [userID] The user ID whose microphone state will be observed.
  /// [targetRoomID] The room ID where the mixed stream exists.
  ValueNotifier<bool> getMixAudioVideoMicrophoneStateNotifier(
    String mixerID,
    String userID, {
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.stream.roomStreams
            .getRoom(targetRoomID)
            .mixerStreamDic[mixerID]
            ?.usersNotifier
            .value
            .firstWhere((user) => user.id == userID,
                orElse: ZegoUIKitCoreUser.empty)
            .microphone ??
        ValueNotifier(false);
  }

  /// Get the loading-complete state notifier for a mixed stream.
  ///
  /// [mixerID] The mixed stream ID.
  /// [targetRoomID] The room ID where the mixed stream exists.
  ValueNotifier<bool> getMixAudioVideoLoadedNotifier(
    String mixerID, {
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.stream.roomStreams
            .getRoom(targetRoomID)
            .mixerStreamDic[mixerID]
            ?.loaded ??
        ValueNotifier(false);
  }

  /// Get the mixed sound levels stream for the room.
  ///
  /// The result is a mapping from sound ID (sound channel ID) to volume level.
  /// [targetRoomID] The room ID where the mixed stream exists.
  Stream<Map<int, double>> getMixedSoundLevelsStream({
    required String targetRoomID,
  }) {
    final mixStreams = ZegoUIKitCore.shared.coreData.stream.roomStreams
        .getRoom(targetRoomID)
        .mixerStreamDic
        .values;
    if (mixStreams.isEmpty) {
      return const Stream.empty();
    }
    return mixStreams.elementAt(0).soundLevels?.stream ?? const Stream.empty();
  }

  /// Get the sound level stream of a specific user in a mixed stream.
  ///
  /// [userID] The user ID whose sound level will be observed.
  /// [targetRoomID] The room ID where the mixed stream exists.
  Stream<double> getMixedSoundLevelStream(
    String userID, {
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.user
            .getUserInMixerStream(userID, targetRoomID: targetRoomID)
            .mainChannel
            .soundLevelStream
            ?.stream ??
        const Stream.empty();
  }

  /// Get user info of a specific user in a mixed stream.
  ///
  /// [userID] The user ID to be queried.
  /// [targetRoomID] The room ID where the mixed stream exists.
  ZegoUIKitUser getUserInMixerStream(
    String userID, {
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.user
        .getUserInMixerStream(userID, targetRoomID: targetRoomID)
        .toZegoUikitUser();
  }

  /// Get the user list of a specific mixed stream.
  ///
  /// [mixerStreamID] The mixed stream ID.
  /// [targetRoomID] The room ID where the mixed stream exists.
  List<ZegoUIKitUser> getMixerStreamUsers(
    String mixerStreamID, {
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.stream.roomStreams
            .getRoom(targetRoomID)
            .mixerStreamDic[mixerStreamID]
            ?.usersNotifier
            .value
            .map((e) => e.toZegoUikitUser())
            .toList() ??
        [];
  }

  /// Get the user list stream of a specific mixed stream.
  ///
  /// [mixerStreamID] The mixed stream ID.
  /// [targetRoomID] The room ID where the mixed stream exists.
  Stream<List<ZegoUIKitUser>> getMixerUserListStream(
    String mixerStreamID, {
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.stream.roomStreams
            .getRoom(targetRoomID)
            .mixerStreamDic[mixerStreamID]
            ?.userListStreamCtrl
            ?.stream
            .map((users) => users.map((e) => e.toZegoUikitUser()).toList()) ??
        const Stream.empty();
  }
}
