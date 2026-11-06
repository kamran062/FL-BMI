import 'dart:io';

import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/features/train/wear/wear_bridge.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FakeChannel implements WearChannel {
  final sent = <WearState>[];
  late Future<void> Function(String, Object?) watch;

  @override
  Future<void> send(WearState s) async => sent.add(s);

  @override
  void listen(Future<void> Function(String event, Object? arg) onEvent) => watch = onEvent;
}

void main() {
  sqfliteFfiInit();
  late Directory tmp;
  late DatabaseHelper db;
  late WorkoutProvider w;
  late FakeChannel ch;
  late WearBridge bridge;
  var now = DateTime(2026, 11, 4, 18);
  final catalog = ExerciseCatalog.parse(File('assets/exercises/catalog.json').readAsStringSync());

  setUp(() async {
    tmp = Directory.systemTemp.createTempSync('wear');
    db = DatabaseHelper.test(databaseFactoryFfi, '${tmp.path}/w.db');
    w = WorkoutProvider(db);
    await w.load();
    ch = FakeChannel();
    bridge = WearBridge(w, catalog, channel: ch, clock: () => now);
  });

  tearDown(() async {
    bridge.dispose();
    await db.close();
    tmp.deleteSync(recursive: true);
  });

  Future<void> twoSetsOfBench() async {
    await w.start(name: 'A');
    await w.addExercise('barbell_bench_press');
    final s = w.setsFor('barbell_bench_press').single;
    await w.updateSet(s.copyWith(weightKg: 60, reps: 8));
    await w.addSet('barbell_bench_press');
  }

  test('idle until a workout starts, then shows the next set', () async {
    expect(ch.sent.single, WearState.idle);
    await twoSetsOfBench();
    final s = ch.sent.last;
    expect(s.active, isTrue);
    expect(s.exercise, 'Barbell Bench Press');
    expect(s.setNumber, 1);
    expect(s.setsTotal, 2);
    expect(s.weightKg, 60);
    expect(s.restEndsAtMs, 0);
  });

  test('"done" on the watch ticks the next set and starts the rest timer', () async {
    await twoSetsOfBench();
    await ch.watch('setDone', null);
    expect(w.setsFor('barbell_bench_press').first.done, isTrue);
    final s = ch.sent.last;
    expect(s.setNumber, 2);
    // Rest comes from the exercise (bench press: 150 s as a heavy lift)
    final rest = catalog.byId('barbell_bench_press')!.prescription.restSec;
    expect(rest, 150);
    expect(s.restEndsAtMs, now.add(Duration(seconds: rest)).millisecondsSinceEpoch);

    await ch.watch('setDone', null);
    expect(ch.sent.last.allDone, isTrue);
    // Extra taps with nothing left do nothing
    await ch.watch('setDone', null);
    expect(w.activeSets.where((s) => s.done), hasLength(2));
  });

  test('ticking on the phone also updates the watch', () async {
    await twoSetsOfBench();
    final first = w.setsFor('barbell_bench_press').first;
    await w.updateSet(first.copyWith(done: true));
    expect(ch.sent.last.setNumber, 2);
  });

  test('heart rate: shown during a workout, noise and stale values hidden', () async {
    await ch.watch('heartRate', 120);
    expect(bridge.currentHeartRate, isNull); // no workout running

    await twoSetsOfBench();
    await ch.watch('heartRate', 132);
    expect(bridge.currentHeartRate, 132);
    await ch.watch('heartRate', 400); // sensor glitch
    expect(bridge.currentHeartRate, 132);

    now = now.add(const Duration(seconds: 30));
    expect(bridge.currentHeartRate, isNull); // watch went quiet

    await w.finish();
    expect(ch.sent.last, WearState.idle);
    expect(bridge.heartRate.value, isNull);
  });

  test('no duplicate syncs for unrelated changes', () async {
    await twoSetsOfBench();
    final n = ch.sent.length;
    w.notifyListeners();
    expect(ch.sent.length, n);
  });
}
