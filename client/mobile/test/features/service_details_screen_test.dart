import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mrwashwala_mobile/data/models/service_model.dart';
import 'package:mrwashwala_mobile/features/cart/presentation/cart_controller.dart';
import 'package:mrwashwala_mobile/features/services/presentation/service_details_screen.dart';

void main() {
  group('ServiceDetailsScreen Widget Tests', () {
    late CartController cartController;

    final testService = ServiceModel(
      id: 'dryclean-suit',
      name: '2-Piece Suit Dry Cleaning',
      price: 450.0,
      unit: 'set',
      displayType: 'main',
      customizeCategory: 'Dry Cleaning',
      hasStainRemoval: true,
      stainRemovalPrice: 50.0,
      hasPremiumClean: true,
      premiumCleanPrice: 100.0,
      features: ['Steam pressing included', 'Antiseptic wash', 'Protective cover'],
    );

    setUp(() {
      cartController = CartController();
    });

    testWidgets('Renders service details, price, features and initial quantity', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailsScreen(
            service: testService,
            cartController: cartController,
          ),
        ),
      );

      expect(find.text('2-Piece Suit Dry Cleaning'), findsWidgets);
      expect(find.text('₹450 / set'), findsOneWidget);
      expect(find.text('DRY CLEANING'), findsOneWidget);
      expect(find.text('Steam pressing included'), findsOneWidget);
      expect(find.text('Antiseptic wash'), findsOneWidget);
      expect(find.text('Protective cover'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Total Price'), findsOneWidget);
      expect(find.text('₹450'), findsOneWidget);
    });

    testWidgets('Increments and decrements quantity correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailsScreen(
            service: testService,
            cartController: cartController,
          ),
        ),
      );

      // Increment
      final addIcon = find.byIcon(Icons.add);
      await tester.tap(addIcon);
      await tester.pump();

      expect(find.text('2'), findsOneWidget);
      expect(find.text('₹900'), findsOneWidget);

      // Decrement
      final removeIcon = find.byIcon(Icons.remove);
      await tester.tap(removeIcon);
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('₹450'), findsOneWidget);

      // Attempt to decrement below 1 (should stay 1)
      await tester.tap(removeIcon);
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('₹450'), findsOneWidget);
    });

    testWidgets('Toggling add-on checkboxes recalculates total price and adds to cart', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailsScreen(
            service: testService,
            cartController: cartController,
          ),
        ),
      );

      // Toggle Stain Removal (+₹50)
      final stainRemovalTile = find.text('Stain Removal Treatment');
      expect(stainRemovalTile, findsOneWidget);
      await tester.tap(stainRemovalTile);
      await tester.pump();

      // Price should now be 450 + 50 = 500
      expect(find.text('₹500'), findsOneWidget);

      // Tap Add to Cart
      final addToCartBtn = find.text('Add to Cart');
      await tester.tap(addToCartBtn);
      await tester.pump();

      expect(cartController.items.length, equals(1));
      expect(cartController.items.first.lineTotal, equals(500.0));
      expect(cartController.items.first.stainRemoval, isTrue);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
