import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/repositories/customer_review_repository.dart';

void main() {
  group('CustomerReviewRepository Tests', () {
    test('fetchCustomerReviews returns list of ReviewModel on 200 OK', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.headers['Authorization'], 'Bearer mock_token');
        return http.Response(
          jsonEncode({
            'success': true,
            'count': 1,
            'data': [
              {
                '_id': 'review-101',
                'author': 'Ajay Kumar',
                'rating': 5,
                'text': '[Order MRW-100200] Great laundry service!',
                'approved': true,
                'reviewDate': '2026-10-08T10:00:00.000Z',
              }
            ],
          }),
          200,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = CustomerReviewRepository(apiClient: apiClient);

      final reviews = await repo.fetchCustomerReviews('mock_token');
      expect(reviews.length, 1);
      expect(reviews.first.id, 'review-101');
      expect(reviews.first.rating, 5);
      expect(reviews.first.orderId, 'MRW-100200');
      expect(reviews.first.displayText, 'Great laundry service!');
    });

    test('submitReview sends POST request and parses returned ReviewModel', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.headers['Authorization'], 'Bearer mock_token');
        final body = jsonDecode(request.body);
        expect(body['rating'], 5);
        expect(body['text'], 'Super fast delivery and clean clothes');
        expect(body['orderId'], 'MRW-100200');

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Review submitted successfully',
            'data': {
              '_id': 'review-102',
              'author': 'Ajay Kumar',
              'rating': 5,
              'text': '[Order MRW-100200] Super fast delivery and clean clothes',
              'approved': true,
            },
          }),
          201,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = CustomerReviewRepository(apiClient: apiClient);

      final review = await repo.submitReview(
        'mock_token',
        rating: 5,
        text: 'Super fast delivery and clean clothes',
        orderId: 'MRW-100200',
      );
      expect(review.id, 'review-102');
      expect(review.rating, 5);
      expect(review.orderId, 'MRW-100200');
    });
  });
}
