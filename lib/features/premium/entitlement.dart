import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Premium as last confirmed by the store, kept on the device so it works
/// offline. There is no server: the store's purchase data is trusted as the
/// app receives it (see PurchaseService).
class Entitlement {
  final String productId;
  final DateTime expiresAt; // lifetime: year 2100

  const Entitlement({required this.productId, required this.expiresAt});

  bool isActive(DateTime now) => now.isBefore(expiresAt);

  String encode() => jsonEncode({
        'productId': productId,
        'expiresAt': expiresAt.millisecondsSinceEpoch,
      });

  /// Null if [raw] is missing or malformed.
  static Entitlement? decode(String? raw) {
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return Entitlement(
        productId: m['productId'] as String,
        expiresAt: DateTime.fromMillisecondsSinceEpoch((m['expiresAt'] as num).toInt()),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Where the entitlement is saved: Keystore / Keychain-backed storage, not
/// plain preferences, so it isn't a one-line edit on the device.
abstract class EntitlementStore {
  Future<String?> read();
  Future<void> write(String? value);
}

class SecureEntitlementStore implements EntitlementStore {
  static const _key = 'premium_entitlement_v2';
  final _storage = const FlutterSecureStorage();

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String? value) =>
      value == null ? _storage.delete(key: _key) : _storage.write(key: _key, value: value);
}

class MemoryEntitlementStore implements EntitlementStore {
  MemoryEntitlementStore([this.value]);
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String? v) async => value = v;
}
