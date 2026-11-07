import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../models/review_model.dart';

class CustomerReviewRepository {
  final ApiClient _apiClient;

  CustomerReviewRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches all reviews submitted by the authenticated customer.
  Future<List<ReviewModel>> fetchCustomerReviews(String token) async {
    final response = await _apiClient.get(
      ApiConfig.reviews,
      token: token,
    );

    if (response is Map<String, dynamic> && response['data'] is List) {
      final rawList = response['data'] as List;
      return rawList
          .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Unexpected response format when fetching customer reviews');
  }

  /// Submits a new review for an order or general service feedback.
  Future<ReviewModel> submitReview(
    String token, {
    required int rating,
    required String text,
    String? orderId,
  }) async {
    final body = <String, dynamic>{
      'rating': rating,
      'text': text.trim(),
    };
    if (orderId != null && orderId.trim().isNotEmpty) {
      body['orderId'] = orderId.trim();
    }

    final response = await _apiClient.post(
      ApiConfig.reviews,
      token: token,
      body: body,
    );

    if (response is Map<String, dynamic> && response['data'] != null) {
      return ReviewModel.fromJson(response['data'] as Map<String, dynamic>);
    }

    throw Exception('Unexpected response format when submitting review');
  }
}
