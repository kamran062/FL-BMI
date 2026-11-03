import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';

/// Searchable, filterable list of exercises.
/// With [onPick] set it works as a picker for the active workout.
class ExerciseLibraryScreen extends StatefulWidget {
  final ValueChanged<Exercise>? onPick;
  final ValueChanged<Exercise> onOpen;
  final VoidCallback onClose;

  const ExerciseLibraryScreen({
    super.key,
    this.onPick,
    required this.onOpen,
    required this.onClose,
  });

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  String _query = '';
  Muscle? _muscle;
  bool _myEquipment = true;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final locale = l.localeName;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final catalog = context.watch<ExerciseCatalog>();
    final allowed =
        equipmentFor(context.watch<ProfileProvider>().profile.equipment);
    final q = _query.trim().toLowerCase();

    final items = catalog.exercises.where((e) {
      if (_myEquipment && !allowed.contains(e.equipment)) return false;
      if (_muscle != null && e.primary != _muscle) return false;
      if (q.isNotEmpty &&
          !e.name.values.any((n) => n.toLowerCase().contains(q))) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => a.nameIn(locale).compareTo(b.nameIn(locale)));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.onPick == null ? l.exerciseLibrary : l.addExercise),
        leading: IconButton(
          icon: Icon(widget.onPick == null
              ? Icons.arrow_back_rounded
              : Icons.close_rounded),
          onPressed: widget.onClose,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: l.searchExercises,
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _Chip(
                  label: l.myEquipmentOnly,
                  icon: Icons.fitness_center_rounded,
                  selected: _myEquipment,
                  onTap: () => setState(() => _myEquipment = !_myEquipment),
                ),
                _Chip(
                  label: l.allMuscles,
                  selected: _muscle == null,
                  onTap: () => setState(() => _muscle = null),
                ),
                for (final m in Muscle.values)
                  _Chip(
                    label: l.muscle(m),
                    selected: _muscle == m,
                    onTap: () => setState(() => _muscle = m),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, i) {
                final e = items[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: brand.withAlpha(30),
                    child: Icon(Icons.fitness_center_rounded,
                        color: brand, size: 20),
                  ),
                  title: Text(e.nameIn(locale),
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${l.muscle(e.primary)} · ${l.exerciseEquipment(e.equipment)}',
                    style: GoogleFonts.inter(fontSize: 13, color: fg3),
                  ),
                  trailing: widget.onPick == null
                      ? const Icon(Icons.chevron_right_rounded)
                      : IconButton(
                          icon: Icon(Icons.info_outline_rounded, color: fg3),
                          onPressed: () => widget.onOpen(e),
                        ),
                  onTap: () => widget.onPick == null
                      ? widget.onOpen(e)
                      : widget.onPick!(e),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _Chip(
      {required this.label, this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FilterChip(
          avatar: icon == null ? null : Icon(icon, size: 16),
          label: Text(label),
          selected: selected,
          showCheckmark: false,
          onSelected: (_) => onTap(),
        ),
      );
}
