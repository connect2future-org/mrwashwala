import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../features/addresses/presentation/address_controller.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/cart/presentation/cart_controller.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/orders/presentation/customer_order_controller.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/reviews/presentation/customer_review_controller.dart';
import '../../features/services/presentation/service_controller.dart';
import '../../features/services/presentation/services_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final AuthController authController;
  final CartController? cartController;
  final ServiceController? serviceController;
  final CustomerOrderController? orderController;
  final AddressController? addressController;
  final CustomerReviewController? reviewController;

  const MainNavigationScreen({
    super.key,
    required this.authController,
    this.cartController,
    this.serviceController,
    this.orderController,
    this.addressController,
    this.reviewController,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late final CartController _cartController;
  late final ServiceController _serviceController;
  late final CustomerOrderController _orderController;
  late final AddressController _addressController;
  late final CustomerReviewController _reviewController;

  @override
  void initState() {
    super.initState();
    _cartController = widget.cartController ?? CartController(storageService: SecureStorageService());
    _cartController.loadSavedCart();
    _serviceController = widget.serviceController ?? ServiceController();
    _orderController = widget.orderController ?? CustomerOrderController();
    _addressController = widget.addressController ?? AddressController();
    _reviewController = widget.reviewController ?? CustomerReviewController();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        serviceController: _serviceController,
        cartController: _cartController,
        onNavigateTab: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      ServicesScreen(
        serviceController: _serviceController,
        cartController: _cartController,
        onViewCart: () {
          setState(() {
            _currentIndex = 2;
          });
        },
      ),
      CartScreen(
        cartController: _cartController,
        authController: widget.authController,
        onBrowseServices: () {
          _serviceController.setCategory('Wash & Fold');
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      OrdersScreen(
        authController: widget.authController,
        orderController: _orderController,
        onExploreServices: () {
          _serviceController.setCategory('Wash & Fold');
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      ProfileScreen(
        authController: widget.authController,
        addressController: _addressController,
        orderController: _orderController,
        reviewController: _reviewController,
      ),
    ];

    return ListenableBuilder(
      listenable: _cartController,
      builder: (context, child) {
        final totalCartQuantity = _cartController.totalQuantity;

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              if (index == 1 && _currentIndex != 1) {
                _serviceController.setCategory('Wash & Fold');
              }
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.white,
            indicatorColor: AppColors.cobaltLight,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: AppColors.cobaltBlue),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.local_laundry_service_outlined),
                selectedIcon: Icon(Icons.local_laundry_service, color: AppColors.cobaltBlue),
                label: 'Services',
              ),
              NavigationDestination(
                icon: totalCartQuantity > 0
                    ? Badge(
                        label: Text('$totalCartQuantity'),
                        backgroundColor: AppColors.cobaltBlue,
                        child: const Icon(Icons.shopping_bag_outlined),
                      )
                    : const Icon(Icons.shopping_bag_outlined),
                selectedIcon: totalCartQuantity > 0
                    ? Badge(
                        label: Text('$totalCartQuantity'),
                        backgroundColor: AppColors.cobaltBlue,
                        child: const Icon(Icons.shopping_bag, color: AppColors.accentCyan),
                      )
                    : const Icon(Icons.shopping_bag, color: AppColors.accentCyan),
                label: 'Cart',
              ),
              const NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long, color: AppColors.cobaltBlue),
                label: 'Orders',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: AppColors.cobaltBlue),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
