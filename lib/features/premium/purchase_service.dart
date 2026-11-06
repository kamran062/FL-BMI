import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:bmi_health/core/monitoring/crash_reporting.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/features/premium/entitlement.dart';
import 'package:bmi_health/core/config/legal_links.dart';

// ── Product IDs ────────────────────────────────────────────────────────────
// Must exactly match Play Console / App Store Connect.
const kProductMonthly  = 'bmi_health_premium_monthly';
const kProductYearly   = 'bmi_health_premium_yearly';
const kProductLifetime = 'bmi_health_premium_lifetime';

const _allProductIds = <String>{kProductMonthly, kProductYearly, kProductLifetime};

/// Premium purchases (ROADMAP 3.5), with no server of our own.
///
/// The store's purchase stream is trusted as delivered and the result is
/// saved on the device. Trade-off accepted to avoid a paid backend: on a
/// rooted / jailbroken device the purchase flow or the saved entitlement can
/// be tampered with. Premium only removes ads, so the loss is small.
///
/// Re-checks: on Android every launch asks Google Play for owned purchases
/// (no UI) and drops premium when a successful query no longer lists one
/// (cancelled after the period ends, refunded). iOS has no silent query
/// (restoring can ask for the Apple ID password), so subscriptions there
/// end at the last transaction date + the period; renewals arrive through
/// the purchase stream while the app runs and extend it.
class PurchaseService extends ChangeNotifier {
  PurchaseService({
    EntitlementStore? store,
    InAppPurchase? iap,
    DateTime Function()? clock,
    bool? isAndroid,
    this.restoreSettle = const Duration(seconds: 2),
  })  : _store = store ?? SecureEntitlementStore(),
        _iapOverride = iap,
        _now = clock ?? DateTime.now,
        _android = isAndroid ?? Platform.isAndroid,
        _mobile = isAndroid != null || Platform.isAndroid || Platform.isIOS;

  static final instance = PurchaseService();

  /// Android: confirmed subscriptions stay valid this long without a new
  /// successful check (offline use).
  static const offlineGrace = Duration(days: 35);

  /// Time to wait for restored purchases after a restore call returns.
  final Duration restoreSettle;

  final EntitlementStore _store;
  final InAppPurchase? _iapOverride;
  final DateTime Function() _now;
  final bool _android;
  final bool _mobile;
  InAppPurchase get _iap => _iapOverride ?? InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _sub;
  Entitlement? _entitlement;
  bool _available = false;
  bool _loading = false;
  String? _error;
  List<ProductDetails> _products = [];
  Set<String>? _seenDuringCheck;

  /// Premium can be sold in this build: the store returned the products and
  /// public Terms/Privacy pages exist (Apple rejects paywalls without them).
  /// An active premium user always sees their status.
  bool get configured =>
      isPremium || (_products.isNotEmpty && (legalLinksOk ?? LegalLinks.configured));

  /// Test override for the legal-links requirement.
  @visibleForTesting
  static bool? legalLinksOk;
  bool get available => _available;
  bool get isPremium => _entitlement?.isActive(_now()) ?? false;
  Entitlement? get entitlement => _entitlement;
  bool get loading => _loading;
  String? get error => _error;
  List<ProductDetails> get products => _products;

  // ── Init ──────────────────────────────────────────────────────────────
  Future<void> init() async {
    try {
      _entitlement = Entitlement.decode(await _store.read());
    } catch (e, st) {
      reportError(e, st, reason: 'premium-read');
    }
    _applyAds();
    notifyListeners();

    if (!_mobile) return;
    _available = await _iap.isAvailable();
    if (!_available) return;
    _sub = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object e) => _setError(e.toString()),
    );
    final response = await _iap.queryProductDetails(_allProductIds);
    _products = response.productDetails;
    notifyListeners();
    if (_android) await _check();
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
  /// Restores past purchases (the paywall button). On iOS the spinner stops
  /// after 20 s even if the store reports nothing (it sends no event when
  /// there is nothing to restore).
  Future<void> restore() async {
    _setError(null);
    _loading = true;
    notifyListeners();
    if (_android) {
      await _check();
      _loading = false;
      notifyListeners();
      return;
    }
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

  /// Android: asks Play for owned purchases; a successful answer without any
  /// premium product ends premium. Offline / errors keep what we have.
  Future<void> _check() async {
    final seen = _seenDuringCheck = <String>{};
    try {
      await _iap.restorePurchases();
      await Future<void>.delayed(restoreSettle);
      if (seen.isEmpty && _entitlement != null) {
        _entitlement = null;
        await _store.write(null);
        _applyAds();
        notifyListeners();
      }
    } catch (e, st) {
      reportError(e, st, reason: 'premium-check');
    } finally {
      _seenDuringCheck = null;
    }
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
          // Always acknowledge, or Google refunds after 3 days.
          if (p.pendingCompletePurchase) await _iap.completePurchase(p);
          if (_allProductIds.contains(p.productID)) {
            _seenDuringCheck?.add(p.productID);
            await _grant(p);
          }
          _loading = false;
          notifyListeners();
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

  /// When premium from [p] ends; the latest of all known purchases wins.
  @visibleForTesting
  DateTime expiryFor(PurchaseDetails p) {
    if (p.productID == kProductLifetime) return DateTime(2100);
    final now = _now();
    if (_android) return now.add(offlineGrace);
    final ms = int.tryParse(p.transactionDate ?? '');
    final from = ms == null ? now : DateTime.fromMillisecondsSinceEpoch(ms);
    final period = p.productID == kProductYearly ? 366 : 31;
    return from.add(Duration(days: period + 3)); // + billing-retry grace
  }

  Future<void> _grant(PurchaseDetails p) async {
    final expires = expiryFor(p);
    final current = _entitlement;
    if (current != null && !expires.isAfter(current.expiresAt)) return;
    _entitlement = Entitlement(productId: p.productID, expiresAt: expires);
    _error = null;
    try {
      await _store.write(_entitlement!.encode());
    } catch (e, st) {
      reportError(e, st, reason: 'premium-save');
    }
    _applyAds();
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
