import 'service_model.dart';

class CartItemModel {
  final String serviceId;
  final String name;
  final double price;
  final String unit;
  final int quantity;
  final bool stainRemoval;
  final double stainRemovalPrice;
  final bool premiumClean;
  final double premiumCleanPrice;

  CartItemModel({
    required this.serviceId,
    required this.name,
    required this.price,
    required this.unit,
    this.quantity = 1,
    this.stainRemoval = false,
    this.stainRemovalPrice = 0.0,
    this.premiumClean = false,
    this.premiumCleanPrice = 0.0,
  });

  factory CartItemModel.fromService(
    ServiceModel service, {
    int quantity = 1,
    bool stainRemoval = false,
    bool premiumClean = false,
  }) {
    return CartItemModel(
      serviceId: service.id,
      name: service.name,
      price: service.price,
      unit: service.unit,
      quantity: quantity > 0 ? quantity : 1,
      stainRemoval: stainRemoval,
      stainRemovalPrice: service.stainRemovalPrice,
      premiumClean: premiumClean,
      premiumCleanPrice: service.premiumCleanPrice,
    );
  }

  /// Calculates line total = (unit price + active addons) * quantity
  double get unitTotalCost {
    double total = price;
    if (stainRemoval) total += stainRemovalPrice;
    if (premiumClean) total += premiumCleanPrice;
    return total;
  }

  double get lineTotal => unitTotalCost * quantity;

  String get formattedUnitPrice {
    if (price == 0) return 'Custom Quote';
    return '₹${price.toInt() == price ? price.toInt() : price.toStringAsFixed(2)} / $unit';
  }

  String get formattedLineTotal {
    if (lineTotal == 0) return 'Custom Quote';
    return '₹${lineTotal.toInt() == lineTotal ? lineTotal.toInt() : lineTotal.toStringAsFixed(2)}';
  }

  CartItemModel copyWith({
    int? quantity,
    bool? stainRemoval,
    bool? premiumClean,
  }) {
    return CartItemModel(
      serviceId: serviceId,
      name: name,
      price: price,
      unit: unit,
      quantity: quantity ?? this.quantity,
      stainRemoval: stainRemoval ?? this.stainRemoval,
      stainRemovalPrice: stainRemovalPrice,
      premiumClean: premiumClean ?? this.premiumClean,
      premiumCleanPrice: premiumCleanPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'name': name,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'stainRemoval': stainRemoval,
      'stainRemovalPrice': stainRemovalPrice,
      'premiumClean': premiumClean,
      'premiumCleanPrice': premiumCleanPrice,
      'lineTotal': lineTotal,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      serviceId: json['serviceId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? 'item',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      stainRemoval: json['stainRemoval'] ?? false,
      stainRemovalPrice: (json['stainRemovalPrice'] as num?)?.toDouble() ?? 0.0,
      premiumClean: json['premiumClean'] ?? false,
      premiumCleanPrice: (json['premiumCleanPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
