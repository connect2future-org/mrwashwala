import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../models/order_model.dart';

class CustomerOrdersResponse {
  final int totalOrders;
  final int page;
  final int totalPages;
  final List<OrderModel> orders;

  CustomerOrdersResponse({
    required this.totalOrders,
    required this.page,
    required this.totalPages,
    required this.orders,
  });
}

class CustomerOrderRepository {
  final ApiClient _apiClient;

  CustomerOrderRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches order history for the authenticated customer.
  Future<CustomerOrdersResponse> fetchCustomerOrders(
    String token, {
    int page = 1,
    int limit = 10,
    String? statusFilter,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (statusFilter != null && statusFilter.isNotEmpty && statusFilter != 'All') {
      queryParams['status'] = statusFilter;
    }

    final queryString = Uri(queryParameters: queryParams).query;
    final url = '${ApiConfig.orders}?$queryString';

    final response = await _apiClient.get(url, token: token);

    if (response is Map<String, dynamic> && response['data'] is List) {
      final rawList = response['data'] as List;
      final orders = rawList
          .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return CustomerOrdersResponse(
        totalOrders: response['totalOrders'] ?? orders.length,
        page: response['page'] ?? page,
        totalPages: response['totalPages'] ?? 1,
        orders: orders,
      );
    }

    throw Exception('Unexpected response format when fetching customer orders');
  }

  /// Fetches details for a single order by orderId.
  Future<OrderModel> fetchOrderDetails(String token, String orderId) async {
    final url = '${ApiConfig.orders}/$orderId';
    final response = await _apiClient.get(url, token: token);

    if (response is Map<String, dynamic> && response['data'] != null) {
      return OrderModel.fromJson(response['data'] as Map<String, dynamic>);
    }

    throw Exception('Failed to fetch order details');
  }
}
