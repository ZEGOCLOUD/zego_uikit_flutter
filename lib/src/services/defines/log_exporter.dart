/// Log file type enumeration
enum ZegoLogExporterFileType {
  /// Text files (.txt)
  txt,

  /// Log files (.log)
  log,

  /// Zip files (.zip)
  zip,

  /// Database files (.db)
  db,

  /// PCM audio files (.pcm)
  pcm,

  /// All file types
  all,
}

/// Extension methods: Get file extension
extension ZegoLogExporterFileTypeExtension on ZegoLogExporterFileType {
  String get extension {
    switch (this) {
      case ZegoLogExporterFileType.txt:
        return '.txt';
      case ZegoLogExporterFileType.log:
        return '.log';
      case ZegoLogExporterFileType.zip:
        return '.zip';
      case ZegoLogExporterFileType.db:
        return '.db';
      case ZegoLogExporterFileType.pcm:
        return '.pcm';
      case ZegoLogExporterFileType.all:
        return '';
    }
  }

  String get displayName {
    switch (this) {
      case ZegoLogExporterFileType.txt:
        return 'Text Files';
      case ZegoLogExporterFileType.log:
        return 'Log Files';
      case ZegoLogExporterFileType.zip:
        return 'Zip Files';
      case ZegoLogExporterFileType.db:
        return 'Database Files';
      case ZegoLogExporterFileType.pcm:
        return 'PCM Audio Files';
      case ZegoLogExporterFileType.all:
        return 'All Files';
    }
  }
}

/// Log directory type enumeration
enum ZegoLogExporterDirectoryType {
  /// ZegoUIKits log directory
  zegoUIKits,

  /// ZIMAudioLog audio log directory
  zimAudioLog,

  /// ZIMLogs log directory
  zimLogs,

  /// ZefLogs log directory (iOS)
  zefLogs,

  /// ZegoLogs log directory (iOS)
  zegoLogs,

  /// All log directories
  all,
}

/// Extension methods: Get directory path
extension ZegoLogExporterDirectoryTypeExtension
    on ZegoLogExporterDirectoryType {
  String get directoryName {
    switch (this) {
      case ZegoLogExporterDirectoryType.zegoUIKits:
        return 'ZegoUIKits';
      case ZegoLogExporterDirectoryType.zimAudioLog:
        return 'ZIMAudioLog';
      case ZegoLogExporterDirectoryType.zimLogs:
        return 'ZIMLogs';
      case ZegoLogExporterDirectoryType.zefLogs:
        return 'ZefLogs';
      case ZegoLogExporterDirectoryType.zegoLogs:
        return 'ZegoLogs';
      case ZegoLogExporterDirectoryType.all:
        return '';
    }
  }

  String get displayName {
    switch (this) {
      case ZegoLogExporterDirectoryType.zegoUIKits:
        return 'ZegoUIKits Directory';
      case ZegoLogExporterDirectoryType.zimAudioLog:
        return 'ZIM Audio Log Directory';
      case ZegoLogExporterDirectoryType.zimLogs:
        return 'ZIM Logs Directory';
      case ZegoLogExporterDirectoryType.zefLogs:
        return 'Zef Logs Directory';
      case ZegoLogExporterDirectoryType.zegoLogs:
        return 'Zego Logs Directory';
      case ZegoLogExporterDirectoryType.all:
        return 'All Directories';
    }
  }
}
