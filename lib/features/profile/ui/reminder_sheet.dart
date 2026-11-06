import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:bmi_health/core/notifications/reminder_settings.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/widgets/app_button.dart';

/// [minutes] after midnight in the phone's 12/24 h style.
String formatMinutes(BuildContext context, int minutes) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
        TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context));

/// Weekday name (DateTime.monday … sunday) in the app language.
String weekdayName(AppLocalizations l, int weekday, {bool short = false}) {
  final date = DateTime(2026, 11, 1 + weekday); // 2 Nov 2026 is a Monday
  return (short ? DateFormat.E(l.localeName) : DateFormat.EEEE(l.localeName)).format(date);
}

/// Mon … Sun, or Sun … Sat where the week starts on Sunday.
List<int> weekdaysInOrder(BuildContext context) {
  final first = MaterialLocalizations.of(context).firstDayOfWeekIndex; // 0 = Sunday
  return [for (var i = 0; i < 7; i++) (first + i + 6) % 7 + 1];
}

/// One line describing when [kind] fires, for the settings row.
String reminderSummary(
    BuildContext context, ReminderKind kind, ReminderSettings r, int perWeek) {
  final l = context.l10n;
  String t(int m) => formatMinutes(context, m);
  return switch (kind) {
    ReminderKind.daily => l.remindDailyAt(t(r.dailyAt)),
    ReminderKind.weekly => l.remindWeeklyAt(weekdayName(l, r.weeklyDay), t(r.weeklyAt)),
    ReminderKind.water => l.remindWaterEvery(r.waterEveryHours, t(r.waterFrom), t(r.waterTo)),
    ReminderKind.weighIn => l.remindWeeklyAt(weekdayName(l, r.weighInDay), t(r.weighInAt)),
    ReminderKind.workout => l.remindDaysAt(
        [
          for (final d in weekdaysInOrder(context))
            if ((r.workoutDays ?? ReminderSettings.defaultWorkoutDays(perWeek)).contains(d))
              weekdayName(l, d, short: true)
        ].join(', '),
        t(r.workoutAt)),
    ReminderKind.bedtime => l.remindDailyAt(t(r.bedtimeAt)),
  };
}

/// Edits the schedule of [kind]. Returns the new settings, or null if
/// dismissed.
Future<ReminderSettings?> editReminder(BuildContext context, ReminderKind kind,
        ReminderSettings r, int perWeek) =>
    showModalBottomSheet<ReminderSettings>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => _ReminderSheet(kind: kind, initial: r, perWeek: perWeek),
    );

class _ReminderSheet extends StatefulWidget {
  final ReminderKind kind;
  final ReminderSettings initial;
  final int perWeek;
  const _ReminderSheet({required this.kind, required this.initial, required this.perWeek});

  @override
  State<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<_ReminderSheet> {
  late ReminderSettings _r = widget.initial;

  String _title(AppLocalizations l) => switch (widget.kind) {
        ReminderKind.daily => l.dailyReminders,
        ReminderKind.weekly => l.weeklyCheckIn,
        ReminderKind.water => l.remindWater,
        ReminderKind.weighIn => l.remindWeighIn,
        ReminderKind.workout => l.remindWorkout,
        ReminderKind.bedtime => l.remindBedtime,
      };

  Future<int?> _pickTime(int minutes) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
    );
    return t == null ? null : t.hour * 60 + t.minute;
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(text, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
      );

  Widget _timeTile(int minutes, ValueChanged<int> onChanged, {String? label}) {
    final l = context.l10n;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.schedule_rounded),
      title: Text(label ?? l.remindTime),
      trailing: Text(formatMinutes(context, minutes),
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
      onTap: () async {
        final m = await _pickTime(minutes);
        if (m != null) setState(() => onChanged(m));
      },
    );
  }

  Widget _dayPicker(int selected, ValueChanged<int> onChanged) {
    final l = context.l10n;
    return Wrap(spacing: 6, runSpacing: 6, children: [
      for (final d in weekdaysInOrder(context))
        ChoiceChip(
          label: Text(weekdayName(l, d, short: true)),
          selected: selected == d,
          onSelected: (_) => setState(() => onChanged(d)),
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final workoutDays =
        _r.workoutDays ?? ReminderSettings.defaultWorkoutDays(widget.perWeek);
    final canSave = widget.kind != ReminderKind.workout || workoutDays.isNotEmpty;

    final body = <Widget>[
      ...switch (widget.kind) {
        ReminderKind.daily => [_timeTile(_r.dailyAt, (m) => _r = _r.copyWith(dailyAt: m))],
        ReminderKind.bedtime => [_timeTile(_r.bedtimeAt, (m) => _r = _r.copyWith(bedtimeAt: m))],
        ReminderKind.weekly => [
            _label(l.remindDay),
            _dayPicker(_r.weeklyDay, (d) => _r = _r.copyWith(weeklyDay: d)),
            _timeTile(_r.weeklyAt, (m) => _r = _r.copyWith(weeklyAt: m)),
          ],
        ReminderKind.weighIn => [
            _label(l.remindDay),
            _dayPicker(_r.weighInDay, (d) => _r = _r.copyWith(weighInDay: d)),
            _timeTile(_r.weighInAt, (m) => _r = _r.copyWith(weighInAt: m)),
          ],
        ReminderKind.workout => [
            _label(l.remindDays),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final d in weekdaysInOrder(context))
                FilterChip(
                  label: Text(weekdayName(l, d, short: true)),
                  selected: workoutDays.contains(d),
                  showCheckmark: false,
                  onSelected: (on) => setState(() {
                    final now = _r.workoutDays ??
                        ReminderSettings.defaultWorkoutDays(widget.perWeek);
                    _r = _r.copyWith(workoutDays: on ? {...now, d} : ({...now}..remove(d)));
                  }),
                ),
            ]),
            if (workoutDays.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(l.remindPickDay,
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.bmiObese)),
              ),
            _timeTile(_r.workoutAt, (m) => _r = _r.copyWith(workoutAt: m)),
          ],
        ReminderKind.water => [
            _label(l.remindEvery),
            Wrap(spacing: 6, children: [
              for (final h in ReminderSettings.waterIntervals)
                ChoiceChip(
                  label: Text(l.remindHours(h)),
                  selected: _r.waterEveryHours == h,
                  onSelected: (_) => setState(() => _r = _r.copyWith(waterEveryHours: h)),
                ),
            ]),
            _timeTile(_r.waterFrom, label: l.remindFrom, (m) {
              _r = _r.copyWith(waterFrom: m, waterTo: m > _r.waterTo ? m : null);
            }),
            _timeTile(_r.waterTo, label: l.remindUntil, (m) {
              _r = _r.copyWith(waterTo: m, waterFrom: m < _r.waterFrom ? m : null);
            }),
          ],
      },
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_title(l), style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700)),
            Text(reminderSummary(context, widget.kind, _r, widget.perWeek),
                style: GoogleFonts.inter(fontSize: 14, color: fg3)),
            ...body,
            const SizedBox(height: 12),
            AppButton(
              label: l.save,
              fullWidth: true,
              disabled: !canSave,
              onPressed: canSave ? () => Navigator.pop(context, _r) : null,
            ),
          ],
        ),
      ),
    );
  }
}
