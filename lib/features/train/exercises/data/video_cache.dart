import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:bmi_health/core/monitoring/crash_reporting.dart';

/// Keeps hosted exercise clips on the device after the first play, so they
/// work offline and aren't downloaded again. The OS may clear this cache.
class VideoCache {
  VideoCache._();
  static final instance = VideoCache._();

  final _inFlight = <String>{};

  Future<File> _file(String url) async {
    final dir = Directory('${(await getApplicationCacheDirectory()).path}/exercise_videos');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return File('${dir.path}/${_hash(url)}.mp4');
  }

  /// The saved copy of [url], or null if it hasn't been downloaded yet.
  Future<File?> cached(String url) async {
    try {
      final f = await _file(url);
      return f.existsSync() && f.lengthSync() > 0 ? f : null;
    } catch (_) {
      return null;
    }
  }

  /// Downloads [url] in the background for next time. Failures are quiet:
  /// the clip still streams, it just isn't kept.
  Future<void> download(String url) async {
    if (!_inFlight.add(url)) return;
    try {
      final res = await http.get(Uri.parse(url)).timeout(const Duration(minutes: 2));
      if (res.statusCode != 200 || res.bodyBytes.length < 1024) return;
      final f = await _file(url);
      final tmp = File('${f.path}.part');
      await tmp.writeAsBytes(res.bodyBytes, flush: true);
      await tmp.rename(f.path);
    } catch (e, st) {
      reportError(e, st, reason: 'video-cache');
    } finally {
      _inFlight.remove(url);
    }
  }

  /// Stable file name for a URL (FNV-1a, 64-bit).
  static String _hash(String s) {
    var h = 0xcbf29ce484222325;
    for (final c in s.codeUnits) {
      h ^= c;
      h = h * 0x100000001b3; // wraps at 64 bits
    }
    return h.toUnsigned(64).toRadixString(16);
  }
}
