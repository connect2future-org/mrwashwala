import "package:flutter/material.dart";
import "../../../app/theme/app_colors.dart";
import "../../../core/constants/app_constants.dart";
import "../../../data/models/address_model.dart";
import "address_controller.dart";

class AddEditAddressScreen extends StatefulWidget {
  final AddressController addressController;
  final String token;
  final AddressModel? addressToEdit;

  const AddEditAddressScreen({
    super.key,
    required this.addressController,
    required this.token,
    this.addressToEdit,
  });

  bool get isEditing => addressToEdit != null;

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedLabel;
  late TextEditingController _fullAddressController;
  late TextEditingController _houseNoController;
  late TextEditingController _streetController;
  late TextEditingController _landmarkController;
  late TextEditingController _cityController;
  late TextEditingController _pincodeController;
  late bool _isDefault;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final addr = widget.addressToEdit;
    _selectedLabel = addr?.label ?? "Home";
    _fullAddressController = TextEditingController(text: addr?.fullAddress ?? "");
    _houseNoController = TextEditingController(text: addr?.houseNo ?? "");
    _streetController = TextEditingController(text: addr?.street ?? "");
    _landmarkController = TextEditingController(text: addr?.landmark ?? "");
    _cityController = TextEditingController(text: addr?.city ?? "Mysuru");
    _pincodeController = TextEditingController(text: addr?.pincode ?? "");
    _isDefault = addr?.isDefault ?? false;
  }

  @override
  void dispose() {
    _fullAddressController.dispose();
    _houseNoController.dispose();
    _streetController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    bool success;
    if (widget.isEditing) {
      success = await widget.addressController.updateAddress(
        widget.token,
        widget.addressToEdit!.addressId,
        label: _selectedLabel,
        fullAddress: _fullAddressController.text,
        houseNo: _houseNoController.text,
        street: _streetController.text,
        landmark: _landmarkController.text,
        city: _cityController.text,
        pincode: _pincodeController.text,
        isDefault: _isDefault,
      );
    } else {
      success = await widget.addressController.addAddress(
        widget.token,
        fullAddress: _fullAddressController.text,
        label: _selectedLabel,
        houseNo: _houseNoController.text,
        street: _streetController.text,
        landmark: _landmarkController.text,
        city: _cityController.text,
        pincode: _pincodeController.text,
        isDefault: _isDefault,
      );
    }

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing ? "Address updated successfully" : "Address added successfully",
          ),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = widget.addressController.errorMessage ?? "Operation failed";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? "Edit Delivery Address" : "Add New Delivery Address";

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Error Display Banner
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.errorRed, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: AppColors.errorRed, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Address Type Selection Chips
                const Text(
                  "Address Type",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ["Home", "Work", "Other"].map((label) {
                    final isSelected = _selectedLabel == label;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        selectedColor: AppColors.primaryNavy,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.primaryNavy,
                          fontWeight: FontWeight.w600,
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
                    labelText: "Full Address / Building Name *",
                    hintText: "Enter complete street address",
                    alignLabelWithHint: true,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Please enter full address";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // House / Flat No & Street
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _houseNoController,
                        decoration: const InputDecoration(
                          labelText: "Flat / House No",
                          hintText: "e.g. 102, 2nd Floor",
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _streetController,
                        decoration: const InputDecoration(
                          labelText: "Street / Area",
                          hintText: "e.g. 5th Main",
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Landmark Input
                TextFormField(
                  controller: _landmarkController,
                  decoration: const InputDecoration(
                    labelText: "Landmark (Optional)",
                    hintText: "e.g. Near Water Tank",
                  ),
                ),

                const SizedBox(height: 12),

                // City & Pincode
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: "City *",
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "City required";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _pincodeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Pincode *",
                          hintText: "6-digit code",
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Pincode required";
                          }
                          if (val.trim().length != 6 || int.tryParse(val.trim()) == null) {
                            return "Invalid 6-digit pincode";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Default Switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    "Set as default delivery address",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    "This address will be selected automatically during checkout",
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  value: _isDefault,
                  activeTrackColor: AppColors.primaryNavy,
                  onChanged: (val) {
                    setState(() {
                      _isDefault = val;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    child: _isSubmitting
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text("Saving Address..."),
                            ],
                          )
                        : Text(widget.isEditing ? "Update Address" : "Save Address"),
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
