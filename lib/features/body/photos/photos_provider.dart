import 'package:flutter/foundation.dart';
import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/core/monitoring/crash_reporting.dart';
import 'package:bmi_health/features/body/photos/photo_vault.dart';

class ProgressPhoto {
  final int id;
  final DateTime date;
  final String file;
  final double? weightKg;
  const ProgressPhoto(this.id, this.date, this.file, this.weightKg);
}

/// Progress photos (ROADMAP 4.6): metadata in the database, images
/// encrypted in the app's private folder.
class PhotosProvider extends ChangeNotifier {
  PhotosProvider(this._db, this._makeVault);

  final DatabaseHelper _db;
  final Future<PhotoVault> Function() _makeVault;
  Future<PhotoVault>? _vaultFuture;

  /// Created on first use (needs the app folder, and the key store only
  /// when a photo is actually saved or opened).
  Future<PhotoVault> get _vault => _vaultFuture ??= _makeVault();
  List<ProgressPhoto> _photos = [];
  final _cache = <String, Uint8List>{};

  List<ProgressPhoto> get photos => _photos;

  Future<void> load() async {
    _photos = [
      for (final r in await _db.getProgressPhotos())
        ProgressPhoto(
          r['id'] as int,
          DateTime.fromMillisecondsSinceEpoch(r['date'] as int),
          r['file'] as String,
          (r['weight_kg'] as num?)?.toDouble(),
        )
    ];
    notifyListeners();
  }

  Future<void> add(Uint8List bytes, {double? weightKg, DateTime? date}) async {
    final name = await (await _vault).save(bytes);
    await _db.insertProgressPhoto(date ?? DateTime.now(), name, weightKg);
    _cache[name] = bytes;
    await load();
  }

  /// Decrypted image, kept in memory only while the app runs.
  Future<Uint8List?> image(ProgressPhoto p) async {
    if (_cache[p.file] case final hit?) return hit;
    try {
      return _cache[p.file] = await (await _vault).load(p.file);
    } catch (e, st) {
      reportError(e, st, reason: 'photo-decrypt');
      return null;
    }
  }

  /// Deletes the database row and the file on disk.
  Future<void> delete(ProgressPhoto p) async {
    await (await _vault).delete(p.file);
    await _db.deleteProgressPhoto(p.id);
    _cache.remove(p.file);
    await load();
  }
}
