import 'dart:async';
import 'dart:io';

import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/movement/domain/timeline.dart';
import 'package:bmi_health/features/movement/movement_provider.dart';
import 'package:bmi_health/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test('timeline follows today across midnight (found on device)', () async {
    SharedPreferences.setMockInitialValues({});
    final tmp = Directory.systemTemp.createTempSync('move_test');
    final db = DatabaseHelper.test(databaseFactoryFfi, '${tmp.path}/m.db');
    var now = DateTime(2026, 11, 3, 23, 50);
    final m = MovementProvider(db, clock: () => now);
    await m.load();

    // Home 23:50–23:58 yesterday, then a place 00:05–00:15 today
    for (var i = 0; i <= 8; i += 2) {
      await db.insertPoint(LocationPoint(
          time: DateTime(2026, 11, 3, 23, 50 + i), lat: 31.50, lng: 74.30, accuracyM: 5));
    }
    for (var i = 5; i <= 15; i += 2) {
      await db.insertPoint(LocationPoint(
          time: DateTime(2026, 11, 4, 0, i), lat: 31.51, lng: 74.30, accuracyM: 5));
    }

    now = DateTime(2026, 11, 4, 0, 20);
    await m.refresh(); // app resumed after midnight
    expect(m.day, DateTime(2026, 11, 4));
    expect(m.visits.single.start, DateTime(2026, 11, 4, 0, 5));

    // Looking at a past day stays on that day
    await m.showDay(DateTime(2026, 11, 3));
    expect(m.visits.single.start, DateTime(2026, 11, 3, 23, 50));

    await db.close();
    tmp.deleteSync(recursive: true);
  });

  test('stop tracking ends every location stream, even after an overlapping start (found on device)',
      () async {
    SharedPreferences.setMockInitialValues({'tracking_enabled': true});
    final geo = _FakeGeolocator();
    GeolocatorPlatform.instance = geo;
    final tmp = Directory.systemTemp.createTempSync('move_test');
    final db = DatabaseHelper.test(databaseFactoryFfi, '${tmp.path}/m.db');
    final m = MovementProvider(db);
    await m.load();
    final l = lookupAppLocalizations(const Locale('en'));

    // Starting tracking and the app resuming after the permission dialog
    // both start the stream at the same time
    await Future.wait([m.resume(l), m.resume(l)]);
    expect(geo.listeners, 1);

    await m.disable();
    expect(geo.listeners, 0, reason: 'a leaked stream keeps the foreground service and its notification');

    await db.close();
    tmp.deleteSync(recursive: true);
  });

  test('a location error (GPS switched off) ends the stream instead of leaking it (found on device)',
      () async {
    SharedPreferences.setMockInitialValues({'tracking_enabled': true});
    final geo = _FakeGeolocator();
    GeolocatorPlatform.instance = geo;
    final tmp = Directory.systemTemp.createTempSync('move_test');
    final db = DatabaseHelper.test(databaseFactoryFfi, '${tmp.path}/m.db');
    final m = MovementProvider(db);
    await m.load();
    await m.resume(lookupAppLocalizations(const Locale('en')));
    expect(geo.listeners, 1);

    geo.controller!.addError(const LocationServiceDisabledException());
    await Future<void>.delayed(Duration.zero);
    expect(geo.listeners, 0);
    expect(m.enabled, isTrue, reason: 'still on: it restarts when the app resumes');

    await db.close();
    tmp.deleteSync(recursive: true);
  });
}

class _FakeGeolocator extends GeolocatorPlatform with MockPlatformInterfaceMixin {
  int listeners = 0;
  StreamController<Position>? controller;

  @override
  Future<LocationPermission> checkPermission() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return LocationPermission.whileInUse;
  }

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    final c = controller = StreamController<Position>(
      onListen: () => listeners++,
      onCancel: () => listeners--,
    );
    return c.stream;
  }
}
