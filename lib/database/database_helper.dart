import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bmi_entry.dart';
import '../models/goal.dart';

class DatabaseHelper {
  static const _dbName = 'bmi_health.db';
  static const _dbVersion = 1;

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get db async => _db ??= await _initDb();

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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
    await database.update('goals', {'active': 0}); // deactivate old
    return database.insert('goals', goal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
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
