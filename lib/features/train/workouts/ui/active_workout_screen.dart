import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/features/train/workouts/domain/workout.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/units/units.dart';
import 'package:bmi_health/shared/widgets/app_button.dart';
import 'package:bmi_health/shared/widgets/app_card.dart';
import 'package:bmi_health/features/train/programs/progression.dart';
import 'package:bmi_health/features/train/wear/wear_bridge.dart';
import 'package:bmi_health/features/train/workouts/rest_alerts.dart';

/// Logs the active workout: exercises, sets (weight × reps), rest timer.
class ActiveWorkoutScreen extends StatefulWidget {
  /// Opens the exercise picker; resolves to the chosen exercise id.
  final Future<String?> Function() pickExercise;
  final VoidCallback onClose;

  const ActiveWorkoutScreen(
      {super.key, required this.pickExercise, required this.onClose});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen>
    with WidgetsBindingObserver {

  Timer? _ticker;

  /// When the current rest ends. Kept as a time (not a countdown) so it
  /// stays right while the app is in the background.
  DateTime? _restEnd;
  bool _inBackground = false;

  int get _restLeft {
    final end = _restEnd;
    if (end == null) return 0;
    final ms = end.difference(DateTime.now()).inMilliseconds;
    return ms <= 0 ? 0 : (ms / 1000).ceil();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Drives the elapsed clock and the rest countdown.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_restEnd != null && _restLeft == 0) {
          _restEnd = null;
          if (!_inBackground) HapticFeedback.heavyImpact();
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final l = context.l10n;
    switch (state) {
      case AppLifecycleState.paused || AppLifecycleState.hidden:
        if (_inBackground) return;
        _inBackground = true;
        final end = _restEnd;
        if (end != null && _restLeft > 0) restAlerts.schedule(end, l);
      case AppLifecycleState.resumed:
        if (!_inBackground) return;
        _inBackground = false;
        restAlerts.cancel();
        setState(() {});
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    if (_restEnd != null) restAlerts.cancel();
    super.dispose();
  }

  void _startRest(int seconds) {
    setState(() => _restEnd = DateTime.now().add(Duration(seconds: seconds)));
    offerRestAlertsOnce(context);
  }

  void _skipRest() {
    setState(() => _restEnd = null);
    restAlerts.cancel();
  }

  Future<void> _addExercise() async {
    final id = await widget.pickExercise();
    if (id != null && mounted) {
      await context.read<WorkoutProvider>().addExercise(id);
    }
  }

  Future<void> _finish() async {
    final l = context.l10n;
    final workouts = context.read<WorkoutProvider>();
    final summary = await workouts.finish();
    if (!mounted) return;
    if (summary == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.nothingLogged)));
      widget.onClose();
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => _SummaryDialog(summary: summary),
    );
    if (mounted) widget.onClose();
  }

  Future<void> _discard() async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Text(l.discardConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(MaterialLocalizations.of(c).cancelButtonLabel)),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(l.discard,
                  style: const TextStyle(color: AppColors.bmiObese))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await context.read<WorkoutProvider>().discard();
    if (mounted) widget.onClose();
  }

  String _clock(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final workouts = context.watch<WorkoutProvider>();
    final catalog = context.read<ExerciseCatalog>();
    final active = workouts.active;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;

    if (active == null) {
      // Finished or discarded elsewhere
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            onPressed: widget.onClose),
        title: Text(_clock(active.duration),
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()])),
        actions: [
          // Heart rate from the watch, when one is sending it
          ValueListenableBuilder<int?>(
            valueListenable: context.read<WearBridge>().heartRate,
            builder: (context, _, __) {
              final bpm = context.read<WearBridge>().currentHeartRate;
              if (bpm == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 4),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.favorite_rounded, color: AppColors.bmiObese, size: 18),
                  const SizedBox(width: 4),
                  Text('$bpm', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                ]),
              );
            },
          ),
          IconButton(
            tooltip: l.discardWorkout,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _discard,
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: FilledButton(onPressed: _finish, child: Text(l.finishWorkout)),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_restLeft > 0)
            Material(
              color: brand,
              child: ListTile(
                textColor: Colors.white,
                iconColor: Colors.white,
                leading: const Icon(Icons.timer_outlined),
                title: Text(l.restTimer(_clock(Duration(seconds: _restLeft))),
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                trailing: TextButton(
                  onPressed: _skipRest,
                  child: Text(l.skip2, style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
              children: [
                for (final id in workouts.activeExercises)
                  _ExerciseBlock(
                    exercise: catalog.byId(id),
                    exerciseId: id,
                    // Rest suited to the exercise (heavy lifts rest longer)
                    onSetDone: () =>
                        _startRest(catalog.byId(id)?.prescription.restSec ?? 90),
                  ),
                const SizedBox(height: 8),
                AppButton(
                  label: l.addExercise,
                  icon: Icons.add_rounded,
                  variant: AppButtonVariant.secondary,
                  fullWidth: true,
                  onPressed: _addExercise,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseBlock extends StatelessWidget {
  final Exercise? exercise;
  final String exerciseId;
  final VoidCallback onSetDone;

  const _ExerciseBlock(
      {required this.exercise, required this.exerciseId, required this.onSetDone});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final workouts = context.watch<WorkoutProvider>();
    final unit = context.watch<ProfileProvider>().profile.weightUnit;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final sets = workouts.setsFor(exerciseId);
    final previous = workouts.previousSets(exerciseId);
    final header = GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w600, color: fg3);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exercise?.nameIn(l.localeName) ?? exerciseId,
                          style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.w700, color: brand)),
                      if (exercise != null)
                        _SuggestionText(
                          suggestion: Progression.suggest(
                              workouts.sessionsFor(exerciseId), exercise!.equipment,
                              deloadWeek: workouts.deloadDue(
                                  context.read<ProfileProvider>().profile.daysPerWeek)),
                          unit: unit,
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (_) => workouts.removeExercise(exerciseId),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'remove', child: Text(l.removeExercise)),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 36, child: Text(l.setLabel, style: header)),
                Expanded(flex: 3, child: Text(l.previousLabel, style: header)),
                Expanded(flex: 2, child: Text(unit, style: header, textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text(l.repsLabel, style: header, textAlign: TextAlign.center)),
                const SizedBox(width: 48),
              ],
            ),
            for (var i = 0; i < sets.length; i++)
              _SetRow(
                key: ValueKey(sets[i].id),
                tag: WorkoutMath.setTag(sets, i),
                set: sets[i],
                previous: i < previous.length ? previous[i] : null,
                unit: unit,
                onDone: onSetDone,
              ),
            TextButton.icon(
              onPressed: () => workouts.addSet(exerciseId),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l.addSet),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetRow extends StatefulWidget {
  /// "1", "2"… or "W" (warm-up) / "D" (drop set).
  final String tag;
  final WorkoutSet set;
  final WorkoutSet? previous;
  final String unit;
  final VoidCallback onDone;

  const _SetRow({
    super.key,
    required this.tag,
    required this.set,
    required this.previous,
    required this.unit,
    required this.onDone,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late final TextEditingController _weight = TextEditingController(
      text: _fmt(Units.kgTo(widget.unit, widget.set.weightKg)));
  late final TextEditingController _reps = TextEditingController(
      text: widget.set.reps == 0 ? '' : '${widget.set.reps}');

  static String _fmt(double v) => v == 0
      ? ''
      : (v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1));

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    super.dispose();
  }

  WorkoutSet _fromFields() => widget.set.copyWith(
        weightKg: Units.toKg(widget.unit, double.tryParse(_weight.text) ?? 0),
        reps: int.tryParse(_reps.text) ?? 0,
      );

  Future<void> _options(BuildContext context) async {
    final workouts = context.read<WorkoutProvider>();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SetOptionsSheet(
        set: widget.set,
        onChanged: (s) => workouts.updateSet(_fromFields().copyWith(type: s.type, rpe: s.rpe, clearRpe: s.rpe == null)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workouts = context.read<WorkoutProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final done = widget.set.done;
    final p = widget.previous;

    InputDecoration deco() => const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        );

    return Dismissible(
      key: ValueKey('set-${widget.set.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.bmiObese,
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 16),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => workouts.removeSet(widget.set),
      child: Container(
        color: done ? brand.withAlpha(25) : null,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _options(context),
                child: Semantics(
                  button: true,
                  label: context.l10n.trainSetOptions,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.tag,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: widget.set.type == SetType.normal ? null : AppColors.bmiOver)),
                      if (widget.set.rpe != null)
                        Text('@${WorkoutMath.rpeText(widget.set.rpe!)}',
                            style: GoogleFonts.inter(fontSize: 11, color: fg3)),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                p == null
                    ? '—'
                    : '${_fmt(Units.kgTo(widget.unit, p.weightKg))} × ${p.reps}',
                textDirection: TextDirection.ltr,
                style: GoogleFonts.inter(fontSize: 13, color: fg3),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  controller: _weight,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                  decoration: deco(),
                  onChanged: (_) => workouts.updateSet(_fromFields()),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  controller: _reps,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: deco(),
                  onChanged: (_) => workouts.updateSet(_fromFields()),
                ),
              ),
            ),
            SizedBox(
              width: 48,
              child: IconButton(
                icon: Icon(
                  done ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                  color: done ? brand : fg3,
                ),
                onPressed: () {
                  final next = _fromFields().copyWith(done: !done);
                  // A set needs reps to count
                  if (!done && next.reps <= 0) return;
                  HapticFeedback.selectionClick();
                  workouts.updateSet(next);
                  if (!done) widget.onDone();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryDialog extends StatefulWidget {
  final WorkoutSummary summary;
  const _SummaryDialog({required this.summary});

  @override
  State<_SummaryDialog> createState() => _SummaryDialogState();
}

class _SummaryDialogState extends State<_SummaryDialog> {
  final _name = TextEditingController();
  bool _saved = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = widget.summary;
    final unit = context.read<ProfileProvider>().profile.weightUnit;
    final exercises = <String>[];
    for (final x in s.sets) {
      if (!exercises.contains(x.exerciseId)) exercises.add(x.exerciseId);
    }

    return AlertDialog(
      title: Text(l.workoutComplete),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (s.prCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('🏆 ${l.newPrs(s.prCount)}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          Text('${l.minutesShort(s.workout.duration.inMinutes)} · '
              '${l.exercisesCount(s.exerciseCount)}'),
          Text(l.volumeLabel(Units.weight(s.volumeKg, unit))),
          const SizedBox(height: 16),
          if (!_saved) ...[
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: l.routineName),
            ),
            TextButton.icon(
              icon: const Icon(Icons.bookmark_add_outlined),
              label: Text(l.saveAsRoutine),
              onPressed: () async {
                await context
                    .read<WorkoutProvider>()
                    .saveRoutine(_name.text, exercises);
                if (mounted && _name.text.trim().isNotEmpty) {
                  setState(() => _saved = true);
                }
              },
            ),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.done)),
      ],
    );
  }
}

/// "Try 62.5 kg × 8" under the exercise name (ROADMAP 3.2).
class _SuggestionText extends StatelessWidget {
  final Suggestion suggestion;
  final String unit;
  const _SuggestionText({required this.suggestion, required this.unit});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = suggestion;
    if (s.reason == SuggestionReason.firstTime) return const SizedBox.shrink();
    final w = Units.weight(s.weightKg, unit);
    final text = s.weightKg == 0
        ? (s.reason == SuggestionReason.deloadWeek ? l.suggestionDeloadReps(s.reps) : l.suggestionRepsOnly(s.reps))
        : switch (s.reason) {
            SuggestionReason.increase => l.suggestionIncrease(w, s.reps),
            SuggestionReason.deload => l.suggestionDeload(w, s.reps),
            SuggestionReason.deloadWeek => l.suggestionDeloadWeek(w, s.reps),
            SuggestionReason.hold => l.suggestionHold(w, s.reps),
            _ => l.suggestionAddRep(w, s.reps),
          };
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(children: [
        Icon(
          switch (s.reason) {
            SuggestionReason.increase => Icons.trending_up_rounded,
            SuggestionReason.deload => Icons.refresh_rounded,
            SuggestionReason.deloadWeek => Icons.battery_charging_full_rounded,
            SuggestionReason.hold => Icons.pause_rounded,
            _ => Icons.add_rounded,
          },
          size: 14,
          color: isDark ? AppColors.darkFg3 : AppColors.fg3,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(text,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? AppColors.darkFg2 : AppColors.fg2)),
        ),
      ]),
    );
  }
}

/// Choose a set's type (normal / warm-up / drop) and rate its effort.
class SetOptionsSheet extends StatefulWidget {
  final WorkoutSet set;
  final ValueChanged<WorkoutSet> onChanged;
  const SetOptionsSheet({super.key, required this.set, required this.onChanged});

  @override
  State<SetOptionsSheet> createState() => _SetOptionsSheetState();
}

class _SetOptionsSheetState extends State<SetOptionsSheet> {
  late WorkoutSet _set = widget.set;

  void _change(WorkoutSet s) {
    setState(() => _set = s);
    widget.onChanged(s);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final label = GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.trainSetOptions, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final (t, name) in [
                (SetType.normal, l.trainSetNormal),
                (SetType.warmup, l.trainSetWarmup),
                (SetType.drop, l.trainSetDrop),
              ])
                ChoiceChip(
                  label: Text(name),
                  selected: _set.type == t,
                  onSelected: (_) => _change(_set.copyWith(type: t)),
                ),
            ]),
            if (_set.type == SetType.warmup) ...[
              const SizedBox(height: 8),
              Text(l.trainWarmupNote, style: GoogleFonts.inter(fontSize: 12, color: fg3)),
            ],
            const SizedBox(height: 20),
            Text(l.trainRpe, style: label),
            const SizedBox(height: 4),
            Text(l.trainRpeHelp, style: GoogleFonts.inter(fontSize: 12, color: fg3)),
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: [
              ChoiceChip(
                label: Text(l.trainRpeNone),
                selected: _set.rpe == null,
                onSelected: (_) => _change(_set.copyWith(clearRpe: true)),
              ),
              for (final r in WorkoutSet.rpeChoices)
                ChoiceChip(
                  label: Text(WorkoutMath.rpeText(r)),
                  selected: _set.rpe == r,
                  onSelected: (_) => _change(_set.copyWith(rpe: r)),
                ),
            ]),
          ],
        ),
      ),
    );
  }
}
