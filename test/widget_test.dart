import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/data/repositories/auth_repository.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final authRepo = AuthRepository();
    await tester.pumpWidget(FitnessTrackerApp(authRepository: authRepo));

    // Verify that our app starts.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
