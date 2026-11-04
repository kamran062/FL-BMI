import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:bmi_health/app/settings_provider.dart';
import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/core/monitoring/crash_reporting.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/features/backup/backup_service.dart';
import 'package:bmi_health/features/body/bmi/bmi_provider.dart';
import 'package:bmi_health/features/body/metrics/body_provider.dart';
import 'package:bmi_health/features/body/photos/photos_provider.dart';
import 'package:bmi_health/features/cycle/cycle_provider.dart';
import 'package:bmi_health/features/fuel/fuel_provider.dart';
import 'package:bmi_health/features/movement/movement_provider.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';
import 'package:bmi_health/l10n/l10n.dart';

/// Settings actions for ROADMAP 5.3.
abstract final class BackupActions {
  static Future<BackupService> _service(BuildContext context) async {
    final db = context.read<DatabaseHelper>();
    final vault = context.read<PhotosProvider>().vault;
    return BackupService(db, photos: await vault);
  }

  static Future<void> _share(List<File> files) async {
    // The share sheet leaves the app; not an "app open".
    AdService.instance.beginExternalUi();
    try {
      await Share.shareXFiles([for (final f in files) XFile(f.path)]);
    } finally {
      AdService.instance.endExternalUi();
    }
  }

  static Future<T?> _busy<T>(BuildContext context, Future<T> Function() work) async {
    final l = context.l10n;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 16),
          Text(l.working),
        ]),
      ),
    );
    try {
      return await work();
    } finally {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }

  static Future<void> create(BuildContext context) async {
    final opts = await showDialog<({String pass, BackupOptions options})>(
      context: context,
      builder: (_) => _PassphraseDialog(
        confirm: true,
        showCycle: context.read<CycleProvider>().enabled,
      ),
    );
    if (opts == null || !context.mounted) return;
    final service = await _service(context);
    if (!context.mounted) return;
    try {
      final file = await _busy(context, () async {
        final bytes = await service.create(opts.pass, opts.options);
        final d = DateTime.now();
        final name = 'bmi-health-backup-${d.year}-${d.month.toString().padLeft(2, '0')}-'
            '${d.day.toString().padLeft(2, '0')}.bmhbackup';
        return File('${(await getTemporaryDirectory()).path}/$name')..writeAsBytesSync(bytes);
      });
      if (file != null) await _share([file]);
    } catch (e, st) {
      reportError(e, st, reason: 'backup-create');
    }
  }

  static Future<void> restore(BuildContext context) async {
    final l = context.l10n;
    AdService.instance.beginExternalUi();
    FilePickerResult? picked;
    try {
      picked = await FilePicker.pickFiles(withData: true);
    } finally {
      AdService.instance.endExternalUi();
    }
    final bytes = picked?.files.single.bytes;
    if (bytes == null || !context.mounted) return;

    final opts = await showDialog<({String pass, BackupOptions options})>(
      context: context,
      builder: (_) => const _PassphraseDialog(confirm: false, showCycle: false),
    );
    if (opts == null || !context.mounted) return;
    final service = await _service(context);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _busy(context, () => service.restore(bytes, opts.pass));
      if (!context.mounted) return;
      await reloadAll(context);
      messenger.showSnackBar(SnackBar(content: Text(l.restoreDone)));
    } on RestoreException catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text(switch (e.error) {
          RestoreError.wrongPassphrase => l.restoreWrongPassphrase,
          RestoreError.notABackup => l.restoreNotBackup,
          RestoreError.newerVersion => l.restoreNewer,
        }),
      ));
    } catch (e, st) {
      reportError(e, st, reason: 'backup-restore');
      messenger.showSnackBar(SnackBar(content: Text(l.restoreNotBackup)));
    }
  }

  /// Re-reads every store after a restore.
  static Future<void> reloadAll(BuildContext context) async {
    await Future.wait([
      context.read<SettingsProvider>().load(),
      context.read<ProfileProvider>().load(),
      context.read<BmiProvider>().load(),
      context.read<BodyProvider>().load(),
      context.read<WorkoutProvider>().load(),
      context.read<FuelProvider>().load(),
      context.read<MovementProvider>().load(),
      context.read<CycleProvider>().load(),
      context.read<PhotosProvider>().load(),
    ]);
  }

  static Future<void> exportCsv(BuildContext context) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.exportCsv),
        content: Text(l.csvWarning),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: Text(MaterialLocalizations.of(d).cancelButtonLabel)),
          TextButton(onPressed: () => Navigator.pop(d, true), child: Text(l.continueLabel)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final csv = await CsvExport.build(context.read<DatabaseHelper>());
    final dir = await getTemporaryDirectory();
    final files = [
      for (final e in csv.entries) File('${dir.path}/${e.key}')..writeAsStringSync(e.value)
    ];
    await _share(files);
  }
}

class _PassphraseDialog extends StatefulWidget {
  final bool confirm;
  final bool showCycle;
  const _PassphraseDialog({required this.confirm, required this.showCycle});

  @override
  State<_PassphraseDialog> createState() => _PassphraseDialogState();
}

class _PassphraseDialogState extends State<_PassphraseDialog> {
  final _pass = TextEditingController();
  final _repeat = TextEditingController();
  bool _cycle = false;
  bool _photos = false;
  String? _error;

  @override
  void dispose() {
    _pass.dispose();
    _repeat.dispose();
    super.dispose();
  }

  void _submit() {
    final l = context.l10n;
    if (_pass.text.length < BackupService.minPassphrase) {
      setState(() => _error = l.passphraseTooShort(BackupService.minPassphrase));
      return;
    }
    if (widget.confirm && _pass.text != _repeat.text) {
      setState(() => _error = l.passphraseMismatch);
      return;
    }
    Navigator.pop(context, (
      pass: _pass.text,
      options: BackupOptions(includeCycle: _cycle, includePhotos: _photos),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(widget.confirm ? l.createBackup : l.restoreBackup),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(widget.confirm ? l.backupBody : l.restoreWarning),
          // Room for the field's floating label
          const SizedBox(height: 12),
          TextField(
            controller: _pass,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(labelText: l.passphrase, errorText: _error),
          ),
          if (widget.confirm) ...[
            TextField(
              controller: _repeat,
              obscureText: true,
              decoration: InputDecoration(labelText: l.passphraseRepeat),
            ),
            if (widget.showCycle)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _cycle,
                title: Text(l.includeCycle),
                onChanged: (v) => setState(() => _cycle = v ?? false),
              ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _photos,
              title: Text(l.includePhotos),
              onChanged: (v) => setState(() => _photos = v ?? false),
            ),
          ],
        ]),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel)),
        TextButton(onPressed: _submit, child: Text(l.continueLabel)),
      ],
    );
  }
}
