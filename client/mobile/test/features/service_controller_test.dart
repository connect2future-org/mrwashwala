import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/repositories/service_repository.dart';
import 'package:mrwashwala_mobile/features/services/presentation/service_controller.dart';

void main() {
  group('ServiceController Tests', () {
    test('loadServices parses and categorizes services into 5 primary categories without All', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {
              'id': 'wash-fold',
              'name': 'Wash & Fold',
              'price': 59,
              'unit': 'kg',
              'displayType': 'main',
            },
            {
              'id': 'dryclean-saree',
              'name': 'Saree',
              'price': 300,
              'unit': 'item',
              'displayType': 'customize',
              'customizeCategory': 'Dry Clean',
              'customizeSubcategory': "Women's Wear",
            }
          ]),
          200,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = ServiceRepository(apiClient: apiClient);
      final controller = ServiceController(serviceRepository: repo);

      await controller.loadServices();

      expect(controller.allServices.length, 2);
      expect(controller.mainServices.length, 1);

      // Verify categories contain only the 5 main categories, no "All"
      expect(controller.categories, [
        'Wash & Fold',
        'Dry Cleaning',
        'Shoe Cleaning',
        'Wash & Iron',
        'Customize Your Service',
      ]);
      expect(controller.categories.contains('All'), isFalse);

      // Verify default selection is Wash & Fold
      expect(controller.selectedCategory, 'Wash & Fold');
      expect(controller.filteredServices.length, 1);
      expect(controller.filteredServices[0].name, 'Wash & Fold');

      // Verify category switching to Dry Cleaning
      controller.setCategory('Dry Cleaning');
      expect(controller.selectedCategory, 'Dry Cleaning');
      expect(controller.subcategories, containsAll(['All', "Women's Wear"]));
      expect(controller.filteredServices.length, 1);
      expect(controller.filteredServices[0].name, 'Saree');

      // Verify empty state for categories with no matching items in mock
      controller.setCategory('Shoe Cleaning');
      expect(controller.selectedCategory, 'Shoe Cleaning');
      expect(controller.filteredServices, isEmpty);

      // Verify setting 'All' maps safely to default 'Wash & Fold'
      controller.setCategory('All');
      expect(controller.selectedCategory, 'Wash & Fold');
      expect(controller.filteredServices.length, 1);
    });

    test('Regression: Wash & Fold Test is excluded and genuine Wash & Fold (₹59/kg) remains visible', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {
              'id': 'test-wash-fold',
              'name': 'Wash & Fold Test',
              'price': 60,
              'unit': 'Kg',
              'displayType': 'main',
              'sortOrder': 0,
            },
            {
              'id': 'wash-fold',
              'name': 'Wash & Fold',
              'price': 59,
              'unit': 'kg',
              'displayType': 'main',
              'sortOrder': 1,
            },
            {
              'id': 'dryclean-saree',
              'name': 'Saree',
              'price': 300,
              'unit': 'item',
              'displayType': 'customize',
              'customizeCategory': 'Dry Clean',
              'sortOrder': 2,
            },
            {
              'id': 'wash-iron',
              'name': 'Wash & Iron',
              'price': 79,
              'unit': 'kg',
              'displayType': 'main',
              'sortOrder': 3,
            },
          ]),
          200,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = ServiceRepository(apiClient: apiClient);
      final controller = ServiceController(serviceRepository: repo);

      await controller.loadServices();

      // Ensure test service is excluded completely
      expect(controller.allServices.any((s) => s.id == 'test-wash-fold'), isFalse);
      expect(controller.allServices.any((s) => s.name.contains('Test')), isFalse);
      expect(controller.mainServices.any((s) => s.id == 'test-wash-fold'), isFalse);
      expect(controller.filteredServices.any((s) => s.name == 'Wash & Fold Test'), isFalse);

      // Ensure genuine services are preserved
      expect(controller.allServices.length, 3);
      final genuineWashFold = controller.filteredServices.firstWhere((s) => s.id == 'wash-fold');
      expect(genuineWashFold.name, 'Wash & Fold');
      expect(genuineWashFold.price, 59.0);
      expect(genuineWashFold.unit, 'kg');

      // Check other genuine services remain visible
      expect(controller.allServices.any((s) => s.id == 'wash-iron'), isTrue);
      expect(controller.allServices.any((s) => s.id == 'dryclean-saree'), isTrue);
    });
  });
}
