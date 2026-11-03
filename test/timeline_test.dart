import 'package:bmi_health/features/movement/domain/timeline.dart';
import 'package:bmi_health/features/movement/movement_provider.dart';
import 'package:flutter_test/flutter_test.dart';

// ~111 m per 0.001° latitude.
LocationPoint p(int minute, double lat, double lng, {double acc = 10}) =>
    LocationPoint(
        time: DateTime(2026, 11, 3, 8).add(Duration(minutes: minute)),
        lat: lat, lng: lng, accuracyM: acc);

void main() {
  test('haversine: 0.01° latitude ≈ 1.11 km', () {
    expect(Geo.distanceM(31.5, 74.3, 31.51, 74.3), closeTo(1112, 5));
  });

  test('home → walk → gym gives visit, trip, visit', () {
    final pts = [
      // home 08:00–08:30 (small GPS jitter)
      for (var m = 0; m <= 30; m += 5) p(m, 31.5000 + (m % 10) * 0.00001, 74.3000),
      // walking 1.1 km north over 15 min (≈4.4 km/h)
      for (var k = 1; k <= 5; k++) p(30 + k * 3, 31.5000 + k * 0.002, 74.3000),
      // gym 08:45–09:45
      for (var m = 45; m <= 105; m += 5) p(m, 31.5100, 74.3000),
    ];
    const gym = Place(name: 'Gym', lat: 31.51, lng: 74.3, isGym: true);
    final items = TimelineBuilder.build(pts, [gym]);

    expect(items.map((e) => e.runtimeType), [Visit, Trip, Visit]);
    final trip = items[1] as Trip;
    expect(trip.mode, TravelMode.walk);
    expect(trip.distanceM, closeTo(1112, 60));
    final gymVisit = items[2] as Visit;
    expect(gymVisit.place?.isGym, isTrue);
    expect(gymVisit.duration, const Duration(hours: 1));
  });

  test('driving speed is classed as vehicle', () {
    final pts = [
      for (var m = 0; m <= 10; m += 5) p(m, 31.50, 74.30),
      // 5.5 km in 10 min = 33 km/h
      for (var k = 1; k <= 5; k++) p(10 + k * 2, 31.50 + k * 0.01, 74.30),
      for (var m = 22; m <= 40; m += 5) p(m, 31.55, 74.30),
    ];
    final trip = TimelineBuilder.build(pts, const []).whereType<Trip>().single;
    expect(trip.mode, TravelMode.vehicle);
  });

  test('short stops are not visits; inaccurate fixes are ignored', () {
    final pts = [
      p(0, 31.50, 74.30),
      p(2, 31.50, 74.30), // only 2 minutes
      p(3, 31.60, 74.30, acc: 900), // indoor noise
    ];
    expect(TimelineBuilder.build(pts, const []).whereType<Visit>(), isEmpty);
  });

  test('empty input', () {
    expect(TimelineBuilder.build(const [], const []), isEmpty);
  });

  group('gym check-in', () {
    const gym = Place(name: 'Gym', lat: 31.51, lng: 74.30, isGym: true);
    final now = DateTime(2026, 11, 3, 8, 10);

    test('fires after 3 minutes inside the gym', () {
      final pts = [for (var m = 0; m <= 10; m += 1) p(m, 31.51, 74.30)];
      expect(MovementProvider.gymArrival(pts, [gym], now), isTrue);
    });

    test('not when only passing by', () {
      final pts = [
        for (var m = 0; m <= 8; m += 1) p(m, 31.50, 74.30), // outside
        p(9, 31.51, 74.30), p(10, 31.51, 74.30), // just arrived
      ];
      expect(MovementProvider.gymArrival(pts, [gym], now), isFalse);
    });

    test('not without a gym place', () {
      final pts = [for (var m = 0; m <= 10; m += 1) p(m, 31.51, 74.30)];
      expect(MovementProvider.gymArrival(pts, const [], now), isFalse);
    });
  });
}

