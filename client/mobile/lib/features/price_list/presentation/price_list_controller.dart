import 'package:flutter/foundation.dart';
import '../../../data/models/service_model.dart';
import '../../../data/repositories/service_repository.dart';

class PriceListController extends ChangeNotifier {
  final ServiceRepository _serviceRepository;

  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  String? _refreshError;
  List<ServiceModel> _services = [];

  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  String? get refreshError => _refreshError;
  List<ServiceModel> get services => _services;
  bool get hasData => _services.isNotEmpty;
  bool get isEmpty => _services.isEmpty && !_isLoading && _errorMessage == null;

  PriceListController({ServiceRepository? serviceRepository})
      : _serviceRepository = serviceRepository ?? ServiceRepository();

  /// Fetches the live service catalogue from the backend.
  /// If [isRefresh] is true, preserves current data and sets [refreshError] on failure.
  Future<void> loadPriceList({bool isRefresh = false}) async {
    if (isRefresh) {
      _isRefreshing = true;
      _refreshError = null;
    } else {
      _isLoading = true;
      _errorMessage = null;
      _refreshError = null;
    }
    notifyListeners();

    try {
      final fetched = await _serviceRepository.fetchServices();
      // Exclude test entries and sort by sortOrder
      final customerServices = fetched.where((s) => !s.isTestService).toList();
      customerServices.sort((a, b) {
        final orderComp = a.sortOrder.compareTo(b.sortOrder);
        if (orderComp != 0) return orderComp;
        return a.name.compareTo(b.name);
      });

      _services = customerServices;
      _errorMessage = null;
      _refreshError = null;
    } catch (e) {
      final cleanedMsg = _cleanErrorMessage(e.toString());
      if (_services.isNotEmpty) {
        _refreshError = cleanedMsg;
      } else {
        _errorMessage = cleanedMsg;
      }
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Groups services by their actual category from the API.
  /// Services with customizeCategory use that field; primary services without
  /// customizeCategory use their service name.
  Map<String, List<ServiceModel>> get groupedServices {
    final Map<String, List<ServiceModel>> groups = {};

    for (final service in _services) {
      final category = resolveCategory(service);
      groups.putIfAbsent(category, () => []).add(service);
    }

    // Sort items within each category
    for (final items in groups.values) {
      items.sort((a, b) {
        final orderComp = a.sortOrder.compareTo(b.sortOrder);
        if (orderComp != 0) return orderComp;
        return a.name.compareTo(b.name);
      });
    }

    // Sort categories with common priority
    final sortedKeys = groups.keys.toList()
      ..sort((a, b) => _categoryPriority(a).compareTo(_categoryPriority(b)));

    final Map<String, List<ServiceModel>> sortedGroups = {};
    for (final key in sortedKeys) {
      sortedGroups[key] = groups[key]!;
    }

    return sortedGroups;
  }

  /// Resolves the display category for a service based on actual API data.
  static String resolveCategory(ServiceModel service) {
    if (service.customizeCategory.trim().isNotEmpty) {
      return service.customizeCategory.trim();
    }
    final lowerName = service.name.toLowerCase().trim();
    if (lowerName.contains('wash & fold')) return 'Wash & Fold';
    if (lowerName.contains('wash & iron')) return 'Wash & Iron';
    if (lowerName.contains('shoe')) return 'Shoe Cleaning';
    if (lowerName.contains('dry clean')) return 'Dry Clean';
    return service.name.trim();
  }

  /// Formats the unit for display (e.g. "per kg", "per item", "per pair").
  static String formatUnit(String unit) {
    final lower = unit.toLowerCase().trim();
    switch (lower) {
      case 'kg':
        return 'per kg';
      case 'item':
        return 'per item';
      case 'pair':
        return 'per pair';
      case 'set':
        return 'per set';
      case 'carpet':
        return 'per carpet';
      case 'package':
        return 'per package';
      default:
        return 'per $unit';
    }
  }

  int _categoryPriority(String category) {
    final norm = category.toLowerCase();
    if (norm.contains('wash & fold')) return 1;
    if (norm.contains('wash & iron')) return 2;
    if (norm.contains('dry clean')) return 3;
    if (norm.contains('shoe clean')) return 4;
    if (norm.contains('bed sheet')) return 5;
    if (norm.contains('blanket')) return 6;
    if (norm.contains('additional')) return 7;
    return 8;
  }

  String _cleanErrorMessage(String rawMessage) {
    return rawMessage
        .replaceAll('ApiException: ', '')
        .replaceAll('Exception: ', '')
        .trim();
  }
}
