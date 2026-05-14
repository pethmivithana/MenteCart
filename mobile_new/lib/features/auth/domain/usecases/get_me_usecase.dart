import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetMeParams {
  final String? accessToken;

  const GetMeParams({this.accessToken});
}

class GetMeUseCase extends UseCase<User, GetMeParams> {
  final AuthRepository repository;

  GetMeUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(GetMeParams params) async {
    return repository.getMe(accessToken: params.accessToken);
  }
}
