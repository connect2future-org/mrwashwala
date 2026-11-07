import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/repositories/customer_review_repository.dart';
import 'package:mrwashwala_mobile/features/reviews/presentation/customer_review_controller.dart';

void main() {
  group('CustomerReviewController Tests', () {
    test('fetchReviews populates state on success', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'count': 1,
            'data': [
              {
                '_id': 'rev-500',
                'author': 'Tester',
                'rating': 4,
                'text': '[Order MRW-55555] Good job',
              }
            ],
          }),
          200,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = CustomerReviewRepository(apiClient: apiClient);
      final controller = CustomerReviewController(reviewRepository: repo);

      await controller.fetchReviews('valid_token');
      expect(controller.isLoading, false);
      expect(controller.hasReviews, true);
      expect(controller.reviews.length, 1);
      expect(controller.hasReviewForOrder('MRW-55555'), true);
    });

    test('submitReview rejects short review text without calling API', () async {
      final repo = CustomerReviewRepository(apiClient: ApiClient());
      final controller = CustomerReviewController(reviewRepository: repo);

      final success = await controller.submitReview(
        'valid_token',
        rating: 5,
        text: 'Bad', // less than 5 characters
      );

      expect(success, false);
      expect(controller.errorMessage, contains('must be at least 5 characters'));
    });

    test('submitReview prevents duplicate review submission for same order', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': [
              {
                '_id': 'rev-500',
                'author': 'Tester',
                'rating': 4,
                'text': '[Order MRW-55555] Good job',
              }
            ],
          }),
          200,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = CustomerReviewRepository(apiClient: apiClient);
      final controller = CustomerReviewController(reviewRepository: repo);

      await controller.fetchReviews('valid_token');
      expect(controller.hasReviewForOrder('MRW-55555'), true);

      final result = await controller.submitReview(
        'valid_token',
        rating: 5,
        text: 'Duplicate review text',
        orderId: 'MRW-55555',
      );

      expect(result, false);
      expect(controller.errorMessage, contains('already submitted a review'));
    });
  });
}
