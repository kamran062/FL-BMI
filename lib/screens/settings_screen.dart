import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/app_toggle.dart';
import '../widgets/overline_label.dart';
import '../widgets/screen_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCanvas = isDark ? AppColors.darkBgCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final bgTint = isDark ? AppColors.darkBgTint : AppColors.bgTint;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final sections = [
          _Section(
            title: 'Appearance',
            rows: [
              _Row(
                icon: Icons.dark_mode_outlined,
                label: 'Dark mode',
                kind: _RowKind.toggle,
                toggleValue: provider.isDark,
                onToggle: (v) => provider.setTheme(
                    v ? ThemeMode.dark : ThemeMode.light),
              ),
            ],
          ),
          _Section(
            title: 'Units',
            rows: [
              _Row(
                icon: Icons.straighten_rounded,
                label: 'Height',
                kind: _RowKind.meta,
                meta: provider.profile.heightUnit == 'cm' ? 'cm' : 'ft / in',
              ),
              _Row(
                icon: Icons.monitor_weight_outlined,
                label: 'Weight',
                kind: _RowKind.meta,
                meta: provider.profile.weightUnit == 'kg' ? 'kg' : 'lbs',
              ),
            ],
          ),
          _Section(
            title: 'Notifications',
            rows: [
              _Row(
                icon: Icons.notifications_outlined,
                label: 'Daily reminders',
                kind: _RowKind.toggle,
                toggleValue: provider.dailyReminder,
                onToggle: provider.setDailyReminder,
              ),
              _Row(
                icon: Icons.calendar_today_outlined,
                label: 'Weekly check-in',
                kind: _RowKind.toggle,
                toggleValue: provider.weeklyCheckIn,
                onToggle: provider.setWeeklyCheckIn,
              ),
            ],
          ),
          _Section(
            title: 'About',
            rows: [
              _Row(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy',
                kind: _RowKind.nav,
                meta: 'On-device',
                onTap: () => _showPrivacyDialog(context, isDark, fg1, fg3, brand),
              ),
              _Row(
                icon: Icons.info_outline_rounded,
                label: 'Version',
                kind: _RowKind.meta,
                meta: '1.0 (build 1)',
              ),
            ],
          ),
        ];

        return Scaffold(
          backgroundColor: bgCanvas,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: ScreenHeader(title: 'Settings', large: true),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      ...sections.map((sec) => Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: OverlineLabel(sec.title),
                            ),
                            AppCard(
                              padding: 0,
                              child: Column(
                                children: sec.rows.asMap().entries.map((e) {
                                  final ri = e.key;
                                  final r = e.value;
                                  return _SettingsRow(
                                    row: r, index: ri,
                                    isDark: isDark,
                                    bgTint: bgTint,
                                    brand: brand,
                                    fg1: fg1, fg3: fg3,
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      )),

                      const SizedBox(height: 24),
                      Text(
                        'Made with care.  ·  No account required.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: fg3,
                          height: 1.4,
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Privacy dialog ─────────────────────────────────────────────────────────
  void _showPrivacyDialog(BuildContext context, bool isDark,
      Color fg1, Color fg3, Color brand) {
    final bg = isDark ? AppColors.darkBgSurface : AppColors.bgSurface;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.privacy_tip_outlined, color: brand, size: 20),
            const SizedBox(width: 10),
            Text(
              'Privacy Policy',
              style: GoogleFonts.inter(
                fontSize: 17, fontWeight: FontWeight.w700, color: fg1,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _privacySection(
                '🔒 Data stays on your device',
                'BMI Health stores all your data — weight entries, goals, and profile — '
                'locally on your device using SQLite. Nothing is sent to any server.',
                fg1, fg3,
              ),
              _privacySection(
                '📊 No analytics or tracking',
                'We do not use any analytics SDKs, crash reporters, or user-tracking tools. '
                'We have no idea who you are, and we prefer it that way.',
                fg1, fg3,
              ),
              _privacySection(
                '📢 Ads (free plan only)',
                'Free users see banner ads powered by Google AdMob. AdMob may use a '
                'device advertising ID for ad personalisation. Upgrade to Premium to '
                'remove all ads entirely.',
                fg1, fg3,
              ),
              _privacySection(
                '🗑 Deleting your data',
                'Uninstalling the app permanently deletes all your data from the device. '
                'There is no cloud backup unless you subscribe to Premium.',
                fg1, fg3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, color: brand,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _privacySection(
      String title, String body, Color fg1, Color fg3) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600, color: fg1)),
          const SizedBox(height: 4),
          Text(body,
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w400,
                  color: fg3, height: 1.5)),
        ],
      ),
    );
  }

}

enum _RowKind { toggle, meta, nav }

class _Row {
  final IconData icon;
  final String label;
  final _RowKind kind;
  final String? meta;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;

  const _Row({
    required this.icon,
    required this.label,
    required this.kind,
    this.meta,
    this.toggleValue,
    this.onToggle,
    this.onTap,
  });
}

class _Section {
  final String title;
  final List<_Row> rows;
  const _Section({required this.title, required this.rows});
}

class _SettingsRow extends StatelessWidget {
  final _Row row;
  final int index;
  final bool isDark;
  final Color bgTint;
  final Color brand;
  final Color fg1;
  final Color fg3;

  const _SettingsRow({
    required this.row,
    required this.index,
    required this.isDark,
    required this.bgTint,
    required this.brand,
    required this.fg1,
    required this.fg3,
  });

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColors.darkBorderFaint : AppColors.borderFaint;
    final canTap = row.onTap != null || row.kind == _RowKind.nav;

    return InkWell(
      onTap: row.onTap,
      borderRadius: BorderRadius.circular(0),
      splashColor: brand.withAlpha(20),
      highlightColor: brand.withAlpha(10),
      child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        border: index > 0
            ? Border(top: BorderSide(color: border, width: 1))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: bgTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(row.icon, size: 16, color: brand),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              row.label,
              style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.w500, color: fg1,
              ),
            ),
          ),
          if (row.kind == _RowKind.toggle)
            AppToggle(value: row.toggleValue ?? false, onChanged: row.onToggle),
          if (row.kind == _RowKind.meta && row.meta != null)
            Text(
              row.meta!,
              style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w500, color: fg3,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          if (row.kind == _RowKind.nav) ...[
            if (row.meta != null) ...[
              Text(row.meta!,
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500, color: fg3)),
              const SizedBox(width: 4),
            ],
            Icon(Icons.chevron_right_rounded, size: 18,
                color: canTap ? fg3 : fg3.withAlpha(80)),
          ],
        ],
      ),
      ),
    );
  }
}
