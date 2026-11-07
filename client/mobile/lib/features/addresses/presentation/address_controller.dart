import "package:flutter/foundation.dart";
import "../../../data/models/address_model.dart";
import "../../../data/repositories/address_repository.dart";

class AddressController extends ChangeNotifier {
  final AddressRepository _addressRepository;

  List<AddressModel> _addresses = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasAddresses => _addresses.isNotEmpty;

  AddressModel? get defaultAddress {
    if (_addresses.isEmpty) return null;
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _addresses.first;
    }
  }

  AddressController({AddressRepository? addressRepository})
      : _addressRepository = addressRepository ?? AddressRepository();

  /// Loads saved delivery addresses for the authenticated customer.
  Future<void> loadAddresses(String? token) async {
    if (token == null || token.isEmpty) {
      _addresses = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final list = await _addressRepository.fetchAddresses(token);
      _addresses = list;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new delivery address.
  Future<bool> addAddress(
    String token, {
    required String fullAddress,
    String label = "Home",
    String houseNo = "",
    String street = "",
    String landmark = "",
    String city = "Mysuru",
    String pincode = "",
    bool isDefault = false,
  }) async {
    if (fullAddress.trim().isEmpty) {
      _errorMessage = "Full delivery address is required.";
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updatedList = await _addressRepository.addAddress(
        token,
        fullAddress: fullAddress,
        label: label,
        houseNo: houseNo,
        street: street,
        landmark: landmark,
        city: city,
        pincode: pincode,
        isDefault: isDefault,
      );
      _addresses = updatedList;
      _isSaving = false;
      _successMessage = "Address added successfully";
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing address.
  Future<bool> updateAddress(
    String token,
    String addressId, {
    String? label,
    String? fullAddress,
    String? houseNo,
    String? street,
    String? landmark,
    String? city,
    String? pincode,
    bool? isDefault,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updatedList = await _addressRepository.updateAddress(
        token,
        addressId,
        label: label,
        fullAddress: fullAddress,
        houseNo: houseNo,
        street: street,
        landmark: landmark,
        city: city,
        pincode: pincode,
        isDefault: isDefault,
      );
      _addresses = updatedList;
      _isSaving = false;
      _successMessage = "Address updated successfully";
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// Sets a specific address as default.
  Future<bool> setDefaultAddress(String token, String addressId) async {
    return updateAddress(token, addressId, isDefault: true);
  }

  /// Deletes a saved address.
  Future<bool> deleteAddress(String token, String addressId) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updatedList = await _addressRepository.deleteAddress(token, addressId);
      _addresses = updatedList;
      _isSaving = false;
      _successMessage = "Address deleted successfully";
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  String _cleanErrorMessage(String rawMessage) {
    return rawMessage.replaceAll("ApiException: ", "").replaceAll("Exception: ", "").trim();
  }
}
