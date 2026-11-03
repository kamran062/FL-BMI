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

  /// Privacy dialog text. Must be updated if crash reporting is added.
  ///
  /// In en, this message translates to:
  /// **'We do not use any analytics SDKs, crash reporters, or user-tracking tools. We have no idea who you are, and we prefer it that way.'**
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
