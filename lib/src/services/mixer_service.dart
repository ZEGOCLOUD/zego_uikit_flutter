part of 'uikit_service.dart';

mixin ZegoMixerService {
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

  Future<ZegoMixerStartResult> startMixerTask(ZegoMixerTask task) async {
    return ZegoUIKitCore.shared.startMixerTask(task);
  }

  Future<ZegoMixerStopResult> stopMixerTask(ZegoMixerTask task) async {
    return ZegoUIKitCore.shared.stopMixerTask(task);
  }

  /// *[userSoundIDs], a map of user id to sound id
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

  Future<void> stopPlayMixAudioVideo(
    String mixerStreamID, {
    required String targetRoomID,
  }) async {
    return ZegoUIKitCore.shared.stopPlayMixAudioVideo(
      mixerStreamID,
      targetRoomID: targetRoomID,
    );
  }

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

  /// get mixed sound level notifier
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

  /// get sound level notifier
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

  ZegoUIKitUser getUserInMixerStream(
    String userID, {
    required String targetRoomID,
  }) {
    return ZegoUIKitCore.shared.coreData.user
        .getUserInMixerStream(userID, targetRoomID: targetRoomID)
        .toZegoUikitUser();
  }

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

  /// get user list notifier
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
