import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/service.dart';

/// Service repository contract
abstract class ServiceRepository {
  /// Get paginated list of services
  /// [page] - page number (1-indexed)
  /// [limit] - items per page
  /// [category] - optional category filter
  /// [search] - optional search query
  Future<Either<Failure, ServiceListResponse>> getServices({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
  });

  /// Get service by ID
  Future<Either<Failure, Service>> getServiceById(String id);
}
