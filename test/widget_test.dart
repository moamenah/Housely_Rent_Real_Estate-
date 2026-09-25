import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housely/core/widgets/error_view.dart';

void main() {
  group('ErrorView', () {
    testWidgets('renders the failure message and invokes the retry callback',
        (tester) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'No internet connection.',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('No internet connection.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);
    });

    testWidgets('hides the retry action when no callback is given',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ErrorView(message: 'Broken')),
        ),
      );

      expect(find.text('Try again'), findsNothing);
    });
  });
}
