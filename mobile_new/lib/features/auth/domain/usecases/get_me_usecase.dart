import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetMeUseCase extends NoParamsUseCase<User> {
  final AuthRepository repository;

  GetMeUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call() async {
    return await repository.getMe();
  }
}
