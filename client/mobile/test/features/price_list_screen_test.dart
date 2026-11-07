import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/repositories/service_repository.dart';
import 'package:mrwashwala_mobile/features/price_list/presentation/price_list_controller.dart';
import 'package:mrwashwala_mobile/features/price_list/presentation/price_list_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('PriceListScreen Widget Tests', () {
    const sampleServicesJson = '''[
      {
        "id": "wash-fold",
        "name": "Wash & Fold Regular Care",
        "unit": "kg",
        "price": 59,
        "displayType": "main",
        "customizeCategory": ""
      },
      {
        "id": "dryclean-shirt",
        "name": "Formal Cotton & Linen Shirt",
        "unit": "item",
        "price": 90,
        "displayType": "customize",
        "customizeCategory": "Dry Clean",
        "hasStainRemoval": true,
        "stainRemovalPrice": 130
      },
      {
        "id": "shoeclean-sports",
        "name": "Sports Shoes",
        "unit": "pair",
        "price": 159,
        "displayType": "customize",
        "customizeCategory": "Shoe Cleaning",
        "hasPremiumClean": true,
        "premiumCleanPrice": 220
      }
    ]''';

    Widget createTestWidget({required PriceListController controller}) {
      return MaterialApp(
        home: PriceListScreen(controller: controller),
      );
    }

    testWidgets('Renders header, title, subtitle, and grouped categories with prices',
        (tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(sampleServicesJson, 200);
      });
      final repo = ServiceRepository(apiClient: ApiClient(client: mockClient));
      final controller = PriceListController(serviceRepository: repo);

      await tester.pumpWidget(createTestWidget(controller: controller));
      await tester.pumpAndSettle();

      // 1. Header & Title
      expect(find.text('Price List'), findsOneWidget);
      expect(find.text('View our current services and prices.'), findsOneWidget);

      // 2. Pricing info banner
      expect(find.text('Transparent & Honest Pricing'), findsOneWidget);

      // 3. Category headers
      expect(find.text('Dry Clean'), findsOneWidget);
      expect(find.text('Shoe Cleaning'), findsOneWidget);

      // 4. Service names
      expect(find.text('Wash & Fold Regular Care'), findsOneWidget);
      expect(find.text('Formal Cotton & Linen Shirt'), findsOneWidget);
      expect(find.text('Sports Shoes'), findsOneWidget);

      // 5. Prices and units
      expect(find.text('₹59'), findsOneWidget);
      expect(find.text('per kg'), findsOneWidget);

      expect(find.text('₹90'), findsOneWidget);
      expect(find.text('per item'), findsOneWidget);

      expect(find.text('₹159'), findsOneWidget);
      expect(find.text('per pair'), findsOneWidget);

      // 6. Add-ons
      expect(find.text('+ ₹130 Stain Removal'), findsOneWidget);
      expect(find.text('+ ₹220 Premium Clean'), findsOneWidget);
    });

    testWidgets('Renders empty state with refresh button when catalogue is empty',
        (tester) async {
      final mockClient = MockClient((request) async {
        return http.Response('[]', 200);
      });
      final repo = ServiceRepository(apiClient: ApiClient(client: mockClient));
      final controller = PriceListController(serviceRepository: repo);

      await tester.pumpWidget(createTestWidget(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('No Services Available'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
    });

    testWidgets('Renders error state with retry button on network failure',
        (tester) async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Down', 500);
      });
      final repo = ServiceRepository(apiClient: ApiClient(client: mockClient));
      final controller = PriceListController(serviceRepository: repo);

      await tester.pumpWidget(createTestWidget(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('Unable to Load Prices'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('Renders warning banner when pull-to-refresh fails with existing data',
        (tester) async {
      int calls = 0;
      final mockClient = MockClient((request) async {
        calls++;
        if (calls == 1) {
          return http.Response(sampleServicesJson, 200);
        }
        return http.Response('Offline', 500);
      });
      final repo = ServiceRepository(apiClient: ApiClient(client: mockClient));
      final controller = PriceListController(serviceRepository: repo);

      await tester.pumpWidget(createTestWidget(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('Wash & Fold Regular Care'), findsOneWidget);

      // Trigger refresh which fails
      await controller.loadPriceList(isRefresh: true);
      await tester.pumpAndSettle();

      // Data is still visible
      expect(find.text('Wash & Fold Regular Care'), findsOneWidget);

      // Warning banner is displayed
      expect(
        find.text('Could not refresh prices. Showing previously loaded price list.'),
        findsOneWidget,
      );
    });

    testWidgets('Back button pops navigation cleanly', (tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(sampleServicesJson, 200);
      });
      final repo = ServiceRepository(apiClient: ApiClient(client: mockClient));
      final controller = PriceListController(serviceRepository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PriceListScreen(controller: controller),
                    ),
                  );
                },
                child: const Text('Open Price List'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Price List'));
      await tester.pumpAndSettle();

      expect(find.text('Price List'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Open Price List'), findsOneWidget);
    });
  });
}
