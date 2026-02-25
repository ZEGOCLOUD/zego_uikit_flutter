// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

// Project imports:
import 'package:zego_uikit/src/plugins/signaling/defines.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/core/advance_invitation_protocol.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/core/core.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/core/defines.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/service/reporter.dart';
import 'package:zego_uikit/src/services/services.dart';

/// @nodoc
mixin ZegoPluginInvitationServiceAdvance {
  DateTime? advanceSendInvitationStartTime;

  /// Send an advanced invitation to one or more users.
  ///
  /// [inviterID] The ID of the user sending the invitation.
  /// [inviterName] The name of the user sending the invitation.
  /// [invitees] List of user IDs to invite.
  /// [timeout] Timeout in seconds for the invitation.
  /// [type] Type of the call (video or voice).
  /// [data] Custom data to send with the invitation.
  /// [zegoNotificationConfig] Configuration for offline push notifications.
  Future<ZegoSignalingPluginSendInvitationResult> sendAdvanceInvitation({
    required String inviterID,
    required String inviterName,
    required List<String> invitees,
    required int timeout,
    required int type,
    required String data,
    ZegoNotificationConfig? zegoNotificationConfig,
  }) async {
    invitees.removeWhere((item) => ['', null].contains(item));
    if (invitees.isEmpty) {
      ZegoLoggerService.logError(
        'invitees is empty',
        tag: 'uikit.plugin.signaling',
        subTag: 'advance invitation service, send invitation',
      );
      return ZegoSignalingPluginSendInvitationResult(
        error: PlatformException(code: '-1', message: 'invitees is empty'),
        invitationID: '',
        errorInvitees: {},
      );
    }

    if (null != advanceSendInvitationStartTime) {
      const maxMilliSeconds = 1000;
      final diffMilliSeconds = DateTime.now()
          .difference(advanceSendInvitationStartTime!)
          .inMilliseconds;
      if (diffMilliSeconds < maxMilliSeconds) {
        ZegoLoggerService.logInfo(
          'limited frequency, '
          'last access time was $advanceSendInvitationStartTime, '
          'please request again after ${maxMilliSeconds - diffMilliSeconds} milliseconds',
          tag: 'uikit.plugin.signaling',
          subTag: 'advance invitation service, send invitation',
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

    final zimExtendedData = jsonEncode(ZegoUIKitAdvanceInvitationSendProtocol(
      inviter: ZegoUIKitUser(
        id: inviterID,
        name: inviterName,
        isAnotherRoomUser: false,
      ),
      invitees: invitees,
      type: type,
      customData: data,
    ));

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

    advanceSendInvitationStartTime = DateTime.now();

    ZegoLoggerService.logInfo(
      'time:$advanceSendInvitationStartTime, '
      'network state:${ZegoUIKit().getNetworkState()}, '
      'invitees:$invitees, timeout:$timeout, type:$type, '
      'zimExtendedData:$zimExtendedData, '
      'notification config:$zegoNotificationConfig',
      tag: 'uikit.plugin.signaling',
      subTag: 'advance invitation service, send invitation',
    );

    return ZegoSignalingPluginCore.shared.coreData
        .advanceInvite(
      invitees: invitees,
      type: type,
      timeout: timeout,
      extendedData: zimExtendedData,
      kitData: data,
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

  /// Add more users to an existing advanced invitation.
  ///
  /// [inviterID] The ID of the user who sent the original invitation.
  /// [inviterName] The name of the user who sent the original invitation.
  /// [invitees] List of additional user IDs to add to the invitation.
  /// [type] Type of the call (video or voice).
  /// [data] Custom data to send with the invitation.
  /// [invitationID] The existing invitation ID to add users to.
  /// [zegoNotificationConfig] Configuration for offline push notifications.
  Future<ZegoSignalingPluginSendInvitationResult> addAdvanceInvitation({
    required String inviterID,
    required String inviterName,
    required List<String> invitees,
    required int type,
    required String data,
    String? invitationID,
    ZegoNotificationConfig? zegoNotificationConfig,
  }) async {
    invitees.removeWhere((item) => ['', null].contains(item));
    if (invitees.isEmpty) {
      ZegoLoggerService.logError(
        'invitees is empty',
        tag: 'uikit.plugin.signaling',
        subTag: 'advance invitation service',
      );
      return const ZegoSignalingPluginSendInvitationResult(
        invitationID: '',
        errorInvitees: {},
      );
    }

    final zimExtendedData = jsonEncode(ZegoUIKitAdvanceInvitationSendProtocol(
      inviter: ZegoUIKitUser(
        id: inviterID,
        name: inviterName,
        isAnotherRoomUser: false,
      ),
      invitees: invitees,
      type: type,
      customData: data,
    ));

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

    var targetInvitationID = invitationID;
    if (targetInvitationID?.isEmpty ?? true) {
      Map<String, dynamic>? extendedDataMap;
      try {
        extendedDataMap = jsonDecode(data) as Map<String, dynamic>?;
      } catch (e) {
        ZegoLoggerService.logError(
          'add invitation, '
          'data is not a json:$data',
          tag: 'uikit.plugin.signaling',
          subTag: 'advance invitation service',
        );
      } finally {
        if (extendedDataMap?.containsKey('invitation_id') ?? false) {
          targetInvitationID = extendedDataMap!['invitation_id']! as String;
        } else {
          targetInvitationID = ZegoSignalingPluginCore.shared.coreData
              .queryAdvanceInvitationIDByInitiatorID(inviterID);
        }
      }
    }
    if (targetInvitationID?.isEmpty ?? true) {
      ZegoLoggerService.logError(
        'add invitation, '
        'invitationID is empty',
        tag: 'uikit.plugin.signaling',
        subTag: 'advance invitation service',
      );
      return ZegoSignalingPluginSendInvitationResult(
        error: PlatformException(code: '-1', message: 'invitationID is empty'),
        invitationID: '',
        errorInvitees: {},
      );
    }

    ZegoLoggerService.logInfo(
      'add invitation, '
      'network state:${ZegoUIKit().getNetworkState()}, '
      'invitationID:$targetInvitationID, '
      'invitees:$invitees, type:$type, '
      'zimExtendedData:$zimExtendedData, '
      'notification config:$zegoNotificationConfig',
      tag: 'uikit.plugin.signaling',
      subTag: 'advance invitation service',
    );

    return ZegoSignalingPluginCore.shared.coreData.advanceAddInvite(
      invitationID: targetInvitationID!,
      invitees: invitees,
      type: type,
      extendedData: data,
      pushConfig: pluginPushConfig,
    );
  }

  /// Join an existing advanced invitation.
  ///
  /// [invitationID] The ID of the invitation to join.
  /// [data] Custom data to send when joining.
  Future<ZegoSignalingPluginJoinInvitationResult> joinAdvanceInvitation({
    required String invitationID,
    String? data,
  }) async {
    if (invitationID.isEmpty) {
      ZegoLoggerService.logError(
        'join invitation, '
        'invitationID is empty',
        tag: 'uikit.plugin.signaling',
        subTag: 'advance invitation service',
      );
      return ZegoSignalingPluginJoinInvitationResult(
        error: PlatformException(code: '-1', message: 'invitationID is empty'),
        invitationID: '',
      );
    }

    ZegoLoggerService.logInfo(
      'join invitation, '
      'network state:${ZegoUIKit().getNetworkState()}, '
      'invitationID:$invitationID, ',
      tag: 'uikit.plugin.signaling',
      subTag: 'advance invitation service',
    );

    return ZegoSignalingPluginCore.shared.coreData.advanceJoinInvite(
      invitationID: invitationID,
      extendedData: data ?? '',
    );
  }

  /// cancel invitation to one or more specified users
  /// Cancel an advanced invitation for specified users.
  ///
  /// [invitees] List of invitee IDs to cancel the invitation for.
  /// [data] Extended field containing invitation data.
  /// [invitationID] The specific invitation ID to cancel (optional).
  Future<ZegoSignalingPluginCancelInvitationResult> cancelAdvanceInvitation({
    required List<String> invitees,
    required String data,
    String? invitationID,
  }) async {
    var targetInvitationID = invitationID;
    if (targetInvitationID?.isEmpty ?? true) {
      Map<String, dynamic>? extendedDataMap;
      try {
        extendedDataMap = jsonDecode(data) as Map<String, dynamic>?;
      } catch (e) {
        ZegoLoggerService.logError(
          'cancel invitation, '
          'data is not a json:$data',
          tag: 'uikit.plugin.signaling',
          subTag: 'advance invitation service',
        );
      } finally {
        if (extendedDataMap?.containsKey('invitation_id') ?? false) {
          targetInvitationID = extendedDataMap!['invitation_id']! as String;
        } else {
          targetInvitationID = ZegoSignalingPluginCore.shared.coreData
              .queryInvitationIDByInvitees(invitees);
        }
      }
    }

    invitees.removeWhere((item) => ['', null].contains(item));
    if (invitees.isEmpty) {
      ZegoLoggerService.logError(
        'invitees is empty',
        tag: 'uikit.plugin.signaling',
        subTag: 'advance invitation service',
      );
      return ZegoSignalingPluginCancelInvitationResult(
        invitationID: targetInvitationID ?? '',
        error: PlatformException(
          code: ZegoSignalingErrorCode.invitationCancelError.toString(),
          message: 'invitees is empty',
        ),
        errorInvitees: <String>[],
      );
    }

    if (targetInvitationID?.isEmpty ?? true) {
      ZegoLoggerService.logError(
        'cancel invitation, '
        'invitationID is empty',
        tag: 'uikit.plugin.signaling',
        subTag: 'advance invitation service',
      );
      return ZegoSignalingPluginCancelInvitationResult(
        invitationID: targetInvitationID ?? '',
        error: PlatformException(
          code: ZegoSignalingErrorCode.invitationCancelError.toString(),
          message: 'invitationID is empty',
        ),
        errorInvitees: invitees,
      );
    }

    final pushConfig = ZegoSignalingPluginIncomingInvitationCancelPushConfig(
      resourcesID: ZegoSignalingPluginCore.shared.coreData
          .queryAdvanceResourceIDByInvitationID(
        targetInvitationID!,
      ),
      payload: data,
    );

    ZegoLoggerService.logInfo(
      'cancel invitation, '
      'network state:${ZegoUIKit().getNetworkState()}, '
      'invitationID:$invitationID, '
      'invitees:$invitees, '
      'data:$data, '
      'pushConfig:$pushConfig',
      tag: 'uikit.plugin.signaling',
      subTag: 'advance invitation service',
    );

    return ZegoSignalingPluginCore.shared.coreData.advanceCancel(
      invitees,
      targetInvitationID,
      data,
      pushConfig,
    );
  }

  /// invitee reject the call invitation
  /// Refuse an incoming advanced invitation.
  ///
  /// [inviterID] The ID of the user who sent the invitation.
  /// [data] Extended field, you can include your reasons such as Declined.
  /// [invitationID] The specific invitation ID to refuse (optional).
  Future<ZegoSignalingPluginResponseInvitationResult> refuseAdvanceInvitation({
    required String inviterID,
    required String data,
    String? invitationID,
  }) async {
    ZegoLoggerService.logInfo(
      'inviterID:$inviterID, '
      'data:$data, '
      'invitationID:$invitationID, ',
      tag: 'uikit.plugin.signaling',
      subTag: 'advance invitation service, refuse invitation',
    );

    var targetInvitationID = invitationID;
    if (targetInvitationID?.isEmpty ?? true) {
      Map<String, dynamic>? extendedDataMap;
      try {
        extendedDataMap = jsonDecode(data) as Map<String, dynamic>?;
      } catch (e) {
        ZegoLoggerService.logError(
          'data is not a json:$data',
          tag: 'uikit.plugin.signaling',
          subTag: 'advance invitation service, refuse invitation',
        );
      } finally {
        ZegoLoggerService.logError(
          'extendedDataMap:$extendedDataMap',
          tag: 'uikit.plugin.signaling',
          subTag: 'advance invitation service, refuse invitation',
        );

        if (extendedDataMap?.containsKey('invitation_id') ?? false) {
          targetInvitationID = extendedDataMap!['invitation_id']! as String;
        } else {
          targetInvitationID = ZegoSignalingPluginCore.shared.coreData
              .queryAdvanceInvitationIDByInitiatorID(
            inviterID,
          );
        }
      }
    }

    if (targetInvitationID?.isEmpty ?? true) {
      ZegoLoggerService.logError(
        'invitationID is empty',
        tag: 'uikit.plugin.signaling',
        subTag: 'advance invitation service, refuse invitation',
      );
      return ZegoSignalingPluginResponseInvitationResult(
        invitationID: targetInvitationID ?? '',
        error: PlatformException(
          code: ZegoSignalingErrorCode.invitationRefuseError.toString(),
          message: 'invitationID is empty',
        ),
      );
    }

    ZegoLoggerService.logInfo(
      'network state:${ZegoUIKit().getNetworkState()}, '
      'invitationID:$targetInvitationID, '
      'inviter id:$inviterID, '
      'data:$data',
      tag: 'uikit.plugin.signaling',
      subTag: 'advance invitation service, refuse invitation',
    );

    return ZegoSignalingPluginCore.shared.coreData.advanceReject(
      targetInvitationID!,
      data,
    );
  }

  Future<ZegoSignalingPluginResponseInvitationResult>
      refuseAdvanceInvitationByInvitationID({
    required String invitationID,
    required String data,
  }) async {
    if (invitationID.isEmpty) {
      ZegoLoggerService.logError(
        'refuse invitation, '
        'invitationID is empty',
        tag: 'uikit.plugin.signaling',
        subTag: 'advance invitation service',
      );
      return ZegoSignalingPluginResponseInvitationResult(
        invitationID: invitationID,
      );
    }

    ZegoLoggerService.logInfo(
      'refuse invitation, '
      'network state:${ZegoUIKit().getNetworkState()}, '
      'invitationID:$invitationID, data:$data',
      tag: 'uikit.plugin.signaling',
      subTag: 'advance invitation service',
    );

    return ZegoSignalingPluginCore.shared.coreData.advanceReject(
      invitationID,
      data,
    );
  }

  /// invitee accept the call invitation
  /// Accept an incoming advanced invitation.
  ///
  /// [inviterID] The ID of the user who sent the invitation.
  /// [data] Extended field containing invitation data.
  /// [inviterName] The name of the user who sent the invitation (optional).
  /// [invitationID] The specific invitation ID to accept (optional).
  Future<ZegoSignalingPluginResponseInvitationResult> acceptAdvanceInvitation({
    required String inviterID,
    required String data,
    String? inviterName,
    String? invitationID,
  }) async {
    final targetInvitationID = invitationID ??
        ZegoSignalingPluginCore.shared.coreData
            .queryAdvanceInvitationIDByInitiatorID(
          inviterID,
        );

    if (targetInvitationID.isEmpty) {
      ZegoLoggerService.logError(
        'accept invitation, '
        'invitationID is empty',
        tag: 'uikit.plugin.signaling',
        subTag: 'advance invitation service',
      );
      return ZegoSignalingPluginResponseInvitationResult(
        invitationID: targetInvitationID,
        error: PlatformException(
          code: ZegoSignalingErrorCode.invitationAcceptError.toString(),
          message: 'invitationID is empty',
        ),
      );
    }

    ZegoLoggerService.logInfo(
      'accept invitation, '
      'network state:${ZegoUIKit().getNetworkState()}, '
      'invitationID:$targetInvitationID, '
      'inviter id:$inviterID, '
      'inviter name:$inviterName, '
      'data:$data, ',
      tag: 'uikit.plugin.signaling',
      subTag: 'advance invitation service',
    );

    return ZegoSignalingPluginCore.shared.coreData.advanceAccept(
      targetInvitationID,
      jsonEncode(ZegoUIKitAdvanceInvitationAcceptProtocol(
        inviter: ZegoUIKitUser(
          id: inviterID,
          name: inviterName ?? '',
          isAnotherRoomUser: false,
        ),
        customData: data,
      )),
    );
  }

  /// End an advanced invitation (for the initiator).
  ///
  /// [data] Custom data to send with the ending.
  /// [invitationID] The specific invitation ID to end (optional).
  /// [zegoNotificationConfig] Configuration for offline push notifications (optional).
  Future<ZegoSignalingPluginEndInvitationResult> endAdvanceInvitation({
    String? data,
    String? invitationID,
    ZegoNotificationConfig? zegoNotificationConfig,
  }) async {
    final zimExtendedData = const JsonEncoder().convert({
      'data': data ?? '',
    });

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

    var targetInvitationID = invitationID;
    if (targetInvitationID?.isEmpty ?? true) {
      Map<String, dynamic>? extendedDataMap;
      try {
        extendedDataMap = jsonDecode(data ?? '') as Map<String, dynamic>?;
      } catch (e) {
        ZegoLoggerService.logError(
          'end invitation, data is not a json:$data',
          tag: 'uikit.plugin.signaling',
          subTag: 'advance invitation service',
        );
      } finally {
        if (extendedDataMap?.containsKey('invitation_id') ?? false) {
          targetInvitationID = extendedDataMap!['invitation_id']! as String;
        }
      }
    }
    if (targetInvitationID?.isEmpty ?? true) {
      ZegoLoggerService.logError(
        'end invitation, invitationID is empty',
        tag: 'uikit.plugin.signaling',
        subTag: 'advance invitation service',
      );
      return const ZegoSignalingPluginEndInvitationResult(
        invitationID: '',
      );
    }

    ZegoLoggerService.logInfo(
      'end invitation, '
      'network state:${ZegoUIKit().getNetworkState()}, '
      'invitationID:$targetInvitationID, '
      'zimExtendedData:$zimExtendedData, '
      'notification config:$zegoNotificationConfig',
      tag: 'uikit.plugin.signaling',
      subTag: 'advance invitation service',
    );

    return ZegoSignalingPluginCore.shared.coreData.advanceEnd(
      targetInvitationID!,
      data ?? '',
      pluginPushConfig,
    );
  }

  /// Quit an advanced invitation (for a participant).
  ///
  /// [data] Custom data to send when quitting.
  /// [invitationID] The specific invitation ID to quit from (optional).
  /// [zegoNotificationConfig] Configuration for offline push notifications (optional).
  Future<ZegoSignalingPluginQuitInvitationResult> quitAdvanceInvitation({
    String? data,
    String? invitationID,
    ZegoNotificationConfig? zegoNotificationConfig,
  }) async {
    final zimExtendedData = const JsonEncoder().convert({
      'data': data ?? '',
    });

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

    var targetInvitationID = invitationID;
    if (targetInvitationID?.isEmpty ?? true) {
      Map<String, dynamic>? extendedDataMap;
      try {
        extendedDataMap = jsonDecode(data ?? '') as Map<String, dynamic>?;
      } catch (e) {
        ZegoLoggerService.logInfo(
          'quit invitation, data is not a json:$data',
          tag: 'uikit.plugin.signaling',
          subTag: 'advance invitation service',
        );
      } finally {
        if (extendedDataMap?.containsKey('invitation_id') ?? false) {
          targetInvitationID = extendedDataMap!['invitation_id']! as String;
        }
      }
    }
    if (targetInvitationID?.isEmpty ?? true) {
      ZegoLoggerService.logError(
        '[Error] quit invitation, invitationID is empty',
        tag: 'uikit.plugin.signaling',
        subTag: 'advance invitation service',
      );
      return const ZegoSignalingPluginQuitInvitationResult(
        invitationID: '',
      );
    }

    ZegoLoggerService.logInfo(
      'quit invitation, '
      'network state:${ZegoUIKit().getNetworkState()}, '
      'invitationID:$targetInvitationID, '
      'zimExtendedData:$zimExtendedData, '
      'notification config:$zegoNotificationConfig',
      tag: 'uikit.plugin.signaling',
      subTag: 'advance invitation service',
    );

    return ZegoSignalingPluginCore.shared.coreData.advanceQuit(
      targetInvitationID!,
      data ?? '',
      pluginPushConfig,
    );
  }

  List<AdvanceInvitationUser> getAdvanceInvitees(String invitationID) {
    return ZegoSignalingPluginCore.shared.coreData
        .getAdvanceInvitees(invitationID);
  }

  /// a->b, b->c;
  /// in c event, a is initiator, b is inviter
  AdvanceInvitationUser? getAdvanceInitiator(String invitationID) {
    return ZegoSignalingPluginCore.shared.coreData
        .getAdvanceInitiator(invitationID);
  }

  bool isUserInAdvanceInvitationNow(String userID) {
    return ZegoSignalingPluginCore.shared.coreData
        .isUserInAdvanceInvitationNow(userID);
  }

  String advanceInvitationToString() {
    return ZegoSignalingPluginCore.shared.coreData.advanceInvitationToString();
  }

  /// stream callback, Listen for calling user status changes.
  /// When to call: After the call invitation is initiated, the calling member accepts, rejects, or exits, or the response times out, the current calling inviting member receives this callback.
  /// Note: If the user is not the inviter who initiated this call invitation or is not online, the callback will not be received.
  Stream<ZegoSignalingPluginInvitationUserStateChangedEvent>
      getAdvanceInvitationUserStateChangedStream() {
    return ZegoSignalingPluginCore.shared.coreData
            .streamCtrlAdvanceInvitationUserStateChanged?.stream ??
        const Stream.empty();
  }

  /// stream callback, notify invitee when call invitation received
  Stream<Map<String, dynamic>> getAdvanceInvitationReceivedStream() {
    return ZegoSignalingPluginCore
            .shared.coreData.streamCtrlAdvanceInvitationReceived?.stream ??
        const Stream.empty();
  }

  /// stream callback, notify invitee if invitation timeout
  Stream<Map<String, dynamic>> getAdvanceInvitationTimeoutStream() {
    return ZegoSignalingPluginCore
            .shared.coreData.streamCtrlAdvanceInvitationTimeout?.stream ??
        const Stream.empty();
  }

  /// stream callback, notify when call invitation cancelled by inviter
  Stream<Map<String, dynamic>> getAdvanceInvitationCanceledStream() {
    return ZegoSignalingPluginCore
            .shared.coreData.streamCtrlAdvanceInvitationCanceled?.stream ??
        const Stream.empty();
  }

  /// stream callback, notify when call ended by inviter
  Stream<Map<String, dynamic>> getAdvanceInvitationEndedStream() {
    return ZegoSignalingPluginCore
            .shared.coreData.streamCtrlAdvanceInvitationEnded?.stream ??
        const Stream.empty();
  }
}
