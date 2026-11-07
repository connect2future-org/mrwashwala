import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/repositories/customer_review_repository.dart';
import 'package:mrwashwala_mobile/features/reviews/presentation/customer_review_controller.dart';
import 'package:mrwashwala_mobile/features/reviews/presentation/my_reviews_screen.dart';

void main() {
  group('MyReviewsScreen Widget Tests', () {
    testWidgets('Renders empty state when customer has no reviews', (tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'success': true, 'count': 0, 'data': []}),
          200,
        );
      });

      final controller = CustomerReviewController(
        reviewRepository: CustomerReviewRepository(apiClient: ApiClient(client: mockClient)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MyReviewsScreen(
            reviewController: controller,
            token: 'test_token',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('My Reviews'), findsOneWidget);
      expect(find.text('No Reviews Yet'), findsOneWidget);
      expect(find.text('Write a Review'), findsWidgets);
    });

    testWidgets('Renders reviews list with rating stars and comment', (tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'count': 1,
            'data': [
              {
                '_id': 'rev-101',
                'author': 'Ajay',
                'rating': 5,
                'text': '[Order MRW-99999] Excellent washing and prompt doorstep delivery!',
                'createdAt': '2026-10-10T10:00:00.000Z',
              }
            ],
          }),
          200,
        );
      });

      final controller = CustomerReviewController(
        reviewRepository: CustomerReviewRepository(apiClient: ApiClient(client: mockClient)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MyReviewsScreen(
            reviewController: controller,
            token: 'test_token',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Order #MRW-99999'), findsOneWidget);
      expect(find.text('Excellent washing and prompt doorstep delivery!'), findsOneWidget);
    });
  });
}
