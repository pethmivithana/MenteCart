import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/use_case.dart';
import '../repositories/auth_repository.dart';

class SignupUseCase extends UseCase<String, SignupParams> {
  final AuthRepository repository;

  SignupUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(SignupParams params) async {
    return await repository.signup(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}

class SignupParams {
  final String email;
  final String password;
  final String name;

  SignupParams({
    required this.email,
    required this.password,
    required this.name,
  });
}
