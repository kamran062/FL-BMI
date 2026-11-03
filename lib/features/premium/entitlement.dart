import 'dart:convert';
import 'dart:io';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;

/// Premium is on only with a valid entitlement signed by our server
/// (functions/src/entitlement.js). The app ships the public key, so the
/// entitlement cannot be forged or edited on the device.
class Entitlement {
  final bool active;
  final String productId;
  final DateTime expiresAt; // subscription end (lifetime: year 2100)
  final DateTime validUntil; // when the app must re-check with the server

  const Entitlement({
    required this.active,
    required this.productId,
    required this.expiresAt,
    required this.validUntil,
  });

  bool isActive(DateTime now) =>
      active && now.isBefore(expiresAt) && now.isBefore(validUntil);

  /// Verifies [jwt] with [publicKeyPem]; null if forged, malformed or for
  /// another issuer. Expiry is checked separately so a lapsed token can
  /// still tell us which product to re-verify.
  static Entitlement? parse(String jwt, String publicKeyPem) {
    try {
      final verified = JWT.verify(
        jwt,
        ECPublicKey(publicKeyPem),
        checkExpiresIn: false,
        issuer: 'bmi-health',
      );
      final p = verified.payload as Map<String, dynamic>;
      return Entitlement(
        active: p['active'] == true,
        productId: p['productId'] as String,
        expiresAt: DateTime.fromMillisecondsSinceEpoch((p['expiresAt'] as num).toInt()),
        validUntil: DateTime.fromMillisecondsSinceEpoch((p['exp'] as num).toInt() * 1000),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Talks to the verifyPurchase function.
abstract class PurchaseVerifier {
  /// Returns the signed entitlement JWT, or throws on network/server error.
  Future<String> verify({
    required String productId,
    required String token,
  });
}

class HttpPurchaseVerifier implements PurchaseVerifier {
  HttpPurchaseVerifier(this.url, {http.Client? client})
      : _client = client ?? http.Client();

  final String url;
  final http.Client _client;

  @override
  Future<String> verify({required String productId, required String token}) async {
    final res = await _client
        .post(
          Uri.parse(url),
          headers: {'content-type': 'application/json'},
          body: jsonEncode({
            'platform': Platform.isIOS ? 'ios' : 'android',
            'productId': productId,
            'token': token,
          }),
        )
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) {
      throw HttpException('verifyPurchase ${res.statusCode}');
    }
    return (jsonDecode(res.body) as Map<String, dynamic>)['entitlement'] as String;
  }
}
