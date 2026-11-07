import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/address_model.dart';
import 'add_edit_address_screen.dart';
import 'address_controller.dart';

class SavedAddressesScreen extends StatefulWidget {
  final AddressController addressController;
  final String token;

  const SavedAddressesScreen({
    super.key,
    required this.addressController,
    required this.token,
  });

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.addressController.loadAddresses(widget.token);
    });
  }

  void _openAddAddress() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditAddressScreen(
          addressController: widget.addressController,
          token: widget.token,
        ),
      ),
    );
  }

  void _openEditAddress(AddressModel address) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditAddressScreen(
          addressController: widget.addressController,
          token: widget.token,
          addressToEdit: address,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(AddressModel address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address?'),
        content: Text("Are you sure you want to delete '${address.label} - ${address.fullAddress}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await widget.addressController.deleteAddress(widget.token, address.addressId);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address deleted successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Saved Addresses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Address',
            onPressed: _openAddAddress,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddAddress,
        backgroundColor: AppColors.primaryNavy,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add New Address', style: TextStyle(color: Colors.white)),
      ),
      body: ListenableBuilder(
        listenable: widget.addressController,
        builder: (context, _) {
          final ctrl = widget.addressController;

          if (ctrl.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (ctrl.errorMessage != null && !ctrl.hasAddresses) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.errorRed),
                    const SizedBox(height: 12),
                    Text(
                      ctrl.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ctrl.loadAddresses(widget.token),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!ctrl.hasAddresses) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.iceBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_off_outlined, size: 48, color: AppColors.primaryNavy),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Saved Addresses',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "You haven't added any delivery addresses yet. Add your home or office address for easy checkout.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _openAddAddress,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Delivery Address'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ctrl.loadAddresses(widget.token),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppConstants.defaultPadding).copyWith(bottom: 80),
              itemCount: ctrl.addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final addr = ctrl.addresses[index];
                return _buildAddressCard(addr, ctrl);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddressCard(AddressModel addr, AddressController ctrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: addr.isDefault ? AppColors.primaryNavy : AppColors.cardBorder,
          width: addr.isDefault ? 1.8 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      addr.label == 'Home'
                          ? Icons.home_outlined
                          : addr.label == 'Work'
                              ? Icons.work_outline
                              : Icons.location_city_outlined,
                      size: 14,
                      color: AppColors.primaryNavy,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      addr.label,
                      style: const TextStyle(
                        fontSize: 12,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'DEFAULT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.successGreen,
                    ),
                  ),
                ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    _openEditAddress(addr);
                  } else if (value == 'default') {
                    await ctrl.setDefaultAddress(widget.token, addr.addressId);
                  } else if (value == 'delete') {
                    _confirmDelete(addr);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit Address'),
                      ],
                    ),
                  ),
                  if (!addr.isDefault)
                    const PopupMenuItem(
                      value: 'default',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 18),
                          SizedBox(width: 8),
                          Text('Set as Default'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: AppColors.errorRed),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: AppColors.errorRed)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            addr.fullAddress,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryNavy,
            ),
          ),
          if (addr.houseNo.isNotEmpty || addr.street.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              [addr.houseNo, addr.street].where((s) => s.isNotEmpty).join(', '),
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
          if (addr.landmark.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              "Landmark: ${addr.landmark}",
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            "${addr.city} - ${addr.pincode}",
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primaryNavy),
          ),
        ],
      ),
    );
  }
}
