import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/repositories/service_repository.dart';

void main() {
  group('ServiceRepository Tests', () {
    test('fetchServices returns list of ServiceModels on 200 OK', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/services'));
        return http.Response(
          jsonEncode([
            {
              '_id': 's1',
              'id': 'wash-fold',
              'name': 'Wash & Fold',
              'price': 59,
              'unit': 'kg',
              'displayType': 'main',
              'featured': true,
              'features': ['Washed', 'Dried', 'Folded'],
            },
            {
              '_id': 's2',
              'id': 'dryclean-saree',
              'name': 'Saree Dry Clean',
              'price': 300,
              'unit': 'item',
              'displayType': 'customize',
              'customizeCategory': 'Dry Clean',
              'customizeSubcategory': "Women's Wear",
              'features': ['Dry clean', 'Fabric care'],
            }
          ]),
          200,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = ServiceRepository(apiClient: apiClient);

      final services = await repo.fetchServices();
      expect(services.length, 2);
      expect(services[0].id, 'wash-fold');
      expect(services[0].price, 59.0);
      expect(services[0].formattedPrice, '₹59 / kg');
      expect(services[1].customizeCategory, 'Dry Clean');
    });

    test('fetchServices handles filter parameters correctly', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.queryParameters['displayType'], 'main');
        expect(request.url.queryParameters['featured'], 'true');
        return http.Response(jsonEncode([]), 200);
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = ServiceRepository(apiClient: apiClient);

      final services = await repo.fetchServices(displayType: 'main', featured: true);
      expect(services, isEmpty);
    });
  });
}
