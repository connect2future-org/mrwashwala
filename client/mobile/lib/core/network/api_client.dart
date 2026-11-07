import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_exception.dart';

/// Reusable HTTP API Client for Mr. WashWala Flutter mobile application.
class ApiClient {
  final http.Client _client;
  final Duration timeout;

  ApiClient({
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  Map<String, String> _buildHeaders(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String url, {String? token}) async {
    try {
      final response = await _client
          .get(
            Uri.parse(url),
            headers: _buildHeaders(token),
          )
          .timeout(timeout);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('Connection timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network request failed: $e');
    }
  }

  Future<dynamic> post(String url, {dynamic body, String? token}) async {
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: _buildHeaders(token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('Connection timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network request failed: $e');
    }
  }

  Future<dynamic> patch(String url, {dynamic body, String? token}) async {
    try {
      final response = await _client
          .patch(
            Uri.parse(url),
            headers: _buildHeaders(token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('Connection timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network request failed: $e');
    }
  }

  Future<dynamic> delete(String url, {String? token}) async {
    try {
      final response = await _client
          .delete(
            Uri.parse(url),
            headers: _buildHeaders(token),
          )
          .timeout(timeout);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('Connection timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network request failed: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    Map<String, dynamic> body = {};

    try {
      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          body = decoded;
        } else if (decoded is List) {
          return decoded;
        }
      }
    } catch (_) {
      throw ApiException('Malformed response received from server', statusCode: statusCode);
    }

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    } else {
      final message = body['message'] ?? 'An error occurred (HTTP $statusCode)';
      throw ApiException(message.toString(), statusCode: statusCode);
    }
  }
}
