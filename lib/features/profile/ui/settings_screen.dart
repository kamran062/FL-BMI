import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/app/settings_provider.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/widgets/app_card.dart';
import 'package:bmi_health/shared/widgets/app_toggle.dart';
import 'package:bmi_health/shared/widgets/overline_label.dart';
import 'package:bmi_health/shared/widgets/screen_header.dart';
import 'package:bmi_health/core/notifications/reminder_service.dart';
import 'package:bmi_health/features/premium/purchase_service.dart';
import 'package:bmi_health/features/cycle/cycle_provider.dart';
import 'package:bmi_health/features/backup/backup_ui.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenPremium;
  const SettingsScreen(
      {super.key, required this.onOpenProfile, required this.onOpenPremium});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCanvas = isDark ? AppColors.darkBgCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final bgTint = isDark ? AppColors.darkBgTint : AppColors.bgTint;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;

    return ValueListenableBuilder<bool>(
      valueListenable: AdService.instance.privacyOptionsRequired,
      builder: (context, showAdPrivacy, _) => Consumer2<SettingsProvider, ProfileProvider>(
      builder: (context, provider, profileProvider, _) {
        final l = context.l10n;
        final name = profileProvider.profile.name;
        final purchases = context.watch<PurchaseService>();
        final cycle = context.watch<CycleProvider>();
        final sections = [
          // Hidden until premium is configured for this build
          if (purchases.configured)
            _Section(
              title: l.premiumBadge,
              rows: [
                _Row(
                  icon: Icons.auto_awesome_rounded,
                  label: purchases.isPremium ? l.premiumActive : l.goPremium,
                  kind: _RowKind.nav,
                  onTap: onOpenPremium,
                ),
              ],
            ),
          _Section(
            title: l.sectionProfile,
            rows: [
              _Row(
                icon: Icons.person_outline_rounded,
                label: l.personalDetails,
                kind: _RowKind.nav,
                meta: name.isEmpty ? l.notSet : name,
                onTap: onOpenProfile,
              ),
            ],
          ),
          _Section(
            title: l.sectionAppearance,
            rows: [
              _Row(
                icon: Icons.dark_mode_outlined,
                label: l.darkMode,
                kind: _RowKind.toggle,
                toggleValue: provider.isDark,
                onToggle: (v) => provider.setTheme(
                    v ? ThemeMode.dark : ThemeMode.light),
              ),
            ],
          ),
          // Hidden in release builds until Urdu is fully translated
          if (urduEnabled)
            _Section(
              title: l.sectionLanguage,
              rows: [
                _Row(
                  icon: Icons.translate_rounded,
                  label: l.appLanguage,
                  kind: _RowKind.nav,
                  meta: _languageName(l, provider.language),
                  onTap: () => _showLanguagePicker(context, provider),
                ),
              ],
            ),
          _Section(
            title: l.sectionUnits,
            rows: [
              _Row(
                icon: Icons.straighten_rounded,
                label: l.fieldHeight,
                kind: _RowKind.meta,
                meta: profileProvider.profile.heightUnit == 'cm' ? 'cm' : 'ft / in',
              ),
              _Row(
                icon: Icons.monitor_weight_outlined,
                label: l.fieldWeight,
                kind: _RowKind.meta,
                meta: profileProvider.profile.weightUnit == 'kg' ? 'kg' : 'lbs',
              ),
            ],
          ),
          // Cycle tracking: offered by profile, opt-in, separate lock & delete
          if (profileProvider.profile.cycleTrackingOffered)
            _Section(
              title: l.cycleTitle,
              rows: [
                _Row(
                  icon: Icons.water_drop_outlined,
                  label: l.cycleTracking,
                  kind: _RowKind.toggle,
                  toggleValue: cycle.enabled,
                  onToggle: (v) => v ? _enableCycle(context, cycle) : cycle.setEnabled(false),
                ),
                if (cycle.enabled) ...[
                  _Row(
                    icon: Icons.fingerprint_rounded,
                    label: l.cycleLock,
                    kind: _RowKind.toggle,
                    toggleValue: cycle.lockEnabled,
                    onToggle: (v) => cycle.setLock(v, l.cycleUnlockReason),
                  ),
                  _Row(
                    icon: Icons.delete_outline_rounded,
                    label: l.cycleDeleteAll,
                    kind: _RowKind.nav,
                    onTap: () => _deleteCycle(context, cycle),
                  ),
                ],
              ],
            ),
          _Section(
            title: l.sectionBackup,
            rows: [
              _Row(
                icon: Icons.lock_outline_rounded,
                label: l.createBackup,
                kind: _RowKind.nav,
                onTap: () => BackupActions.create(context),
              ),
              _Row(
                icon: Icons.restore_rounded,
                label: l.restoreBackup,
                kind: _RowKind.nav,
                onTap: () => BackupActions.restore(context),
              ),
              _Row(
                icon: Icons.table_chart_outlined,
                label: l.exportCsv,
                kind: _RowKind.nav,
                onTap: () => BackupActions.exportCsv(context),
              ),
            ],
          ),
          _Section(
            title: l.sectionNotifications,
            rows: [
              _Row(
                icon: Icons.notifications_outlined,
                label: l.dailyReminders,
                kind: _RowKind.toggle,
                toggleValue: provider.dailyReminder,
                onToggle: (v) => _setReminder(context, v, provider.setDailyReminder),
              ),
              _Row(
                icon: Icons.calendar_today_outlined,
                label: l.weeklyCheckIn,
                kind: _RowKind.toggle,
                toggleValue: provider.weeklyCheckIn,
                onToggle: (v) => _setReminder(context, v, provider.setWeeklyCheckIn),
              ),
            ],
          ),
          _Section(
            title: l.sectionAbout,
            rows: [
              _Row(
                icon: Icons.privacy_tip_outlined,
                label: l.privacy,
                kind: _RowKind.nav,
                meta: l.onDevice,
                onTap: () => _showPrivacyDialog(context, isDark, fg1, fg3, brand),
              ),
              // Required by Google's consent policy in regions like the EEA/UK
              if (showAdPrivacy)
                _Row(
                  icon: Icons.ads_click_rounded,
                  label: l.adPrivacyChoices,
                  kind: _RowKind.nav,
                  onTap: AdService.instance.showPrivacyOptions,
                ),
              _Row(
                icon: Icons.info_outline_rounded,
                label: l.version,
                kind: _RowKind.meta,
                meta: provider.appVersion,
              ),
            ],
          ),
        ];

        return Scaffold(
          backgroundColor: bgCanvas,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ScreenHeader(title: l.settingsTitle, large: true),
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
                        l.settingsFooter,
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
      ),
    );
  }

  // ── Reminders ──────────────────────────────────────────────────────────────
  /// Turning a reminder on asks for notification permission first; if the
  /// user declines, the toggle stays off and we explain why. The shell
  /// re-schedules reminders whenever these settings change.
  /// Explains what is stored before turning cycle tracking on.
  static Future<void> _enableCycle(BuildContext context, CycleProvider c) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.cycleTracking),
        content: Text(l.cycleOptInBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: Text(MaterialLocalizations.of(d).cancelButtonLabel)),
          TextButton(
              onPressed: () => Navigator.pop(d, true),
              child: Text(MaterialLocalizations.of(d).okButtonLabel)),
        ],
      ),
    );
    if (ok == true) await c.setEnabled(true);
  }

  static Future<void> _deleteCycle(BuildContext context, CycleProvider c) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.cycleDeleteAll),
        content: Text(l.cycleDeleteConfirm),
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
    if (ok == true) await c.deleteAll();
  }

  static Future<void> _setReminder(BuildContext context, bool on,
      Future<void> Function(bool) save) async {
    if (on && !await ReminderService.instance.requestPermission()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.notificationsDenied)));
      }
      return;
    }
    await save(on);
  }

  // ── Language ───────────────────────────────────────────────────────────────
  static String _languageName(AppLocalizations l, String code) => switch (code) {
        'en' => l.languageEnglish,
        'ur' => l.languageUrdu,
        _ => l.languageSystem,
      };

  void _showLanguagePicker(BuildContext context, SettingsProvider provider) {
    final l = context.l10n;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l.appLanguage),
        children: [
          // SimpleDialog sizes to its children's intrinsic width, which is
          // tiny for ListTiles — give the options a comfortable fixed width.
          SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final code in const ['system', 'en', 'ur'])
                  ListTile(
                    leading: Icon(provider.language == code
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded),
                    title: Text(_languageName(l, code)),
                    onTap: () {
                      provider.setLanguage(code);
                      Navigator.pop(dialogContext);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
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
              context.l10n.privacyPolicy,
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
                context.l10n.privacyDataTitle,
                context.l10n.privacyDataBody,
                fg1, fg3,
              ),
              _privacySection(
                context.l10n.privacyAnalyticsTitle,
                context.l10n.privacyAnalyticsBody,
                fg1, fg3,
              ),
              _privacySection(
                context.l10n.privacyAdsTitle,
                context.l10n.privacyAdsBody,
                fg1, fg3,
              ),
              _privacySection(
                context.l10n.privacyThirdPartyTitle,
                context.l10n.privacyThirdPartyBody,
                fg1, fg3,
              ),
              _privacySection(
                context.l10n.privacyDeleteTitle,
                context.l10n.privacyDeleteBody,
                fg1, fg3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.l10n.gotIt,
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
