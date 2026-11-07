import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/repositories/customer_order_repository.dart';

void main() {
  group('CustomerOrderRepository Tests', () {
    test('fetchCustomerOrders returns paginated order list on 200 OK', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.headers['Authorization'], 'Bearer mock_jwt_token');
        expect(request.url.path, contains('/orders'));

        return http.Response(
          jsonEncode({
            'success': true,
            'count': 1,
            'totalOrders': 1,
            'page': 1,
            'totalPages': 1,
            'data': [
              {
                '_id': 'mongo_id_555',
                'orderId': 'MRW-583920',
                'status': 'In Process',
                'totalAmount': 800,
                'paymentMethod': 'Cash on Delivery',
                'paymentStatus': 'Pending',
                'pickupDate': '2026-10-10',
                'pickupTime': '10:00 AM - 12:00 PM',
                'items': [
                  {
                    'name': 'Wash & Fold',
                    'quantity': 5,
                    'price': 60,
                    'unit': 'Kg',
                  }
                ],
              }
            ],
          }),
          200,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = CustomerOrderRepository(apiClient: apiClient);

      final res = await repo.fetchCustomerOrders('mock_jwt_token');
      expect(res.totalOrders, 1);
      expect(res.orders.length, 1);
      expect(res.orders.first.orderId, 'MRW-583920');
      expect(res.orders.first.status, 'In Process');
      expect(res.orders.first.items.first.name, 'Wash & Fold');
    });

    test('fetchOrderDetails returns single OrderModel on 200 OK', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/orders/MRW-583920'));
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              '_id': 'mongo_id_555',
              'orderId': 'MRW-583920',
              'status': 'Delivered',
              'totalAmount': 800,
            }
          }),
          200,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = CustomerOrderRepository(apiClient: apiClient);

      final order = await repo.fetchOrderDetails('mock_jwt_token', 'MRW-583920');
      expect(order.orderId, 'MRW-583920');
      expect(order.status, 'Delivered');
    });
  });
}
