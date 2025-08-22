part of 'uikit_service.dart';

mixin ZegoMixerService {
  Future<void> startPlayAnotherRoomAudioVideo(
    String roomID,
    String userID, {
    String userName = '',
    PlayerStateUpdateCallback? onPlayerStateUpdated,
  }) async {
    return ZegoUIKitCore.shared.startPlayAnotherRoomAudioVideo(
      roomID,
      userID,
      userName,
    );
  }

  Future<void> stopPlayAnotherRoomAudioVideo(String userID) async {
    return ZegoUIKitCore.shared.stopPlayAnotherRoomAudioVideo(userID);
  }

  Future<ZegoMixerStartResult> startMixerTask(ZegoMixerTask task) async {
    return ZegoUIKitCore.shared.startMixerTask(task);
  }

  Future<ZegoMixerStopResult> stopMixerTask(ZegoMixerTask task) async {
    return ZegoUIKitCore.shared.stopMixerTask(task);
  }

  /// *[userSoundIDs], a map of user id to sound id
  Future<void> startPlayMixAudioVideo(
    String mixerID,
    List<ZegoUIKitUser> users,
    Map<String, int> userSoundIDs, {
    PlayerStateUpdateCallback? onPlayerStateUpdated,
  }) async {
    return ZegoUIKitCore.shared.startPlayMixAudioVideo(
      mixerID,
      users.map((e) => ZegoUIKitCoreUser(e.id, e.name)).toList(),
      userSoundIDs,
    );
  }

  Future<void> stopPlayMixAudioVideo(String mixerID) async {
    return ZegoUIKitCore.shared.stopPlayMixAudioVideo(mixerID);
  }

  ValueNotifier<Widget?> getMixAudioVideoViewNotifier(String mixerID) {
    return ZegoUIKitCore.shared.coreData.mixerStreamDic[mixerID]?.view ??
        ValueNotifier(null);
  }

  ValueNotifier<bool> getMixAudioVideoCameraStateNotifier(
    String mixerID,
    String userID,
  ) {
    final targetUser = ZegoUIKitCore
        .shared.coreData.mixerStreamDic[mixerID]?.usersNotifier.value
        .firstWhere((user) => user.id == userID,
            orElse: ZegoUIKitCoreUser.empty);
    return targetUser?.camera ?? ValueNotifier(false);
  }

  ValueNotifier<bool> getMixAudioVideoMicrophoneStateNotifier(
    String mixerID,
    String userID,
  ) {
    return ZegoUIKitCore
            .shared.coreData.mixerStreamDic[mixerID]?.usersNotifier.value
            .firstWhere((user) => user.id == userID,
                orElse: ZegoUIKitCoreUser.empty)
            .microphone ??
        ValueNotifier(false);
  }

  ValueNotifier<bool> getMixAudioVideoLoadedNotifier(String mixerID) {
    return ZegoUIKitCore.shared.coreData.mixerStreamDic[mixerID]?.loaded ??
        ValueNotifier(false);
  }

  /// get mixed sound level notifier
  Stream<Map<int, double>> getMixedSoundLevelsStream() {
    final mixStreams = ZegoUIKitCore.shared.coreData.mixerStreamDic.values;
    if (mixStreams.isEmpty) {
      return const Stream.empty();
    }
    return mixStreams.elementAt(0).soundLevels?.stream ?? const Stream.empty();
  }

  /// get sound level notifier
  Stream<double> getMixedSoundLevelStream(String userID) {
    return ZegoUIKitCore.shared.coreData
            .getUserInMixerStream(userID)
            .mainChannel
            .soundLevelStream
            ?.stream ??
        const Stream.empty();
  }

  ZegoUIKitUser getUserInMixerStream(String userID) {
    return ZegoUIKitCore.shared.coreData
        .getUserInMixerStream(userID)
        .toZegoUikitUser();
  }

  List<ZegoUIKitUser> getMixerStreamUsers(String mixerStreamID) {
    return ZegoUIKitCore
            .shared.coreData.mixerStreamDic[mixerStreamID]?.usersNotifier.value
            .map((e) => e.toZegoUikitUser())
            .toList() ??
        [];
  }

  /// get user list notifier
  Stream<List<ZegoUIKitUser>> getMixerUserListStream(String mixerStreamID) {
    return ZegoUIKitCore.shared.coreData.mixerStreamDic[mixerStreamID]
            ?.userListStreamCtrl?.stream
            .map((users) => users.map((e) => e.toZegoUikitUser()).toList()) ??
        const Stream.empty();
  }
}
