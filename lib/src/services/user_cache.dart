// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:zego_uikit/zego_uikit.dart';

/// 用户缓存类，用于持久化存储离开房间的用户 ID 列表
/// 以 room id 作为主 key
class ZegoUIKitCache {
  ZegoUIKitCache._internal();

  static final ZegoUIKitCache _instance = ZegoUIKitCache._internal();

  factory ZegoUIKitCache() {
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

  /// 存储删除的流的缓存 key 前缀
  String _getDeletedStreamsCacheKey(String roomID) {
    return 'zego_uikit_deleted_streams_$roomID';
  }

  /// 保存删除的流 ID 列表到缓存
  Future<void> setDeletedStreamIDs(String roomID, List<String> streamIDs) async {
    ZegoLoggerService.logInfo(
      'set deleted streams for room:$roomID, streamIDs:$streamIDs, ',
      tag: 'uikit-user',
      subTag: 'userCache',
    );

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _getDeletedStreamsCacheKey(roomID);
    await prefs.setStringList(cacheKey, streamIDs);
    await prefs.reload();

    ZegoLoggerService.logInfo(
      'set deleted streams done for room:$roomID(key:$cacheKey)',
      tag: 'uikit-user',
      subTag: 'userCache',
    );
  }

  /// 从缓存获取删除的流 ID 列表
  Future<List<String>> getDeletedStreamIDs(String roomID) async {
    ZegoLoggerService.logInfo(
      'get deleted streams for room:$roomID',
      tag: 'uikit-user',
      subTag: 'userCache',
    );

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _getDeletedStreamsCacheKey(roomID);
    await prefs.reload();
    final streamIDs = prefs.getStringList(cacheKey);

    if (streamIDs == null || streamIDs.isEmpty) {
      ZegoLoggerService.logInfo(
        'no cached deleted streams for room:$roomID(key:$cacheKey)',
        tag: 'uikit-user',
        subTag: 'userCache',
      );
      return [];
    }

    ZegoLoggerService.logInfo(
      'get deleted streams done for room:$roomID(key:$cacheKey), streamIDs:$streamIDs',
      tag: 'uikit-user',
      subTag: 'userCache',
    );

    return streamIDs;
  }

  /// 清除指定房间的删除流缓存
  Future<void> clearDeletedStreamIDs(String roomID) async {
    ZegoLoggerService.logInfo(
      'clear deleted streams for room:$roomID',
      tag: 'uikit-user',
      subTag: 'userCache',
    );

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _getDeletedStreamsCacheKey(roomID);
    await prefs.remove(cacheKey);

    ZegoLoggerService.logInfo(
      'clear deleted streams done for room:$roomID',
      tag: 'uikit-user',
      subTag: 'userCache',
    );
  }

  /// 存储删除流所属用户ID的缓存 key 前缀
  String _getDeletedStreamUsersCacheKey(String roomID) {
    return 'zego_uikit_deleted_stream_users_$roomID';
  }

  /// 保存删除流所属的用户 ID 列表到缓存
  Future<void> setDeletedStreamUserIDs(String roomID, List<String> userIDs) async {
    ZegoLoggerService.logInfo(
      'set deleted stream users for room:$roomID, userIDs:$userIDs, ',
      tag: 'uikit-user',
      subTag: 'userCache',
    );

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _getDeletedStreamUsersCacheKey(roomID);
    await prefs.setStringList(cacheKey, userIDs);
    await prefs.reload();

    ZegoLoggerService.logInfo(
      'set deleted stream users done for room:$roomID(key:$cacheKey)',
      tag: 'uikit-user',
      subTag: 'userCache',
    );
  }

  /// 从缓存获取删除流所属的用户 ID 列表
  Future<List<String>> getDeletedStreamUserIDs(String roomID) async {
    ZegoLoggerService.logInfo(
      'get deleted stream users for room:$roomID',
      tag: 'uikit-user',
      subTag: 'userCache',
    );

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _getDeletedStreamUsersCacheKey(roomID);
    await prefs.reload();
    final userIDs = prefs.getStringList(cacheKey);

    if (userIDs == null || userIDs.isEmpty) {
      ZegoLoggerService.logInfo(
        'no cached deleted stream users for room:$roomID(key:$cacheKey)',
        tag: 'uikit-user',
        subTag: 'userCache',
      );
      return [];
    }

    ZegoLoggerService.logInfo(
      'get deleted stream users done for room:$roomID(key:$cacheKey), userIDs:$userIDs',
      tag: 'uikit-user',
      subTag: 'userCache',
    );

    return userIDs;
  }

  /// 清除指定房间的删除流用户缓存
  Future<void> clearDeletedStreamUserIDs(String roomID) async {
    ZegoLoggerService.logInfo(
      'clear deleted stream users for room:$roomID',
      tag: 'uikit-user',
      subTag: 'userCache',
    );

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _getDeletedStreamUsersCacheKey(roomID);
    await prefs.remove(cacheKey);

    ZegoLoggerService.logInfo(
      'clear deleted stream users done for room:$roomID',
      tag: 'uikit-user',
      subTag: 'userCache',
    );
  }
}
