import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bmi_health/core/monitoring/crash_reporting.dart';

/// Creates the coach the player uses; tests swap in [RecordingVoiceCoach].
VoiceCoach Function() createVoiceCoach = TtsVoiceCoach.new;

/// Spoken cues for the guided player. An interface so tests can record
/// what would be said.
abstract class VoiceCoach {
  bool get enabled;
  Future<void> setEnabled(bool on);
  Future<void> load();

  /// Speaks [text] (in [locale] when a voice exists, else English),
  /// replacing anything still being said.
  Future<void> say(String text, {required String locale});
  Future<void> stop();
}

class TtsVoiceCoach implements VoiceCoach {
  final _tts = FlutterTts();
  static const _key = 'voice_coach';
  bool _enabled = true;
  bool _ready = false;
  String? _lang;

  @override
  bool get enabled => _enabled;

  @override
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_key) ?? true;
  }

  @override
  Future<void> setEnabled(bool on) async {
    _enabled = on;
    if (!on) await stop();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, on);
  }

  Future<void> _prepare(String locale) async {
    final want = locale == 'ur' ? 'ur-PK' : 'en-US';
    if (_ready && _lang == want) return;
    try {
      if (!_ready && Platform.isIOS) {
        // Lower (duck) music instead of stopping it.
        await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.duckOthers,
        ]);
      }
      final available = await _tts.isLanguageAvailable(want);
      _lang = available == true ? want : 'en-US';
      await _tts.setLanguage(_lang!);
      await _tts.setSpeechRate(Platform.isIOS ? 0.5 : 0.48);
      _ready = true;
    } catch (e, st) {
      reportError(e, st, reason: 'tts-setup');
    }
  }

  @override
  Future<void> say(String text, {required String locale}) async {
    if (!_enabled) return;
    try {
      await _prepare(locale);
      await _tts.stop();
      // focus: true asks Android for transient audio focus with ducking.
      await _tts.speak(text, focus: true);
    } catch (e, st) {
      reportError(e, st, reason: 'tts-speak');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}

/// Silent coach (tests, desktop) that remembers what it would have said.
class RecordingVoiceCoach implements VoiceCoach {
  final said = <String>[];
  bool _enabled = true;

  @override
  bool get enabled => _enabled;
  @override
  Future<void> load() async {}
  @override
  Future<void> setEnabled(bool on) async => _enabled = on;
  @override
  Future<void> say(String text, {required String locale}) async {
    if (_enabled) said.add(text);
  }

  @override
  Future<void> stop() async {}
}
