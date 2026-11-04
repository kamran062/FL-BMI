import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bmi_health/core/monitoring/crash_reporting.dart';

/// Keeps private data out of cloud backups.
///
/// Android: allowBackup=false + data_extraction_rules.xml (manifest).
/// iOS: folders are flagged "exclude from iCloud backup" here, every launch
/// (the flag is cheap to set and survives app updates).
abstract final class BackupExclusion {
  static const _channel = MethodChannel('bmi_health/backup');

  static Future<Directory> photosDir() async =>
      Directory('${(await getApplicationSupportDirectory()).path}/progress_photos');

  static Future<void> apply() async {
    if (!Platform.isIOS) return;
    try {
      for (final path in [await getDatabasesPath(), (await photosDir()).path]) {
        await _channel.invokeMethod<bool>('exclude', path);
      }
    } catch (e, st) {
      reportError(e, st, reason: 'backup-exclusion');
    }
  }
}
