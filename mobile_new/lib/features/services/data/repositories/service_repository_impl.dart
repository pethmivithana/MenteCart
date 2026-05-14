import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/exception_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/service.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/service_remote_datasource.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceRemoteDataSource remoteDataSource;

  ServiceRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ServiceListResponse>> getServices({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
  }) async {
    try {
      final response = await remoteDataSource.getServices(
        page: page,
        limit: limit,
        category: category,
        search: search,
      );
      return Right(
        ServiceListResponse(
          services: response.data.map((m) => m.toEntity()).toList(),
          total: response.total,
          page: response.page,
          limit: response.limit,
          totalPages: response.totalPages,
        ),
      );
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Service>> getServiceById(String id) async {
    try {
      final model = await remoteDataSource.getServiceById(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
