import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/core/monitoring/crash_reporting.dart';
import 'package:bmi_health/core/notifications/reminder_service.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/features/movement/domain/timeline.dart';
import 'package:bmi_health/l10n/l10n.dart';

enum TrackingStart { started, denied, serviceOff, unsupported }

/// Records location while tracking is on and turns it into a daily timeline.
///
/// Free approach (ROADMAP 2.2): a geolocator position stream that, on
/// Android, runs as a visible foreground service started from the app.
/// It keeps tracking with the screen off, but stops if the user swipes the
/// app away; it restarts automatically on the next launch.
class MovementProvider extends ChangeNotifier {
  MovementProvider(this._db, {DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  final DatabaseHelper _db;
  final DateTime Function() _now;
  static const _enabledKey = 'tracking_enabled';
  static const _saverKey = 'tracking_battery_saver';
  bool _batterySaver = false;

  /// Fewer, coarser fixes (every 3 min, ~100 m) to save battery.
  bool get batterySaver => _batterySaver;

  /// Long silences in the shown day while tracking was on.
  List<({DateTime from, DateTime to})> get gaps =>
      _enabled ? TrackingGaps.find(_points) : const [];

  Future<void> setBatterySaver(bool v, AppLocalizations l) async {
    _batterySaver = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_saverKey, v);
    // Restart the stream with the new settings.
    await _sub?.cancel();
    _sub = null;
    notifyListeners();
    await resume(l);
  }

  StreamSubscription<Position>? _sub;
  bool _enabled = false;
  List<Place> _places = [];
  DateTime _day = DateTime.now();
  /// True unless the user is looking at a past day; then the shown day
  /// rolls over to the new date at midnight.
  bool _followToday = true;
  List<TimelineItem> _timeline = [];
  List<LocationPoint> _points = [];
  Duration _gymWeek = Duration.zero;
  DateTime? _lastGymNotice;

  bool get enabled => _enabled;
  bool get tracking => _sub != null;
  List<Place> get places => _places;
  DateTime get day => _day;
  List<TimelineItem> get timeline => _timeline;
  List<LocationPoint> get points => _points;
  Duration get gymTimeThisWeek => _gymWeek;

  List<Visit> get visits => _timeline.whereType<Visit>().toList();
  double get distanceM => _timeline
      .whereType<Trip>()
      .fold(0.0, (sum, t) => sum + t.distanceM);

  static DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledKey) ?? false;
    _batterySaver = prefs.getBool(_saverKey) ?? false;
    _places = await _db.getPlaces();
    _day = _dayStart(_now());
    await _rebuild();
  }

  /// Re-reads the shown day (call on app resume; also rolls over at midnight).
  Future<void> refresh() => _rebuild();

  Future<void> showDay(DateTime day) async {
    _day = _dayStart(day);
    _followToday = _day == _dayStart(_now());
    await _rebuild();
  }

  Future<void> _rebuild() async {
    if (_followToday) _day = _dayStart(_now());
    _points = await _db.getPoints(_day, _day.add(const Duration(days: 1)));
    _timeline = TimelineBuilder.build(_points, _places);

    final now = _now();
    final weekStart =
        _dayStart(now).subtract(Duration(days: now.weekday - 1));
    final weekItems = TimelineBuilder.build(
        await _db.getPoints(weekStart, now.add(const Duration(minutes: 1))),
        _places);
    _gymWeek = weekItems
        .whereType<Visit>()
        .where((v) => v.place?.isGym ?? false)
        .fold(Duration.zero, (sum, v) => sum + v.duration);
    notifyListeners();
  }

  /// Turns tracking on (asking for location permission in context).
  Future<TrackingStart> enable(AppLocalizations l) async {
    if (!Platform.isAndroid && !Platform.isIOS) return TrackingStart.unsupported;
    if (!await Geolocator.isLocationServiceEnabled()) {
      return TrackingStart.serviceOff;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      AdService.instance.beginExternalUi();
      try {
        permission = await Geolocator.requestPermission();
      } finally {
        AdService.instance.endExternalUi();
      }
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return TrackingStart.denied;
    }
    // The ongoing notification needs notification permission on Android 13+
    await ReminderService.instance.requestPermission();

    _enabled = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, true);
    await resume(l);
    return TrackingStart.started;
  }

  Future<void> disable() async {
    _enabled = false;
    await _sub?.cancel();
    _sub = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, false);
    notifyListeners();
  }

  /// (Re)starts the position stream if the user has tracking on.
  /// Called on launch and on resume; does nothing if already running.
  Future<void> resume(AppLocalizations l) async {
    if (!_enabled || _sub != null) return;
    try {
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return;
      }
      final LocationSettings settings = Platform.isAndroid
          ? AndroidSettings(
              accuracy: _batterySaver ? LocationAccuracy.medium : LocationAccuracy.high,
              // Time-based updates (no distance filter): stays need points
              // while standing still, and Android's fused provider blocks
              // distance-filtered delivery as "too fast" when the interval
              // is short. One fix a minute keeps battery use low.
              distanceFilter: 0,
              intervalDuration: Duration(seconds: _batterySaver ? 180 : 60),
              foregroundNotificationConfig: ForegroundNotificationConfig(
                notificationTitle: l.trackingNotificationTitle,
                notificationText: l.trackingNotificationBody,
                notificationChannelName: l.activityChannel,
                enableWakeLock: false,
                setOngoing: true,
              ),
            )
          : AppleSettings(
              accuracy: _batterySaver ? LocationAccuracy.reduced : LocationAccuracy.high,
              distanceFilter: _batterySaver ? 100 : 25,
              activityType: ActivityType.fitness,
              pauseLocationUpdatesAutomatically: true,
              showBackgroundLocationIndicator: true,
            );
      // Another call may have started the stream (or the user stopped
      // tracking) while we awaited the permission check. A second
      // subscription would leak and keep the foreground service running.
      if (!_enabled || _sub != null) return;
      _sub = Geolocator.getPositionStream(locationSettings: settings).listen(
        (pos) => _onPosition(pos, l),
        onError: (Object e, StackTrace st) {
          reportError(e, st, reason: 'location-stream');
          // Cancel, don't just forget it: a stream that is still listened to
          // keeps the foreground service and its notification alive, and
          // Stop tracking could no longer reach it. resume() retries later.
          final dead = _sub;
          _sub = null;
          dead?.cancel();
          notifyListeners();
        },
      );
      notifyListeners();
    } catch (e, st) {
      reportError(e, st, reason: 'location-start');
    }
  }

  Future<void> _onPosition(Position pos, AppLocalizations l) async {
    final point = LocationPoint(
      time: pos.timestamp,
      lat: pos.latitude,
      lng: pos.longitude,
      accuracyM: pos.accuracy,
    );
    await _db.insertPoint(point);
    if (_followToday || _dayStart(point.time) == _day) await _rebuild();
    await _checkGym(l);
  }

  /// Gym check-in: once per visit, after 3 minutes inside a gym place.
  Future<void> _checkGym(AppLocalizations l) async {
    final now = _now();
    if (_lastGymNotice != null &&
        now.difference(_lastGymNotice!) < const Duration(hours: 3)) {
      return;
    }
    final recent = await _db.getPoints(
        now.subtract(const Duration(minutes: 10)), now.add(const Duration(minutes: 1)));
    if (gymArrival(recent, _places, now)) {
      _lastGymNotice = now;
      await ReminderService.instance.showNow(
          id: 10, title: l.gymCheckInTitle, body: l.gymCheckInBody, l: l);
    }
  }

  /// True when the last [dwell] of points are all inside a gym place.
  @visibleForTesting
  static bool gymArrival(List<LocationPoint> recent, List<Place> places,
      DateTime now, {Duration dwell = const Duration(minutes: 3)}) {
    final gyms = places.where((p) => p.isGym).toList();
    if (gyms.isEmpty || recent.isEmpty) return false;
    final window = recent
        .where((p) => !p.time.isBefore(now.subtract(dwell)))
        .toList();
    if (window.isEmpty) return false;
    // Need points spanning (almost) the whole dwell period
    if (now.difference(recent.first.time) < dwell) return false;
    return gyms.any((g) => window.every((p) => g.contains(p.lat, p.lng)));
  }

  /// Distance moved and gym time between two dates (for recaps). Built
  /// day by day so each day's timeline stays small.
  Future<({double km, Duration gym})> totalsBetween(DateTime from, DateTime to) async {
    var m = 0.0;
    var gym = Duration.zero;
    for (var d = _dayStart(from); d.isBefore(to); d = d.add(const Duration(days: 1))) {
      final items = TimelineBuilder.build(
          await _db.getPoints(d, d.add(const Duration(days: 1))), _places);
      for (final i in items) {
        if (i is Trip) m += i.distanceM;
        if (i is Visit && (i.place?.isGym ?? false)) gym += i.duration;
      }
    }
    return (km: m / 1000, gym: gym);
  }

  Future<void> addPlace(Place place) async {
    await _db.insertPlace(place);
    _places = await _db.getPlaces();
    await _rebuild();
  }

  Future<void> deletePlace(int id) async {
    await _db.deletePlace(id);
    _places = await _db.getPlaces();
    await _rebuild();
  }

  Future<void> deleteDay() async {
    await _db.deletePoints(_day, _day.add(const Duration(days: 1)));
    await _rebuild();
  }

  Future<void> deleteAll() async {
    await _db.deleteAllPoints();
    await _rebuild();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
