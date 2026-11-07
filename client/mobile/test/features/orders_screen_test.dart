import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/models/cart_item_model.dart';
import 'package:mrwashwala_mobile/data/models/order_model.dart';
import 'package:mrwashwala_mobile/data/repositories/customer_order_repository.dart';
import 'package:mrwashwala_mobile/features/auth/presentation/auth_controller.dart';
import 'package:mrwashwala_mobile/features/orders/presentation/customer_order_controller.dart';
import 'package:mrwashwala_mobile/features/orders/presentation/order_details_screen.dart';
import 'package:mrwashwala_mobile/features/orders/presentation/orders_screen.dart';

class FakeAuthController extends AuthController {
  final bool _mockAuth;
  final String? _mockToken;

  FakeAuthController({bool isAuthenticated = false, String? token})
      : _mockAuth = isAuthenticated,
        _mockToken = token;

  @override
  bool get isAuthenticated => _mockAuth;

  @override
  String? get token => _mockToken;
}

void main() {
  group('OrdersScreen Widget & UI Redesign Tests', () {
    final mockOrders = [
      OrderModel(
        id: 'ord_1',
        orderId: 'MRW-310222',
        status: 'Pending',
        totalAmount: 60.0,
        paymentMethod: 'Cash on Delivery',
        paymentStatus: 'Pending',
        pickupDate: '2026-10-15',
        pickupTime: '09:00 AM - 11:00 AM',
        items: [
          CartItemModel(
            serviceId: 'srv_1',
            name: 'Wash & Fold',
            price: 60.0,
            unit: 'Kg',
            quantity: 1,
          ),
        ],
      ),
      OrderModel(
        id: 'ord_2',
        orderId: 'MRW-718104',
        status: 'Cancelled',
        totalAmount: 99.0,
        paymentMethod: 'UPI',
        paymentStatus: 'Pending',
        pickupDate: '2026-08-27',
        pickupTime: '11:15',
        items: [
          CartItemModel(
            serviceId: 'srv_2',
            name: 'Dry Cleaning Silk',
            price: 99.0,
            unit: 'pcs',
            quantity: 1,
          ),
        ],
      ),
      OrderModel(
        id: 'ord_3',
        orderId: 'MRW-817630',
        status: 'Delivered',
        totalAmount: 200.0,
        paymentMethod: 'WhatsApp',
        paymentStatus: 'Paid',
        pickupDate: '2026-08-25',
        pickupTime: '19:00',
        items: [
          CartItemModel(
            serviceId: 'srv_3',
            name: 'Casual Shoe Cleaning',
            price: 200.0,
            unit: 'item',
            quantity: 1,
          ),
        ],
      ),
    ];

    CustomerOrderController createMockController({
      List<OrderModel>? orders,
    }) {
      final mockClient = MockClient((request) async {
        final list = orders ?? mockOrders;
        return http.Response(
          jsonEncode({
            'success': true,
            'count': list.length,
            'totalOrders': list.length,
            'page': 1,
            'totalPages': 1,
            'data': list.map((o) => o.toJson()).toList(),
          }),
          200,
        );
      });

      final repo = CustomerOrderRepository(apiClient: ApiClient(client: mockClient));
      final controller = CustomerOrderController(orderRepository: repo);
      return controller;
    }

    testWidgets('Renders unauthenticated state when not logged in', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OrdersScreen(
            authController: FakeAuthController(isAuthenticated: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('Sign In to View Orders'), findsOneWidget);
      expect(find.text('Sign In with Mobile OTP'), findsOneWidget);
    });

    testWidgets('Renders empty state with Explore Services button when no orders', (tester) async {
      final controller = createMockController(orders: []);
      final auth = FakeAuthController(isAuthenticated: true, token: 'valid_token');
      bool explored = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OrdersScreen(
            authController: auth,
            orderController: controller,
            onExploreServices: () {
              explored = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Orders Yet'), findsOneWidget);
      expect(find.text('Explore Services'), findsOneWidget);

      await tester.tap(find.text('Explore Services'));
      await tester.pumpAndSettle();

      expect(explored, isTrue);
    });

    testWidgets('Renders populated orders with Order ID, status badge, items preview, and total amount', (tester) async {
      final controller = createMockController();
      final auth = FakeAuthController(isAuthenticated: true, token: 'valid_token');

      await tester.pumpWidget(
        MaterialApp(
          home: OrdersScreen(
            authController: auth,
            orderController: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('3 bookings recorded'), findsOneWidget);

      // Verify Order cards and badges for visible orders
      expect(find.text('#MRW-310222'), findsOneWidget);
      expect(find.text('#MRW-718104'), findsOneWidget);
      expect(find.text('Order Placed'), findsOneWidget);
      expect(find.text('Order Cancelled'), findsOneWidget);
      expect(find.text('₹60'), findsOneWidget);
      expect(find.text('₹99'), findsOneWidget);

      // Scroll down to verify the third order
      await tester.drag(find.byType(ListView).last, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('#MRW-817630'), findsOneWidget);
      expect(find.text('Delivered & Completed'), findsOneWidget);
      expect(find.text('₹200'), findsOneWidget);

      // Verify View Details Buttons
      expect(find.text('View Details'), findsWidgets);
    });

    testWidgets('Filter chips render all options and allow switching', (tester) async {
      final controller = createMockController();
      final auth = FakeAuthController(isAuthenticated: true, token: 'valid_token');

      await tester.pumpWidget(
        MaterialApp(
          home: OrdersScreen(
            authController: auth,
            orderController: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Picked Up'), findsOneWidget);
      expect(find.text('In Process'), findsOneWidget);
      expect(find.text('Out for Delivery'), findsOneWidget);
      // Scroll horizontal filter chips to see remaining chips
      await tester.drag(find.byType(ListView).first, const Offset(-200, 0));
      await tester.pumpAndSettle();
      expect(find.text('Delivered'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);

      // Tap on Delivered chip
      await tester.tap(find.text('Delivered'));
      await tester.pumpAndSettle();

      expect(controller.selectedStatusFilter, 'Delivered');
    });

    testWidgets('Search input filters orders by query', (tester) async {
      final controller = createMockController();
      final auth = FakeAuthController(isAuthenticated: true, token: 'valid_token');

      await tester.pumpWidget(
        MaterialApp(
          home: OrdersScreen(
            authController: auth,
            orderController: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search text for 'Shoe'
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Shoe');
      await tester.pumpAndSettle();

      expect(find.text('#MRW-817630'), findsOneWidget);
      expect(find.text('#MRW-310222'), findsNothing);
      expect(find.text('#MRW-718104'), findsNothing);
    });

    testWidgets('Tapping order card navigates to OrderDetailsScreen', (tester) async {
      final controller = createMockController();
      final auth = FakeAuthController(isAuthenticated: true, token: 'valid_token');

      await tester.pumpWidget(
        MaterialApp(
          home: OrdersScreen(
            authController: auth,
            orderController: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final firstOrderCard = find.text('#MRW-310222');
      expect(firstOrderCard, findsOneWidget);

      await tester.tap(firstOrderCard);
      await tester.pumpAndSettle();

      // Should now be on OrderDetailsScreen
      expect(find.byType(OrderDetailsScreen), findsOneWidget);
      expect(find.text('Order Details'), findsOneWidget);
      expect(find.text('Order #MRW-310222'), findsWidgets);
    });
  });
}
