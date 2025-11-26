// Dart imports:
import 'dart:math';

/// room hall
class ZegoUIKitHallRoomIDHelper {
  static bool isRandomUserID(String userID) {
    RegExp regex = RegExp(r'^zg_t_u_[a-zA-Z0-9]{5}$');
    return regex.hasMatch(userID);
  }

  static bool isRandomRoomID(String roomID) {
    RegExp regex = RegExp(r'^zg_t_r_[a-zA-Z0-9]{5}$');
    return regex.hasMatch(roomID);
  }

  static String randomUserID() {
    return 'zg_t_u_${generateRandomID()}';
  }

  static String randomRoomID() {
    return 'zg_t_r_${generateRandomID()}';
  }

  static String generateRandomID() {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final Random rnd = Random();

    return String.fromCharCodes(
      Iterable.generate(
        5,
        (_) => chars.codeUnitAt(
          rnd.nextInt(chars.length),
        ),
      ),
    );
  }
}
