// Dart imports:
import 'dart:core';
import 'dart:math' as math;
import 'dart:typed_data';

/// @nodoc
class StringUtils {
  static String makeRandomString(int size) {
    const ref = '0123456789abcdefghijklmnopqrstuvwxyz';
    return makeRandom(ref, size);
  }

  static String makeRandomID(int size) {
    const ref = '0123456789';
    return makeRandom(ref, size);
  }

  static String makeRandom(String ref, int size) {
    var result = '';
    for (var i = 0; i < size; i++) {
      final r = math.Random().nextInt(ref.length);
      result = '$result${ref[r]}';
    }
    return result;
  }
}

/// @nodoc
class Hex {
  /// Creates a `Uint8List` by a hex string.
  static Uint8List createUint8ListFromHexString(String hex) {
    final result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < hex.length; i += 2) {
      final num = hex.substring(i, i + 2);
      final byte = int.parse(num, radix: 16);
      result[i ~/ 2] = byte;
    }

    return result;
  }

  /// Returns a hex string by a `Uint8List`.
  static String formatBytesAsHexString(Uint8List bytes) {
    final result = StringBuffer();
    for (var i = 0; i < bytes.lengthInBytes; i++) {
      final part = bytes[i];
      result.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
    }

    return result.toString();
  }

  static Uint8List createUint8ListFromInt(int hex) {
    return createUint8ListFromHexString(hex.toRadixString(16));
  }
}
