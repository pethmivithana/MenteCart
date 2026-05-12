import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class UpdateCartItemUseCase extends UseCase<CartItem, UpdateCartItemParams> {
  final CartRepository repository;

  UpdateCartItemUseCase(this.repository);

  @override
  Future<Either<Failure, CartItem>> call(UpdateCartItemParams params) async {
    return await repository.updateItem(
      params.itemId,
      quantity: params.quantity,
      selectedDate: params.selectedDate,
      selectedSlot: params.selectedSlot,
    );
  }
}

class UpdateCartItemParams {
  final String itemId;
  final int quantity;
  final DateTime? selectedDate;
  final String? selectedSlot;

  UpdateCartItemParams({
    required this.itemId,
    required this.quantity,
    this.selectedDate,
    this.selectedSlot,
  });
}
