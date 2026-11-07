import "../../core/config/api_config.dart";
import "../../core/network/api_client.dart";
import "../models/address_model.dart";

class AddressRepository {
  final ApiClient _apiClient;

  AddressRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches all saved delivery addresses for the authenticated customer.
  Future<List<AddressModel>> fetchAddresses(String token) async {
    final response = await _apiClient.get(
      ApiConfig.addresses,
      token: token,
    );

    if (response is Map<String, dynamic> && response["data"] is List) {
      final rawList = response["data"] as List;
      return rawList
          .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception("Unexpected response format when fetching addresses");
  }

  /// Adds a new delivery address for the authenticated customer.
  Future<List<AddressModel>> addAddress(
    String token, {
    required String fullAddress,
    String label = "Home",
    String houseNo = "",
    String street = "",
    String landmark = "",
    String city = "Mysuru",
    String pincode = "",
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    final body = {
      "label": label,
      "fullAddress": fullAddress.trim(),
      "houseNo": houseNo.trim(),
      "street": street.trim(),
      "landmark": landmark.trim(),
      "city": city.trim(),
      "pincode": pincode.trim(),
      "latitude": latitude,
      "longitude": longitude,
      "isDefault": isDefault,
    };

    final response = await _apiClient.post(
      ApiConfig.addresses,
      token: token,
      body: body,
    );

    if (response is Map<String, dynamic> && response["addresses"] is List) {
      final rawList = response["addresses"] as List;
      return rawList
          .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception("Unexpected response format when adding address");
  }

  /// Updates an existing address or sets it as default.
  Future<List<AddressModel>> updateAddress(
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
    final body = <String, dynamic>{};
    if (label != null) body["label"] = label;
    if (fullAddress != null) body["fullAddress"] = fullAddress.trim();
    if (houseNo != null) body["houseNo"] = houseNo.trim();
    if (street != null) body["street"] = street.trim();
    if (landmark != null) body["landmark"] = landmark.trim();
    if (city != null) body["city"] = city.trim();
    if (pincode != null) body["pincode"] = pincode.trim();
    if (isDefault != null) body["isDefault"] = isDefault;

    final url = "${ApiConfig.addresses}/$addressId";
    final response = await _apiClient.patch(url, token: token, body: body);

    if (response is Map<String, dynamic> && response["addresses"] is List) {
      final rawList = response["addresses"] as List;
      return rawList
          .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception("Unexpected response format when updating address");
  }

  /// Deletes a saved address by addressId.
  Future<List<AddressModel>> deleteAddress(String token, String addressId) async {
    final url = "${ApiConfig.addresses}/$addressId";
    final response = await _apiClient.delete(url, token: token);

    if (response is Map<String, dynamic> && response["addresses"] is List) {
      final rawList = response["addresses"] as List;
      return rawList
          .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception("Unexpected response format when deleting address");
  }
}
