import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/models/order_model.dart';
import 'package:mrwashwala_mobile/data/models/cart_item_model.dart';
import 'package:mrwashwala_mobile/data/repositories/customer_review_repository.dart';
import 'package:mrwashwala_mobile/features/reviews/presentation/customer_review_controller.dart';
import 'package:mrwashwala_mobile/features/reviews/presentation/write_review_screen.dart';

void main() {
  group('WriteReviewScreen Widget Tests', () {
    late CustomerReviewController controller;

    setUp(() {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'success': true, 'data': {}}), 200);
      });
      controller = CustomerReviewController(
        reviewRepository: CustomerReviewRepository(apiClient: ApiClient(client: mockClient)),
      );
    });

    testWidgets('Renders star selector, label, and validates input length', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WriteReviewScreen(
            reviewController: controller,
            token: 'test_token',
          ),
        ),
      );

      expect(find.text('Write a Review'), findsOneWidget);
      expect(find.text('Your Overall Rating *'), findsOneWidget);
      expect(find.text('5 / 5 - Excellent'), findsOneWidget);
      expect(find.text('Submit Review'), findsOneWidget);

      // Tap submit with empty review text
      await tester.tap(find.text('Submit Review'));
      await tester.pumpAndSettle();

      expect(find.text('Please write your review feedback'), findsOneWidget);
    });

    testWidgets('Renders order header banner when review is linked to an order', (tester) async {
      final testOrder = OrderModel(
        id: 'ord-123',
        orderId: 'MRW-7788',
        totalAmount: 350.0,
        status: 'Delivered',
        createdAt: DateTime.now(),
        items: [
          CartItemModel(serviceId: 'wf', name: 'Wash & Fold', quantity: 3, price: 59.0, unit: 'kg'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: WriteReviewScreen(
            reviewController: controller,
            token: 'test_token',
            order: testOrder,
          ),
        ),
      );

      expect(find.text('Review Order #MRW-7788'), findsOneWidget);
      expect(find.text('Order #MRW-7788'), findsOneWidget);
      expect(find.text('1 Service(s) • Total: ₹350'), findsOneWidget);
    });
  });
}
