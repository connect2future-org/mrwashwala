import 'package:flutter/foundation.dart';
import '../../../data/models/service_model.dart';
import '../../../data/repositories/service_repository.dart';

class ServiceController extends ChangeNotifier {
  final ServiceRepository _serviceRepository;

  static const List<String> primaryCategories = [
    'Wash & Fold',
    'Dry Cleaning',
    'Shoe Cleaning',
    'Wash & Iron',
    'Customize Your Service',
  ];

  bool _isLoading = false;
  String? _errorMessage;
  List<ServiceModel> _allServices = [];
  String _selectedCategory = 'Wash & Fold';
  String _selectedSubcategory = 'All';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ServiceModel> get allServices => _allServices;
  List<ServiceModel> get services => _allServices;
  String get selectedCategory => _selectedCategory;
  String get selectedSubcategory => _selectedSubcategory;

  ServiceController({ServiceRepository? serviceRepository})
      : _serviceRepository = serviceRepository ?? ServiceRepository();

  /// Main display services (Wash & Fold, Wash & Iron, Dry Cleaning, Shoe Cleaning, etc.)
  List<ServiceModel> get mainServices {
    return _allServices.where((s) => s.displayType == 'main').toList();
  }

  /// Featured services for Home Screen banner / highlight section
  List<ServiceModel> get featuredServices {
    return _allServices.where((s) => s.featured || s.displayType == 'main').toList();
  }

  /// The five main categories for Services Screen (no "All" option)
  List<String> get categories => primaryCategories;

  /// Dynamically derived subcategories for the currently selected category
  List<String> get subcategories {
    final subSet = <String>{'All'};
    final normCat = _selectedCategory.toLowerCase();
    for (final s in _allServices) {
      if (_isServiceInCategory(s, normCat) && s.customizeSubcategory.isNotEmpty) {
        subSet.add(s.customizeSubcategory);
      }
    }
    return subSet.toList();
  }

  /// Services filtered by selected category and subcategory
  List<ServiceModel> get filteredServices {
    final normCat = _selectedCategory.toLowerCase();
    return _allServices.where((s) {
      if (!_isServiceInCategory(s, normCat)) {
        return false;
      }
      if (_selectedSubcategory != 'All' && s.customizeSubcategory != _selectedSubcategory) {
        return false;
      }
      return true;
    }).toList();
  }

  bool _isServiceInCategory(ServiceModel s, String normCat) {
    if (normCat == 'wash & fold') {
      return s.name.toLowerCase().contains('wash & fold') ||
          s.customizeCategory.toLowerCase().contains('wash & fold');
    }

    if (normCat == 'dry cleaning' || normCat == 'dry clean') {
      return s.customizeCategory.toLowerCase() == 'dry clean' ||
          s.name.toLowerCase().contains('dry clean') ||
          s.name.toLowerCase().contains('dry cleaning');
    }

    if (normCat == 'shoe cleaning' || normCat == 'shoe care') {
      return s.customizeCategory.toLowerCase() == 'shoe cleaning' ||
          s.name.toLowerCase().contains('shoe');
    }

    if (normCat == 'wash & iron' || normCat == 'steam press') {
      return s.name.toLowerCase().contains('wash & iron') ||
          s.name.toLowerCase().contains('steam press') ||
          s.customizeCategory.toLowerCase().contains('wash & iron');
    }

    if (normCat == 'customize your service' ||
        normCat == 'additional services' ||
        normCat == 'customize') {
      return s.name.toLowerCase().contains('customize') ||
          s.customizeCategory.toLowerCase() == 'additional services' ||
          s.customizeCategory.toLowerCase() == 'bed sheet washing' ||
          s.customizeCategory.toLowerCase() == 'blanket washing';
    }

    // Direct match for any other custom category name or displayType
    return s.customizeCategory.toLowerCase() == normCat ||
        s.displayType.toLowerCase() == normCat;
  }

  /// Fetches services from backend and resets filters
  Future<void> fetchServices() => loadServices();

  Future<void> loadServices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _serviceRepository.fetchServices();
      // Exclude test entries from customer-facing services catalogue
      final customerServices = fetched.where((s) => !s.isTestService).toList();
      customerServices.sort((a, b) {
        final orderComp = a.sortOrder.compareTo(b.sortOrder);
        if (orderComp != 0) return orderComp;
        return a.name.compareTo(b.name);
      });
      _allServices = customerServices;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _cleanErrorMessage(e.toString());
      notifyListeners();
    }
  }

  void setCategory(String category) {
    final target = (category == 'All' || category.isEmpty) ? 'Wash & Fold' : category;
    if (_selectedCategory == target) return;
    _selectedCategory = target;
    _selectedSubcategory = 'All';
    notifyListeners();
  }

  void setSubcategory(String subcategory) {
    if (_selectedSubcategory == subcategory) return;
    _selectedSubcategory = subcategory;
    notifyListeners();
  }

  String _cleanErrorMessage(String rawMessage) {
    return rawMessage.replaceAll('ApiException: ', '').replaceAll('Exception: ', '').trim();
  }
}
