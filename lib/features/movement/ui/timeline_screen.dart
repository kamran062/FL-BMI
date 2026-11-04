import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/features/movement/domain/timeline.dart';
import 'package:bmi_health/features/movement/movement_provider.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/widgets/app_button.dart';
import 'package:bmi_health/shared/widgets/app_card.dart';

String formatDuration(AppLocalizations l, Duration d) => d.inHours > 0
    ? l.durationHm(d.inHours, d.inMinutes.remainder(60))
    : l.minutesShort(d.inMinutes);

/// Turns tracking on and reports problems the user can fix.
Future<void> startTracking(BuildContext context) async {
  final l = context.l10n;
  final result = await context.read<MovementProvider>().enable(l);
  if (!context.mounted) return;
  final message = switch (result) {
    TrackingStart.denied => l.locationDenied,
    TrackingStart.serviceOff => l.locationServiceOff,
    _ => null,
  };
  if (message != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Daily movement timeline: map, places, trips, tracking switch.
class TimelineScreen extends StatelessWidget {
  final VoidCallback onBack;
  const TimelineScreen({super.key, required this.onBack});

  Future<void> _confirmDelete(BuildContext context, {required bool all}) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(all ? l.deleteAllLocation : l.deleteDay),
        content: Text(l.deleteLocationConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(MaterialLocalizations.of(c).cancelButtonLabel)),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(l.delete,
                  style: const TextStyle(color: AppColors.bmiObese))),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final m = context.read<MovementProvider>();
    all ? await m.deleteAll() : await m.deleteDay();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final m = context.watch<MovementProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final today = DateTime.now();
    final isToday = m.day.year == today.year &&
        m.day.month == today.month &&
        m.day.day == today.day;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: onBack),
        title: Text(l.movementTitle),
        actions: [
          PopupMenuButton<bool>(
            onSelected: (all) => _confirmDelete(context, all: all),
            itemBuilder: (_) => [
              PopupMenuItem(value: false, child: Text(l.deleteDay)),
              PopupMenuItem(value: true, child: Text(l.deleteAllLocation)),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          // ── Day picker ───────────────────────────────────────────────
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () =>
                    m.showDay(m.day.subtract(const Duration(days: 1))),
              ),
              Expanded(
                child: Text(
                  DateFormat.MMMMEEEEd(l.localeName).format(m.day),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: isToday
                    ? null
                    : () => m.showDay(m.day.add(const Duration(days: 1))),
              ),
            ],
          ),
          // ── Tracking switch ──────────────────────────────────────────
          AppCard(
            padding: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (m.enabled)
                  Row(children: [
                    Icon(Icons.my_location_rounded, color: brand),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(l.trackingOn,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    ),
                    TextButton(onPressed: m.disable, child: Text(l.stopTracking)),
                  ])
                else ...[
                  Text(l.trackingOff,
                      style: GoogleFonts.inter(fontSize: 14, height: 1.45)),
                  const SizedBox(height: 10),
                  AppButton(
                    label: l.startTracking,
                    icon: Icons.my_location_rounded,
                    fullWidth: true,
                    onPressed: () => startTracking(context),
                  ),
                ],
                const SizedBox(height: 6),
                Text(l.trackingLimitNote,
                    style: GoogleFonts.inter(fontSize: 12, color: fg3)),
                if (m.enabled)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.batterySaver),
                    subtitle: Text(l.batterySaverBody,
                        style: GoogleFonts.inter(fontSize: 12, color: fg3)),
                    value: m.batterySaver,
                    onChanged: (v) => m.setBatterySaver(v, l),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Explain gaps instead of silently showing a broken day
          for (final g in m.gaps)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: 14,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.battery_alert_rounded, color: AppColors.bmiOver),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.trackingGap(DateFormat.jm(l.localeName).format(g.from),
                            DateFormat.jm(l.localeName).format(g.to)),
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ]),
                  Text(l.trackingGapBody, style: GoogleFonts.inter(fontSize: 13, color: fg3)),
                  TextButton(
                    onPressed: () => showKeepTrackingGuide(context),
                    child: Text(l.keepTrackingOn),
                  ),
                ]),
              ),
            ),
          if (m.points.isNotEmpty) ...[
            _DayMap(points: m.points, visits: m.visits),
            const SizedBox(height: 12),
          ],
          if (m.timeline.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l.noTimelineYet,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: fg3)),
            )
          else
            for (final item in m.timeline) _TimelineRow(item: item),
        ],
      ),
    );
  }
}

class _DayMap extends StatelessWidget {
  final List<LocationPoint> points;
  final List<Visit> visits;

  const _DayMap({required this.points, required this.visits});

  @override
  Widget build(BuildContext context) {
    final latLngs = [for (final p in points) LatLng(p.lat, p.lng)];
    final brand = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkBrand500
        : AppColors.brand500;
    final bounds = LatLngBounds.fromPoints(latLngs);
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 220,
        child: FlutterMap(
          options: MapOptions(
            // Fitting a zero-size area (all fixes in one spot, e.g. home all
            // day) gives an infinite zoom; centre on it instead.
            initialCameraFit: latLngs.length < 2 ||
                    (bounds.north - bounds.south).abs() < 1e-4 &&
                        (bounds.east - bounds.west).abs() < 1e-4
                ? null
                : CameraFit.bounds(
                    bounds: bounds, padding: const EdgeInsets.all(28)),
            initialCenter: latLngs.first,
            initialZoom: 15,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.bmihealth.bmi_health',
            ),
            PolylineLayer(polylines: [
              Polyline(points: latLngs, strokeWidth: 4, color: brand),
            ]),
            MarkerLayer(markers: [
              for (final v in visits)
                Marker(
                  point: LatLng(v.lat, v.lng),
                  width: 28,
                  height: 28,
                  child: Icon(
                    v.place?.isGym ?? false
                        ? Icons.fitness_center_rounded
                        : Icons.place_rounded,
                    color: AppColors.bmiObese,
                  ),
                ),
            ]),
            // Collapsed to its icon so it does not cover the route
            const RichAttributionWidget(
              popupInitialDisplayDuration: Duration.zero,
              attributions: [TextSourceAttribution('OpenStreetMap contributors')],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final TimelineItem item;
  const _TimelineRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final time = DateFormat.jm(l.localeName);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final range =
        '${time.format(item.start)} – ${time.format(item.end)} · ${formatDuration(l, item.duration)}';

    return switch (item) {
      Visit v => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AppCard(
            padding: 4,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: brand.withAlpha(30),
                child: Icon(
                    v.place?.isGym ?? false
                        ? Icons.fitness_center_rounded
                        : Icons.place_rounded,
                    color: brand),
              ),
              title: Text(v.place?.name ?? l.unnamedPlace,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              subtitle: Text(range),
              trailing: v.place == null
                  ? IconButton(
                      tooltip: l.namePlace,
                      icon: const Icon(Icons.edit_location_alt_outlined),
                      onPressed: () => showDialog<void>(
                          context: context,
                          builder: (_) => _NamePlaceDialog(visit: v)),
                    )
                  : null,
            ),
          ),
        ),
      Trip t => Padding(
          padding: const EdgeInsetsDirectional.only(start: 28, bottom: 8),
          child: Row(
            children: [
              Icon(
                switch (t.mode) {
                  TravelMode.walk => Icons.directions_walk_rounded,
                  TravelMode.run => Icons.directions_run_rounded,
                  TravelMode.vehicle => Icons.directions_car_rounded,
                },
                color: fg3,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${switch (t.mode) {
                    TravelMode.walk => l.modeWalk,
                    TravelMode.run => l.modeRun,
                    TravelMode.vehicle => l.modeVehicle,
                  }} · ${l.distanceKm((t.distanceM / 1000).toStringAsFixed(1))} · $range',
                  style: GoogleFonts.inter(fontSize: 13, color: fg3),
                ),
              ),
            ],
          ),
        ),
    };
  }
}

class _NamePlaceDialog extends StatefulWidget {
  final Visit visit;
  const _NamePlaceDialog({required this.visit});

  @override
  State<_NamePlaceDialog> createState() => _NamePlaceDialogState();
}

class _NamePlaceDialogState extends State<_NamePlaceDialog> {
  final _name = TextEditingController();
  bool _gym = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.namePlace),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            maxLength: 40,
            decoration: InputDecoration(labelText: l.placeName, counterText: ''),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _gym,
            title: Text(l.thisIsMyGym),
            onChanged: (v) => setState(() => _gym = v ?? false),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel)),
        TextButton(
          onPressed: () async {
            final name = _name.text.trim();
            if (name.isEmpty) return;
            final m = context.read<MovementProvider>();
            Navigator.pop(context);
            await m.addPlace(Place(
              name: name,
              lat: widget.visit.lat,
              lng: widget.visit.lng,
              isGym: _gym,
            ));
          },
          child: Text(l.save),
        ),
      ],
    );
  }
}

/// Per-brand steps to stop battery savers killing tracking.
void showKeepTrackingGuide(BuildContext context) {
  final l = context.l10n;
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20),
        children: [
          Text(l.keepTrackingOn,
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(l.keepTrackingIntro),
          for (final step in [l.guideXiaomi, l.guideOppo, l.guideVivo, l.guideSamsung, l.guideHuawei, l.guideOther])
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('• $step', style: GoogleFonts.inter(fontSize: 14, height: 1.4)),
            ),
        ],
      ),
    ),
  );
}

