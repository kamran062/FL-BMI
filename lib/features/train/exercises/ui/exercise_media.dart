import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:bmi_health/features/train/exercises/data/video_cache.dart';
import 'package:bmi_health/features/train/exercises/demo/exercise_demo.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';

/// What the user watches for an exercise: the filmed clip for the chosen
/// trainer when one exists, otherwise the animated guide (also shown while
/// the clip loads, or if it can't play).
///
/// Clip sources in the catalog: `asset:assets/videos/x.mp4` (bundled in the
/// app) or an https URL (free hosting; kept on the device after first play).
class ExerciseMedia extends StatefulWidget {
  final Exercise exercise;
  final Sex demonstrator;

  /// Show "Animated guide · video coming soon" under the animation.
  final bool caption;

  const ExerciseMedia({super.key, required this.exercise, required this.demonstrator, this.caption = true});

  @override
  State<ExerciseMedia> createState() => _ExerciseMediaState();
}

class _ExerciseMediaState extends State<ExerciseMedia> {
  VideoPlayerController? _controller;
  bool _ready = false;

  String? get _url => widget.exercise.videoFor(widget.demonstrator);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(ExerciseMedia old) {
    super.didUpdateWidget(old);
    if (old.exercise.id != widget.exercise.id || old.demonstrator != widget.demonstrator) {
      _controller?.dispose();
      _controller = null;
      _ready = false;
      _load();
    }
  }

  Future<void> _load() async {
    final url = _url;
    if (url == null) return;
    final VideoPlayerController c;
    if (url.startsWith('asset:')) {
      c = VideoPlayerController.asset(url.substring('asset:'.length));
    } else {
      final saved = await VideoCache.instance.cached(url);
      if (!mounted || _url != url) return;
      if (saved == null) VideoCache.instance.download(url);
      c = saved != null ? VideoPlayerController.file(saved) : VideoPlayerController.networkUrl(Uri.parse(url));
    }
    _controller = c;
    try {
      await c.initialize();
      if (!mounted || _controller != c) return;
      await c.setLooping(true);
      await c.setVolume(0);
      await c.play();
      setState(() => _ready = true);
    } catch (_) {
      // Keep showing the animation
      if (mounted && _controller == c) setState(() => _ready = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c != null && _ready && c.value.isInitialized) {
      return FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(width: c.value.size.width, height: c.value.size.height, child: VideoPlayer(c)),
      );
    }
    final demo = ExerciseDemo(exercise: widget.exercise, female: widget.demonstrator == Sex.female);
    if (!widget.caption) return demo;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(children: [
        Expanded(child: demo),
        Text(context.l10n.demoCaption,
            style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkFg3 : AppColors.fg3)),
      ]),
    );
  }
}
