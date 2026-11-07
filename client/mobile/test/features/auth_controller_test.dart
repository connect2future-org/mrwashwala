import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/repositories/auth_repository.dart';
import 'package:mrwashwala_mobile/features/auth/presentation/auth_controller.dart';

void main() {
  group('AuthController Validation & Flow Tests', () {
    test('sendOtp rejects invalid phone numbers without calling API', () async {
      final controller = AuthController();
      final success = await controller.sendOtp('12345');

      expect(success, isFalse);
      expect(controller.status, AuthStatus.error);
      expect(controller.errorMessage, contains('valid 10-digit mobile number'));
    });

    test('sendOtp handles valid phone number transition', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'OTP sent',
            'expiresInSeconds': 300,
            'devNote': 'Development Mode: Use OTP 123456',
          }),
          200,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AuthRepository(apiClient: apiClient);
      final controller = AuthController(authRepository: repo);

      final success = await controller.sendOtp('9876543210');
      expect(success, isTrue);
      expect(controller.status, AuthStatus.otpSent);
      expect(controller.activePhone, '9876543210');
      expect(controller.devNote, contains('123456'));
    });
  });
}
