/// Represents a mobile system version with major, minor, and patch numbers.
class ZegoMobileSystemVersion {
  /// Major version number.
  int major = 0;

  /// Minor version number.
  int minor = 0;

  /// Patch version number.
  int patch = 0;

  ZegoMobileSystemVersion({
    required this.major,
    required this.minor,
    required this.patch,
  });

  bool get isEmpty => major == 0;

  ZegoMobileSystemVersion.empty();
}
