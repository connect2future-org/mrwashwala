import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mrwashwala_mobile/core/constants/app_constants.dart';
import 'package:mrwashwala_mobile/data/models/cart_item_model.dart';
import 'package:mrwashwala_mobile/data/models/order_model.dart';
import 'package:mrwashwala_mobile/features/orders/presentation/order_details_screen.dart';

void main() {
  group('OrderDetailsScreen Widget & UI Redesign Tests', () {
    final testOrder = OrderModel(
      id: 'ord_test_001',
      orderId: 'MRW-98765',
      status: 'In Process',
      totalAmount: 180.0,
      paymentMethod: 'Cash on Delivery',
      paymentStatus: 'Pending',
      pickupDate: '2026-10-15',
      pickupTime: '09:00 AM - 11:00 AM',
      deliveryDate: '2026-10-17',
      selectedBranch: {
        'id': 'gokulam-branch',
        'name': 'Gokulam 3rd Stage Branch, Mysuru',
      },
      customer: {
        'name': 'Ajay Kumar',
        'phone': '9876543210',
        'address': 'Plot 42, Gokulam 3rd Stage, Mysuru',
        'instructions': 'Please ring the doorbell twice',
      },
      items: [
        CartItemModel(
          serviceId: 'srv_1',
          name: 'Wash & Fold Premium',
          price: 60.0,
          unit: 'kg',
          quantity: 2,
          stainRemoval: true,
        ),
        CartItemModel(
          serviceId: 'srv_2',
          name: 'Dry Cleaning Suit',
          price: 60.0,
          unit: 'pcs',
          quantity: 1,
        ),
      ],
    );

    testWidgets('Renders Order Details header, order reference, status badge, and dual metrics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OrderDetailsScreen(order: testOrder),
        ),
      );
      await tester.pumpAndSettle();

      // Header AppBar
      expect(find.text('Order Details'), findsOneWidget);
      expect(find.text('Order #MRW-98765'), findsWidgets);

      // Status Badge
      expect(find.text('Cleaning In Process'), findsWidgets);

      // Metrics
      expect(find.text('Total Payable'), findsOneWidget);
      expect(find.text('₹180'), findsWidgets);
      expect(find.text('Cash on Delivery'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('Renders vertical Order Progress Tracking timeline with current status on active step', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OrderDetailsScreen(order: testOrder),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Order Progress Tracking'), findsOneWidget);
      expect(find.text('Order Placed'), findsOneWidget);
      expect(find.text('Picked Up'), findsOneWidget);
      expect(find.text('Cleaning In Process'), findsWidgets);
      expect(find.text('Out for Delivery'), findsOneWidget);
      expect(find.text('Delivered & Completed'), findsOneWidget);

      // Current active step pill badge
      expect(find.text('CURRENT STATUS'), findsOneWidget);
      expect(find.text('✓ Completed'), findsWidgets);
    });

    testWidgets('Renders ordered service items and bill sum breakdown', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OrderDetailsScreen(order: testOrder),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ordered Services'), findsOneWidget);
      expect(find.text('2 Services'), findsOneWidget);
      expect(find.text('Wash & Fold Premium'), findsOneWidget);
      expect(find.text('Dry Cleaning Suit'), findsOneWidget);
      expect(find.text('Stain Removal add-on'), findsOneWidget);
      expect(find.text('Total Payable Sum'), findsOneWidget);
    });

    testWidgets('Renders pickup, delivery schedule, outlet, and customer address details', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OrderDetailsScreen(order: testOrder),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pickup & Delivery Details'), findsOneWidget);
      expect(find.text('2026-10-15'), findsOneWidget);
      expect(find.text('09:00 AM - 11:00 AM'), findsOneWidget);
      expect(find.text('2026-10-17'), findsOneWidget);
      expect(find.text('Gokulam 3rd Stage Branch, Mysuru'), findsOneWidget);
      expect(find.text('Plot 42, Gokulam 3rd Stage, Mysuru'), findsOneWidget);
      expect(find.text('Ajay Kumar (9876543210)'), findsOneWidget);
      expect(find.text('Please ring the doorbell twice'), findsOneWidget);
    });

    testWidgets('Renders specialized cancellation card when order is cancelled', (tester) async {
      final cancelledOrder = OrderModel(
        id: 'ord_cancelled',
        orderId: 'MRW-CANCELLED',
        status: 'Cancelled',
        totalAmount: 100.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: OrderDetailsScreen(order: cancelledOrder),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Order Cancelled'), findsWidgets);
      expect(find.text('This order has been cancelled and will not be processed.'), findsOneWidget);
      expect(find.text('Order Progress Tracking'), findsNothing);
    });

    testWidgets('Gracefully handles minimal order data without crash', (tester) async {
      final minimalOrder = OrderModel(
        id: 'ord_min',
        orderId: 'MRW-EMPTY',
        status: 'Pending',
        totalAmount: 50.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: OrderDetailsScreen(order: minimalOrder),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Order #MRW-EMPTY'), findsWidgets);
      expect(find.text('₹50'), findsWidgets);
      expect(find.text('No item breakdown available for this order.'), findsOneWidget);
    });

    testWidgets('Action buttons exist and Support Bottom Sheet opens with verified contact details', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OrderDetailsScreen(order: testOrder),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Back to Orders'), findsOneWidget);
      expect(find.text('Continue Shopping'), findsOneWidget);

      final supportButton = find.text('Need Help with this Order? Contact Support');
      expect(supportButton, findsOneWidget);
      await tester.ensureVisible(supportButton);
      await tester.pumpAndSettle();
      await tester.tap(supportButton);
      await tester.pumpAndSettle();

      // Verify Modal Support Sheet content
      expect(find.text('Mr. WashWala Support'), findsOneWidget);
      expect(find.text(AppConstants.supportPhone), findsOneWidget);
      expect(find.text(AppConstants.supportEmail), findsOneWidget);
      expect(find.text('Order Reference: #MRW-98765'), findsOneWidget);
    });
  });
}
