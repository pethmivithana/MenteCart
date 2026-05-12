import 'package:equatable/equatable.dart';

/// CartItem entity
class CartItem extends Equatable {
  final String id;
  final String serviceId;
  final String serviceName;
  final double price;
  final int quantity;
  final DateTime? selectedDate;
  final String? selectedSlot;

  const CartItem({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.quantity,
    this.selectedDate,
    this.selectedSlot,
  });

  double get subtotal => price * quantity;

  @override
  List<Object?> get props => [
    id,
    serviceId,
    serviceName,
    price,
    quantity,
    selectedDate,
    selectedSlot,
  ];
}

/// Cart entity
class Cart extends Equatable {
  final List<CartItem> items;
  final String userId;
  final DateTime? expiresAt;

  const Cart({
    required this.items,
    required this.userId,
    this.expiresAt,
  });

  /// Calculate total price
  double get totalPrice => items.fold(0, (sum, item) => sum + item.subtotal);

  /// Count total items
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [items, userId, expiresAt];
}
