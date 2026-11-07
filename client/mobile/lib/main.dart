import 'package:flutter/material.dart';
import 'app/theme/app_colors.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/app_typography.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/phone_screen.dart';
import 'shared/widgets/laundry_illustrations.dart';
import 'shared/widgets/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MrWashWalaApp());
}

class MrWashWalaApp extends StatefulWidget {
  const MrWashWalaApp({super.key});

  @override
  State<MrWashWalaApp> createState() => _MrWashWalaAppState();
}

class _MrWashWalaAppState extends State<MrWashWalaApp> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
    _authController.checkAuthStatus();
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: ListenableBuilder(
        listenable: _authController,
        builder: (context, child) {
          if (_authController.status == AuthStatus.uninitialized) {
            return const AnimatedSplashScreen();
          }

          if (_authController.isAuthenticated) {
            return MainNavigationScreen(authController: _authController);
          } else {
            return PhoneScreen(authController: _authController);
          }
        },
      ),
    );
  }
}

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cobaltBlue,
      body: Stack(
        children: [
          // Subtle background decorative floating bubbles
          ...List.generate(6, (index) {
            final randomX = 0.15 + (index * 0.15);
            final randomY = 0.10 + ((index * 37) % 70) * 0.01;
            final bubbleSize = 16.0 + (index % 3) * 12.0;
            return Positioned(
              left: MediaQuery.of(context).size.width * randomX,
              top: MediaQuery.of(context).size.height * randomY,
              child: Opacity(
                opacity: 0.18,
                child: Container(
                  width: bubbleSize,
                  height: bubbleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            );
          }),

          // Center illustration & branding
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Sketch Washing Machine Illustration
                        const LaundryIllustration(
                          type: LaundryIllustrationType.washingMachine,
                          size: 150,
                          strokeColor: Colors.white,
                          strokeWidth: 2.2,
                        ),
                        const SizedBox(height: 28),

                        // Official Brand Typography
                        Text(
                          'Mr. WashWala',
                          style: AppTypography.display(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Clean Clothes • Happier Days',
                          style: AppTypography.sans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Elegant subtle loader
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
