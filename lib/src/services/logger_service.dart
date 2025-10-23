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

  /// export logs
  ///
  /// [title] export title, defaults to current timestamp
  /// [content] export content description
  /// [fileName] Zip file name (without extension), defaults to current timestamp
  /// [fileTypes] List of file types to collect, defaults to [ZegoLogExporterFileType.txt, ZegoLogExporterFileType.log, ZegoLogExporterFileType.zip]
  /// [directories] List of directory types to collect, defaults to 5 log directories
  /// [onProgress] Optional progress callback, returns progress percentage (0.0 to 1.0)
  Future<bool> exportLogs({
    String? title,
    String? content,
    String? fileName,
    List<ZegoLogExporterFileType> fileTypes = const [
      ZegoLogExporterFileType.txt,
      ZegoLogExporterFileType.log,
      ZegoLogExporterFileType.zip
    ],
    List<ZegoLogExporterDirectoryType> directories = const [
      ZegoLogExporterDirectoryType.zegoUIKits,
      ZegoLogExporterDirectoryType.zimAudioLog,
      ZegoLogExporterDirectoryType.zimLogs,
      ZegoLogExporterDirectoryType.zefLogs,
      ZegoLogExporterDirectoryType.zegoLogs,
    ],
    void Function(double progress)? onProgress,
  }) async {
    return ZegoLogExporterShareManager().share(
      title: title,
      content: content,
      fileName: fileName,
      fileTypes: fileTypes,
      directories: directories,
      onProgress: onProgress,
    );
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
