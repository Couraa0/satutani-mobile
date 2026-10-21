import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:satutani_mobile/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      DevicePreview(
        enabled: false,
        builder: (_) => const SatuTaniApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
    // Habiskan timer delay flutter_animate di splash (maks 700 ms); timer
    // navigasi 3 detik dibatalkan SplashScreen.dispose().
    await tester.pump(const Duration(seconds: 1));
  });
}
