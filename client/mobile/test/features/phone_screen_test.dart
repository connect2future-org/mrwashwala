import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/repositories/auth_repository.dart';
import 'package:mrwashwala_mobile/features/auth/presentation/auth_controller.dart';
import 'package:mrwashwala_mobile/features/auth/presentation/phone_screen.dart';

void main() {
  group('PhoneScreen Widget Tests', () {
    late AuthController authController;

    setUp(() {
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
    });

    testWidgets('Renders phone input screen with brand title and +91 prefix', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PhoneScreen(authController: authController),
        ),
      );

      expect(find.text('Mr. WashWala'), findsOneWidget);
      expect(find.text('Premium Laundry & Dry Cleaning in Mysuru'), findsOneWidget);
      expect(find.text('+91'), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);
    });

    testWidgets('Validates 10-digit mobile number input', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PhoneScreen(authController: authController),
        ),
      );

      // Tap Send OTP without entering phone
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();

      expect(find.text('Mobile number is required'), findsOneWidget);

      // Enter incomplete phone number
      await tester.enterText(find.byType(TextFormField), '98765');
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid 10-digit mobile number'), findsOneWidget);
    });

    testWidgets('Submitting valid 10-digit phone navigates to OtpScreen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PhoneScreen(authController: authController),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '9876543210');
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();

      expect(find.text('Verify Mobile OTP'), findsOneWidget);
      expect(find.text('+91 9876543210'), findsOneWidget);
    });
  });
}
