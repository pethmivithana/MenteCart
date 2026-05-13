import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/use_case.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase extends NoParamsUseCase<void> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call() async {
    await repository.logout();
    return const Right(null);
  }
}
