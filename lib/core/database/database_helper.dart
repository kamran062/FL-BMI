import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bmi_health/features/body/bmi/domain/bmi_entry.dart';
import 'package:bmi_health/features/body/bmi/domain/goal.dart';
import 'package:bmi_health/features/body/metrics/domain/body_metrics.dart';
import 'package:bmi_health/features/fuel/domain/nutrition.dart';
import 'package:bmi_health/features/cycle/domain/cycle.dart';
import 'package:bmi_health/features/movement/domain/timeline.dart';
import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:bmi_health/features/train/workouts/domain/workout.dart';

class DatabaseHelper {
  static const _dbName = 'bmi_health.db';

  /// Current schema version. Must equal 1 + the number of [_migrations].
  static const schemaVersion = 10;

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
    // 4 → 5: workout tracker
    (db) async {
      await db.execute('''
        CREATE TABLE workouts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL DEFAULT '',
          started_at INTEGER NOT NULL,
          finished_at INTEGER
        )
      ''');
      await db.execute('''
        CREATE TABLE workout_sets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          workout_id INTEGER NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
          exercise_id TEXT NOT NULL,
          exercise_order INTEGER NOT NULL,
          weight_kg REAL NOT NULL DEFAULT 0,
          reps INTEGER NOT NULL DEFAULT 0,
          done INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute(
          'CREATE INDEX idx_workout_sets_workout ON workout_sets(workout_id)');
      await db.execute('''
        CREATE TABLE routines (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          exercise_ids TEXT NOT NULL
        )
      ''');
    },
    // 5 → 6: Fuel (quick calorie log + water)
    (db) async {
      await db.execute('''
        CREATE TABLE food_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date INTEGER NOT NULL,
          name TEXT NOT NULL DEFAULT '',
          kcal INTEGER NOT NULL,
          protein_g REAL
        )
      ''');
      await db.execute('CREATE INDEX idx_food_logs_date ON food_logs(date)');
      await db.execute('''
        CREATE TABLE water_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date INTEGER NOT NULL,
          ml INTEGER NOT NULL
        )
      ''');
      await db.execute('CREATE INDEX idx_water_logs_date ON water_logs(date)');
    },
    // 6 → 7: movement timeline (location history stays on the device)
    (db) async {
      await db.execute('''
        CREATE TABLE location_points (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          time INTEGER NOT NULL,
          lat REAL NOT NULL,
          lng REAL NOT NULL,
          accuracy REAL NOT NULL DEFAULT 0
        )
      ''');
      await db.execute(
          'CREATE INDEX idx_location_points_time ON location_points(time)');
      await db.execute('''
        CREATE TABLE places (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          lat REAL NOT NULL,
          lng REAL NOT NULL,
          radius_m REAL NOT NULL DEFAULT 120,
          is_gym INTEGER NOT NULL DEFAULT 0
        )
      ''');
    },
    // 7 → 8: cycle tracking (opt-in; deleted with one tap)
    (db) async {
      await db.execute('''
        CREATE TABLE periods (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          start TEXT NOT NULL,
          "end" TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE cycle_symptoms (
          date TEXT PRIMARY KEY,
          symptoms TEXT NOT NULL
        )
      ''');
    },
    // 8 → 9: progress photos (encrypted files; this table holds metadata)
    (db) async {
      await db.execute('''
        CREATE TABLE progress_photos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date INTEGER NOT NULL,
          file TEXT NOT NULL,
          weight_kg REAL
        )
      ''');
    },
    // 9 → 10: Home Challenges progress (one row per completed day)
    (db) async {
      await db.execute('''
        CREATE TABLE challenge_progress (
          challenge TEXT NOT NULL,
          day INTEGER NOT NULL,
          completed_at INTEGER NOT NULL,
          PRIMARY KEY (challenge, day)
        )
      ''');
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

  // ── Workouts ─────────────────────────────────────────────────

  Future<int> insertWorkout(Workout w) async =>
      (await db).insert('workouts', w.toMap());

  Future<void> updateWorkout(Workout w) async => (await db)
      .update('workouts', w.toMap(), where: 'id = ?', whereArgs: [w.id]);

  /// Deletes the workout and its sets.
  Future<void> deleteWorkout(int id) async {
    final database = await db;
    await database.transaction((txn) async {
      await txn.delete('workout_sets', where: 'workout_id = ?', whereArgs: [id]);
      await txn.delete('workouts', where: 'id = ?', whereArgs: [id]);
    });
  }

  /// The unfinished workout, if the app was closed during one.
  Future<Workout?> getActiveWorkout() async {
    final rows = await (await db).query('workouts',
        where: 'finished_at IS NULL', orderBy: 'started_at DESC', limit: 1);
    return rows.isEmpty ? null : Workout.fromMap(rows.first);
  }

  /// Finished workouts, newest first.
  Future<List<Workout>> getFinishedWorkouts() async {
    final rows = await (await db).query('workouts',
        where: 'finished_at IS NOT NULL', orderBy: 'started_at DESC');
    return rows.map(Workout.fromMap).toList();
  }

  Future<List<WorkoutSet>> getSets(int workoutId) async {
    final rows = await (await db).query('workout_sets',
        where: 'workout_id = ?', whereArgs: [workoutId],
        orderBy: 'exercise_order ASC, id ASC');
    return rows.map(WorkoutSet.fromMap).toList();
  }

  /// Every completed set of finished workouts (for PRs and "previous").
  Future<List<WorkoutSet>> getAllFinishedSets() async {
    final rows = await (await db).rawQuery('''
      SELECT s.* FROM workout_sets s
      JOIN workouts w ON w.id = s.workout_id
      WHERE w.finished_at IS NOT NULL AND s.done = 1
      ORDER BY w.started_at ASC, s.id ASC
    ''');
    return rows.map(WorkoutSet.fromMap).toList();
  }

  Future<int> insertSet(WorkoutSet s) async =>
      (await db).insert('workout_sets', s.toMap());

  Future<void> updateSet(WorkoutSet s) async => (await db)
      .update('workout_sets', s.toMap(), where: 'id = ?', whereArgs: [s.id]);

  Future<void> deleteSet(int id) async =>
      (await db).delete('workout_sets', where: 'id = ?', whereArgs: [id]);

  Future<List<Routine>> getRoutines() async {
    final rows = await (await db).query('routines', orderBy: 'name COLLATE NOCASE');
    return rows.map(Routine.fromMap).toList();
  }

  Future<int> insertRoutine(Routine r) async =>
      (await db).insert('routines', r.toMap());

  Future<void> deleteRoutine(int id) async =>
      (await db).delete('routines', where: 'id = ?', whereArgs: [id]);

  // ── Fuel ─────────────────────────────────────────────────────

  Future<List<FoodLog>> getFoodSince(DateTime from) async {
    final rows = await (await db).query('food_logs',
        where: 'date >= ?', whereArgs: [from.millisecondsSinceEpoch],
        orderBy: 'date ASC');
    return rows.map(FoodLog.fromMap).toList();
  }

  Future<int> insertFood(FoodLog f) async =>
      (await db).insert('food_logs', f.toMap());

  Future<void> deleteFood(int id) async =>
      (await db).delete('food_logs', where: 'id = ?', whereArgs: [id]);

  Future<int> getWaterSince(DateTime from) async {
    final rows = await (await db).rawQuery(
        'SELECT COALESCE(SUM(ml), 0) AS total FROM water_logs WHERE date >= ?',
        [from.millisecondsSinceEpoch]);
    return (rows.first['total'] as num).toInt();
  }

  Future<void> insertWater(DateTime at, int ml) async => (await db)
      .insert('water_logs', {'date': at.millisecondsSinceEpoch, 'ml': ml});

  // ── Movement ─────────────────────────────────────────────────

  Future<void> insertPoint(LocationPoint p) async =>
      (await db).insert('location_points', p.toMap());

  Future<List<LocationPoint>> getPoints(DateTime from, DateTime to) async {
    final rows = await (await db).query('location_points',
        where: 'time >= ? AND time < ?',
        whereArgs: [from.millisecondsSinceEpoch, to.millisecondsSinceEpoch],
        orderBy: 'time ASC');
    return rows.map(LocationPoint.fromMap).toList();
  }

  Future<void> deletePoints(DateTime from, DateTime to) async =>
      (await db).delete('location_points',
          where: 'time >= ? AND time < ?',
          whereArgs: [from.millisecondsSinceEpoch, to.millisecondsSinceEpoch]);

  Future<void> deleteAllPoints() async => (await db).delete('location_points');

  Future<List<Place>> getPlaces() async =>
      (await (await db).query('places', orderBy: 'name')).map(Place.fromMap).toList();

  Future<int> insertPlace(Place p) async => (await db).insert('places', p.toMap());

  Future<void> deletePlace(int id) async =>
      (await db).delete('places', where: 'id = ?', whereArgs: [id]);

  // ── Cycle ────────────────────────────────────────────────────

  Future<List<Period>> getPeriods() async =>
      (await (await db).query('periods', orderBy: 'start')).map(Period.fromMap).toList();

  Future<int> insertPeriod(Period p) async => (await db).insert('periods', p.toMap());

  Future<void> updatePeriod(Period p) async => (await db)
      .update('periods', p.toMap(), where: 'id = ?', whereArgs: [p.id]);

  Future<void> deletePeriod(int id) async =>
      (await db).delete('periods', where: 'id = ?', whereArgs: [id]);

  Future<Map<String, String>> getCycleSymptoms() async => {
        for (final r in await (await db).query('cycle_symptoms'))
          r['date'] as String: r['symptoms'] as String
      };

  Future<void> setCycleSymptoms(String date, String symptoms) async {
    final d = await db;
    if (symptoms.isEmpty) {
      await d.delete('cycle_symptoms', where: 'date = ?', whereArgs: [date]);
    } else {
      await d.insert('cycle_symptoms', {'date': date, 'symptoms': symptoms},
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  /// Removes every cycle record (one-tap delete).
  Future<void> deleteAllCycleData() async {
    final d = await db;
    await d.delete('periods');
    await d.delete('cycle_symptoms');
  }

  // ── Progress photos ──────────────────────────────────────────

  Future<List<Map<String, Object?>>> getProgressPhotos() async =>
      (await db).query('progress_photos', orderBy: 'date ASC');

  Future<int> insertProgressPhoto(DateTime date, String file, double? weightKg) async =>
      (await db).insert('progress_photos', {
        'date': date.millisecondsSinceEpoch,
        'file': file,
        'weight_kg': weightKg,
      });

  Future<void> deleteProgressPhoto(int id) async =>
      (await db).delete('progress_photos', where: 'id = ?', whereArgs: [id]);

  // ── Home Challenges ──────────────────────────────────────────

  /// challenge key → completed day → when.
  Future<Map<String, Map<int, DateTime>>> getChallengeProgress() async {
    final out = <String, Map<int, DateTime>>{};
    for (final r in await (await db).query('challenge_progress')) {
      out.putIfAbsent(r['challenge'] as String, () => {})[r['day'] as int] =
          DateTime.fromMillisecondsSinceEpoch(r['completed_at'] as int);
    }
    return out;
  }

  Future<void> completeChallengeDay(String challenge, int day, DateTime at) async =>
      (await db).insert('challenge_progress',
          {'challenge': challenge, 'day': day, 'completed_at': at.millisecondsSinceEpoch},
          conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> resetChallenge(String challenge) async => (await db)
      .delete('challenge_progress', where: 'challenge = ?', whereArgs: [challenge]);

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
