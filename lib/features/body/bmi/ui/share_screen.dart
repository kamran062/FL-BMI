import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/features/body/bmi/domain/bmi_calculator.dart';
import 'package:bmi_health/shared/widgets/app_button.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/text_tracking.dart';
import 'package:bmi_health/core/monitoring/crash_reporting.dart';

class ShareScreen extends StatefulWidget {
  final double bmi;
  final VoidCallback onClose;

  const ShareScreen({super.key, required this.bmi, required this.onClose});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final _screenshotCtrl = ScreenshotController();
  bool _saving = false;

  Future<void> _share() async {
    final l = context.l10n; // read before any await
    setState(() => _saving = true);
    try {
      final bytes = await _screenshotCtrl.capture(pixelRatio: 3);
      if (bytes == null) return;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/bmi_card.png');
      await file.writeAsBytes(bytes);
      // The share sheet leaves the app; don't treat coming back as an app open.
      AdService.instance.beginExternalUi();
      try {
        await Share.shareXFiles([XFile(file.path)],
            text: l.shareText(widget.bmi.toStringAsFixed(1)));
      } finally {
        AdService.instance.endExternalUi();
      }
    } catch (e, stack) {
      reportError(e, stack, reason: 'share');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.shareError)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cat = BmiCalculator.category(widget.bmi);

    return Scaffold(
      backgroundColor: const Color(0xFF0E1411),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 20, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      context.l10n.shareTitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 17, fontWeight: FontWeight.w600,
                        color: Colors.white, letterSpacing: -0.015 * 17,
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),

            // Card preview
            Expanded(
              child: Center(
                child: Screenshot(
                  controller: _screenshotCtrl,
                  child: _ShareCard(bmi: widget.bmi, cat: cat),
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: context.l10n.saveImage,
                      variant: AppButtonVariant.light,
                      icon: Icons.download_rounded,
                      fullWidth: true,
                      onPressed: _saving ? null : _share,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      label: _saving ? context.l10n.sharing : context.l10n.shareTitle,
                      variant: AppButtonVariant.primary,
                      icon: Icons.share_outlined,
                      fullWidth: true,
                      disabled: _saving,
                      onPressed: _saving ? null : _share,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  final double bmi;
  final BmiCategory cat;

  const _ShareCard({required this.bmi, required this.cat});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cat.color, const Color(0xFF0E1411)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 48,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wordmark
          Row(
            children: [
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.monitor_heart_outlined,
                  size: 14, color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.appTitle,
                style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: Colors.white, letterSpacing: -0.005 * 13,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Hero number
          Text(
            context.l10n.bmiCategory(cat.key).toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600,
              letterSpacing: tracking(context, 0.12 * 11),
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            bmi.toStringAsFixed(1),
            style: GoogleFonts.inter(
              fontSize: 96, fontWeight: FontWeight.w700,
              letterSpacing: -0.04 * 96,
              color: Colors.white,
              height: 0.95,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            'kg/m²  ·  ${context.l10n.shareCardToday}',
            style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
            ),
          ),

          const Spacer(),

          // Footer
          Text(
            cat.key == 'normal'
                ? context.l10n.shareCardHealthy
                : context.l10n.shareCardTracking,
            style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'bmihealth.app',
            style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
