import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service responsible for managing encrypted customer authentication token and session state.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  static const String _keyToken = 'mrw_customer_jwt_token';
  static const String _keyCustomer = 'mrw_customer_profile_data';
  static const String _keyCart = 'mrw_customer_cart_items';

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
            );

  /// Saves the JWT token securely.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  /// Retrieves the stored JWT token.
  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  /// Checks whether a valid JWT token is stored.
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.trim().isNotEmpty;
  }

  /// Deletes the stored JWT token.
  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  /// Saves customer profile metadata as JSON string.
  Future<void> saveCustomer(Map<String, dynamic> customerJson) async {
    await _storage.write(key: _keyCustomer, value: jsonEncode(customerJson));
  }

  /// Retrieves stored customer profile metadata.
  Future<Map<String, dynamic>?> getCustomer() async {
    final rawJson = await _storage.read(key: _keyCustomer);
    if (rawJson == null || rawJson.isEmpty) return null;
    try {
      return jsonDecode(rawJson) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Saves customer cart items securely.
  Future<void> saveCart(List<Map<String, dynamic>> itemsJson) async {
    await _storage.write(key: _keyCart, value: jsonEncode(itemsJson));
  }

  /// Retrieves stored customer cart items.
  Future<List<Map<String, dynamic>>?> getCart() async {
    final rawJson = await _storage.read(key: _keyCart);
    if (rawJson == null || rawJson.isEmpty) return null;
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is List) {
        return decoded.map((e) => e as Map<String, dynamic>).toList();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Clears stored cart items.
  Future<void> clearCart() async {
    await _storage.delete(key: _keyCart);
  }

  /// Clears all stored customer authentication credentials and session data.
  Future<void> clearAll() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyCustomer);
  }
}
