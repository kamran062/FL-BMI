import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/core/monitoring/crash_reporting.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/features/train/rep_counter/rep_logic.dart' as rc;
import 'package:bmi_health/features/train/rep_counter/yuv.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';

/// Camera rep counter (ROADMAP 3.4). Frames are analysed on the device by
/// ML Kit pose detection and immediately discarded — nothing is recorded,
/// saved or uploaded.
class RepCounterScreen extends StatefulWidget {
  final VoidCallback onClose;
  const RepCounterScreen({super.key, required this.onClose});

  @override
  State<RepCounterScreen> createState() => _RepCounterScreenState();
}

class _RepCounterScreenState extends State<RepCounterScreen>
    with WidgetsBindingObserver {
  CameraController? _camera;
  CameraDescription? _description;
  final _detector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.stream));
  rc.CountedExercise _exercise = rc.CountedExercise.squat;
  late rc.RepCounter _counter = rc.RepCounter(_exercise);
  bool _busy = false;
  bool _frameErrorReported = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start after the first frame: _start reads localisations from context,
    // which is not allowed during initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _start();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stop();
    _detector.close();
    super.dispose();
  }

  // Release the camera while the app is in the background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _stop();
    } else if (state == AppLifecycleState.resumed && _camera == null) {
      _start();
    }
  }

  Future<void> _start() async {
    final l = context.l10n;
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) {
        setState(() => _error = l.cameraUnavailable);
        return;
      }
      // Front camera, so users can see themselves while training.
      _description = cams.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => cams.first);
      final controller = CameraController(
        _description!,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup:
            Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      );
      // The permission prompt leaves the app; it is not an "app open".
      AdService.instance.beginExternalUi();
      try {
        await controller.initialize();
      } finally {
        AdService.instance.endExternalUi();
      }
      if (!mounted) {
        await controller.dispose();
        return;
      }
      // Show the preview first; on CameraX startImageStream may not return
      // until the stream stops, so it must not gate the UI.
      setState(() {
        _camera = controller;
        _error = null;
      });
      await controller.startImageStream(_onFrame);
    } on CameraException catch (e) {
      if (mounted) {
        setState(() => _error = e.code.contains('Access')
            ? l.cameraDenied
            : l.cameraUnavailable);
      }
    } catch (e, st) {
      reportError(e, st, reason: 'rep-counter-camera');
      if (mounted) setState(() => _error = l.cameraUnavailable);
    }
  }

  Future<void> _stop() async {
    final c = _camera;
    _camera = null;
    if (c == null) return;
    try {
      if (c.value.isStreamingImages) await c.stopImageStream();
    } catch (_) {}
    await c.dispose();
  }

  Future<void> _onFrame(CameraImage image) async {
    // Drop frames while the previous one is still being analysed.
    if (_busy) return;
    _busy = true;
    try {
      final input = _toInputImage(image);
      if (input == null) return;
      final poses = await _detector.processImage(input);
      if (!mounted) return;
      final pose = poses.isEmpty ? <rc.Joint, rc.JointPoint>{} : _convert(poses.first);
      final counted = _counter.update(pose);
      if (counted) HapticFeedback.mediumImpact();
      setState(() {});
    } catch (e, st) {
      // Report once per session; this runs for every camera frame.
      if (!_frameErrorReported) {
        _frameErrorReported = true;
        reportError(e, st, reason: 'rep-counter-frame');
      }
    } finally {
      _busy = false;
    }
  }

  InputImage? _toInputImage(CameraImage image) {
    final d = _description;
    if (d == null || image.planes.isEmpty) return null;
    final rotation = InputImageRotationValue.fromRawValue(d.sensorOrientation) ??
        InputImageRotation.rotation0deg;
    final size = Size(image.width.toDouble(), image.height.toDouble());

    // Android: CameraX delivers 3-plane YUV_420_888 even when NV21 is
    // requested; ML Kit only accepts NV21 there, so convert.
    if (Platform.isAndroid && image.planes.length == 3) {
      return InputImage.fromBytes(
        bytes: yuv420ToNv21(image.width, image.height, [
          for (final p in image.planes)
            (bytes: p.bytes, bytesPerRow: p.bytesPerRow, bytesPerPixel: p.bytesPerPixel)
        ]),
        metadata: InputImageMetadata(
          size: size,
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.width,
        ),
      );
    }

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: size,
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  static const _map = {
    rc.Joint.leftShoulder: PoseLandmarkType.leftShoulder,
    rc.Joint.rightShoulder: PoseLandmarkType.rightShoulder,
    rc.Joint.leftElbow: PoseLandmarkType.leftElbow,
    rc.Joint.rightElbow: PoseLandmarkType.rightElbow,
    rc.Joint.leftWrist: PoseLandmarkType.leftWrist,
    rc.Joint.rightWrist: PoseLandmarkType.rightWrist,
    rc.Joint.leftHip: PoseLandmarkType.leftHip,
    rc.Joint.rightHip: PoseLandmarkType.rightHip,
    rc.Joint.leftKnee: PoseLandmarkType.leftKnee,
    rc.Joint.rightKnee: PoseLandmarkType.rightKnee,
    rc.Joint.leftAnkle: PoseLandmarkType.leftAnkle,
    rc.Joint.rightAnkle: PoseLandmarkType.rightAnkle,
  };

  static rc.Pose _convert(Pose p) => {
        for (final e in _map.entries)
          if (p.landmarks[e.value] case final lm?)
            e.key: (x: lm.x, y: lm.y, likelihood: lm.likelihood),
      };

  void _choose(rc.CountedExercise e) => setState(() {
        _exercise = e;
        _counter = rc.RepCounter(e);
      });

  Future<void> _logSet() async {
    final l = context.l10n;
    final reps = _counter.reps;
    if (reps == 0) return;
    final workouts = context.read<WorkoutProvider>();
    if (workouts.active == null) await workouts.start(name: l.repCounter);
    final id = rc.catalogIdFor(_exercise);
    if (!workouts.activeExercises.contains(id)) {
      await workouts.addExercise(id);
    } else {
      await workouts.addSet(id);
    }
    // Fill the newest unticked set of this exercise with the counted reps.
    final target = workouts.setsFor(id).lastWhere((s) => !s.done,
        orElse: () => workouts.setsFor(id).last);
    await workouts.updateSet(target.copyWith(reps: reps, done: true));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.setLogged(reps))));
    setState(_counter.reset);
  }

  String _cueText(AppLocalizations l, rc.FormCue c) => switch (c) {
        rc.FormCue.goLower => l.cueGoLower,
        rc.FormCue.keepHipsUp => l.cueKeepHipsUp,
        rc.FormCue.fullExtension => l.cueFullExtension,
        rc.FormCue.stepIntoFrame => l.cueStepIntoFrame,
      };

  String _name(AppLocalizations l, rc.CountedExercise e) => switch (e) {
        rc.CountedExercise.squat => l.countSquat,
        rc.CountedExercise.pushUp => l.countPushUp,
        rc.CountedExercise.curl => l.countCurl,
        rc.CountedExercise.shoulderPress => l.countShoulderPress,
        rc.CountedExercise.lunge => l.countLunge,
      };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = _camera;
    final cue = _counter.cue;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: CloseButton(onPressed: widget.onClose),
        title: Text(l.repCounter),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                for (final e in rc.CountedExercise.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(_name(l, e)),
                      selected: _exercise == e,
                      onSelected: (_) => _choose(e),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (c != null && c.value.isInitialized)
                  Center(child: CameraPreview(c))
                else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _error == null
                          ? const CircularProgressIndicator()
                          : Text(_error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                // Rep count
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      '${_counter.reps}',
                      style: GoogleFonts.inter(
                        fontSize: 96,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: const [Shadow(blurRadius: 12)],
                      ),
                    ),
                  ),
                ),
                if (cue != null)
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cue == rc.FormCue.stepIntoFrame
                            ? Colors.black54
                            : AppColors.bmiOver,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(_cueText(l, cue),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Column(
                children: [
                  Text(
                    _counter.reps == 0 ? l.repCounterIntro : l.repsCounted(_counter.reps),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54)),
                          onPressed: () => setState(_counter.reset),
                          child: Text(l.resetCount),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          // Disabled state must stay visible on black
                          style: FilledButton.styleFrom(
                            disabledBackgroundColor: Colors.white24,
                            disabledForegroundColor: Colors.white60,
                          ),
                          onPressed: _counter.reps > 0 ? _logSet : null,
                          child: Text(l.logSet),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(l.repCounterPrivacy,
                      style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @visibleForTesting
  rc.RepCounter get counter => _counter;
}
