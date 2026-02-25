/// @nodoc
typedef InvitationID = String;

/// invitation state
enum InvitationState {
  error,
  waiting,
  accept,
  refuse,
  cancel,
  timeout,
}

/// invitation user info
class InvitationUser {
  InvitationUser({required this.userID, required this.state});

  /// User ID of the invitee.
  String userID;

  /// Current state of the invitation.
  InvitationState state;

  @override
  String toString() {
    return '{'
        'userid :$userID, '
        'state:$state, '
        '}';
  }
}

/// invitation state in advance mode
enum AdvanceInvitationState {
  idle,
  error,
  waiting,
  accepted,
  rejected,
  cancelled,
}

/// invitation user info in advance mode
class AdvanceInvitationUser {
  AdvanceInvitationUser({
    required this.userID,
    required this.state,
    this.extendedData = '',
  });

  /// User ID of the invitee.
  String userID;

  /// Current state of the invitation.
  AdvanceInvitationState state;

  /// Extended data for the invitation.
  String extendedData;

  @override
  String toString() {
    return '{'
        'userid :$userID, '
        'state:$state, '
        'extendedData:$extendedData, '
        '}';
  }
}
