import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/models/order_model.dart';
import '../../../shared/widgets/laundry_illustrations.dart';
import 'order_details_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final OrderModel order;

  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final branchName = order.selectedBranch?['name'] ??
        order.selectedBranch?['branchName'] ??
        order.selectedBranch?['outletName'];

    return Scaffold(
      backgroundColor: AppColors.cobaltBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // 1. White Sketch Laundry Basket with Radiating Sparkles
              const Center(
                child: LaundryIllustration(
                  type: LaundryIllustrationType.orderSuccess,
                  size: 130,
                  strokeColor: Colors.white,
                  strokeWidth: 2.2,
                ),
              ),

              const SizedBox(height: 20),

              // 2. Handwritten Celebration Display Title
              Text(
                'Order Placed Successfully!',
                textAlign: TextAlign.center,
                style: AppTypography.display(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Thank you! Your doorstep laundry pickup has been booked with Mr. WashWala.',
                textAlign: TextAlign.center,
                style: AppTypography.sans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // 3. White Order Information Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: Order ID & Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order ID',
                              style: AppTypography.sans(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '#${order.orderId.isNotEmpty ? order.orderId : order.id}',
                              style: AppTypography.sans(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.cobaltBlue,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.cobaltLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'CONFIRMED',
                            style: AppTypography.sans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.cobaltBlue,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: 14),

                    // Metrics Grid
                    _buildDetailRow('Total Amount', '₹${order.totalAmount.toStringAsFixed(0)}', isHighlight: true),
                    const SizedBox(height: 10),
                    _buildDetailRow('Pickup Date', order.pickupDate.isNotEmpty ? order.pickupDate : 'Scheduled'),
                    const SizedBox(height: 10),
                    _buildDetailRow('Pickup Slot', order.pickupTime.isNotEmpty ? order.pickupTime : 'Standard Slot'),
                    const SizedBox(height: 10),
                    _buildDetailRow('Payment Mode', order.paymentMethod.isNotEmpty ? order.paymentMethod : 'Cash on Delivery'),

                    if (branchName != null) ...[
                      const SizedBox(height: 10),
                      _buildDetailRow('Processing Outlet', branchName),
                    ],

                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: 14),

                    // Assurance Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAssuranceItem(Icons.verified_outlined, 'Fabric Care Assured'),
                        _buildAssuranceItem(Icons.home_outlined, 'Doorstep Service'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. White Pill Track Order Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsScreen(order: order),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.cobaltBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Track Order',
                    style: AppTypography.sans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cobaltBlue,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 5. Continue Shopping Text Link
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(
                  'Continue Shopping',
                  style: AppTypography.sans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.sans(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.sans(
            fontSize: isHighlight ? 16 : 13.5,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            color: isHighlight ? AppColors.cobaltBlue : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAssuranceItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.cobaltBlue),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.sans(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
