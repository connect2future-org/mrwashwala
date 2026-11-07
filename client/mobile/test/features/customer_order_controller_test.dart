import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/repositories/customer_order_repository.dart';
import 'package:mrwashwala_mobile/features/orders/presentation/customer_order_controller.dart';

void main() {
  group('CustomerOrderController Tests', () {
    test('fetchOrders handles empty token cleanly', () async {
      final controller = CustomerOrderController();
      await controller.fetchOrders(null);

      expect(controller.orders, isEmpty);
      expect(controller.isLoading, isFalse);
    });

    test('fetchOrders parses backend orders response correctly', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'count': 1,
            'totalOrders': 1,
            'page': 1,
            'totalPages': 1,
            'data': [
              {
                '_id': 'ord_1',
                'orderId': 'MRW-100200',
                'status': 'Out for Delivery',
                'totalAmount': 450,
              }
            ],
          }),
          200,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = CustomerOrderRepository(apiClient: apiClient);
      final controller = CustomerOrderController(orderRepository: repo);

      await controller.fetchOrders('valid_token');

      expect(controller.orders.length, 1);
      expect(controller.orders.first.orderId, 'MRW-100200');
      expect(controller.orders.first.status, 'Out for Delivery');
    });
  });
}
