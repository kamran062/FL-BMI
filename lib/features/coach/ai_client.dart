import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bmi_health/features/profile/domain/user_profile.dart';

// Build-time config (.env.json). Each feature is hidden until its URL is set.
const _coachUrlEnv = String.fromEnvironment('COACH_URL');
const _foodUrlEnv = String.fromEnvironment('FOOD_PHOTO_URL');

class AiLimitReached implements Exception {}

class AiUnavailable implements Exception {}

typedef ChatTurn = ({bool fromUser, String text});

class FoodItem {
  final String name;
  final int grams;
  final int kcal;
  final double proteinG;
  const FoodItem(this.name, this.grams, this.kcal, this.proteinG);
}

class FoodEstimate {
  final bool isFood;
  final List<FoodItem> items;
  final String confidence; // low | medium | high
  const FoodEstimate(this.isFood, this.items, this.confidence);

  int get totalKcal => items.fold(0, (s, i) => s + i.kcal);
}

/// Talks to the coach / estimateFood functions (functions/src/ai.js).
class AiClient {
  AiClient({String coachUrl = _coachUrlEnv, String foodUrl = _foodUrlEnv, http.Client? client})
      : _coachUrl = coachUrl,
        _foodUrl = foodUrl,
        _http = client ?? http.Client();

  final String _coachUrl;
  final String _foodUrl;
  final http.Client _http;

  bool get coachEnabled => _coachUrl.isNotEmpty;
  bool get foodPhotoEnabled => _foodUrl.isNotEmpty;

  static const _installKey = 'ai_install_id';
  static const consentKey = 'ai_consent';

  /// Random, anonymous ID used only for daily usage limits.
  static Future<String> installId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_installKey);
    if (id == null) {
      final r = Random.secure();
      id = List.generate(32, (_) => r.nextInt(16).toRadixString(16)).join();
      await prefs.setString(_installKey, id);
    }
    return id;
  }

  Future<Map<String, dynamic>> _post(String url, Map<String, dynamic> body) async {
    final http.Response res;
    try {
      res = await _http
          .post(Uri.parse(url),
              headers: {'content-type': 'application/json'}, body: jsonEncode(body))
          .timeout(const Duration(seconds: 90));
    } catch (_) {
      throw AiUnavailable();
    }
    if (res.statusCode == 429) throw AiLimitReached();
    if (res.statusCode != 200) throw AiUnavailable();
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Profile summary sent with coach questions (no name, no history).
  static Map<String, dynamic> profileSummary(UserProfile p, double? weightKg) => {
        'sex': switch (p.gender) { 'm' => 'male', 'f' => 'female', _ => 'other' },
        'age': p.age,
        if (weightKg != null) 'weightKg': double.parse(weightKg.toStringAsFixed(1)),
        if (p.goal != null) 'goal': p.goal!.name,
        if (p.experience != null) 'experience': p.experience!.name,
        'trainingDays': p.daysPerWeek,
      };

  /// Sends the last 20 turns; returns the coach's reply.
  Future<({String reply, bool emergency})> ask(
      List<ChatTurn> turns, Map<String, dynamic> profile) async {
    final recent = turns.length > 20 ? turns.sublist(turns.length - 20) : turns;
    // The server expects the conversation to start with the user.
    final start = recent.indexWhere((t) => t.fromUser);
    final body = await _post(_coachUrl, {
      'installId': await installId(),
      'profile': profile,
      'messages': [
        for (final t in recent.sublist(start < 0 ? 0 : start))
          {'role': t.fromUser ? 'user' : 'assistant', 'content': t.text}
      ],
    });
    return (reply: body['reply'] as String, emergency: body['emergency'] == true);
  }

  Future<FoodEstimate> estimate(Uint8List jpeg) async {
    final body = await _post(_foodUrl, {
      'installId': await installId(),
      'image': base64Encode(jpeg),
    });
    return FoodEstimate(
      body['is_food'] == true,
      [
        for (final i in (body['items'] as List? ?? const []).cast<Map<String, dynamic>>())
          FoodItem(i['name'] as String, (i['grams'] as num).round(), (i['kcal'] as num).round(),
              (i['protein_g'] as num).toDouble())
      ],
      body['confidence'] as String? ?? 'low',
    );
  }
}
