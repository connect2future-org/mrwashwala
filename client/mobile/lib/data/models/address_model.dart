class AddressModel {
  final String addressId;
  final String label;
  final String fullAddress;
  final String houseNo;
  final String street;
  final String landmark;
  final String city;
  final String pincode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  AddressModel({
    required this.addressId,
    this.label = 'Home',
    required this.fullAddress,
    this.houseNo = '',
    this.street = '',
    this.landmark = '',
    this.city = 'Mysuru',
    this.pincode = '',
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      addressId: json['addressId'] ?? '',
      label: json['label'] ?? 'Home',
      fullAddress: json['fullAddress'] ?? '',
      houseNo: json['houseNo'] ?? '',
      street: json['street'] ?? '',
      landmark: json['landmark'] ?? '',
      city: json['city'] ?? 'Mysuru',
      pincode: json['pincode'] ?? '',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressId': addressId,
      'label': label,
      'fullAddress': fullAddress,
      'houseNo': houseNo,
      'street': street,
      'landmark': landmark,
      'city': city,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };
  }
}
