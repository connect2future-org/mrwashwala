import 'package:flutter_test/flutter_test.dart';
import 'package:mrwashwala_mobile/data/models/service_model.dart';
import 'package:mrwashwala_mobile/features/cart/presentation/cart_controller.dart';

void main() {
  group('CartController Unit & State Tests', () {
    late CartController cartController;

    final service1 = ServiceModel(
      id: 'wash-fold',
      name: 'Wash & Fold',
      price: 59.0,
      unit: 'kg',
    );

    final service2 = ServiceModel(
      id: 'dryclean-saree',
      name: 'Saree Dry Clean',
      price: 300.0,
      unit: 'item',
    );

    setUp(() {
      cartController = CartController();
    });

    test('Initial cart is empty', () {
      expect(cartController.isEmpty, isTrue);
      expect(cartController.totalQuantity, 0);
      expect(cartController.subtotal, 0.0);
    });

    test('addItem adds new service to cart', () {
      cartController.addItem(service1, quantity: 2);

      expect(cartController.isEmpty, isFalse);
      expect(cartController.uniqueItemCount, 1);
      expect(cartController.totalQuantity, 2);
      expect(cartController.subtotal, 118.0);
      expect(cartController.formattedSubtotal, '₹118');
    });

    test('addItem with existing service ID increments quantity without duplicating row', () {
      cartController.addItem(service1, quantity: 2);
      cartController.addItem(service1, quantity: 3);

      expect(cartController.uniqueItemCount, 1);
      expect(cartController.totalQuantity, 5);
      expect(cartController.subtotal, 295.0);
    });

    test('Multiple unique services in cart', () {
      cartController.addItem(service1, quantity: 2); // 2 * 59 = 118
      cartController.addItem(service2, quantity: 1); // 1 * 300 = 300

      expect(cartController.uniqueItemCount, 2);
      expect(cartController.totalQuantity, 3);
      expect(cartController.subtotal, 418.0);
    });

    test('incrementQuantity and decrementQuantity update line totals', () {
      cartController.addItem(service1, quantity: 1);
      expect(cartController.subtotal, 59.0);

      cartController.incrementQuantity('wash-fold');
      expect(cartController.totalQuantity, 2);
      expect(cartController.subtotal, 118.0);

      cartController.decrementQuantity('wash-fold');
      expect(cartController.totalQuantity, 1);
      expect(cartController.subtotal, 59.0);
    });

    test('decrementQuantity removes item when reaching zero', () {
      cartController.addItem(service1, quantity: 1);
      cartController.decrementQuantity('wash-fold');

      expect(cartController.isEmpty, isTrue);
      expect(cartController.totalQuantity, 0);
    });

    test('removeItem removes target item', () {
      cartController.addItem(service1, quantity: 2);
      cartController.addItem(service2, quantity: 1);

      cartController.removeItem('wash-fold');
      expect(cartController.uniqueItemCount, 1);
      expect(cartController.items.first.serviceId, 'dryclean-saree');
    });

    test('clearCart empties all items', () {
      cartController.addItem(service1, quantity: 2);
      cartController.addItem(service2, quantity: 1);

      cartController.clearCart();
      expect(cartController.isEmpty, isTrue);
      expect(cartController.totalQuantity, 0);
    });

    test('addItem rejects test service and does not add it to cart', () {
      final testService = ServiceModel(
        id: 'test-wash-fold',
        name: 'Wash & Fold Test',
        price: 60.0,
        unit: 'Kg',
      );

      cartController.addItem(testService, quantity: 1);
      expect(cartController.isEmpty, isTrue);
      expect(cartController.totalQuantity, 0);
      expect(cartController.uniqueItemCount, 0);

      // Genuine service can still be added
      cartController.addItem(service1, quantity: 1);
      expect(cartController.isEmpty, isFalse);
      expect(cartController.uniqueItemCount, 1);
      expect(cartController.items.first.name, 'Wash & Fold');
      expect(cartController.items.first.price, 59.0);
    });
  });
}
