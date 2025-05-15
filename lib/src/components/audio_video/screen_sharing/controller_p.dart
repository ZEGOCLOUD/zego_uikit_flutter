// Project imports:
import 'defines.dart';

class ZegoScreenSharingViewControllerPrivate {
  var countDownStopSettings = ZegoScreenSharingCountDownStopSettings();

  /// when ending screen sharing from a non-app,
  /// the automatic check end mechanism will be triggered.
  var autoStopSettings = ZegoScreenSharingAutoStopSettings();

  /// If true, then when there is screen sharing display, it will automatically be full screen
  /// default is false
  bool defaultFullScreen = false;
}
