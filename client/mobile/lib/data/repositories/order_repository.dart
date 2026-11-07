import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';

class OrderRepository {
  final ApiClient _apiClient;

  OrderRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Submits an order booking to the backend POST /api/orders
  Future<OrderModel> createOrder({
    String? token,
    required Map<String, dynamic> customer,
    required List<CartItemModel> items,
    required double totalAmount,
    required String pickupDate,
    required String pickupTime,
    String paymentMethod = 'Cash on Delivery',
    String paymentStatus = 'Pending',
    Map<String, dynamic>? selectedBranch,
    Map<String, dynamic>? recommendedBranch,
    double? latitude,
    double? longitude,
  }) async {
    final formattedItems = items.map((item) {
      return {
        'name': item.name,
        'quantity': item.quantity,
        'price': item.price,
        'unit': item.unit,
      };
    }).toList();

    final defaultBranch = {
      'id': 'vijaynagar-mysuru',
      'name': 'Vijaynagar Outlet, Mysuru',
    };

    final body = {
      'customer': customer,
      'items': formattedItems,
      'totalAmount': totalAmount,
      'pickupDate': pickupDate,
      'pickupTime': pickupTime,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'latitude': latitude,
      'longitude': longitude,
      'selectedBranch': selectedBranch ?? defaultBranch,
      'recommendedBranch': recommendedBranch ?? defaultBranch,
    };

    final response = await _apiClient.post(
      ApiConfig.createOrder,
      token: token,
      body: body,
    );

    if (response is Map<String, dynamic>) {
      return OrderModel.fromJson(response);
    }

    throw Exception('Unexpected response format when creating order');
  }
}
