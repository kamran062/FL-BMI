import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/features/body/metrics/body_provider.dart';
import 'package:bmi_health/features/body/photos/photos_provider.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/widgets/app_button.dart';
import 'package:bmi_health/shared/widgets/app_card.dart';
import 'package:bmi_health/shared/widgets/overline_label.dart';

/// Thumbnails, add and compare (ROADMAP 4.6).
class ProgressPhotosCard extends StatelessWidget {
  const ProgressPhotosCard({super.key});

  static Future<void> _add(BuildContext context) async {
    final l = context.l10n;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      useRootNavigator: true,
      builder: (sheet) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l.takePhoto),
            onTap: () => Navigator.pop(sheet, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l.chooseFromGallery),
            onTap: () => Navigator.pop(sheet, ImageSource.gallery),
          ),
        ]),
      ),
    );
    if (source == null || !context.mounted) return;
    final photos = context.read<PhotosProvider>();
    final weight = context.read<BodyProvider>().latestWeight?.weightKg;

    // Camera/gallery leave the app; not an "app open".
    AdService.instance.beginExternalUi();
    XFile? file;
    try {
      // Downscaled: plenty for comparing, small to encrypt and store.
      file = await ImagePicker().pickImage(
          source: source, maxWidth: 1440, maxHeight: 1440, imageQuality: 85);
    } finally {
      AdService.instance.endExternalUi();
    }
    if (file == null) return;
    await photos.add(await file.readAsBytes(), weightKg: weight);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final photos = context.watch<PhotosProvider>().photos;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;

    return AppCard(
      padding: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.photo_outlined, size: 20),
            const SizedBox(width: 6),
            OverlineLabel(l.progressPhotos),
          ]),
          const SizedBox(height: 4),
          Text(l.progressPhotosBody, style: GoogleFonts.inter(fontSize: 13, color: fg3)),
          if (photos.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final p in photos.reversed)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: _Thumb(photo: p, onTap: () => _open(context, [p])),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: AppButton(
                label: l.addPhoto,
                icon: Icons.add_a_photo_outlined,
                variant: AppButtonVariant.secondary,
                fullWidth: true,
                onPressed: () => _add(context),
              ),
            ),
            if (photos.length >= 2) ...[
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: l.comparePhotos,
                  icon: Icons.compare_rounded,
                  variant: AppButtonVariant.secondary,
                  fullWidth: true,
                  onPressed: () => _open(context, [photos.first, photos.last]),
                ),
              ),
            ],
          ]),
        ],
      ),
    );
  }

  static void _open(BuildContext context, List<ProgressPhoto> shown) {
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
      builder: (_) => _PhotoViewer(photos: shown),
    ));
  }
}

/// Pick any two photos to compare; returns them oldest first.
class _ComparePicker extends StatefulWidget {
  final List<ProgressPhoto> initial;
  const _ComparePicker({required this.initial});

  @override
  State<_ComparePicker> createState() => _ComparePickerState();
}

class _ComparePickerState extends State<_ComparePicker> {
  late final List<ProgressPhoto> _selected = [...widget.initial];

  void _toggle(ProgressPhoto p) => setState(() {
        final i = _selected.indexWhere((s) => s.id == p.id);
        if (i >= 0) {
          _selected.removeAt(i);
        } else {
          // A third pick replaces the one chosen first.
          if (_selected.length == 2) _selected.removeAt(0);
          _selected.add(p);
        }
      });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final photos = context.watch<PhotosProvider>().photos;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final ids = _selected.map((p) => p.id).toSet();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.bodyChoosePhotos,
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(l.bodyChoosePhotosHint,
                style: GoogleFonts.inter(fontSize: 13, color: fg3)),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.5),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in photos)
                      Stack(children: [
                        _Thumb(
                          key: ValueKey('pick-${p.id}'),
                          photo: p,
                          onTap: () => _toggle(p),
                        ),
                        if (ids.contains(p.id))
                          PositionedDirectional(
                            top: 4,
                            end: 4,
                            child: CircleAvatar(
                              radius: 11,
                              backgroundColor: brand,
                              child: const Icon(Icons.check_rounded,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                      ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            AppButton(
              label: l.bodyCompareThese,
              icon: Icons.compare_rounded,
              fullWidth: true,
              onPressed: _selected.length == 2
                  ? () => Navigator.pop(context,
                      [..._selected]..sort((a, b) => a.date.compareTo(b.date)))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final ProgressPhoto photo;
  final VoidCallback onTap;
  const _Thumb({super.key, required this.photo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(width: 72, height: 88, child: _DecryptedImage(photo: photo)),
        ),
        const SizedBox(height: 4),
        Text(DateFormat.MMMd(l.localeName).format(photo.date),
            style: const TextStyle(fontSize: 11)),
      ]),
    );
  }
}

class _DecryptedImage extends StatefulWidget {
  final ProgressPhoto photo;
  final BoxFit fit;
  const _DecryptedImage({required this.photo, this.fit = BoxFit.cover});

  @override
  State<_DecryptedImage> createState() => _DecryptedImageState();
}

class _DecryptedImageState extends State<_DecryptedImage> {
  // Created once per photo: a new future on every build would make
  // FutureBuilder rebuild in an endless loop.
  late Future<Uint8List?> _image = context.read<PhotosProvider>().image(widget.photo);

  @override
  void didUpdateWidget(_DecryptedImage old) {
    super.didUpdateWidget(old);
    if (old.photo.file != widget.photo.file) {
      _image = context.read<PhotosProvider>().image(widget.photo);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: _image,
        builder: (_, snap) => snap.data == null
            ? const ColoredBox(color: Colors.black12)
            : Image.memory(snap.data!, fit: widget.fit, gaplessPlayback: true),
      );
}

/// One photo full screen, or two side by side for comparison (first vs
/// latest by default; "Choose photos" picks any two).
class _PhotoViewer extends StatefulWidget {
  final List<ProgressPhoto> photos;
  const _PhotoViewer({required this.photos});

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late List<ProgressPhoto> photos = widget.photos;

  Future<void> _choose() async {
    final picked = await showModalBottomSheet<List<ProgressPhoto>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ComparePicker(initial: photos),
    );
    if (picked != null && picked.length == 2) setState(() => photos = picked);
  }

  Future<void> _delete(BuildContext context, ProgressPhoto p) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.deletePhoto),
        content: Text(l.deletePhotoConfirm),
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
    if (ok != true || !context.mounted) return;
    final provider = context.read<PhotosProvider>();
    Navigator.pop(context);
    await provider.delete(p);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = DateFormat.yMMMd(l.localeName);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (photos.length == 1)
            IconButton(
              tooltip: l.deletePhoto,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _delete(context, photos.single),
            )
          else
            IconButton(
              tooltip: l.bodyChoosePhotos,
              icon: const Icon(Icons.photo_library_outlined),
              onPressed: _choose,
            ),
        ],
      ),
      body: Row(
        children: [
          for (final p in photos)
            Expanded(
              child: Column(children: [
                Expanded(child: _DecryptedImage(photo: p, fit: BoxFit.contain)),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    [
                      fmt.format(p.date),
                      if (p.weightKg != null) '${p.weightKg!.toStringAsFixed(1)} kg',
                    ].join(' · '),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ]),
            ),
        ],
      ),
    );
  }
}
