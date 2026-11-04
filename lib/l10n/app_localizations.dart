import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur')
  ];

  /// App name
  ///
  /// In en, this message translates to:
  /// **'BMI Calculator & Health'**
  String get appTitle;

  /// Tagline on the splash screen
  ///
  /// In en, this message translates to:
  /// **'Know Your Body. Improve Your Health.'**
  String get appTagline;

  /// Bottom nav tab: BMI calculator
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get navCalculate;

  /// Bottom nav tab: saved BMI history
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// Bottom nav tab: health tips
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get navTips;

  /// Bottom nav tab: settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// BMI category below 18.5
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get categoryUnder;

  /// BMI category 18.5–24.9
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get categoryNormal;

  /// BMI category 25–29.9
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get categoryOver;

  /// BMI category 30 and above
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get categoryObese;

  /// Gender option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// Gender option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// Gender option
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// Calculate screen title
  ///
  /// In en, this message translates to:
  /// **'BMI Calculator'**
  String get homeTitle;

  /// Calculate screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Know your body. Track your health.'**
  String get homeSubtitle;

  /// Input label
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get fieldHeight;

  /// Input label
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get fieldWeight;

  /// Input label
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get fieldAge;

  /// Input label
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get fieldGender;

  /// Short unit after the age number, e.g. 30 yrs
  ///
  /// In en, this message translates to:
  /// **'yrs'**
  String get yearsShort;

  /// Main calculate button
  ///
  /// In en, this message translates to:
  /// **'Calculate BMI'**
  String get calculateBmi;

  /// Card showing the most recent saved result
  ///
  /// In en, this message translates to:
  /// **'Last result · {date}'**
  String lastResult(String date);

  /// A BMI number with label
  ///
  /// In en, this message translates to:
  /// **'BMI {value}'**
  String bmiValue(String value);

  /// Shown when a field is empty
  ///
  /// In en, this message translates to:
  /// **'Enter your height and weight to calculate.'**
  String get errorEnterHeightWeight;

  /// Shown when height is outside the accepted range
  ///
  /// In en, this message translates to:
  /// **'Enter a height between 50 and 272 cm (20–107 in).'**
  String get errorHeightRange;

  /// Shown when weight is outside the accepted range
  ///
  /// In en, this message translates to:
  /// **'Enter a weight between 2 and 635 kg (5–1400 lbs).'**
  String get errorWeightRange;

  /// Result screen title
  ///
  /// In en, this message translates to:
  /// **'Your result'**
  String get resultTitle;

  /// Section label above advice
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get recommendation;

  /// Section label above the BMI range bar
  ///
  /// In en, this message translates to:
  /// **'Healthy range'**
  String get healthyRange;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Save result'**
  String get saveResult;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Set goal'**
  String get setGoal;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Share result'**
  String get shareResult;

  /// Share screen title
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareTitle;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Save image'**
  String get saveImage;

  /// Button label while the share sheet is opening
  ///
  /// In en, this message translates to:
  /// **'Sharing…'**
  String get sharing;

  /// Text sent with the shared image
  ///
  /// In en, this message translates to:
  /// **'My BMI is {value} — tracked with BMI Calculator & Health'**
  String shareText(String value);

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Could not share right now. Please try again.'**
  String get shareError;

  /// Date label on the share card
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get shareCardToday;

  /// Share card line for a normal BMI
  ///
  /// In en, this message translates to:
  /// **'Within the healthy range — keeping it up.'**
  String get shareCardHealthy;

  /// Share card line for other BMIs
  ///
  /// In en, this message translates to:
  /// **'Tracking my body, one week at a time.'**
  String get shareCardTracking;

  /// Onboarding page 1 title
  ///
  /// In en, this message translates to:
  /// **'Track your health easily'**
  String get onboardTitle1;

  /// Onboarding page 1 text
  ///
  /// In en, this message translates to:
  /// **'Calculate your BMI in seconds, no account needed.'**
  String get onboardBody1;

  /// Onboarding page 2 title
  ///
  /// In en, this message translates to:
  /// **'Get smart recommendations'**
  String get onboardTitle2;

  /// Onboarding page 2 text
  ///
  /// In en, this message translates to:
  /// **'Personalized advice based on your body and goals.'**
  String get onboardBody2;

  /// Onboarding page 3 title
  ///
  /// In en, this message translates to:
  /// **'Track progress over time'**
  String get onboardTitle3;

  /// Onboarding page 3 text
  ///
  /// In en, this message translates to:
  /// **'See your weight journey visually, week by week.'**
  String get onboardBody3;

  /// Onboarding skip button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Last onboarding page button
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// Onboarding next button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Settings section
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// Settings toggle
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// Settings section
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get sectionLanguage;

  /// Settings row that opens the language picker
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// Language option: follow the phone's language
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// Language option, always written in English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Language option, always written in Urdu
  ///
  /// In en, this message translates to:
  /// **'اردو'**
  String get languageUrdu;

  /// Settings section
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get sectionUnits;

  /// Settings section
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get sectionNotifications;

  /// Settings toggle
  ///
  /// In en, this message translates to:
  /// **'Daily reminders'**
  String get dailyReminders;

  /// Settings toggle
  ///
  /// In en, this message translates to:
  /// **'Weekly check-in'**
  String get weeklyCheckIn;

  /// Settings section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// Settings row
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// Short note next to Privacy: data stays on the phone
  ///
  /// In en, this message translates to:
  /// **'On-device'**
  String get onDevice;

  /// Settings row that opens Google's consent form
  ///
  /// In en, this message translates to:
  /// **'Ad privacy choices'**
  String get adPrivacyChoices;

  /// Settings row
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Footer at the bottom of Settings
  ///
  /// In en, this message translates to:
  /// **'Made with care.  ·  No account required.'**
  String get settingsFooter;

  /// Privacy dialog title
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Privacy dialog section
  ///
  /// In en, this message translates to:
  /// **'🔒 Data stays on your device'**
  String get privacyDataTitle;

  /// Privacy dialog text
  ///
  /// In en, this message translates to:
  /// **'BMI Calculator & Health stores all your data — weight entries, goals, and profile — locally on your device using SQLite. Nothing is sent to any server.'**
  String get privacyDataBody;

  /// Privacy dialog section
  ///
  /// In en, this message translates to:
  /// **'📊 No analytics or tracking'**
  String get privacyAnalyticsTitle;

  /// Privacy dialog text. Must stay accurate about crash reporting (Sentry, no health data).
  ///
  /// In en, this message translates to:
  /// **'We do not use analytics or user-tracking tools. If the app crashes, an anonymous crash report (device model, Android or iOS version, and the technical error) may be sent to our crash-reporting service, Sentry, so we can fix the problem. Crash reports never include your weight, BMI or other health data.'**
  String get privacyAnalyticsBody;

  /// Privacy dialog section
  ///
  /// In en, this message translates to:
  /// **'📢 Ads'**
  String get privacyAdsTitle;

  /// Privacy dialog text
  ///
  /// In en, this message translates to:
  /// **'BMI Calculator & Health is free and supported by ads powered by Google AdMob. AdMob may use your device\'s advertising ID to show relevant ads. You can opt out of personalised ads at any time in your device settings under Google → Ads → Delete advertising ID.'**
  String get privacyAdsBody;

  /// Privacy dialog section
  ///
  /// In en, this message translates to:
  /// **'🔗 Third-party ad services'**
  String get privacyThirdPartyTitle;

  /// Privacy dialog text
  ///
  /// In en, this message translates to:
  /// **'Google AdMob may collect certain device information (such as IP address, device identifiers, and general location) to serve ads. This data is governed by Google\'s Privacy Policy. BMI Calculator & Health does not have access to this data.'**
  String get privacyThirdPartyBody;

  /// Privacy dialog section
  ///
  /// In en, this message translates to:
  /// **'🗑 Deleting your data'**
  String get privacyDeleteTitle;

  /// Privacy dialog text
  ///
  /// In en, this message translates to:
  /// **'Uninstalling the app permanently deletes all your health data from the device. There is no cloud backup — your data never leaves your phone.'**
  String get privacyDeleteBody;

  /// Dialog close button
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// History screen title
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// History filter period
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get periodAll;

  /// History filter period
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get period7d;

  /// History filter period
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get period30d;

  /// History filter period
  ///
  /// In en, this message translates to:
  /// **'Last 3 months'**
  String get period3m;

  /// History filter period
  ///
  /// In en, this message translates to:
  /// **'Last year'**
  String get period1y;

  /// Filter option meaning no category filter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// Removes all history filters
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// Empty state when filters hide every entry
  ///
  /// In en, this message translates to:
  /// **'No entries match your filter'**
  String get noEntriesMatch;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// Overline above the entry list
  ///
  /// In en, this message translates to:
  /// **'Entries  ·  {count}'**
  String entriesCount(int count);

  /// Overline above a filtered entry list
  ///
  /// In en, this message translates to:
  /// **'Entries  ·  {count} of {total}'**
  String entriesCountOf(int count, int total);

  /// Filter sheet title
  ///
  /// In en, this message translates to:
  /// **'Filter entries'**
  String get filterEntries;

  /// Filter sheet section
  ///
  /// In en, this message translates to:
  /// **'Time period'**
  String get timePeriod;

  /// Filter sheet section
  ///
  /// In en, this message translates to:
  /// **'BMI category'**
  String get bmiCategoryLabel;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Apply filter'**
  String get applyFilter;

  /// Empty history title
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// Empty history text
  ///
  /// In en, this message translates to:
  /// **'Start tracking today — every entry shapes your trend.'**
  String get noHistoryBody;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Add first entry'**
  String get addFirstEntry;

  /// Chart card label
  ///
  /// In en, this message translates to:
  /// **'BMI Trend'**
  String get bmiTrend;

  /// Number of entries in the chart
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry} other{{count} entries}}'**
  String entryCount(int count);

  /// Change in BMI, e.g. +6.8 BMI
  ///
  /// In en, this message translates to:
  /// **'{delta} BMI'**
  String bmiDelta(String delta);

  /// Goal screen title
  ///
  /// In en, this message translates to:
  /// **'Set a goal'**
  String get goalTitle;

  /// Current weight label
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get goalCurrent;

  /// Target weight label
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get goalTarget;

  /// Slider label
  ///
  /// In en, this message translates to:
  /// **'Target weight'**
  String get goalTargetWeight;

  /// Section label
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get goalTimeline;

  /// Timeline option
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week} other{{count} weeks}}'**
  String weeksCount(int count);

  /// Section label
  ///
  /// In en, this message translates to:
  /// **'Your plan'**
  String get goalYourPlan;

  /// Plan when target equals current weight
  ///
  /// In en, this message translates to:
  /// **'Maintain your current weight'**
  String get goalMaintain;

  /// Plan sentence; {amount} is highlighted
  ///
  /// In en, this message translates to:
  /// **'Lose {amount} in {weeks} weeks'**
  String goalLose(String amount, int weeks);

  /// Plan sentence; {amount} is highlighted
  ///
  /// In en, this message translates to:
  /// **'Gain {amount} in {weeks} weeks'**
  String goalGain(String amount, int weeks);

  /// Weekly rate of change
  ///
  /// In en, this message translates to:
  /// **'{value} kg / week'**
  String goalRate(String value);

  /// Pace sentence; {rate} is bold
  ///
  /// In en, this message translates to:
  /// **'That\'s {rate} — a safe, sustainable pace.'**
  String goalPaceSafe(String rate);

  /// Pace sentence; {rate} is bold
  ///
  /// In en, this message translates to:
  /// **'That\'s {rate} — faster than recommended. Try a longer timeline.'**
  String goalPaceFast(String rate);

  /// Label above the target date
  ///
  /// In en, this message translates to:
  /// **'Reach by'**
  String get goalReachBy;

  /// Label above the calorie change
  ///
  /// In en, this message translates to:
  /// **'Daily calories'**
  String get goalDailyCalories;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Start tracking goal'**
  String get goalStart;

  /// Tips screen title
  ///
  /// In en, this message translates to:
  /// **'Daily tips'**
  String get tipsTitle;

  /// Tip category
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get tipCatDiet;

  /// Tip category
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get tipCatExercise;

  /// Tip category
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get tipCatHydration;

  /// Tip category
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get tipCatLifestyle;

  /// Label on the featured tip
  ///
  /// In en, this message translates to:
  /// **'Today · {category}'**
  String tipToday(String category);

  /// Tip title
  ///
  /// In en, this message translates to:
  /// **'Half your plate, vegetables'**
  String get tip1Title;

  /// Tip text
  ///
  /// In en, this message translates to:
  /// **'A simple visual rule that crowds out higher-calorie foods without counting.'**
  String get tip1Body;

  /// Tip title
  ///
  /// In en, this message translates to:
  /// **'Water before coffee'**
  String get tip2Title;

  /// Tip text
  ///
  /// In en, this message translates to:
  /// **'Drink 200 ml of water before your first coffee to reset overnight dehydration.'**
  String get tip2Body;

  /// Tip title
  ///
  /// In en, this message translates to:
  /// **'A 10-min walk after meals'**
  String get tip3Title;

  /// Tip text
  ///
  /// In en, this message translates to:
  /// **'Studies show short post-meal walks meaningfully lower blood-glucose spikes.'**
  String get tip3Body;

  /// Tip title
  ///
  /// In en, this message translates to:
  /// **'Sleep is the multiplier'**
  String get tip4Title;

  /// Tip text
  ///
  /// In en, this message translates to:
  /// **'Under 7 hours raises hunger hormones the next day. Protect a wind-down ritual.'**
  String get tip4Body;

  /// Tip title
  ///
  /// In en, this message translates to:
  /// **'Protein first, every meal'**
  String get tip5Title;

  /// Tip text
  ///
  /// In en, this message translates to:
  /// **'Eat the protein on your plate before carbs — satiety lasts longer.'**
  String get tip5Body;

  /// Tip title
  ///
  /// In en, this message translates to:
  /// **'Strength training twice a week'**
  String get tip6Title;

  /// Tip text
  ///
  /// In en, this message translates to:
  /// **'Two sessions of resistance training weekly significantly improves metabolic health.'**
  String get tip6Body;

  /// Tip title
  ///
  /// In en, this message translates to:
  /// **'Hydrate with meals too'**
  String get tip7Title;

  /// Tip text
  ///
  /// In en, this message translates to:
  /// **'Sipping water during meals helps digestion and reduces overeating.'**
  String get tip7Body;

  /// Tip title
  ///
  /// In en, this message translates to:
  /// **'Stress fuels hunger'**
  String get tip8Title;

  /// Tip text
  ///
  /// In en, this message translates to:
  /// **'Cortisol spikes increase appetite. Try 5 minutes of deep breathing before eating.'**
  String get tip8Body;

  /// Result headline for BMI category 'under'
  ///
  /// In en, this message translates to:
  /// **'Your weight is below the healthy range'**
  String get adviceUnderHeadline;

  /// Result intro for BMI category 'under'
  ///
  /// In en, this message translates to:
  /// **'Being underweight can weaken immunity, reduce bone density, and affect energy levels. The goal is gradual, quality weight gain — not just eating more junk food.'**
  String get adviceUnderCopy;

  /// Action step 1 for BMI category 'under'
  ///
  /// In en, this message translates to:
  /// **'Eat calorie-dense whole foods: nuts, nut butter, avocado, eggs, whole milk, oats, and brown rice'**
  String get adviceUnderStep1;

  /// Action step 2 for BMI category 'under'
  ///
  /// In en, this message translates to:
  /// **'Add 300–500 extra kcal per day — enough to gain ~0.3–0.5 kg per week sustainably'**
  String get adviceUnderStep2;

  /// Action step 3 for BMI category 'under'
  ///
  /// In en, this message translates to:
  /// **'Eat 3 main meals + 2–3 snacks daily; never skip breakfast'**
  String get adviceUnderStep3;

  /// Action step 4 for BMI category 'under'
  ///
  /// In en, this message translates to:
  /// **'Include protein at every meal — aim for 1.2–1.6 g per kg of body weight to build muscle'**
  String get adviceUnderStep4;

  /// Action step 5 for BMI category 'under'
  ///
  /// In en, this message translates to:
  /// **'Do resistance training 2–3× per week (squats, push-ups, rows) so gained weight becomes muscle, not just fat'**
  String get adviceUnderStep5;

  /// Action step 6 for BMI category 'under'
  ///
  /// In en, this message translates to:
  /// **'If weight loss is unexplained or rapid, see a doctor — it may signal an underlying condition'**
  String get adviceUnderStep6;

  /// Medical note for BMI category 'under'
  ///
  /// In en, this message translates to:
  /// **'If you have been underweight for a long time, consult a doctor or registered dietitian for personalised support.'**
  String get adviceUnderNote;

  /// Result headline for BMI category 'normal'
  ///
  /// In en, this message translates to:
  /// **'You are in the healthy weight range'**
  String get adviceNormalHeadline;

  /// Result intro for BMI category 'normal'
  ///
  /// In en, this message translates to:
  /// **'A healthy BMI is a great foundation. The priority now is maintaining it through consistent habits — movement, quality nutrition, sleep, and stress management all matter.'**
  String get adviceNormalCopy;

  /// Action step 1 for BMI category 'normal'
  ///
  /// In en, this message translates to:
  /// **'Get 150–300 min of moderate aerobic activity per week: brisk walking, cycling, or swimming'**
  String get adviceNormalStep1;

  /// Action step 2 for BMI category 'normal'
  ///
  /// In en, this message translates to:
  /// **'Add 2–3 strength training sessions per week to preserve muscle mass as you age'**
  String get adviceNormalStep2;

  /// Action step 3 for BMI category 'normal'
  ///
  /// In en, this message translates to:
  /// **'Fill half your plate with vegetables and fruit at every main meal'**
  String get adviceNormalStep3;

  /// Action step 4 for BMI category 'normal'
  ///
  /// In en, this message translates to:
  /// **'Limit ultra-processed foods, added sugars, and alcohol — they add calories with little nutrition'**
  String get adviceNormalStep4;

  /// Action step 5 for BMI category 'normal'
  ///
  /// In en, this message translates to:
  /// **'Sleep 7–9 hours per night; poor sleep raises ghrelin (hunger hormone) and leads to overeating'**
  String get adviceNormalStep5;

  /// Action step 6 for BMI category 'normal'
  ///
  /// In en, this message translates to:
  /// **'Re-check your BMI every 4–6 weeks to catch any drift early'**
  String get adviceNormalStep6;

  /// Medical note for BMI category 'normal'
  ///
  /// In en, this message translates to:
  /// **'BMI is a screening tool, not a full health picture. Body composition, blood pressure, and blood sugar also matter.'**
  String get adviceNormalNote;

  /// Result headline for BMI category 'over'
  ///
  /// In en, this message translates to:
  /// **'Your weight is slightly above the healthy range'**
  String get adviceOverHeadline;

  /// Result intro for BMI category 'over'
  ///
  /// In en, this message translates to:
  /// **'Overweight raises the risk of type 2 diabetes, high blood pressure, and joint problems over time. Even a 5–10% reduction in body weight significantly lowers these risks.'**
  String get adviceOverCopy;

  /// Action step 1 for BMI category 'over'
  ///
  /// In en, this message translates to:
  /// **'Create a moderate calorie deficit of 300–500 kcal/day — target 0.3–0.5 kg loss per week (sustainable pace)'**
  String get adviceOverStep1;

  /// Action step 2 for BMI category 'over'
  ///
  /// In en, this message translates to:
  /// **'Walk 8,000–10,000 steps daily; start with 30 min brisk walks and build from there'**
  String get adviceOverStep2;

  /// Action step 3 for BMI category 'over'
  ///
  /// In en, this message translates to:
  /// **'Swap sugary drinks (soda, juice, energy drinks) for water, sparkling water, or unsweetened tea'**
  String get adviceOverStep3;

  /// Action step 4 for BMI category 'over'
  ///
  /// In en, this message translates to:
  /// **'Eat protein first at each meal — it increases satiety and reduces overall calorie intake'**
  String get adviceOverStep4;

  /// Action step 5 for BMI category 'over'
  ///
  /// In en, this message translates to:
  /// **'Fill half your plate with non-starchy vegetables (broccoli, spinach, cucumber, peppers) at lunch and dinner'**
  String get adviceOverStep5;

  /// Action step 6 for BMI category 'over'
  ///
  /// In en, this message translates to:
  /// **'Avoid eating within 2–3 hours of bedtime — late-night eating promotes fat storage'**
  String get adviceOverStep6;

  /// Medical note for BMI category 'over'
  ///
  /// In en, this message translates to:
  /// **'Crash diets backfire. A 300–500 kcal deficit is enough — losing weight slowly preserves muscle and is easier to maintain.'**
  String get adviceOverNote;

  /// Result headline for BMI category 'obese'
  ///
  /// In en, this message translates to:
  /// **'Your weight is in the obese range'**
  String get adviceObeseHeadline;

  /// Result intro for BMI category 'obese'
  ///
  /// In en, this message translates to:
  /// **'Obesity is associated with increased risk of heart disease, type 2 diabetes, sleep apnea, and joint pain. The good news: even modest weight loss of 5–10% of your body weight produces meaningful health improvements.'**
  String get adviceObeseCopy;

  /// Action step 1 for BMI category 'obese'
  ///
  /// In en, this message translates to:
  /// **'Set your first target at 5–10% of current weight — for an 100 kg person, that is just 5–10 kg'**
  String get adviceObeseStep1;

  /// Action step 2 for BMI category 'obese'
  ///
  /// In en, this message translates to:
  /// **'Aim for 0.5–1.0 kg loss per week; faster rates typically cause muscle loss and a rebound'**
  String get adviceObeseStep2;

  /// Action step 3 for BMI category 'obese'
  ///
  /// In en, this message translates to:
  /// **'Start with low-impact daily movement: 30 min walking, swimming, or stationary cycling — knees and joints will thank you'**
  String get adviceObeseStep3;

  /// Action step 4 for BMI category 'obese'
  ///
  /// In en, this message translates to:
  /// **'Cut out ultra-processed foods, fried food, and added sugars first — these alone can reduce 500+ kcal/day'**
  String get adviceObeseStep4;

  /// Action step 5 for BMI category 'obese'
  ///
  /// In en, this message translates to:
  /// **'Build meals around protein (chicken, fish, legumes, eggs) and vegetables; they keep you full longer'**
  String get adviceObeseStep5;

  /// Action step 6 for BMI category 'obese'
  ///
  /// In en, this message translates to:
  /// **'See your doctor for a baseline check — blood pressure, blood sugar, and cholesterol — and ask about structured support programs'**
  String get adviceObeseStep6;

  /// Medical note for BMI category 'obese'
  ///
  /// In en, this message translates to:
  /// **'BMI alone does not diagnose health. Speak with a doctor or registered dietitian for a plan tailored to your medical history.'**
  String get adviceObeseNote;

  /// Progress label in the profile setup
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(int current, int total);

  /// Postpones the profile setup
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// Previous step
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Last step of the profile setup
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// Saves edited profile details
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Settings row and profile editor title
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get personalDetails;

  /// Shown when a profile value is empty
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// Subtitle on the first profile setup step
  ///
  /// In en, this message translates to:
  /// **'A few quick questions so the app can tailor workouts and targets to you.'**
  String get setupIntro;

  /// Profile setup question
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get setupNameTitle;

  /// Name field placeholder
  ///
  /// In en, this message translates to:
  /// **'Your name (optional)'**
  String get setupNameHint;

  /// Profile setup question
  ///
  /// In en, this message translates to:
  /// **'What is your gender?'**
  String get setupGenderTitle;

  /// Explains why gender is asked
  ///
  /// In en, this message translates to:
  /// **'We use this for calorie and body-fat formulas and to show exercise videos with a matching trainer. You can change it any time.'**
  String get setupGenderBody;

  /// Asked when gender is Other
  ///
  /// In en, this message translates to:
  /// **'Calculations based on'**
  String get setupFormulaTitle;

  /// Explains the formula basis question
  ///
  /// In en, this message translates to:
  /// **'Calorie and body-fat formulas differ for male and female bodies. Pick the one that fits you best.'**
  String get setupFormulaBody;

  /// Formula basis option
  ///
  /// In en, this message translates to:
  /// **'Male body'**
  String get bodyMale;

  /// Formula basis option
  ///
  /// In en, this message translates to:
  /// **'Female body'**
  String get bodyFemale;

  /// Demonstrator preference question
  ///
  /// In en, this message translates to:
  /// **'Exercise videos show'**
  String get setupDemonstratorTitle;

  /// Demonstrator option
  ///
  /// In en, this message translates to:
  /// **'Match my profile'**
  String get demonstratorAuto;

  /// Demonstrator option
  ///
  /// In en, this message translates to:
  /// **'Male trainer'**
  String get demonstratorMale;

  /// Demonstrator option
  ///
  /// In en, this message translates to:
  /// **'Female trainer'**
  String get demonstratorFemale;

  /// Profile setup step title
  ///
  /// In en, this message translates to:
  /// **'About your body'**
  String get setupBodyTitle;

  /// Profile setup question
  ///
  /// In en, this message translates to:
  /// **'What is your main goal?'**
  String get setupGoalTitle;

  /// Fitness goal
  ///
  /// In en, this message translates to:
  /// **'Lose fat'**
  String get goalLoseFat;

  /// Fitness goal description
  ///
  /// In en, this message translates to:
  /// **'Burn fat while keeping muscle'**
  String get goalLoseFatBody;

  /// Fitness goal
  ///
  /// In en, this message translates to:
  /// **'Build muscle'**
  String get goalBuildMuscle;

  /// Fitness goal description
  ///
  /// In en, this message translates to:
  /// **'Gain size and shape'**
  String get goalBuildMuscleBody;

  /// Fitness goal
  ///
  /// In en, this message translates to:
  /// **'Get stronger'**
  String get goalGetStronger;

  /// Fitness goal description
  ///
  /// In en, this message translates to:
  /// **'Lift heavier, step by step'**
  String get goalGetStrongerBody;

  /// Fitness goal
  ///
  /// In en, this message translates to:
  /// **'Stay fit & healthy'**
  String get goalStayFit;

  /// Fitness goal description
  ///
  /// In en, this message translates to:
  /// **'Move more and feel better'**
  String get goalStayFitBody;

  /// Profile setup question
  ///
  /// In en, this message translates to:
  /// **'How experienced are you with training?'**
  String get setupExperienceTitle;

  /// Experience level
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get expBeginner;

  /// Experience description
  ///
  /// In en, this message translates to:
  /// **'New to training or returning after a long break'**
  String get expBeginnerBody;

  /// Experience level
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get expIntermediate;

  /// Experience description
  ///
  /// In en, this message translates to:
  /// **'Training regularly for 6+ months'**
  String get expIntermediateBody;

  /// Experience level
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get expAdvanced;

  /// Experience description
  ///
  /// In en, this message translates to:
  /// **'Several years of consistent training'**
  String get expAdvancedBody;

  /// Profile setup question
  ///
  /// In en, this message translates to:
  /// **'Where will you train?'**
  String get setupEquipmentTitle;

  /// Equipment option
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get equipGym;

  /// Equipment description
  ///
  /// In en, this message translates to:
  /// **'Full access to machines and free weights'**
  String get equipGymBody;

  /// Equipment option
  ///
  /// In en, this message translates to:
  /// **'Home with some equipment'**
  String get equipHome;

  /// Equipment description
  ///
  /// In en, this message translates to:
  /// **'Dumbbells, bands or a bench'**
  String get equipHomeBody;

  /// Equipment option
  ///
  /// In en, this message translates to:
  /// **'No equipment'**
  String get equipNone;

  /// Equipment description
  ///
  /// In en, this message translates to:
  /// **'Bodyweight exercises only'**
  String get equipNoneBody;

  /// Profile setup question
  ///
  /// In en, this message translates to:
  /// **'How many days a week can you train?'**
  String get setupDaysTitle;

  /// Training frequency
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day a week} other{{count} days a week}}'**
  String daysPerWeek(int count);

  /// Hint below the training days choice
  ///
  /// In en, this message translates to:
  /// **'3–4 days is a great start for most people.'**
  String get setupDaysTip;

  /// Settings section
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get sectionProfile;

  /// Bottom nav tab: body tracking
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get navBody;

  /// Body screen title
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get bodyTitle;

  /// Button and dialog title
  ///
  /// In en, this message translates to:
  /// **'Log weight'**
  String get logWeight;

  /// Weight card empty state
  ///
  /// In en, this message translates to:
  /// **'Log your weight regularly to see your trend.'**
  String get weightEmpty;

  /// Smoothed weight under the latest weigh-in
  ///
  /// In en, this message translates to:
  /// **'7-day average: {value}'**
  String weightAverage(String value);

  /// Date of the latest weigh-in
  ///
  /// In en, this message translates to:
  /// **'Last logged {date}'**
  String lastLogged(String date);

  /// Card title
  ///
  /// In en, this message translates to:
  /// **'Body fat (estimate)'**
  String get bodyFatTitle;

  /// Shown when measurements are missing (male formula)
  ///
  /// In en, this message translates to:
  /// **'Add neck and waist measurements to estimate your body fat.'**
  String get bodyFatNeedsMale;

  /// Shown when measurements are missing (female formula)
  ///
  /// In en, this message translates to:
  /// **'Add neck, waist and hip measurements to estimate your body fat.'**
  String get bodyFatNeedsFemale;

  /// Explains the body-fat number
  ///
  /// In en, this message translates to:
  /// **'US Navy tape method — an estimate, not a medical measurement.'**
  String get bodyFatMethod;

  /// Card and sheet title
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get measurementsTitle;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Add measurements'**
  String get addMeasurements;

  /// Measurements card empty state
  ///
  /// In en, this message translates to:
  /// **'Track your waist, hips and more to see changes the scale misses.'**
  String get measurementsEmpty;

  /// Body measurement
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get measureNeck;

  /// Body measurement (male/other wording)
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get measureChest;

  /// Body measurement (female wording)
  ///
  /// In en, this message translates to:
  /// **'Bust'**
  String get measureBust;

  /// Body measurement
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get measureWaist;

  /// Body measurement
  ///
  /// In en, this message translates to:
  /// **'Hips'**
  String get measureHips;

  /// Body measurement
  ///
  /// In en, this message translates to:
  /// **'Arm'**
  String get measureArm;

  /// Body measurement
  ///
  /// In en, this message translates to:
  /// **'Thigh'**
  String get measureThigh;

  /// Instructions in the measurements sheet
  ///
  /// In en, this message translates to:
  /// **'Measure relaxed, at the widest point, without pulling the tape tight.'**
  String get measureHint;

  /// Validation error
  ///
  /// In en, this message translates to:
  /// **'Measurements must be between 5 and 300 cm (2–118 in).'**
  String get measureRangeError;

  /// Card title / link
  ///
  /// In en, this message translates to:
  /// **'BMI history'**
  String get bmiHistory;

  /// Link to a full list
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// BMI card empty state
  ///
  /// In en, this message translates to:
  /// **'No BMI saved yet'**
  String get noBmiYet;

  /// Footer disclaimer on body screens
  ///
  /// In en, this message translates to:
  /// **'For general wellness only. Not medical advice.'**
  String get wellnessDisclaimer;

  /// Bottom nav tab: workouts
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get navTrain;

  /// Train screen title
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get trainTitle;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Start empty workout'**
  String get startEmptyWorkout;

  /// Card shown while a workout is in progress
  ///
  /// In en, this message translates to:
  /// **'Resume workout'**
  String get resumeWorkout;

  /// Subtitle of the resume card
  ///
  /// In en, this message translates to:
  /// **'Workout in progress · {elapsed}'**
  String workoutInProgress(String elapsed);

  /// Button and screen title
  ///
  /// In en, this message translates to:
  /// **'Exercise library'**
  String get exerciseLibrary;

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get routines;

  /// Routines empty state
  ///
  /// In en, this message translates to:
  /// **'Save a workout as a routine to repeat it with one tap.'**
  String get routinesEmpty;

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Recent workouts'**
  String get recentWorkouts;

  /// History empty state
  ///
  /// In en, this message translates to:
  /// **'Your finished workouts will appear here.'**
  String get noWorkoutsYet;

  /// Count of exercises
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 exercise} other{{count} exercises}}'**
  String exercisesCount(int count);

  /// Duration in minutes
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutesShort(int count);

  /// Personal records in a workout
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 PR} other{{count} PRs}}'**
  String prCount(int count);

  /// Total weight lifted
  ///
  /// In en, this message translates to:
  /// **'Volume {value}'**
  String volumeLabel(String value);

  /// Name of a workout started without a routine
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workoutDefaultName;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get addExercise;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get addSet;

  /// Column header
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get setLabel;

  /// Column header: last time's set
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousLabel;

  /// Column header
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get repsLabel;

  /// Ends the workout
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishWorkout;

  /// Deletes the active workout
  ///
  /// In en, this message translates to:
  /// **'Discard workout'**
  String get discardWorkout;

  /// Confirmation
  ///
  /// In en, this message translates to:
  /// **'Discard this workout? Logged sets will be deleted.'**
  String get discardConfirm;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// Menu item
  ///
  /// In en, this message translates to:
  /// **'Remove exercise'**
  String get removeExercise;

  /// Rest countdown
  ///
  /// In en, this message translates to:
  /// **'Rest {time}'**
  String restTimer(String time);

  /// Skips the rest timer
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip2;

  /// Summary dialog title
  ///
  /// In en, this message translates to:
  /// **'Workout complete'**
  String get workoutComplete;

  /// Celebration in the summary
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{New personal record!} other{{count} new personal records!}}'**
  String newPrs(int count);

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Save as routine'**
  String get saveAsRoutine;

  /// Text field label
  ///
  /// In en, this message translates to:
  /// **'Routine name'**
  String get routineName;

  /// Closes a dialog
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Snack bar after finishing an empty workout
  ///
  /// In en, this message translates to:
  /// **'No sets were ticked, so the workout was not saved.'**
  String get nothingLogged;

  /// Search field hint
  ///
  /// In en, this message translates to:
  /// **'Search exercises'**
  String get searchExercises;

  /// Filter chip: only exercises for the user's equipment
  ///
  /// In en, this message translates to:
  /// **'My equipment'**
  String get myEquipmentOnly;

  /// Filter chip: any muscle
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allMuscles;

  /// Section title on the exercise page
  ///
  /// In en, this message translates to:
  /// **'How to do it'**
  String get howTo;

  /// Placeholder until the demonstrator clip is filmed
  ///
  /// In en, this message translates to:
  /// **'Video coming soon'**
  String get videoComingSoon;

  /// Which demonstrator the video shows
  ///
  /// In en, this message translates to:
  /// **'With {trainer}'**
  String videoWithTrainer(String trainer);

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Target muscles'**
  String get targetMuscles;

  /// Muscle group
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get muscleChest;

  /// Muscle group (upper/lower back)
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get muscleBack;

  /// Muscle group
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get muscleShoulders;

  /// Muscle group
  ///
  /// In en, this message translates to:
  /// **'Biceps'**
  String get muscleBiceps;

  /// Muscle group
  ///
  /// In en, this message translates to:
  /// **'Triceps'**
  String get muscleTriceps;

  /// Muscle group
  ///
  /// In en, this message translates to:
  /// **'Quads'**
  String get muscleQuads;

  /// Muscle group
  ///
  /// In en, this message translates to:
  /// **'Hamstrings'**
  String get muscleHamstrings;

  /// Muscle group
  ///
  /// In en, this message translates to:
  /// **'Glutes'**
  String get muscleGlutes;

  /// Muscle group
  ///
  /// In en, this message translates to:
  /// **'Calves'**
  String get muscleCalves;

  /// Muscle group
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get muscleCore;

  /// Equipment
  ///
  /// In en, this message translates to:
  /// **'Barbell'**
  String get eqBarbell;

  /// Equipment
  ///
  /// In en, this message translates to:
  /// **'Dumbbell'**
  String get eqDumbbell;

  /// Equipment
  ///
  /// In en, this message translates to:
  /// **'Machine'**
  String get eqMachine;

  /// Equipment
  ///
  /// In en, this message translates to:
  /// **'Cable'**
  String get eqCable;

  /// Equipment
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get eqBodyweight;

  /// Equipment
  ///
  /// In en, this message translates to:
  /// **'Band'**
  String get eqBand;

  /// Equipment
  ///
  /// In en, this message translates to:
  /// **'Kettlebell'**
  String get eqKettlebell;

  /// Bottom nav tab: home dashboard
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// Bottom nav tab: calories and water
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get navFuel;

  /// Fuel screen title
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get fuelTitle;

  /// Card title
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get caloriesTitle;

  /// Calories eaten of target
  ///
  /// In en, this message translates to:
  /// **'{eaten} / {target} kcal'**
  String kcalOf(int eaten, int target);

  /// Calories remaining today
  ///
  /// In en, this message translates to:
  /// **'{count} kcal left'**
  String kcalLeft(int count);

  /// Calories over target today
  ///
  /// In en, this message translates to:
  /// **'{count} kcal over'**
  String kcalOver(int count);

  /// Macronutrient
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get macroProtein;

  /// Macronutrient
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get macroCarbs;

  /// Macronutrient
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get macroFat;

  /// Grams eaten of target
  ///
  /// In en, this message translates to:
  /// **'{eaten} / {target} g'**
  String gramsOf(int eaten, int target);

  /// Daily grams target
  ///
  /// In en, this message translates to:
  /// **'{target} g'**
  String gramsTarget(int target);

  /// Button and dialog title
  ///
  /// In en, this message translates to:
  /// **'Log food'**
  String get logFood;

  /// Food name field
  ///
  /// In en, this message translates to:
  /// **'What did you eat? (optional)'**
  String get foodName;

  /// Calories field
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get foodKcal;

  /// Protein field
  ///
  /// In en, this message translates to:
  /// **'Protein (g, optional)'**
  String get foodProtein;

  /// Validation error
  ///
  /// In en, this message translates to:
  /// **'Enter calories between 1 and 5000.'**
  String get foodKcalError;

  /// Food list empty state
  ///
  /// In en, this message translates to:
  /// **'Nothing logged today. Quick-add calories after each meal.'**
  String get foodEmpty;

  /// Name shown for an unnamed food entry
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get foodUnnamed;

  /// Card title
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get waterTitle;

  /// Water drunk of goal
  ///
  /// In en, this message translates to:
  /// **'{drunk} / {goal} ml'**
  String waterOf(int drunk, int goal);

  /// Adds a glass of water
  ///
  /// In en, this message translates to:
  /// **'+250 ml'**
  String get addGlass;

  /// Removes a glass of water
  ///
  /// In en, this message translates to:
  /// **'−250 ml'**
  String get removeGlass;

  /// Explains how the targets are calculated
  ///
  /// In en, this message translates to:
  /// **'Based on your age, height, weight, gender, goal and training days (Mifflin-St Jeor). A starting point, not a medical prescription.'**
  String get targetsExplain;

  /// Shown when the profile has no goal
  ///
  /// In en, this message translates to:
  /// **'Set your goal in Personal details for personalised targets.'**
  String get completeProfileForTargets;

  /// Today header with the user's name
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String greeting(String name);

  /// Today header without a name
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get greetingNoName;

  /// Weekly training progress
  ///
  /// In en, this message translates to:
  /// **'{done} of {target} workouts this week'**
  String thisWeekWorkouts(int done, int target);

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Start workout'**
  String get startWorkout;

  /// Card label
  ///
  /// In en, this message translates to:
  /// **'Latest weight'**
  String get latestWeight;

  /// Card label
  ///
  /// In en, this message translates to:
  /// **'Tip of the day'**
  String get tipOfTheDay;

  /// Link to all tips
  ///
  /// In en, this message translates to:
  /// **'More tips'**
  String get moreTips;

  /// Quick action
  ///
  /// In en, this message translates to:
  /// **'Calculate BMI'**
  String get calculateBmiShort;

  /// Android notification channel name
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminderChannel;

  /// Daily reminder notification title
  ///
  /// In en, this message translates to:
  /// **'Time for a quick check-in'**
  String get dailyReminderTitle;

  /// Daily reminder notification text
  ///
  /// In en, this message translates to:
  /// **'Log today\'s weight, water and meals to keep your trend accurate.'**
  String get dailyReminderBody;

  /// Weekly reminder notification title
  ///
  /// In en, this message translates to:
  /// **'Your weekly check-in'**
  String get weeklyReminderTitle;

  /// Weekly reminder notification text
  ///
  /// In en, this message translates to:
  /// **'See how your week went and plan your next workouts.'**
  String get weeklyReminderBody;

  /// When the daily reminder fires
  ///
  /// In en, this message translates to:
  /// **'Every day at 8:00 PM'**
  String get dailyReminderAt;

  /// When the weekly reminder fires
  ///
  /// In en, this message translates to:
  /// **'Sundays at 10:00 AM'**
  String get weeklyReminderAt;

  /// Shown when the user denies notification permission
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for this app. Turn them on in your phone\'s settings to get reminders.'**
  String get notificationsDenied;

  /// Card title
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get stepsTitle;

  /// Steps of daily goal
  ///
  /// In en, this message translates to:
  /// **'{steps} / {goal}'**
  String stepsOf(int steps, int goal);

  /// Explains the steps connection (Android)
  ///
  /// In en, this message translates to:
  /// **'See your daily steps here. Steps are read from Health Connect and stay on your phone.'**
  String get stepsConnectBody;

  /// Explains the steps connection (iOS)
  ///
  /// In en, this message translates to:
  /// **'See your daily steps here. Steps are read from Apple Health and stay on your phone.'**
  String get stepsConnectBodyIos;

  /// Button that asks for step access
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connectSteps;

  /// Button when Health Connect is missing
  ///
  /// In en, this message translates to:
  /// **'Get Health Connect'**
  String get installHealthConnect;

  /// Shown when Health Connect is missing
  ///
  /// In en, this message translates to:
  /// **'Step counting needs Google\'s Health Connect app.'**
  String get stepsNeedsInstall;

  /// Android notification channel for gym check-in and tracking
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityChannel;

  /// Movement timeline screen title
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get movementTitle;

  /// Today card title for the timeline
  ///
  /// In en, this message translates to:
  /// **'Your day'**
  String get movementCardTitle;

  /// Explains the timeline before it is turned on
  ///
  /// In en, this message translates to:
  /// **'Turn on tracking to see where you went, how long you stayed and how far you walked. Your location never leaves this phone.'**
  String get trackingOff;

  /// Status label
  ///
  /// In en, this message translates to:
  /// **'Tracking is on'**
  String get trackingOn;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Start tracking'**
  String get startTracking;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Stop tracking'**
  String get stopTracking;

  /// Ongoing notification while tracking
  ///
  /// In en, this message translates to:
  /// **'Tracking your day'**
  String get trackingNotificationTitle;

  /// Ongoing notification text
  ///
  /// In en, this message translates to:
  /// **'Building your private timeline. Tap to open.'**
  String get trackingNotificationBody;

  /// Shown when location permission is denied
  ///
  /// In en, this message translates to:
  /// **'Location access is off. Allow it in your phone\'s settings to build your timeline.'**
  String get locationDenied;

  /// Shown when GPS is off
  ///
  /// In en, this message translates to:
  /// **'Turn on location (GPS) on your phone to track your day.'**
  String get locationServiceOff;

  /// Number of places visited today
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No places yet} =1{1 place} other{{count} places}}'**
  String placesVisited(int count);

  /// Distance
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String distanceKm(String km);

  /// Duration over an hour
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHm(int hours, int minutes);

  /// Visit with no label
  ///
  /// In en, this message translates to:
  /// **'Unnamed place'**
  String get unnamedPlace;

  /// Travel mode
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get modeWalk;

  /// Travel mode
  ///
  /// In en, this message translates to:
  /// **'Run / cycle'**
  String get modeRun;

  /// Travel mode
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get modeVehicle;

  /// Button and dialog title
  ///
  /// In en, this message translates to:
  /// **'Name this place'**
  String get namePlace;

  /// Text field label
  ///
  /// In en, this message translates to:
  /// **'Place name'**
  String get placeName;

  /// Checkbox: mark the place as the user's gym
  ///
  /// In en, this message translates to:
  /// **'This is my gym'**
  String get thisIsMyGym;

  /// Timeline empty state
  ///
  /// In en, this message translates to:
  /// **'No movement recorded for this day.'**
  String get noTimelineYet;

  /// Menu item
  ///
  /// In en, this message translates to:
  /// **'Delete this day'**
  String get deleteDay;

  /// Menu item
  ///
  /// In en, this message translates to:
  /// **'Delete all location history'**
  String get deleteAllLocation;

  /// Confirmation
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes the selected location history from this phone.'**
  String get deleteLocationConfirm;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Weekly gym time
  ///
  /// In en, this message translates to:
  /// **'Gym time this week: {time}'**
  String gymTimeWeek(String time);

  /// Gym check-in notification title
  ///
  /// In en, this message translates to:
  /// **'You\'re at the gym 💪'**
  String get gymCheckInTitle;

  /// Gym check-in notification text
  ///
  /// In en, this message translates to:
  /// **'Start today\'s workout? Open the app to begin logging.'**
  String get gymCheckInBody;

  /// Explains the limitation of tracking
  ///
  /// In en, this message translates to:
  /// **'Tracking pauses if you close the app from recent apps.'**
  String get trackingLimitNote;

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get programs;

  /// Program frequency
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day a week} other{{count} days a week}}'**
  String programDays(int count);

  /// Starts a workout for one program day
  ///
  /// In en, this message translates to:
  /// **'Start {day}'**
  String startDay(String day);

  /// Badge on the suggested program
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// Next-session suggestion: heavier
  ///
  /// In en, this message translates to:
  /// **'Try {weight} × {reps}'**
  String suggestionIncrease(String weight, int reps);

  /// Next-session suggestion: one more rep
  ///
  /// In en, this message translates to:
  /// **'Aim for {reps} reps at {weight}'**
  String suggestionAddRep(String weight, int reps);

  /// Next-session suggestion: back off
  ///
  /// In en, this message translates to:
  /// **'Reset to {weight} × {reps}'**
  String suggestionDeload(String weight, int reps);

  /// Suggestion for bodyweight exercises
  ///
  /// In en, this message translates to:
  /// **'Aim for {reps} reps'**
  String suggestionRepsOnly(int reps);

  /// Heatmap card title
  ///
  /// In en, this message translates to:
  /// **'Muscles this week'**
  String get muscleMapTitle;

  /// Heatmap explanation
  ///
  /// In en, this message translates to:
  /// **'Hard sets per muscle (secondary muscles count half). About 10 a week builds muscle.'**
  String get muscleMapHint;

  /// Lists under-trained muscles
  ///
  /// In en, this message translates to:
  /// **'Needs more work: {muscles}'**
  String undertrained(String muscles);

  /// Weekly sets for a muscle
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String setsCount(String count);

  /// Camera rep counter title and button
  ///
  /// In en, this message translates to:
  /// **'Rep counter'**
  String get repCounter;

  /// Setup hint
  ///
  /// In en, this message translates to:
  /// **'Place your phone so your whole body is visible from the side, then start moving.'**
  String get repCounterIntro;

  /// Privacy note on the camera screen
  ///
  /// In en, this message translates to:
  /// **'Analysed on your phone. Nothing is recorded or uploaded.'**
  String get repCounterPrivacy;

  /// Live rep count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 rep} other{{count} reps}}'**
  String repsCounted(int count);

  /// Form cue
  ///
  /// In en, this message translates to:
  /// **'Go lower'**
  String get cueGoLower;

  /// Form cue
  ///
  /// In en, this message translates to:
  /// **'Keep your hips up'**
  String get cueKeepHipsUp;

  /// Form cue
  ///
  /// In en, this message translates to:
  /// **'Use the full range'**
  String get cueFullExtension;

  /// Form cue
  ///
  /// In en, this message translates to:
  /// **'Step into the frame'**
  String get cueStepIntoFrame;

  /// Counted exercise
  ///
  /// In en, this message translates to:
  /// **'Squat'**
  String get countSquat;

  /// Counted exercise
  ///
  /// In en, this message translates to:
  /// **'Push-up'**
  String get countPushUp;

  /// Counted exercise
  ///
  /// In en, this message translates to:
  /// **'Curl'**
  String get countCurl;

  /// Counted exercise
  ///
  /// In en, this message translates to:
  /// **'Shoulder press'**
  String get countShoulderPress;

  /// Counted exercise
  ///
  /// In en, this message translates to:
  /// **'Lunge'**
  String get countLunge;

  /// Resets the rep count
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetCount;

  /// Adds the counted reps as a set
  ///
  /// In en, this message translates to:
  /// **'Log set'**
  String get logSet;

  /// Snack bar
  ///
  /// In en, this message translates to:
  /// **'Set logged: {count} reps'**
  String setLogged(int count);

  /// Camera permission denied
  ///
  /// In en, this message translates to:
  /// **'Camera access is off. Allow it in your phone\'s settings to count reps.'**
  String get cameraDenied;

  /// No camera
  ///
  /// In en, this message translates to:
  /// **'No camera is available on this device.'**
  String get cameraUnavailable;

  /// Settings row that opens the paywall
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get goPremium;

  /// Settings row value when premium
  ///
  /// In en, this message translates to:
  /// **'Premium active'**
  String get premiumActive;

  /// Small label above the paywall headline
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumBadge;

  /// Paywall headline
  ///
  /// In en, this message translates to:
  /// **'Train without interruptions'**
  String get premiumHeadline;

  /// Paywall intro
  ///
  /// In en, this message translates to:
  /// **'Remove every ad and help fund new features.'**
  String get premiumBody;

  /// Paywall headline after purchase
  ///
  /// In en, this message translates to:
  /// **'Welcome to Premium!'**
  String get premiumWelcome;

  /// Paywall text after purchase
  ///
  /// In en, this message translates to:
  /// **'Ads are removed. Thank you for supporting BMI Health.'**
  String get premiumThanksBody;

  /// Premium benefit
  ///
  /// In en, this message translates to:
  /// **'No banner or full-screen ads'**
  String get premiumFeatureNoAds;

  /// Premium benefit
  ///
  /// In en, this message translates to:
  /// **'Support an independent app'**
  String get premiumFeatureSupport;

  /// Premium benefit
  ///
  /// In en, this message translates to:
  /// **'Same privacy: your health data stays on your phone'**
  String get premiumFeaturePrivacy;

  /// Plan name
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get planMonthly;

  /// Plan name
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get planYearly;

  /// Plan name
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get planLifetime;

  /// Plan subtitle
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get planPerMonth;

  /// Yearly plan subtitle, monthly equivalent
  ///
  /// In en, this message translates to:
  /// **'{price} / month, billed yearly'**
  String planYearlyPerMonth(String price);

  /// Plan subtitle
  ///
  /// In en, this message translates to:
  /// **'one-time payment'**
  String get planOneTime;

  /// Badge on the yearly plan
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get bestValue;

  /// Restore purchases
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// Button while a purchase runs
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get processing;

  /// Purchase button
  ///
  /// In en, this message translates to:
  /// **'Upgrade now'**
  String get upgradeNow;

  /// Button after purchase
  ///
  /// In en, this message translates to:
  /// **'You\'re all set!'**
  String get allSet;

  /// Error
  ///
  /// In en, this message translates to:
  /// **'The store is not available on this device.'**
  String get storeUnavailable;

  /// Shown until store prices load
  ///
  /// In en, this message translates to:
  /// **'Loading prices…'**
  String get pricesLoading;

  /// Legal note under the purchase button
  ///
  /// In en, this message translates to:
  /// **'Subscriptions renew automatically until cancelled. Cancel anytime in your Google Play or App Store subscriptions. No tracking. No data sold.'**
  String get renewNote;

  /// Note after purchase
  ///
  /// In en, this message translates to:
  /// **'Thank you for supporting BMI Health.'**
  String get thanksNote;

  /// Card title
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get recoveryTitle;

  /// Recovery score
  ///
  /// In en, this message translates to:
  /// **'{score} / 100'**
  String recoveryScore(int score);

  /// Recovery advice
  ///
  /// In en, this message translates to:
  /// **'Good day to train hard'**
  String get adviceTrainHard;

  /// Recovery advice
  ///
  /// In en, this message translates to:
  /// **'Train light today: easier sets or cardio'**
  String get adviceTrainLight;

  /// Recovery advice
  ///
  /// In en, this message translates to:
  /// **'Rest or gentle movement today'**
  String get adviceRest;

  /// Main reason for a lower score
  ///
  /// In en, this message translates to:
  /// **'Held back by short sleep'**
  String get limiterSleep;

  /// Main reason for a lower score
  ///
  /// In en, this message translates to:
  /// **'Resting heart rate is higher than usual'**
  String get limiterRestingHr;

  /// Main reason for a lower score
  ///
  /// In en, this message translates to:
  /// **'Heart-rate variability is lower than usual'**
  String get limiterHrv;

  /// Main reason for a lower score
  ///
  /// In en, this message translates to:
  /// **'You\'ve trained much more than usual lately'**
  String get limiterLoad;

  /// Main reason for a lower score
  ///
  /// In en, this message translates to:
  /// **'You\'re feeling sore'**
  String get limiterSoreness;

  /// Soreness check-in
  ///
  /// In en, this message translates to:
  /// **'How sore are you today?'**
  String get sorenessQuestion;

  /// Soreness scale hint
  ///
  /// In en, this message translates to:
  /// **'1 = not at all, 5 = very'**
  String get sorenessScale;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Connect sleep & heart data'**
  String get connectSleepHeart;

  /// Explains the connection
  ///
  /// In en, this message translates to:
  /// **'Optional: adds sleep, resting heart rate and HRV from your watch or phone for a more accurate score.'**
  String get connectSleepHeartBody;

  /// Shown with no data
  ///
  /// In en, this message translates to:
  /// **'Answer the check-in or log a workout to see your recovery.'**
  String get recoveryEmpty;

  /// Card section title
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleepTitle;

  /// Last night's sleep
  ///
  /// In en, this message translates to:
  /// **'Last night: {time}'**
  String sleepLastNight(String time);

  /// Average sleep
  ///
  /// In en, this message translates to:
  /// **'7-night average: {time}'**
  String sleepAverage(String time);

  /// Sleep debt
  ///
  /// In en, this message translates to:
  /// **'Sleep debt this week: {time}'**
  String sleepDebt(String time);

  /// Sleep insight
  ///
  /// In en, this message translates to:
  /// **'Your bedtimes are regular, which helps sleep quality.'**
  String get sleepRegular;

  /// Sleep insight
  ///
  /// In en, this message translates to:
  /// **'Bedtimes vary a lot. A steadier bedtime usually improves sleep.'**
  String get sleepIrregular;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ur': return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
