import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class GetCartUseCase extends NoParamsUseCase<Cart> {
  final CartRepository repository;

  GetCartUseCase(this.repository);

  @override
  Future<Either<Failure, Cart>> call() async {
    return await repository.getCart();
  }
}
