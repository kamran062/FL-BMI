import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bmi_health/core/monitoring/crash_reporting.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/features/premium/entitlement.dart';

// ── Product IDs ────────────────────────────────────────────────────────────
// Must exactly match Play Console / App Store Connect and functions/src/verify.js.
const kProductMonthly  = 'bmi_health_premium_monthly';
const kProductYearly   = 'bmi_health_premium_yearly';
const kProductLifetime = 'bmi_health_premium_lifetime';

const _allProductIds = <String>{kProductMonthly, kProductYearly, kProductLifetime};

// Build-time config (.env.json). Premium stays hidden until both are set.
const _verifyUrl = String.fromEnvironment('PREMIUM_VERIFY_URL');
const _publicKeyEnv = String.fromEnvironment('ENTITLEMENT_PUBLIC_KEY');

const _entitlementKey = 'premium_entitlement'; // signed JWT
const _tokenKey = 'premium_token'; // last purchase token, for re-checks
const _productKey = 'premium_product';

/// Premium purchases (ROADMAP 3.5). Premium is granted only by a server-
/// signed entitlement; the store purchase alone is not trusted.
class PurchaseService extends ChangeNotifier {
  PurchaseService({
    PurchaseVerifier? verifier,
    String publicKey = _publicKeyEnv,
    InAppPurchase? iap,
    DateTime Function()? clock,
  })  : _verifier = verifier ??
            (_verifyUrl.isEmpty ? null : HttpPurchaseVerifier(_verifyUrl)),
        _publicKey = publicKey.replaceAll(r'\n', '\n'),
        _iapOverride = iap,
        _now = clock ?? DateTime.now;

  static final instance = PurchaseService();

  final PurchaseVerifier? _verifier;
  final String _publicKey;
  final InAppPurchase? _iapOverride;
  final DateTime Function() _now;
  InAppPurchase get _iap => _iapOverride ?? InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _sub;
  Entitlement? _entitlement;
  bool _available = false;
  bool _loading = false;
  String? _error;
  List<ProductDetails> _products = [];

  /// Premium can be sold in this build (server + key configured).
  bool get configured => _verifier != null && _publicKey.isNotEmpty;
  bool get available => _available;
  bool get isPremium => _entitlement?.isActive(_now()) ?? false;
  Entitlement? get entitlement => _entitlement;
  bool get loading => _loading;
  String? get error => _error;
  List<ProductDetails> get products => _products;

  // ── Init ──────────────────────────────────────────────────────────────
  Future<void> init() async {
    if (!configured) return;
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString(_entitlementKey);
    if (jwt != null) _entitlement = Entitlement.parse(jwt, _publicKey);
    _applyAds();
    notifyListeners();

    // Re-check with the server when the signed entitlement has lapsed
    // (renewals, refunds, cancellations).
    final token = prefs.getString(_tokenKey);
    final product = prefs.getString(_productKey);
    if (!isPremium && token != null && product != null) {
      unawaited(_verify(product, token));
    }

    if (!(Platform.isAndroid || Platform.isIOS)) return;
    _available = await _iap.isAvailable();
    if (!_available) return;
    _sub = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object e) => _setError(e.toString()),
    );
    final response = await _iap.queryProductDetails(_allProductIds);
    _products = response.productDetails;
    notifyListeners();
  }

  // ── Purchase ──────────────────────────────────────────────────────────
  Future<void> buy(String productId) async {
    _setError(null);
    final product = _products.where((p) => p.id == productId).firstOrNull;
    if (product == null) {
      _setError('Product not found. Check your internet connection and try again.');
      return;
    }
    // The store sheet leaves the app; not an "app open".
    AdService.instance.beginExternalUi();
    try {
      await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));
    } finally {
      AdService.instance.endExternalUi();
    }
  }

  // ── Restore ───────────────────────────────────────────────────────────
  /// Restores past purchases. Stops the spinner after 20 s even if the
  /// store reports nothing (it sends no event when there is nothing to
  /// restore).
  Future<void> restore() async {
    _setError(null);
    _loading = true;
    notifyListeners();
    try {
      await _iap.restorePurchases();
    } catch (e) {
      _setError(e.toString());
    }
    Future<void>.delayed(const Duration(seconds: 20), () {
      if (_loading) {
        _loading = false;
        notifyListeners();
      }
    });
  }

  // ── Purchase stream ───────────────────────────────────────────────────
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      switch (p.status) {
        case PurchaseStatus.pending:
          _loading = true;
          notifyListeners();
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Always acknowledge, or Google refunds after 3 days. A real
          // purchase that we fail to verify now is retried on next launch.
          if (p.pendingCompletePurchase) await _iap.completePurchase(p);
          final token = Platform.isIOS
              ? (p.purchaseID ?? '')
              : p.verificationData.serverVerificationData;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, token);
          await prefs.setString(_productKey, p.productID);
          await _verify(p.productID, token);
        case PurchaseStatus.error:
          _loading = false;
          _setError(p.error?.message ?? 'Purchase failed. Please try again.');
          if (p.pendingCompletePurchase) await _iap.completePurchase(p);
        case PurchaseStatus.canceled:
          _loading = false;
          notifyListeners();
      }
    }
  }

  /// Asks the server; stores the signed entitlement it returns.
  @visibleForTesting
  Future<void> verify(String productId, String token) =>
      _verify(productId, token);

  Future<void> _verify(String productId, String token) async {
    final verifier = _verifier;
    if (verifier == null) return;
    try {
      final jwt = await verifier.verify(productId: productId, token: token);
      final ent = Entitlement.parse(jwt, _publicKey);
      if (ent == null) throw const FormatException('entitlement signature invalid');
      _entitlement = ent;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_entitlementKey, jwt);
      _error = null;
    } catch (e, st) {
      reportError(e, st, reason: 'premium-verify');
      _error = 'Could not confirm your purchase. It will be retried automatically.';
    } finally {
      _loading = false;
      _applyAds();
      notifyListeners();
    }
  }

  void _applyAds() => AdService.instance.premium = isPremium;

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
