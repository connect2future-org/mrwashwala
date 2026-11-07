import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/models/address_model.dart';
import 'package:mrwashwala_mobile/data/models/customer_model.dart';
import 'package:mrwashwala_mobile/data/repositories/customer_order_repository.dart';
import 'package:mrwashwala_mobile/data/repositories/customer_review_repository.dart';
import 'package:mrwashwala_mobile/features/addresses/presentation/address_controller.dart';
import 'package:mrwashwala_mobile/features/auth/presentation/auth_controller.dart';
import 'package:mrwashwala_mobile/features/orders/presentation/customer_order_controller.dart';
import 'package:mrwashwala_mobile/features/profile/presentation/profile_screen.dart';
import 'package:mrwashwala_mobile/features/reviews/presentation/customer_review_controller.dart';

class FakeAuthController extends AuthController {
  final bool _mockAuth;
  final String? _mockToken;
  final CustomerModel? _mockCustomer;
  bool logoutCalled = false;

  FakeAuthController({
    bool isAuthenticated = false,
    String? token,
    CustomerModel? customer,
  })  : _mockAuth = isAuthenticated,
        _mockToken = token,
        _mockCustomer = customer;

  @override
  bool get isAuthenticated => _mockAuth;

  @override
  String? get token => _mockToken;

  @override
  CustomerModel? get currentCustomer => _mockCustomer;

  @override
  Future<void> checkAuthStatus() async {}

  @override
  Future<void> logout() async {
    logoutCalled = true;
    notifyListeners();
  }
}

class FakeAddressController extends AddressController {
  final List<AddressModel> _mockAddresses;
  final bool _mockLoading;

  FakeAddressController({
    List<AddressModel> addresses = const [],
    bool isLoading = false,
  })  : _mockAddresses = addresses,
        _mockLoading = isLoading;

  @override
  List<AddressModel> get addresses => _mockAddresses;

  @override
  bool get hasAddresses => _mockAddresses.isNotEmpty;

  @override
  bool get isLoading => _mockLoading;

  @override
  AddressModel? get defaultAddress {
    if (_mockAddresses.isEmpty) return null;
    try {
      return _mockAddresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _mockAddresses.first;
    }
  }

  @override
  Future<void> loadAddresses(String? token) async {}
}

void main() {
  group('ProfileScreen Widget & UI Redesign Tests', () {
    late CustomerOrderController mockOrderCtrl;
    late CustomerReviewController mockReviewCtrl;

    setUp(() {
      final mockClient = MockClient((request) async {
        return http.Response('[]', 200);
      });
      final apiClient = ApiClient(client: mockClient);
      mockOrderCtrl = CustomerOrderController(
        orderRepository: CustomerOrderRepository(apiClient: apiClient),
      );
      mockReviewCtrl = CustomerReviewController(
        reviewRepository: CustomerReviewRepository(apiClient: apiClient),
      );
    });

    Widget createTestWidget({
      required AuthController authController,
      required AddressController addressController,
    }) {
      return MaterialApp(
        home: ProfileScreen(
          authController: authController,
          addressController: addressController,
          orderController: mockOrderCtrl,
          reviewController: mockReviewCtrl,
        ),
      );
    }

    testWidgets('Renders unauthenticated state with login prompt when not logged in',
        (tester) async {
      final authCtrl = FakeAuthController(isAuthenticated: false);
      final addrCtrl = FakeAddressController();

      await tester.pumpWidget(
        createTestWidget(authController: authCtrl, addressController: addrCtrl),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Sign In to Your Account'), findsOneWidget);
      expect(find.text('Sign In with Mobile OTP'), findsOneWidget);
      expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
    });

    testWidgets('Renders profile hero card with verified badge and customer info',
        (tester) async {
      final customer = CustomerModel(
        id: 'cust_1',
        phone: '9731303067',
        name: 'Minchu Gowda',
        email: 'minchu@example.com',
      );
      final authCtrl = FakeAuthController(
        isAuthenticated: true,
        token: 'token_123',
        customer: customer,
      );
      final addrCtrl = FakeAddressController();

      await tester.pumpWidget(
        createTestWidget(authController: authCtrl, addressController: addrCtrl),
      );
      await tester.pumpAndSettle();

      expect(find.text('Minchu Gowda'), findsAtLeastNWidgets(1));
      expect(find.text('VERIFIED'), findsOneWidget);
      expect(find.text('+91 9731303067'), findsAtLeastNWidgets(1));
      expect(find.text('minchu@example.com'), findsAtLeastNWidgets(1));
      expect(find.text('M'), findsOneWidget); // Initial avatar
      expect(find.text('Edit Personal Details'), findsOneWidget);
    });

    testWidgets('Renders Account Information section with all fields', (tester) async {
      final customer = CustomerModel(
        id: 'cust_1',
        phone: '9731303067',
        name: 'Minchu Gowda',
        email: 'minchu@example.com',
      );
      final authCtrl = FakeAuthController(
        isAuthenticated: true,
        token: 'token_123',
        customer: customer,
      );
      final addrCtrl = FakeAddressController();

      await tester.pumpWidget(
        createTestWidget(authController: authCtrl, addressController: addrCtrl),
      );
      await tester.pumpAndSettle();

      expect(find.text('Account Information'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Registered Mobile'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Account Status'), findsOneWidget);
      expect(find.text('Active & OTP Verified'), findsOneWidget);
    });

    testWidgets('Renders default saved address card when addresses are present',
        (tester) async {
      final customer = CustomerModel(
        id: 'cust_1',
        phone: '9731303067',
        name: 'Minchu Gowda',
      );
      final authCtrl = FakeAuthController(
        isAuthenticated: true,
        token: 'token_123',
        customer: customer,
      );
      final addr = AddressModel(
        addressId: 'addr_1',
        label: 'Home',
        fullAddress: 'No 45, 2nd Cross, Jayalakshmipuram',
        city: 'Mysuru',
        pincode: '570012',
        isDefault: true,
      );
      final addrCtrl = FakeAddressController(addresses: [addr]);

      await tester.pumpWidget(
        createTestWidget(authController: authCtrl, addressController: addrCtrl),
      );
      await tester.pumpAndSettle();

      expect(find.text('Saved Delivery Addresses'), findsOneWidget);
      expect(find.text('DEFAULT'), findsOneWidget);
      expect(find.text('No 45, 2nd Cross, Jayalakshmipuram'), findsOneWidget);
      expect(find.text('Mysuru - 570012'), findsOneWidget);
      expect(find.text('All Addresses (1)'), findsOneWidget);
      expect(find.text('Add New'), findsOneWidget);
    });

    testWidgets('Renders empty address card when no addresses are saved', (tester) async {
      final customer = CustomerModel(
        id: 'cust_1',
        phone: '9731303067',
        name: 'Minchu Gowda',
      );
      final authCtrl = FakeAuthController(
        isAuthenticated: true,
        token: 'token_123',
        customer: customer,
      );
      final addrCtrl = FakeAddressController(addresses: []);

      await tester.pumpWidget(
        createTestWidget(authController: authCtrl, addressController: addrCtrl),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Saved Addresses Yet'), findsOneWidget);
      expect(find.text('Add Delivery Address'), findsOneWidget);
    });

    testWidgets('Renders Orders & Activity, Support menu cards and Sign Out button',
        (tester) async {
      final customer = CustomerModel(
        id: 'cust_1',
        phone: '9731303067',
        name: 'Minchu Gowda',
      );
      final authCtrl = FakeAuthController(
        isAuthenticated: true,
        token: 'token_123',
        customer: customer,
      );
      final addrCtrl = FakeAddressController();

      await tester.pumpWidget(
        createTestWidget(authController: authCtrl, addressController: addrCtrl),
      );
      await tester.pumpAndSettle();

      expect(find.text('Orders & Activity'), findsOneWidget);
      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('My Reviews'), findsOneWidget);
      expect(find.text('Support & App Info'), findsOneWidget);
      expect(find.text('Customer Support'), findsOneWidget);
      expect(find.text('About Mr. WashWala'), findsOneWidget);
      expect(find.text('Sign Out of Account'), findsOneWidget);
    });

    testWidgets('Tapping Sign Out displays confirmation dialog and triggers logout',
        (tester) async {
      final customer = CustomerModel(
        id: 'cust_1',
        phone: '9731303067',
        name: 'Minchu Gowda',
      );
      final authCtrl = FakeAuthController(
        isAuthenticated: true,
        token: 'token_123',
        customer: customer,
      );
      final addrCtrl = FakeAddressController();

      await tester.pumpWidget(
        createTestWidget(authController: authCtrl, addressController: addrCtrl),
      );
      await tester.pumpAndSettle();

      // Scroll to Sign Out button
      await tester.scrollUntilVisible(find.text('Sign Out of Account'), 200);
      await tester.tap(find.text('Sign Out of Account'));
      await tester.pumpAndSettle();

      expect(find.text('Sign Out?'), findsOneWidget);
      expect(
        find.text('Are you sure you want to sign out of your Mr. WashWala account?'),
        findsOneWidget,
      );

      // Confirm sign out
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Out'));
      await tester.pumpAndSettle();

      expect(authCtrl.logoutCalled, isTrue);
    });

    testWidgets('Renders Plans & Pricing section with Price List and Subscription Plans',
        (tester) async {
      final customer = CustomerModel(
        id: 'cust_1',
        phone: '9731303067',
        name: 'Minchu Gowda',
      );
      final authCtrl = FakeAuthController(
        isAuthenticated: true,
        token: 'token_123',
        customer: customer,
      );
      final addrCtrl = FakeAddressController();

      await tester.pumpWidget(
        createTestWidget(authController: authCtrl, addressController: addrCtrl),
      );
      await tester.pumpAndSettle();

      expect(find.text('Plans & Pricing'), findsOneWidget);
      expect(find.text('Price List'), findsOneWidget);
      expect(find.text('Subscription Plans'), findsOneWidget);
      expect(find.text('SOON'), findsOneWidget);
    });

    testWidgets('Tapping Subscription Plans navigates to SubscriptionPlansScreen',
        (tester) async {
      final customer = CustomerModel(
        id: 'cust_1',
        phone: '9731303067',
        name: 'Minchu Gowda',
      );
      final authCtrl = FakeAuthController(
        isAuthenticated: true,
        token: 'token_123',
        customer: customer,
      );
      final addrCtrl = FakeAddressController();

      await tester.pumpWidget(
        createTestWidget(authController: authCtrl, addressController: addrCtrl),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Subscription Plans'), 200);
      await tester.tap(find.text('Subscription Plans'));
      await tester.pumpAndSettle();

      expect(find.text('Subscription Plans Coming Soon'), findsOneWidget);
      expect(
        find.text("We're working on exciting plans for our regular customers. Stay tuned!"),
        findsOneWidget,
      );
    });

    testWidgets('Tapping Price List navigates to PriceListScreen',
        (tester) async {
      final customer = CustomerModel(
        id: 'cust_1',
        phone: '9731303067',
        name: 'Minchu Gowda',
      );
      final authCtrl = FakeAuthController(
        isAuthenticated: true,
        token: 'token_123',
        customer: customer,
      );
      final addrCtrl = FakeAddressController();

      await tester.pumpWidget(
        createTestWidget(authController: authCtrl, addressController: addrCtrl),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Price List'), 200);
      await tester.tap(find.text('Price List'));
      await tester.pumpAndSettle();

      expect(find.text('Price List'), findsAtLeastNWidgets(1));
      expect(find.text('View our current services and prices.'), findsOneWidget);
    });
  });
}
