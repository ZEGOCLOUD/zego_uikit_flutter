// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:zego_uikit/zego_uikit.dart';

class ZegoUIKitAdvanceInvitationSendProtocol {
  ZegoUIKitAdvanceInvitationSendProtocol.empty();

  ZegoUIKitAdvanceInvitationSendProtocol({
    required this.inviter,
    required this.invitees,
    required this.type,
    required this.customData,
  });

  ZegoUIKitUser inviter = ZegoUIKitUser.empty();
  List<String> invitees = const [];
  int type = -1;
  String customData = '';

  @override
  String toString() {
    return toJson().toString();
  }

  static bool typeOf(Map<String, dynamic> json) {
    Set<String> requiredKeys = {
      'inviter',
      'invitees',
      'type',
      'custom_data',
    };

    final keysValid = requiredKeys.every((key) => json.containsKey(key));
    if (keysValid) {
      /// web's invitees\'s value is map, flutter is list
      if (json.containsKey('invitees')) {
        final jsonInvitees = json['invitees'];
        ZegoLoggerService.logInfo(
          'invitees:$jsonInvitees',
          tag: 'uikit',
          subTag: 'ZegoUIKitAdvanceInvitationSendProtocol',
        );

        if (jsonInvitees is List) {
          bool isStringList =
              jsonInvitees.every((element) => element is String);

          ZegoLoggerService.logInfo(
            'is a string list:$isStringList',
            tag: 'uikit',
            subTag: 'ZegoUIKitAdvanceInvitationSendProtocol',
          );

          if (!isStringList) {
            /// from web
            return false;
          }
        }
      }
    }

    return keysValid;
  }

  Map<String, dynamic> toJson() => {
        'inviter': inviter,
        'invitees': invitees,
        'type': type,
        'custom_data': customData,

        /// for support web invitation protocol
        'inviter_id': inviter.id,
        'inviter_name': inviter.name,
        'data': customData,
      };

  factory ZegoUIKitAdvanceInvitationSendProtocol.fromJson(
      Map<String, dynamic> json) {
    ZegoUIKitUser inviter = ZegoUIKitUser.empty();
    if (json.containsKey('inviter')) {
      inviter = ZegoUIKitUser.fromJson(
        json['inviter'] as Map<String, dynamic>? ?? {},
      );
    }

    /// for support web invitation protocol
    else if (json.containsKey('inviter_id') ||
        json.containsKey('inviter_name')) {
      inviter = ZegoUIKitUser(
        id: json['inviter_id'] as String? ?? '',
        name: json['inviter_name'] as String? ?? '',
        isAnotherRoomUser: false,
      );
    }

    List<String> invitees = [];
    if (json.containsKey('invitees')) {
      invitees = List<String>.from(json['invitees']);
    }

    String customData = '';
    if (json.containsKey('custom_data')) {
      customData = json['custom_data'] as String? ?? '';
    }

    /// for support web invitation protocol
    else if (json.containsKey('data')) {
      customData = json['data'] as String? ?? '';

      try {
        final extendedDataMap = jsonDecode(customData) as Map<String, dynamic>;
        if (extendedDataMap.containsKey('inviter')) {
          inviter = ZegoUIKitUser.fromJson(
            extendedDataMap['inviter'] as Map<String, dynamic>? ?? {},
          );
        }

        if (extendedDataMap.containsKey('invitees')) {
          final webInviteesMap =
              extendedDataMap['invitees'] as List<dynamic>? ?? [];
          invitees = webInviteesMap.map((item) {
            final inviteeMap = item as Map<String, dynamic>? ?? {};
            return inviteeMap['user_id'] as String? ?? '';
          }).toList();
        }
      } catch (e) {
        ZegoLoggerService.logInfo(
          'fromJson, e:$e',
          tag: 'uikit',
          subTag: 'ZegoUIKitAdvanceInvitationSendProtocol',
        );
      }
    }

    return ZegoUIKitAdvanceInvitationSendProtocol(
      inviter: inviter,
      invitees: invitees,
      type: json['type'] as int? ?? -1,
      customData: customData,
    );
  }
}

class ZegoUIKitAdvanceInvitationAcceptProtocol {
  ZegoUIKitAdvanceInvitationAcceptProtocol.empty();

  ZegoUIKitAdvanceInvitationAcceptProtocol({
    required this.inviter,
    required this.customData,
  });

  /// accept invitation from [inviter]
  ZegoUIKitUser inviter = ZegoUIKitUser.empty();

  /// [invitee]'s [customData]
  String customData = '';

  Map<String, dynamic> toJson() => {
        'inviter': inviter,
        'custom_data': customData,
      };

  factory ZegoUIKitAdvanceInvitationAcceptProtocol.fromJson(
      Map<String, dynamic> json) {
    return ZegoUIKitAdvanceInvitationAcceptProtocol(
      inviter: ZegoUIKitUser.fromJson(
        json['inviter'] as Map<String, dynamic>? ?? {},
      ),
      customData: json['custom_data'],
    );
  }
}
