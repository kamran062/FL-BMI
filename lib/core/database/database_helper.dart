import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bmi_health/features/body/bmi/domain/bmi_entry.dart';
import 'package:bmi_health/features/body/bmi/domain/goal.dart';
import 'package:bmi_health/features/body/metrics/domain/body_metrics.dart';
import 'package:bmi_health/features/profile/domain/user_profile.dart';

class DatabaseHelper {
  static const _dbName = 'bmi_health.db';

  /// Current schema version. Must equal 1 + the number of [_migrations].
  static const schemaVersion = 4;

  /// Ordered schema migrations: `_migrations[i]` upgrades version i+1 → i+2.
  ///
  /// Rules:
  /// - Never edit or remove a migration that has shipped — append a new one
  ///   and bump [schemaVersion].
  /// - Every migration needs a case in test/database_migration_test.dart.
  static final List<Future<void> Function(Database db)> _migrations = [
    // 1 → 2: history is always read ordered by date
    (db) => db.execute(
        'CREATE INDEX IF NOT EXISTS idx_bmi_entries_date ON bmi_entries(date)'),
    // 2 → 3: profile moves from SharedPreferences into the database
    // (single row, id = 1); ProfileRepository imports the old values.
    (db) => db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        name TEXT NOT NULL DEFAULT '',
        height REAL NOT NULL,
        height_unit TEXT NOT NULL,
        weight REAL NOT NULL,
        weight_unit TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        demonstrator_pref TEXT NOT NULL DEFAULT 'auto',
        formula_basis TEXT NOT NULL DEFAULT 'female',
        goal TEXT,
        experience TEXT,
        equipment TEXT,
        days_per_week INTEGER NOT NULL DEFAULT 3,
        cycle_tracking INTEGER NOT NULL DEFAULT 0,
        completed INTEGER NOT NULL DEFAULT 0
      )
    '''),
    // 3 → 4: Body module. Weight history starts from every saved BMI entry,
    // so existing users see their past weights straight away.
    (db) async {
      await db.execute('''
        CREATE TABLE weight_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date INTEGER NOT NULL,
          weight_kg REAL NOT NULL
        )
      ''');
      await db.execute(
          'CREATE INDEX idx_weight_logs_date ON weight_logs(date)');
      await db.execute(
          'INSERT INTO weight_logs (date, weight_kg) '
          'SELECT date, weight FROM bmi_entries');
      await db.execute('''
        CREATE TABLE measurements (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date INTEGER NOT NULL,
          neck REAL, chest REAL, waist REAL,
          hips REAL, arm REAL, thigh REAL
        )
      ''');
      await db.execute(
          'CREATE INDEX idx_measurements_date ON measurements(date)');
    },
  ];

  DatabaseHelper._(this._factory, this._path);
  static final DatabaseHelper instance = DatabaseHelper._(null, null);

  /// Opens the database at [path] with [factory] (e.g. sqflite_common_ffi).
  @visibleForTesting
  DatabaseHelper.test(DatabaseFactory factory, String path)
      : this._(factory, path);

  final DatabaseFactory? _factory;
  final String? _path;
  Database? _db;

  Future<Database> get db async => _db ??= await _initDb();

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<Database> _initDb() async {
    final factory = _factory ?? databaseFactory;
    final path = _path ?? join(await getDatabasesPath(), _dbName);
    assert(schemaVersion == _migrations.length + 1);
    return factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  // Fresh installs build the original v1 schema, then run every migration,
  // so new and upgraded users always end up with identical schemas.
  Future<void> _onCreate(Database db, int version) async {
    await createV1Schema(db);
    await _migrate(db, 1, version);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) =>
      _migrate(db, oldVersion, newVersion);

  static Future<void> _migrate(Database db, int from, int to) async {
    for (var v = from; v < to; v++) {
      await _migrations[v - 1](db);
    }
  }

  /// The schema shipped in app version 1.0.x. Frozen — do not change.
  @visibleForTesting
  static Future<void> createV1Schema(Database db) async {
    await db.execute('''
      CREATE TABLE bmi_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        bmi REAL NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        weight_unit TEXT NOT NULL,
        height_unit TEXT NOT NULL,
        date INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        current_weight REAL NOT NULL,
        target_weight REAL NOT NULL,
        weeks INTEGER NOT NULL,
        start_date INTEGER NOT NULL,
        active INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  // ── Profile ──────────────────────────────────────────────────

  Future<UserProfile?> getProfile() async {
    final database = await db;
    final rows = await database.query('profile', where: 'id = 1');
    return rows.isEmpty ? null : UserProfile.fromMap(rows.first);
  }

  Future<void> saveProfile(UserProfile profile) async {
    final database = await db;
    await database.insert('profile', {'id': 1, ...profile.toMap()},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ── Weight logs & measurements ───────────────────────────────

  /// Oldest first (chart order).
  Future<List<WeightLog>> getWeightLogs() async {
    final database = await db;
    final rows = await database.query('weight_logs', orderBy: 'date ASC');
    return rows.map(WeightLog.fromMap).toList();
  }

  Future<int> insertWeightLog(WeightLog log) async {
    final database = await db;
    return database.insert('weight_logs', log.toMap());
  }

  Future<void> deleteWeightLog(int id) async {
    final database = await db;
    await database.delete('weight_logs', where: 'id = ?', whereArgs: [id]);
  }

  /// Newest first.
  Future<List<Measurement>> getMeasurements() async {
    final database = await db;
    final rows = await database.query('measurements', orderBy: 'date DESC');
    return rows.map(Measurement.fromMap).toList();
  }

  Future<int> insertMeasurement(Measurement m) async {
    final database = await db;
    return database.insert('measurements', m.toMap());
  }

  Future<void> deleteMeasurement(int id) async {
    final database = await db;
    await database.delete('measurements', where: 'id = ?', whereArgs: [id]);
  }

  // ── BMI Entries ──────────────────────────────────────────────

  Future<int> insertEntry(BmiEntry entry) async {
    final database = await db;
    return database.insert('bmi_entries', entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<BmiEntry>> getEntries() async {
    final database = await db;
    final rows = await database.query(
      'bmi_entries',
      orderBy: 'date DESC',
    );
    return rows.map(BmiEntry.fromMap).toList();
  }

  Future<void> deleteEntry(int id) async {
    final database = await db;
    await database.delete('bmi_entries', where: 'id = ?', whereArgs: [id]);
  }

  // ── Goals ────────────────────────────────────────────────────

  Future<int> insertGoal(Goal goal) async {
    final database = await db;
    // One transaction, so a crash can never leave zero active goals.
    return database.transaction((txn) async {
      await txn.update('goals', {'active': 0}); // deactivate old
      return txn.insert('goals', goal.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<Goal?> getActiveGoal() async {
    final database = await db;
    final rows = await database.query(
      'goals',
      where: 'active = 1',
      orderBy: 'start_date DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Goal.fromMap(rows.first);
  }

  Future<void> deactivateGoal() async {
    final database = await db;
    await database.update('goals', {'active': 0});
  }
}
