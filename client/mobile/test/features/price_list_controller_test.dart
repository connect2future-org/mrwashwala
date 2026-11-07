import 'package:flutter_test/flutter_test.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/repositories/service_repository.dart';
import 'package:mrwashwala_mobile/features/price_list/presentation/price_list_controller.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('PriceListController Unit Tests', () {
    test('Loads services, filters test service, and groups by actual category', () async {
      final mockJson = '''[
        {
          "id": "test-wash-fold",
          "name": "Wash & Fold Test",
          "unit": "Kg",
          "price": 60,
          "displayType": "main",
          "customizeCategory": ""
        },
        {
          "id": "wash-fold",
          "name": "Wash & Fold",
          "unit": "kg",
          "price": 59,
          "displayType": "main",
          "customizeCategory": ""
        },
        {
          "id": "dryclean-shirt",
          "name": "Shirt",
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

      final mockClient = MockClient((request) async {
        return http.Response(mockJson, 200);
      });

      final repository = ServiceRepository(apiClient: ApiClient(client: mockClient));
      final controller = PriceListController(serviceRepository: repository);

      await controller.loadPriceList();

      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.hasData, isTrue);

      // Verify test service is filtered out (only 3 genuine services remain)
      expect(controller.services.length, 3);
      expect(controller.services.any((s) => s.id == 'test-wash-fold'), isFalse);
      expect(controller.services.any((s) => s.id == 'wash-fold'), isTrue);

      // Verify grouping by actual category
      final grouped = controller.groupedServices;
      expect(grouped.containsKey('Wash & Fold'), isTrue);
      expect(grouped.containsKey('Dry Clean'), isTrue);
      expect(grouped.containsKey('Shoe Cleaning'), isTrue);

      // Verify item details, prices, and units
      final washFold = grouped['Wash & Fold']!.first;
      expect(washFold.price, 59.0);
      expect(washFold.unit, 'kg');

      final shirt = grouped['Dry Clean']!.first;
      expect(shirt.price, 90.0);
      expect(shirt.unit, 'item');
      expect(shirt.hasStainRemoval, isTrue);
      expect(shirt.stainRemovalPrice, 130.0);

      final shoes = grouped['Shoe Cleaning']!.first;
      expect(shoes.price, 159.0);
      expect(shoes.unit, 'pair');
      expect(shoes.hasPremiumClean, isTrue);
      expect(shoes.premiumCleanPrice, 220.0);
    });

    test('formatUnit formats different pricing units accurately', () {
      expect(PriceListController.formatUnit('kg'), 'per kg');
      expect(PriceListController.formatUnit('Kg'), 'per kg');
      expect(PriceListController.formatUnit('item'), 'per item');
      expect(PriceListController.formatUnit('pair'), 'per pair');
      expect(PriceListController.formatUnit('set'), 'per set');
      expect(PriceListController.formatUnit('carpet'), 'per carpet');
      expect(PriceListController.formatUnit('package'), 'per package');
      expect(PriceListController.formatUnit('piece'), 'per piece');
    });

    test('Handles empty catalogue gracefully', () async {
      final mockClient = MockClient((request) async {
        return http.Response('[]', 200);
      });

      final repository = ServiceRepository(apiClient: ApiClient(client: mockClient));
      final controller = PriceListController(serviceRepository: repository);

      await controller.loadPriceList();

      expect(controller.isLoading, isFalse);
      expect(controller.hasData, isFalse);
      expect(controller.isEmpty, isTrue);
      expect(controller.errorMessage, isNull);
    });

    test('Handles network failure on initial load', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final repository = ServiceRepository(apiClient: ApiClient(client: mockClient));
      final controller = PriceListController(serviceRepository: repository);

      await controller.loadPriceList();

      expect(controller.isLoading, isFalse);
      expect(controller.hasData, isFalse);
      expect(controller.errorMessage, isNotNull);
    });

    test('Pull-to-refresh updates prices and handles refresh failure gracefully', () async {
      int requestCount = 0;
      final mockClient = MockClient((request) async {
        requestCount++;
        if (requestCount == 1) {
          return http.Response('''[
            {
              "id": "wash-fold",
              "name": "Wash & Fold",
              "unit": "kg",
              "price": 59,
              "displayType": "main",
              "customizeCategory": ""
            }
          ]''', 200);
        } else if (requestCount == 2) {
          // Price updated from 59 to 65 by admin
          return http.Response('''[
            {
              "id": "wash-fold",
              "name": "Wash & Fold",
              "unit": "kg",
              "price": 65,
              "displayType": "main",
              "customizeCategory": ""
            }
          ]''', 200);
        } else {
          // Network failure on 3rd request
          return http.Response('Network Error', 500);
        }
      });

      final repository = ServiceRepository(apiClient: ApiClient(client: mockClient));
      final controller = PriceListController(serviceRepository: repository);

      // 1. Initial load
      await controller.loadPriceList();
      expect(controller.services.first.price, 59.0);

      // 2. Refresh with updated price
      await controller.loadPriceList(isRefresh: true);
      expect(controller.services.first.price, 65.0);
      expect(controller.refreshError, isNull);

      // 3. Refresh failure: retains existing data (price 65) and records refreshError
      await controller.loadPriceList(isRefresh: true);
      expect(controller.services.first.price, 65.0);
      expect(controller.hasData, isTrue);
      expect(controller.refreshError, isNotNull);
    });
  });
}
