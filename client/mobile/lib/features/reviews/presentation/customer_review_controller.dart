import 'package:flutter/foundation.dart';
import '../../../data/models/review_model.dart';
import '../../../data/repositories/customer_review_repository.dart';

class CustomerReviewController extends ChangeNotifier {
  final CustomerReviewRepository _reviewRepository;

  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasReviews => _reviews.isNotEmpty;

  CustomerReviewController({CustomerReviewRepository? reviewRepository})
      : _reviewRepository = reviewRepository ?? CustomerReviewRepository();

  /// Loads reviews for the authenticated customer.
  Future<void> fetchReviews(String? token) async {
    if (token == null || token.isEmpty) {
      _reviews = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final list = await _reviewRepository.fetchCustomerReviews(token);
      _reviews = list;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Checks if a review has already been submitted for a specific orderId.
  ReviewModel? getReviewForOrder(String? orderId) {
    if (orderId == null || orderId.trim().isEmpty) return null;
    final cleanId = orderId.trim();
    try {
      return _reviews.firstWhere(
        (r) => (r.orderId != null && r.orderId == cleanId) || r.text.contains(cleanId),
      );
    } catch (_) {
      return null;
    }
  }

  bool hasReviewForOrder(String? orderId) {
    return getReviewForOrder(orderId) != null;
  }

  /// Submits a new review.
  Future<bool> submitReview(
    String token, {
    required int rating,
    required String text,
    String? orderId,
  }) async {
    if (rating < 1 || rating > 5) {
      _errorMessage = 'Please select a rating between 1 and 5 stars';
      notifyListeners();
      return false;
    }

    if (text.trim().length < 5) {
      _errorMessage = 'Review text must be at least 5 characters long';
      notifyListeners();
      return false;
    }

    // Check client-side duplicate prevention
    if (orderId != null && hasReviewForOrder(orderId)) {
      _errorMessage = 'You have already submitted a review for this order';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final createdReview = await _reviewRepository.submitReview(
        token,
        rating: rating,
        text: text,
        orderId: orderId,
      );

      _reviews.insert(0, createdReview);
      _isSubmitting = false;
      _successMessage = 'Thank you! Your review has been submitted.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  String _cleanErrorMessage(String rawMessage) {
    return rawMessage.replaceAll('ApiException: ', '').replaceAll('Exception: ', '').trim();
  }
}
