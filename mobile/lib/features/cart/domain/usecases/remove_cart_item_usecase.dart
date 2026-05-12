import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/use_case.dart';
import '../repositories/cart_repository.dart';

class RemoveCartItemUseCase extends UseCase<void, String> {
  final CartRepository repository;

  RemoveCartItemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String itemId) async {
    return await repository.removeItem(itemId);
  }
}
