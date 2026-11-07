import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/order_status_helper.dart';
import '../../../data/models/order_model.dart';
import '../../reviews/presentation/customer_review_controller.dart';
import '../../reviews/presentation/write_review_screen.dart';

/// Phase 9F — Premium Order Details & Tracking Screen Redesign
class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;
  final CustomerReviewController? reviewController;
  final String? token;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    this.reviewController,
    this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: AppColors.cobaltBlue,
          ),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.cobaltLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                color: AppColors.cobaltBlue,
                size: 19,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Details',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.cobaltBlue,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    order.orderId.isNotEmpty ? 'Order #${order.orderId}' : 'Order Reference',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.headset_mic_outlined,
              size: 21,
              color: AppColors.cobaltBlue,
            ),
            tooltip: 'Customer Support',
            onPressed: () => _showSupportBottomSheet(context),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.cardBorder,
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Order Summary & Status Card
              _buildSummaryHeaderCard(context),

              const SizedBox(height: 16),

              // 2. Order Tracking Timeline Card
              _buildTrackingTimelineCard(context),

              const SizedBox(height: 16),

              // 3. Customer Review Section (For Delivered Orders)
              if (reviewController != null && token != null) ...[
                _buildReviewSection(context),
                const SizedBox(height: 16),
              ],

              // 4. Ordered Services Breakdown Card
              _buildServicesBreakdownCard(),

              const SizedBox(height: 16),

              // 5. Pickup & Delivery Details Card
              _buildPickupDeliveryCard(),

              const SizedBox(height: 22),

              // 6. Action Buttons (Back to Orders & Continue Shopping)
              _buildActionButtons(context),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. Summary & Status Header Card
  // ==========================================
  Widget _buildSummaryHeaderCard(BuildContext context) {
    final statusColor = OrderStatusHelper.getStatusColor(order.status);
    final statusLabel = OrderStatusHelper.getStatusLabel(order.status);
    final statusIcon = OrderStatusHelper.getStatusIcon(order.status);
    final isPaid = order.paymentStatus.toLowerCase() == 'paid';
    final paymentStatusColor = isPaid ? AppColors.successGreen : AppColors.warningOrange;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Order ID reference + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Order ID + Copy icon
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () {
                  if (order.orderId.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: order.orderId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Order ID #${order.orderId} copied'),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        order.orderId.isNotEmpty ? 'Order #${order.orderId}' : 'Order Reference',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cobaltBlue,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.copy_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),

              // Current Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 5),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          ),

          // Row 2: Dual Metric Cards (Total Amount & Order Date)
          Row(
            children: [
              // Metric 1: Total Amount
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.cobaltLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.skyBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Payable',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        order.formattedTotal,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cobaltBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Metric 2: Order Date
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Placed Date',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        order.formattedCreatedDate.isNotEmpty
                            ? order.formattedCreatedDate
                            : 'Confirmed',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cobaltBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Row 3: Payment details
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      order.paymentMethod.isNotEmpty ? order.paymentMethod : 'Cash on Delivery',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cobaltBlue,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: paymentStatusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPaid ? Icons.check_circle_rounded : Icons.schedule_rounded,
                        size: 11,
                        color: paymentStatusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.paymentStatus.isNotEmpty ? order.paymentStatus : 'Pending',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: paymentStatusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. Order Tracking Timeline Component
  // ==========================================
  Widget _buildTrackingTimelineCard(BuildContext context) {
    if (order.status == 'Cancelled') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cancel_rounded, color: AppColors.errorRed, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Cancelled',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.errorRed,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'This order has been cancelled and will not be processed.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Color(0xFFFEE2E2)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Need assistance or refund query?',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
                TextButton(
                  onPressed: () => _showSupportBottomSheet(context),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppColors.cobaltBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text(
                    'Contact Support',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final currentStepIndex = OrderStatusHelper.getStatusStepIndex(order.status);
    final trackingSteps = OrderStatusHelper.trackingSteps;

    final stepDescriptions = [
      'Order request confirmed & assigned for pickup',
      'Laundry collected safely from your doorstep',
      'Washing, sorting & fabric care underway',
      'Fresh clothes packaged & out on the delivery route',
      'Order delivered safely to your doorstep',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.cobaltLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  size: 18,
                  color: AppColors.cobaltBlue,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Progress Tracking',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cobaltBlue,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Real-time status updates from processing facility',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Vertical timeline list
          ...List.generate(trackingSteps.length, (index) {
            final stepKey = trackingSteps[index];
            final stepLabel = OrderStatusHelper.getStatusLabel(stepKey);
            final stepDesc = index < stepDescriptions.length ? stepDescriptions[index] : '';
            final isCompleted = index <= currentStepIndex;
            final isCurrent = index == currentStepIndex;
            final isLast = index == trackingSteps.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step Indicator + Vertical Line
                  SizedBox(
                    width: 32,
                    child: Column(
                      children: [
                        // Circle Indicator
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent
                                ? AppColors.cobaltBlue
                                : (isCompleted ? AppColors.successGreen : const Color(0xFFF1F5F9)),
                            border: Border.all(
                              color: isCurrent
                                  ? AppColors.skyBlue
                                  : (isCompleted ? AppColors.successGreen : AppColors.cardBorder),
                              width: isCurrent ? 2 : 1,
                            ),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: AppColors.skyBlue.withValues(alpha: 0.4),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Icon(
                              isCompleted
                                  ? Icons.check_rounded
                                  : (isCurrent ? Icons.circle : Icons.circle_outlined),
                              size: isCompleted ? 14 : 9,
                              color: isCompleted
                                  ? Colors.white
                                  : (isCurrent ? Colors.white : const Color(0xFF94A3B8)),
                            ),
                          ),
                        ),

                        // Vertical connecting line
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2.5,
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              decoration: BoxDecoration(
                                color: isCompleted && !isCurrent
                                    ? AppColors.successGreen
                                    : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Step Content
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                stepLabel,
                                style: TextStyle(
                                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                                  fontSize: 13.5,
                                  color: isCompleted
                                      ? AppColors.cobaltBlue
                                      : AppColors.textSecondary.withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isCurrent)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.cobaltBlue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'CURRENT STATUS',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              if (isCompleted && !isCurrent)
                                const Text(
                                  '✓ Completed',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.successGreen,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            stepDesc,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isCurrent
                                  ? AppColors.cobaltBlue.withValues(alpha: 0.8)
                                  : AppColors.textSecondary,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // 3. Customer Review Section (Delivered Orders)
  // ==========================================
  Widget _buildReviewSection(BuildContext context) {
    if (order.status != 'Delivered') {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.textSecondary, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Reviews can be submitted once your order is Delivered.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return ListenableBuilder(
      listenable: reviewController!,
      builder: (context, _) {
        final existingReview = reviewController!.getReviewForOrder(order.orderId);

        if (existingReview != null) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cobaltBlue.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.rate_review, color: AppColors.cobaltBlue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Your Review',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.cobaltBlue,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < existingReview.rating ? Icons.star : Icons.star_border,
                          size: 16,
                          color: i < existingReview.rating ? Colors.amber : Colors.grey.shade300,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  existingReview.displayText,
                  style: const TextStyle(fontSize: 13, color: AppColors.cobaltBlue),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rate Your Laundry Experience',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.cobaltBlue),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your feedback helps us maintain top washing quality.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WriteReviewScreen(
                          reviewController: reviewController!,
                          token: token!,
                          order: order,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.star_outline),
                  label: const Text('Write a Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cobaltBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // 4. Ordered Services Breakdown Card
  // ==========================================
  Widget _buildServicesBreakdownCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.cobaltLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 18,
                      color: AppColors.cobaltBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Ordered Services',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.cobaltBlue,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.cobaltLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${order.items.length} ${order.items.length == 1 ? "Service" : "Services"}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cobaltBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (order.items.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: const Text(
                'No item breakdown available for this order.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            )
          else ...[
            ...order.items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Icon(
                        Icons.local_laundry_service_outlined,
                        size: 18,
                        color: AppColors.cobaltBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cobaltBlue,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${item.quantity} ${item.unit} × ₹${item.price.toInt() == item.price ? item.price.toInt() : item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (item.stainRemoval) ...[
                            const SizedBox(height: 4),
                            const Row(
                              children: [
                                Icon(Icons.auto_fix_high_rounded, size: 12, color: AppColors.cobaltBlue),
                                SizedBox(width: 4),
                                Text(
                                  'Stain Removal add-on',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.cobaltBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (item.premiumClean) ...[
                            const SizedBox(height: 4),
                            const Row(
                              children: [
                                Icon(Icons.verified_rounded, size: 12, color: AppColors.cobaltBlue),
                                SizedBox(width: 4),
                                Text(
                                  'Premium Fabric Care add-on',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.cobaltBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      item.formattedLineTotal,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cobaltBlue,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const Divider(height: 16, thickness: 1, color: Color(0xFFF1F5F9)),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Payable Sum',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cobaltBlue,
                  ),
                ),
                Text(
                  order.formattedTotal,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.cobaltBlue,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // 5. Pickup & Delivery Details Card
  // ==========================================
  Widget _buildPickupDeliveryCard() {
    final customerAddress = order.customer != null &&
            order.customer!['address'] != null &&
            order.customer!['address'].toString().trim().isNotEmpty
        ? order.customer!['address'].toString().trim()
        : null;

    final customerName = order.customer?['name']?.toString().trim();
    final customerPhone = order.customer?['phone']?.toString().trim();

    final branchName = order.selectedBranch != null &&
            order.selectedBranch!['name'] != null &&
            order.selectedBranch!['name'].toString().trim().isNotEmpty
        ? order.selectedBranch!['name'].toString().trim()
        : null;

    final instructions = order.customer != null &&
            order.customer!['instructions'] != null &&
            order.customer!['instructions'].toString().trim().isNotEmpty
        ? order.customer!['instructions'].toString().trim()
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.cobaltLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  size: 18,
                  color: AppColors.cobaltBlue,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Pickup & Delivery Details',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.cobaltBlue,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Pickup Schedule
          if (order.pickupDate.isNotEmpty)
            _buildDetailRow(
              icon: Icons.calendar_month_rounded,
              label: 'Pickup Date',
              value: order.pickupDate,
            ),

          if (order.pickupTime.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.alarm_rounded,
              label: 'Pickup Time Slot',
              value: order.pickupTime,
            ),
          ],

          // Delivery Schedule (if confirmed)
          if (order.deliveryDate.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.event_available_rounded,
              label: 'Target Delivery Date',
              value: order.deliveryDate,
            ),
          ],

          // Assigned Branch Outlet
          if (branchName != null) ...[
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.storefront_outlined,
              label: 'Processing Outlet',
              value: branchName,
            ),
          ],

          // Delivery Address
          if (customerAddress != null) ...[
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.location_on_outlined,
              label: 'Delivery Address',
              value: customerAddress,
            ),
          ],

          // Customer Phone/Contact
          if (customerPhone != null && customerPhone.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.phone_outlined,
              label: 'Customer Phone',
              value: customerName != null && customerName.isNotEmpty
                  ? '$customerName ($customerPhone)'
                  : customerPhone,
            ),
          ],

          // Special Instructions
          if (instructions != null) ...[
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.notes_rounded,
              label: 'Instructions',
              value: instructions,
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // 6. Action Buttons
  // ==========================================
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary Action: Back to Orders
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text(
              'Back to Orders',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cobaltBlue,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Secondary Action: Continue Shopping
        SizedBox(
          height: 46,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.shopping_bag_outlined, size: 17),
            label: const Text(
              'Continue Shopping',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.cobaltBlue,
              side: const BorderSide(color: AppColors.cobaltBlue, width: 1.3),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Support Link
        Center(
          child: TextButton.icon(
            onPressed: () => _showSupportBottomSheet(context),
            icon: const Icon(
              Icons.headset_mic_outlined,
              size: 16,
              color: AppColors.cobaltBlue,
            ),
            label: const Text(
              'Need Help with this Order? Contact Support',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.cobaltBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // Helper: Detail Row with Icon & Text
  // ==========================================
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.cobaltBlue,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // Support Bottom Sheet Dialog
  // ==========================================
  void _showSupportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.cobaltLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.headset_mic_rounded,
                        color: AppColors.cobaltBlue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mr. WashWala Support',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.cobaltBlue,
                            ),
                          ),
                          Text(
                            'Mysuru Doorstep Laundry Assistance',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Order Reference Reminder
                if (order.orderId.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cobaltLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long_rounded, size: 15, color: AppColors.cobaltBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Order Reference: #${order.orderId}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cobaltBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 14),

                // Contact Option 1: Phone / WhatsApp
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 18, color: AppColors.cobaltBlue),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phone / WhatsApp Support',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              AppConstants.supportPhone,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.cobaltBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.cobaltBlue),
                        tooltip: 'Copy Phone',
                        onPressed: () {
                          Clipboard.setData(const ClipboardData(text: AppConstants.supportPhone));
                          Navigator.of(sheetContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Support phone copied: ${AppConstants.supportPhone}'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Contact Option 2: Email
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 18, color: AppColors.cobaltBlue),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email Support',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              AppConstants.supportEmail,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.cobaltBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.cobaltBlue),
                        tooltip: 'Copy Email',
                        onPressed: () {
                          Clipboard.setData(const ClipboardData(text: AppConstants.supportEmail));
                          Navigator.of(sheetContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Support email copied: ${AppConstants.supportEmail}'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Working Hours
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                      SizedBox(width: 6),
                      Text(
                        'Operating Hours: Mon - Sun (8:00 AM - 8:00 PM)',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.cobaltBlue,
                      side: const BorderSide(color: AppColors.cardBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
