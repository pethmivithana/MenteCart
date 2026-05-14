import 'package:dio/dio.dart';
import '../models/service_model.dart';

/// Contract for service remote operations
abstract class ServiceRemoteDataSource {
  Future<ServiceListResponseModel> getServices({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
  });

  Future<ServiceModel> getServiceById(String id);
}

/// Implementation using Dio
class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  final Dio dio;

  ServiceRemoteDataSourceImpl(this.dio);

  @override
  Future<ServiceListResponseModel> getServices({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await dio.get(
        '/services',
        queryParameters: queryParams,
      );
      return ServiceListResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<ServiceModel> getServiceById(String id) async {
    try {
      final response = await dio.get('/services/$id');
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'] as Map<String, dynamic>;
      final serviceJson = data['service'] as Map<String, dynamic>;
      return ServiceModel.fromJson(serviceJson);
    } on DioException {
      rethrow;
    }
  }
}
