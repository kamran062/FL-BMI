import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// A packaged food from Open Food Facts (ROADMAP 4.4).
class FoodProduct {
  final String barcode;
  final String name;
  final double kcalPer100g;
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? fatPer100g;

  /// Grams in one serving, when the label gives it.
  final double? servingG;

  const FoodProduct({
    required this.barcode,
    required this.name,
    required this.kcalPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatPer100g,
    this.servingG,
  });

  int kcalFor(double grams) => (kcalPer100g * grams / 100).round();
  double? proteinFor(double grams) => _for(proteinPer100g, grams);
  double? carbsFor(double grams) => _for(carbsPer100g, grams);
  double? fatFor(double grams) => _for(fatPer100g, grams);

  static double? _for(double? per100g, double grams) => per100g == null
      ? null
      : (per100g * grams / 100 * 10).roundToDouble() / 10;

  /// Parses an Open Food Facts v2 product. Null when there is no usable
  /// energy value (many entries are incomplete).
  static FoodProduct? fromOff(String barcode, Map<String, dynamic> product) {
    final n = (product['nutriments'] as Map?)?.cast<String, dynamic>() ?? const {};
    double? num_(String k) {
      final v = n[k];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    // Prefer kcal; fall back to kJ (some labels only give kJ).
    final kcal = num_('energy-kcal_100g') ??
        (num_('energy-kj_100g') ?? num_('energy_100g')).let((kj) => kj / 4.184);
    if (kcal == null || kcal < 0 || kcal > 950) return null; // 900 = pure fat

    final name = [product['product_name'], product['brands']]
        .whereType<String>()
        .map((s) => s.split(',').first.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .join(' · ');
    final serving = product['serving_quantity'];
    return FoodProduct(
      barcode: barcode,
      name: name.isEmpty ? barcode : name,
      kcalPer100g: (kcal * 10).roundToDouble() / 10,
      proteinPer100g: num_('proteins_100g'),
      carbsPer100g: num_('carbohydrates_100g'),
      fatPer100g: num_('fat_100g'),
      servingG: serving is num && serving > 0 && serving < 2000
          ? serving.toDouble()
          : (serving is String ? double.tryParse(serving) : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'barcode': barcode,
        'name': name,
        'kcal': kcalPer100g,
        'protein': proteinPer100g,
        'carbs': carbsPer100g,
        'fat': fatPer100g,
        'serving': servingG,
      };

  factory FoodProduct.fromJson(Map<String, dynamic> j) => FoodProduct(
        barcode: j['barcode'] as String,
        name: j['name'] as String,
        kcalPer100g: (j['kcal'] as num).toDouble(),
        proteinPer100g: (j['protein'] as num?)?.toDouble(),
        carbsPer100g: (j['carbs'] as num?)?.toDouble(),
        fatPer100g: (j['fat'] as num?)?.toDouble(),
        servingG: (j['serving'] as num?)?.toDouble(),
      );
}

extension<T> on T? {
  R? let<R>(R Function(T) f) => this == null ? null : f(this as T);
}

enum LookupError { notFound, noNutrition, offline }

class LookupResult {
  final FoodProduct? product;
  final LookupError? error;
  const LookupResult.ok(this.product) : error = null;
  const LookupResult.fail(this.error) : product = null;
}

/// Looks barcodes up on Open Food Facts, caching recent products so
/// rescanning works offline.
class FoodLookup {
  FoodLookup({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _cacheKey = 'food_cache';
  static const _cacheMax = 60;

  static bool isBarcode(String code) =>
      RegExp(r'^\d{8}$|^\d{12,14}$').hasMatch(code);

  Future<LookupResult> lookup(String barcode) async {
    if (!isBarcode(barcode)) return const LookupResult.fail(LookupError.notFound);
    final cached = await _cached(barcode);
    if (cached != null) return LookupResult.ok(cached);

    try {
      final res = await _client.get(
        Uri.parse('https://world.openfoodfacts.org/api/v2/product/$barcode.json'
            '?fields=product_name,brands,nutriments,serving_quantity'),
        // Open Food Facts asks every app to identify itself.
        headers: {'User-Agent': 'BMIHealth/1.0 (Android/iOS app)'},
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 404) return const LookupResult.fail(LookupError.notFound);
      if (res.statusCode != 200) return const LookupResult.fail(LookupError.offline);
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['status'] != 1 || body['product'] is! Map) {
        return const LookupResult.fail(LookupError.notFound);
      }
      final p = FoodProduct.fromOff(barcode, (body['product'] as Map).cast());
      if (p == null) return const LookupResult.fail(LookupError.noNutrition);
      await _remember(p);
      return LookupResult.ok(p);
    } catch (_) {
      return const LookupResult.fail(LookupError.offline);
    }
  }

  Future<FoodProduct?> _cached(String barcode) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    final hit = list.where((j) => j['barcode'] == barcode).firstOrNull;
    return hit == null ? null : FoodProduct.fromJson(hit);
  }

  Future<void> _remember(FoodProduct p) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    final list = raw == null
        ? <Map<String, dynamic>>[]
        : (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    list
      ..removeWhere((j) => j['barcode'] == p.barcode)
      ..insert(0, p.toJson());
    await prefs.setString(_cacheKey, jsonEncode(list.take(_cacheMax).toList()));
  }
}
