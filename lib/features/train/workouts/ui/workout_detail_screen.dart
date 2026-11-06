import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/features/train/workouts/domain/workout.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/units/units.dart';
import 'package:bmi_health/shared/widgets/app_card.dart';

/// A finished workout: its sets, with edit, delete and rename.
class WorkoutDetailScreen extends StatelessWidget {
  final int workoutId;
  const WorkoutDetailScreen({super.key, required this.workoutId});

  static Future<void> open(BuildContext context, int workoutId) =>
      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
          builder: (_) => WorkoutDetailScreen(workoutId: workoutId)));

  Future<void> _rename(BuildContext context, WorkoutSummary h) async {
    final l = context.l10n;
    final c = TextEditingController(text: h.workout.name);
    final name = await showDialog<String>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.trainRename),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: InputDecoration(labelText: l.trainWorkoutName),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d),
              child: Text(MaterialLocalizations.of(d).cancelButtonLabel)),
          TextButton(onPressed: () => Navigator.pop(d, c.text), child: Text(l.save)),
        ],
      ),
    );
    c.dispose();
    if (name != null && name.trim().isNotEmpty && context.mounted) {
      await context.read<WorkoutProvider>().renameWorkout(workoutId, name);
    }
  }

  Future<void> _delete(BuildContext context) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        content: Text(l.trainDeleteWorkoutConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: Text(MaterialLocalizations.of(d).cancelButtonLabel)),
          TextButton(
              onPressed: () => Navigator.pop(d, true),
              child: Text(l.delete, style: const TextStyle(color: AppColors.bmiObese))),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final workouts = context.read<WorkoutProvider>();
    Navigator.pop(context);
    await workouts.deleteWorkout(workoutId);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final h = context.watch<WorkoutProvider>().summaryOf(workoutId);
    final unit = context.watch<ProfileProvider>().profile.weightUnit;
    final catalog = context.read<ExerciseCatalog>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCanvas = isDark ? AppColors.darkBgCanvas : AppColors.bgCanvas;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;

    // Deleted (its last set removed, or from elsewhere)
    if (h == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }
    final w = h.workout;
    final exercises = <String>[];
    for (final s in h.sets) {
      if (!exercises.contains(s.exerciseId)) exercises.add(s.exerciseId);
    }

    return Scaffold(
      backgroundColor: bgCanvas,
      appBar: AppBar(
        title: Text(w.name.isEmpty ? l.workoutDefaultName : w.name),
        actions: [
          IconButton(
            tooltip: l.trainRename,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _rename(context, h),
          ),
          IconButton(
            tooltip: l.trainDeleteWorkout,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _delete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            '${DateFormat.yMMMEd(l.localeName).add_jm().format(w.startedAt)}\n'
            '${l.minutesShort(w.duration.inMinutes)} · ${l.exercisesCount(h.exerciseCount)}'
            ' · ${l.volumeLabel(Units.weight(h.volumeKg, unit))}'
            '${h.prCount > 0 ? ' · 🏆 ${l.prCount(h.prCount)}' : ''}',
            style: GoogleFonts.inter(fontSize: 14, color: fg3, height: 1.5),
          ),
          const SizedBox(height: 4),
          Text(l.trainEditHint, style: GoogleFonts.inter(fontSize: 12, color: fg3)),
          const SizedBox(height: 12),
          for (final id in exercises)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                padding: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(catalog.byId(id)?.nameIn(l.localeName) ?? id,
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.w700, color: brand)),
                    const SizedBox(height: 4),
                    for (final (i, s) in h.sets.where((s) => s.exerciseId == id).indexed)
                      _FinishedSetRow(index: i, set: s, unit: unit),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FinishedSetRow extends StatelessWidget {
  final int index;
  final WorkoutSet set;
  final String unit;
  const _FinishedSetRow({required this.index, required this.set, required this.unit});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final workouts = context.read<WorkoutProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final text = set.weightKg > 0
        ? '${_trim(Units.kgTo(unit, set.weightKg))} $unit × ${set.reps}'
        : l.trainRepsCount(set.reps);
    return Dismissible(
      key: ValueKey('done-set-${set.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.bmiObese,
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 16),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => workouts.deleteFinishedSet(set),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        leading: CircleAvatar(
          radius: 14,
          child: Text('${index + 1}', style: GoogleFonts.inter(fontSize: 12)),
        ),
        title: Text(text,
            textDirection: TextDirection.ltr,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
        trailing: Icon(Icons.edit_outlined, size: 18, color: fg3),
        onTap: () => _edit(context),
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final l = context.l10n;
    final workouts = context.read<WorkoutProvider>();
    final edited = await showDialog<WorkoutSet>(
      context: context,
      builder: (_) => _EditSetDialog(set: set, unit: unit),
    );
    if (edited == null) return;
    if (edited.reps <= 0) {
      await workouts.deleteFinishedSet(set);
    } else {
      await workouts.updateFinishedSet(edited);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.trainSetSaved)));
    }
  }
}

String _trim(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

class _EditSetDialog extends StatefulWidget {
  final WorkoutSet set;
  final String unit;
  const _EditSetDialog({required this.set, required this.unit});

  @override
  State<_EditSetDialog> createState() => _EditSetDialogState();
}

class _EditSetDialogState extends State<_EditSetDialog> {
  late final _weight = TextEditingController(text: _fmt(Units.kgTo(widget.unit, widget.set.weightKg)));
  late final _reps = TextEditingController(text: '${widget.set.reps}');

  static String _fmt(double v) => v == 0
      ? ''
      : (v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1));

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.trainEditSet),
      content: Row(children: [
        Expanded(
          child: TextField(
            key: const ValueKey('edit-weight'),
            controller: _weight,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
            decoration: InputDecoration(labelText: widget.unit),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            key: const ValueKey('edit-reps'),
            controller: _reps,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: l.repsLabel),
          ),
        ),
      ]),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel)),
        TextButton(
          onPressed: () => Navigator.pop(
            context,
            widget.set.copyWith(
              weightKg: Units.toKg(widget.unit, double.tryParse(_weight.text) ?? 0),
              reps: int.tryParse(_reps.text) ?? 0,
            ),
          ),
          child: Text(l.save),
        ),
      ],
    );
  }
}
