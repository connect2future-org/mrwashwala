class ServiceModel {
  final String id;
  final String name;
  final String unit;
  final double price;
  final double surahiUnitCost;
  final List<String> features;
  final bool featured;
  final String displayType;
  final String customizeCategory;
  final String customizeSubcategory;
  final bool isActive;
  final int sortOrder;
  final bool hasStainRemoval;
  final double stainRemovalPrice;
  final bool hasPremiumClean;
  final double premiumCleanPrice;

  ServiceModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    this.surahiUnitCost = 0.0,
    this.features = const [],
    this.featured = false,
    this.displayType = 'main',
    this.customizeCategory = '',
    this.customizeSubcategory = '',
    this.isActive = true,
    this.sortOrder = 0,
    this.hasStainRemoval = false,
    this.stainRemovalPrice = 0.0,
    this.hasPremiumClean = false,
    this.premiumCleanPrice = 0.0,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    var rawFeatures = json['features'];
    List<String> parsedFeatures = [];
    if (rawFeatures is List) {
      parsedFeatures = rawFeatures.map((f) => f.toString()).toList();
    }

    return ServiceModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      unit: json['unit'] ?? 'item',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      surahiUnitCost: (json['surahiUnitCost'] as num?)?.toDouble() ?? 0.0,
      features: parsedFeatures,
      featured: json['featured'] ?? false,
      displayType: json['displayType'] ?? 'main',
      customizeCategory: json['customizeCategory'] ?? '',
      customizeSubcategory: json['customizeSubcategory'] ?? '',
      isActive: json['isActive'] ?? true,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      hasStainRemoval: json['hasStainRemoval'] ?? false,
      stainRemovalPrice: (json['stainRemovalPrice'] as num?)?.toDouble() ?? 0.0,
      hasPremiumClean: json['hasPremiumClean'] ?? false,
      premiumCleanPrice: (json['premiumCleanPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'price': price,
      'surahiUnitCost': surahiUnitCost,
      'features': features,
      'featured': featured,
      'displayType': displayType,
      'customizeCategory': customizeCategory,
      'customizeSubcategory': customizeSubcategory,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'hasStainRemoval': hasStainRemoval,
      'stainRemovalPrice': stainRemovalPrice,
      'hasPremiumClean': hasPremiumClean,
      'premiumCleanPrice': premiumCleanPrice,
    };
  }

  /// Formatted price with currency symbol (e.g. ₹59 / kg or ₹300 / item)
  String get formattedPrice {
    if (price == 0) return 'Custom Quote';
    return '₹${price.toInt() == price ? price.toInt() : price.toStringAsFixed(2)} / $unit';
  }

  /// Returns true if this service is a test or fixture entry that must not be
  /// displayed in the customer-facing catalogue or offered for new orders.
  bool get isTestService {
    final lowerId = id.toLowerCase().trim();
    final lowerName = name.toLowerCase().trim();
    return lowerId == 'test-wash-fold' ||
        lowerId.startsWith('test-') ||
        lowerName == 'wash & fold test' ||
        lowerName.endsWith(' test') ||
        lowerName.contains('(test)');
  }
}
