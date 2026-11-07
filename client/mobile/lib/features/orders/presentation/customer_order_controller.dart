import 'package:flutter/foundation.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/customer_order_repository.dart';

class CustomerOrderController extends ChangeNotifier {
  final CustomerOrderRepository _orderRepository;

  bool _isLoading = false;
  String? _errorMessage;
  List<OrderModel> _orders = [];
  int _totalOrders = 0;
  int _currentPage = 1;
  int _totalPages = 1;
  String _selectedStatusFilter = 'All';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<OrderModel> get orders => _orders;
  int get totalOrders => _totalOrders;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String get selectedStatusFilter => _selectedStatusFilter;
  bool get isEmpty => _orders.isEmpty && !_isLoading;

  static const List<String> statusFilterOptions = [
    'All',
    'Pending',
    'Picked Up',
    'In Process',
    'Out for Delivery',
    'Delivered',
    'Cancelled',
  ];

  CustomerOrderController({CustomerOrderRepository? orderRepository})
      : _orderRepository = orderRepository ?? CustomerOrderRepository();

  /// Fetches authenticated customer orders from backend
  Future<void> fetchOrders(String? token, {bool refresh = false}) async {
    if (token == null || token.isEmpty) {
      _orders = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (refresh) {
      _currentPage = 1;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _orderRepository.fetchCustomerOrders(
        token,
        page: _currentPage,
        statusFilter: _selectedStatusFilter,
      );

      _orders = res.orders;
      _totalOrders = res.totalOrders;
      _currentPage = res.page;
      _totalPages = res.totalPages;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', '').trim();
      notifyListeners();
    }
  }

  void setStatusFilter(String? token, String filter) {
    if (_selectedStatusFilter == filter) return;
    _selectedStatusFilter = filter;
    fetchOrders(token, refresh: true);
  }

  /// Fetches single order detail by orderId
  Future<OrderModel?> fetchOrderDetails(String? token, String orderId) async {
    if (token == null || token.isEmpty) return null;
    try {
      return await _orderRepository.fetchOrderDetails(token, orderId);
    } catch (_) {
      return null;
    }
  }
}
