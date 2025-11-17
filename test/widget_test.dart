// test/widget_test.dart

import 'package:ezan_hatirlatici/main.dart';
import 'package:ezan_hatirlatici/services/ad_service.dart'; // ✅ EKLEDİM
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart'; // ✅ EKLEDİM

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AdService?>.value(value: null), // Test için null
        ],
        child: const PrayerTimeApp(),
      ),
    );

    // Uygulamanın başladığını doğrula
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Namaz Vatki'), findsOneWidget);
  });
}