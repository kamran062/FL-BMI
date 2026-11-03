import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/body/bmi/domain/bmi_entry.dart';
import 'package:bmi_health/features/body/bmi/domain/goal.dart';
import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:bmi_health/features/body/bmi/domain/bmi_calculator.dart';

class AppProvider extends ChangeNotifier {
  // ── State ────────────────────────────────────────────────────
  UserProfile _profile = const UserProfile();
  List<BmiEntry> _entries = [];
  Goal? _activeGoal;
  ThemeMode _themeMode = ThemeMode.light;
  String _language = 'system'; // 'system' | 'en' | 'ur'
  bool _onboardingDone = false;
  bool _loading = true;
  String _appVersion = '';
  String _versionName = '';

  // ── Notification prefs (stored in SharedPreferences) ─────────
  bool _dailyReminder = true;
  bool _weeklyCheckIn = false;

  // ── Getters ──────────────────────────────────────────────────
  UserProfile get profile => _profile;
  List<BmiEntry> get entries => _entries;
  Goal? get activeGoal => _activeGoal;
  ThemeMode get themeMode => _themeMode;
  String get language => _language;

  /// null → follow the phone's language.
  Locale? get locale => _language == 'system' ? null : Locale(_language);
  bool get isDark => _themeMode == ThemeMode.dark;
  bool get onboardingDone => _onboardingDone;
  bool get loading => _loading;
  String get appVersion => _appVersion; // e.g. 1.0.1 (build 3)
  String get versionName => _versionName; // e.g. 1.0.1
  bool get dailyReminder => _dailyReminder;
  bool get weeklyCheckIn => _weeklyCheckIn;

  BmiEntry? get lastEntry => _entries.isNotEmpty ? _entries.first : null;

  double get currentBmi => BmiCalculator.calculate(
    _profile.weightInKg,
    _profile.heightInCm,
  );

  // ── Init ─────────────────────────────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingDone = prefs.getBool('onboarding_done') ?? false;
    _themeMode = (prefs.getString('theme') == 'dark')
        ? ThemeMode.dark
        : ThemeMode.light;
    _language = prefs.getString('language') ?? 'system';
    _dailyReminder = prefs.getBool('daily_reminder') ?? true;
    _weeklyCheckIn = prefs.getBool('weekly_check_in') ?? false;

    final info = await PackageInfo.fromPlatform();
    _versionName = info.version;
    _appVersion = '${info.version} (build ${info.buildNumber})';

    // Restore profile from prefs
    _profile = UserProfile(
      height: prefs.getDouble('profile_height') ?? 172,
      heightUnit: prefs.getString('profile_height_unit') ?? 'cm',
      weight: prefs.getDouble('profile_weight') ?? 70,
      weightUnit: prefs.getString('profile_weight_unit') ?? 'kg',
      age: prefs.getInt('profile_age') ?? 30,
      gender: prefs.getString('profile_gender') ?? 'f',
    );

    _entries = await DatabaseHelper.instance.getEntries();
    _activeGoal = await DatabaseHelper.instance.getActiveGoal();
    _loading = false;
    notifyListeners();
  }

  // ── Profile ──────────────────────────────────────────────────
  Future<void> updateProfile(UserProfile p) async {
    _profile = p;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('profile_height', p.height);
    await prefs.setString('profile_height_unit', p.heightUnit);
    await prefs.setDouble('profile_weight', p.weight);
    await prefs.setString('profile_weight_unit', p.weightUnit);
    await prefs.setInt('profile_age', p.age);
    await prefs.setString('profile_gender', p.gender);
    notifyListeners();
  }

  // ── BMI Entries ──────────────────────────────────────────────
  Future<BmiEntry> saveCurrentResult() async {
    final entry = BmiEntry(
      weight: _profile.weightInKg,
      height: _profile.heightInCm,
      bmi: currentBmi,
      age: _profile.age,
      gender: _profile.gender,
      weightUnit: _profile.weightUnit,
      heightUnit: _profile.heightUnit,
      date: DateTime.now(),
    );
    final id = await DatabaseHelper.instance.insertEntry(entry);
    _entries = await DatabaseHelper.instance.getEntries();
    notifyListeners();
    return entry.copyWith(id: id);
  }

  Future<void> deleteEntry(int id) async {
    await DatabaseHelper.instance.deleteEntry(id);
    _entries = await DatabaseHelper.instance.getEntries();
    notifyListeners();
  }

  // ── Goal ─────────────────────────────────────────────────────
  Future<void> saveGoal(Goal goal) async {
    await DatabaseHelper.instance.insertGoal(goal);
    _activeGoal = goal;
    notifyListeners();
  }

  Future<void> clearGoal() async {
    await DatabaseHelper.instance.deactivateGoal();
    _activeGoal = null;
    notifyListeners();
  }

  // ── Theme ─────────────────────────────────────────────────────
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  // ── Language ─────────────────────────────────────────────────
  Future<void> setLanguage(String language) async {
    _language = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    notifyListeners();
  }

  // ── Onboarding ───────────────────────────────────────────────
  Future<void> completeOnboarding() async {
    _onboardingDone = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    notifyListeners();
  }

  // ── Notifications ─────────────────────────────────────────────
  Future<void> setDailyReminder(bool v) async {
    _dailyReminder = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_reminder', v);
    notifyListeners();
  }

  Future<void> setWeeklyCheckIn(bool v) async {
    _weeklyCheckIn = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('weekly_check_in', v);
    notifyListeners();
  }
}
