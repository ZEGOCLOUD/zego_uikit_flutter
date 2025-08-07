// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

// Project imports:
import 'package:zego_uikit/src/plugins/signaling/impl/core/core.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/core/defines.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/service/reporter.dart';
import 'package:zego_uikit/src/services/services.dart';

/// @nodoc
class InvitationData {
  InvitationData({
    required this.id,
    required this.inviterID,
    required this.invitees,
    required this.type,
    required this.data,
    required this.resourceID,
  });

  String id; // invitation ID
  String inviterID;
  List<InvitationUser> invitees;

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
    return 'id:$id, type:$type, inviter id:$inviterID, '
        'invitees:${invitees.map((e) => e.toString())}, '
        'data:$data, resourceID:$resourceID';
  }
}

/// @nodoc
mixin ZegoSignalingPluginCoreInvitationData {
  // ------- events ------
  StreamController<ZegoSignalingPluginInvitationUserStateChangedEvent>?
      streamCtrlInvitationUserStateChanged;
  StreamController<Map<String, dynamic>>? streamCtrlInvitationReceived;
  StreamController<Map<String, dynamic>>? streamCtrlInvitationTimeout;
  StreamController<Map<String, dynamic>>? streamCtrlInvitationResponseTimeout;
  StreamController<Map<String, dynamic>>? streamCtrlInvitationAccepted;
  StreamController<Map<String, dynamic>>? streamCtrlInvitationRefused;
  StreamController<Map<String, dynamic>>? streamCtrlInvitationCanceled;
  StreamController<Map<String, dynamic>>? streamCtrlInvitationEnded;

  Map<InvitationID, InvitationData> invitationMap = {};

  void initInvitationData() {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'uikit-plugin-signaling',
      subTag: 'invitation data',
    );

    streamCtrlInvitationUserStateChanged ??= StreamController<
        ZegoSignalingPluginInvitationUserStateChangedEvent>.broadcast();
    streamCtrlInvitationReceived ??=
        StreamController<Map<String, dynamic>>.broadcast();
    streamCtrlInvitationTimeout ??=
        StreamController<Map<String, dynamic>>.broadcast();
    streamCtrlInvitationResponseTimeout ??=
        StreamController<Map<String, dynamic>>.broadcast();
    streamCtrlInvitationAccepted ??=
        StreamController<Map<String, dynamic>>.broadcast();
    streamCtrlInvitationRefused ??=
        StreamController<Map<String, dynamic>>.broadcast();
    streamCtrlInvitationCanceled ??=
        StreamController<Map<String, dynamic>>.broadcast();
    streamCtrlInvitationEnded ??=
        StreamController<Map<String, dynamic>>.broadcast();
  }

  void uninitInvitationData() {
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'uikit-plugin-signaling',
      subTag: 'invitation data',
    );

    invitationMap.clear();

    streamCtrlInvitationReceived?.close();
    streamCtrlInvitationReceived = null;

    streamCtrlInvitationTimeout?.close();
    streamCtrlInvitationTimeout = null;

    streamCtrlInvitationResponseTimeout?.close();
    streamCtrlInvitationResponseTimeout = null;

    streamCtrlInvitationAccepted?.close();
    streamCtrlInvitationAccepted = null;

    streamCtrlInvitationRefused?.close();
    streamCtrlInvitationRefused = null;

    streamCtrlInvitationCanceled?.close();
    streamCtrlInvitationCanceled = null;

    streamCtrlInvitationEnded?.close();
    streamCtrlInvitationEnded = null;
  }

  String? get _loginUser =>
      ZegoSignalingPluginCore.shared.coreData.currentUserID;

  void addInvitationData(InvitationData invitationData) {
    ZegoLoggerService.logInfo(
      'add invitation data $invitationData',
      tag: 'uikit-plugin-signaling',
      subTag: 'invitation data',
    );
    invitationMap[invitationData.id] = invitationData;
  }

  void appendInvitationData(InvitationData invitationData) {
    if (invitationMap.containsKey(invitationData.id)) {
      invitationMap[invitationData.id]!
          .invitees
          .addAll(invitationData.invitees);

      ZegoLoggerService.logInfo(
        'append invitation data $invitationData,'
        'now ${invitationData.id}\'s invitees is ${invitationMap[invitationData.id]!.invitees}',
        tag: 'uikit-plugin-signaling',
        subTag: 'invitation data',
      );
    } else {
      addInvitationData(invitationData);
    }
  }

  InvitationData? removeInvitationData(String invitationID) {
    ZegoLoggerService.logInfo(
      'remove invitation data, invitationID: $invitationID',
      tag: 'uikit-plugin-signaling',
      subTag: 'invitation data',
    );
    return invitationMap.remove(invitationID);
  }

  InvitationUser? getInvitee(String invitationID, String userID) {
    for (final invitee
        in invitationMap[invitationID]?.invitees ?? <InvitationUser>[]) {
      if (invitee.userID == userID) {
        return invitee;
      }
    }

    return null;
  }

  String queryResourceIDByInvitationID(String invitationID) {
    for (final invitationData in invitationMap.values) {
      if (invitationData.id == invitationID) {
        return invitationData.resourceID;
      }
    }

    return '';
  }

  String queryInvitationIDByInviterID(String inviterID) {
    for (final invitationData in invitationMap.values) {
      if (invitationData.inviterID == inviterID) {
        return invitationData.id;
      }
    }

    return '';
  }

  String queryInvitationIDByInvitees(List<String> invitees) {
    for (final invitationData in invitationMap.values) {
      var querySuccess = 0;
      for (final targetInvitee in invitees) {
        if (invitationData.invitees
            .any((element) => element.userID == targetInvitee)) {
          querySuccess++;
        } else {
          break;
        }
      }
      if (querySuccess == invitees.length) {
        return invitationData.id;
      }
    }
    return '';
  }

  InvitationData? removeIfAllInviteesDone(String invitationID) {
    var isDone = true;
    for (final invitee
        in invitationMap[invitationID]?.invitees ?? <InvitationUser>[]) {
      if (invitee.state == InvitationState.waiting) {
        isDone = false;
        break;
      }
    }

    if (isDone) {
      return removeInvitationData(invitationID);
    }
    return invitationMap[invitationID];
  }

  void clearInvitationData() {
    invitationMap = {};
  }

  /// invite
  Future<ZegoSignalingPluginSendInvitationResult> invite({
    required int type,
    required List<String> invitees,
    required int timeout,
    required String kitData,
    bool isAdvancedMode = false,
    String zimExtendedData = '',
    ZegoSignalingPluginPushConfig? pushConfig,
  }) async {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .sendInvitation(
          invitees: invitees,
          timeout: timeout,
          isAdvancedMode: isAdvancedMode,
          extendedData: zimExtendedData,
          pushConfig: pushConfig,
        )
        .then((result) {
      if (result.error == null) {
        ZegoLoggerService.logInfo(
          'send invitation done, invitationID:${result.invitationID}',
          tag: 'uikit-plugin-signaling',
          subTag: 'invitation data',
        );

        final invitationData = InvitationData(
          id: result.invitationID,
          inviterID: _loginUser!,
          invitees: invitees
              .map((inviteeID) => InvitationUser(
                    userID: inviteeID,
                    state: InvitationState.waiting,
                  ))
              .toList(),
          type: type,
          data: kitData,
          resourceID: pushConfig?.resourceID ?? '',
        );
        addInvitationData(invitationData);

        if (result.errorInvitees.isNotEmpty) {
          var errorMessage = '';
          result.errorInvitees.forEach((id, reason) {
            errorMessage += '$id, reason:$reason;';
            ZegoLoggerService.logInfo(
              'invite error, $errorMessage',
              tag: 'uikit-plugin-signaling',
              subTag: 'invitation data',
            );
          });

          final errorUserIDs = result.errorInvitees.keys.toList();
          for (final invitee in invitationData.invitees) {
            if (errorUserIDs.contains(invitee.userID)) {
              invitee.state = InvitationState.error;
            }
          }
          removeIfAllInviteesDone(result.invitationID);
          return ZegoSignalingPluginSendInvitationResult(
            invitationID: result.invitationID,
            errorInvitees: result.errorInvitees,
          );
        } else {
          ZegoLoggerService.logInfo(
            'invite success, invitationID:${result.invitationID}',
            tag: 'uikit-plugin-signaling',
            subTag: 'invitation data',
          );

          return result;
        }
      } else {
        ZegoLoggerService.logError(
          'send invitation failed, error: ${result.error}',
          tag: 'uikit-plugin-signaling',
          subTag: 'invitation data',
        );
      }
      return result;
    });
  }

  /// cancel
  Future<ZegoSignalingPluginCancelInvitationResult> cancel(
    List<String> invitees,
    String invitationID,
    String extendedData,
    ZegoSignalingPluginIncomingInvitationCancelPushConfig? pushConfig,
  ) async {
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
        for (final invitee
            in invitationMap[invitationID]?.invitees ?? <InvitationUser>[]) {
          final isCancelUser = invitees.contains(invitee.userID);
          final isCancelError = result.errorInvitees.contains(invitee.userID);
          if (isCancelUser && !isCancelError) {
            invitee.state = InvitationState.cancel;
          } else {
            invitee.state = InvitationState.error;
          }
        }
        removeIfAllInviteesDone(invitationID);

        if (result.errorInvitees.isNotEmpty) {
          for (final element in result.errorInvitees) {
            ZegoLoggerService.logInfo(
              'cancel invitation error, invitationID:$invitationID, invitee id:$element',
              tag: 'uikit-plugin-signaling',
              subTag: 'invitation data',
            );
          }
        } else {
          ZegoLoggerService.logInfo(
            'cancel invitation done, invitationID:$invitationID',
            tag: 'uikit-plugin-signaling',
            subTag: 'invitation data',
          );
        }
      } else {
        ZegoLoggerService.logError(
          'cancel invitation failed, error:${result.error}',
          tag: 'uikit-plugin-signaling',
          subTag: 'invitation data',
        );
      }
      return result;
    });
  }

  /// accept
  Future<ZegoSignalingPluginResponseInvitationResult> accept(
    String invitationID,
    String extendedData,
  ) async {
    removeInvitationData(invitationID);

    return ZegoPluginAdapter()
        .signalingPlugin!
        .acceptInvitation(
          invitationID: invitationID,
          extendedData: extendedData,
        )
        .then((result) {
      if (result.error == null) {
        ZegoLoggerService.logInfo(
          'accept invitation done, invitationID:$invitationID',
          tag: 'uikit-plugin-signaling',
          subTag: 'invitation data',
        );
      } else {
        ZegoLoggerService.logError(
          'accept invitation failed, error: ${result.error}',
          tag: 'uikit-plugin-signaling',
          subTag: 'invitation data',
        );
      }
      return result;
    });
  }

  /// reject
  Future<ZegoSignalingPluginResponseInvitationResult> reject(
      String invitationID, String extendedData) async {
    removeInvitationData(invitationID);

    return ZegoPluginAdapter()
        .signalingPlugin!
        .refuseInvitation(
          invitationID: invitationID,
          extendedData: extendedData,
        )
        .then((result) {
      if (result.error == null) {
        ZegoLoggerService.logInfo(
          'reject invitation done, invitationID:$invitationID',
          tag: 'uikit-plugin-signaling',
          subTag: 'invitation data',
        );
      } else {
        ZegoLoggerService.logError(
          'reject invitation failed, error: ${result.error}',
          tag: 'uikit-plugin-signaling',
          subTag: 'invitation data',
        );
      }
      return result;
    });
  }

  void onInvitationUserStateChanged(
    ZegoSignalingPluginInvitationUserStateChangedEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'onInvitationUserStateChanged, $event',
      tag: 'uikit-plugin-signaling',
      subTag: 'invitation data',
    );

    final evenType = invitationMap[event.invitationID]?.type ?? -1;

    streamCtrlInvitationUserStateChanged?.add(
      ZegoSignalingPluginInvitationUserStateChangedEvent(
        invitationID: event.invitationID,
        callUserList: event.callUserList,
        type: evenType,
      ),
    );
  }

  /// on incoming invitation received
  void onIncomingInvitationReceived(
    ZegoSignalingPluginIncomingInvitationReceivedEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'onIncomingInvitationReceived, $event',
      tag: 'uikit-plugin-signaling',
      subTag: 'invitation data',
    );

    final extendedMap = jsonDecode(event.extendedData) as Map<String, dynamic>;

    final invitees = <InvitationUser>[];
    try {
      final extendedDataMap = jsonDecode(extendedMap['data'] as String? ?? '')
          as Map<String, dynamic>;

      for (final invitee in extendedDataMap['invitees'] as List? ?? []) {
        final inviteeDict = invitee as Map<String, dynamic>? ?? {};
        final user = InvitationUser(
          userID: inviteeDict['user_id'] as String,
          state: InvitationState.waiting,
        );
        invitees.add(user);
      }
    } catch (e) {
      ZegoLoggerService.logInfo(
        'data ${extendedMap['data']} is not a json',
        tag: 'signal',
        subTag: 'invitation data',
      );
    }

    final invitationData = InvitationData(
      id: event.invitationID,
      inviterID: event.inviterID,
      invitees: invitees,
      type: extendedMap['type'] as int,
      data: extendedMap['data'] as String,
      resourceID: '', //todo notificationConfig?.resourceID ?? '',
    );
    if (invitationMap.containsKey(invitationData.id)) {
      ZegoLoggerService.logInfo(
        'call id ${invitationData.id} is exist before',
        tag: 'signal',
        subTag: 'invitation data',
      );

      return;
    }

    addInvitationData(invitationData);

    ZegoUIKit().reporter().report(
      event: ZegoUIKitSignalingReporter.eventCallInviteReceived,
      params: {
        ZegoUIKitSignalingReporter.eventKeyInvitationID: event.invitationID,
        ZegoUIKitSignalingReporter.eventKeyInviter: event.inviterID,
        ZegoUIKitSignalingReporter.eventKeyExtendedData: event.extendedData,
        ZegoUIKitReporter.eventKeyAppState: ZegoUIKitReporter.currentAppState(),
      },
    );

    streamCtrlInvitationReceived?.add({
      'invitation_id': event.invitationID,
      'data': extendedMap['data'] as String,
      'type': extendedMap['type'] as int,
      'inviter': ZegoUIKitUser(
        id: event.inviterID,
        name: extendedMap['inviter_name'] as String,
      ),
      'create_timestamp_second': event.createTime ~/ 1000,
      'timeout_second': event.timeoutSecond,
    });
  }

  void onIncomingInvitationCancelled(
    ZegoSignalingPluginIncomingInvitationCancelledEvent event,
  ) {
    //  inviter extendedData
    ZegoLoggerService.logInfo(
      'onIncomingInvitationCancelled, $event',
      tag: 'uikit-plugin-signaling',
      subTag: 'invitation data',
    );

    final invitationData = removeInvitationData(event.invitationID);

    streamCtrlInvitationCanceled?.add({
      'invitation_id': event.invitationID,
      'data': event.extendedData,
      'type': invitationData?.type ?? 0,
      'inviter': ZegoUIKitUser(id: event.inviterID, name: ''),
    });
  }

  /// on call invitation accepted
  void onOutgoingInvitationAccepted(
    ZegoSignalingPluginOutgoingInvitationAcceptedEvent event,
  ) {
    //  inviter extendedData
    ZegoLoggerService.logInfo(
      'onOutgoingInvitationAccepted, $event',
      tag: 'uikit-plugin-signaling',
      subTag: 'invitation data',
    );

    getInvitee(event.invitationID, event.inviteeID)?.state =
        InvitationState.accept;

    final invitationData = removeIfAllInviteesDone(event.invitationID);

    streamCtrlInvitationAccepted?.add({
      'invitation_id': event.invitationID,
      'data': event.extendedData,
      'type': invitationData?.type ?? 0,
      'invitee': ZegoUIKitUser(id: event.inviteeID, name: ''),
    });
  }

  /// on call invitation rejected
  void onOutgoingInvitationRejected(
    ZegoSignalingPluginOutgoingInvitationRejectedEvent event,
  ) {
    //  inviter extendedData
    ZegoLoggerService.logInfo(
      'onOutgoingInvitationRejected, $event',
      tag: 'uikit-plugin-signaling',
      subTag: 'invitation data',
    );

    getInvitee(event.invitationID, event.inviteeID)?.state =
        InvitationState.refuse;

    final invitationData = removeIfAllInviteesDone(event.invitationID);

    streamCtrlInvitationRefused?.add({
      'invitation_id': event.invitationID,
      'data': event.extendedData,
      'type': invitationData?.type ?? 0,
      'invitee': ZegoUIKitUser(id: event.inviteeID, name: ''),
    });
  }

  /// on call invitation timeout
  void onIncomingInvitationTimeout(
    ZegoSignalingPluginIncomingInvitationTimeoutEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'onIncomingInvitationTimeout, $event',
      tag: 'uikit-plugin-signaling',
      subTag: 'invitation data',
    );

    final invitationData = removeInvitationData(event.invitationID);

    streamCtrlInvitationTimeout?.add({
      'invitation_id': event.invitationID,
      'data': invitationData?.data ?? '',
      'type': invitationData?.type ?? 0,
      'inviter': ZegoUIKitUser(id: invitationData?.inviterID ?? '', name: ''),
    });
  }

  /// on call invitation answered timeout
  void onOutgoingInvitationTimeout(
    ZegoSignalingPluginOutgoingInvitationTimeoutEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'onOutgoingInvitationTimeout, $event',
      tag: 'uikit-plugin-signaling',
      subTag: 'invitation data',
    );

    for (final invitee
        in invitationMap[event.invitationID]?.invitees ?? <InvitationUser>[]) {
      if (event.invitees.contains(invitee.userID)) {
        invitee.state = InvitationState.timeout;
      }
    }

    final invitationData = removeIfAllInviteesDone(event.invitationID);

    streamCtrlInvitationResponseTimeout?.add({
      'invitation_id': event.invitationID,
      'type': invitationData?.type ?? 0,
      'data': invitationData?.data ?? '',
      'invitees': event.invitees
          .map((inviteeID) => ZegoUIKitUser(id: inviteeID, name: ''))
          .toList(),
    });
  }

  void onOutgoingInvitationEnded(
    ZegoSignalingPluginOutgoingInvitationEndedEvent event,
  ) {
    //  inviter extendedData
    ZegoLoggerService.logInfo(
      'onOutgoingInvitationEnded, $event',
      tag: 'uikit-plugin-signaling',
      subTag: 'invitation data',
    );

    final invitationData = removeInvitationData(event.invitationID);

    streamCtrlInvitationEnded?.add({
      'type': invitationData?.type ?? 0,
      'invitation_id': event.invitationID,
      'caller_id': event.callerID,
      'operated_user_id': event.operatedUserID,
      'end_time': event.endTime,
      'data': event.extendedData,
    });
  }
}
