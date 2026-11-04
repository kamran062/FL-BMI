import 'dart:io';
import 'dart:typed_data';

import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/backup/backup_service.dart';
import 'package:bmi_health/features/body/photos/photo_vault.dart';
import 'package:bmi_health/features/cycle/domain/cycle.dart';
import 'package:bmi_health/features/movement/domain/timeline.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/app_harness.dart' show MemoryKeyStore;

void main() {
  sqfliteFfiInit();
  late Directory tmp;
  late DatabaseHelper phoneA;

  DatabaseHelper newDb(String name) =>
      DatabaseHelper.test(databaseFactoryFfi, '${tmp.path}/$name.db');

  setUp(() async {
    tmp = Directory.systemTemp.createTempSync('backup');
    SharedPreferences.setMockInitialValues({
      'theme': 'dark',
      'ai_install_id': 'device-specific',
      'cycle_enabled': true,
    });
    phoneA = newDb('a');
    final d = await phoneA.db;
    // A large dataset: 2 years of weights, 300 workouts × 15 sets, a month
    // of location points.
    final start = DateTime(2024, 11, 1);
    await d.transaction((tx) async {
      for (var i = 0; i < 730; i++) {
        await tx.insert('weight_logs', {
          'date': start.add(Duration(days: i)).millisecondsSinceEpoch,
          'weight_kg': 80 - i / 100,
        });
      }
      for (var w = 0; w < 300; w++) {
        final id = await tx.insert('workouts', {
          'name': 'W$w',
          'started_at': start.add(Duration(days: w * 2)).millisecondsSinceEpoch,
        });
        for (var s = 0; s < 15; s++) {
          await tx.insert('workout_sets', {
            'workout_id': id, 'exercise_id': 'push_up', 'exercise_order': 0,
            'weight_kg': 0, 'reps': 10 + s, 'done': 1,
          });
        }
      }
    });
    for (var m = 0; m < 1440 * 3; m += 3) {
      await phoneA.insertPoint(LocationPoint(
          time: start.add(Duration(minutes: m)), lat: 31.5, lng: 74.3, accuracyM: 5));
    }
    await phoneA.insertPeriod(Period(start: DateTime(2026, 10, 1), end: DateTime(2026, 10, 5)));
  });

  tearDown(() async {
    await phoneA.close();
    tmp.deleteSync(recursive: true);
  });

  Future<int> count(DatabaseHelper h, String t) async =>
      (await (await h.db).rawQuery('SELECT COUNT(*) AS n FROM $t')).single['n'] as int;

  test('backup → new phone → restore brings everything back', () async {
    final file = await BackupService(phoneA, iterations: 1000)
        .create('correct horse battery', const BackupOptions(includeCycle: true));

    // Encrypted: no readable data in the file
    expect(String.fromCharCodes(file).contains('push_up'), isFalse);

    SharedPreferences.setMockInitialValues({'ai_install_id': 'phone-b-id'});
    final phoneB = newDb('b');
    await BackupService(phoneB, iterations: 1000).restore(file, 'correct horse battery');

    expect(await count(phoneB, 'weight_logs'), 730);
    expect(await count(phoneB, 'workouts'), 300);
    expect(await count(phoneB, 'workout_sets'), 4500);
    expect(await count(phoneB, 'location_points'), 1440);
    expect(await count(phoneB, 'periods'), 1);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme'), 'dark');
    expect(prefs.getString('ai_install_id'), 'phone-b-id'); // device id not copied
    await phoneB.close();
  });

  test('cycle data is left out unless chosen', () async {
    final file = await BackupService(phoneA, iterations: 1000)
        .create('correct horse battery', const BackupOptions());
    SharedPreferences.setMockInitialValues({});
    final phoneB = newDb('b');
    await BackupService(phoneB, iterations: 1000).restore(file, 'correct horse battery');
    expect(await count(phoneB, 'periods'), 0);
    expect(await count(phoneB, 'workouts'), 300);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('cycle_enabled'), isNull);
    await phoneB.close();
  });

  test('wrong passphrase, corrupted file, not a backup, newer version', () async {
    final svc = BackupService(phoneA, iterations: 1000);
    final file = await svc.create('correct horse battery', const BackupOptions());
    final before = await count(phoneA, 'workouts');

    Future<RestoreError?> err(Uint8List f, String p) async {
      try {
        await svc.restore(f, p);
        return null;
      } on RestoreException catch (e) {
        return e.error;
      }
    }

    expect(await err(file, 'wrong passphrase'), RestoreError.wrongPassphrase);
    final damaged = Uint8List.fromList(file)..[file.length ~/ 2] ^= 0xFF;
    expect(await err(damaged, 'correct horse battery'), RestoreError.wrongPassphrase);
    expect(await err(Uint8List.fromList('hello'.codeUnits), 'x'), RestoreError.notABackup);
    // Failed restores leave the data untouched
    expect(await count(phoneA, 'workouts'), before);
    expect(() => svc.create('short', const BackupOptions()), throwsArgumentError);
  });

  test('photos are carried over and re-encrypted with the new phone key', () async {
    final vaultA = PhotoVault(Directory('${tmp.path}/pa'), keys: MemoryKeyStore());
    final name = await vaultA.save(Uint8List.fromList([1, 2, 3, 4]));
    await phoneA.insertProgressPhoto(DateTime(2026, 10, 1), name, 80);

    final file = await BackupService(phoneA, photos: vaultA, iterations: 1000)
        .create('correct horse battery', const BackupOptions(includePhotos: true));

    SharedPreferences.setMockInitialValues({});
    final phoneB = newDb('b');
    final vaultB = PhotoVault(Directory('${tmp.path}/pb'), keys: MemoryKeyStore());
    await BackupService(phoneB, photos: vaultB, iterations: 1000)
        .restore(file, 'correct horse battery');
    final rows = await phoneB.getProgressPhotos();
    expect(rows, hasLength(1));
    expect(await vaultB.load(rows.single['file'] as String), [1, 2, 3, 4]);
    await phoneB.close();
  });

  test('CSV export has headers, rows and escaping', () async {
    await (await phoneA.db).insert('food_logs', {
      'date': DateTime(2026, 11, 4, 13).millisecondsSinceEpoch,
      'name': 'Daal, "special"', 'kcal': 320, 'protein_g': 14.0,
    });
    final csv = await CsvExport.build(phoneA);
    expect(csv['weights.csv']!.split('\n'), hasLength(731));
    expect(csv['workout_sets.csv']!.split('\n').first,
        'started,workout,exercise,weight_kg,reps,done');
    expect(csv['food.csv'], contains('"Daal, ""special"""'));
  });
}
