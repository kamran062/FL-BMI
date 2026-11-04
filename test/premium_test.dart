import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/features/premium/entitlement.dart';
import 'package:bmi_health/features/premium/purchase_service.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Test-only keys (generated for these tests; not used anywhere else).
const _priv = '''-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgLDOkGETOkTcIOYXK
Kb9s+mY1ikTSiLTfW+0G8wDiKEqhRANCAASc0coqDOjceUhMYogxoL0Fvt5TN6yH
KyvJEmHlSFAHQ4xtFi4lrDfnTcFauGJQgMa1U5js45Y/5yI4hEzYNk8b
-----END PRIVATE KEY-----''';
const _pub = '''-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEnNHKKgzo3HlITGKIMaC9Bb7eUzes
hysryRJh5UhQB0OMbRYuJaw3503BWrhiUIDGtVOY7OOWP+ciOIRM2DZPGw==
-----END PUBLIC KEY-----''';
const _otherPriv = '''-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgJWm2nBthFB05RamY
rRpmMT4sYqFmZ5IrkiQ31PxXV22hRANCAATqiqTnnUkvF8EAgHOdsos7p8ax6GNH
TmPgJRfIu+XRUm4n1c2K5F7rs+pQwM2YHprrEc9Jv6DhRw4ba1PWEVIZ
-----END PRIVATE KEY-----''';

final _now = DateTime.utc(2026, 11, 4);

String _sign({
  bool active = true,
  String product = kProductMonthly,
  Duration expiresIn = const Duration(days: 30),
  Duration validFor = const Duration(days: 30),
  String key = _priv,
  String issuer = 'bmi-health',
}) =>
    JWT({
      'active': active,
      'productId': product,
      'expiresAt': _now.add(expiresIn).millisecondsSinceEpoch,
      'exp': _now.add(validFor).millisecondsSinceEpoch ~/ 1000,
    }, issuer: issuer).sign(ECPrivateKey(key), algorithm: JWTAlgorithm.ES256);

class _FakeVerifier implements PurchaseVerifier {
  _FakeVerifier(this.response);
  String Function() response;
  int calls = 0;

  @override
  Future<String> verify({required String productId, required String token}) async {
    calls++;
    return response();
  }
}

void main() {
  setUpAll(() => PurchaseService.legalLinksOk = true);
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AdService.instance.premium = false;
  });

  group('Entitlement.parse', () {
    test('accepts a server-signed entitlement', () {
      final e = Entitlement.parse(_sign(), _pub)!;
      expect(e.productId, kProductMonthly);
      expect(e.isActive(_now), isTrue);
    });

    test('rejects a token signed with another key (forged)', () {
      expect(Entitlement.parse(_sign(key: _otherPriv), _pub), isNull);
    });

    test('rejects edited payloads', () {
      final parts = _sign(active: false).split('.');
      final forged = '${parts[0]}.${_sign().split('.')[1]}.${parts[2]}';
      expect(Entitlement.parse(forged, _pub), isNull);
    });

    test('rejects the wrong issuer', () {
      expect(Entitlement.parse(_sign(issuer: 'someone-else'), _pub), isNull);
    });

    test('inactive after the subscription or the check window ends', () {
      final e = Entitlement.parse(_sign(expiresIn: const Duration(days: 2)), _pub)!;
      expect(e.isActive(_now.add(const Duration(days: 1))), isTrue);
      expect(e.isActive(_now.add(const Duration(days: 3))), isFalse);
      final stale = Entitlement.parse(_sign(validFor: const Duration(days: 1)), _pub)!;
      expect(stale.isActive(_now.add(const Duration(days: 2))), isFalse);
    });
  });

  group('PurchaseService', () {
    PurchaseService service(_FakeVerifier v) =>
        PurchaseService(verifier: v, publicKey: _pub, clock: () => _now);

    test('a verified purchase unlocks premium and removes ads', () async {
      final s = service(_FakeVerifier(() => _sign()));
      await s.verify(kProductMonthly, 'purchase-token-123');
      expect(s.isPremium, isTrue);
      expect(AdService.instance.premium, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('premium_entitlement'), isNotNull);
    });

    test('a forged server response does not unlock premium', () async {
      final s = service(_FakeVerifier(() => _sign(key: _otherPriv)));
      await s.verify(kProductMonthly, 'purchase-token-123');
      expect(s.isPremium, isFalse);
      expect(s.error, isNotNull);
      expect(AdService.instance.premium, isFalse);
    });

    test('server unreachable: no premium, friendly error, retried on launch',
        () async {
      final v = _FakeVerifier(() => throw Exception('offline'));
      final s = service(v);
      SharedPreferences.setMockInitialValues({
        'premium_token': 'purchase-token-123',
        'premium_product': kProductYearly,
      });
      await s.init(); // retries in the background
      await Future<void>.delayed(Duration.zero);
      expect(v.calls, 1);
      expect(s.isPremium, isFalse);
      expect(s.error, contains('retried'));
    });

    test('a saved entitlement keeps premium offline after restart', () async {
      SharedPreferences.setMockInitialValues({'premium_entitlement': _sign()});
      final v = _FakeVerifier(() => throw Exception('offline'));
      final s = service(v);
      await s.init();
      expect(s.isPremium, isTrue);
      expect(v.calls, 0);
    });

    test('editing the saved flag on the device cannot grant premium', () async {
      SharedPreferences.setMockInitialValues({
        'is_premium': true, // the old, unsigned flag
        'premium_entitlement': 'not-a-real-token',
      });
      final s = service(_FakeVerifier(() => throw Exception('offline')));
      await s.init();
      expect(s.isPremium, isFalse);
    });

    test('not configured → premium hidden and inactive', () async {
      final s = PurchaseService(publicKey: '', clock: () => _now);
      await s.init();
      expect(s.configured, isFalse);
      expect(s.isPremium, isFalse);
    });
  });
}
