import 'dart:typed_data';

/// One image plane as delivered by the camera.
typedef YuvPlane = ({Uint8List bytes, int bytesPerRow, int? bytesPerPixel});

/// Converts a 3-plane YUV_420_888 frame (what CameraX delivers on Android,
/// whatever format is requested) into NV21, the layout ML Kit accepts:
/// full Y plane, then interleaved V/U at quarter resolution.
///
/// Handles row padding (bytesPerRow > width) and both packed
/// (pixel stride 2) and planar (pixel stride 1) chroma.
Uint8List yuv420ToNv21(int width, int height, List<YuvPlane> planes) {
  final y = planes[0], u = planes[1], v = planes[2];
  final out = Uint8List(width * height + 2 * (width ~/ 2) * (height ~/ 2));
  var o = 0;

  for (var row = 0; row < height; row++) {
    final start = row * y.bytesPerRow;
    out.setRange(o, o + width, y.bytes, start);
    o += width;
  }

  final uvStride = u.bytesPerPixel ?? 1;
  for (var row = 0; row < height ~/ 2; row++) {
    for (var col = 0; col < width ~/ 2; col++) {
      final ui = row * u.bytesPerRow + col * uvStride;
      final vi = row * v.bytesPerRow + col * (v.bytesPerPixel ?? 1);
      out[o++] = v.bytes[vi];
      out[o++] = u.bytes[ui];
    }
  }
  return out;
}
