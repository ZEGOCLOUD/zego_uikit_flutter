part of 'uikit_service.dart';

/// @nodoc
mixin ZegoLoggerService {
  static bool isZegoLoggerInit = false;

  Future<void> initLog({String folderName = 'uikit'}) async {
    if (isZegoLoggerInit) {
      return;
    }

    if (kIsWeb) {
      return;
    }

    try {
      await FlutterLogs.initLogs(
              logLevelsEnabled: [LogLevel.INFO, LogLevel.WARNING, LogLevel.ERROR, LogLevel.SEVERE],
              timeStampFormat: TimeStampFormat.TIME_FORMAT_24_FULL,
              directoryStructure: DirectoryStructure.SINGLE_FILE_FOR_DAY,
              logTypesEnabled: ['device', 'network', 'errors'],
              logFileExtension: LogFileExtension.LOG,
              logsWriteDirectoryName: 'zego_prebuilt/$folderName',
              logsExportDirectoryName: 'zego_prebuilt/$folderName/Exported',
              debugFileOperations: true,
              isDebuggable: true)
          .then((value) {
        FlutterLogs.setDebugLevel(0);
        FlutterLogs.logInfo(
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
    FlutterLogs.clearLogs();
  }

  @pragma('vm:entry-point')
  static Future<void> logInfo(
    String logMessage, {
    String tag = '',
    String subTag = '',
  }) async {
    if (!isZegoLoggerInit) {
      debugPrint('[INFO] ${DateTime.now()} [$tag] [$subTag] $logMessage');
      return;
    }

    return FlutterLogs.logInfo(tag, subTag, logMessage);
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

    return FlutterLogs.logWarn(tag, subTag, logMessage);
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

    return FlutterLogs.logError(tag, subTag, logMessage);
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

    return FlutterLogs.logErrorTrace(tag, subTag, logMessage, e);
  }
}
