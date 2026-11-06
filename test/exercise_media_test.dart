import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:bmi_health/features/train/exercises/demo/exercise_demo.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/features/train/exercises/ui/exercise_media.dart';
import 'package:bmi_health/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => ExerciseDemo.loop = false);

  Exercise pushUp({String? male, String? female}) => Exercise(
        id: 'push_up',
        name: const {'en': 'Push-up'},
        primary: Muscle.chest,
        equipment: ExerciseEquipment.bodyweight,
        difficulty: Difficulty.beginner,
        maleVideo: male,
        femaleVideo: female,
      );

  Widget host(Exercise e, Sex who) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(width: 320, height: 200, child: ExerciseMedia(exercise: e, demonstrator: who)),
        ),
      );

  testWidgets('no clip yet: the animated guide with its caption', (tester) async {
    await tester.pumpWidget(host(pushUp(), Sex.female));
    await tester.pump();
    expect(find.byType(ExerciseDemo), findsOneWidget);
    expect(find.text('Animated guide · video coming soon'), findsOneWidget);
  });

  testWidgets("a clip that can't play falls back to the animation", (tester) async {
    await tester.pumpWidget(host(pushUp(female: 'asset:assets/videos/missing.mp4'), Sex.female));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ExerciseDemo), findsOneWidget);
  });

  test("each trainer falls back to the other trainer's clip", () {
    final onlyFemale = pushUp(female: 'https://example.org/push_up_female.mp4');
    expect(onlyFemale.videoFor(Sex.male), 'https://example.org/push_up_female.mp4');
    final both = pushUp(male: 'm.mp4', female: 'f.mp4');
    expect(both.videoFor(Sex.male), 'm.mp4');
    expect(both.videoFor(Sex.female), 'f.mp4');
  });
}
