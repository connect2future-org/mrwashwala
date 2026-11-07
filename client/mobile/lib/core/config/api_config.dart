import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

/// Centralized API configuration for Mr. WashWala backend communication.
/// Supports both Android (10.0.2.2) and iOS (127.0.0.1 / localhost) local development.
class ApiConfig {
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return 'http://127.0.0.1:5000/api';
    }
    return 'http://10.0.2.2:5000/api';
  }

  static String get services => '$baseUrl/services';
  static String get sendOtp => '$baseUrl/customer/auth/send-otp';
  static String get verifyOtp => '$baseUrl/customer/auth/verify-otp';
  static String get profile => '$baseUrl/customer/profile';
  static String get addresses => '$baseUrl/customer/addresses';
  static String get createOrder => '$baseUrl/orders';
  static String get orders => '$baseUrl/customer/orders';
  static String get reviews => '$baseUrl/customer/reviews';
}
