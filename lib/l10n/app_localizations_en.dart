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
  String get tipsTitle => 'Tips';

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

  @override
  String get reminderChannel => 'Reminders';

  @override
  String get dailyReminderTitle => 'Time for a quick check-in';

  @override
  String get dailyReminderBody => 'Log today\'s weight, water and meals to keep your trend accurate.';

  @override
  String get weeklyReminderTitle => 'Your weekly check-in';

  @override
  String get weeklyReminderBody => 'See how your week went and plan your next workouts.';

  @override
  String get dailyReminderAt => 'Every day at 8:00 PM';

  @override
  String get weeklyReminderAt => 'Sundays at 10:00 AM';

  @override
  String get notificationsDenied => 'Notifications are turned off for this app. Turn them on in your phone\'s settings to get reminders.';

  @override
  String get stepsTitle => 'Steps';

  @override
  String stepsOf(int steps, int goal) {
    return '$steps / $goal';
  }

  @override
  String get stepsConnectBody => 'See your daily steps here. Steps are read from Health Connect and stay on your phone.';

  @override
  String get stepsConnectBodyIos => 'See your daily steps here. Steps are read from Apple Health and stay on your phone.';

  @override
  String get connectSteps => 'Connect';

  @override
  String get installHealthConnect => 'Get Health Connect';

  @override
  String get stepsNeedsInstall => 'Step counting needs Google\'s Health Connect app.';

  @override
  String get activityChannel => 'Activity';

  @override
  String get movementTitle => 'Timeline';

  @override
  String get movementCardTitle => 'Your day';

  @override
  String get trackingOff => 'Turn on tracking to see where you went, how long you stayed and how far you walked. Your location never leaves this phone.';

  @override
  String get trackingOn => 'Tracking is on';

  @override
  String get startTracking => 'Start tracking';

  @override
  String get stopTracking => 'Stop tracking';

  @override
  String get trackingNotificationTitle => 'Tracking your day';

  @override
  String get trackingNotificationBody => 'Building your private timeline. Tap to open.';

  @override
  String get locationDenied => 'Location access is off. Allow it in your phone\'s settings to build your timeline.';

  @override
  String get locationServiceOff => 'Turn on location (GPS) on your phone to track your day.';

  @override
  String placesVisited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places',
      one: '1 place',
      zero: 'No places yet',
    );
    return '$_temp0';
  }

  @override
  String distanceKm(String km) {
    return '$km km';
  }

  @override
  String durationHm(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get unnamedPlace => 'Unnamed place';

  @override
  String get modeWalk => 'Walk';

  @override
  String get modeRun => 'Run / cycle';

  @override
  String get modeVehicle => 'Vehicle';

  @override
  String get namePlace => 'Name this place';

  @override
  String get placeName => 'Place name';

  @override
  String get thisIsMyGym => 'This is my gym';

  @override
  String get noTimelineYet => 'No movement recorded for this day.';

  @override
  String get deleteDay => 'Delete this day';

  @override
  String get deleteAllLocation => 'Delete all location history';

  @override
  String get deleteLocationConfirm => 'This permanently deletes the selected location history from this phone.';

  @override
  String get delete => 'Delete';

  @override
  String gymTimeWeek(String time) {
    return 'Gym time this week: $time';
  }

  @override
  String get gymCheckInTitle => 'You\'re at the gym 💪';

  @override
  String get gymCheckInBody => 'Start today\'s workout? Open the app to begin logging.';

  @override
  String get trackingLimitNote => 'Tracking pauses if you close the app from recent apps.';

  @override
  String get programs => 'Programs';

  @override
  String programDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days a week',
      one: '1 day a week',
    );
    return '$_temp0';
  }

  @override
  String startDay(int day) {
    return 'Start Day $day';
  }

  @override
  String get recommended => 'Recommended';

  @override
  String suggestionIncrease(String weight, int reps) {
    return 'Try $weight × $reps';
  }

  @override
  String suggestionAddRep(String weight, int reps) {
    return 'Aim for $reps reps at $weight';
  }

  @override
  String suggestionDeload(String weight, int reps) {
    return 'Reset to $weight × $reps';
  }

  @override
  String suggestionRepsOnly(int reps) {
    return 'Aim for $reps reps';
  }

  @override
  String get muscleMapTitle => 'Muscles this week';

  @override
  String get muscleMapHint => 'Hard sets per muscle (secondary muscles count half). About 10 a week builds muscle.';

  @override
  String undertrained(String muscles) {
    return 'Needs more work: $muscles';
  }

  @override
  String setsCount(String count) {
    return '$count sets';
  }

  @override
  String get repCounter => 'Rep counter';

  @override
  String get repCounterIntro => 'Place your phone so your whole body is visible from the side, then start moving.';

  @override
  String get repCounterPrivacy => 'Analysed on your phone. Nothing is recorded or uploaded.';

  @override
  String repsCounted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reps',
      one: '1 rep',
    );
    return '$_temp0';
  }

  @override
  String get cueGoLower => 'Go lower';

  @override
  String get cueKeepHipsUp => 'Keep your hips up';

  @override
  String get cueFullExtension => 'Use the full range';

  @override
  String get cueStepIntoFrame => 'Step into the frame';

  @override
  String get countSquat => 'Squat';

  @override
  String get countPushUp => 'Push-up';

  @override
  String get countCurl => 'Curl';

  @override
  String get countShoulderPress => 'Shoulder press';

  @override
  String get countLunge => 'Lunge';

  @override
  String get resetCount => 'Reset';

  @override
  String get logSet => 'Log set';

  @override
  String setLogged(int count) {
    return 'Set logged: $count reps';
  }

  @override
  String get cameraDenied => 'Camera access is off. Allow it in your phone\'s settings to count reps.';

  @override
  String get cameraUnavailable => 'No camera is available on this device.';

  @override
  String get goPremium => 'Go Premium';

  @override
  String get premiumActive => 'Premium active';

  @override
  String get premiumBadge => 'Premium';

  @override
  String get premiumHeadline => 'Train without interruptions';

  @override
  String get premiumBody => 'Remove every ad and help fund new features.';

  @override
  String get premiumWelcome => 'Welcome to Premium!';

  @override
  String get premiumThanksBody => 'Ads are removed. Thank you for supporting BMI Health.';

  @override
  String get premiumFeatureNoAds => 'No banner or full-screen ads';

  @override
  String get premiumFeatureSupport => 'Support an independent app';

  @override
  String get premiumFeaturePrivacy => 'Same privacy: your health data stays on your phone';

  @override
  String get planMonthly => 'Monthly';

  @override
  String get planYearly => 'Yearly';

  @override
  String get planLifetime => 'Lifetime';

  @override
  String get planPerMonth => 'per month';

  @override
  String planYearlyPerMonth(String price) {
    return '$price / month, billed yearly';
  }

  @override
  String get planOneTime => 'one-time payment';

  @override
  String get bestValue => 'Best value';

  @override
  String get restore => 'Restore';

  @override
  String get processing => 'Processing…';

  @override
  String get upgradeNow => 'Upgrade now';

  @override
  String get allSet => 'You\'re all set!';

  @override
  String get storeUnavailable => 'The store is not available on this device.';

  @override
  String get pricesLoading => 'Loading prices…';

  @override
  String get renewNote => 'Subscriptions renew automatically until cancelled. Cancel anytime in your Google Play or App Store subscriptions. No tracking. No data sold.';

  @override
  String get thanksNote => 'Thank you for supporting BMI Health.';

  @override
  String get recoveryTitle => 'Recovery';

  @override
  String recoveryScore(int score) {
    return '$score / 100';
  }

  @override
  String get adviceTrainHard => 'Good day to train hard';

  @override
  String get adviceTrainLight => 'Train light today: easier sets or cardio';

  @override
  String get adviceRest => 'Rest or gentle movement today';

  @override
  String get limiterSleep => 'Held back by short sleep';

  @override
  String get limiterRestingHr => 'Resting heart rate is higher than usual';

  @override
  String get limiterHrv => 'Heart-rate variability is lower than usual';

  @override
  String get limiterLoad => 'You\'ve trained much more than usual lately';

  @override
  String get limiterSoreness => 'You\'re feeling sore';

  @override
  String get sorenessQuestion => 'How sore are you today?';

  @override
  String get sorenessScale => '1 = not at all, 5 = very';

  @override
  String get connectSleepHeart => 'Connect sleep & heart data';

  @override
  String get connectSleepHeartBody => 'Optional: adds sleep, resting heart rate and HRV from your watch or phone for a more accurate score.';

  @override
  String get recoveryEmpty => 'Answer the check-in or log a workout to see your recovery.';

  @override
  String get sleepTitle => 'Sleep';

  @override
  String sleepLastNight(String time) {
    return 'Last night: $time';
  }

  @override
  String sleepAverage(String time) {
    return '7-night average: $time';
  }

  @override
  String sleepDebt(String time) {
    return 'Sleep debt this week: $time';
  }

  @override
  String get sleepRegular => 'Your bedtimes are regular, which helps sleep quality.';

  @override
  String get sleepIrregular => 'Bedtimes vary a lot. A steadier bedtime usually improves sleep.';

  @override
  String get cycleTitle => 'Cycle';

  @override
  String get cycleTracking => 'Cycle tracking';

  @override
  String get cycleOptInBody => 'Track your period and symptoms and get training and nutrition tips for each phase. Stored only on this phone. You can delete it all at any time.';

  @override
  String get cycleLock => 'Lock with fingerprint or PIN';

  @override
  String get cycleUnlockReason => 'Unlock your cycle data';

  @override
  String get cycleUnlock => 'Unlock';

  @override
  String get cycleLocked => 'Cycle data is locked.';

  @override
  String get cycleDeleteAll => 'Delete all cycle data';

  @override
  String get cycleDeleteConfirm => 'This permanently deletes all periods and symptoms from this phone and turns cycle tracking off.';

  @override
  String cycleDay(int day) {
    return 'Day $day';
  }

  @override
  String get periodStartedToday => 'My period started today';

  @override
  String get periodEndedToday => 'My period ended today';

  @override
  String get periodStartedOn => 'Log a past period';

  @override
  String nextPeriodIn(int days) {
    return 'Next period in about $days days';
  }

  @override
  String get nextPeriodToday => 'Next period expected about today';

  @override
  String nextPeriodWindow(String from, String to) {
    return 'Likely between $from and $to';
  }

  @override
  String get periodLate => 'Your period is later than usual. Cycles often vary; if you\'re worried, talk to a doctor.';

  @override
  String get cycleIrregular => 'Your cycles vary in length, so predictions are wider.';

  @override
  String get cycleNoData => 'Log your period to start getting predictions.';

  @override
  String get phaseMenstrual => 'Period';

  @override
  String get phaseFollicular => 'Follicular phase';

  @override
  String get phaseOvulation => 'Around ovulation';

  @override
  String get phaseLuteal => 'Luteal phase';

  @override
  String get tipMenstrual => 'Train by feel: lighter sessions, walking and mobility are fine. Iron-rich foods (lentils, spinach, meat) help replace losses.';

  @override
  String get tipFollicular => 'Energy often rises: a good time for heavier lifts and trying new personal bests.';

  @override
  String get tipOvulation => 'Strength can feel high. Warm up well and keep good form on jumps and quick changes of direction.';

  @override
  String get tipLuteal => 'You may feel warmer and hungrier. Keep protein up, stay hydrated, and favour steady training over max efforts late in this phase.';

  @override
  String get cycleTipNote => 'General guidance; everyone\'s cycle feels different.';

  @override
  String get symptomsToday => 'Symptoms today';

  @override
  String get symptomCramps => 'Cramps';

  @override
  String get symptomHeadache => 'Headache';

  @override
  String get symptomBloating => 'Bloating';

  @override
  String get symptomFatigue => 'Tired';

  @override
  String get symptomLowMood => 'Low mood';

  @override
  String get symptomAcne => 'Acne';

  @override
  String get symptomCravings => 'Cravings';

  @override
  String get symptomTenderBreasts => 'Tender breasts';

  @override
  String get pastPeriods => 'Past periods';

  @override
  String periodRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String periodOngoing(String from) {
    return '$from – ongoing';
  }

  @override
  String get scanBarcode => 'Scan barcode';

  @override
  String get scanHint => 'Point the camera at the barcode on the pack.';

  @override
  String get lookingUp => 'Looking up product…';

  @override
  String get productNotFound => 'Product not found. You can enter it yourself.';

  @override
  String get productNoNutrition => 'This product has no calorie information yet. You can enter it yourself.';

  @override
  String get lookupOffline => 'Couldn\'t reach the food database. Check your connection or enter it yourself.';

  @override
  String get enterManually => 'Enter manually';

  @override
  String get scanAgain => 'Scan again';

  @override
  String per100g(String kcal) {
    return '$kcal kcal per 100 g';
  }

  @override
  String get portionGrams => 'Amount (g)';

  @override
  String oneServing(String grams) {
    return '1 serving ($grams g)';
  }

  @override
  String portionTotal(int kcal, String protein) {
    return '$kcal kcal · $protein g protein';
  }

  @override
  String portionTotalKcal(int kcal) {
    return '$kcal kcal';
  }

  @override
  String get logThis => 'Log it';

  @override
  String foodLogged(String name) {
    return 'Logged: $name';
  }

  @override
  String get offAttribution => 'Product data: Open Food Facts (ODbL)';

  @override
  String get progressPhotos => 'Progress photos';

  @override
  String get progressPhotosBody => 'Private: encrypted on this phone and never added to your gallery.';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get comparePhotos => 'Compare first and latest';

  @override
  String get deletePhoto => 'Delete photo';

  @override
  String get deletePhotoConfirm => 'This permanently deletes the photo from this phone.';

  @override
  String photoDate(String date) {
    return '$date';
  }

  @override
  String get coachTitle => 'AI coach';

  @override
  String get coachCardBody => 'Ask about training, food or recovery.';

  @override
  String get coachHint => 'Ask a question…';

  @override
  String get coachWelcome => 'Hi! I can help with workouts, nutrition, recovery and habits. I\'m not a doctor, so for medical questions please see a professional.';

  @override
  String get aiConsentTitle => 'Before you start';

  @override
  String get aiConsentBody => 'Your questions, and a short profile summary (age, sex, weight, goal, experience, training days), are sent to our server and to Anthropic\'s Claude AI to write answers. Photos you send for a calorie estimate are sent the same way. Nothing is stored or used for ads. Answers are general guidance, not medical advice.';

  @override
  String get aiAgree => 'I agree';

  @override
  String get aiLimit => 'You\'ve reached today\'s limit. Try again tomorrow.';

  @override
  String get aiUnavailable => 'Couldn\'t reach the coach. Check your connection and try again.';

  @override
  String get coachThinking => 'Thinking…';

  @override
  String get photoEstimate => 'Photo estimate';

  @override
  String get photoEstimating => 'Estimating calories…';

  @override
  String get photoNotFood => 'That doesn\'t look like food. Try another photo.';

  @override
  String get photoEstimateNote => 'AI estimate from a photo — portions can be off by 20–40%. Adjust if you know better.';

  @override
  String get photoConfidenceLow => 'Low confidence';

  @override
  String photoTotal(int kcal) {
    return 'Total: $kcal kcal';
  }

  @override
  String get logSelected => 'Log selected';

  @override
  String get estimateSuffix => '(estimate)';

  @override
  String get progressTitle => 'Progress';

  @override
  String weekStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-week streak',
      one: '1-week streak',
      zero: 'No streak yet',
    );
    return '$_temp0';
  }

  @override
  String streakGoal(int count) {
    return 'Hit $count workouts a week to keep it going.';
  }

  @override
  String badgesEarned(int earned, int total) {
    return '$earned of $total badges';
  }

  @override
  String get thisMonth => 'This month';

  @override
  String get lastMonth => 'Last month';

  @override
  String recapWorkouts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count workouts',
      one: '1 workout',
    );
    return '$_temp0';
  }

  @override
  String recapSets(int count, String kg) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sets · $kg kg lifted',
      one: '1 set · $kg kg lifted',
    );
    return '$_temp0';
  }

  @override
  String recapPrs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personal records',
      one: '1 personal record',
    );
    return '$_temp0';
  }

  @override
  String recapTime(String time) {
    return '$time training';
  }

  @override
  String recapDistance(String km) {
    return '$km km moved';
  }

  @override
  String recapGym(String time) {
    return '$time at the gym';
  }

  @override
  String recapWeight(String change) {
    return 'Weight $change kg';
  }

  @override
  String get recapEmpty => 'Nothing logged in this period yet.';

  @override
  String get shareRecap => 'Share';

  @override
  String get badgesTitle => 'Badges';

  @override
  String get badgeFirstWorkout => 'First workout';

  @override
  String get badgeWorkouts10 => '10 workouts';

  @override
  String get badgeWorkouts50 => '50 workouts';

  @override
  String get badgeWorkouts100 => '100 workouts';

  @override
  String get badgeStreak4 => '4-week streak';

  @override
  String get badgeStreak12 => '12-week streak';

  @override
  String get badgeFirstPr => 'First personal record';

  @override
  String get badgePrs10 => '10 personal records';

  @override
  String get badgeTon => '1,000 kg lifted';

  @override
  String get badgeSteps10k => '10,000 steps in a day';

  @override
  String get appName => 'BMI Health';

  @override
  String get sectionBackup => 'Backup & export';

  @override
  String get createBackup => 'Create backup';

  @override
  String get restoreBackup => 'Restore from backup';

  @override
  String get exportCsv => 'Export as spreadsheet (CSV)';

  @override
  String get backupBody => 'Your data stays off cloud backups. Create an encrypted backup file and save it to Google Drive, iCloud or anywhere you like. Only your passphrase can open it — if you lose it, the backup can\'t be recovered.';

  @override
  String get passphrase => 'Passphrase';

  @override
  String get passphraseRepeat => 'Repeat passphrase';

  @override
  String passphraseTooShort(int count) {
    return 'Use at least $count characters.';
  }

  @override
  String get passphraseMismatch => 'Passphrases don\'t match.';

  @override
  String get includeCycle => 'Include cycle data';

  @override
  String get includePhotos => 'Include progress photos';

  @override
  String get working => 'Working…';

  @override
  String get restoreWarning => 'Restoring replaces the data on this phone with the backup\'s. This can\'t be undone.';

  @override
  String get restoreDone => 'Backup restored.';

  @override
  String get restoreWrongPassphrase => 'Wrong passphrase, or the file is damaged.';

  @override
  String get restoreNotBackup => 'This isn\'t a BMI Health backup file.';

  @override
  String get restoreNewer => 'This backup is from a newer version of the app. Update the app first.';

  @override
  String get csvWarning => 'Spreadsheet files are not encrypted. Anyone you share them with can read them.';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get batterySaver => 'Battery saver';

  @override
  String get batterySaverBody => 'Fewer, less precise location fixes. Uses less battery; short walks may be missed.';

  @override
  String trackingGap(String from, String to) {
    return 'Tracking stopped from $from to $to';
  }

  @override
  String get trackingGapBody => 'Your phone\'s battery saver probably closed the app.';

  @override
  String get keepTrackingOn => 'How to keep tracking on';

  @override
  String get keepTrackingIntro => 'Allow BMI Health to run in the background on your phone:';

  @override
  String get guideXiaomi => 'Xiaomi / Redmi / POCO: Settings → Apps → BMI Health → Battery saver → No restrictions. Also turn on Autostart.';

  @override
  String get guideOppo => 'Oppo / Realme / OnePlus: Settings → Battery → App battery management → BMI Health → Allow background activity.';

  @override
  String get guideVivo => 'Vivo / iQOO: Settings → Battery → Background power consumption → BMI Health → Allow.';

  @override
  String get guideSamsung => 'Samsung: Settings → Apps → BMI Health → Battery → Unrestricted.';

  @override
  String get guideHuawei => 'Huawei / Honor: Settings → Battery → App launch → BMI Health → Manage manually, all on.';

  @override
  String get guideOther => 'Other phones: Settings → Apps → BMI Health → Battery → Unrestricted (or \"Don\'t optimise\"). Don\'t swipe the app away from recent apps.';

  @override
  String setsReps(int sets, int min, int max) {
    return '$sets sets × $min–$max reps';
  }

  @override
  String setsSeconds(int sets, int min, int max) {
    return '$sets sets × $min–$max seconds';
  }

  @override
  String restBetween(String time) {
    return 'Rest $time between sets';
  }

  @override
  String get mistakesTitle => 'Common mistakes';

  @override
  String get alternativesTitle => 'Alternatives';

  @override
  String get muscleDayTitle => 'Train a muscle today';

  @override
  String get dayChest => 'Chest';

  @override
  String get dayBack => 'Back';

  @override
  String get dayShoulders => 'Shoulders';

  @override
  String get dayArms => 'Arms';

  @override
  String get dayLegs => 'Legs';

  @override
  String get dayGlutes => 'Glutes';

  @override
  String get dayCore => 'Core';

  @override
  String dayWorkout(String day) {
    return '$day workout';
  }

  @override
  String planSummary(int count, int sets, int minutes) {
    return '$count exercises · $sets sets · about $minutes min';
  }

  @override
  String get jointFriendlyNote => 'Joint-friendly picks based on your BMI: no jumping moves.';

  @override
  String get planBasedOn => 'Matched to your equipment and experience. Tap an exercise for steps and tips.';

  @override
  String get startThisWorkout => 'Start this workout';

  @override
  String get noExercisesForDay => 'No exercises match your equipment for this day yet.';

  @override
  String get homeChallenges => 'Home Challenges';

  @override
  String get homeChallengesBody => 'Day-by-day plans with no equipment. Pick a level and a focus.';

  @override
  String get levelBeginner => 'Beginner';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get levelAdvanced => 'Advanced';

  @override
  String levelLocked(String level) {
    return 'Finish $level in this focus to unlock';
  }

  @override
  String get focusFullBody => 'Full Body';

  @override
  String get focusUpperBody => 'Chest & Upper Body';

  @override
  String get focusCoreAbs => 'Core & Abs';

  @override
  String get focusLegsGlutes => 'Legs & Glutes';

  @override
  String get focusHiit => 'HIIT & Fat Burn';

  @override
  String get focusStretch => 'Stretch & Mobility';

  @override
  String challengeLength(int days, int minutes) {
    return '$days days · $minutes min a day';
  }

  @override
  String challengeProgress(int day, int total) {
    return 'Day $day of $total';
  }

  @override
  String get challengeDone => 'Completed!';

  @override
  String get restDay => 'Rest day';

  @override
  String get restDayBody => 'Recovery is part of training. Take a walk or stretch gently.';

  @override
  String get markRested => 'Mark as rested';

  @override
  String get todayPlan => 'Today\'s plan';

  @override
  String get warmUp => 'Warm-up';

  @override
  String get coolDown => 'Cool-down';

  @override
  String repsTarget(int count) {
    return '$count reps';
  }

  @override
  String secondsTarget(int count) {
    return '$count s';
  }

  @override
  String setOfTotal(int set, int total) {
    return 'Set $set of $total';
  }

  @override
  String get doneSet => 'Done';

  @override
  String get restNow => 'Rest';

  @override
  String nextUp(String name) {
    return 'Next: $name';
  }

  @override
  String get addTwenty => '+20 s';

  @override
  String get skipRest => 'Skip rest';

  @override
  String get skipExercise => 'Skip exercise';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get howTo2 => 'How to do it';

  @override
  String get quitWorkoutTitle => 'Quit this workout?';

  @override
  String get quitWorkoutBody => 'Today\'s progress won\'t be saved.';

  @override
  String get quit => 'Quit';

  @override
  String dayComplete(int day) {
    return 'Day $day complete!';
  }

  @override
  String dayCompleteBody(int minutes, int sets) {
    return '$minutes min · $sets sets. Great work, see you tomorrow.';
  }

  @override
  String challengeStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-day streak',
      one: '1-day streak',
    );
    return '$_temp0';
  }

  @override
  String get finishActiveFirst => 'Finish or discard your current workout first.';

  @override
  String get restartChallenge => 'Restart challenge';

  @override
  String continueChallenge(String name) {
    return 'Continue: $name';
  }

  @override
  String get voiceCoach => 'Voice coach';

  @override
  String sayExerciseReps(String name, int count) {
    return '$name. $count reps.';
  }

  @override
  String sayExerciseSeconds(String name, int count) {
    return '$name. $count seconds. Go!';
  }

  @override
  String saySetOf(int set, int total) {
    return 'Set $set of $total.';
  }

  @override
  String get sayHalfway => 'Halfway.';

  @override
  String sayRest(int count, String name) {
    return 'Rest $count seconds. Next: $name.';
  }

  @override
  String get sayGetReady => 'Get ready.';

  @override
  String sayDayComplete(int day) {
    return 'Day $day complete. Well done!';
  }
}
