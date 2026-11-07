import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mrwashwala_mobile/features/subscription/presentation/subscription_plans_screen.dart';

void main() {
  group('SubscriptionPlansScreen Widget Tests', () {
    Widget createTestWidget() {
      return const MaterialApp(
        home: SubscriptionPlansScreen(),
      );
    }

    testWidgets('Renders page title, heading, supporting message, and COMING SOON label',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 1. Page title
      expect(find.text('Subscription Plans'), findsOneWidget);

      // 2. Main heading
      expect(find.text('Subscription Plans Coming Soon'), findsOneWidget);

      // 3. Supporting message
      expect(
        find.text("We're working on exciting plans for our regular customers. Stay tuned!"),
        findsOneWidget,
      );

      // 4. COMING SOON label
      expect(find.text('COMING SOON'), findsOneWidget);

      // 5. App Iconography
      expect(find.byIcon(Icons.card_membership_rounded), findsOneWidget);
    });

    testWidgets('Does not display fictional plan cards, prices, or purchase buttons',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify no price amounts or currency symbols
      expect(find.textContaining('₹'), findsNothing);
      expect(find.textContaining('/month'), findsNothing);
      expect(find.textContaining('/year'), findsNothing);

      // Verify no subscription buy/purchase/subscribe buttons
      expect(find.text('Subscribe Now'), findsNothing);
      expect(find.text('Buy Plan'), findsNothing);
      expect(find.text('Purchase'), findsNothing);
      expect(find.text('Pay Now'), findsNothing);

      // Verify no countdown or fake launch dates
      expect(find.textContaining('Launching in'), findsNothing);
      expect(find.textContaining('Days Left'), findsNothing);
    });

    testWidgets('Back button pops navigation route cleanly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPlansScreen(),
                    ),
                  );
                },
                child: const Text('Open Plans'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Plans'));
      await tester.pumpAndSettle();

      expect(find.text('Subscription Plans Coming Soon'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Subscription Plans Coming Soon'), findsNothing);
      expect(find.text('Open Plans'), findsOneWidget);
    });
  });
}
