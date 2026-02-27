class ZegoUIKitSignalingReporter {
  static String eventCallInvite = "callInvite";
  static String eventCallInviteReceived = "invitationReceived";

  static String eventKeyInviter = "inviter";

  ///  List of invited multi-user IDs, array in JSON format, for example `['user1', 'user2', 'user3']`
  static String eventKeyInvitees = "invitees";
  static String eventKeyInviteesCount = "count";

  ///   List of userid and reason for failed invitations, array in json format
  static String eventKeyErrorUsers = "error_userlist";
  static String eventKeyErrorUsersCount = "error_count";

  ///  zim
  static String eventKeyInvitationID = "call_id";

  ///  extended data
  static String eventKeyExtendedData = "extended_data";
}
