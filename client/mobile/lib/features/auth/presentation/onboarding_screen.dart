import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/laundry_illustrations.dart';
import '../../../shared/widgets/sketch_widgets.dart';
import 'auth_controller.dart';
import 'phone_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final AuthController authController;
  final VoidCallback? onGetStarted;

  const OnboardingScreen({
    super.key,
    required this.authController,
    this.onGetStarted,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Brand Heading in handwritten display typography
              Text(
                'Fresh\nClean\nFor a\nBrighter You',
                style: AppTypography.display(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cobaltBlue,
                  height: 1.15,
                ),
              ),

              const Spacer(),

              // Hand-drawn sketch delivery person illustration
              Center(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.cobaltLight.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: LaundryIllustration(
                      type: LaundryIllustrationType.deliveryPerson,
                      size: 160,
                      strokeColor: AppColors.cobaltBlue,
                      strokeWidth: 2.2,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Page Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(0),
                  const SizedBox(width: 8),
                  _buildDot(1),
                  const SizedBox(width: 8),
                  _buildDot(2),
                ],
              ),

              const SizedBox(height: 32),

              // Get Started Button
              CobaltButton(
                text: 'Get Started  →',
                onPressed: () {
                  if (widget.onGetStarted != null) {
                    widget.onGetStarted!();
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhoneScreen(authController: widget.authController),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.cobaltBlue : AppColors.cardBorder,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
