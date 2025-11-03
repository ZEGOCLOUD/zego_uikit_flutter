class ZegoMobileSystemVersion {
  int major = 0;
  int minor = 0;
  int patch = 0;

  ZegoMobileSystemVersion({
    required this.major,
    required this.minor,
    required this.patch,
  });

  bool get isEmpty => major == 0;

  ZegoMobileSystemVersion.empty();
}
