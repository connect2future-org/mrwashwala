import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/repositories/auth_repository.dart';
import 'package:mrwashwala_mobile/features/auth/presentation/auth_controller.dart';
import 'package:mrwashwala_mobile/features/auth/presentation/otp_screen.dart';

void main() {
  group('OtpScreen Widget Tests', () {
    late AuthController authController;

    setUp(() async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'OTP sent',
            'expiresInSeconds': 300,
          }),
          200,
        );
      });
      authController = AuthController(
        authRepository: AuthRepository(apiClient: ApiClient(client: mockClient)),
      );
      await authController.sendOtp('9876543210');
    });

    testWidgets('Renders OTP screen with phone number and 6-digit input', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OtpScreen(
            authController: authController,
                      ),
        ),
      );

      expect(find.text('Verify Mobile OTP'), findsOneWidget);
      expect(find.text('+91 9876543210'), findsOneWidget);
      expect(find.text('Enter 6-Digit OTP'), findsOneWidget);
      expect(find.text('Verify & Sign In'), findsOneWidget);
      expect(find.textContaining('Resend OTP'), findsOneWidget);
    });

    testWidgets('Validates 6-digit OTP requirement', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OtpScreen(
            authController: authController,
                      ),
        ),
      );

      // Tap verify with empty OTP
      await tester.tap(find.text('Verify & Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter all 6 digits of the OTP'), findsOneWidget);
    });

    testWidgets('Resend OTP button is disabled during countdown and enables after timer expires', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OtpScreen(
            authController: authController,
          ),
        ),
      );

      // Initially disabled with 30s countdown
      expect(find.text('Resend OTP (30s)'), findsOneWidget);
      final buttonFinder = find.widgetWithText(TextButton, 'Resend OTP (30s)');
      final initialButton = tester.widget<TextButton>(buttonFinder);
      expect(initialButton.onPressed, isNull);

      // Advance clock by 30 seconds
      await tester.pump(const Duration(seconds: 30));
      await tester.pump();

      expect(find.text('Resend OTP'), findsOneWidget);
      final enabledButton = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Resend OTP'));
      expect(enabledButton.onPressed, isNotNull);
    });
  });
}
