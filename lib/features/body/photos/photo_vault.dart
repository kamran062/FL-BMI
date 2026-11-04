import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Where the photo encryption key lives (Android Keystore / iOS Keychain).
abstract class KeyStore {
  Future<String?> read();
  Future<void> write(String value);
}

class SecureKeyStore implements KeyStore {
  static const _name = 'progress_photo_key';
  final _storage = const FlutterSecureStorage();

  @override
  Future<String?> read() => _storage.read(key: _name);

  @override
  Future<void> write(String value) => _storage.write(key: _name, value: value);
}

/// Encrypts progress photos with AES-256-GCM (ROADMAP 4.6).
///
/// Files sit in the app's private folder (never the gallery), so other
/// apps and gallery apps can't see them; the key is in the platform key
/// store, so a copied file is unreadable.
class PhotoVault {
  PhotoVault(this.dir, {KeyStore? keys}) : _keys = keys ?? SecureKeyStore();

  final Directory dir;
  final KeyStore _keys;
  final _algo = AesGcm.with256bits();
  SecretKey? _key;

  Future<SecretKey> _secret() async {
    if (_key != null) return _key!;
    var stored = await _keys.read();
    if (stored == null) {
      final rnd = Random.secure();
      stored = base64Encode(List<int>.generate(32, (_) => rnd.nextInt(256)));
      await _keys.write(stored);
    }
    return _key = SecretKey(base64Decode(stored));
  }

  /// Encrypts [bytes] to a new file; returns its name.
  Future<String> save(Uint8List bytes) async {
    final box = await _algo.encrypt(bytes, secretKey: await _secret());
    await dir.create(recursive: true);
    final name = '${DateTime.now().microsecondsSinceEpoch}.enc';
    await File('${dir.path}/$name').writeAsBytes(box.concatenation(), flush: true);
    return name;
  }

  /// Decrypts a stored photo. Throws if the file was altered.
  Future<Uint8List> load(String name) async {
    final data = await File('${dir.path}/$name').readAsBytes();
    final box = SecretBox.fromConcatenation(data,
        nonceLength: _algo.nonceLength, macLength: _algo.macAlgorithm.macLength);
    return Uint8List.fromList(await _algo.decrypt(box, secretKey: await _secret()));
  }

  /// Removes the file from disk.
  Future<void> delete(String name) async {
    final f = File('${dir.path}/$name');
    if (await f.exists()) await f.delete();
  }
}
