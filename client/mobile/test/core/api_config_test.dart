import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mrwashwala_mobile/core/config/api_config.dart';

void main() {
  group('ApiConfig Cross-Platform Base URL Tests', () {
    final originalPlatform = debugDefaultTargetPlatformOverride;

    tearDown(() {
      debugDefaultTargetPlatformOverride = originalPlatform;
    });

    test('Returns 127.0.0.1 on iOS platform', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(ApiConfig.baseUrl, equals('http://127.0.0.1:5000/api'));
      expect(ApiConfig.services, equals('http://127.0.0.1:5000/api/services'));
      expect(ApiConfig.sendOtp, equals('http://127.0.0.1:5000/api/customer/auth/send-otp'));
      expect(ApiConfig.verifyOtp, equals('http://127.0.0.1:5000/api/customer/auth/verify-otp'));
      expect(ApiConfig.profile, equals('http://127.0.0.1:5000/api/customer/profile'));
      expect(ApiConfig.addresses, equals('http://127.0.0.1:5000/api/customer/addresses'));
      expect(ApiConfig.createOrder, equals('http://127.0.0.1:5000/api/orders'));
      expect(ApiConfig.orders, equals('http://127.0.0.1:5000/api/customer/orders'));
      expect(ApiConfig.reviews, equals('http://127.0.0.1:5000/api/customer/reviews'));
    });

    test('Returns 10.0.2.2 on Android platform', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(ApiConfig.baseUrl, equals('http://10.0.2.2:5000/api'));
      expect(ApiConfig.services, equals('http://10.0.2.2:5000/api/services'));
      expect(ApiConfig.sendOtp, equals('http://10.0.2.2:5000/api/customer/auth/send-otp'));
      expect(ApiConfig.verifyOtp, equals('http://10.0.2.2:5000/api/customer/auth/verify-otp'));
      expect(ApiConfig.profile, equals('http://10.0.2.2:5000/api/customer/profile'));
      expect(ApiConfig.addresses, equals('http://10.0.2.2:5000/api/customer/addresses'));
      expect(ApiConfig.createOrder, equals('http://10.0.2.2:5000/api/orders'));
      expect(ApiConfig.orders, equals('http://10.0.2.2:5000/api/customer/orders'));
      expect(ApiConfig.reviews, equals('http://10.0.2.2:5000/api/customer/reviews'));
    });
  });
}
