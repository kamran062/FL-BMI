import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/bmi_calculator.dart';
import '../widgets/app_button.dart';

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
    setState(() => _saving = true);
    try {
      final bytes = await _screenshotCtrl.capture(pixelRatio: 3);
      if (bytes == null) return;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/bmi_card.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)],
          text: 'My BMI is ${widget.bmi.toStringAsFixed(1)} — tracked with BMI Health');
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
                      'Share',
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
                      label: 'Save image',
                      variant: AppButtonVariant.light,
                      icon: Icons.download_rounded,
                      fullWidth: true,
                      onPressed: _saving ? null : _share,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      label: _saving ? 'Sharing…' : 'Share',
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
                'BMI Health',
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
            cat.label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600,
              letterSpacing: 0.12 * 11,
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
            'kg/m²  ·  today',
            style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
            ),
          ),

          const Spacer(),

          // Footer
          Text(
            cat.key == 'normal'
                ? 'Within the healthy range — keeping it up.'
                : 'Tracking my body, one week at a time.',
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
