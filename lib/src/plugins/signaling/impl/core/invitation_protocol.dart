// Project imports:
import 'package:zego_uikit/zego_uikit.dart';

class ZegoUIKitInvitationSendProtocol {
  ZegoUIKitInvitationSendProtocol.empty();

  ZegoUIKitInvitationSendProtocol({
    required this.inviter,
    required this.type,
    required this.customData,
  });

  ZegoUIKitUser inviter = ZegoUIKitUser.empty();
  int type = -1;
  String customData = '';

  @override
  String toString() {
    return toJson().toString();
  }

  static bool typeOf(Map<String, dynamic> json) {
    Set<String> requiredKeys = {
      'inviter_id',
      'inviter_name',
      'type',
      'data',
    };

    return requiredKeys.every((key) => json.containsKey(key));
  }

  Map<String, dynamic> toJson() => {
        'inviter_id': inviter.id,
        'inviter_name': inviter.name,
        'type': type,
        'data': customData,
      };

  factory ZegoUIKitInvitationSendProtocol.fromJson(Map<String, dynamic> json) {
    return ZegoUIKitInvitationSendProtocol(
      inviter: ZegoUIKitUser(
        id: json['inviter_id'] as String? ?? '',
        name: json['inviter_name'] as String? ?? '',
        isAnotherRoomUser: false,
      ),
      type: json['type'] as int? ?? -1,
      customData: json['data'] as String? ?? '',
    );
  }
}
