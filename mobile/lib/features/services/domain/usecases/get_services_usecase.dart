import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/service.dart';
import '../repositories/service_repository.dart';

class GetServicesUseCase
    extends UseCase<ServiceListResponse, GetServicesParams> {
  final ServiceRepository repository;

  GetServicesUseCase(this.repository);

  @override
  Future<Either<Failure, ServiceListResponse>> call(
    GetServicesParams params,
  ) async {
    return await repository.getServices(
      page: params.page,
      limit: params.limit,
      category: params.category,
      search: params.search,
    );
  }
}

class GetServicesParams {
  final int page;
  final int limit;
  final String? category;
  final String? search;

  GetServicesParams({
    this.page = 1,
    this.limit = 10,
    this.category,
    this.search,
  });
}
