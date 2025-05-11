import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laporin_final/main.dart';

void main() {
  testWidgets('App shows Lapor.in text and Mulai button', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(LaporInApp());

    // Verify that the app name text is present.
    expect(find.text('Lapor.in'), findsWidgets);

    // Navigate to HomePage by waiting for splash delay.
    await tester.pumpAndSettle(Duration(seconds: 3));

    // Verify that the "Mulai" button is present.
    expect(find.text('Mulai'), findsOneWidget);
  });
}
