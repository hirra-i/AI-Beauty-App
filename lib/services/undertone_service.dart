import 'dart:io';
import 'package:image/image.dart' as img;

class UndertoneResult {
  final String undertone; // warm/cool/neutral
  final double confidence; // 0..1
  final String quality; // good/low_light/overexposed
  final Map<String, dynamic> debug;

  UndertoneResult({
    required this.undertone,
    required this.confidence,
    required this.quality,
    required this.debug,
  });
}

class UndertoneService {
  /// Reads image, downscales, samples pixels, and estimates undertone.
  /// computes color statistics.
  Future<UndertoneResult> analyse(File file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return UndertoneResult(
        undertone: 'unknown',
        confidence: 0,
        quality: 'invalid_image',
        debug: {},
      );
    }

    // Downscale for speed + stability
    final resized = img.copyResize(decoded, width: 180);

    // Sample pixels (skip edges a bit to reduce background influence)
    final w = resized.width;
    final h = resized.height;
    final x0 = (w * 0.15).round();
    final x1 = (w * 0.85).round();
    final y0 = (h * 0.15).round();
    final y1 = (h * 0.85).round();

    double sumR = 0, sumG = 0, sumB = 0;
    double sumLuma = 0;
    int count = 0;

    for (int y = y0; y < y1; y += 2) {
      for (int x = x0; x < x1; x += 2) {
final pixel = resized.getPixel(x, y);

final r = pixel.r.toDouble();
final g = pixel.g.toDouble();
final b = pixel.b.toDouble();

        // Luma (perceived brightness)
        final luma = 0.2126 * r + 0.7152 * g + 0.0722 * b;

        sumR += r; sumG += g; sumB += b;
        sumLuma += luma;
        count++;
      }
    }

    final avgR = sumR / count;
    final avgG = sumG / count;
    final avgB = sumB / count;
    final avgLuma = sumLuma / count;

    // Quality gates
    String quality = 'good';
    if (avgLuma < 60) quality = 'low_light';
    if (avgLuma > 210) quality = 'overexposed';

    // Undertone heuristic
    // Warm undertones tend to have relatively higher red/yellow components.
    // Cool undertones tend to have relatively higher blue/pink-ish balance.
    // We’ll use simple ratios that behave decently under normal lighting.
    final warmScore = (avgR - avgB) + (avgR - avgG) * 0.5;
    final coolScore = (avgB - avgR) + (avgG - avgR) * 0.2;

    // Normalize into a “decision margin”
    final margin = warmScore - coolScore;

    String undertone = 'neutral';
    if (margin > 8) undertone = 'warm';
    if (margin < -8) undertone = 'cool';

    // Confidence grows with absolute margin but is capped.
    double confidence = (margin.abs() / 30).clamp(0.0, 1.0);

    // If lighting is poor, reduce confidence and refuse if very low
    if (quality != 'good') {
      confidence *= 0.55;
      if (confidence < 0.25) {
        return UndertoneResult(
          undertone: 'unknown',
          confidence: confidence,
          quality: quality,
          debug: {
            'avgR': avgR, 'avgG': avgG, 'avgB': avgB, 'avgLuma': avgLuma,
            'margin': margin,
          },
        );
      }
    }

    return UndertoneResult(
      undertone: undertone,
      confidence: confidence,
      quality: quality,
      debug: {
        'avgR': avgR, 'avgG': avgG, 'avgB': avgB, 'avgLuma': avgLuma,
        'warmScore': warmScore,
        'coolScore': coolScore,
        'margin': margin,
      },
    );
  }
}