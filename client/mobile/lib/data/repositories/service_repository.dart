import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../models/service_model.dart';

class ServiceRepository {
  final ApiClient _apiClient;

  ServiceRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches laundry services from the backend with optional server-side filters.
  Future<List<ServiceModel>> fetchServices({
    String? displayType,
    String? customizeCategory,
    String? customizeSubcategory,
    bool? featured,
  }) async {
    final queryParams = <String, String>{};

    if (displayType != null && displayType.isNotEmpty) {
      queryParams['displayType'] = displayType;
    }
    if (customizeCategory != null && customizeCategory.isNotEmpty) {
      queryParams['customizeCategory'] = customizeCategory;
    }
    if (customizeSubcategory != null && customizeSubcategory.isNotEmpty) {
      queryParams['customizeSubcategory'] = customizeSubcategory;
    }
    if (featured != null) {
      queryParams['featured'] = featured.toString();
    }

    final queryString = queryParams.isNotEmpty
        ? '?${Uri(queryParameters: queryParams).query}'
        : '';

    final url = '${ApiConfig.services}$queryString';
    final response = await _apiClient.get(url);

    if (response is List) {
      return response
          .map((json) => ServiceModel.fromJson(json as Map<String, dynamic>))
          .where((s) => !s.isTestService)
          .toList();
    }

    throw Exception('Unexpected response format when fetching services');
  }
}
