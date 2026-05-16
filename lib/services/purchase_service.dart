import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Product IDs ────────────────────────────────────────────────────────────
// Must exactly match the IDs created in Play Store / App Store Connect.
const kProductMonthly  = 'bmi_health_premium_monthly';
const kProductYearly   = 'bmi_health_premium_yearly';
const kProductLifetime = 'bmi_health_premium_lifetime';

const _allProductIds = <String>{
  kProductMonthly,
  kProductYearly,
  kProductLifetime,
};

const _premiumKey = 'is_premium';

class PurchaseService extends ChangeNotifier {
  PurchaseService._();
  static final instance = PurchaseService._();

  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  bool _available  = false;
  bool _isPremium  = false;
  bool _loading    = false;
  String? _error;
  List<ProductDetails> _products = [];

  bool get available => _available;
  bool get isPremium => _isPremium;
  bool get loading   => _loading;
  String? get error  => _error;
  List<ProductDetails> get products => _products;

  // ── Init ──────────────────────────────────────────────────────────────────
  Future<void> init() async {
    // Restore premium from local cache so no store call needed on launch
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;
    notifyListeners();

    _available = await _iap.isAvailable();
    if (!_available) return;

    // Listen to the purchase stream
    _sub = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (e) => _setError(e.toString()),
    );

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails(_allProductIds);
    _products = response.productDetails;
    notifyListeners();
  }

  // ── Purchase ──────────────────────────────────────────────────────────────
  Future<void> buy(String productId) async {
    _setError(null);
    final product = _products.where((p) => p.id == productId).firstOrNull;
    if (product == null) {
      _setError('Product not found. Check your internet connection and try again.');
      return;
    }
    final param = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  // ── Restore ───────────────────────────────────────────────────────────────
  Future<void> restore() async {
    _setError(null);
    _loading = true;
    notifyListeners();
    try {
      await _iap.restorePurchases();
    } catch (e) {
      _setError(e.toString());
      _loading = false;
      notifyListeners();
    }
  }

  // ── Purchase stream handler ───────────────────────────────────────────────
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      switch (p.status) {
        case PurchaseStatus.pending:
          _loading = true;
          notifyListeners();

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (p.pendingCompletePurchase) {
            await _iap.completePurchase(p);
          }
          await _markPremium(true);

        case PurchaseStatus.error:
          _loading = false;
          _setError(p.error?.message ?? 'Purchase failed. Please try again.');
          if (p.pendingCompletePurchase) {
            await _iap.completePurchase(p);
          }

        case PurchaseStatus.canceled:
          _loading = false;
          notifyListeners();
      }
    }
  }

  Future<void> _markPremium(bool value) async {
    _isPremium = value;
    _loading   = false;
    _error     = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, value);
    notifyListeners();
  }

  // ── Dev helpers ───────────────────────────────────────────────────────────
  Future<void> debugUnlockPremium() async {
    if (kDebugMode) await _markPremium(true);
  }

  Future<void> debugRevokePremium() async {
    if (kDebugMode) await _markPremium(false);
  }

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
