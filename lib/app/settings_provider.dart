import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide preferences: theme, language, onboarding state, reminders.
class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  String _language = 'system'; // 'system' | 'en' | 'ur'
  bool _onboardingDone = false;
  bool _profileSetupDismissed = false;
  bool _dailyReminder = false;
  bool _weeklyCheckIn = false;
  String _appVersion = '';
  String _versionName = '';

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;
  String get language => _language;

  /// null → follow the phone's language.
  Locale? get locale => _language == 'system' ? null : Locale(_language);

  /// The intro slides have been seen (or skipped).
  bool get onboardingDone => _onboardingDone;

  /// An existing user chose "Later" on the profile setup prompt.
  bool get profileSetupDismissed => _profileSetupDismissed;
  bool get dailyReminder => _dailyReminder;
  bool get weeklyCheckIn => _weeklyCheckIn;
  String get appVersion => _appVersion; // e.g. 1.0.1 (build 3)
  String get versionName => _versionName; // e.g. 1.0.1

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingDone = prefs.getBool('onboarding_done') ?? false;
    _profileSetupDismissed = prefs.getBool('profile_setup_dismissed') ?? false;
    _themeMode = (prefs.getString('theme') == 'dark')
        ? ThemeMode.dark
        : ThemeMode.light;
    _language = prefs.getString('language') ?? 'system';
    // Off until the user turns it on (and grants notification permission)
    _dailyReminder = prefs.getBool('daily_reminder') ?? false;
    _weeklyCheckIn = prefs.getBool('weekly_check_in') ?? false;

    final info = await PackageInfo.fromPlatform();
    _versionName = info.version;
    _appVersion = '${info.version} (build ${info.buildNumber})';
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', mode == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  Future<void> completeOnboarding() async {
    _onboardingDone = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
  }

  Future<void> dismissProfileSetup() async {
    _profileSetupDismissed = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profile_setup_dismissed', true);
  }

  Future<void> setDailyReminder(bool v) async {
    _dailyReminder = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_reminder', v);
  }

  Future<void> setWeeklyCheckIn(bool v) async {
    _weeklyCheckIn = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('weekly_check_in', v);
  }
}
