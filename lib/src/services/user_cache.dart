// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:zego_uikit/zego_uikit.dart';

/// 用户缓存类，用于持久化存储离开房间的用户 ID 列表
/// 以 room id 作为主 key，只存储用户 ID
class ZegoUIKitUserCache {
  ZegoUIKitUserCache._internal();

  static final ZegoUIKitUserCache _instance = ZegoUIKitUserCache._internal();

  factory ZegoUIKitUserCache() {
    return _instance;
  }

  /// 存储离开用户的缓存 key 前缀
  String _getLeaveUsersCacheKey(String roomID) {
    return 'zego_uikit_leave_users_$roomID';
  }

  /// 保存离开的用户 ID 列表到缓存
  Future<void> setLeaveUsers(String roomID, List<String> userIDs) async {
    ZegoLoggerService.logInfo(
      'set leave users for room:$roomID, userIDs:$userIDs, ',
      tag: 'uikit-user',
      subTag: 'userCache',
    );

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _getLeaveUsersCacheKey(roomID);
    await prefs.setStringList(cacheKey, userIDs);
    await prefs.reload();

    ZegoLoggerService.logInfo(
      'set leave users done for room:$roomID(key:$cacheKey)',
      tag: 'uikit-user',
      subTag: 'userCache',
    );
  }

  /// 从缓存获取离开的用户 ID 列表
  Future<List<String>> getLeaveUsers(String roomID) async {
    ZegoLoggerService.logInfo(
      'get leave users for room:$roomID',
      tag: 'uikit-user',
      subTag: 'userCache',
    );

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _getLeaveUsersCacheKey(roomID);
    await prefs.reload();
    final userIDs = prefs.getStringList(cacheKey);

    if (userIDs == null || userIDs.isEmpty) {
      ZegoLoggerService.logInfo(
        'no cached leave users for room:$roomID(key:$cacheKey)',
        tag: 'uikit-user',
        subTag: 'userCache',
      );
      return [];
    }

    ZegoLoggerService.logInfo(
      'get leave users done for room:$roomID(key:$cacheKey), userIDs:$userIDs',
      tag: 'uikit-user',
      subTag: 'userCache',
    );

    return userIDs;
  }

  /// 清除指定房间的离开用户缓存
  Future<void> clearLeaveUsers(String roomID) async {
    ZegoLoggerService.logInfo(
      'clear leave users for room:$roomID',
      tag: 'uikit-user',
      subTag: 'userCache',
    );

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _getLeaveUsersCacheKey(roomID);
    await prefs.remove(cacheKey);

    ZegoLoggerService.logInfo(
      'clear leave users done for room:$roomID',
      tag: 'uikit-user',
      subTag: 'userCache',
    );
  }
}
