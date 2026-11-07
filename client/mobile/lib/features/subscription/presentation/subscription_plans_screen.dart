import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/laundry_illustrations.dart';
import '../../../shared/widgets/sketch_widgets.dart';

class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surfaceWhite,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.cobaltBlue,
            size: 20,
          ),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Subscription Plans',
          style: AppTypography.display(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            children: [
              // 1. Hero Card with Sketch Illustration & Typography
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cobaltBlue.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sketch Illustration Container
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cobaltLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cobaltBorder, width: 1),
                      ),
                      child: const LaundryIllustration(
                        type: LaundryIllustrationType.calendarPlan,
                        size: 72,
                        strokeColor: AppColors.cobaltBlue,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Small COMING SOON Badge with Icon
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cobaltLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.cobaltBorder,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.card_membership_rounded,
                            size: 16,
                            color: AppColors.cobaltBlue,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'COMING SOON',
                            style: AppTypography.sans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.cobaltBlue,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Main Heading
                    Text(
                      'Subscription Plans Coming Soon',
                      textAlign: TextAlign.center,
                      style: AppTypography.display(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Supporting Message
                    Text(
                      "We're working on exciting plans for our regular customers. Stay tuned!",
                      textAlign: TextAlign.center,
                      style: AppTypography.sans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),
                    const Divider(height: 1, color: AppColors.cardBorder),
                    const SizedBox(height: 24),

                    // Informational Highlights Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cobaltSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.cobaltBorder,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 20,
                            color: AppColors.cobaltBlue,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tailored Care for Regular Laundry',
                                  style: AppTypography.sans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Scheduled doorstep pickups, professional fabric sanitization, and priority turnarounds are being designed to make your weekly laundry seamless.',
                                  style: AppTypography.sans(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
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
              ),

              const SizedBox(height: 28),

              // Notify Me Button matching Reference Screen 15
              CobaltButton(
                text: 'Notify Me',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("You're on the priority list! We'll notify you as soon as plans launch."),
                      backgroundColor: AppColors.cobaltBlue,
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Back to Previous Screen Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.cobaltBlue,
                    side: const BorderSide(color: AppColors.cobaltBlue, width: 1.5),
                    backgroundColor: AppColors.surfaceWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: Text(
                    'Back to Profile',
                    style: AppTypography.sans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
