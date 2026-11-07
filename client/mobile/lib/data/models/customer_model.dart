import 'address_model.dart';

class CustomerModel {
  final String id;
  final String phone;
  final String? name;
  final String? email;
  final String? avatar;
  final List<AddressModel> addresses;
  final bool isActive;

  CustomerModel({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.avatar,
    this.addresses = const [],
    this.isActive = true,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    var rawAddresses = json['addresses'];
    List<AddressModel> parsedAddresses = [];

    if (rawAddresses is List) {
      parsedAddresses = rawAddresses
          .map((a) => AddressModel.fromJson(a as Map<String, dynamic>))
          .toList();
    }

    return CustomerModel(
      id: json['_id'] ?? json['id'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      addresses: parsedAddresses,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'phone': phone,
      'name': name,
      'email': email,
      'avatar': avatar,
      'addresses': addresses.map((a) => a.toJson()).toList(),
      'isActive': isActive,
    };
  }

  CustomerModel copyWith({
    String? name,
    String? email,
    String? avatar,
    List<AddressModel>? addresses,
  }) {
    return CustomerModel(
      id: id,
      phone: phone,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      addresses: addresses ?? this.addresses,
      isActive: isActive,
    );
  }
}
