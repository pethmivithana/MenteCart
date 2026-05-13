import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class AddCartItemUseCase extends UseCase<CartItem, AddCartItemParams> {
  final CartRepository repository;

  AddCartItemUseCase(this.repository);

  @override
  Future<Either<Failure, CartItem>> call(AddCartItemParams params) async {
    return await repository.addItem(
      serviceId: params.serviceId,
      serviceName: params.serviceName,
      price: params.price,
      quantity: params.quantity,
      selectedDate: params.selectedDate,
      selectedSlot: params.selectedSlot,
    );
  }
}

class AddCartItemParams {
  final String serviceId;
  final String serviceName;
  final double price;
  final int quantity;
  final DateTime? selectedDate;
  final String? selectedSlot;

  AddCartItemParams({
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.quantity,
    this.selectedDate,
    this.selectedSlot,
  });
}
