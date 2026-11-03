// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BMI Calculator & Health';

  @override
  String get appTagline => 'Know Your Body. Improve Your Health.';

  @override
  String get navCalculate => 'Calculate';

  @override
  String get navHistory => 'History';

  @override
  String get navTips => 'Tips';

  @override
  String get navSettings => 'Settings';

  @override
  String get categoryUnder => 'Underweight';

  @override
  String get categoryNormal => 'Normal';

  @override
  String get categoryOver => 'Overweight';

  @override
  String get categoryObese => 'Obese';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderMale => 'Male';

  @override
  String get genderOther => 'Other';

  @override
  String get homeTitle => 'BMI Calculator';

  @override
  String get homeSubtitle => 'Know your body. Track your health.';

  @override
  String get fieldHeight => 'Height';

  @override
  String get fieldWeight => 'Weight';

  @override
  String get fieldAge => 'Age';

  @override
  String get fieldGender => 'Gender';

  @override
  String get yearsShort => 'yrs';

  @override
  String get calculateBmi => 'Calculate BMI';

  @override
  String lastResult(String date) {
    return 'Last result · $date';
  }

  @override
  String bmiValue(String value) {
    return 'BMI $value';
  }

  @override
  String get errorEnterHeightWeight => 'Enter your height and weight to calculate.';

  @override
  String get errorHeightRange => 'Enter a height between 50 and 272 cm (20–107 in).';

  @override
  String get errorWeightRange => 'Enter a weight between 2 and 635 kg (5–1400 lbs).';

  @override
  String get resultTitle => 'Your result';

  @override
  String get recommendation => 'Recommendation';

  @override
  String get healthyRange => 'Healthy range';

  @override
  String get saveResult => 'Save result';

  @override
  String get setGoal => 'Set goal';

  @override
  String get shareResult => 'Share result';

  @override
  String get shareTitle => 'Share';

  @override
  String get saveImage => 'Save image';

  @override
  String get sharing => 'Sharing…';

  @override
  String shareText(String value) {
    return 'My BMI is $value — tracked with BMI Calculator & Health';
  }

  @override
  String get shareError => 'Could not share right now. Please try again.';

  @override
  String get shareCardToday => 'today';

  @override
  String get shareCardHealthy => 'Within the healthy range — keeping it up.';

  @override
  String get shareCardTracking => 'Tracking my body, one week at a time.';

  @override
  String get onboardTitle1 => 'Track your health easily';

  @override
  String get onboardBody1 => 'Calculate your BMI in seconds, no account needed.';

  @override
  String get onboardTitle2 => 'Get smart recommendations';

  @override
  String get onboardBody2 => 'Personalized advice based on your body and goals.';

  @override
  String get onboardTitle3 => 'Track progress over time';

  @override
  String get onboardBody3 => 'See your weight journey visually, week by week.';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get started';

  @override
  String get continueLabel => 'Continue';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get sectionLanguage => 'Language';

  @override
  String get appLanguage => 'App language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUrdu => 'اردو';

  @override
  String get sectionUnits => 'Units';

  @override
  String get sectionNotifications => 'Notifications';

  @override
  String get dailyReminders => 'Daily reminders';

  @override
  String get weeklyCheckIn => 'Weekly check-in';

  @override
  String get sectionAbout => 'About';

  @override
  String get privacy => 'Privacy';

  @override
  String get onDevice => 'On-device';

  @override
  String get adPrivacyChoices => 'Ad privacy choices';

  @override
  String get version => 'Version';

  @override
  String get settingsFooter => 'Made with care.  ·  No account required.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyDataTitle => '🔒 Data stays on your device';

  @override
  String get privacyDataBody => 'BMI Calculator & Health stores all your data — weight entries, goals, and profile — locally on your device using SQLite. Nothing is sent to any server.';

  @override
  String get privacyAnalyticsTitle => '📊 No analytics or tracking';

  @override
  String get privacyAnalyticsBody => 'We do not use analytics or user-tracking tools. If the app crashes, an anonymous crash report (device model, Android or iOS version, and the technical error) may be sent to our crash-reporting service, Sentry, so we can fix the problem. Crash reports never include your weight, BMI or other health data.';

  @override
  String get privacyAdsTitle => '📢 Ads';

  @override
  String get privacyAdsBody => 'BMI Calculator & Health is free and supported by ads powered by Google AdMob. AdMob may use your device\'s advertising ID to show relevant ads. You can opt out of personalised ads at any time in your device settings under Google → Ads → Delete advertising ID.';

  @override
  String get privacyThirdPartyTitle => '🔗 Third-party ad services';

  @override
  String get privacyThirdPartyBody => 'Google AdMob may collect certain device information (such as IP address, device identifiers, and general location) to serve ads. This data is governed by Google\'s Privacy Policy. BMI Calculator & Health does not have access to this data.';

  @override
  String get privacyDeleteTitle => '🗑 Deleting your data';

  @override
  String get privacyDeleteBody => 'Uninstalling the app permanently deletes all your health data from the device. There is no cloud backup — your data never leaves your phone.';

  @override
  String get gotIt => 'Got it';

  @override
  String get historyTitle => 'History';

  @override
  String get periodAll => 'All time';

  @override
  String get period7d => 'Last 7 days';

  @override
  String get period30d => 'Last 30 days';

  @override
  String get period3m => 'Last 3 months';

  @override
  String get period1y => 'Last year';

  @override
  String get categoryAll => 'All';

  @override
  String get clearAll => 'Clear all';

  @override
  String get noEntriesMatch => 'No entries match your filter';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String entriesCount(int count) {
    return 'Entries  ·  $count';
  }

  @override
  String entriesCountOf(int count, int total) {
    return 'Entries  ·  $count of $total';
  }

  @override
  String get filterEntries => 'Filter entries';

  @override
  String get timePeriod => 'Time period';

  @override
  String get bmiCategoryLabel => 'BMI category';

  @override
  String get applyFilter => 'Apply filter';

  @override
  String get noHistoryYet => 'No history yet';

  @override
  String get noHistoryBody => 'Start tracking today — every entry shapes your trend.';

  @override
  String get addFirstEntry => 'Add first entry';

  @override
  String get bmiTrend => 'BMI Trend';

  @override
  String entryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
    );
    return '$_temp0';
  }

  @override
  String bmiDelta(String delta) {
    return '$delta BMI';
  }

  @override
  String get goalTitle => 'Set a goal';

  @override
  String get goalCurrent => 'Current';

  @override
  String get goalTarget => 'Target';

  @override
  String get goalTargetWeight => 'Target weight';

  @override
  String get goalTimeline => 'Timeline';

  @override
  String weeksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: '1 week',
    );
    return '$_temp0';
  }

  @override
  String get goalYourPlan => 'Your plan';

  @override
  String get goalMaintain => 'Maintain your current weight';

  @override
  String goalLose(String amount, int weeks) {
    return 'Lose $amount in $weeks weeks';
  }

  @override
  String goalGain(String amount, int weeks) {
    return 'Gain $amount in $weeks weeks';
  }

  @override
  String goalRate(String value) {
    return '$value kg / week';
  }

  @override
  String goalPaceSafe(String rate) {
    return 'That\'s $rate — a safe, sustainable pace.';
  }

  @override
  String goalPaceFast(String rate) {
    return 'That\'s $rate — faster than recommended. Try a longer timeline.';
  }

  @override
  String get goalReachBy => 'Reach by';

  @override
  String get goalDailyCalories => 'Daily calories';

  @override
  String get goalStart => 'Start tracking goal';

  @override
  String get tipsTitle => 'Daily tips';

  @override
  String get tipCatDiet => 'Diet';

  @override
  String get tipCatExercise => 'Exercise';

  @override
  String get tipCatHydration => 'Hydration';

  @override
  String get tipCatLifestyle => 'Lifestyle';

  @override
  String tipToday(String category) {
    return 'Today · $category';
  }

  @override
  String get tip1Title => 'Half your plate, vegetables';

  @override
  String get tip1Body => 'A simple visual rule that crowds out higher-calorie foods without counting.';

  @override
  String get tip2Title => 'Water before coffee';

  @override
  String get tip2Body => 'Drink 200 ml of water before your first coffee to reset overnight dehydration.';

  @override
  String get tip3Title => 'A 10-min walk after meals';

  @override
  String get tip3Body => 'Studies show short post-meal walks meaningfully lower blood-glucose spikes.';

  @override
  String get tip4Title => 'Sleep is the multiplier';

  @override
  String get tip4Body => 'Under 7 hours raises hunger hormones the next day. Protect a wind-down ritual.';

  @override
  String get tip5Title => 'Protein first, every meal';

  @override
  String get tip5Body => 'Eat the protein on your plate before carbs — satiety lasts longer.';

  @override
  String get tip6Title => 'Strength training twice a week';

  @override
  String get tip6Body => 'Two sessions of resistance training weekly significantly improves metabolic health.';

  @override
  String get tip7Title => 'Hydrate with meals too';

  @override
  String get tip7Body => 'Sipping water during meals helps digestion and reduces overeating.';

  @override
  String get tip8Title => 'Stress fuels hunger';

  @override
  String get tip8Body => 'Cortisol spikes increase appetite. Try 5 minutes of deep breathing before eating.';

  @override
  String get adviceUnderHeadline => 'Your weight is below the healthy range';

  @override
  String get adviceUnderCopy => 'Being underweight can weaken immunity, reduce bone density, and affect energy levels. The goal is gradual, quality weight gain — not just eating more junk food.';

  @override
  String get adviceUnderStep1 => 'Eat calorie-dense whole foods: nuts, nut butter, avocado, eggs, whole milk, oats, and brown rice';

  @override
  String get adviceUnderStep2 => 'Add 300–500 extra kcal per day — enough to gain ~0.3–0.5 kg per week sustainably';

  @override
  String get adviceUnderStep3 => 'Eat 3 main meals + 2–3 snacks daily; never skip breakfast';

  @override
  String get adviceUnderStep4 => 'Include protein at every meal — aim for 1.2–1.6 g per kg of body weight to build muscle';

  @override
  String get adviceUnderStep5 => 'Do resistance training 2–3× per week (squats, push-ups, rows) so gained weight becomes muscle, not just fat';

  @override
  String get adviceUnderStep6 => 'If weight loss is unexplained or rapid, see a doctor — it may signal an underlying condition';

  @override
  String get adviceUnderNote => 'If you have been underweight for a long time, consult a doctor or registered dietitian for personalised support.';

  @override
  String get adviceNormalHeadline => 'You are in the healthy weight range';

  @override
  String get adviceNormalCopy => 'A healthy BMI is a great foundation. The priority now is maintaining it through consistent habits — movement, quality nutrition, sleep, and stress management all matter.';

  @override
  String get adviceNormalStep1 => 'Get 150–300 min of moderate aerobic activity per week: brisk walking, cycling, or swimming';

  @override
  String get adviceNormalStep2 => 'Add 2–3 strength training sessions per week to preserve muscle mass as you age';

  @override
  String get adviceNormalStep3 => 'Fill half your plate with vegetables and fruit at every main meal';

  @override
  String get adviceNormalStep4 => 'Limit ultra-processed foods, added sugars, and alcohol — they add calories with little nutrition';

  @override
  String get adviceNormalStep5 => 'Sleep 7–9 hours per night; poor sleep raises ghrelin (hunger hormone) and leads to overeating';

  @override
  String get adviceNormalStep6 => 'Re-check your BMI every 4–6 weeks to catch any drift early';

  @override
  String get adviceNormalNote => 'BMI is a screening tool, not a full health picture. Body composition, blood pressure, and blood sugar also matter.';

  @override
  String get adviceOverHeadline => 'Your weight is slightly above the healthy range';

  @override
  String get adviceOverCopy => 'Overweight raises the risk of type 2 diabetes, high blood pressure, and joint problems over time. Even a 5–10% reduction in body weight significantly lowers these risks.';

  @override
  String get adviceOverStep1 => 'Create a moderate calorie deficit of 300–500 kcal/day — target 0.3–0.5 kg loss per week (sustainable pace)';

  @override
  String get adviceOverStep2 => 'Walk 8,000–10,000 steps daily; start with 30 min brisk walks and build from there';

  @override
  String get adviceOverStep3 => 'Swap sugary drinks (soda, juice, energy drinks) for water, sparkling water, or unsweetened tea';

  @override
  String get adviceOverStep4 => 'Eat protein first at each meal — it increases satiety and reduces overall calorie intake';

  @override
  String get adviceOverStep5 => 'Fill half your plate with non-starchy vegetables (broccoli, spinach, cucumber, peppers) at lunch and dinner';

  @override
  String get adviceOverStep6 => 'Avoid eating within 2–3 hours of bedtime — late-night eating promotes fat storage';

  @override
  String get adviceOverNote => 'Crash diets backfire. A 300–500 kcal deficit is enough — losing weight slowly preserves muscle and is easier to maintain.';

  @override
  String get adviceObeseHeadline => 'Your weight is in the obese range';

  @override
  String get adviceObeseCopy => 'Obesity is associated with increased risk of heart disease, type 2 diabetes, sleep apnea, and joint pain. The good news: even modest weight loss of 5–10% of your body weight produces meaningful health improvements.';

  @override
  String get adviceObeseStep1 => 'Set your first target at 5–10% of current weight — for an 100 kg person, that is just 5–10 kg';

  @override
  String get adviceObeseStep2 => 'Aim for 0.5–1.0 kg loss per week; faster rates typically cause muscle loss and a rebound';

  @override
  String get adviceObeseStep3 => 'Start with low-impact daily movement: 30 min walking, swimming, or stationary cycling — knees and joints will thank you';

  @override
  String get adviceObeseStep4 => 'Cut out ultra-processed foods, fried food, and added sugars first — these alone can reduce 500+ kcal/day';

  @override
  String get adviceObeseStep5 => 'Build meals around protein (chicken, fish, legumes, eggs) and vegetables; they keep you full longer';

  @override
  String get adviceObeseStep6 => 'See your doctor for a baseline check — blood pressure, blood sugar, and cholesterol — and ask about structured support programs';

  @override
  String get adviceObeseNote => 'BMI alone does not diagnose health. Speak with a doctor or registered dietitian for a plan tailored to your medical history.';

  @override
  String stepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get later => 'Later';

  @override
  String get back => 'Back';

  @override
  String get finish => 'Finish';

  @override
  String get save => 'Save';

  @override
  String get personalDetails => 'Personal details';

  @override
  String get notSet => 'Not set';

  @override
  String get setupIntro => 'A few quick questions so the app can tailor workouts and targets to you.';

  @override
  String get setupNameTitle => 'What should we call you?';

  @override
  String get setupNameHint => 'Your name (optional)';

  @override
  String get setupGenderTitle => 'What is your gender?';

  @override
  String get setupGenderBody => 'We use this for calorie and body-fat formulas and to show exercise videos with a matching trainer. You can change it any time.';

  @override
  String get setupFormulaTitle => 'Calculations based on';

  @override
  String get setupFormulaBody => 'Calorie and body-fat formulas differ for male and female bodies. Pick the one that fits you best.';

  @override
  String get bodyMale => 'Male body';

  @override
  String get bodyFemale => 'Female body';

  @override
  String get setupDemonstratorTitle => 'Exercise videos show';

  @override
  String get demonstratorAuto => 'Match my profile';

  @override
  String get demonstratorMale => 'Male trainer';

  @override
  String get demonstratorFemale => 'Female trainer';

  @override
  String get setupBodyTitle => 'About your body';

  @override
  String get setupGoalTitle => 'What is your main goal?';

  @override
  String get goalLoseFat => 'Lose fat';

  @override
  String get goalLoseFatBody => 'Burn fat while keeping muscle';

  @override
  String get goalBuildMuscle => 'Build muscle';

  @override
  String get goalBuildMuscleBody => 'Gain size and shape';

  @override
  String get goalGetStronger => 'Get stronger';

  @override
  String get goalGetStrongerBody => 'Lift heavier, step by step';

  @override
  String get goalStayFit => 'Stay fit & healthy';

  @override
  String get goalStayFitBody => 'Move more and feel better';

  @override
  String get setupExperienceTitle => 'How experienced are you with training?';

  @override
  String get expBeginner => 'Beginner';

  @override
  String get expBeginnerBody => 'New to training or returning after a long break';

  @override
  String get expIntermediate => 'Intermediate';

  @override
  String get expIntermediateBody => 'Training regularly for 6+ months';

  @override
  String get expAdvanced => 'Advanced';

  @override
  String get expAdvancedBody => 'Several years of consistent training';

  @override
  String get setupEquipmentTitle => 'Where will you train?';

  @override
  String get equipGym => 'Gym';

  @override
  String get equipGymBody => 'Full access to machines and free weights';

  @override
  String get equipHome => 'Home with some equipment';

  @override
  String get equipHomeBody => 'Dumbbells, bands or a bench';

  @override
  String get equipNone => 'No equipment';

  @override
  String get equipNoneBody => 'Bodyweight exercises only';

  @override
  String get setupDaysTitle => 'How many days a week can you train?';

  @override
  String daysPerWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days a week',
      one: '1 day a week',
    );
    return '$_temp0';
  }

  @override
  String get setupDaysTip => '3–4 days is a great start for most people.';

  @override
  String get sectionProfile => 'Profile';

  @override
  String get navBody => 'Body';

  @override
  String get bodyTitle => 'Body';

  @override
  String get logWeight => 'Log weight';

  @override
  String get weightEmpty => 'Log your weight regularly to see your trend.';

  @override
  String weightAverage(String value) {
    return '7-day average: $value';
  }

  @override
  String lastLogged(String date) {
    return 'Last logged $date';
  }

  @override
  String get bodyFatTitle => 'Body fat (estimate)';

  @override
  String get bodyFatNeedsMale => 'Add neck and waist measurements to estimate your body fat.';

  @override
  String get bodyFatNeedsFemale => 'Add neck, waist and hip measurements to estimate your body fat.';

  @override
  String get bodyFatMethod => 'US Navy tape method — an estimate, not a medical measurement.';

  @override
  String get measurementsTitle => 'Measurements';

  @override
  String get addMeasurements => 'Add measurements';

  @override
  String get measurementsEmpty => 'Track your waist, hips and more to see changes the scale misses.';

  @override
  String get measureNeck => 'Neck';

  @override
  String get measureChest => 'Chest';

  @override
  String get measureBust => 'Bust';

  @override
  String get measureWaist => 'Waist';

  @override
  String get measureHips => 'Hips';

  @override
  String get measureArm => 'Arm';

  @override
  String get measureThigh => 'Thigh';

  @override
  String get measureHint => 'Measure relaxed, at the widest point, without pulling the tape tight.';

  @override
  String get measureRangeError => 'Measurements must be between 5 and 300 cm (2–118 in).';

  @override
  String get bmiHistory => 'BMI history';

  @override
  String get viewAll => 'View all';

  @override
  String get noBmiYet => 'No BMI saved yet';

  @override
  String get wellnessDisclaimer => 'For general wellness only. Not medical advice.';

  @override
  String get navTrain => 'Train';

  @override
  String get trainTitle => 'Train';

  @override
  String get startEmptyWorkout => 'Start empty workout';

  @override
  String get resumeWorkout => 'Resume workout';

  @override
  String workoutInProgress(String elapsed) {
    return 'Workout in progress · $elapsed';
  }

  @override
  String get exerciseLibrary => 'Exercise library';

  @override
  String get routines => 'Routines';

  @override
  String get routinesEmpty => 'Save a workout as a routine to repeat it with one tap.';

  @override
  String get recentWorkouts => 'Recent workouts';

  @override
  String get noWorkoutsYet => 'Your finished workouts will appear here.';

  @override
  String exercisesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
    );
    return '$_temp0';
  }

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String prCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count PRs',
      one: '1 PR',
    );
    return '$_temp0';
  }

  @override
  String volumeLabel(String value) {
    return 'Volume $value';
  }

  @override
  String get workoutDefaultName => 'Workout';

  @override
  String get addExercise => 'Add exercise';

  @override
  String get addSet => 'Add set';

  @override
  String get setLabel => 'Set';

  @override
  String get previousLabel => 'Previous';

  @override
  String get repsLabel => 'Reps';

  @override
  String get finishWorkout => 'Finish';

  @override
  String get discardWorkout => 'Discard workout';

  @override
  String get discardConfirm => 'Discard this workout? Logged sets will be deleted.';

  @override
  String get discard => 'Discard';

  @override
  String get removeExercise => 'Remove exercise';

  @override
  String restTimer(String time) {
    return 'Rest $time';
  }

  @override
  String get skip2 => 'Skip';

  @override
  String get workoutComplete => 'Workout complete';

  @override
  String newPrs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new personal records!',
      one: 'New personal record!',
    );
    return '$_temp0';
  }

  @override
  String get saveAsRoutine => 'Save as routine';

  @override
  String get routineName => 'Routine name';

  @override
  String get done => 'Done';

  @override
  String get nothingLogged => 'No sets were ticked, so the workout was not saved.';

  @override
  String get searchExercises => 'Search exercises';

  @override
  String get myEquipmentOnly => 'My equipment';

  @override
  String get allMuscles => 'All';

  @override
  String get howTo => 'How to do it';

  @override
  String get videoComingSoon => 'Video coming soon';

  @override
  String videoWithTrainer(String trainer) {
    return 'With $trainer';
  }

  @override
  String get targetMuscles => 'Target muscles';

  @override
  String get muscleChest => 'Chest';

  @override
  String get muscleBack => 'Back';

  @override
  String get muscleShoulders => 'Shoulders';

  @override
  String get muscleBiceps => 'Biceps';

  @override
  String get muscleTriceps => 'Triceps';

  @override
  String get muscleQuads => 'Quads';

  @override
  String get muscleHamstrings => 'Hamstrings';

  @override
  String get muscleGlutes => 'Glutes';

  @override
  String get muscleCalves => 'Calves';

  @override
  String get muscleCore => 'Core';

  @override
  String get eqBarbell => 'Barbell';

  @override
  String get eqDumbbell => 'Dumbbell';

  @override
  String get eqMachine => 'Machine';

  @override
  String get eqCable => 'Cable';

  @override
  String get eqBodyweight => 'Bodyweight';

  @override
  String get eqBand => 'Band';

  @override
  String get eqKettlebell => 'Kettlebell';

  @override
  String get navToday => 'Today';

  @override
  String get navFuel => 'Fuel';

  @override
  String get fuelTitle => 'Fuel';

  @override
  String get caloriesTitle => 'Calories';

  @override
  String kcalOf(int eaten, int target) {
    return '$eaten / $target kcal';
  }

  @override
  String kcalLeft(int count) {
    return '$count kcal left';
  }

  @override
  String kcalOver(int count) {
    return '$count kcal over';
  }

  @override
  String get macroProtein => 'Protein';

  @override
  String get macroCarbs => 'Carbs';

  @override
  String get macroFat => 'Fat';

  @override
  String gramsOf(int eaten, int target) {
    return '$eaten / $target g';
  }

  @override
  String gramsTarget(int target) {
    return '$target g';
  }

  @override
  String get logFood => 'Log food';

  @override
  String get foodName => 'What did you eat? (optional)';

  @override
  String get foodKcal => 'Calories (kcal)';

  @override
  String get foodProtein => 'Protein (g, optional)';

  @override
  String get foodKcalError => 'Enter calories between 1 and 5000.';

  @override
  String get foodEmpty => 'Nothing logged today. Quick-add calories after each meal.';

  @override
  String get foodUnnamed => 'Food';

  @override
  String get waterTitle => 'Water';

  @override
  String waterOf(int drunk, int goal) {
    return '$drunk / $goal ml';
  }

  @override
  String get addGlass => '+250 ml';

  @override
  String get removeGlass => '−250 ml';

  @override
  String get targetsExplain => 'Based on your age, height, weight, gender, goal and training days (Mifflin-St Jeor). A starting point, not a medical prescription.';

  @override
  String get completeProfileForTargets => 'Set your goal in Personal details for personalised targets.';

  @override
  String greeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get greetingNoName => 'Today';

  @override
  String thisWeekWorkouts(int done, int target) {
    return '$done of $target workouts this week';
  }

  @override
  String get startWorkout => 'Start workout';

  @override
  String get latestWeight => 'Latest weight';

  @override
  String get tipOfTheDay => 'Tip of the day';

  @override
  String get moreTips => 'More tips';

  @override
  String get calculateBmiShort => 'Calculate BMI';
}
