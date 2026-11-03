import 'package:flutter/widgets.dart';
import 'package:bmi_health/core/config/feature_flags.dart';
import 'package:bmi_health/features/body/bmi/domain/bmi_calculator.dart';
import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:bmi_health/l10n/app_localizations.dart';

export 'package:bmi_health/l10n/app_localizations.dart';

/// Whether this build offers Urdu. See [FeatureFlags.urdu].
bool get urduEnabled => FeatureFlags.urdu;

/// Locales the app offers in this build.
List<Locale> get appSupportedLocales => urduEnabled
    ? AppLocalizations.supportedLocales
    : const [Locale('en')];

extension L10nContext on BuildContext {
  /// Strings for the current app language: `context.l10n.calculateBmi`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Advice shown on the result screen for one BMI category.
typedef BmiAdvice = ({String headline, String copy, List<String> steps, String note});

/// Display text for domain values. Domain code returns keys and enums;
/// only the UI turns them into words, so the logic stays language-free.
extension L10nDomain on AppLocalizations {
  String bmiCategory(String key) => switch (key) {
        'under' => categoryUnder,
        'normal' => categoryNormal,
        'over' => categoryOver,
        _ => categoryObese,
      };

  String gender(String code) => switch (code) {
        'm' => genderMale,
        'f' => genderFemale,
        _ => genderOther,
      };

  BmiAdvice bmiAdvice(String categoryKey) => switch (categoryKey) {
        'under' => (
            headline: adviceUnderHeadline,
            copy: adviceUnderCopy,
            steps: [adviceUnderStep1, adviceUnderStep2, adviceUnderStep3, adviceUnderStep4, adviceUnderStep5, adviceUnderStep6],
            note: adviceUnderNote,
          ),
        'normal' => (
            headline: adviceNormalHeadline,
            copy: adviceNormalCopy,
            steps: [adviceNormalStep1, adviceNormalStep2, adviceNormalStep3, adviceNormalStep4, adviceNormalStep5, adviceNormalStep6],
            note: adviceNormalNote,
          ),
        'over' => (
            headline: adviceOverHeadline,
            copy: adviceOverCopy,
            steps: [adviceOverStep1, adviceOverStep2, adviceOverStep3, adviceOverStep4, adviceOverStep5, adviceOverStep6],
            note: adviceOverNote,
          ),
        _ => (
            headline: adviceObeseHeadline,
            copy: adviceObeseCopy,
            steps: [adviceObeseStep1, adviceObeseStep2, adviceObeseStep3, adviceObeseStep4, adviceObeseStep5, adviceObeseStep6],
            note: adviceObeseNote,
          ),
      };

  String fitnessGoal(FitnessGoal g) => switch (g) {
        FitnessGoal.loseFat => goalLoseFat,
        FitnessGoal.buildMuscle => goalBuildMuscle,
        FitnessGoal.getStronger => goalGetStronger,
        FitnessGoal.stayFit => goalStayFit,
      };

  String fitnessGoalBody(FitnessGoal g) => switch (g) {
        FitnessGoal.loseFat => goalLoseFatBody,
        FitnessGoal.buildMuscle => goalBuildMuscleBody,
        FitnessGoal.getStronger => goalGetStrongerBody,
        FitnessGoal.stayFit => goalStayFitBody,
      };

  String experience(Experience e) => switch (e) {
        Experience.beginner => expBeginner,
        Experience.intermediate => expIntermediate,
        Experience.advanced => expAdvanced,
      };

  String experienceBody(Experience e) => switch (e) {
        Experience.beginner => expBeginnerBody,
        Experience.intermediate => expIntermediateBody,
        Experience.advanced => expAdvancedBody,
      };

  String equipment(Equipment e) => switch (e) {
        Equipment.gym => equipGym,
        Equipment.home => equipHome,
        Equipment.none => equipNone,
      };

  String equipmentBody(Equipment e) => switch (e) {
        Equipment.gym => equipGymBody,
        Equipment.home => equipHomeBody,
        Equipment.none => equipNoneBody,
      };

  String demonstrator(DemonstratorPref d) => switch (d) {
        DemonstratorPref.auto => demonstratorAuto,
        DemonstratorPref.male => demonstratorMale,
        DemonstratorPref.female => demonstratorFemale,
      };

  String formulaBody(Sex s) => switch (s) {
        Sex.male => bodyMale,
        Sex.female => bodyFemale,
      };

  String bmiInputError(BmiInputError error) => switch (error) {
        BmiInputError.height => errorHeightRange,
        BmiInputError.weight => errorWeightRange,
      };
}
