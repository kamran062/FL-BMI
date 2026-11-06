import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/features/fuel/barcode/food_product.dart';
import 'package:bmi_health/features/fuel/fuel_provider.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/widgets/app_button.dart';

/// Scan a packaged food, pick an amount, log it (ROADMAP 4.4).
class ScanFoodScreen extends StatefulWidget {
  final VoidCallback onClose;

  /// Opens the manual entry dialog (used when a product isn't found).
  final VoidCallback onManual;
  final FoodLookup? lookup;

  /// Tests pass false: there is no camera plugin in widget tests.
  final bool camera;

  const ScanFoodScreen({
    super.key,
    required this.onClose,
    required this.onManual,
    this.lookup,
    this.camera = true,
  });

  @override
  State<ScanFoodScreen> createState() => ScanFoodScreenState();
}

class ScanFoodScreenState extends State<ScanFoodScreen> {
  late final FoodLookup _lookup = widget.lookup ?? FoodLookup();
  final _controller = MobileScannerController(
    autoStart: false,
    formats: const [BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.upcA, BarcodeFormat.upcE],
  );
  final _grams = TextEditingController();

  bool _busy = false;
  LookupResult? _result;

  @override
  void initState() {
    super.initState();
    if (widget.camera) {
      // Camera permission prompt leaves the app; not an "app open".
      AdService.instance.beginExternalUi();
      _controller.start().whenComplete(AdService.instance.endExternalUi);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _grams.dispose();
    super.dispose();
  }

  /// Handles one scanned code (public for tests).
  Future<void> handleCode(String code) async {
    if (_busy || _result != null) return;
    setState(() => _busy = true);
    HapticFeedback.selectionClick();
    if (widget.camera) await _controller.stop();
    final r = await _lookup.lookup(code);
    if (!mounted) return;
    final p = r.product;
    if (p != null) _grams.text = (p.servingG ?? 100).round().toString();
    setState(() {
      _busy = false;
      _result = r;
    });
  }

  void _scanAgain() {
    setState(() => _result = null);
    if (widget.camera) _controller.start();
  }

  Future<void> _log(FoodProduct p) async {
    final grams = double.tryParse(_grams.text.trim());
    if (grams == null || grams <= 0 || grams > 3000) return;
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    await context.read<FuelProvider>().addFood(
          kcal: p.kcalFor(grams),
          name: p.name,
          proteinG: p.proteinFor(grams),
          carbsG: p.carbsFor(grams),
          fatG: p.fatFor(grams),
        );
    messenger.showSnackBar(SnackBar(content: Text(l.foodLogged(p.name))));
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final r = _result;
    return Scaffold(
      appBar: AppBar(leading: CloseButton(onPressed: widget.onClose), title: Text(l.scanBarcode)),
      body: Column(
        children: [
          Expanded(
            child: r == null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      if (widget.camera)
                        MobileScanner(
                          controller: _controller,
                          onDetect: (c) {
                            final code = c.barcodes.firstOrNull?.rawValue;
                            if (code != null) handleCode(code);
                          },
                        )
                      else
                        const ColoredBox(color: Colors.black),
                      // Aim box
                      Center(
                        child: Container(
                          width: 260,
                          height: 140,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 3),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      if (_busy)
                        Container(
                          color: Colors.black54,
                          alignment: Alignment.center,
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 12),
                            Text(l.lookingUp, style: const TextStyle(color: Colors.white)),
                          ]),
                        ),
                    ],
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: r.product != null ? _portion(l, r.product!) : _error(l, r.error!),
                  ),
          ),
          if (r == null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l.scanHint, textAlign: TextAlign.center),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(l.offAttribution, style: const TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _portion(AppLocalizations l, FoodProduct p) {
    final grams = double.tryParse(_grams.text.trim()) ?? 0;
    final protein = p.proteinFor(grams);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(p.name, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
        Text(l.per100g(p.kcalPer100g.round().toString())),
        const SizedBox(height: 16),
        Wrap(spacing: 8, children: [
          if (p.servingG != null)
            ActionChip(
              label: Text(l.oneServing(p.servingG!.round().toString())),
              onPressed: () => setState(() => _grams.text = p.servingG!.round().toString()),
            ),
          for (final g in const [50, 100, 200])
            ActionChip(
              label: Text('$g g'),
              onPressed: () => setState(() => _grams.text = '$g'),
            ),
        ]),
        const SizedBox(height: 8),
        TextField(
          controller: _grams,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
          decoration: InputDecoration(labelText: l.portionGrams),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Text(
          protein == null
              ? l.portionTotalKcal(p.kcalFor(grams))
              : l.portionTotal(p.kcalFor(grams), protein.toStringAsFixed(1)),
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        AppButton(
          label: l.logThis,
          icon: Icons.check_rounded,
          fullWidth: true,
          disabled: grams <= 0,
          onPressed: grams <= 0 ? null : () => _log(p),
        ),
        const SizedBox(height: 8),
        AppButton(
          label: l.scanAgain,
          variant: AppButtonVariant.secondary,
          fullWidth: true,
          onPressed: _scanAgain,
        ),
      ],
    );
  }

  Widget _error(AppLocalizations l, LookupError e) => Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 48),
          const SizedBox(height: 12),
          Text(
            switch (e) {
              LookupError.notFound => l.productNotFound,
              LookupError.noNutrition => l.productNoNutrition,
              LookupError.offline => l.lookupOffline,
            },
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: l.enterManually,
            icon: Icons.edit_rounded,
            fullWidth: true,
            onPressed: () {
              widget.onClose();
              widget.onManual();
            },
          ),
          const SizedBox(height: 8),
          AppButton(
            label: l.scanAgain,
            variant: AppButtonVariant.secondary,
            fullWidth: true,
            onPressed: _scanAgain,
          ),
        ],
      );
}
