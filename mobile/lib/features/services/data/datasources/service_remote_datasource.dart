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
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
        if (category != null) 'category': category,
        if (search != null) 'search': search,
      };

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
      return ServiceModel.fromJson(response.data['data']);
    } on DioException {
      rethrow;
    }
  }
}
