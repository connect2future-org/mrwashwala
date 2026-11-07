import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../checkout/presentation/checkout_controller.dart';

class AddAddressDialog extends StatefulWidget {
  final CheckoutController checkoutController;
  final String? token;

  const AddAddressDialog({
    super.key,
    required this.checkoutController,
    this.token,
  });

  @override
  State<AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<AddAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullAddressController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  String _selectedLabel = 'Home';
  bool _isSaving = false;

  @override
  void dispose() {
    _fullAddressController.dispose();
    _houseNoController.dispose();
    _streetController.dispose();
    _landmarkController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
    });

    final fullAddress = _fullAddressController.text.trim();

    if (widget.token != null && widget.token!.isNotEmpty) {
      final success = await widget.checkoutController.addNewAddress(
        widget.token!,
        fullAddress: fullAddress,
        label: _selectedLabel,
        houseNo: _houseNoController.text.trim(),
        street: _streetController.text.trim(),
        landmark: _landmarkController.text.trim(),
        pincode: _pincodeController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        if (success) {
          Navigator.of(context).pop(fullAddress);
        }
      }
    } else {
      widget.checkoutController.setCustomAddress(fullAddress);
      Navigator.of(context).pop(fullAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Delivery Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Label selector (Home / Work / Other)
                Row(
                  children: ['Home', 'Work', 'Other'].map((label) {
                    final isSelected = _selectedLabel == label;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        selectedColor: AppColors.primaryNavy,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.primaryNavy,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedLabel = label;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Full Address Input
                TextFormField(
                  controller: _fullAddressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Full Address *',
                    hintText: 'House No., Building, Street, Area, Mysuru',
                    prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.accentCyan),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Full address is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // House No & Street
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _houseNoController,
                        decoration: const InputDecoration(
                          labelText: 'Flat / House No.',
                          hintText: 'e.g. #42',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _streetController,
                        decoration: const InputDecoration(
                          labelText: 'Street / Area',
                          hintText: 'e.g. 5th Main',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Landmark & Pincode
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _landmarkController,
                        decoration: const InputDecoration(
                          labelText: 'Landmark',
                          hintText: 'Near Park',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _pincodeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Pincode',
                          hintText: '570001',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Save Address'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
