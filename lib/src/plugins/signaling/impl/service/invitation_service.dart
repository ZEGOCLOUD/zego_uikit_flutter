// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

// Project imports:
import 'package:zego_uikit/src/plugins/signaling/defines.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/core/core.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/core/invitation_protocol.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/service/reporter.dart';
import 'package:zego_uikit/src/services/services.dart';

/// @nodoc
mixin ZegoPluginInvitationService {
  DateTime? sendInvitationStartTime;

  /// send invitation to one or more specified users
  /// [invitees] list of invitees.
  /// [timeout] timeout of the call invitation, the unit is seconds
  /// [type] call type
  /// [data] extended field, through which the inviter can carry information to the invitee.
  Future<ZegoSignalingPluginSendInvitationResult> sendInvitation({
    required String inviterID,
    required String inviterName,
    required List<String> invitees,
    required int timeout,
    required int type,
    required String data,
    bool isAdvancedMode = false,
    ZegoNotificationConfig? zegoNotificationConfig,
  }) async {
    invitees.removeWhere((item) => ['', null].contains(item));
    if (invitees.isEmpty) {
      ZegoLoggerService.logError(
        'invitees is empty',
        tag: 'uikit-plugin-signaling',
        subTag: 'invitation service, send invitation',
      );
      return ZegoSignalingPluginSendInvitationResult(
        error: PlatformException(code: '-1', message: 'invitees is empty'),
        invitationID: '',
        errorInvitees: const {},
      );
    }

    if (null != sendInvitationStartTime) {
      const maxMilliSeconds = 1000;
      final diffMilliSeconds =
          DateTime.now().difference(sendInvitationStartTime!).inMilliseconds;
      if (diffMilliSeconds < maxMilliSeconds) {
        ZegoLoggerService.logInfo(
          'limited frequency, '
          'last access time was $sendInvitationStartTime, '
          'please request again after ${maxMilliSeconds - diffMilliSeconds} milliseconds',
          tag: 'uikit-plugin-signaling',
          subTag: 'invitation service, send invitation',
        );

        return ZegoSignalingPluginSendInvitationResult(
          error: PlatformException(code: '-1', message: 'limited frequency'),
          invitationID: '',
          errorInvitees: invitees.fold<Map<String, int>>({}, (acc, invitee) {
            acc[invitee] = -1;
            return acc;
          }),
        );
      }
    }

    final zimExtendedData = const JsonEncoder().convert(
      ZegoUIKitInvitationSendProtocol(
        inviter: ZegoUIKitUser(id: inviterID, name: inviterName),
        type: type,
        customData: data,
      ).toJson(),
    );

    ZegoSignalingPluginPushConfig? pluginPushConfig;
    if (ZegoSignalingPluginCore
            .shared.coreData.notifyWhenAppIsInTheBackgroundOrQuit &&
        (zegoNotificationConfig?.notifyWhenAppIsInTheBackgroundOrQuit ??
            false)) {
      pluginPushConfig = ZegoSignalingPluginPushConfig(
        resourceID: zegoNotificationConfig!.resourceID,
        title: zegoNotificationConfig.title,
        message: zegoNotificationConfig.message,
        payload: zimExtendedData,
        voipConfig: ZegoSignalingPluginVoIPConfig(
          iOSVoIPHasVideo:
              zegoNotificationConfig.voIPConfig?.iOSVoIPHasVideo ?? false,
        ),
      );
    }

    sendInvitationStartTime = DateTime.now();

    ZegoLoggerService.logInfo(
      'time:$sendInvitationStartTime, '
      'network state:${ZegoUIKit().getNetworkState()}, '
      'invitees:$invitees, timeout:$timeout, type:$type, '
      'zimExtendedData:$zimExtendedData, '
      'notification config:$zegoNotificationConfig',
      tag: 'uikit-plugin-signaling',
      subTag: 'invitation service, send invitation',
    );

    return ZegoSignalingPluginCore.shared.coreData
        .invite(
      invitees: invitees,
      type: type,
      timeout: timeout,
      zimExtendedData: zimExtendedData,
      kitData: data,
      isAdvancedMode: isAdvancedMode,
      pushConfig: pluginPushConfig,
    )
        .then((result) {
      ZegoUIKit().reporter().report(
        event: ZegoUIKitSignalingReporter.eventCallInvite,
        params: {
          ZegoUIKitSignalingReporter.eventKeyInvitationID: result.invitationID,
          ZegoUIKitSignalingReporter.eventKeyInvitees: invitees,
          ZegoUIKitSignalingReporter.eventKeyInviteesCount: invitees.length,
          ZegoUIKitSignalingReporter.eventKeyErrorUsers:
              result.errorInvitees.keys.toList(),
          ZegoUIKitSignalingReporter.eventKeyErrorUsersCount:
              result.errorInvitees.keys.length,
          ZegoUIKitSignalingReporter.eventKeyExtendedData: zimExtendedData,
        },
      );

      return result;
    });
  }

  /// cancel invitation to one or more specified users
  /// [inviteeID] invitee's id
  /// [data] extended field
  Future<ZegoSignalingPluginCancelInvitationResult> cancelInvitation({
    required List<String> invitees,
    required String data,
  }) async {
    var invitationID = '';
    Map<String, dynamic> extendedDataMap = {};
    try {
      extendedDataMap = jsonDecode(data) as Map<String, dynamic>? ?? {};
    } catch (e) {
      ZegoLoggerService.logError(
        'cancel invitation, data is not a json:$data',
        tag: 'uikit-plugin-signaling',
        subTag: 'invitation service',
      );
    } finally {
      invitationID = extendedDataMap['invitation_id'] as String? ?? '';
      if (invitationID.isEmpty) {
        invitationID = ZegoSignalingPluginCore.shared.coreData
            .queryInvitationIDByInvitees(invitees);
      }
    }

    invitees.removeWhere((item) => ['', null].contains(item));
    if (invitees.isEmpty) {
      ZegoLoggerService.logError(
        'invitees is empty',
        tag: 'uikit-plugin-signaling',
        subTag: 'invitation service',
      );
      return ZegoSignalingPluginCancelInvitationResult(
        invitationID: invitationID,
        error: PlatformException(
          code: ZegoSignalingErrorCode.invitationCancelError.toString(),
          message: 'invitees is empty',
        ),
        errorInvitees: <String>[],
      );
    }

    if (invitationID.isEmpty) {
      ZegoLoggerService.logError(
        'cancel invitation, '
        'invitationID is empty',
        tag: 'uikit-plugin-signaling',
        subTag: 'invitation service',
      );
      return ZegoSignalingPluginCancelInvitationResult(
        invitationID: invitationID,
        error: PlatformException(
          code: ZegoSignalingErrorCode.invitationCancelError.toString(),
          message: 'invitationID is empty',
        ),
        errorInvitees: invitees,
      );
    }

    final pushConfig = ZegoSignalingPluginIncomingInvitationCancelPushConfig(
      resourcesID: ZegoSignalingPluginCore.shared.coreData
          .queryResourceIDByInvitationID(invitationID),
      payload: data,
    );

    ZegoLoggerService.logInfo(
      'cancel invitation: '
      'network state:${ZegoUIKit().getNetworkState()}, '
      'invitationID:$invitationID, '
      'invitees:$invitees, '
      'data:$data, '
      'pushConfig:$pushConfig',
      tag: 'uikit-plugin-signaling',
      subTag: 'invitation service',
    );

    return ZegoSignalingPluginCore.shared.coreData.cancel(
      invitees,
      invitationID,
      data,
      pushConfig,
    );
  }

  /// invitee reject the call invitation
  /// [inviterID] inviter id, who send invitation
  /// [data] extended field, you can include your reasons such as Declined
  Future<ZegoSignalingPluginResponseInvitationResult> refuseInvitation({
    required String inviterID,
    required String data,
    String? targetInvitationID,
  }) async {
    ZegoLoggerService.logInfo(
      'inviterID:$inviterID, '
      'data:$data, '
      'targetInvitationID:$targetInvitationID, ',
      tag: 'uikit-plugin-signaling',
      subTag: 'invitation service, refuse invitation',
    );

    late String invitationID;
    Map<String, dynamic> extendedDataMap = {};
    try {
      extendedDataMap = jsonDecode(data) as Map<String, dynamic>? ?? {};
    } catch (e) {
      ZegoLoggerService.logError(
        'data is not a json:$data',
        tag: 'uikit-plugin-signaling',
        subTag: 'invitation service, refuse invitation',
      );
    } finally {
      ZegoLoggerService.logInfo(
        'extendedDataMap:$extendedDataMap',
        tag: 'uikit-plugin-signaling',
        subTag: 'invitation service, refuse invitation',
      );

      invitationID = (targetInvitationID?.isNotEmpty ?? false)
          ? targetInvitationID!
          : (extendedDataMap['invitation_id'] as String? ?? '');
      if (invitationID.isEmpty) {
        invitationID = ZegoSignalingPluginCore.shared.coreData
            .queryInvitationIDByInviterID(inviterID);
      }
    }

    if (invitationID.isEmpty) {
      ZegoLoggerService.logError(
        'invitationID is empty, inviter id:$inviterID',
        tag: 'uikit-plugin-signaling',
        subTag: 'invitation service, refuse invitation',
      );
      return ZegoSignalingPluginResponseInvitationResult(
        invitationID: invitationID,
        error: PlatformException(
          code: ZegoSignalingErrorCode.invitationRefuseError.toString(),
          message: 'invitationID is empty',
        ),
      );
    }

    ZegoLoggerService.logInfo(
      'network state:${ZegoUIKit().getNetworkState()}, '
      'invitationID:$invitationID, '
      'inviter id:$inviterID, data:$data',
      tag: 'uikit-plugin-signaling',
      subTag: 'invitation service, refuse invitation',
    );

    return ZegoSignalingPluginCore.shared.coreData.reject(invitationID, data);
  }

  Future<ZegoSignalingPluginResponseInvitationResult>
      refuseInvitationByInvitationID({
    required String invitationID,
    required String data,
  }) async {
    if (invitationID.isEmpty) {
      ZegoLoggerService.logError(
        'refuse invitation: '
        'invitationID is empty',
        tag: 'uikit-plugin-signaling',
        subTag: 'invitation service',
      );
      return ZegoSignalingPluginResponseInvitationResult(
        invitationID: invitationID,
      );
    }

    ZegoLoggerService.logInfo(
      'refuse invitation: '
      'network state:${ZegoUIKit().getNetworkState()}, '
      'invitationID:$invitationID, data:$data',
      tag: 'uikit-plugin-signaling',
      subTag: 'invitation service',
    );

    return ZegoSignalingPluginCore.shared.coreData.reject(invitationID, data);
  }

  /// invitee accept the call invitation
  /// [inviterID] inviter id, who send invitation
  /// [data] extended field
  Future<ZegoSignalingPluginResponseInvitationResult> acceptInvitation({
    required String inviterID,
    required String data,
    String? targetInvitationID,
  }) async {
    final invitationID = (targetInvitationID?.isNotEmpty ?? false)
        ? targetInvitationID!
        : ZegoSignalingPluginCore.shared.coreData
            .queryInvitationIDByInviterID(inviterID);

    if (invitationID.isEmpty) {
      ZegoLoggerService.logError(
        'accept invitation, '
        'invitationID is empty',
        tag: 'uikit-plugin-signaling',
        subTag: 'invitation service',
      );
      return ZegoSignalingPluginResponseInvitationResult(
        invitationID: invitationID,
        error: PlatformException(
          code: ZegoSignalingErrorCode.invitationAcceptError.toString(),
          message: 'invitationID is empty',
        ),
      );
    }

    ZegoLoggerService.logInfo(
      'accept invitation, '
      'network state:${ZegoUIKit().getNetworkState()}, '
      'invitationID:$invitationID, inviter id:$inviterID, data:$data',
      tag: 'uikit-plugin-signaling',
      subTag: 'invitation service',
    );

    return ZegoSignalingPluginCore.shared.coreData.accept(invitationID, data);
  }

  /// When to call: After the call invitation is initiated, the calling member accepts, rejects, or exits, or the response times out, the current calling inviting member receives this callback.
  /// Note: If the user is not the inviter who initiated this call invitation or is not online, the callback will not be received.
  Stream<ZegoSignalingPluginInvitationUserStateChangedEvent>
      getInvitationUserStateChangedStream() {
    return ZegoSignalingPluginCore
            .shared.coreData.streamCtrlInvitationUserStateChanged?.stream ??
        const Stream.empty();
  }

  /// stream callback, notify invitee when call invitation received
  Stream<Map<String, dynamic>> getInvitationReceivedStream() {
    return ZegoSignalingPluginCore
            .shared.coreData.streamCtrlInvitationReceived?.stream ??
        const Stream.empty();
  }

  /// stream callback, notify invitee if invitation timeout
  Stream<Map<String, dynamic>> getInvitationTimeoutStream() {
    return ZegoSignalingPluginCore
            .shared.coreData.streamCtrlInvitationTimeout?.stream ??
        const Stream.empty();
  }

  /// stream callback, When the call invitation times out, the invitee does not respond, and the inviter will receive a callback.
  Stream<Map<String, dynamic>> getInvitationResponseTimeoutStream() {
    return ZegoSignalingPluginCore
            .shared.coreData.streamCtrlInvitationResponseTimeout?.stream ??
        const Stream.empty();
  }

  /// stream callback, notify when call invitation accepted by invitee
  Stream<Map<String, dynamic>> getInvitationAcceptedStream() {
    return ZegoSignalingPluginCore
            .shared.coreData.streamCtrlInvitationAccepted?.stream ??
        const Stream.empty();
  }

  /// stream callback, notify when call invitation rejected by invitee
  Stream<Map<String, dynamic>> getInvitationRefusedStream() {
    return ZegoSignalingPluginCore
            .shared.coreData.streamCtrlInvitationRefused?.stream ??
        const Stream.empty();
  }

  /// stream callback, notify when call invitation cancelled by inviter
  Stream<Map<String, dynamic>> getInvitationCanceledStream() {
    return ZegoSignalingPluginCore
            .shared.coreData.streamCtrlInvitationCanceled?.stream ??
        const Stream.empty();
  }
}
