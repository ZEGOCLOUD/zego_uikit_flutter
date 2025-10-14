// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:zego_uikit/src/services/services.dart';

/// Log share manager
///
/// Features:
/// - Collect log files from Android/iOS platforms
/// - Compress into zip file
/// - Share via system share functionality
///
/// Usage example:
/// ```dart
/// final manager = ZegoLogExporterShareManager();
///
/// // Default: collect txt and zip files, 5 log directories
/// await manager.share(
///   title: 'Bug Report',
///   content: 'App crashed when...',
/// );
///
/// // Collect only txt files (still collects 5 default directories)
/// await manager.share(
///   title: 'Text Logs',
///   fileTypes: [ZegoLogExporterFileType.txt],
/// );
///
/// // Collect multiple file types
/// await manager.share(
///   title: 'Database Logs',
///   fileTypes: [ZegoLogExporterFileType.txt, ZegoLogExporterFileType.db],
/// );
///
/// // Collect only specified directories
/// await manager.share(
///   title: 'ZIM Logs',
///   directories: [ZegoLogExporterDirectoryType.zimLogs, ZegoLogExporterDirectoryType.zimAudioLog],
/// );
///
/// // Collect all file types and all directories
/// await manager.share(
///   title: 'Complete Logs',
///   fileTypes: [ZegoLogExporterFileType.all],
///   directories: [ZegoLogExporterDirectoryType.all],
/// );
/// ```
class ZegoLogExporterShareManager {
  static final ZegoLogExporterShareManager _instance =
      ZegoLogExporterShareManager._internal();
  factory ZegoLogExporterShareManager() => _instance;
  ZegoLogExporterShareManager._internal();

  /// Share logs
  ///
  /// [title] Share title, defaults to current timestamp
  /// [content] Share content description
  /// [fileName] Zip file name (without extension), defaults to current timestamp
  /// [fileTypes] List of file types to collect, defaults to [ZegoLogExporterFileType.txt, ZegoLogExporterFileType.log, ZegoLogExporterFileType.zip]
  /// [directories] List of directory types to collect, defaults to 5 log directories
  /// [onProgress] Optional progress callback, returns number of processed files
  Future<bool> share({
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
    void Function(int processedFiles)? onProgress,
  }) async {
    String? zipPath;
    try {
      /// Collect and compress logs
      zipPath = await _collectLogs(
        fileName: fileName,
        fileTypes: fileTypes,
        directories: directories,
        onProgress: onProgress,
      );

      if (zipPath == null) {
        debugPrint('ZegoLogExporterShareManager: No logs collected');
        return false;
      }

      /// Prepare share content
      final timestamp = DateTime.now().toString();
      final shareTitle = title ?? 'Logs_$timestamp';
      final shareContent = content ?? 'App logs collected at $timestamp';

      /// Share zip file directly
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(zipPath)],
          text: shareContent,
          subject: shareTitle,
        ),
      );

      debugPrint(
          'ZegoLogExporterShareManager: Successfully shared logs zip file');
      return true;
    } catch (e, stackTrace) {
      debugPrint('ZegoLogExporterShareManager: Error sharing logs: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    } finally {
      /// Clean up temporary files
      if (zipPath != null) {
        await _cleanup(zipPath);
      }
    }
  }

  /// Collect logs and compress into zip file
  ///
  /// [fileName] Zip file name (without extension), defaults to current timestamp
  /// [fileTypes] List of file types to collect, defaults to [ZegoLogExporterFileType.txt, ZegoLogExporterFileType.log, ZegoLogExporterFileType.zip]
  /// [directories] List of directory types to collect, defaults to 5 log directories
  /// [onProgress] Optional progress callback
  ///
  /// Returns the full path of the zip file, or null if failed
  Future<String?> _collectLogs({
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
    void Function(int processedFiles)? onProgress,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final archive = Archive();
      int processedFiles = 0;

      /// File type filtering
      final includeAllFileTypes =
          fileTypes.contains(ZegoLogExporterFileType.all);

      /// Directory type filtering
      final includeAllDirectories =
          directories.contains(ZegoLogExporterDirectoryType.all);

      void updateProgress() {
        processedFiles++;
        onProgress?.call(processedFiles);
      }

      /// Check if file matches specified type
      bool shouldIncludeFile(String fileName) {
        if (includeAllFileTypes) return true;
        for (final type in fileTypes) {
          if (fileName.endsWith(type.extension)) {
            return true;
          }
        }
        return false;
      }

      /// Check if directory matches specified type (by first-level directory name)
      /// Extract first-level directory name from relative path and check against configured directories
      bool shouldIncludeDirectory(String relativePath) {
        if (includeAllDirectories) return true;

        // Extract first-level directory name
        final firstSlashIndex = relativePath.indexOf('/');
        if (firstSlashIndex == -1) {
          // No slash means it's a root file, should not reach here
          return false;
        }
        final firstLevelDirName = relativePath.substring(0, firstSlashIndex);

        // Check if first-level directory name matches any configured directory
        for (final dir in directories) {
          if (dir.directoryName == firstLevelDirName) {
            return true;
          }
        }

        // Only print skip message once, not in the loop
        debugPrint(
            'ZegoLogExporterShareManager: Skipping Android directory (not in config): $firstLevelDirName');
        return false;
      }

      /// Check if directory name should be collected
      bool shouldIncludeDirectoryName(String dirName) {
        if (includeAllDirectories) return true;

        for (final dir in directories) {
          if (dir.directoryName == dirName) {
            return true;
          }
        }

        // Only print skip message once, not in the loop
        debugPrint(
            'ZegoLogExporterShareManager: Skipping iOS directory (not in config): $dirName');
        return false;
      }

      /// Add file to archive
      Future<void> addFileToArchive(File file, String archivePath) async {
        try {
          final bytes = await file.readAsBytes();
          final fileSize = bytes.length;
          archive.addFile(ArchiveFile(archivePath, bytes.length, bytes));
          updateProgress();
          debugPrint(
            'ZegoLogExporterShareManager: Added $archivePath (${fileSize ~/ 1024}KB)',
          );
        } catch (e) {
          debugPrint(
              'ZegoLogExporterShareManager: Error adding file ${file.path}: $e');
        }
      }

      /// Collect Android logs
      if (Platform.isAndroid) {
        debugPrint('ZegoLogExporterShareManager: Collecting Android logs...');
        final appDir = await getExternalStorageDirectory();
        if (appDir != null) {
          final filesDir = Directory(appDir.path);
          if (await filesDir.exists()) {
            // Track all discovered directories for debugging
            final Set<String> discoveredDirs = {};

            await for (final entity in filesDir.list(recursive: true)) {
              final name = entity.uri.pathSegments.last;
              final relativePath = p.relative(entity.path, from: filesDir.path);

              // Track first-level directories
              if (relativePath.contains('/')) {
                final firstLevelDir =
                    relativePath.substring(0, relativePath.indexOf('/'));
                discoveredDirs.add(firstLevelDir);
              }

              if (entity is File) {
                /// Check if file should be collected
                /// For root directory files (no '/' in path), only check file type
                /// For subdirectory files, check both directory and file type
                final isRootFile = !relativePath.contains('/');

                if (isRootFile) {
                  /// Root directory file: only check file type
                  if (shouldIncludeFile(name)) {
                    await addFileToArchive(
                        entity, 'zego_logs_android/$relativePath');
                  }
                } else {
                  /// Subdirectory file: check directory first, then file type
                  if (shouldIncludeDirectory(relativePath)) {
                    if (shouldIncludeFile(name)) {
                      await addFileToArchive(
                          entity, 'zego_logs_android/$relativePath');
                    }
                  } else {
                    debugPrint(
                        'ZegoLogExporterShareManager: Skipping Android directory: $relativePath');
                  }
                }
              }
            }

            // Print all discovered directories
            debugPrint(
                'ZegoLogExporterShareManager: Discovered Android directories: ${discoveredDirs.toList()..sort()}');
          }
        }
      }

      /// Collect iOS logs
      else if (Platform.isIOS) {
        debugPrint('ZegoLogExporterShareManager: Collecting iOS logs...');

        /// Collect logs from Application Support directory
        final appSupportDir = await getApplicationSupportDirectory();
        final logsDir = Directory('${appSupportDir.path}/Logs');
        if (await logsDir.exists()) {
          await for (final entity in logsDir.list(recursive: true)) {
            if (entity is File) {
              final name = entity.uri.pathSegments.last;

              /// Check if file type matches
              if (shouldIncludeFile(name)) {
                final relativePath =
                    p.relative(entity.path, from: logsDir.path);
                await addFileToArchive(entity, 'ios_logs/$relativePath');
              }
            }
          }
        }

        /// Collect logs from Caches directory
        final cachesDir = await getTemporaryDirectory();
        final parentDir = cachesDir.parent;
        final cachesDirPath = Directory('${parentDir.path}/Caches');

        if (await cachesDirPath.exists()) {
          /// Iterate through all first-level items under Caches
          await for (final entity in cachesDirPath.list()) {
            if (entity is File) {
              /// Root directory file in Caches: only check file type
              final fileName = entity.uri.pathSegments.last;
              if (shouldIncludeFile(fileName)) {
                final relativePath =
                    p.relative(entity.path, from: cachesDirPath.path);
                debugPrint(
                    'ZegoLogExporterShareManager: Processing iOS Caches root file: $fileName');
                await addFileToArchive(entity, 'zego_logs_ios/$relativePath');
              }
            } else if (entity is Directory) {
              final dirName = entity.path.split('/').last;

              /// Check if this directory should be collected (directly by directory name)
              if (shouldIncludeDirectoryName(dirName)) {
                debugPrint(
                    'ZegoLogExporterShareManager: Processing iOS Caches directory: $dirName');
                await for (final file in entity.list(recursive: true)) {
                  if (file is File) {
                    final fileName = file.uri.pathSegments.last;

                    /// Check if file type matches
                    if (shouldIncludeFile(fileName)) {
                      final relativePath =
                          p.relative(file.path, from: entity.path);
                      await addFileToArchive(
                        file,
                        'zego_logs_ios/$dirName/$relativePath',
                      );
                    }
                  }
                }
              } else {
                debugPrint(
                    'ZegoLogExporterShareManager: Skipping iOS Caches directory: $dirName');
              }
            }
          }
        }
      }

      /// Check if any logs were collected
      if (archive.isEmpty) {
        debugPrint('ZegoLogExporterShareManager: No logs found');
        return null;
      }

      /// Compress and save
      debugPrint(
        'ZegoLogExporterShareManager: Compressing ${archive.length} files...',
      );
      final encoder = ZipEncoder();
      final zipData = encoder.encode(archive);

      /// Save zip file
      final zipFileName =
          fileName ?? 'logs_${DateTime.now().millisecondsSinceEpoch}';
      final zipPath = '${tempDir.path}/$zipFileName.zip';
      final zipFile = File(zipPath);
      await zipFile.writeAsBytes(zipData);

      final zipSize = await zipFile.length();
      debugPrint(
        'ZegoLogExporterShareManager: Created zip file: $zipPath '
        '(${zipSize ~/ 1024}KB, ${archive.length} files)',
      );

      return zipPath;
    } catch (e, stackTrace) {
      debugPrint('ZegoLogExporterShareManager: Error collecting logs: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Clean up temporary files
  Future<void> _cleanup(String zipPath) async {
    try {
      /// Clean up zip file
      final zipFile = File(zipPath);
      if (await zipFile.exists()) {
        await zipFile.delete();
        debugPrint('ZegoLogExporterShareManager: Cleaned up $zipPath');
      }
    } catch (e) {
      debugPrint('ZegoLogExporterShareManager: Error during cleanup: $e');
    }
  }

  /// Manually clean up all temporary log files (optional)
  ///
  /// Clean up all temporary files created by this manager
  Future<void> cleanupAll() async {
    try {
      final tempDir = await getTemporaryDirectory();
      await for (final entity in tempDir.list()) {
        if (entity is File && entity.path.contains('logs_')) {
          try {
            await entity.delete();
            debugPrint(
                'ZegoLogExporterShareManager: Cleaned up ${entity.path}');
          } catch (e) {
            debugPrint(
                'ZegoLogExporterShareManager: Error cleaning ${entity.path}: $e');
          }
        }
      }
      debugPrint('ZegoLogExporterShareManager: Cleanup all completed');
    } catch (e) {
      debugPrint('ZegoLogExporterShareManager: Error during cleanup all: $e');
    }
  }
}
