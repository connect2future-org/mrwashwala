import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mrwashwala_mobile/data/models/order_model.dart';
import 'package:mrwashwala_mobile/features/orders/presentation/order_details_screen.dart';
import 'package:mrwashwala_mobile/features/orders/presentation/order_success_screen.dart';

void main() {
  group('OrderSuccessScreen Widget & UI Redesign Tests', () {
    final testOrder = OrderModel(
      id: 'ord_mock_123',
      orderId: 'MRW-10492',
      status: 'Pending',
      totalAmount: 118.0,
      paymentMethod: 'Cash on Delivery',
      pickupDate: '2026-10-15',
      pickupTime: '11:00 AM - 01:00 PM',
      selectedBranch: {
        'id': 'vijaynagar-mysuru',
        'name': 'Vijaynagar Outlet, Mysuru',
      },
    );

    testWidgets('Renders success celebration, actual order details, and action buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OrderSuccessScreen(order: testOrder),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Headings
      expect(find.text('Order Placed Successfully!'), findsOneWidget);
      expect(
        find.text('Thank you! Your doorstep laundry pickup has been booked with Mr. WashWala.'),
        findsOneWidget,
      );

      // Verify Status badge
      expect(find.text('CONFIRMED'), findsOneWidget);

      // Verify Actual Order Metrics
      expect(find.text('#MRW-10492'), findsOneWidget);
      expect(find.text('₹118'), findsOneWidget);
      expect(find.text('2026-10-15'), findsOneWidget);
      expect(find.text('11:00 AM - 01:00 PM'), findsOneWidget);
      expect(find.text('Cash on Delivery'), findsOneWidget);
      expect(find.text('Vijaynagar Outlet, Mysuru'), findsOneWidget);

      // Verify Assurance badges
      expect(find.text('Fabric Care Assured'), findsOneWidget);
      expect(find.text('Doorstep Service'), findsOneWidget);

      // Verify Buttons
      expect(find.text('Track Order'), findsOneWidget);
      expect(find.text('Continue Shopping'), findsOneWidget);
    });

    testWidgets('Handles missing optional order fields gracefully', (tester) async {
      final minimalOrder = OrderModel(
        id: 'ord_min_456',
        orderId: 'MRW-MINIMAL',
        status: 'Pending',
        totalAmount: 59.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: OrderSuccessScreen(order: minimalOrder),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('#MRW-MINIMAL'), findsOneWidget);
      expect(find.text('₹59'), findsOneWidget);
      expect(find.text('Scheduled'), findsOneWidget);
      expect(find.text('Standard Slot'), findsOneWidget);
      expect(find.text('Processing Outlet'), findsNothing);
    });

    testWidgets('Track Order button navigates to OrderDetailsScreen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OrderSuccessScreen(order: testOrder),
        ),
      );
      await tester.pumpAndSettle();

      final trackButton = find.text('Track Order');
      expect(trackButton, findsOneWidget);
      await tester.ensureVisible(trackButton);
      await tester.pumpAndSettle();
      await tester.tap(trackButton);
      await tester.pumpAndSettle();

      // Should now be on OrderDetailsScreen
      expect(find.byType(OrderDetailsScreen), findsOneWidget);
      expect(find.text('Order Progress Tracking'), findsOneWidget);
      expect(find.text('Order #MRW-10492'), findsWidgets);
    });

    testWidgets('Continue Shopping button pops back to root', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (context) => const Scaffold(body: Text('Home Screen Root')),
            '/success': (context) => OrderSuccessScreen(order: testOrder),
          },
          initialRoute: '/',
        ),
      );
      await tester.pumpAndSettle();

      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.pushNamed('/success');
      await tester.pumpAndSettle();

      expect(find.text('Order Placed Successfully!'), findsOneWidget);

      final continueButton = find.text('Continue Shopping');
      expect(continueButton, findsOneWidget);
      await tester.ensureVisible(continueButton);
      await tester.pumpAndSettle();
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      expect(find.text('Home Screen Root'), findsOneWidget);
    });
  });
}
