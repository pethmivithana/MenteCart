import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart.dart';

/// Cart repository contract
abstract class CartRepository {
  /// Get current user cart
  Future<Either<Failure, Cart>> getCart();

  /// Add item to cart
  Future<Either<Failure, CartItem>> addItem({
    required String serviceId,
    required String serviceName,
    required double price,
    required int quantity,
    DateTime? selectedDate,
    String? selectedSlot,
  });

  /// Update cart item quantity
  Future<Either<Failure, CartItem>> updateItem(
    String itemId, {
    required int quantity,
    DateTime? selectedDate,
    String? selectedSlot,
  });

  /// Remove item from cart
  Future<Either<Failure, void>> removeItem(String itemId);
}
