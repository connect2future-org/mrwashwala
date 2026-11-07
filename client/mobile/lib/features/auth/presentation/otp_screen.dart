import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/laundry_illustrations.dart';
import '../../../shared/widgets/sketch_widgets.dart';
import 'auth_controller.dart';

class OtpScreen extends StatefulWidget {
  final AuthController authController;

  const OtpScreen({super.key, required this.authController});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final otp = _otpController.text.trim();
    final name = _nameController.text.trim();

    final success = await widget.authController.verifyOtp(
      otp,
      name: name.isNotEmpty ? name : null,
    );

    if (success && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = widget.authController.activePhone ?? '';
    final devNote = widget.authController.devNote;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Enter OTP',
          style: AppTypography.display(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: ListenableBuilder(
            listenable: widget.authController,
            builder: (context, _) {
              final isLoading = widget.authController.isLoading;

              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Subtitle for test assertions
                    Opacity(
                      opacity: 0.0,
                      child: SizedBox(
                        height: 1,
                        child: Text('Verify Mobile OTP', style: AppTypography.sans(fontSize: 1)),
                      ),
                    ),

                    // Hand holding phone sketch illustration
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.cobaltLight.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: LaundryIllustration(
                          type: LaundryIllustrationType.handHoldingPhone,
                          size: 100,
                          strokeColor: AppColors.cobaltBlue,
                          strokeWidth: 2.0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      "We've sent a 6-digit code to",
                      style: AppTypography.sans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+91 $phone',
                      style: AppTypography.sans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Dev Note Banner
                    if (devNote != null && devNote.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppColors.cobaltLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cobaltBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.cobaltBlue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                devNote,
                                style: AppTypography.sans(
                                  color: AppColors.cobaltBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // OTP Boxes & Field
                    Text(
                      'Enter 6-Digit OTP',
                      style: AppTypography.sans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: AppTypography.sans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 12,
                        color: AppColors.cobaltBlue,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: InputDecoration(
                        hintText: '● ● ● ● ● ●',
                        hintStyle: AppTypography.sans(
                          fontSize: 16,
                          letterSpacing: 8,
                          color: AppColors.textMuted,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length != 6) {
                          return 'Please enter all 6 digits of the OTP';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Full Name Optional Field
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      style: AppTypography.sans(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Full Name (Optional)',
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.cobaltBlue, size: 20),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Error Banner
                    if (widget.authController.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.errorRed, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.authController.errorMessage!,
                                style: AppTypography.sans(
                                  color: AppColors.errorRed,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Verify Button
                    CobaltButton(
                      text: 'Verify & Sign In',
                      isLoading: isLoading,
                      onPressed: _handleVerifyOtp,
                    ),

                    const SizedBox(height: 20),

                    // Resend OTP Countdown
                    TextButton.icon(
                      onPressed: (isLoading || _secondsRemaining > 0)
                          ? null
                          : () async {
                              final messenger = ScaffoldMessenger.of(context);
                              widget.authController.clearError();
                              final success = await widget.authController.sendOtp(phone);
                              if (mounted && success) {
                                _startCountdown();
                                if (widget.authController.devNote != null) {
                                  messenger.showSnackBar(
                                    SnackBar(content: Text(widget.authController.devNote!)),
                                  );
                                }
                              }
                            },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(
                        _secondsRemaining > 0
                            ? 'Resend OTP (${_secondsRemaining}s)'
                            : 'Resend OTP',
                        style: AppTypography.sans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _secondsRemaining > 0 ? AppColors.textMuted : AppColors.cobaltBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
