import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/features/coach/ai_client.dart';
import 'package:bmi_health/features/coach/coach_screen.dart' show ensureAiConsent;
import 'package:bmi_health/features/fuel/fuel_provider.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/widgets/app_button.dart';

/// Takes a meal photo, asks for an AI estimate, lets the user pick which
/// items to log (ROADMAP 4.4). Always labelled as an estimate.
Future<void> startPhotoEstimate(BuildContext context) async {
  if (!await ensureAiConsent(context) || !context.mounted) return;
  AdService.instance.beginExternalUi();
  XFile? file;
  try {
    // Small JPEG: enough to recognise food, cheap to send.
    file = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
  } finally {
    AdService.instance.endExternalUi();
  }
  if (file == null || !context.mounted) return;
  final bytes = await file.readAsBytes();
  if (!context.mounted) return;
  final nav = Navigator.of(context, rootNavigator: true);
  nav.push(MaterialPageRoute<void>(
    builder: (_) => PhotoEstimateScreen(
        estimate: context.read<AiClient>().estimate(bytes), onClose: nav.pop),
  ));
}

class PhotoEstimateScreen extends StatefulWidget {
  final Future<FoodEstimate> estimate;
  final VoidCallback onClose;
  const PhotoEstimateScreen({super.key, required this.estimate, required this.onClose});

  @override
  State<PhotoEstimateScreen> createState() => _PhotoEstimateScreenState();
}

class _PhotoEstimateScreenState extends State<PhotoEstimateScreen> {
  FoodEstimate? _result;
  String? _error;
  final _selected = <int>{};

  @override
  void initState() {
    super.initState();
    widget.estimate.then((r) {
      if (!mounted) return;
      setState(() {
        _result = r;
        _selected.addAll(List.generate(r.items.length, (i) => i));
      });
    }, onError: (Object e) {
      if (!mounted) return;
      final l = context.l10n;
      setState(() => _error = e is AiLimitReached ? l.aiLimit : l.aiUnavailable);
    });
  }

  Future<void> _log() async {
    final l = context.l10n;
    final fuel = context.read<FuelProvider>();
    for (final i in _selected) {
      final item = _result!.items[i];
      await fuel.addFood(
          kcal: item.kcal, name: '${item.name} ${l.estimateSuffix}', proteinG: item.proteinG);
    }
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final r = _result;
    final total = r == null
        ? 0
        : _selected.fold<int>(0, (s, i) => s + r.items[i].kcal);
    return Scaffold(
      appBar: AppBar(leading: CloseButton(onPressed: widget.onClose), title: Text(l.photoEstimate)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _error != null
            ? Center(child: Text(_error!, textAlign: TextAlign.center))
            : r == null
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(l.photoEstimating),
                    ]),
                  )
                : !r.isFood || r.items.isEmpty
                    ? Center(child: Text(l.photoNotFood, textAlign: TextAlign.center))
                    : ListView(children: [
                        Text(l.photoEstimateNote,
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.bmiOver)),
                        if (r.confidence == 'low')
                          Text(l.photoConfidenceLow,
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        for (final (i, item) in r.items.indexed)
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _selected.contains(i),
                            onChanged: (v) => setState(
                                () => v == true ? _selected.add(i) : _selected.remove(i)),
                            title: Text(item.name),
                            subtitle: Text(
                                '${item.grams} g · ${l.portionTotal(item.kcal, item.proteinG.toStringAsFixed(1))}'),
                          ),
                        const SizedBox(height: 8),
                        Text(l.photoTotal(total),
                            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        AppButton(
                          label: l.logSelected,
                          icon: Icons.check_rounded,
                          fullWidth: true,
                          disabled: _selected.isEmpty,
                          onPressed: _selected.isEmpty ? null : _log,
                        ),
                      ]),
      ),
    );
  }
}
