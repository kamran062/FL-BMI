import 'dart:typed_data';

import 'package:bmi_health/features/train/rep_counter/yuv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('planar YUV with row padding → NV21 (Y then V,U interleaved)', () {
    // 4×2 image, Y rows padded to 6 bytes; chroma 2×1
    final y = Uint8List.fromList([1, 2, 3, 4, 0, 0, 5, 6, 7, 8, 0, 0]);
    final u = Uint8List.fromList([20, 21]);
    final v = Uint8List.fromList([30, 31]);
    final nv21 = yuv420ToNv21(4, 2, [
      (bytes: y, bytesPerRow: 6, bytesPerPixel: 1),
      (bytes: u, bytesPerRow: 2, bytesPerPixel: 1),
      (bytes: v, bytesPerRow: 2, bytesPerPixel: 1),
    ]);
    expect(nv21, [1, 2, 3, 4, 5, 6, 7, 8, 30, 20, 31, 21]);
  });

  test('packed chroma (pixel stride 2) is de-interleaved correctly', () {
    final y = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
    // Android often shares one buffer: U at even, V at odd offsets
    final u = Uint8List.fromList([20, 99, 21, 99]);
    final v = Uint8List.fromList([30, 99, 31, 99]);
    final nv21 = yuv420ToNv21(4, 2, [
      (bytes: y, bytesPerRow: 4, bytesPerPixel: 1),
      (bytes: u, bytesPerRow: 4, bytesPerPixel: 2),
      (bytes: v, bytesPerRow: 4, bytesPerPixel: 2),
    ]);
    expect(nv21.sublist(8), [30, 20, 31, 21]);
  });
}
