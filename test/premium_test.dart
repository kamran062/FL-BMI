import 'dart:async';

import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/features/premium/entitlement.dart';
import 'package:bmi_health/features/premium/purchase_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

final _now = DateTime.utc(2026, 11, 6);

PurchaseDetails _purchase(
  String product, {
  PurchaseStatus status = PurchaseStatus.purchased,
  DateTime? at,
}) =>
    PurchaseDetails(
      productID: product,
      verificationData: PurchaseVerificationData(
          localVerificationData: '', serverVerificationData: 'token', source: 'test'),
      transactionDate: (at ?? _now).millisecondsSinceEpoch.toString(),
      status: status,
    )..pendingCompletePurchase = true;

/// Store stand-in: [owned] is what a restore reports; [restoreFails]
/// simulates being offline.
class _FakeIap implements InAppPurchase {
  final _stream = StreamController<List<PurchaseDetails>>.broadcast();
  List<String> owned = [];
  bool restoreFails = false;
  int completed = 0;

  void emit(List<PurchaseDetails> p) => _stream.add(p);

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _stream.stream;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> ids) async =>
      ProductDetailsResponse(
        productDetails: [
          for (final id in ids)
            ProductDetails(
                id: id, title: id, description: '', price: '1', rawPrice: 1, currencyCode: 'USD'),
        ],
        notFoundIDs: const [],
      );

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    if (restoreFails) throw Exception('offline');
    emit([for (final id in owned) _purchase(id, status: PurchaseStatus.restored)]);
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async => completed++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() => PurchaseService.legalLinksOk = true);
  setUp(() => AdService.instance.premium = false);

  PurchaseService service(_FakeIap iap, MemoryEntitlementStore store, {bool android = true}) =>
      PurchaseService(
        store: store,
        iap: iap,
        clock: () => _now,
        isAndroid: android,
        restoreSettle: Duration.zero,
      );

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

  test('a purchase unlocks premium, is acknowledged, saved, and removes ads', () async {
    final iap = _FakeIap();
    final store = MemoryEntitlementStore();
    final s = service(iap, store);
    await s.init();
    expect(s.configured, isTrue); // products loaded + legal links
    expect(s.isPremium, isFalse);

    iap.emit([_purchase(kProductMonthly)]);
    await settle();
    expect(s.isPremium, isTrue);
    expect(iap.completed, 1);
    expect(AdService.instance.premium, isTrue);
    expect(Entitlement.decode(store.value)!.productId, kProductMonthly);
  });

  test('saved premium works offline after a restart', () async {
    final iap = _FakeIap()..restoreFails = true;
    final store = MemoryEntitlementStore(
        Entitlement(productId: kProductYearly, expiresAt: _now.add(const Duration(days: 10)))
            .encode());
    final s = service(iap, store);
    await s.init();
    expect(s.isPremium, isTrue);
  });

  test('Android: a successful check without the purchase ends premium', () async {
    final iap = _FakeIap(); // owns nothing any more (cancelled / refunded)
    final store = MemoryEntitlementStore(
        Entitlement(productId: kProductMonthly, expiresAt: _now.add(const Duration(days: 10)))
            .encode());
    final s = service(iap, store);
    await s.init();
    expect(s.isPremium, isFalse);
    expect(store.value, isNull);
  });

  test('Android: a check that still lists the purchase renews the offline window',
      () async {
    final iap = _FakeIap()..owned = [kProductMonthly];
    final store = MemoryEntitlementStore(
        Entitlement(productId: kProductMonthly, expiresAt: _now.add(const Duration(days: 1)))
            .encode());
    final s = service(iap, store);
    await s.init();
    expect(s.entitlement!.expiresAt, _now.add(PurchaseService.offlineGrace));
  });

  test('lifetime never expires; iOS subscriptions end after the period', () async {
    final s = service(_FakeIap(), MemoryEntitlementStore(), android: false);
    expect(s.expiryFor(_purchase(kProductLifetime)).year, 2100);
    final bought = _now.subtract(const Duration(days: 40));
    final monthly = s.expiryFor(_purchase(kProductMonthly, at: bought));
    expect(monthly.isBefore(_now), isTrue);
    expect(s.expiryFor(_purchase(kProductYearly, at: bought)).isAfter(_now), isTrue);
  });

  test('an older restored transaction does not shorten premium (iOS)', () async {
    final iap = _FakeIap();
    final s = service(iap, MemoryEntitlementStore(), android: false);
    await s.init();
    iap.emit([
      _purchase(kProductMonthly, status: PurchaseStatus.restored),
      _purchase(kProductMonthly,
          status: PurchaseStatus.restored, at: _now.subtract(const Duration(days: 60))),
    ]);
    await settle();
    expect(s.isPremium, isTrue);
  });

  test('garbage in storage does not grant premium', () async {
    final s = service(_FakeIap()..restoreFails = true, MemoryEntitlementStore('not json'));
    await s.init();
    expect(s.isPremium, isFalse);
  });

  test('no store products → premium hidden', () async {
    final s = PurchaseService(store: MemoryEntitlementStore(), clock: () => _now);
    await s.init();
    expect(s.configured, isFalse);
    expect(s.isPremium, isFalse);
  });
}
