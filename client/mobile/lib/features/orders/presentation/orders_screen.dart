import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/order_status_helper.dart';
import '../../../data/models/order_model.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/phone_screen.dart';
import '../../reviews/presentation/customer_review_controller.dart';
import 'customer_order_controller.dart';
import 'order_details_screen.dart';

/// Phase 9G — Premium My Orders Screen UI Redesign
class OrdersScreen extends StatefulWidget {
  final AuthController? authController;
  final CustomerOrderController? orderController;
  final CustomerReviewController? reviewController;
  final VoidCallback? onExploreServices;

  const OrdersScreen({
    super.key,
    this.authController,
    this.orderController,
    this.reviewController,
    this.onExploreServices,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late final CustomerOrderController _controller;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.orderController ?? CustomerOrderController();
    _fetchOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchOrders() {
    final token = widget.authController?.token;
    if (token != null && token.isNotEmpty) {
      _controller.fetchOrders(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = widget.authController;
    final bool isLoggedIn = authController?.isAuthenticated ?? false;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: _buildAppBar(context, isLoggedIn, authController?.token),
          body: !isLoggedIn
              ? _buildUnauthenticatedState(context)
              : _buildOrdersContent(context),
        );
      },
    );
  }

  // ==========================================
  // 1. Premium Branded Screen Header / AppBar
  // ==========================================
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isLoggedIn, String? token) {
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      backgroundColor: AppColors.surfaceWhite,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: canPop,
      leading: canPop
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 19,
                color: AppColors.cobaltBlue,
              ),
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.cobaltLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.cobaltBlue,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Orders',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cobaltBlue,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  _controller.orders.isNotEmpty
                      ? '${_controller.totalOrders > 0 ? _controller.totalOrders : _controller.orders.length} ${_controller.orders.length == 1 ? "booking" : "bookings"} recorded'
                      : 'Doorstep Laundry History',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (isLoggedIn)
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 21, color: AppColors.cobaltBlue),
            tooltip: 'Refresh Orders',
            onPressed: () => _controller.fetchOrders(token, refresh: true),
          ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.cardBorder,
          height: 1,
        ),
      ),
    );
  }

  // ==========================================
  // 2. Unauthenticated State
  // ==========================================
  Widget _buildUnauthenticatedState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding * 1.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.cobaltLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.4), width: 1.5),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 56,
                color: AppColors.cobaltBlue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sign In to View Orders',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.cobaltBlue,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Login with your mobile number to view active laundry bookings, tracking, and past orders.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (widget.authController != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PhoneScreen(authController: widget.authController!),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text(
                  'Sign In with Mobile OTP',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cobaltBlue,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 3. Orders Content (Search + Filters + List)
  // ==========================================
  Widget _buildOrdersContent(BuildContext context) {
    // 3A. Loading state
    if (_controller.isLoading && _controller.orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.cobaltBlue,
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Fetching your orders...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.cobaltBlue,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Connecting to Mr. WashWala Mysuru',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    // 3B. Error state
    if (_controller.errorMessage != null && _controller.orders.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 48,
                  color: AppColors.errorRed,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to Load Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.cobaltBlue,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _controller.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _fetchOrders,
                  icon: const Icon(Icons.refresh_rounded, size: 17),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cobaltBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final orders = _controller.orders;

    // Filter in-memory by search query (order ID or service name)
    final filteredOrders = _searchQuery.trim().isEmpty
        ? orders
        : orders.where((order) {
            final q = _searchQuery.trim().toLowerCase();
            final matchesId = order.orderId.toLowerCase().contains(q);
            final matchesSummary = order.orderSummary.toLowerCase().contains(q);
            final matchesItem = order.items.any((item) => item.name.toLowerCase().contains(q));
            final matchesDate = order.pickupDate.toLowerCase().contains(q);
            return matchesId || matchesSummary || matchesItem || matchesDate;
          }).toList();

    return RefreshIndicator(
      color: AppColors.cobaltBlue,
      backgroundColor: Colors.white,
      onRefresh: () async {
        await _controller.fetchOrders(widget.authController?.token, refresh: true);
      },
      child: Column(
        children: [
          // Client-side Search Bar
          if (orders.isNotEmpty || _searchQuery.isNotEmpty)
            _buildSearchBar(),

          // Status Filter Chips Row
          _buildStatusFilterBar(),

          // Orders List or Empty State
          Expanded(
            child: orders.isEmpty
                ? _buildEmptyState(context)
                : filteredOrders.isEmpty
                    ? _buildNoSearchResultsState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return _buildOrderCard(context, order);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. Client-side Search Bar
  // ==========================================
  Widget _buildSearchBar() {
    return Container(
      color: AppColors.surfaceWhite,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: SizedBox(
        height: 42,
        child: TextField(
          controller: _searchController,
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search by Order ID or Service...',
            hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textSecondary),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.textSecondary),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.backgroundLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.cobaltBlue, width: 1.2),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 5. Status Filter Bar
  // ==========================================
  Widget _buildStatusFilterBar() {
    final filterOptions = CustomerOrderController.statusFilterOptions;

    return Container(
      height: 48,
      color: AppColors.surfaceWhite,
      alignment: Alignment.centerLeft,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: filterOptions.length,
        itemBuilder: (context, index) {
          final filter = filterOptions[index];
          final isSelected = _controller.selectedStatusFilter == filter;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                _controller.setStatusFilter(widget.authController?.token, filter);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.cobaltBlue : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.cobaltBlue : AppColors.cardBorder,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.cobaltBlue.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.cobaltBlue,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // 6. Premium Order Card
  // ==========================================
  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final statusColor = OrderStatusHelper.getStatusColor(order.status);
    final statusLabel = OrderStatusHelper.getStatusLabel(order.status);
    final statusIcon = OrderStatusHelper.getStatusIcon(order.status);
    final isCancelled = order.status == 'Cancelled';
    final isPaid = order.paymentStatus.toLowerCase() == 'paid';
    final paymentStatusColor = isPaid ? AppColors.successGreen : AppColors.warningOrange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCancelled
              ? AppColors.errorRed.withValues(alpha: 0.3)
              : AppColors.cardBorder,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _navigateToDetails(context, order),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Order ID + Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.cobaltLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          size: 14,
                          color: AppColors.cobaltBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order.orderId.isNotEmpty ? '#${order.orderId}' : 'Booking Reference',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cobaltBlue,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 11, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Row 2: Service items summary chip
              if (order.items.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_laundry_service_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.items.map((i) => '${i.name} (${i.quantity} ${i.unit})').join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cobaltBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Text(
                          '${order.items.length} ${order.items.length == 1 ? "service" : "services"}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ] else if (order.orderSummary.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.orderSummary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cobaltBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Row 3: Pickup schedule
              if (order.pickupDate.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Pickup: ${order.pickupDate}${order.pickupTime.isNotEmpty ? ' • ${order.pickupTime}' : ""}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else if (order.formattedCreatedDate.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Placed on ${order.formattedCreatedDate}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              // Row 4: Payment method and status
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    order.paymentMethod.isNotEmpty ? order.paymentMethod : 'Cash on Delivery',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: paymentStatusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.paymentStatus.isNotEmpty ? order.paymentStatus : 'Pending',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: paymentStatusColor,
                      ),
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
              ),

              // Row 5: Total Amount + View Details Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        order.formattedTotal,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cobaltBlue,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => _navigateToDetails(context, order),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.cobaltLight.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.skyBlue.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.cobaltBlue,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 11,
                            color: AppColors.cobaltBlue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 7. Empty State (No orders placed yet)
  // ==========================================
  Widget _buildEmptyState(BuildContext context) {
    final isFiltered = _controller.selectedStatusFilter != 'All';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.cobaltLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.35), width: 1.5),
              ),
              child: Icon(
                isFiltered ? Icons.filter_alt_off_rounded : Icons.receipt_long_rounded,
                size: 52,
                color: AppColors.cobaltBlue,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isFiltered ? 'No ${_controller.selectedStatusFilter} Orders' : 'No Orders Yet',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.cobaltBlue,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'You do not have any orders currently marked as "${_controller.selectedStatusFilter}".'
                  : "You haven't placed any laundry orders with Mr. WashWala yet. Book a fresh doorstep pickup today!",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 22),
            if (isFiltered)
              SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _controller.setStatusFilter(widget.authController?.token, 'All');
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Show All Orders'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.cobaltBlue,
                    side: const BorderSide(color: AppColors.cobaltBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (widget.onExploreServices != null) {
                      widget.onExploreServices!();
                    } else if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: const Text(
                    'Explore Services',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cobaltBlue,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 8. No Search Results State
  // ==========================================
  Widget _buildNoSearchResultsState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 44,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Orders Found',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.cobaltBlue,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No orders match "$_searchQuery".',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              child: const Text('Clear Search', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 9. Navigation to Order Details
  // ==========================================
  void _navigateToDetails(BuildContext context, OrderModel order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(
          order: order,
          token: widget.authController?.token,
          reviewController: widget.reviewController,
        ),
      ),
    );
  }
}
