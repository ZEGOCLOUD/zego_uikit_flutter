// Package imports:
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:zego_uikit/src/services/uikit_service.dart';

/// Requests a specific permission from the user.
///
/// Returns true if the permission is granted, false otherwise.
Future<bool> requestPermission(Permission permission) async {
  PermissionStatus? status;
  try {
    status = await permission.request();
  } catch (e) {
    ZegoLoggerService.logError(
      '$permission permission not granted, $e',
      tag: 'uikit',
      subTag: 'permission',
    );
  }

  ZegoLoggerService.logInfo(
    '$permission status: $status',
    tag: 'uikit',
    subTag: 'permission',
  );
  if (status != PermissionStatus.granted) {
    ZegoLoggerService.logError(
      '$permission permission not granted, $status',
      tag: 'uikit',
      subTag: 'permission',
    );
    return false;
  }

  return true;
}
