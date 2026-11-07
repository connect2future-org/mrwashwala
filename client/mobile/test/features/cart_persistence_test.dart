import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mrwashwala_mobile/core/storage/secure_storage_service.dart';
import 'package:mrwashwala_mobile/data/models/service_model.dart';
import 'package:mrwashwala_mobile/features/cart/presentation/cart_controller.dart';

class MockStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _data[key] = value;
    } else {
      _data.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }
}

void main() {
  group('Cart Persistence & Reliability Tests', () {
    late MockStorage mockStorage;
    late SecureStorageService storageService;

    setUp(() {
      mockStorage = MockStorage();
      storageService = SecureStorageService(storage: mockStorage);
    });

    test('Persists cart items to storage and restores on loadSavedCart()', () async {
      final cart1 = CartController(storageService: storageService);
      final service = ServiceModel(
        id: 'wash-fold',
        name: 'Wash & Fold',
        unit: 'kg',
        price: 59.0,
      );

      cart1.addItem(service, quantity: 3);
      expect(cart1.totalQuantity, 3);
      expect(cart1.subtotal, 177.0);

      // Verify stored in mockStorage
      final raw = await mockStorage.read(key: 'mrw_customer_cart_items');
      expect(raw, isNotNull);
      final decoded = jsonDecode(raw!) as List;
      expect(decoded.length, 1);
      expect(decoded.first['serviceId'], 'wash-fold');
      expect(decoded.first['quantity'], 3);

      // Simulate app restart with a fresh CartController instance
      final cart2 = CartController(storageService: storageService);
      expect(cart2.isEmpty, isTrue);

      await cart2.loadSavedCart();
      expect(cart2.isEmpty, isFalse);
      expect(cart2.totalQuantity, 3);
      expect(cart2.subtotal, 177.0);
      expect(cart2.items.first.name, 'Wash & Fold');
    });

    test('Filters out any legacy test services during loadSavedCart()', () async {
      // Pre-seed storage with a legacy test service and a genuine service
      final legacyList = [
        {
          'serviceId': 'test-wash-fold',
          'name': 'Wash & Fold Test',
          'price': 60.0,
          'unit': 'Kg',
          'quantity': 2,
          'stainRemoval': false,
          'premiumClean': false,
        },
        {
          'serviceId': 'wash-fold',
          'name': 'Wash & Fold',
          'price': 59.0,
          'unit': 'kg',
          'quantity': 2,
          'stainRemoval': false,
          'premiumClean': false,
        },
      ];
      await mockStorage.write(
        key: 'mrw_customer_cart_items',
        value: jsonEncode(legacyList),
      );

      final cart = CartController(storageService: storageService);
      await cart.loadSavedCart();

      // Only genuine service should be loaded
      expect(cart.items.length, 1);
      expect(cart.items.first.serviceId, 'wash-fold');
      expect(cart.items.first.name, 'Wash & Fold');
      expect(cart.items.first.price, 59.0);
    });

    test('clearCart() clears items from both memory and persistent storage', () async {
      final cart = CartController(storageService: storageService);
      final service = ServiceModel(
        id: 'dry-clean-shirt',
        name: 'Dry Cleaning Shirt',
        unit: 'piece',
        price: 99.0,
      );

      cart.addItem(service, quantity: 2);
      expect(await mockStorage.read(key: 'mrw_customer_cart_items'), isNotNull);

      cart.clearCart();
      expect(cart.isEmpty, isTrue);
      expect(await mockStorage.read(key: 'mrw_customer_cart_items'), isNull);
    });
  });
}
