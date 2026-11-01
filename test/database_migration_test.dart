import 'dart:io';

import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/body/bmi/domain/goal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('bmi_db_test'));
  tearDown(() => tmp.deleteSync(recursive: true));

  /// Builds a database exactly as app version 1.0.x left it on a user's phone.
  Future<String> createV1Database() async {
    final path = p.join(tmp.path, 'v1.db');
    final db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) => DatabaseHelper.createV1Schema(db),
      ),
    );
    await db.insert('bmi_entries', {
      'weight': 70.5, 'height': 172.0, 'bmi': 23.8, 'age': 30,
      'gender': 'f', 'weight_unit': 'kg', 'height_unit': 'cm',
      'date': DateTime(2026, 5, 17).millisecondsSinceEpoch,
    });
    await db.insert('bmi_entries', {
      'weight': 69.0, 'height': 172.0, 'bmi': 23.3, 'age': 30,
      'gender': 'f', 'weight_unit': 'kg', 'height_unit': 'cm',
      'date': DateTime(2026, 6, 1).millisecondsSinceEpoch,
    });
    await db.insert('goals', {
      'current_weight': 70.5, 'target_weight': 65.0, 'weeks': 10,
      'start_date': DateTime(2026, 5, 17).millisecondsSinceEpoch, 'active': 1,
    });
    await db.close();
    return path;
  }

  Future<List<Map<String, Object?>>> schemaOf(String path) async {
    final db = await factory.openDatabase(path);
    final rows = await db.rawQuery(
      "SELECT type, name, sql FROM sqlite_master "
      "WHERE name NOT LIKE 'sqlite_%' ORDER BY type, name",
    );
    await db.close();
    return rows;
  }

  test('upgrading a v1 database keeps all history and goals', () async {
    final path = await createV1Database();
    final helper = DatabaseHelper.test(factory, path);

    final entries = await helper.getEntries();
    expect(entries, hasLength(2));
    expect(entries.first.date, DateTime(2026, 6, 1)); // newest first
    expect(entries.last.weight, 70.5);

    final goal = await helper.getActiveGoal();
    expect(goal?.targetWeight, 65.0);

    final version = await (await helper.db).getVersion();
    expect(version, DatabaseHelper.schemaVersion);
    await helper.close();
  });

  test('fresh install and upgraded install end with the same schema', () async {
    final upgradedPath = await createV1Database();
    final upgraded = DatabaseHelper.test(factory, upgradedPath);
    await upgraded.db;
    await upgraded.close();

    final freshPath = p.join(tmp.path, 'fresh.db');
    final fresh = DatabaseHelper.test(factory, freshPath);
    await fresh.db;
    await fresh.close();

    expect(await schemaOf(freshPath), await schemaOf(upgradedPath));
  });

  test('migration 2 adds the history date index', () async {
    final path = await createV1Database();
    final helper = DatabaseHelper.test(factory, path);
    final rows = await (await helper.db).rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'index' AND name = ?",
      ['idx_bmi_entries_date'],
    );
    expect(rows, hasLength(1));
    await helper.close();
  });

  test('saving a goal leaves exactly one active goal', () async {
    final helper = DatabaseHelper.test(factory, p.join(tmp.path, 'goals.db'));
    Goal goal(double target) => Goal(
          currentWeight: 80, targetWeight: target, weeks: 8,
          startDate: DateTime(2026, 11, 1),
        );
    await helper.insertGoal(goal(75));
    await helper.insertGoal(goal(72));

    final active = await (await helper.db)
        .query('goals', where: 'active = 1');
    expect(active, hasLength(1));
    expect((await helper.getActiveGoal())?.targetWeight, 72);
    await helper.close();
  });
}
