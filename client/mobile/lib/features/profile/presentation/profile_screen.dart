import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/address_model.dart';
import '../../../data/models/customer_model.dart';
import '../../addresses/presentation/add_edit_address_screen.dart';
import '../../addresses/presentation/address_controller.dart';
import '../../addresses/presentation/saved_addresses_screen.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/phone_screen.dart';
import '../../orders/presentation/customer_order_controller.dart';
import '../../orders/presentation/orders_screen.dart';
import '../../reviews/presentation/customer_review_controller.dart';
import '../../reviews/presentation/my_reviews_screen.dart';
import 'edit_profile_screen.dart';
import '../../price_list/presentation/price_list_screen.dart';
import '../../subscription/presentation/subscription_plans_screen.dart';

class ProfileScreen extends StatefulWidget {
  final AuthController authController;
  final AddressController addressController;
  final CustomerOrderController orderController;
  final CustomerReviewController reviewController;

  const ProfileScreen({
    super.key,
    required this.authController,
    required this.addressController,
    required this.orderController,
    required this.reviewController,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final token = widget.authController.token;
    if (widget.authController.isAuthenticated && token != null && token.isNotEmpty) {
      widget.addressController.loadAddresses(token);
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    final token = widget.authController.token;
    if (widget.authController.isAuthenticated && token != null && token.isNotEmpty) {
      await Future.wait([
        widget.authController.checkAuthStatus(),
        widget.addressController.loadAddresses(token),
      ]);
    }

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.authController, widget.addressController]),
      builder: (context, _) {
        final isLoggedIn = widget.authController.isAuthenticated;
        final customer = widget.authController.currentCustomer;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: _buildAppBar(context, isLoggedIn),
          body: (!isLoggedIn || customer == null)
              ? _buildUnauthenticatedState(context)
              : SafeArea(
                  child: RefreshIndicator(
                    color: AppColors.primaryNavy,
                    onRefresh: _handleRefresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultPadding,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Profile Hero Card
                          _buildProfileHeroCard(context, customer),

                          const SizedBox(height: 20),

                          // 2. Account Information Section
                          _buildAccountInfoSection(context, customer),

                          const SizedBox(height: 20),

                          // 3. Saved Addresses Section
                          _buildSavedAddressesSection(context),

                          const SizedBox(height: 20),

                          // 4. Activity & Orders Section
                          _buildActivitySection(context),

                          const SizedBox(height: 20),

                          // 5. Plans & Pricing Section
                          _buildServicesAndPlansSection(context),

                          const SizedBox(height: 20),

                          // 6. Support & Legal Section
                          _buildSupportSection(context),

                          const SizedBox(height: 24),

                          // 6. Sign Out Button
                          _buildSignOutButton(context),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isLoggedIn) {
    return AppBar(
      backgroundColor: AppColors.surfaceWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primaryNavy,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.iceBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primaryNavy,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
              Text(
                'Account & Preferences',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (isLoggedIn)
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryNavy,
                    ),
                  )
                : const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.primaryNavy,
                  ),
            tooltip: 'Refresh Profile',
            onPressed: _isRefreshing ? null : _handleRefresh,
          ),
      ],
    );
  }

  Widget _buildProfileHeroCard(BuildContext context, CustomerModel customer) {
    final name = customer.name?.trim().isNotEmpty == true
        ? customer.name!.trim()
        : 'Valued Customer';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'C';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primaryNavy,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryNavy,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.successGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 11,
                                  color: AppColors.successGreen,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'VERIFIED',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.successGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_iphone_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+91 ${customer.phone}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (customer.email != null && customer.email!.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                customer.email!.trim(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                      authController: widget.authController,
                    ),
                  ),
                );
              },
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppColors.primaryNavy,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Edit Personal Details',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoSection(BuildContext context, CustomerModel customer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(Icons.badge_outlined, size: 16, color: AppColors.primaryNavy),
              SizedBox(width: 6),
              Text(
                'Account Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoTile(
                icon: Icons.person_outline_rounded,
                label: 'Full Name',
                value: customer.name?.trim().isNotEmpty == true
                    ? customer.name!.trim()
                    : 'Valued Customer',
              ),
              const Divider(height: 1, color: AppColors.cardBorder),
              _buildInfoTile(
                icon: Icons.phone_outlined,
                label: 'Registered Mobile',
                value: '+91 ${customer.phone}',
                trailing: const Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const Divider(height: 1, color: AppColors.cardBorder),
              _buildInfoTile(
                icon: Icons.mail_outline_rounded,
                label: 'Email Address',
                value: customer.email?.trim().isNotEmpty == true
                    ? customer.email!.trim()
                    : 'Not provided',
                valueStyle: customer.email?.trim().isNotEmpty == true
                    ? null
                    : const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
              ),
              const Divider(height: 1, color: AppColors.cardBorder),
              _buildInfoTile(
                icon: Icons.verified_user_outlined,
                label: 'Account Status',
                value: customer.isActive ? 'Active & OTP Verified' : 'Inactive',
                trailing: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: customer.isActive ? AppColors.successGreen : AppColors.warningOrange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.iceBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primaryNavy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: valueStyle ??
                      const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryNavy,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildSavedAddressesSection(BuildContext context) {
    final addrCtrl = widget.addressController;
    final token = widget.authController.token;
    final defaultAddr = addrCtrl.defaultAddress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primaryNavy),
              const SizedBox(width: 6),
              const Text(
                'Saved Delivery Addresses',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
              const Spacer(),
              if (token != null && addrCtrl.hasAddresses)
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SavedAddressesScreen(
                          addressController: widget.addressController,
                          token: token,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'Manage (${addrCtrl.addresses.length}) >',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (addrCtrl.isLoading && !addrCtrl.hasAddresses)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Loading addresses...',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else if (defaultAddr != null && token != null)
          _buildAddressHighlightCard(context, defaultAddr, token, addrCtrl)
        else
          _buildEmptyAddressCard(context, token),
      ],
    );
  }

  Widget _buildAddressHighlightCard(
    BuildContext context,
    AddressModel addr,
    String token,
    AddressController ctrl,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: addr.isDefault ? AppColors.accentCyan : AppColors.cardBorder,
          width: addr.isDefault ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.iceBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      addr.label == 'Home'
                          ? Icons.home_outlined
                          : addr.label == 'Work'
                              ? Icons.work_outline
                              : Icons.location_city_outlined,
                      size: 13,
                      color: AppColors.primaryNavy,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      addr.label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (addr.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'DEFAULT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.successGreen,
                    ),
                  ),
                ),
              const Spacer(),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryNavy),
                tooltip: 'Edit Address',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddEditAddressScreen(
                        addressController: ctrl,
                        token: token,
                        addressToEdit: addr,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            addr.fullAddress,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryNavy,
            ),
          ),
          if (addr.houseNo.isNotEmpty || addr.street.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              [addr.houseNo, addr.street].where((s) => s.isNotEmpty).join(', '),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
          if (addr.landmark.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Near ${addr.landmark}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            '${addr.city} - ${addr.pincode}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryNavy,
                    side: const BorderSide(color: AppColors.cardBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SavedAddressesScreen(
                          addressController: ctrl,
                          token: token,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.list_alt_rounded, size: 16),
                  label: Text('All Addresses (${ctrl.addresses.length})', style: const TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.iceBlue,
                    foregroundColor: AppColors.primaryNavy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddEditAddressScreen(
                          addressController: ctrl,
                          token: token,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add New', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAddressCard(BuildContext context, String? token) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.iceBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off_outlined,
              size: 28,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'No Saved Addresses Yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Save your delivery address for 1-tap checkout and doorstep pickup.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          if (token != null)
            SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddEditAddressScreen(
                        addressController: widget.addressController,
                        token: token,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add_location_alt_outlined, size: 16),
                label: const Text('Add Delivery Address', style: TextStyle(fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(Icons.history_rounded, size: 16, color: AppColors.primaryNavy),
              SizedBox(width: 6),
              Text(
                'Orders & Activity',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
        ),
        _buildMenuCard(
          context,
          children: [
            _buildMenuItem(
              icon: Icons.receipt_long_rounded,
              title: 'My Orders',
              subtitle: 'Track active pickups, status & past invoices',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OrdersScreen(authController: widget.authController, 
                      orderController: widget.orderController, reviewController: widget.reviewController,
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 1, color: AppColors.cardBorder),
            _buildMenuItem(
              icon: Icons.star_outline_rounded,
              title: 'My Reviews',
              subtitle: 'Share feedback and manage past service reviews',
              onTap: () {
                final token = widget.authController.token;
                if (token != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MyReviewsScreen(
                        reviewController: widget.reviewController,
                        token: token,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServicesAndPlansSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(Icons.local_offer_outlined, size: 16, color: AppColors.primaryNavy),
              SizedBox(width: 6),
              Text(
                'Plans & Pricing',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
        ),
        _buildMenuCard(
          context,
          children: [
            _buildMenuItem(
              icon: Icons.receipt_long_rounded,
              title: 'Price List',
              subtitle: 'View current services and transparent prices',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PriceListScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 1, color: AppColors.cardBorder),
            _buildMenuItem(
              icon: Icons.card_membership_rounded,
              title: 'Subscription Plans',
              subtitle: 'Prepaid & regular plans • Coming Soon',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.iceBlue,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.skyBlue.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Text(
                      'SOON',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionPlansScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(Icons.help_outline_rounded, size: 16, color: AppColors.primaryNavy),
              SizedBox(width: 6),
              Text(
                'Support & App Info',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
        ),
        _buildMenuCard(
          context,
          children: [
            _buildMenuItem(
              icon: Icons.headset_mic_outlined,
              title: 'Customer Support',
              subtitle: 'Reach out via call or email (Mon - Sun, 8 AM - 8 PM)',
              onTap: () => _showHelpSupportDialog(context),
            ),
            const Divider(height: 1, color: AppColors.cardBorder),
            _buildMenuItem(
              icon: Icons.info_outline_rounded,
              title: 'About Mr. WashWala',
              subtitle: 'Version 1.0.0 (Android Build) • Mysuru Laundry Service',
              onTap: () => _showAboutDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.iceBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryNavy, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryNavy,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: trailing ??
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.errorRed,
          side: BorderSide(color: AppColors.errorRed.withValues(alpha: 0.4), width: 1.2),
          backgroundColor: AppColors.errorRed.withValues(alpha: 0.03),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => _confirmSignOut(context),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text(
          'Sign Out of Account',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedState(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: const BoxDecoration(
                  color: AppColors.iceBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_circle_outlined,
                  size: 64,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sign In to Your Account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage your profile, view saved addresses, and track active laundry orders in real-time.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PhoneScreen(
                          authController: widget.authController,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Sign In with Mobile OTP', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 28),
              const Divider(color: AppColors.cardBorder),
              const SizedBox(height: 16),
              _buildServicesAndPlansSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.errorRed),
            SizedBox(width: 8),
            Text('Sign Out?'),
          ],
        ),
        content: const Text('Are you sure you want to sign out of your Mr. WashWala account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.authController.logout();
    }
  }

  void _showHelpSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.headset_mic_outlined, color: AppColors.accentCyan),
            SizedBox(width: 8),
            Text('Customer Support', style: TextStyle(color: AppColors.primaryNavy)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need assistance with your order or services? Reach out to us:'),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone_rounded, size: 16, color: AppColors.primaryNavy),
                SizedBox(width: 8),
                Text('+91 98765 43210', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email_outlined, size: 16, color: AppColors.primaryNavy),
                SizedBox(width: 8),
                Text('support@mrwashwala.com', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 16, color: AppColors.primaryNavy),
                SizedBox(width: 8),
                Text('Mon - Sun: 8:00 AM - 8:00 PM'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.primaryNavy),
            SizedBox(width: 8),
            Text('About Mr. WashWala', style: TextStyle(color: AppColors.primaryNavy)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: 90,
                height: 90,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryNavy.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/mrwashwala_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Mr. WashWala Mobile App', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Version 1.0.0 (Android Build)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your trusted laundry & dry cleaning partner in Mysuru. Fast pickup, eco-friendly fabric care, and reliable doorstep delivery.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
