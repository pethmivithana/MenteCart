import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/service.dart';
import '../repositories/service_repository.dart';

class GetServiceByIdUseCase extends UseCase<Service, String> {
  final ServiceRepository repository;

  GetServiceByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Service>> call(String id) async {
    return await repository.getServiceById(id);
  }
}
