import 'dart:math';

import 'package:ezan_hatirlatici/screens/qibla_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// Telefonun üst kenarı [headingDeg] yönüne bakarken [pitchDeg] kadar kaldırıldığında
/// sensörlerin okuyacağı değerler. Dünya alanı: kuzeye 20 µT, aşağı 40 µT (Türkiye gibi).
List<double> sensorsFor(double headingDeg, double pitchDeg) {
  final h = headingDeg * pi / 180, p = pitchDeg * pi / 180;
  // Dünya ekseni: (doğu, kuzey, yukarı)
  final x = [cos(h), -sin(h), 0.0];
  final y = [sin(h) * cos(p), cos(h) * cos(p), sin(p)];
  final z = [-sin(h) * sin(p), -cos(h) * sin(p), cos(p)];
  const up = [0.0, 0.0, 9.81];
  const field = [0.0, 20.0, -40.0];
  double dot(List<double> a, List<double> b) => a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
  return [dot(up, x), dot(up, y), dot(up, z), dot(field, x), dot(field, y), dot(field, z)];
}

double angleDiff(double a, double b) {
  final d = (a - b).abs() % 360;
  return d > 180 ? 360 - d : d;
}

void main() {
  test('pusula, telefon düz, eğik veya dik tutulunca gerçek yönü verir', () {
    for (final heading in [0.0, 45, 90, 151.6, 180, 270, 300]) {
      // 90 = telefon tam dik (ekran kullanıcıya dönük), 100 = dikeyi biraz geçmiş
      for (final pitch in [0.0, 30, 60, 75, 85, 90, 100]) {
        final s = sensorsFor(heading.toDouble(), pitch.toDouble());
        final result = compassHeading(s[0], s[1], s[2], s[3], s[4], s[5])!;
        expect(angleDiff(result, heading.toDouble()), lessThan(0.01),
            reason: 'yön $heading°, eğim $pitch° → $result°');
      }
    }
  });

  test('serbest düşüşte yön hesaplanmaz', () {
    expect(compassHeading(0, 0, 0, 0, 20, -40), isNull);
  });

  test('kıble açısı bilinen şehirlerle uyumlu', () {
    expect(qiblaBearing(41.0082, 28.9784), closeTo(151.6, 0.1)); // İstanbul
    expect(qiblaBearing(40.7128, -74.0060), closeTo(58.5, 0.1)); // New York
    expect(qiblaBearing(-6.2088, 106.8456), closeTo(295.15, 0.1)); // Cakarta
    expect(qiblaBearing(-33.8688, 151.2093), closeTo(277.5, 0.1)); // Sidney
  });
}
