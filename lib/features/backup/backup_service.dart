import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/body/photos/photo_vault.dart';

class BackupOptions {
  final bool includeCycle;
  final bool includePhotos;
  const BackupOptions({this.includeCycle = false, this.includePhotos = false});
}

enum RestoreError { wrongPassphrase, notABackup, newerVersion }

class RestoreException implements Exception {
  final RestoreError error;
  const RestoreException(this.error);
}

/// End-to-end encrypted backup file (ROADMAP 5.3).
///
/// File = "BMIHBK1" + salt(16) + nonce(12) + AES-256-GCM(gzip(JSON)) + mac.
/// The key comes from the user's passphrase (PBKDF2-HMAC-SHA256), so only
/// someone with the passphrase can read it — not us, not Google or Apple.
class BackupService {
  BackupService(this._db, {this.photos, this.iterations = 200000});

  final DatabaseHelper _db;
  final PhotoVault? photos;

  /// PBKDF2 rounds (lowered in tests for speed).
  final int iterations;

  static const _magic = 'BMIHBK1';
  static const minPassphrase = 8;

  static const _cycleTables = {'periods', 'cycle_symptoms'};

  /// Device-specific prefs that must not move to another phone.
  static const _skipPrefs = {
    'ai_install_id', 'steps_connected', 'recovery_connected', 'tracking_enabled',
    'food_cache', 'cycle_lock',
  };

  final _aes = AesGcm.with256bits();

  Future<SecretKey> _key(String passphrase, List<int> salt) =>
      Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: iterations, bits: 256)
          .deriveKeyFromPassword(password: passphrase, nonce: salt);

  Future<List<String>> _tables(Database d) async => [
        for (final r in await d.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' "
            "AND name NOT LIKE 'sqlite_%' AND name != 'android_metadata'"))
          r['name'] as String
      ];

  Future<Uint8List> create(String passphrase, BackupOptions o) async {
    if (passphrase.length < minPassphrase) throw ArgumentError('passphrase too short');
    final d = await _db.db;
    final tables = <String, List<Map<String, Object?>>>{};
    for (final t in await _tables(d)) {
      if (!o.includeCycle && _cycleTables.contains(t)) continue;
      if (!o.includePhotos && t == 'progress_photos') continue;
      tables[t] = await d.query(t);
    }

    final prefs = await SharedPreferences.getInstance();
    final prefMap = <String, Object?>{
      for (final k in prefs.getKeys())
        if (!_skipPrefs.contains(k) && (o.includeCycle || !k.startsWith('cycle_')))
          k: prefs.get(k)
    };

    // Photos: decrypted with this phone's key, re-encrypted inside the backup.
    final photoFiles = <String, String>{};
    if (o.includePhotos && photos != null) {
      for (final r in tables['progress_photos'] ?? const []) {
        final name = r['file'] as String;
        try {
          photoFiles[name] = base64Encode(await photos!.load(name));
        } catch (_) {/* unreadable photo: skip it */}
      }
    }

    final payload = gzip.encode(utf8.encode(jsonEncode({
      'schema': DatabaseHelper.schemaVersion,
      'created': DateTime.now().toIso8601String(),
      'tables': tables,
      'prefs': prefMap,
      'photos': photoFiles,
    })));

    final rnd = Random.secure();
    final salt = List<int>.generate(16, (_) => rnd.nextInt(256));
    final box = await _aes.encrypt(payload, secretKey: await _key(passphrase, salt));
    return Uint8List.fromList([...ascii.encode(_magic), ...salt, ...box.concatenation()]);
  }

  /// Replaces this phone's data with the backup's.
  Future<void> restore(Uint8List file, String passphrase) async {
    final magic = ascii.encode(_magic);
    if (file.length < magic.length + 16 + 12 + 16 ||
        !const ListEquality().equals(file.sublist(0, magic.length), magic)) {
      throw const RestoreException(RestoreError.notABackup);
    }
    final salt = file.sublist(magic.length, magic.length + 16);
    final box = SecretBox.fromConcatenation(file.sublist(magic.length + 16),
        nonceLength: _aes.nonceLength, macLength: _aes.macAlgorithm.macLength);

    final List<int> plain;
    try {
      plain = await _aes.decrypt(box, secretKey: await _key(passphrase, salt));
    } on SecretBoxAuthenticationError {
      // Wrong passphrase and a damaged file look the same by design.
      throw const RestoreException(RestoreError.wrongPassphrase);
    }
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(utf8.decode(gzip.decode(plain))) as Map<String, dynamic>;
    } catch (_) {
      throw const RestoreException(RestoreError.notABackup);
    }
    if ((data['schema'] as int) > DatabaseHelper.schemaVersion) {
      throw const RestoreException(RestoreError.newerVersion);
    }

    final d = await _db.db;
    final tables = (data['tables'] as Map).cast<String, dynamic>();
    final photoData = (data['photos'] as Map? ?? const {}).cast<String, String>();

    // Re-encrypt photos with this phone's key before touching the database.
    final renamed = <String, String>{};
    if (photos != null) {
      for (final e in photoData.entries) {
        renamed[e.key] = await photos!.save(base64Decode(e.value));
      }
    }

    // Parents before children (workout_sets → workouts).
    final order = (await _tables(d))
      ..sort((a, b) => (a == 'workouts' ? 0 : 1).compareTo(b == 'workouts' ? 0 : 1));
    await d.transaction((tx) async {
      // Tables missing from the backup (e.g. cycle off) keep local data.
      final restored = order.where(tables.containsKey).toList();
      for (final t in restored.reversed) {
        await tx.delete(t);
      }
      for (final t in restored) {
        final cols = {
          for (final c in await tx.rawQuery('PRAGMA table_info("$t")')) c['name'] as String
        };
        for (final r in (tables[t] as List).cast<Map<String, dynamic>>()) {
          final row = {
            for (final e in r.entries)
              if (cols.contains(e.key)) e.key: e.value
          };
          if (t == 'progress_photos') {
            final f = renamed[row['file']];
            if (f == null) continue;
            row['file'] = f;
          }
          await tx.insert(t, row);
        }
      }
    });

    final prefs = await SharedPreferences.getInstance();
    for (final e in (data['prefs'] as Map).cast<String, dynamic>().entries) {
      if (_skipPrefs.contains(e.key)) continue;
      final v = e.value;
      if (v is bool) await prefs.setBool(e.key, v);
      if (v is int) await prefs.setInt(e.key, v);
      if (v is double) await prefs.setDouble(e.key, v);
      if (v is String) await prefs.setString(e.key, v);
      if (v is List) await prefs.setStringList(e.key, v.cast<String>());
    }
  }
}

class ListEquality {
  const ListEquality();
  bool equals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Plain CSV export of the main logs (unencrypted; the user chooses where
/// it goes).
abstract final class CsvExport {
  static String _csv(List<String> header, Iterable<List<Object?>> rows) {
    String cell(Object? v) {
      final s = v?.toString() ?? '';
      return s.contains(RegExp(r'[",\n]')) ? '"${s.replaceAll('"', '""')}"' : s;
    }

    return [header.map(cell).join(','), for (final r in rows) r.map(cell).join(',')]
        .join('\n');
  }

  static String _date(Object? ms) =>
      ms is int ? DateTime.fromMillisecondsSinceEpoch(ms).toIso8601String() : '';

  static Future<Map<String, String>> build(DatabaseHelper helper) async {
    final d = await helper.db;
    return {
      'weights.csv': _csv(['date', 'weight_kg'], [
        for (final r in await d.query('weight_logs', orderBy: 'date'))
          [_date(r['date']), r['weight_kg']]
      ]),
      'workout_sets.csv': _csv(['started', 'workout', 'exercise', 'weight_kg', 'reps', 'done', 'set_type', 'rpe'], [
        for (final r in await d.rawQuery(
            'SELECT w.started_at, w.name, s.exercise_id, s.weight_kg, s.reps, s.done, s.set_type, s.rpe '
            'FROM workout_sets s JOIN workouts w ON w.id = s.workout_id ORDER BY w.started_at'))
          [_date(r['started_at']), r['name'], r['exercise_id'], r['weight_kg'], r['reps'], r['done'], r['set_type'], r['rpe']]
      ]),
      'food.csv': _csv(['date', 'name', 'kcal', 'protein_g', 'carbs_g', 'fat_g'], [
        for (final r in await d.query('food_logs', orderBy: 'date'))
          [_date(r['date']), r['name'], r['kcal'], r['protein_g'], r['carbs_g'], r['fat_g']]
      ]),
    };
  }
}
