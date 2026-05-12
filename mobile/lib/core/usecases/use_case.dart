/// Abstract base class for all Use Cases.
/// Forces a consistent call interface across the domain layer.
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Use case with no parameters.
abstract class NoParamsUseCase<Type> {
  Future<Type> call();
}

/// Marker class for use cases that need no params.
class NoParams {
  const NoParams();
}
