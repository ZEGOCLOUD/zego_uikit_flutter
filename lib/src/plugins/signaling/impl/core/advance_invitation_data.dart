// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

// Project imports:
import 'package:zego_uikit/src/plugins/signaling/impl/core/advance_invitation_protocol.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/core/core.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/core/defines.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/service/reporter.dart';
import 'package:zego_uikit/src/services/services.dart';

extension AdvanceInvitationStateExtension on AdvanceInvitationState {
  static AdvanceInvitationState fromSignalingPluginInvitationUserState(
      ZegoSignalingPluginInvitationUserState state) {
    switch (state) {
      case ZegoSignalingPluginInvitationUserState.unknown:
        return AdvanceInvitationState.error;
      case ZegoSignalingPluginInvitationUserState.inviting:
      case ZegoSignalingPluginInvitationUserState.received:
      case ZegoSignalingPluginInvitationUserState.notYetReceived:
        return AdvanceInvitationState.waiting;
      case ZegoSignalingPluginInvitationUserState.accepted:
        return AdvanceInvitationState.accepted;
      case ZegoSignalingPluginInvitationUserState.rejected:
        return AdvanceInvitationState.rejected;
      case ZegoSignalingPluginInvitationUserState.cancelled:
      case ZegoSignalingPluginInvitationUserState.beCanceled:
        return AdvanceInvitationState.cancelled;
      case ZegoSignalingPluginInvitationUserState.timeout:
      case ZegoSignalingPluginInvitationUserState.quited:
      case ZegoSignalingPluginInvitationUserState.offline:
      case ZegoSignalingPluginInvitationUserState.ended:
        return AdvanceInvitationState.idle;
    }
  }
}

/// @nodoc
class AdvanceInvitationData {
  AdvanceInvitationData({
    required this.id,
    required this.initiator,
    required this.invitees,
    required this.type,
    required this.data,
    required this.resourceID,
  });

  String id; // invitation ID
  /// a->b, b->c;
  /// in c event, a is initiator, b is inviter
  AdvanceInvitationUser initiator;
  List<AdvanceInvitationUser> invitees;

  /// invitation type use by prebuilt
  //
  // call
  // ZegoCallInvitationType.voiceCall: 0,
  // ZegoCallInvitationType.videoCall: 1,
  //
  // live streaming
  // ZegoLiveStreamingInvitationType.requestCoHost: 2,
  // ZegoLiveStreamingInvitationType.inviteToJoinCoHost: 3,
  // ZegoLiveStreamingInvitationType.removeFromCoHost: 4,
  // // ZegoLiveStreamingInvitationType.crossRoomPKBattleRequest: 5,
  // ZegoLiveStreamingInvitationType.crossRoomPKBattleRequestV2: 6,
  int type;

  String data;
  String resourceID;

  @override
  String toString() {
    return 'AdvanceInvitationData:{'
        'id:$id, '
        'type:$type, '
        'data:$data, '
        'resourceID:$resourceID, '
        'initiator:$initiator, '
        'invitees:${invitees.map((e) => e.toString())}, '
        '}';
  }
}

/// @nodoc
mixin ZegoSignalingPluginCoreAdvanceInvitationData {
  // ------- events ------
  StreamController<ZegoSignalingPluginInvitationUserStateChangedEvent>?
      streamCtrlAdvanceInvitationUserStateChanged;
  StreamController<Map<String, dynamic>>? streamCtrlAdvanceInvitationReceived;
  StreamController<Map<String, dynamic>>? streamCtrlAdvanceInvitationTimeout;
  StreamController<Map<String, dynamic>>? streamCtrlAdvanceInvitationCanceled;
  StreamController<Map<String, dynamic>>? streamCtrlAdvanceInvitationEnded;

  Map<InvitationID, AdvanceInvitationData> advanceInvitationMap = {};

  void initAdvanceInvitationData() {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    streamCtrlAdvanceInvitationUserStateChanged ??= StreamController<
        ZegoSignalingPluginInvitationUserStateChangedEvent>.broadcast();
    streamCtrlAdvanceInvitationReceived ??=
        StreamController<Map<String, dynamic>>.broadcast();
    streamCtrlAdvanceInvitationTimeout ??=
        StreamController<Map<String, dynamic>>.broadcast();
    streamCtrlAdvanceInvitationCanceled ??=
        StreamController<Map<String, dynamic>>.broadcast();
    streamCtrlAdvanceInvitationEnded ??=
        StreamController<Map<String, dynamic>>.broadcast();
  }

  void uninitAdvanceInvitationData() {
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    advanceInvitationMap.clear();

    streamCtrlAdvanceInvitationUserStateChanged?.close();
    streamCtrlAdvanceInvitationUserStateChanged = null;

    streamCtrlAdvanceInvitationReceived?.close();
    streamCtrlAdvanceInvitationReceived = null;

    streamCtrlAdvanceInvitationTimeout?.close();
    streamCtrlAdvanceInvitationTimeout = null;

    streamCtrlAdvanceInvitationCanceled?.close();
    streamCtrlAdvanceInvitationCanceled = null;

    streamCtrlAdvanceInvitationEnded?.close();
    streamCtrlAdvanceInvitationEnded = null;
  }

  String? get _loginUser =>
      ZegoSignalingPluginCore.shared.coreData.currentUserID;

  void addAdvanceInvitationData(AdvanceInvitationData invitationData) {
    ZegoLoggerService.logInfo(
      'add invitation data $invitationData',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );
    advanceInvitationMap[invitationData.id] = invitationData;
  }

  void appendAdvanceInvitationData(AdvanceInvitationData invitationData) {
    if (advanceInvitationMap.containsKey(invitationData.id)) {
      advanceInvitationMap[invitationData.id]!
          .invitees
          .addAll(invitationData.invitees);

      ZegoLoggerService.logInfo(
        'append invitation data $invitationData,'
        'now ${invitationData.id}\'s invitees is ${advanceInvitationMap[invitationData.id]!.invitees}',
        tag: 'uikit-plugin-signaling',
        subTag: 'advance invitation data',
      );
    } else {
      addAdvanceInvitationData(invitationData);
    }
  }

  AdvanceInvitationData? removeAdvanceInvitationData(String invitationID) {
    final data = advanceInvitationMap.remove(invitationID);

    ZegoLoggerService.logInfo(
      'remove invitation data, '
      'invitationID: $invitationID, '
      'containsKey: ${advanceInvitationMap.containsKey(invitationID)}, '
      'map:$advanceInvitationMap, ',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    return data;
  }

  AdvanceInvitationUser? getAdvanceInvitee(String invitationID, String userID) {
    for (final invitee in advanceInvitationMap[invitationID]?.invitees ??
        <AdvanceInvitationUser>[]) {
      if (invitee.userID == userID) {
        return invitee;
      }
    }

    return null;
  }

  /// a->b, b->c;
  /// in c event, a is initiator, b is inviter
  AdvanceInvitationUser? getAdvanceInitiator(String invitationID) {
    return advanceInvitationMap[invitationID]?.initiator;
  }

  List<AdvanceInvitationUser> getAdvanceInvitees(String invitationID) {
    return List.from(
      advanceInvitationMap[invitationID]?.invitees ?? <AdvanceInvitationUser>[],
    );
  }

  bool isUserInAdvanceInvitationNow(String userID) {
    var isInInvitation = false;
    var find = false;
    advanceInvitationMap.forEach((id, data) {
      if (find) {
        return;
      }

      for (var invitee in data.invitees) {
        if (invitee.userID == userID &&
            (AdvanceInvitationState.waiting == invitee.state ||
                AdvanceInvitationState.accepted == invitee.state)) {
          isInInvitation = true;
          find = true;
          break;
        }
      }
    });

    return isInInvitation;
  }

  String queryAdvanceResourceIDByInvitationID(String invitationID) {
    for (final invitationData in advanceInvitationMap.values) {
      if (invitationData.id == invitationID) {
        return invitationData.resourceID;
      }
    }

    return '';
  }

  /// a->b, b->c;
  /// in c event, a is initiator, b is inviter
  String queryAdvanceInvitationIDByInitiatorID(String initiatorID) {
    for (final invitationData in advanceInvitationMap.values) {
      if (invitationData.initiator.userID == initiatorID) {
        return invitationData.id;
      }
    }

    return '';
  }

  void clearAdvanceInvitationsIfDone() {
    if (advanceInvitationMap.keys.isEmpty) {
      return;
    }

    ZegoLoggerService.logInfo(
      'clear advance invitation map if done, '
      'current map:$advanceInvitationMap',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    advanceInvitationMap.forEach((id, data) {
      data.invitees.removeWhere((user) {
        return AdvanceInvitationState.idle == user.state ||
            AdvanceInvitationState.rejected == user.state ||
            AdvanceInvitationState.cancelled == user.state;
      });
    });

    ZegoLoggerService.logInfo(
      'remove not connecting\'s invitee:$advanceInvitationMap',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    final keys = List.from(advanceInvitationMap.keys);
    for (var invitationID in keys) {
      removeIfAllAdvanceInviteesDone(invitationID);
    }
  }

  void timerClearAdvanceInvitationsIfDone() {
    Future.delayed(const Duration(seconds: 3), () {
      clearAdvanceInvitationsIfDone();
    });
  }

  AdvanceInvitationData? removeIfAllAdvanceInviteesDone(String invitationID) {
    var isDone = true;
    final invitees = advanceInvitationMap[invitationID]?.invitees ??
        <AdvanceInvitationUser>[];
    for (final invitee in invitees) {
      if (invitee.state == AdvanceInvitationState.waiting ||
          invitee.state == AdvanceInvitationState.accepted) {
        /// In a multi-party call, if the call is accepted, the call will still be connected
        isDone = false;
        break;
      }
    }

    if (isDone) {
      ZegoLoggerService.logInfo(
        'all done， invitee:${invitees.map((e) => '${e.userID}:${e.state},')}, remove $invitationID',
        tag: 'uikit-plugin-signaling',
        subTag: 'advance invitation data',
      );

      return removeAdvanceInvitationData(invitationID);
    }
    return advanceInvitationMap[invitationID];
  }

  void clearAdvanceInvitationData() {
    ZegoLoggerService.logInfo(
      'clear invitation data',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    advanceInvitationMap = {};
  }

  String advanceInvitationToString() {
    return 'advanceInvitationMap:$advanceInvitationMap';
  }

  /// invite
  Future<ZegoSignalingPluginSendInvitationResult> advanceInvite({
    required int type,
    required List<String> invitees,
    required int timeout,
    required String kitData,
    String extendedData = '',
    ZegoSignalingPluginPushConfig? pushConfig,
  }) async {
    ZegoLoggerService.logInfo(
      'invite, '
      'invitees:$invitees, '
      'type:$type, '
      'invitees:$invitees, '
      'timeout:$timeout, '
      'kitData:$kitData, '
      'extendedData:$extendedData, '
      'pushConfig:$pushConfig, ',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    /// delay clear
    clearAdvanceInvitationsIfDone();

    return ZegoPluginAdapter()
        .signalingPlugin!
        .sendInvitation(
          invitees: invitees,
          timeout: timeout,
          isAdvancedMode: true,
          extendedData: extendedData,
          pushConfig: pushConfig,
        )
        .then((result) {
      if (result.error == null) {
        ZegoLoggerService.logInfo(
          'send invitation done, invitationID:${result.invitationID}',
          tag: 'uikit-plugin-signaling',
          subTag: 'advance invitation data',
        );

        final invitationData = AdvanceInvitationData(
          id: result.invitationID,
          initiator: AdvanceInvitationUser(
            userID: _loginUser!,
            state: AdvanceInvitationState.idle,
          ),
          invitees: invitees
              .map((inviteeID) => AdvanceInvitationUser(
                    userID: inviteeID,
                    state: AdvanceInvitationState.waiting,
                  ))
              .toList(),
          type: type,
          data: kitData,
          resourceID: pushConfig?.resourceID ?? '',
        );
        addAdvanceInvitationData(invitationData);

        if (result.errorInvitees.isNotEmpty) {
          var errorMessage = '';
          result.errorInvitees.forEach((id, reason) {
            errorMessage += '$id, reason:$reason;';
            ZegoLoggerService.logInfo(
              'invite error, $errorMessage',
              tag: 'uikit-plugin-signaling',
              subTag: 'advance invitation data',
            );
          });

          final errorUserIDs = result.errorInvitees.keys.toList();
          for (final invitee in invitationData.invitees) {
            if (errorUserIDs.contains(invitee.userID)) {
              invitee.state = AdvanceInvitationState.error;
            }
          }

          timerClearAdvanceInvitationsIfDone();

          return ZegoSignalingPluginSendInvitationResult(
            invitationID: result.invitationID,
            errorInvitees: result.errorInvitees,
          );
        } else {
          ZegoLoggerService.logInfo(
            'invite success, invitationID:${result.invitationID}',
            tag: 'uikit-plugin-signaling',
            subTag: 'advance invitation data',
          );

          return result;
        }
      } else {
        ZegoLoggerService.logError(
          'send invitation failed, error: ${result.error}',
          tag: 'uikit-plugin-signaling',
          subTag: 'advance invitation data',
        );
      }
      return result;
    });
  }

  Future<ZegoSignalingPluginSendInvitationResult> advanceAddInvite({
    required String invitationID,
    required int type,
    required List<String> invitees,
    required String extendedData,
    ZegoSignalingPluginPushConfig? pushConfig,
  }) async {
    ZegoLoggerService.logInfo(
      'add, '
      'invitationID:$invitationID, '
      'type:$type, '
      'invitees:$invitees, '
      'extendedData:$extendedData, '
      'pushConfig:$pushConfig, ',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    /// delay clear
    clearAdvanceInvitationsIfDone();

    return ZegoPluginAdapter()
        .signalingPlugin!
        .addInvitation(
          invitationID: invitationID,
          invitees: invitees,
          pushConfig: pushConfig,
        )
        .then((result) {
      if (result.error == null) {
        ZegoLoggerService.logInfo(
          'add invitation done, invitationID:${result.invitationID}',
          tag: 'uikit-plugin-signaling',
          subTag: 'advance invitation data',
        );

        final invitationData = AdvanceInvitationData(
          id: result.invitationID,
          initiator: AdvanceInvitationUser(
            userID: _loginUser!,
            state: AdvanceInvitationState.idle,
          ),
          invitees: invitees
              .map((inviteeID) => AdvanceInvitationUser(
                    userID: inviteeID,
                    state: AdvanceInvitationState.waiting,
                  ))
              .toList(),
          type: type,
          data: extendedData,
          resourceID: pushConfig?.resourceID ?? '',
        );
        appendAdvanceInvitationData(invitationData);

        if (result.errorInvitees.isNotEmpty) {
          var errorMessage = '';
          result.errorInvitees.forEach((id, reason) {
            errorMessage += '$id, reason:$reason;';
            ZegoLoggerService.logInfo(
              'add invite error, $errorMessage',
              tag: 'uikit-plugin-signaling',
              subTag: 'advance invitation data',
            );
          });

          final errorUserIDs = result.errorInvitees.keys.toList();
          for (final invitee in invitationData.invitees) {
            if (errorUserIDs.contains(invitee.userID)) {
              invitee.state = AdvanceInvitationState.error;
            }
          }

          timerClearAdvanceInvitationsIfDone();
          return ZegoSignalingPluginSendInvitationResult(
            invitationID: result.invitationID,
            errorInvitees: result.errorInvitees,
          );
        } else {
          ZegoLoggerService.logInfo(
            'add invite success, invitationID:${result.invitationID}',
            tag: 'uikit-plugin-signaling',
            subTag: 'advance invitation data',
          );

          return result;
        }
      } else {
        ZegoLoggerService.logError(
          'add invitation failed, error: ${result.error}',
          tag: 'uikit-plugin-signaling',
          subTag: 'advance invitation data',
        );
      }
      return result;
    });
  }

  /// join
  Future<ZegoSignalingPluginJoinInvitationResult> advanceJoinInvite({
    required String invitationID,
    String extendedData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'join, '
      'invitationID:$invitationID, '
      'extendedData:$extendedData, ',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    return ZegoPluginAdapter().signalingPlugin!.joinInvitation(
          invitationID: invitationID,
          extendedData: extendedData,
        );
  }

  /// cancel
  Future<ZegoSignalingPluginCancelInvitationResult> advanceCancel(
    List<String> invitees,
    String invitationID,
    String extendedData,
    ZegoSignalingPluginIncomingInvitationCancelPushConfig? pushConfig,
  ) async {
    ZegoLoggerService.logInfo(
      'cancel, '
      'invitees:$invitees, '
      'invitationID:$invitationID, '
      'extendedData:$extendedData, '
      'pushConfig:$pushConfig, ',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    return ZegoPluginAdapter()
        .signalingPlugin!
        .cancelInvitation(
          invitationID: invitationID,
          invitees: invitees,
          extendedData: extendedData,
          pushConfig: pushConfig,
        )
        .then((result) {
      if (result.error == null) {
        for (final invitee in advanceInvitationMap[invitationID]?.invitees ??
            <AdvanceInvitationUser>[]) {
          final isCancelUser = invitees.contains(invitee.userID);
          final isCancelError = result.errorInvitees.contains(invitee.userID);
          if (isCancelUser) {
            invitee.state = isCancelError
                ? AdvanceInvitationState.error
                : AdvanceInvitationState.cancelled;
          }
        }

        timerClearAdvanceInvitationsIfDone();

        if (result.errorInvitees.isNotEmpty) {
          for (final element in result.errorInvitees) {
            ZegoLoggerService.logError(
              'cancel invitation error, invitationID:$invitationID, invitee id:$element',
              tag: 'uikit-plugin-signaling',
              subTag: 'advance invitation data',
            );
          }
        } else {
          ZegoLoggerService.logInfo(
            'cancel invitation done, invitationID:$invitationID',
            tag: 'uikit-plugin-signaling',
            subTag: 'advance invitation data',
          );
        }
      } else {
        ZegoLoggerService.logError(
          'cancel invitation failed, error:${result.error}',
          tag: 'uikit-plugin-signaling',
          subTag: 'advance invitation data',
        );
      }
      return result;
    });
  }

  /// accept
  Future<ZegoSignalingPluginResponseInvitationResult> advanceAccept(
    String invitationID,
    String extendedData,
  ) async {
    ZegoLoggerService.logInfo(
      'accept, '
      'invitationID:$invitationID, '
      'extendedData:$extendedData, ',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    return ZegoPluginAdapter()
        .signalingPlugin!
        .acceptInvitation(
          invitationID: invitationID,
          extendedData: extendedData,
        )
        .then((result) {
      if (result.error == null) {
        ZegoLoggerService.logInfo(
          'accept invitation done, result: $result',
          tag: 'uikit-plugin-signaling',
          subTag: 'advance invitation data',
        );
      } else {
        ZegoLoggerService.logError(
          'accept invitation failed, result: $result',
          tag: 'uikit-plugin-signaling',
          subTag: 'advance invitation data',
        );
      }
      return result;
    });
  }

  /// reject
  Future<ZegoSignalingPluginResponseInvitationResult> advanceReject(
    String invitationID,
    String extendedData,
  ) async {
    ZegoLoggerService.logInfo(
      'refuse, '
      'invitationID:$invitationID, '
      'extendedData:$extendedData, ',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    return ZegoPluginAdapter()
        .signalingPlugin!
        .refuseInvitation(
          invitationID: invitationID,
          extendedData: extendedData,
        )
        .then((result) {
      if (result.error == null) {
        ZegoLoggerService.logInfo(
          'refuse invitation done, result: $result',
          tag: 'uikit-plugin-signaling',
          subTag: 'advance invitation data',
        );
      } else {
        ZegoLoggerService.logError(
          'refuse invitation failed, result: $result',
          tag: 'uikit-plugin-signaling',
          subTag: 'advance invitation data',
        );
      }
      return result;
    });
  }

  /// end
  Future<ZegoSignalingPluginEndInvitationResult> advanceEnd(
    String invitationID,
    String extendedData,
    ZegoSignalingPluginPushConfig? pushConfig,
  ) async {
    ZegoLoggerService.logInfo(
      'end, '
      'invitationID:$invitationID, '
      'extendedData:$extendedData, '
      'pushConfig:$pushConfig, ',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    return ZegoPluginAdapter()
        .signalingPlugin!
        .endInvitation(
          invitationID: invitationID,
          extendedData: extendedData,
          pushConfig: pushConfig,
        )
        .then((result) {
      if (result.error == null) {
        ZegoLoggerService.logInfo(
          'end invitation done, result: $result',
          tag: 'uikit-plugin-signaling',
          subTag: 'advance invitation data',
        );
      } else {
        ZegoLoggerService.logError(
          'end invitation failed, result: $result',
          tag: 'uikit-plugin-signaling',
          subTag: 'advance invitation data',
        );
      }
      return result;
    });
  }

  /// quit
  Future<ZegoSignalingPluginQuitInvitationResult> advanceQuit(
    String invitationID,
    String extendedData,
    ZegoSignalingPluginPushConfig? pushConfig,
  ) async {
    ZegoLoggerService.logInfo(
      'quit, '
      'invitationID:$invitationID, '
      'extendedData:$extendedData, '
      'pushConfig:$pushConfig, ',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    return ZegoPluginAdapter()
        .signalingPlugin!
        .quitInvitation(
          invitationID: invitationID,
          extendedData: extendedData,
          pushConfig: pushConfig,
        )
        .then((result) {
      if (result.error == null) {
        ZegoLoggerService.logInfo(
          'quit invitation done, result: $result',
          tag: 'uikit-plugin-signaling',
          subTag: 'advance invitation data',
        );

        if (ZegoUIKit().getLocalUser().id ==
            getAdvanceInitiator(invitationID)?.userID) {
          /// clear if quit local invitation
          ZegoLoggerService.logInfo(
            'clear local invitation data',
            tag: 'uikit-plugin-signaling',
            subTag: 'advance invitation data',
          );
          getAdvanceInvitees(invitationID).forEach((invitee) {
            invitee.state = AdvanceInvitationState.idle;
          });
          timerClearAdvanceInvitationsIfDone();
        }
      } else {
        ZegoLoggerService.logError(
          'quit invitation failed, result: $result',
          tag: 'uikit-plugin-signaling',
          subTag: 'advance invitation data',
        );
      }
      return result;
    });
  }

  void onAdvanceInvitationUserStateChanged(
    ZegoSignalingPluginInvitationUserStateChangedEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'onAdvanceInvitationUserStateChanged, $event',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    event.type = advanceInvitationMap[event.invitationID]?.type ?? -1;

    for (var callUser in event.callUserList) {
      /// update initiator
      if (callUser.userID ==
          advanceInvitationMap[event.invitationID]?.initiator.userID) {
        advanceInvitationMap[event.invitationID]?.initiator.state =
            AdvanceInvitationStateExtension
                .fromSignalingPluginInvitationUserState(
          callUser.state,
        );
        advanceInvitationMap[event.invitationID]?.initiator.extendedData =
            callUser.extendedData;

        continue;
      }

      /// update invitees
      var user = getAdvanceInvitee(event.invitationID, callUser.userID);
      if (null == user) {
        advanceInvitationMap[event.invitationID]?.invitees.add(
              AdvanceInvitationUser(
                userID: callUser.userID,
                state: AdvanceInvitationStateExtension
                    .fromSignalingPluginInvitationUserState(callUser.state),
                extendedData: callUser.extendedData,
              ),
            );
        ZegoLoggerService.logInfo(
          'add user info, ${callUser.userID}',
          tag: 'uikit-plugin-signaling',
          subTag: 'advance invitation data',
        );
      } else {
        user.state = AdvanceInvitationStateExtension
            .fromSignalingPluginInvitationUserState(
          callUser.state,
        );
        user.extendedData = callUser.extendedData;

        ZegoLoggerService.logInfo(
          'update user info, $user',
          tag: 'uikit-plugin-signaling',
          subTag: 'advance invitation data',
        );
      }
    }
    ZegoLoggerService.logInfo(
      'invitation map: $advanceInvitationMap',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    timerClearAdvanceInvitationsIfDone();

    streamCtrlAdvanceInvitationUserStateChanged?.add(event);
  }

  /// on incoming invitation received
  void onIncomingAdvanceInvitationReceived(
    ZegoSignalingPluginIncomingInvitationReceivedEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'onIncomingInvitationReceived, event:$event',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    var requestData = ZegoUIKitAdvanceInvitationSendProtocol.empty();
    try {
      final extendedDataMap =
          jsonDecode(event.extendedData) as Map<String, dynamic>;

      requestData =
          ZegoUIKitAdvanceInvitationSendProtocol.fromJson(extendedDataMap);
    } catch (e) {
      ZegoLoggerService.logInfo(
        'onIncomingInvitationReceived, event extended data not a '
        'AdvanceInvitationRequestData:${event.extendedData}',
        tag: 'uikit-plugin-signaling',
        subTag: 'advance invitation data',
      );
    }

    /// who first invite
    /// a->b, b->c;
    /// in c event, a is initiator, b is inviter
    ZegoUIKitUser initiator = requestData.inviter;
    var invitationInitiator = AdvanceInvitationUser(
      userID: initiator.id,
      state: AdvanceInvitationState.accepted,
    );

    /// inviter maybe the initiator
    ZegoUIKitUser currentInviter = initiator;
    if (event.inviterID != initiator.id) {
      /// or other inviter(second and later inviter)
      currentInviter = ZegoUIKitUser(
        id: event.inviterID,
        name: '',
        isAnotherRoomUser: false,
      );

      invitationInitiator.extendedData = requestData.customData;
    }

    final invitees = <AdvanceInvitationUser>[];
    for (final inviteeID in requestData.invitees) {
      final user = AdvanceInvitationUser(
        userID: inviteeID,
        state: AdvanceInvitationState.waiting,
      );
      invitees.add(user);
    }

    /// cache session users in existed calling
    for (var userInfo in event.callUserList) {
      final queryIndex =
          invitees.indexWhere((user) => user.userID == userInfo.userID);
      if (-1 == queryIndex) {
        if (invitationInitiator.userID != userInfo.userID) {
          /// insert not in invitee, but in call-list, whom calling before
          invitees.add(
            AdvanceInvitationUser(
              userID: userInfo.userID,
              state: AdvanceInvitationStateExtension
                  .fromSignalingPluginInvitationUserState(userInfo.state),
              extendedData: userInfo.extendedData,
            ),
          );
        }
      } else {
        /// exist, update
        invitees[queryIndex].state = AdvanceInvitationStateExtension
            .fromSignalingPluginInvitationUserState(
          userInfo.state,
        );
        try {
          final acceptData = ZegoUIKitAdvanceInvitationAcceptProtocol.fromJson(
              jsonDecode(userInfo.extendedData));
          if (acceptData.customData.isNotEmpty) {
            invitees[queryIndex].extendedData = acceptData.customData;
          }
        } catch (e) {
          /// do nothing
        }
      }
    }

    addAdvanceInvitationData(
      AdvanceInvitationData(
        id: event.invitationID,
        initiator: invitationInitiator,
        invitees: invitees,
        type: requestData.type,
        data: requestData.customData,
        resourceID: '', //todo notificationConfig?.resourceID ?? '',
      ),
    );

    /// not local user, which in calling before
    var sessionCallUserList = event.callUserList.where((user) {
      return user.userID != ZegoUIKit().getLocalUser().id;
    }).toList();
    if (event.inviterID == initiator.id) {
      /// not inviter, which in calling before
      sessionCallUserList
          .removeWhere((user) => user.userID == currentInviter.id);
    }

    ZegoUIKit().reporter().report(
      event: ZegoUIKitSignalingReporter.eventCallInviteReceived,
      params: {
        ZegoUIKitSignalingReporter.eventKeyInvitationID: event.invitationID,
        ZegoUIKitSignalingReporter.eventKeyInviter: event.inviterID,
        ZegoUIKitSignalingReporter.eventKeyExtendedData: event.extendedData,
        ZegoUIKitReporter.eventKeyAppState: ZegoUIKitReporter.currentAppState(),
      },
    );

    streamCtrlAdvanceInvitationReceived?.add({
      'invitation_id': event.invitationID,
      'data': requestData.customData,
      'type': requestData.type,
      'inviter': currentInviter,
      'session_invitees': sessionCallUserList
          .map((e) => {
                'invitee_id': e.userID,
                'state': e.state,
                'data': e.extendedData,
              })
          .toList(),
      'create_timestamp_second': event.createTime ~/ 1000,
      'timeout_second': event.timeoutSecond,
    });
  }

  void onIncomingAdvanceInvitationCancelled(
    ZegoSignalingPluginIncomingInvitationCancelledEvent event,
  ) {
    //  inviter extendedData
    ZegoLoggerService.logInfo(
      'onIncomingInvitationCancelled',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    final invitationData = removeAdvanceInvitationData(event.invitationID);
    ZegoLoggerService.logInfo(
      'onIncomingInvitationCancelled, '
      'event:$event, '
      'invitationData:$invitationData',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    streamCtrlAdvanceInvitationCanceled?.add({
      'invitation_id': event.invitationID,
      'data': event.extendedData,
      'type': invitationData?.type ?? 0,
      'inviter': ZegoUIKitUser(
        id: event.inviterID,
        name: '',
        isAnotherRoomUser: false,
      ),
    });
  }

  void onOutgoingAdvanceInvitationEnded(
    ZegoSignalingPluginOutgoingInvitationEndedEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'onOutgoingAdvanceInvitationEnded',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    final invitationData = advanceInvitationMap[event.invitationID];
    ZegoLoggerService.logInfo(
      'onOutgoingAdvanceInvitationEnded, '
      'event:$event, '
      'invitationData:$invitationData',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    getAdvanceInvitees(event.invitationID).forEach((invitee) {
      invitee.state = AdvanceInvitationState.idle;
    });
    timerClearAdvanceInvitationsIfDone();

    streamCtrlAdvanceInvitationEnded?.add({
      'type': invitationData?.type ?? 0,
      'invitation_id': event.invitationID,
      'inviter': ZegoUIKitUser(
        id: event.callerID,
        name: '',
        isAnotherRoomUser: false,
      ),
      'end_time': event.endTime,
      'data': event.extendedData,
    });
  }

  /// on call invitation timeout
  void onIncomingAdvanceInvitationTimeout(
    ZegoSignalingPluginIncomingInvitationTimeoutEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'onIncomingInvitationTimeout, '
      'event:$event, ',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    final invitationData = removeAdvanceInvitationData(event.invitationID);
    ZegoLoggerService.logInfo(
      'onIncomingInvitationTimeout, '
      'event:$event, '
      'invitationData:$invitationData',
      tag: 'uikit-plugin-signaling',
      subTag: 'advance invitation data',
    );

    streamCtrlAdvanceInvitationTimeout?.add({
      'invitation_id': event.invitationID,
      'data': invitationData?.data ?? '',
      'type': invitationData?.type ?? 0,
      'inviter': ZegoUIKitUser(
        id: invitationData?.initiator.userID ?? '',
        name: '',
        isAnotherRoomUser: false,
      ),
    });
  }
}
