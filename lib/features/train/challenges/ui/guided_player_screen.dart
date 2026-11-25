import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/core/review/review_prompter.dart';
import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/features/train/challenges/challenge_provider.dart';
import 'package:bmi_health/features/train/challenges/domain/challenge.dart';
import 'package:bmi_health/features/train/challenges/voice_coach.dart';
import 'package:bmi_health/features/train/challenges/ui/challenges_screen.dart' show ChallengeLabels;
import 'package:bmi_health/features/train/exercises/ui/exercise_media.dart';
import 'package:bmi_health/features/train/wear/wear_bridge.dart';
import 'package:bmi_health/features/train/workouts/domain/workout.dart';
import 'package:bmi_health/features/train/workouts/rest_alerts.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/widgets/app_button.dart';

enum _Phase { starting, work, rest, finished }

/// Guided, one-exercise-at-a-time player for a challenge day.
///
/// It runs on top of the normal workout logger, so the finished day lands
/// in history, streaks, badges and the muscle map, and "Done" on a paired
/// watch advances it too.
class GuidedPlayerScreen extends StatefulWidget {
  final ChallengeFocus focus;
  final ChallengeLevel level;
  final ChallengeDay plan;

  /// Spoken cues; tests pass a recording coach.
  final VoiceCoach? coach;

  const GuidedPlayerScreen(
      {super.key, required this.focus, required this.level, required this.plan, this.coach});

  @override
  State<GuidedPlayerScreen> createState() => GuidedPlayerScreenState();
}

class GuidedPlayerScreenState extends State<GuidedPlayerScreen> with WidgetsBindingObserver {
  late final WorkoutProvider _w = context.read<WorkoutProvider>();
  late final Map<String, ChallengeStep> _steps = {
    for (final s in widget.plan.steps) s.exercise.id: s
  };

  _Phase _phase = _Phase.starting;
  Timer? _ticker;
  bool _paused = false;
  int _doneCount = 0;
  int _restLeft = 0;
  int? _timedLeft;
  int? _timedForSet;
  final _startedAt = DateTime.now();
  int _setsDone = 0;
  late final VoiceCoach _coach = widget.coach ?? createVoiceCoach();
  int? _announcedSet;

  /// When the app went to the background; the countdowns stop meanwhile
  /// and catch up on return.
  DateTime? _bgAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _coach.load().then((_) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _begin());
  }

  void _say(String text) => _coach.say(text, locale: context.l10n.localeName);

  /// Names the exercise (or "Set 2 of 3") once per set.
  void _announce() {
    final next = _next;
    final step = _step;
    if (next == null || step == null || _announcedSet == next.set.id) return;
    _announcedSet = next.set.id;
    final l = context.l10n;
    if (next.index == 0) {
      final name = step.exercise.nameIn(l.localeName);
      _say(step.timed
          ? l.sayExerciseSeconds(name, step.target)
          : l.sayExerciseReps(name, step.target));
    } else {
      _say('${l.saySetOf(next.index + 1, next.total)} '
          '${step.timed ? l.secondsTarget(step.target) : l.repsTarget(step.target)}');
    }
  }

  Future<void> _begin() async {
    final l = context.l10n;
    await _w.start(
      routine: Routine(
        name: '${l.focus(widget.focus)} · ${l.challengeProgress(widget.plan.day, widget.level.days)}',
        exerciseIds: [for (final s in widget.plan.steps) s.exercise.id],
      ),
      targets: {for (final s in widget.plan.steps) s.exercise.id: s.asPrescription},
    );
    _w.addListener(_onWorkout);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    if (mounted) {
      setState(() => _phase = _Phase.work);
      _announce();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_bgAt != null || _phase == _Phase.rest) restAlerts.cancel();
    _ticker?.cancel();
    _w.removeListener(_onWorkout);
    _coach.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused || AppLifecycleState.hidden:
        if (_bgAt != null) return;
        _bgAt = DateTime.now();
        if (!_paused && _phase == _Phase.rest && _restLeft > 0) {
          restAlerts.schedule(_bgAt!.add(Duration(seconds: _restLeft)), context.l10n);
        }
      case AppLifecycleState.resumed:
        final since = _bgAt;
        if (since == null) return;
        _bgAt = null;
        restAlerts.cancel();
        if (!_paused) catchUp(DateTime.now().difference(since).inSeconds);
      default:
    }
  }

  /// Applies [seconds] spent away to the rest or timed-hold countdown.
  @visibleForTesting
  void catchUp(int seconds) {
    if (!mounted || seconds <= 0) return;
    setState(() {
      if (_phase == _Phase.rest) {
        _restLeft -= seconds;
        if (_restLeft <= 0) {
          _phase = _Phase.work;
          _announce();
        }
      } else if (_phase == _Phase.work && _timedLeft != null) {
        _timedLeft = _timedLeft! - seconds;
        if (_timedLeft! <= 0) _markDone();
      }
    });
  }

  ({String exerciseId, WorkoutSet set, int index, int total})? get _next =>
      _w.active == null ? null : WearState.nextSet(_w);

  Sex get _demonstrator => context.read<ProfileProvider>().profile.demonstrator;

  ChallengeStep? get _step => _next == null ? null : _steps[_next!.exerciseId];

  /// Reacts to sets being ticked here or on the watch.
  void _onWorkout() {
    if (!mounted || _phase == _Phase.finished || _w.active == null) return;
    final done = _w.activeSets.where((s) => s.done).length;
    if (done > _doneCount) {
      final justDone = _w.activeSets.where((s) => s.done).last.exerciseId;
      _doneCount = done;
      _setsDone = done;
      if (_next == null) {
        _finish();
        return;
      }
      final rest = _steps[justDone]?.restSec ?? 30;
      setState(() {
        _timedLeft = null;
        if (rest > 0) {
          _phase = _Phase.rest;
          _restLeft = rest;
        } else {
          _phase = _Phase.work;
        }
      });
      if (rest > 0) offerRestAlertsOnce(context);
      final l = context.l10n;
      if (rest > 0 && _step != null) {
        _say(l.sayRest(rest, _step!.exercise.nameIn(l.localeName)));
      } else {
        _announce();
      }
    } else {
      setState(() {});
    }
  }

  void _tick() {
    if (!mounted || _paused || _bgAt != null) return;
    setState(() {
      if (_phase == _Phase.rest) {
        _restLeft--;
        if (_restLeft == 5) _say(context.l10n.sayGetReady);
        if (_restLeft <= 3 && _restLeft > 0) {
          HapticFeedback.selectionClick();
          _say('$_restLeft');
        }
        if (_restLeft <= 0) {
          HapticFeedback.heavyImpact();
          _phase = _Phase.work;
          _announce();
        }
      } else if (_phase == _Phase.work) {
        final step = _step;
        final next = _next;
        _announce();
        if (step == null || next == null || !step.timed) return;
        // Start the countdown for each new timed set.
        if (_timedForSet != next.set.id) {
          _timedForSet = next.set.id;
          _timedLeft = step.target;
          return;
        }
        _timedLeft = (_timedLeft ?? step.target) - 1;
        if (step.target >= 20 && _timedLeft == step.target ~/ 2) {
          _say(context.l10n.sayHalfway);
        }
        if (_timedLeft! <= 3 && _timedLeft! > 0) {
          HapticFeedback.selectionClick();
          _say('$_timedLeft');
        }
        if (_timedLeft! <= 0) _markDone();
      }
    });
  }

  Future<void> _markDone() async {
    final next = _next;
    final step = _step;
    if (next == null || step == null) return;
    HapticFeedback.mediumImpact();
    await _w.updateSet(next.set.copyWith(done: true, reps: step.target));
  }

  Future<void> _skipExercise() async {
    final next = _next;
    if (next == null) return;
    final remaining = _w.setsFor(next.exerciseId).where((s) => !s.done).toList();
    for (final s in remaining) {
      await _w.removeSet(s);
    }
    if (_next == null) {
      _finish();
    } else {
      setState(() {
        _phase = _Phase.work;
        _timedLeft = null;
      });
    }
  }

  Future<void> _finish() async {
    if (_phase == _Phase.finished) return;
    final challenges = context.read<ChallengeProvider>();
    setState(() => _phase = _Phase.finished);
    _ticker?.cancel();
    _w.removeListener(_onWorkout);
    await _w.finish();
    await challenges.completeDay(widget.focus, widget.level, widget.plan.day);
    HapticFeedback.heavyImpact();
    ReviewPrompter.happyMoment();
    if (mounted) _say(context.l10n.sayDayComplete(widget.plan.day));
  }

  Future<void> _quit() async {
    if (_phase == _Phase.finished) {
      Navigator.pop(context);
      return;
    }
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.quitWorkoutTitle),
        content: Text(l.quitWorkoutBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: Text(MaterialLocalizations.of(d).cancelButtonLabel)),
          TextButton(onPressed: () => Navigator.pop(d, true), child: Text(l.quit)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    _w.removeListener(_onWorkout);
    await _w.discard();
    if (mounted) Navigator.pop(context);
  }

  static String _clock(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _quit();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: CloseButton(onPressed: _quit),
          title: Text(l.challengeProgress(widget.plan.day, widget.level.days)),
          actions: [
            IconButton(
              tooltip: l.voiceCoach,
              icon: Icon(_coach.enabled ? Icons.volume_up_rounded : Icons.volume_off_rounded),
              onPressed: () async {
                await _coach.setEnabled(!_coach.enabled);
                if (mounted) setState(() {});
              },
            ),
            if (_phase == _Phase.work || _phase == _Phase.rest)
              IconButton(
                tooltip: _paused ? l.resume : l.pause,
                icon: Icon(_paused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                onPressed: () => setState(() => _paused = !_paused),
              ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: switch (_phase) {
              _Phase.starting => const Center(child: CircularProgressIndicator()),
              _Phase.work => _work(l, brand),
              _Phase.rest => _rest(l, brand),
              _Phase.finished => _finished(l, brand),
            },
          ),
        ),
      ),
    );
  }

  Widget _work(AppLocalizations l, Color brand) {
    final next = _next;
    final step = _step;
    if (next == null || step == null) return const SizedBox.shrink();
    final e = step.exercise;
    final timed = step.timed;
    final left = _timedForSet == next.set.id ? (_timedLeft ?? step.target) : step.target;
    return Column(
      children: [
        if (step.isWarmup || step.isCooldown)
          Text((step.isWarmup ? l.warmUp : l.coolDown).toUpperCase(),
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: brand)),
        Text(e.nameIn(l.localeName),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(l.setOfTotal(next.index + 1, next.total), style: GoogleFonts.inter(fontSize: 15)),
        const SizedBox(height: 12),
        Expanded(child: ExerciseMedia(exercise: e, demonstrator: _demonstrator, caption: false)),
        const SizedBox(height: 12),
        // Big target: countdown for holds, rep goal otherwise
        SizedBox(
          width: 160,
          height: 160,
          child: Stack(alignment: Alignment.center, children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: timed ? left / step.target : 1,
                strokeWidth: 9,
                color: brand,
                backgroundColor: brand.withAlpha(40),
              ),
            ),
            Text(timed ? _clock(left) : l.repsTarget(step.target),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.w700)),
          ]),
        ),
        const SizedBox(height: 8),
        ExpansionTile(
          title: Text(l.howTo2),
          children: [
            for (final s in e.stepsIn(l.localeName))
              ListTile(dense: true, leading: const Icon(Icons.check_rounded, size: 18), title: Text(s)),
          ],
        ),
        const SizedBox(height: 8),
        AppButton(
          label: l.doneSet,
          icon: Icons.check_rounded,
          fullWidth: true,
          onPressed: _paused ? null : _markDone,
        ),
        TextButton(onPressed: _skipExercise, child: Text(l.skipExercise)),
      ],
    );
  }

  Widget _rest(AppLocalizations l, Color brand) {
    final next = _next;
    final step = _step;
    return Column(
      children: [
        Text(l.restNow.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: brand)),
        const Spacer(),
        Text(_clock(_restLeft < 0 ? 0 : _restLeft),
            style: GoogleFonts.inter(fontSize: 72, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        if (next != null && step != null)
          Text(
            '${l.nextUp(step.exercise.nameIn(l.localeName))}\n'
            '${l.setOfTotal(next.index + 1, next.total)} · '
            '${step.timed ? l.secondsTarget(step.target) : l.repsTarget(step.target)}',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 16, height: 1.4),
          ),
        const SizedBox(height: 12),
        if (step != null)
          Expanded(child: ExerciseMedia(exercise: step.exercise, demonstrator: _demonstrator, caption: false))
        else
          const Spacer(),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: AppButton(
              label: l.addTwenty,
              variant: AppButtonVariant.secondary,
              fullWidth: true,
              onPressed: () => setState(() => _restLeft += 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AppButton(
              label: l.skipRest,
              icon: Icons.skip_next_rounded,
              fullWidth: true,
              onPressed: () => setState(() {
                _restLeft = 0;
                _phase = _Phase.work;
              }),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _finished(AppLocalizations l, Color brand) {
    final minutes = DateTime.now().difference(_startedAt).inMinutes.clamp(1, 999);
    final streak = context.watch<ChallengeProvider>().streak;
    return Column(
      children: [
        const Spacer(),
        Icon(Icons.emoji_events_rounded, size: 96, color: AppColors.bmiOver),
        const SizedBox(height: 16),
        Text(l.dayComplete(widget.plan.day),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(l.dayCompleteBody(minutes, _setsDone),
            textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 16)),
        if (streak > 0) ...[
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.local_fire_department_rounded, color: AppColors.bmiOver),
            const SizedBox(width: 6),
            Text(l.challengeStreak(streak),
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
          ]),
        ],
        const Spacer(),
        AppButton(
          label: l.continueLabel,
          fullWidth: true,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
