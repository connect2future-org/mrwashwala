import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mrwashwala_mobile/data/models/service_model.dart';
import 'package:mrwashwala_mobile/features/auth/presentation/auth_controller.dart';
import 'package:mrwashwala_mobile/features/cart/presentation/cart_controller.dart';
import 'package:mrwashwala_mobile/features/cart/presentation/cart_screen.dart';
import 'package:mrwashwala_mobile/features/checkout/presentation/checkout_screen.dart';

void main() {
  group('CartScreen Widget & Verification Tests', () {
    late CartController cartController;

    final genuineWashFold = ServiceModel(
      id: 'wash-fold',
      name: 'Wash & Fold',
      price: 59.0,
      unit: 'kg',
    );

    final genuineDryClean = ServiceModel(
      id: 'dryclean-saree',
      name: 'Saree Dry Clean',
      price: 300.0,
      unit: 'item',
    );

    final testService = ServiceModel(
      id: 'test-wash-fold',
      name: 'Wash & Fold Test',
      price: 60.0,
      unit: 'Kg',
    );

    setUp(() {
      cartController = CartController();
    });

    testWidgets('Renders empty cart state with Browse Services action', (tester) async {
      bool browseTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: CartScreen(
            cartController: cartController,
            onBrowseServices: () {
              browseTriggered = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your Cart'), findsOneWidget);
      expect(find.text('Review your laundry order'), findsOneWidget);
      expect(find.text('Your Cart is Empty'), findsOneWidget);
      expect(find.text('Browse Services'), findsOneWidget);
      expect(find.text('Proceed to Checkout'), findsNothing);

      await tester.tap(find.text('Browse Services'));
      await tester.pumpAndSettle();

      expect(browseTriggered, isTrue);
    });

    testWidgets('Renders genuine service item with correct price and bill summary', (tester) async {
      cartController.addItem(genuineWashFold, quantity: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: CartScreen(
            cartController: cartController,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your Cart'), findsOneWidget);
      expect(find.text('1 item selected'), findsOneWidget);
      expect(find.text('Wash & Fold'), findsOneWidget);
      expect(find.text('₹59 / kg'), findsOneWidget);
      expect(find.text('1'), findsWidgets);
      expect(find.text('₹59'), findsWidgets);
      expect(find.text('Estimated Total'), findsOneWidget);
      expect(find.text('Proceed to Checkout'), findsOneWidget);
    });

    testWidgets('Steppers increment and decrement quantities and update totals', (tester) async {
      cartController.addItem(genuineWashFold, quantity: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: CartScreen(
            cartController: cartController,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('₹59'), findsWidgets);

      // Tap + button
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(cartController.totalQuantity, 2);
      expect(cartController.subtotal, 118.0);
      expect(find.text('2'), findsWidgets);
      expect(find.text('₹118'), findsWidgets);

      // Tap - button
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pumpAndSettle();

      expect(cartController.totalQuantity, 1);
      expect(cartController.subtotal, 59.0);
      expect(find.text('1'), findsWidgets);
      expect(find.text('₹59'), findsWidgets);
    });

    testWidgets('Removing item transitions cart to empty state and displays SnackBar', (tester) async {
      cartController.addItem(genuineWashFold, quantity: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartScreen(
              cartController: cartController,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      expect(cartController.isEmpty, isTrue);
      expect(find.text('Your Cart is Empty'), findsOneWidget);
      expect(find.text('Wash & Fold removed from cart'), findsOneWidget);
    });

    testWidgets('Clear button in AppBar opens dialog and clears entire cart', (tester) async {
      cartController.addItem(genuineWashFold, quantity: 1);
      cartController.addItem(genuineDryClean, quantity: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: CartScreen(
            cartController: cartController,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Clear'), findsOneWidget);

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(find.text('Clear Cart?'), findsOneWidget);
      expect(find.text('Clear All'), findsOneWidget);

      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      expect(cartController.isEmpty, isTrue);
      expect(find.text('Your Cart is Empty'), findsOneWidget);
    });

    testWidgets('Tapping Proceed to Checkout navigates to CheckoutScreen', (tester) async {
      cartController.addItem(genuineWashFold, quantity: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: CartScreen(
            cartController: cartController,
            authController: AuthController(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final checkoutButton = find.text('Proceed to Checkout');
      expect(checkoutButton, findsOneWidget);

      await tester.tap(checkoutButton);
      await tester.pumpAndSettle();

      expect(find.byType(CheckoutScreen), findsOneWidget);
    });

    testWidgets('Test service Wash & Fold Test cannot be added to cart', (tester) async {
      // Attempt to add test service
      cartController.addItem(testService, quantity: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: CartScreen(
            cartController: cartController,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Cart must remain completely empty
      expect(cartController.isEmpty, isTrue);
      expect(find.text('Your Cart is Empty'), findsOneWidget);
      expect(find.text('Wash & Fold Test'), findsNothing);
      expect(find.text('₹60 / Kg'), findsNothing);
    });
  });
}
