import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/models/service_model.dart';
import 'package:mrwashwala_mobile/data/repositories/order_repository.dart';
import 'package:mrwashwala_mobile/features/auth/presentation/auth_controller.dart';
import 'package:mrwashwala_mobile/features/cart/presentation/cart_controller.dart';
import 'package:mrwashwala_mobile/features/checkout/presentation/checkout_controller.dart';

void main() {
  group('CheckoutController Flow Tests', () {
    late CartController cartController;
    late AuthController authController;

    final testService = ServiceModel(
      id: 'wash-fold',
      name: 'Wash & Fold',
      price: 59.0,
      unit: 'kg',
    );

    setUp(() {
      cartController = CartController();
      authController = AuthController();
    });

    test('placeOrder rejects empty cart without sending HTTP request', () async {
      final controller = CheckoutController();
      final success = await controller.placeOrder(
        cartController: cartController,
        authController: authController,
      );

      expect(success, isFalse);
      expect(controller.errorMessage, contains('Cart is empty'));
    });

    test('placeOrder sends order and clears cart ONLY on success', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            '_id': 'ord_123',
            'orderId': 'MRW-999888',
            'status': 'Pending',
            'totalAmount': 118,
            'paymentMethod': 'Cash on Delivery',
          }),
          201,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = OrderRepository(apiClient: apiClient);
      final controller = CheckoutController(orderRepository: repo);

      // Add item to cart
      cartController.addItem(testService, quantity: 2);
      expect(cartController.totalQuantity, 2);

      final success = await controller.placeOrder(
        cartController: cartController,
        authController: authController,
        manualName: 'Test Customer',
        manualPhone: '9876543210',
        manualAddress: '42 Main St, Mysuru',
      );

      expect(success, isTrue);
      expect(controller.createdOrder?.orderId, 'MRW-999888');
      // Cart MUST be cleared after successful order creation
      expect(cartController.isEmpty, isTrue);
    });

    test('placeOrder preserves cart when backend API fails', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Server error creating order'}),
          500,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = OrderRepository(apiClient: apiClient);
      final controller = CheckoutController(orderRepository: repo);

      // Add item to cart
      cartController.addItem(testService, quantity: 2);

      final success = await controller.placeOrder(
        cartController: cartController,
        authController: authController,
        manualName: 'Test Customer',
        manualPhone: '9876543210',
        manualAddress: '42 Main St, Mysuru',
      );

      expect(success, isFalse);
      expect(controller.errorMessage, contains('Server error creating order'));
      // Cart MUST NOT be cleared on failure
      expect(cartController.totalQuantity, 2);
    });
  });
}
