import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/models/cart_item_model.dart';
import 'package:mrwashwala_mobile/data/repositories/order_repository.dart';

void main() {
  group('OrderRepository Unit Tests', () {
    test('createOrder sends exact payload and parses returned OrderModel', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, contains('/orders'));

        final body = jsonDecode(request.body);
        expect(body['customer']['name'], 'Jane Doe');
        expect(body['customer']['phone'], '9876543210');
        expect(body['customer']['address'], '123 Main St, Mysuru');
        expect(body['totalAmount'], 295.0);
        expect(body['pickupDate'], '2026-10-10');
        expect(body['pickupTime'], '10:00 AM - 12:00 PM');
        expect(body['paymentMethod'], 'Cash on Delivery');

        return http.Response(
          jsonEncode({
            '_id': 'order_mongo_id_123',
            'orderId': 'MRW-583920',
            'status': 'Pending',
            'totalAmount': 295,
            'paymentMethod': 'Cash on Delivery',
            'paymentStatus': 'Pending',
            'pickupDate': '2026-10-10',
            'pickupTime': '10:00 AM - 12:00 PM',
            'createdAt': '2026-10-07T14:00:00.000Z',
          }),
          201,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = OrderRepository(apiClient: apiClient);

      final cartItems = [
        CartItemModel(
          serviceId: 'wash-fold',
          name: 'Wash & Fold',
          price: 59.0,
          unit: 'kg',
          quantity: 5,
        ),
      ];

      final order = await repo.createOrder(
        customer: {
          'name': 'Jane Doe',
          'phone': '9876543210',
          'address': '123 Main St, Mysuru',
        },
        items: cartItems,
        totalAmount: 295.0,
        pickupDate: '2026-10-10',
        pickupTime: '10:00 AM - 12:00 PM',
      );

      expect(order.id, 'order_mongo_id_123');
      expect(order.orderId, 'MRW-583920');
      expect(order.status, 'Pending');
      expect(order.formattedTotal, '₹295');
    });
  });
}
