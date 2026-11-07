import 'package:flutter/foundation.dart';
import '../../../data/models/address_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../cart/presentation/cart_controller.dart';

class CheckoutController extends ChangeNotifier {
  final AddressRepository _addressRepository;
  final OrderRepository _orderRepository;

  List<AddressModel> _savedAddresses = [];
  AddressModel? _selectedAddress;
  String _customAddress = '';
  DateTime _selectedPickupDate = DateTime.now().add(const Duration(days: 1));
  String _selectedPickupTime = '10:00 AM - 12:00 PM';
  Map<String, dynamic> _selectedBranch = {
    'id': 'vijaynagar-mysuru',
    'name': 'Vijaynagar Outlet, Mysuru',
  };
  String _paymentMethod = 'Cash on Delivery';

  bool _isLoadingAddresses = false;
  bool _isSubmittingOrder = false;
  String? _errorMessage;
  OrderModel? _createdOrder;

  List<AddressModel> get savedAddresses => _savedAddresses;
  AddressModel? get selectedAddress => _selectedAddress;
  String get customAddress => _customAddress;
  DateTime get selectedPickupDate => _selectedPickupDate;
  String get selectedPickupTime => _selectedPickupTime;
  Map<String, dynamic> get selectedBranch => _selectedBranch;
  String get paymentMethod => _paymentMethod;
  bool get isLoadingAddresses => _isLoadingAddresses;
  bool get isSubmittingOrder => _isSubmittingOrder;
  String? get errorMessage => _errorMessage;
  OrderModel? get createdOrder => _createdOrder;

  static const List<Map<String, dynamic>> availableBranches = [
    {'id': 'vijaynagar-mysuru', 'name': 'Vijaynagar Outlet, Mysuru'},
    {'id': 'saraswathipuram-mysuru', 'name': 'Saraswathipuram Outlet, Mysuru'},
  ];

  static const List<String> availableTimeSlots = [
    '09:00 AM - 11:00 AM',
    '11:00 AM - 01:00 PM',
    '02:00 PM - 04:00 PM',
    '04:00 PM - 06:00 PM',
    '06:00 PM - 08:00 PM',
  ];

  CheckoutController({
    AddressRepository? addressRepository,
    OrderRepository? orderRepository,
  })  : _addressRepository = addressRepository ?? AddressRepository(),
        _orderRepository = orderRepository ?? OrderRepository();

  /// Formats selected pickup date as YYYY-MM-DD
  String get formattedPickupDate {
    final year = _selectedPickupDate.year;
    final month = _selectedPickupDate.month.toString().padLeft(2, '0');
    final day = _selectedPickupDate.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Loads saved delivery addresses for logged-in user
  Future<void> loadSavedAddresses(String? token) async {
    if (token == null || token.isEmpty) return;

    _isLoadingAddresses = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final addresses = await _addressRepository.fetchAddresses(token);
      _savedAddresses = addresses;
      if (addresses.isNotEmpty) {
        _selectedAddress = addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        );
      }
      _isLoadingAddresses = false;
      notifyListeners();
    } catch (e) {
      _isLoadingAddresses = false;
      notifyListeners();
    }
  }

  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void setCustomAddress(String address) {
    _customAddress = address.trim();
    notifyListeners();
  }

  /// Adds a new delivery address via backend API
  Future<bool> addNewAddress(
    String token, {
    required String fullAddress,
    String label = 'Home',
    String houseNo = '',
    String street = '',
    String landmark = '',
    String pincode = '',
  }) async {
    try {
      final updatedAddresses = await _addressRepository.addAddress(
        token,
        fullAddress: fullAddress,
        label: label,
        houseNo: houseNo,
        street: street,
        landmark: landmark,
        pincode: pincode,
        isDefault: _savedAddresses.isEmpty,
      );
      _savedAddresses = updatedAddresses;
      if (updatedAddresses.isNotEmpty) {
        _selectedAddress = updatedAddresses.last;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('ApiException: ', '').trim();
      notifyListeners();
      return false;
    }
  }

  void setPickupDate(DateTime date) {
    _selectedPickupDate = date;
    notifyListeners();
  }

  void setPickupTime(String timeSlot) {
    _selectedPickupTime = timeSlot;
    notifyListeners();
  }

  void setBranch(Map<String, dynamic> branch) {
    if (availableBranches.any((b) => b['id'] == branch['id'])) {
      _selectedBranch = branch;
      notifyListeners();
    }
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  /// Submits the order booking to backend POST /api/orders
  Future<bool> placeOrder({
    required CartController cartController,
    required AuthController authController,
    String? manualName,
    String? manualPhone,
    String? manualAddress,
  }) async {
    if (_isSubmittingOrder) return false; // Guard against duplicate submissions

    if (cartController.isEmpty) {
      _errorMessage = 'Cart is empty. Please add items before placing an order.';
      notifyListeners();
      return false;
    }

    final name = (authController.currentCustomer?.name?.trim().isNotEmpty == true)
        ? authController.currentCustomer!.name!
        : (manualName?.trim() ?? 'Customer');

    final phone = (authController.currentCustomer?.phone.trim().isNotEmpty == true)
        ? authController.currentCustomer!.phone
        : (manualPhone?.trim() ?? '');

    final addressStr = _selectedAddress?.fullAddress ??
        (_customAddress.isNotEmpty ? _customAddress : (manualAddress?.trim() ?? ''));

    if (name.isEmpty || phone.isEmpty || addressStr.isEmpty) {
      _errorMessage = 'Customer name, phone, and delivery address are required.';
      notifyListeners();
      return false;
    }

    _isSubmittingOrder = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Guard against placing an order with the closed Kuvempunagar outlet
      if (_selectedBranch['id'] == 'kuvempunagar-mysuru' ||
          _selectedBranch['id'] == 'kuvempunagar-1st-stage-mysuru' ||
          _selectedBranch['name']?.toString().toLowerCase().contains('kuvempu') == true) {
        _selectedBranch = availableBranches.first;
      }

      final customerPayload = {
        'name': name,
        'phone': phone,
        'address': addressStr,
      };

      final order = await _orderRepository.createOrder(
        token: authController.token,
        customer: customerPayload,
        items: cartController.items,
        totalAmount: cartController.subtotal,
        pickupDate: formattedPickupDate,
        pickupTime: _selectedPickupTime,
        paymentMethod: _paymentMethod,
        paymentStatus: _paymentMethod == 'QR Payment' ? 'Paid' : 'Pending',
        selectedBranch: _selectedBranch,
        recommendedBranch: _selectedBranch,
      );

      _createdOrder = order;

      // CLEAR CART ONLY AFTER SUCCESSFUL ORDER CREATION
      cartController.clearCart();

      _isSubmittingOrder = false;
      notifyListeners();
      return true;
    } catch (e) {
      // DO NOT CLEAR CART ON FAILURE
      _errorMessage = e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', '').trim();
      _isSubmittingOrder = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
