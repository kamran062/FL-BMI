import 'dart:io';

import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/movement/domain/timeline.dart';
import 'package:bmi_health/features/movement/movement_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test('timeline follows today across midnight (found on device)', () async {
    SharedPreferences.setMockInitialValues({});
    final tmp = Directory.systemTemp.createTempSync('move_test');
    final db = DatabaseHelper.test(databaseFactoryFfi, '${tmp.path}/m.db');
    var now = DateTime(2026, 11, 3, 23, 50);
    final m = MovementProvider(db, clock: () => now);
    await m.load();

    // Home 23:50–23:58 yesterday, then a place 00:05–00:15 today
    for (var i = 0; i <= 8; i += 2) {
      await db.insertPoint(LocationPoint(
          time: DateTime(2026, 11, 3, 23, 50 + i), lat: 31.50, lng: 74.30, accuracyM: 5));
    }
    for (var i = 5; i <= 15; i += 2) {
      await db.insertPoint(LocationPoint(
          time: DateTime(2026, 11, 4, 0, i), lat: 31.51, lng: 74.30, accuracyM: 5));
    }

    now = DateTime(2026, 11, 4, 0, 20);
    await m.refresh(); // app resumed after midnight
    expect(m.day, DateTime(2026, 11, 4));
    expect(m.visits.single.start, DateTime(2026, 11, 4, 0, 5));

    // Looking at a past day stays on that day
    await m.showDay(DateTime(2026, 11, 3));
    expect(m.visits.single.start, DateTime(2026, 11, 3, 23, 50));

    await db.close();
    tmp.deleteSync(recursive: true);
  });
}
