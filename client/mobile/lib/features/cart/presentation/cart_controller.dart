import 'package:flutter/foundation.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/service_model.dart';

class CartController extends ChangeNotifier {
  final SecureStorageService? storageService;
  final List<CartItemModel> _items = [];

  CartController({this.storageService});

  /// Loads saved cart items from storage on app launch.
  Future<void> loadSavedCart() async {
    if (storageService == null) return;
    try {
      final savedData = await storageService?.getCart();
      if (savedData != null && savedData.isNotEmpty) {
        _items.clear();
        for (final itemJson in savedData) {
          final item = CartItemModel.fromJson(itemJson);
          if (!item.serviceId.toLowerCase().contains('test') &&
              !item.name.toLowerCase().contains('test')) {
            _items.add(item);
          }
        }
        notifyListeners();
      }
    } catch (_) {
      // Non-blocking fallback
    }
  }

  void _persistCart() {
    if (storageService == null) return;
    try {
      final jsonList = _items.map((i) => i.toJson()).toList();
      storageService?.saveCart(jsonList);
    } catch (_) {
      // Non-blocking fallback
    }
  }

  List<CartItemModel> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get totalQuantity {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  int get uniqueItemCount => _items.length;

  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.lineTotal);
  }

  String get formattedSubtotal {
    if (subtotal == 0) return '₹0';
    return '₹${subtotal.toInt() == subtotal ? subtotal.toInt() : subtotal.toStringAsFixed(2)}';
  }

  /// Adds a service to the cart. If the service already exists, increases its quantity.
  /// Test services are blocked from being added to the cart for new orders.
  void addItem(
    ServiceModel service, {
    int quantity = 1,
    bool stainRemoval = false,
    bool premiumClean = false,
  }) {
    if (quantity <= 0 || service.isTestService) return;

    final index = _items.indexWhere((item) => item.serviceId == service.id);

    if (index >= 0) {
      final existing = _items[index];
      _items[index] = existing.copyWith(
        quantity: existing.quantity + quantity,
        stainRemoval: existing.stainRemoval || stainRemoval,
        premiumClean: existing.premiumClean || premiumClean,
      );
    } else {
      _items.add(
        CartItemModel.fromService(
          service,
          quantity: quantity,
          stainRemoval: stainRemoval,
          premiumClean: premiumClean,
        ),
      );
    }
    _persistCart();
    notifyListeners();
  }

  /// Updates quantity for a specific service ID. If quantity <= 0, removes the item.
  void updateQuantity(String serviceId, int quantity) {
    if (quantity <= 0) {
      removeItem(serviceId);
      return;
    }

    final index = _items.indexWhere((item) => item.serviceId == serviceId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      _persistCart();
      notifyListeners();
    }
  }

  /// Increments quantity of a cart item by 1.
  void incrementQuantity(String serviceId) {
    final index = _items.indexWhere((item) => item.serviceId == serviceId);
    if (index >= 0) {
      updateQuantity(serviceId, _items[index].quantity + 1);
    }
  }

  /// Decrements quantity of a cart item by 1. If quantity reaches 0, removes item.
  void decrementQuantity(String serviceId) {
    final index = _items.indexWhere((item) => item.serviceId == serviceId);
    if (index >= 0) {
      updateQuantity(serviceId, _items[index].quantity - 1);
    }
  }

  /// Removes an item from the cart by service ID.
  void removeItem(String serviceId) {
    _items.removeWhere((item) => item.serviceId == serviceId);
    _persistCart();
    notifyListeners();
  }

  /// Clears all items from the cart.
  void clearCart() {
    _items.clear();
    storageService?.clearCart();
    notifyListeners();
  }
  /// Returns the quantity of an item currently in the cart by service ID.
  int getItemQuantity(String serviceId) {
    final index = _items.indexWhere((item) => item.serviceId == serviceId);
    return index >= 0 ? _items[index].quantity : 0;
  }
}
