import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Abstract base class for all Use Cases.
/// Forces a consistent call interface across the domain layer.
/// Returns Either<Failure, Type> for result/error handling
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case with no parameters.
abstract class NoParamsUseCase<Type> {
  Future<Either<Failure, Type>> call();
}

/// Marker class for use cases that need no params.
class NoParams {
  const NoParams();
}
