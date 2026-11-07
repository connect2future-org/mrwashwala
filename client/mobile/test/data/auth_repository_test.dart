import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/repositories/auth_repository.dart';

void main() {
  group('AuthRepository Tests', () {
    test('sendOtp returns SendOtpResponse on success', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        expect(body['phone'], '9876543210');
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'OTP sent successfully',
            'expiresInSeconds': 300,
            'devNote': 'Development Mode: Use OTP 123456',
          }),
          200,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AuthRepository(apiClient: apiClient);

      final res = await repo.sendOtp('9876543210');
      expect(res.success, isTrue);
      expect(res.expiresInSeconds, 300);
      expect(res.devNote, contains('123456'));
    });

    test('verifyOtp returns token and customer model on success', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        expect(body['phone'], '9876543210');
        expect(body['otp'], '123456');

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Authentication successful',
            'token': 'mock_jwt_token_123',
            'isNewCustomer': false,
            'customer': {
              '_id': 'cust_123',
              'phone': '9876543210',
              'name': 'Test User',
              'addresses': [],
            },
          }),
          200,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AuthRepository(apiClient: apiClient);

      final res = await repo.verifyOtp('9876543210', '123456');
      expect(res.success, isTrue);
      expect(res.token, 'mock_jwt_token_123');
      expect(res.customer.phone, '9876543210');
      expect(res.customer.name, 'Test User');
    });
  });
}
