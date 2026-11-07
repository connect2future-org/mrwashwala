import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mrwashwala_mobile/data/models/customer_model.dart';
import 'package:mrwashwala_mobile/data/models/service_model.dart';
import 'package:mrwashwala_mobile/features/auth/presentation/auth_controller.dart';
import 'package:mrwashwala_mobile/features/cart/presentation/cart_controller.dart';
import 'package:mrwashwala_mobile/features/checkout/presentation/checkout_controller.dart';
import 'package:mrwashwala_mobile/features/checkout/presentation/checkout_screen.dart';

class FakeAuthController extends AuthController {
  final CustomerModel? _mockCustomer;
  final String? _mockToken;
  final bool _mockAuth;

  FakeAuthController({
    CustomerModel? customer,
    String? token,
    bool isAuthenticated = false,
  })  : _mockCustomer = customer,
        _mockToken = token,
        _mockAuth = isAuthenticated;

  @override
  CustomerModel? get currentCustomer => _mockCustomer;

  @override
  String? get token => _mockToken;

  @override
  bool get isAuthenticated => _mockAuth;
}

void main() {
  group('CheckoutScreen Widget & UI Redesign Tests', () {
    late CartController cartController;
    late CheckoutController checkoutController;

    final testService = ServiceModel(
      id: 'dry-clean-suit',
      name: 'Dry Clean Suit',
      price: 249.0,
      unit: 'piece',
    );

    setUp(() {
      cartController = CartController();
      cartController.addItem(testService, quantity: 2);
      checkoutController = CheckoutController();
    });

    testWidgets('Renders branded AppBar and all 6 checkout sections', (tester) async {
      final authController = FakeAuthController();

      await tester.pumpWidget(
        MaterialApp(
          home: CheckoutScreen(
            cartController: cartController,
            authController: authController,
            checkoutController: checkoutController,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Checkout & Booking'), findsOneWidget);
      expect(find.text('Mysuru Doorstep Laundry Service'), findsOneWidget);

      // Verify Sections 1 to 3 visible initially
      expect(find.text('1. Customer Contact'), findsOneWidget);
      expect(find.text('2. Delivery Address'), findsOneWidget);
      expect(find.text('3. Pickup Schedule'), findsOneWidget);

      // Scroll down to check Sections 4, 5, 6
      await tester.ensureVisible(find.text('4. Processing Outlet'));
      expect(find.text('4. Processing Outlet'), findsOneWidget);

      await tester.ensureVisible(find.text('5. Payment Method'));
      expect(find.text('5. Payment Method'), findsOneWidget);

      await tester.ensureVisible(find.text('6. Order Summary'));
      expect(find.text('6. Order Summary'), findsOneWidget);

      // Verify Order Item & Total
      expect(find.text('Dry Clean Suit'), findsOneWidget);
      expect(find.text('Total Payable'), findsOneWidget);

      // Verify Prominent Sticky Place Order button
      expect(find.text('Place Order'), findsOneWidget);
      expect(find.text('TOTAL PAYABLE'), findsOneWidget);
    });

    testWidgets('Displays verified customer details when logged in', (tester) async {
      final authController = FakeAuthController(
        isAuthenticated: true,
        token: 'test-jwt-token',
        customer: CustomerModel(
          id: 'cust_1',
          phone: '9876543210',
          name: 'Rahul Sharma',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CheckoutScreen(
            cartController: cartController,
            authController: authController,
            checkoutController: checkoutController,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('VERIFIED'), findsOneWidget);
      expect(find.text('Rahul Sharma'), findsOneWidget);
      expect(find.text('+91 9876543210'), findsOneWidget);
    });

    testWidgets('Allows selecting payment methods interactively', (tester) async {
      final authController = FakeAuthController();

      await tester.pumpWidget(
        MaterialApp(
          home: CheckoutScreen(
            cartController: cartController,
            authController: authController,
            checkoutController: checkoutController,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Default is Cash on Delivery
      expect(checkoutController.paymentMethod, 'Cash on Delivery');

      // Scroll to QR Payment card and tap
      final qrCard = find.text('UPI / QR Payment');
      await tester.ensureVisible(qrCard);
      await tester.pumpAndSettle();

      await tester.tap(qrCard);
      await tester.pumpAndSettle();

      expect(checkoutController.paymentMethod, 'QR Payment');
    });

    testWidgets('Allows selecting time slots', (tester) async {
      final authController = FakeAuthController();

      await tester.pumpWidget(
        MaterialApp(
          home: CheckoutScreen(
            cartController: cartController,
            authController: authController,
            checkoutController: checkoutController,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final slot = find.text('02:00 PM - 04:00 PM');
      await tester.ensureVisible(slot);
      await tester.pumpAndSettle();

      await tester.tap(slot);
      await tester.pumpAndSettle();

      expect(checkoutController.selectedPickupTime, '02:00 PM - 04:00 PM');
    });
  });
}
