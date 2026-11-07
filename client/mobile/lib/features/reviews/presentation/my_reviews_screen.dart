import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/review_model.dart';
import 'customer_review_controller.dart';
import 'write_review_screen.dart';

class MyReviewsScreen extends StatefulWidget {
  final CustomerReviewController reviewController;
  final String token;
  final VoidCallback? onExploreServices;

  const MyReviewsScreen({
    super.key,
    required this.reviewController,
    required this.token,
    this.onExploreServices,
  });

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.reviewController.fetchReviews(widget.token);
    });
  }

  void _openWriteReview() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WriteReviewScreen(
          reviewController: widget.reviewController,
          token: widget.token,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('My Reviews'),
        actions: [
          IconButton(
            icon: const Icon(Icons.rate_review_outlined),
            tooltip: 'Write a Review',
            onPressed: _openWriteReview,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openWriteReview,
        backgroundColor: AppColors.primaryNavy,
        icon: const Icon(Icons.star_outline, color: Colors.white),
        label: const Text('Write a Review', style: TextStyle(color: Colors.white)),
      ),
      body: ListenableBuilder(
        listenable: widget.reviewController,
        builder: (context, _) {
          final ctrl = widget.reviewController;

          if (ctrl.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (ctrl.errorMessage != null && !ctrl.hasReviews) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.errorRed),
                    const SizedBox(height: 12),
                    Text(
                      ctrl.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ctrl.fetchReviews(widget.token),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!ctrl.hasReviews) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.iceBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star_half, size: 48, color: AppColors.primaryNavy),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Reviews Yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "You haven't reviewed any laundry services yet. Share your experience after receiving your delivered order.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _openWriteReview,
                      icon: const Icon(Icons.rate_review),
                      label: const Text('Write a Review'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ctrl.fetchReviews(widget.token),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppConstants.defaultPadding).copyWith(bottom: 80),
              itemCount: ctrl.reviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final review = ctrl.reviews[index];
                return _buildReviewCard(review);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Rating Stars
              Row(
                children: List.generate(5, (starIndex) {
                  return Icon(
                    starIndex < review.rating ? Icons.star : Icons.star_border,
                    size: 18,
                    color: starIndex < review.rating ? Colors.amber : Colors.grey.shade300,
                  );
                }),
              ),

              Text(
                review.formattedDate,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Order Badge if present
          if (review.orderId != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Order #${review.orderId}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
            ),
          ],

          // Review Text
          Text(
            review.displayText,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppColors.primaryNavy,
            ),
          ),

          if (review.branchName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.storefront, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  review.branchName!,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
