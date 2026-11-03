import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/widgets/app_card.dart';
import 'package:bmi_health/shared/widgets/overline_label.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onClose;

  const ExerciseDetailScreen(
      {super.key, required this.exercise, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final locale = l.localeName;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg2 = isDark ? AppColors.darkFg2 : AppColors.fg2;
    final demonstrator = context.watch<ProfileProvider>().profile.demonstrator;
    final steps = exercise.stepsIn(locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.nameIn(locale)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded), onPressed: onClose),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          _ExerciseVideo(
            url: exercise.videoFor(demonstrator),
            demonstrator: demonstrator,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(l.exerciseEquipment(exercise.equipment))),
              Chip(label: Text(l.difficulty(exercise.difficulty))),
            ],
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OverlineLabel(l.targetMuscles),
                const SizedBox(height: 8),
                Text(l.muscle(exercise.primary),
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w700, color: brand)),
                if (exercise.secondary.isNotEmpty)
                  Text(exercise.secondary.map(l.muscle).join(' · '),
                      style: GoogleFonts.inter(fontSize: 14, color: fg2)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OverlineLabel(l.howTo),
                const SizedBox(height: 8),
                for (var i = 0; i < steps.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: brand.withAlpha(30),
                          child: Text('${i + 1}',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: brand)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(steps[i],
                              style: GoogleFonts.inter(
                                  fontSize: 15, height: 1.45, color: fg1)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(l.wellnessDisclaimer,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: fg2)),
        ],
      ),
    );
  }
}

/// Looping, muted demonstrator clip. Shows a placeholder until the clip for
/// this exercise has been filmed (ROADMAP §4).
class _ExerciseVideo extends StatefulWidget {
  final String? url;
  final Sex demonstrator;

  const _ExerciseVideo({required this.url, required this.demonstrator});

  @override
  State<_ExerciseVideo> createState() => _ExerciseVideoState();
}

class _ExerciseVideoState extends State<_ExerciseVideo> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    final url = widget.url;
    if (url == null) return;
    final c = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller = c;
    c.initialize().then((_) {
      if (!mounted) return;
      c
        ..setLooping(true)
        ..setVolume(0)
        ..play();
      setState(() {});
    }).catchError((Object _) {
      if (mounted) setState(() => _failed = true);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sunken = isDark ? AppColors.darkBgSunken : AppColors.bgSunken;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final c = _controller;
    final trainer = widget.demonstrator == Sex.male
        ? l.demonstratorMale
        : l.demonstratorFemale;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: c != null && c.value.isInitialized && !_failed
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: c.value.size.width,
                  height: c.value.size.height,
                  child: VideoPlayer(c),
                ),
              )
            : Container(
                color: sunken,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        widget.url == null || _failed
                            ? Icons.videocam_outlined
                            : Icons.hourglass_empty_rounded,
                        size: 40,
                        color: fg3),
                    const SizedBox(height: 8),
                    if (widget.url == null || _failed)
                      Text(l.videoComingSoon,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600, color: fg3)),
                    Text(l.videoWithTrainer(trainer.toLowerCase()),
                        style: GoogleFonts.inter(fontSize: 13, color: fg3)),
                  ],
                ),
              ),
      ),
    );
  }
}
