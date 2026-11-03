import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:bmi_health/features/body/bmi/domain/bmi_calculator.dart';
import 'package:bmi_health/l10n/app_localizations.dart';

export 'package:bmi_health/l10n/app_localizations.dart';

/// Urdu ships to users only once every screen is translated. Until then it is
/// available in debug and profile builds for testing, and release builds
/// stay English-only so nobody sees a half-translated app.
const urduReady = false;

bool get urduEnabled => urduReady || !kReleaseMode;

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

  String bmiInputError(BmiInputError error) => switch (error) {
        BmiInputError.height => errorHeightRange,
        BmiInputError.weight => errorWeightRange,
      };
}
