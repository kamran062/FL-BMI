import 'dart:math' as math;

/// A recorded GPS fix.
class LocationPoint {
  final int? id;
  final DateTime time;
  final double lat;
  final double lng;
  final double accuracyM;

  const LocationPoint({
    this.id,
    required this.time,
    required this.lat,
    required this.lng,
    this.accuracyM = 0,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'time': time.millisecondsSinceEpoch,
        'lat': lat,
        'lng': lng,
        'accuracy': accuracyM,
      };

  factory LocationPoint.fromMap(Map<String, dynamic> m) => LocationPoint(
        id: m['id'] as int?,
        time: DateTime.fromMillisecondsSinceEpoch(m['time'] as int),
        lat: (m['lat'] as num).toDouble(),
        lng: (m['lng'] as num).toDouble(),
        accuracyM: (m['accuracy'] as num?)?.toDouble() ?? 0,
      );
}

/// A place the user named (Home, Gym, …).
class Place {
  final int? id;
  final String name;
  final double lat;
  final double lng;
  final double radiusM;
  final bool isGym;

  const Place({
    this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.radiusM = 120,
    this.isGym = false,
  });

  bool contains(double la, double ln) => Geo.distanceM(lat, lng, la, ln) <= radiusM;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'lat': lat,
        'lng': lng,
        'radius_m': radiusM,
        'is_gym': isGym ? 1 : 0,
      };

  factory Place.fromMap(Map<String, dynamic> m) => Place(
        id: m['id'] as int?,
        name: m['name'] as String,
        lat: (m['lat'] as num).toDouble(),
        lng: (m['lng'] as num).toDouble(),
        radiusM: (m['radius_m'] as num).toDouble(),
        isGym: (m['is_gym'] as int) == 1,
      );
}

enum TravelMode { walk, run, vehicle }

sealed class TimelineItem {
  DateTime get start;
  DateTime get end;
  Duration get duration => end.difference(start);
}

/// Staying in one place.
class Visit extends TimelineItem {
  @override
  final DateTime start;
  @override
  final DateTime end;
  final double lat;
  final double lng;
  final Place? place;

  Visit({required this.start, required this.end, required this.lat,
      required this.lng, this.place});
}

/// Moving between places.
class Trip extends TimelineItem {
  @override
  final DateTime start;
  @override
  final DateTime end;
  final double distanceM;
  final TravelMode mode;
  final List<LocationPoint> path;

  Trip({required this.start, required this.end, required this.distanceM,
      required this.mode, required this.path});

  double get speedKmh =>
      duration.inSeconds == 0 ? 0 : distanceM / duration.inSeconds * 3.6;
}

abstract final class Geo {
  /// Great-circle distance in metres (haversine).
  static double distanceM(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371000.0;
    double rad(double d) => d * math.pi / 180;
    final dLat = rad(lat2 - lat1);
    final dLng = rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(rad(lat1)) * math.cos(rad(lat2)) *
            math.sin(dLng / 2) * math.sin(dLng / 2);
    return 2 * r * math.asin(math.min(1, math.sqrt(a)));
  }

  static double pathLengthM(List<LocationPoint> pts) {
    var total = 0.0;
    for (var i = 1; i < pts.length; i++) {
      total += distanceM(pts[i - 1].lat, pts[i - 1].lng, pts[i].lat, pts[i].lng);
    }
    return total;
  }
}

/// Turns raw GPS points into visits and trips.
abstract final class TimelineBuilder {
  /// Points within this radius belong to the same stay.
  static const stayRadiusM = 100.0;

  /// A stay must last at least this long to count as a visit.
  static const minStay = Duration(minutes: 5);

  /// Fixes worse than this are GPS noise (indoors, tunnels) and ignored.
  static const maxAccuracyM = 150.0;

  static TravelMode modeFor(double speedKmh) => speedKmh < 7.5
      ? TravelMode.walk
      : speedKmh < 16
          ? TravelMode.run
          : TravelMode.vehicle;

  static List<TimelineItem> build(List<LocationPoint> raw, List<Place> places) {
    final pts = raw.where((p) => p.accuracyM <= maxAccuracyM).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    if (pts.isEmpty) return const [];

    // 1. Find stays: maximal runs of points close to the run's first point.
    final stays = <({int from, int to})>[];
    var i = 0;
    while (i < pts.length) {
      var j = i;
      while (j + 1 < pts.length &&
          Geo.distanceM(pts[i].lat, pts[i].lng, pts[j + 1].lat, pts[j + 1].lng) <=
              stayRadiusM) {
        j++;
      }
      if (pts[j].time.difference(pts[i].time) >= minStay) {
        stays.add((from: i, to: j));
        i = j + 1;
      } else {
        i++;
      }
    }

    // 2. Visits for stays; trips for the movement in between.
    final items = <TimelineItem>[];
    var cursor = 0;
    void addTrip(int from, int to) {
      if (to <= from) return;
      final path = pts.sublist(from, to + 1);
      final dist = Geo.pathLengthM(path);
      if (dist < stayRadiusM) return; // jitter, not a journey
      final dur = path.last.time.difference(path.first.time);
      final kmh = dur.inSeconds == 0 ? 0.0 : dist / dur.inSeconds * 3.6;
      items.add(Trip(
        start: path.first.time,
        end: path.last.time,
        distanceM: dist,
        mode: modeFor(kmh),
        path: path,
      ));
    }

    for (final s in stays) {
      addTrip(cursor, s.from);
      final group = pts.sublist(s.from, s.to + 1);
      final lat = group.map((p) => p.lat).reduce((a, b) => a + b) / group.length;
      final lng = group.map((p) => p.lng).reduce((a, b) => a + b) / group.length;
      Place? place;
      for (final pl in places) {
        if (pl.contains(lat, lng)) {
          place = pl;
          break;
        }
      }
      items.add(Visit(
        start: group.first.time,
        end: group.last.time,
        lat: lat,
        lng: lng,
        place: place,
      ));
      cursor = s.to;
    }
    addTrip(cursor, pts.length - 1);
    return items;
  }
}

/// Stretches with no location fixes while tracking was on (ROADMAP risk:
/// phone-maker battery savers killing the tracker). Fixes arrive at least
/// every few minutes, so a long silence means tracking was stopped.
abstract final class TrackingGaps {
  static const minGap = Duration(minutes: 45);

  static List<({DateTime from, DateTime to})> find(List<LocationPoint> points,
      {Duration min = minGap}) {
    final sorted = [...points]..sort((a, b) => a.time.compareTo(b.time));
    return [
      for (var i = 1; i < sorted.length; i++)
        if (sorted[i].time.difference(sorted[i - 1].time) >= min)
          (from: sorted[i - 1].time, to: sorted[i].time)
    ];
  }
}

