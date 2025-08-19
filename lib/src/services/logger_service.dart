part of 'uikit_service.dart';

/// @nodoc
mixin ZegoLoggerService {
  static bool isZegoLoggerInit = false;

  Future<void> initLog() async {
    if (isZegoLoggerInit) {
      return;
    }

    if (kIsWeb) {
      return;
    }

    try {
      await FlutterLogsYoer.initLogs(
              logLevelsEnabled: [
                LogLevel.INFO,
                LogLevel.WARNING,
                LogLevel.ERROR,
                LogLevel.SEVERE
              ],
              timeStampFormat: TimeStampFormat.TIME_FORMAT_24_FULL,
              directoryStructure: DirectoryStructure.SINGLE_FILE_FOR_DAY,
              logTypesEnabled: ['device', 'network', 'errors'],
              logFileExtension: LogFileExtension.LOG,
              logsWriteDirectoryName: 'ZegoUIKits',
              logsExportDirectoryName: 'ZegoUIKits/Exported',
              useCachesDirectory: true,
              debugFileOperations: true,
              isDebuggable: true)
          .then((value) {
        FlutterLogsYoer.setDebugLevel(0);
        FlutterLogsYoer.logInfo(
          'uikit',
          'log init done',
          '==========================================',
        );
      });

      isZegoLoggerInit = true;
    } catch (e) {
      debugPrint('uikit init logger error:$e');
    }
  }

  Future<void> clearLogs() async {
    FlutterLogsYoer.clearLogs();
  }

  static Future<void> logInfo(
    String logMessage, {
    String tag = '',
    String subTag = '',
  }) async {
    if (!isZegoLoggerInit) {
      debugPrint('[INFO] ${DateTime.now()} [$tag] [$subTag] $logMessage');
      return;
    }

    return FlutterLogsYoer.logInfo(tag, subTag, logMessage);
  }

  static Future<void> logWarn(
    String logMessage, {
    String tag = '',
    String subTag = '',
  }) async {
    if (!isZegoLoggerInit) {
      debugPrint('[WARN] ${DateTime.now()} [$tag] [$subTag] $logMessage');
      return;
    }

    return FlutterLogsYoer.logWarn(tag, subTag, logMessage);
  }

  static Future<void> logError(
    String logMessage, {
    String tag = '',
    String subTag = '',
  }) async {
    if (!isZegoLoggerInit) {
      debugPrint('[ERROR] ${DateTime.now()} [$tag] [$subTag] $logMessage');
      return;
    }

    return FlutterLogsYoer.logError(tag, subTag, logMessage);
  }

  static Future<void> logErrorTrace(
    String logMessage,
    Error e, {
    String tag = '',
    String subTag = '',
  }) async {
    if (!isZegoLoggerInit) {
      debugPrint('[ERROR] ${DateTime.now()} [$tag] [$subTag] $logMessage');
      return;
    }

    return FlutterLogsYoer.logErrorTrace(tag, subTag, logMessage, e);
  }
}
