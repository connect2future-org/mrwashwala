import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../models/customer_model.dart';

class SendOtpResponse {
  final bool success;
  final String message;
  final int expiresInSeconds;
  final String? devNote;

  SendOtpResponse({
    required this.success,
    required this.message,
    required this.expiresInSeconds,
    this.devNote,
  });
}

class VerifyOtpResponse {
  final bool success;
  final String message;
  final String token;
  final bool isNewCustomer;
  final CustomerModel customer;

  VerifyOtpResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.isNewCustomer,
    required this.customer,
  });
}

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Requests a 6-digit OTP for the given 10-digit mobile number.
  Future<SendOtpResponse> sendOtp(String phone) async {
    final response = await _apiClient.post(
      ApiConfig.sendOtp,
      body: {'phone': phone},
    );

    if (response is Map<String, dynamic>) {
      return SendOtpResponse(
        success: response['success'] ?? true,
        message: response['message'] ?? 'OTP sent successfully',
        expiresInSeconds: response['expiresInSeconds'] ?? 300,
        devNote: response['devNote'],
      );
    }

    throw Exception('Unexpected response format from send-otp');
  }

  /// Verifies the 6-digit OTP and authenticates/registers the customer.
  Future<VerifyOtpResponse> verifyOtp(String phone, String otp, {String? name}) async {
    final body = <String, dynamic>{
      'phone': phone,
      'otp': otp,
    };
    if (name != null && name.trim().isNotEmpty) {
      body['name'] = name.trim();
    }

    final response = await _apiClient.post(
      ApiConfig.verifyOtp,
      body: body,
    );

    if (response is Map<String, dynamic>) {
      final token = response['token'];
      final customerData = response['customer'];

      if (token == null || customerData == null) {
        throw Exception('Invalid authentication response: missing token or customer data');
      }

      return VerifyOtpResponse(
        success: response['success'] ?? true,
        message: response['message'] ?? 'Authentication successful',
        token: token.toString(),
        isNewCustomer: response['isNewCustomer'] ?? false,
        customer: CustomerModel.fromJson(customerData as Map<String, dynamic>),
      );
    }

    throw Exception('Unexpected response format from verify-otp');
  }

  /// Fetches the authenticated customer's profile.
  Future<CustomerModel> fetchProfile(String token) async {
    final response = await _apiClient.get(
      ApiConfig.profile,
      token: token,
    );

    if (response is Map<String, dynamic> && response['data'] != null) {
      return CustomerModel.fromJson(response['data'] as Map<String, dynamic>);
    }

    throw Exception('Failed to parse customer profile data');
  }

  /// Updates the authenticated customer profile (name, email).
  Future<CustomerModel> updateProfile(
    String token, {
    String? name,
    String? email,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body["name"] = name.trim();
    if (email != null) body["email"] = email.trim();

    final response = await _apiClient.patch(
      ApiConfig.profile,
      token: token,
      body: body,
    );

    if (response is Map<String, dynamic> && response["data"] != null) {
      return CustomerModel.fromJson(response["data"] as Map<String, dynamic>);
    }

    throw Exception("Failed to update customer profile");
  }
}
