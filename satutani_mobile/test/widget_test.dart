import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:satutani_mobile/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SatuTaniApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
