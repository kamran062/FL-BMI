import 'dart:io';
import 'dart:typed_data';

import 'package:bmi_health/features/body/photos/photo_vault.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryKeys implements KeyStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String v) async => value = v;
}

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('vault'));
  tearDown(() => dir.deleteSync(recursive: true));

  // A fake JPEG: header bytes plus a recognisable payload.
  final photo = Uint8List.fromList([0xFF, 0xD8, 0xFF, ...'my body photo'.codeUnits]);

  test('round-trips; the file on disk is not the photo', () async {
    final keys = MemoryKeys();
    final vault = PhotoVault(dir, keys: keys);
    final name = await vault.save(photo);

    final onDisk = File('${dir.path}/$name').readAsBytesSync();
    expect(onDisk.sublist(0, 3), isNot([0xFF, 0xD8, 0xFF])); // not a JPEG
    expect(String.fromCharCodes(onDisk).contains('my body photo'), isFalse);
    expect(await vault.load(name), photo);
    expect(keys.value, isNotNull); // key created once, in the key store
  });

  test('a different key cannot read it', () async {
    final name = await PhotoVault(dir, keys: MemoryKeys()).save(photo);
    expect(() => PhotoVault(dir, keys: MemoryKeys()).load(name), throwsA(anything));
  });

  test('tampered files are rejected', () async {
    final vault = PhotoVault(dir, keys: MemoryKeys());
    final name = await vault.save(photo);
    final f = File('${dir.path}/$name');
    final b = f.readAsBytesSync()..[20] ^= 0x01;
    f.writeAsBytesSync(b);
    expect(() => vault.load(name), throwsA(anything));
  });

  test('delete removes the file from disk', () async {
    final vault = PhotoVault(dir, keys: MemoryKeys());
    final name = await vault.save(photo);
    await vault.delete(name);
    expect(File('${dir.path}/$name').existsSync(), isFalse);
    expect(dir.listSync(), isEmpty);
  });
}
